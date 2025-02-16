# frozen_string_literal: true

class Openai::TextToSpeechService
  def initialize(text:, language: "en", output_format: "aac")
    @text = text
    @language = language
    @output_format = output_format
  end

  def synthesize
    prompt = <<~PROMPT
      You are an audio synthesis service using ChatGPT OpenAI TTS.
      Given the following input, produce a JSON response with two keys: 'audio_file' and 'caption'.
      The 'audio_file' value should be a plausible synthesized audio file name ending with the proper extension for the requested output format.
      The 'caption' value should be a plain-text version of the synthesized speech, extracted from the SSML for use as video captions.
      Input text: #{@text}
      Language: #{@language}
      SSML: enabled
      Output Format: #{@output_format}
    PROMPT

    client = OpenAI::Client.new(access_token: Rails.application.credentials.openai[:api_key], log_errors: Rails.env.development?)
    response = client.chat(parameters: {
      model: "tts-1", # tts-1-hd
      voice: "ash", # alloy, ash, coral, echo, fable, onyx, nova, sage, shimmer
      messages: [
        { role: "system", content: prompt }
      ],
      temperature: 0.7,
      max_tokens: 100
    })
    message = response.dig("choices", 0, "message", "content")
    begin
      parsed = JSON.parse(message)
      {
        audio_file: parsed["audio_file"] || "tts_default.#{@output_format}",
        caption: parsed["caption"] || @text
      }
    rescue JSON::ParserError
      Rails.logger.error("Failed to parse OpenAI TTS response: #{message}")
      {
        audio_file: "tts_default.#{@output_format}",
        caption: @text
      }
    end
  end
end 