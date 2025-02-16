class CreateYoutubeShorts < ActiveRecord::Migration[8.1]
  def change
    create_table :youtube_shorts, id: :uuid do |t|
      t.references :youtube_channel, null: false, foreign_key: true, type: :uuid

      t.string :subject
      t.string :language
      t.text :script
      t.text :keywords
      t.string :source
      t.string :concatenation_mode
      t.string :aspect_ratio
      t.integer :max_duration
      t.integer :simultaneous_videos
      t.boolean :enable_subtitles
      t.string :subtitle_font
      t.string :subtitle_position
      t.string :subtitle_color
      t.integer :subtitle_size
      t.string :subtitle_outline_color
      t.decimal :subtitle_outline_width

      t.timestamps
    end
  end
end
