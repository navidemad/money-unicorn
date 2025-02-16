# frozen_string_literal: true

class GenerateYoutubeShortJob < ApplicationJob
  queue_as :default

  def perform(youtube_channel_id:)
    youtube_channel = YoutubeChannel.find(youtube_channel_id)
    youtube_short = youtube_channel.shorts.build

    # Generate title and transcript
    if youtube_short.title.blank? || youtube_short.transcript.blank?
      data = Openai::ShortContentSpinningService.new(language: youtube_channel.language, niche: youtube_channel.niche).generate
      return nil if data.nil?
      parsed_data = JSON.parse(data)
      youtube_short.title = parsed_data[:title]
      youtube_short.keywords = parsed_data[:keywords]
      youtube_short.description = parsed_data[:description]
      youtube_short.transcript = parsed_data[:transcript]
      youtube_short.save! if youtube_short.new_record? || youtube_short.changed?
    end


    # # Generate TTS audio
    # tts_audio = Openai::TtsService.new(youtube_short.transcript, ssml: true).synthesize

    # # Format subtitles
    # subtitle_lines = SubtitleService.new(youtube_short.transcript).formatted_subtitles

    # # Compose video
    # final_video = VideoComposerService.new(audio_file: tts_audio, subtitle_lines: subtitle_lines).compose

    # # Upload video to YouTube
    # video_url = YouTubeUploaderService.new(final_video, youtube_short.title, youtube_short.transcript).upload

    # # Update the ShortVideo record
    # youtube_short.update(video_url: video_url, status: 'completed')
  rescue StandardError => e
    Rails.logger.error("Error generating short video: \\#{e.message}")
    youtube_short&.update(status: 'error')
  end
end 