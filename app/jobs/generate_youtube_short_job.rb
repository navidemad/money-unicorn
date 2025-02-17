# frozen_string_literal: true

class GenerateYoutubeShortJob < ApplicationJob
  queue_as :default

  def perform(youtube_channel_id:, youtube_short_id: nil)
    youtube_channel = YoutubeChannel.includes(:youtube_shorts).find(youtube_channel_id)
    youtube_short = youtube_short_id.present? ? youtube_channel.youtube_shorts.find(youtube_short_id) : youtube_channel.youtube_shorts.create!

    # Generate title and transcript
    if youtube_short.title.blank? || youtube_short.keywords.blank? || youtube_short.description.blank? || youtube_short.transcript.blank?
      data = Openai::ShortContentSpinningService.new(
        language: youtube_channel.language,
        niche: youtube_channel.niche,
        youtube_channel_shorts_titles: youtube_channel.youtube_shorts.pluck(:title)
      ).generate
      return nil if data.nil?

      youtube_short.title = data[:title]
      youtube_short.keywords = data[:keywords]
      youtube_short.description = data[:description]
      youtube_short.transcript = data[:transcript]
    end

    youtube_short.save! if youtube_short.changed?

    # Generate TTS audio
    if !youtube_short.audio.attached?
      tts_audio = Openai::TextToSpeechService.new(
        object: youtube_short,
        text: youtube_short.transcript,
        language: youtube_channel.language,
      ).synthesize
      return nil if tts_audio[:error].present?
    end
    audio_path = ActiveStorage::Blob.service.path_for(youtube_short.audio.key)

    # Generate SRT
    if !youtube_short.srt.attached?
      srt_audio = Openai::SpeechToSubtitlesService.new(
        object: youtube_short,
        audio_path: audio_path,
      ).generate_and_save
      return nil if srt_audio[:error].present?
    end
    srt_path = ActiveStorage::Blob.service.path_for(youtube_short.srt.key)

    # Compose video
    if !youtube_short.video.attached?
      video = VideoComposerService.new(object: youtube_short, audio_path: audio_path, srt_path: srt_path).compose
      return nil if video[:error].present?
    end

    # Update status
    youtube_short.update!(status: 'ready')
  rescue StandardError => e
    Rails.logger.error("Error generating short video: \\#{e.message}")
    youtube_short&.update(status: 'error') if youtube_short&.persisted?
  end
end 