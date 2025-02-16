class CreateYoutubeShorts < ActiveRecord::Migration[8.1]
  def change
    create_table :youtube_shorts, id: :uuid do |t|
      t.references :youtube_channel, null: false, foreign_key: true, type: :uuid

      t.string :status, default: 'pending'
      t.string :title
      t.text :keywords
      t.text :description
      t.text :transcript

      t.timestamps
    end

    add_index :youtube_shorts, :status
  end
end


