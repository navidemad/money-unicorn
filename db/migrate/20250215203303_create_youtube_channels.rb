class CreateYoutubeChannels < ActiveRecord::Migration[8.1]
  def change
    create_table :youtube_channels, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.string :nickname
      t.string :niche
      t.string :language

      t.timestamps
    end
  end
end
