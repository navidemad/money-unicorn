# frozen_string_literal: true

module Openai
  class TextToSpeechService
    VALID_MODELS = %w[tts-1 tts-1-hd].freeze
    VALID_VOICES = %w[alloy echo fable nova shimmer onyx coral sage ash].freeze
    VALID_FORMATS = %w[mp3 opus aac flac wav flac].freeze
    VALID_LANGUAGES = %w[en].freeze
    
    DEFAULT_VOICE = "ash"
    DEFAULT_MODEL = "tts-1"
    DEFAULT_FORMAT = "mp3"
    DEFAULT_LANGUAGE = "en"
    DEFAULT_VOICE_SPEED = 0.8
    
    class InvalidParameterError < StandardError; end

    attr_reader :object, :text, :language, :voice, :model, :output_format, :voice_speed

    def initialize(
                  object:,
                  text:,
                  language: DEFAULT_LANGUAGE,
                  voice: DEFAULT_VOICE,
                  model: DEFAULT_MODEL,
                  output_format: DEFAULT_FORMAT,
                  voice_speed: DEFAULT_VOICE_SPEED
                )
      @object = object
      @text = text.to_s
      @language = language.to_s.downcase
      @voice = voice.to_s.downcase
      @model = model.to_s.downcase
      @output_format = output_format.to_s.downcase
      @voice_speed = voice_speed

      validate_parameters!
    end

    def synthesize
      client = create_client
      response = generate_speech(client)
      save_audio_file(response)
    rescue OpenAI::Error => e
      Rails.logger.error("OpenAI TTS error: #{e.message}")
      fallback_response("OpenAI API Error: #{e.message}")
    rescue StandardError => e
      Rails.logger.error("TTS Generation error: #{e.class}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      fallback_response("General Error: #{e.message}")
    end

    private

    def validate_parameters!
      errors = []
      errors << "Text cannot be empty" if text.blank?
      errors << "Invalid model. Must be one of: #{VALID_MODELS.join(', ')}" unless VALID_MODELS.include?(model)
      errors << "Invalid voice. Must be one of: #{VALID_VOICES.join(', ')}" unless VALID_VOICES.include?(voice)
      errors << "Invalid format. Must be one of: #{VALID_FORMATS.join(', ')}" unless VALID_FORMATS.include?(output_format)
      errors << "Invalid language. Must be one of: #{VALID_LANGUAGES.join(', ')}" unless VALID_LANGUAGES.include?(language)
      
      raise InvalidParameterError, errors.join(". ") if errors.any?
    end

    def create_client
      OpenAI::Client.new(
        access_token: fetch_api_key,
        log_errors: Rails.env.development?
      )
    end

    def fetch_api_key
      key = Rails.application.credentials.dig(:openai, :api_key)
      raise InvalidParameterError, "OpenAI API key not configured" if key.blank?
      key
    end

    def generate_speech(client)
      client.audio.speech(
        parameters: {
          model: model,
          input: process_text,
          voice: voice,
          response_format: output_format,
          speed: voice_speed,
        }
      )
    end

    def process_text
      # Limit text length according to OpenAI's constraints (4096 characters)
      truncated_text = text[0...4096]
      # Normalize whitespace and encode properly
      truncated_text.squish.encode('UTF-8', invalid: :replace, undef: :replace)
    end

    def save_audio_file(response)
      filename = generate_filename
      file_path = Rails.root.join("storage", "tmp", filename)

      # Ensure directory exists
      FileUtils.mkdir_p(File.dirname(file_path))

      File.binwrite(file_path, response)

      ActiveRecord::Base.transaction do
        audio_data = File.binread(file_path)
        stream = StringIO.new(audio_data)
        stream.rewind
        blob = ActiveStorage::Blob.create_and_upload!(io: stream, filename: File.basename(file_path), content_type: "audio/#{output_format}")
        blob.analyze
        object.audio.attach(blob)
      end

      schedule_cleanup(file_path)

      { audio_path: file_path }
    end

    def fallback_response(error)
      {
        audio_path: nil,
        error: error,
      }
    end

    def generate_filename
      timestamp = Time.current.strftime("%Y%m%d%H%M%S")
      uuid = SecureRandom.uuid
      "tts_#{timestamp}_#{uuid}.#{output_format}"
    end

    def schedule_cleanup(file_path)
      CleanupTempFileJob.set(wait: 1.hour).perform_later(file_path.to_s)
    end
  end
end