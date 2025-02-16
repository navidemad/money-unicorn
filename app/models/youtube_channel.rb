class YoutubeChannel < ApplicationRecord
  has_many :youtube_shorts, dependent: :destroy

  validates :nickname, :niche, :language, presence: true
end
