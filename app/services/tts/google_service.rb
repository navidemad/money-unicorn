class Tts::GoogleService
  require "google/cloud/text_to_speech"

  def initialize
    @client = Google::Cloud::Text_to_speech.text_to_speech
  end

  # synthesize(text, output_path) method in GoogleTtsService class
  def synthesize(text, output_path)
    input = { text: text }
    voice = { language_code: "en-US", ssml_gender: "FEMALE" }
    audio_config = { audio_encoding: "MP3" }

    request = {
      input: input,
      voice: voice,
      audio_config: audio_config
    }

    response = @client.synthesize_speech(request)
    File.open(output_path, "wb") { |file| file.write(response.audio_content) }
  end
end