class YoutubeShort < ApplicationRecord
  belongs_to :youtube_channel
  has_one_attached :audio
  has_one_attached :srt
  has_one_attached :video

  validates :status, presence: true

  broadcasts_to ->(youtube_short) { [ youtube_short.youtube_channel, :youtube_shorts ] }, inserts_by: :prepend, target: "youtube_shorts", partial: "dashboard/youtube_channels/youtube_shorts/youtube_short"

  def to_partial_path
    "dashboard/youtube_channels/youtube_shorts/youtube_short"
  end
end
