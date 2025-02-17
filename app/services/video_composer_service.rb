# frozen_string_literal: true
require 'shellwords'
require 'mini_magick'
require 'tempfile'
require 'open-uri'
require 'streamio-ffmpeg'
require 'base64'

class VideoComposerService
  attr_reader :object, :audio_path, :srt_path

  # Initializes the service with a YoutubeShort record
  def initialize(object:, audio_path:, srt_path:)
    @object = object
    @audio_path = audio_path
    @srt_path = srt_path
  end

  # Main method to compose the final mp4 video
  def compose
    client = create_client
    video_path = generate_video(client)
    return if video_path.nil?

    save_video_file(video_path)
  rescue OpenAI::Error => e
    Rails.logger.error("OpenAI Image Generation error: #{e.message}")
    fallback_response("OpenAI API Error: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("Image Generation error: #{e.class}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    fallback_response("General Error: #{e.message}")
  end

  private

  def create_client
    OpenAI::Client.new(
      access_token: fetch_api_key,
      log_errors: Rails.env.development?,
    )
  end

  def fetch_api_key
    key = Rails.application.credentials.dig(:openai, :api_key)
    raise InvalidParameterError, "OpenAI API key not configured" if key.blank?
    key
  end

  def generate_video(client)
    # Create temporary files that preserve the original extensions
    downloaded_audio_path = create_audio_temp_file_with_extension
    downloaded_srt_path = create_srt_temp_file_with_extension
    # Get total duration of the audio using ffprobe
    audio_duration = get_audio_duration(downloaded_audio_path)
    # (audio_duration could be very short; default to 10 sec if needed)
    audio_duration = 10 if audio_duration.nil? || audio_duration.zero?
    # Calculate number of images as (audio_duration / 10 seconds)
    number_of_images = (audio_duration.to_f / 10).ceil
    # Generate images based on the transcript (not SRT cues) using OpenAI's image generation
    image_paths = generate_images(client, object.transcript, number_of_images)
    # Calculate display duration per image
    per_image_duration = audio_duration.to_f / image_paths.size
    # Create an image sequence video from the images
    image_sequence_video = create_image_sequence(image_paths, per_image_duration)
    # Add the audio track to the image sequence video
    video_with_audio = add_audio_to_video(image_sequence_video, downloaded_audio_path)
    # Overlay subtitles and scale/pad to vertical 1080x1920 format
    add_subtitles(video_with_audio, downloaded_srt_path)
  end

  def save_video_file(video_path)
    ActiveRecord::Base.transaction do
      debugger
      video_data = File.binread(video_path)
      stream = StringIO.new(video_data)
      stream.rewind
      blob = ActiveStorage::Blob.create_and_upload!(
        io: stream,
        filename: File.basename(video_path),
        content_type: "video/mp4",
      )
      blob.analyze
      object.video.attach(blob)
    end
    schedule_cleanup(video_path)
    { video_path: video_path }
  end

  def fallback_response(error)
    { video_path: nil, error: error }
  end

  def create_audio_temp_file_with_extension
    temp_file_path = Rails.root.join("tmp", "audio_#{SecureRandom.uuid}.mp3")
    FileUtils.cp(audio_path, temp_file_path)
    temp_file_path
  end

  def create_srt_temp_file_with_extension
    temp_file_path = Rails.root.join("tmp", "srt_#{SecureRandom.uuid}.srt")
    FileUtils.cp(srt_path, temp_file_path)
    temp_file_path
  end

  # Uses ffprobe to get the duration of the audio file in seconds
  def get_audio_duration(_audio_path)
    command = "ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 #{Shellwords.escape(audio_path)}"
    output = `#{command}`.strip
    output.to_f
  end

  def clean_prompt(prompt)
    prompt.gsub(/[^\w\s.?!]/, ' ').squish
  end

  # Generates images based on the transcript using OpenAI's DALL-E 2
  # number_of_images: number of images to generate (audio_duration/10 seconds)
  def generate_images(client, transcript, number_of_images)
    return object.images if object.images.attached?

    niche = object.respond_to?(:youtube_channel) && object.youtube_channel.present? ? object.youtube_channel.niche : 'general'
    simple_transcript = clean_prompt(transcript)

    system_prompt = "You are an expert in DALL-E 2 image prompt generation. Provide detailed, engaging, and nuanced image prompts based on the context provided. ONLY output the prompt, nothing else. MAKE SURE THE PROMPT IS SHORT AND TO THE POINT AND LESS THAN 1000 CHARACTERS."
    user_prompt   = "Given the niche '#{niche}' and the transcript '#{simple_transcript}', generate a detailed prompt for creating an engaging image."

    # Requery OpenAI using model 'o1-mini' to generate an improved prompt
    improved_response = client.chat(parameters: {
      model: 'gpt-4o-mini',
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: user_prompt }
      ],
      temperature: 1.0
    })
    refined_prompt = improved_response.dig("choices", 0, "message", "content").strip
    refined_prompt = clean_prompt(refined_prompt)

    response = client.images.generate(parameters: {
      model: 'dall-e-2',
      prompt: refined_prompt,
      n: number_of_images,
      size: '1024x1024',
      response_format: 'b64_json'
    })
    
    response['data'].each.with_index(1) do |row, index| 
      image_data = Base64.decode64(row['b64_json'])
      ActiveRecord::Base.transaction do
        stream = StringIO.new(image_data)
        stream.rewind
        blob = ActiveStorage::Blob.create_and_upload!(
          io: stream,
          filename: "image_#{object.id}_#{index}.png",
          content_type: "image/png",
        )
        blob.analyze
        object.images.attach(blob)
      end
    end

    object.touch

    object.images
  end

  # Creates an image sequence video from a list of image paths.
  # Each image is displayed for per_image_duration seconds.
  def create_image_sequence(_image_paths, per_image_duration)
    # Use images from the object's ActiveStorage images attachment
    # Download each attached image to a file with sequential naming
    object.images.each_with_index do |image, index|
      file_path = Rails.root.join('tmp', "image_#{object.id}_#{index + 1}.png")
      File.binwrite(file_path, image.download)
    end
    # Calculate frame rate: each image is displayed for per_image_duration seconds
    pattern = Rails.root.join('tmp', "image_#{object.id}_%d.png").to_s
    fps = 1.0 / per_image_duration
    output_path = Rails.root.join('tmp', "image_sequence_#{object.id}.mp4").to_s
    command = "ffmpeg -y -framerate #{fps} -i #{Shellwords.escape(pattern)} -c:v libx264 -r 30 -pix_fmt yuv420p #{Shellwords.escape(output_path)}"
    system(command)
    output_path
  end

  # Adds the audio track to the video without audio using streamio-ffmpeg.
  def add_audio_to_video(video_without_audio, audio_path)
    movie = FFMPEG::Movie.new(video_without_audio)
    # Fix: Properly format the ffmpeg command options
    options = {
      audio_codec: 'aac',
      custom: [
        "-i", Shellwords.escape(audio_path),
        "-c:v", "copy"
      ]
    }
    output_path = Rails.root.join('tmp', "video_with_audio_#{object.id}.mp4").to_s
    movie.transcode(output_path, options, { validate: false })
    output_path
  end

  # Overlays subtitles onto the video and scales/pads to vertical 1080x1920 using streamio-ffmpeg.
  def add_subtitles(video_with_audio, srt_path)
    puts "\n\n\n\n\n------------------------ add_subtitles"
    movie = FFMPEG::Movie.new(video_with_audio)
    # Use a filter to add subtitles and scale the video to vertical 1080x1920.
    filter = [
      "subtitles=file:#{srt_path}:charenc=UTF-8",
      "scale=1080:1920:force_original_aspect_ratio=decrease",
      "pad=1080:1920:(ow-iw)/2:(oh-ih)/2",
    ].join(',')
    options = {
      video_codec: 'libx264',
      custom: [
        "-vf", filter,
      ],
    }
    output_path = Rails.root.join('tmp', "video_final_#{object.id}.mp4").to_s
    result = movie.transcode(output_path, options)
    puts "Transcoding result: #{result.inspect}"
    unless File.exist?(output_path)
      Rails.logger.error "add_subtitles failed: output file not created. Transcode result: #{result.inspect}"
      return nil
    end
    output_path
  end

  def schedule_cleanup(file_path)
    CleanupTempFileJob.set(wait: 1.hour).perform_later(file_path.to_s)
  end
end
