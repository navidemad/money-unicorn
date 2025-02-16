class YoutubeShort < ApplicationRecord
  belongs_to :youtube_channel
  has_many_attached :video_files

  validates :subject, presence: true
  validates :max_duration, numericality: { only_integer: true, greater_than: 0 }
  validates :simultaneous_videos, numericality: { only_integer: true, greater_than: 0 }

  broadcasts_to ->(youtube_short) { [ youtube_short.channel, :youtube_shorts ] }, inserts_by: :prepend, target: "youtube_shorts", partial: "dashboard/youtube/channels/shorts/short"

  def to_partial_path
    "dashboard/youtube/channels/shorts/short"
  end
end
