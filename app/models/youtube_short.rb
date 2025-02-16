class YoutubeShort < ApplicationRecord
  belongs_to :youtube_channel
  has_many_attached :video_files

  validates :subject, presence: true
  validates :max_duration, numericality: { only_integer: true, greater_than: 0 }
  validates :simultaneous_videos, numericality: { only_integer: true, greater_than: 0 }
end
