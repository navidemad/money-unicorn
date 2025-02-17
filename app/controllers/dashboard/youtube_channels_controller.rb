class Dashboard::YoutubeChannelsController < Dashboard::ApplicationController
  before_action :set_youtube_channel, only: %i[ show edit update destroy generate_youtube_short ]

  def index
    @youtube_channels = Current.user.youtube_channels.preload(youtube_shorts: { audio_attachment: :blob, srt_attachment: :blob, video_attachment: :blob, images_attachments: :blob })
  end

  def show
  end

  def new
    @youtube_channel = Current.user.youtube_channels.build
  end

  def edit
  end

  def create
    @youtube_channel = Current.user.youtube_channels.build(youtube_channel_params)

    if @youtube_channel.save
      redirect_to dashboard_youtube_channel_path(@youtube_channel), notice: "Youtube channel was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @youtube_channel.update(youtube_channel_params)
      redirect_to dashboard_youtube_channel_path(@youtube_channel), notice: "Youtube channel was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @youtube_channel.destroy!
    redirect_to dashboard_youtube_channels_path, notice: "Youtube channel was successfully destroyed.", status: :see_other
  end

  def generate_youtube_short
    GenerateYoutubeShortJob.perform_later(youtube_channel_id: @youtube_channel.id)
    flash.now[:notice] = "Youtube short was enqueued for generation."
  end

  private
    def set_youtube_channel
      @youtube_channel = Current.user.youtube_channels.find(params.expect(:id))
    end

    def youtube_channel_params
      params.expect(youtube_channel: [ :nickname, :niche, :language ])
    end
end
