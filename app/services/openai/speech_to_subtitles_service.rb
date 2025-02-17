# frozen_string_literal: true

module Openai
  class SpeechToSubtitlesService
    VALID_MODELS = %w[whisper-1].freeze
    VALID_FORMATS = %w[mp3 opus aac flac wav flac].freeze
    VALID_LANGUAGES = %w[en].freeze
    
    DEFAULT_MODEL = "whisper-1"
    DEFAULT_FORMAT = "mp3"
    DEFAULT_LANGUAGE = "en"
    
    class InvalidParameterError < StandardError; end

    attr_reader :object, :audio_path, :audio_format, :language, :model

    def initialize(
                  object:,
                  audio_path:,
                  audio_format: DEFAULT_FORMAT,
                  language: DEFAULT_LANGUAGE,
                  model: DEFAULT_MODEL
                )
      @object = object
      @audio_path = audio_path
      @audio_format = audio_format
      @language = language.to_s.downcase
      @model = model.to_s.downcase

      validate_parameters!
    end

    def generate_and_save
      client = create_client
      response = generate_srt(client)
      save_subtitles_file(response)
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
      errors << "Invalid model. Must be one of: #{VALID_MODELS.join(', ')}" unless VALID_MODELS.include?(model)
      errors << "Invalid format. Must be one of: #{VALID_FORMATS.join(', ')}" unless VALID_FORMATS.include?(audio_format)
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

    # https://platform.openai.com/docs/api-reference/audio/createTranscription
    def generate_srt(client)
      file_path = File.extname(audio_path).present? ? audio_path : create_temp_file_with_extension
      begin
        client.audio.transcribe(
          parameters: {
            model: model,
            file: File.open(file_path, "rb"),
            language: language,
            response_format: "srt"
          }
        )
      ensure
        # Only delete if it's a temporary file we created
        File.delete(file_path) if file_path != audio_path && File.exist?(file_path)
      end
    end
    
    def create_temp_file_with_extension
      temp_dir = Rails.root.join("tmp", "audio_processing")
      FileUtils.mkdir_p(temp_dir)
      
      temp_file_path = File.join(temp_dir, "audio_#{SecureRandom.uuid}.#{audio_format}")
      FileUtils.cp(audio_path, temp_file_path)
      
      temp_file_path
    end

    def save_subtitles_file(response)
      filename = generate_filename
      srt_path = Rails.root.join("storage", "tmp", filename)

      # Ensure directory exists
      FileUtils.mkdir_p(File.dirname(srt_path))

      File.binwrite(srt_path, response)

      ActiveRecord::Base.transaction do
        srt_data = File.binread(srt_path)
        stream = StringIO.new(srt_data)
        stream.rewind
        blob = ActiveStorage::Blob.create_and_upload!(
          io: stream, 
          filename: File.basename(srt_path), 
          content_type: "application/x-subrip"
        )
        blob.analyze
        object.srt.attach(blob)
      end

      schedule_cleanup(srt_path)

      { srt_path: srt_path }
    end

    def fallback_response(error)
      {
        srt_path: nil,
        error: error,
      }
    end

    def generate_filename
      timestamp = Time.current.strftime("%Y%m%d%H%M%S")
      uuid = SecureRandom.uuid
      "subtitles_#{timestamp}_#{uuid}.srt"
    end

    def schedule_cleanup(file_path)
      CleanupTempFileJob.set(wait: 1.hour).perform_later(file_path.to_s)
    end
  end
end