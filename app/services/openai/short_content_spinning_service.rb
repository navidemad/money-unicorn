# frozen_string_literal: true

class Openai::ShortContentSpinningService
  def initialize(language:, niche:)
    @language = language
    @niche = niche
  end

  def generate
    prompt = <<~PROMPT
      As an experienced YouTube shorts creator, your task is to write a short transcript for a YouTube Short video about #{@niche} in #{@language} language for a 1 minute reading time.
      The transcript should be engaging, concise, and captivating to capture the viewer's attention within the first few seconds.
      Incorporate trending elements, catchy phrases, and visually appealing content to keep the audience engaged throughout the video.
      Ensure that the transcript aligns with YouTube Shorts guidelines and best practices to maximize its reach and engagement potential.
      Based on the transcript and the title generated, provided accurately the keywords and description for the video.
      Format the output as a JSON object with keys "title", "keywords", "description", and "transcript".
    PROMPT

    client = OpenAI::Client.new(access_token: Rails.application.credentials.openai[:api_key], log_errors: Rails.env.development?)
    response = client.chat(parameters: {
      model: "gpt-4o-mini",
      messages: [
        { role: "user", content: prompt }
      ]
    })

    message = response.dig("choices", 0, "message", "content")

    begin
      parsed = JSON.parse(message)
      {
        title: parsed["title"],
        keywords: parsed["keywords"],
        description: parsed["description"],
        transcript: parsed["transcript"]
      }
    rescue JSON::ParserError
      Rails.logger.error("Failed to parse OpenAI response: #{message}")
      nil
    end
  end
end 