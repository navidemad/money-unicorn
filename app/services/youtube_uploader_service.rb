# frozen_string_literal: true

class YouTubeUploaderService
  def initialize(video_file, title, description)
    @video_file = video_file
    @title = title
    @description = description
  end

  def upload
    Rails.logger.info("Uploading video \\#{@video_file} to YouTube with title: \\#{@title}")
    # Placeholder: Implement YouTube API integration here
    "https://youtube.com/video/sample"
  end
end 