class Youtube::Shorts::AutoCreateService
  def initialize(youtube_channel)
    @youtube_channel = youtube_channel
  end

  def call
    # TODO: Implement the logic to auto create shorts for the youtube channel
    # Upload Twice a day
    # writing to a file with MoviePy
    # AssemblyAI API (assembly_ai_api_key)
    # Equalizes the subtitles in a SRT file with srt_equalizer (The maximum amount of characters in a subtitle)

    # "Upload Short",
    # "Show all Shorts",
    # "Setup CRON Job",

    # youtube.generate_video(tts)
    # youtube.upload_video()

    # Cron to generate shorts in advance for few days
    # Cron to upload shorts once a day
  end
end
