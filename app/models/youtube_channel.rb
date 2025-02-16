class YoutubeChannel < ApplicationRecord
  has_many :shorts, class_name: "YoutubeShort", dependent: :destroy

  validates :nickname, :niche, :language, presence: true
end
