class Dashboard::Youtube::ChannelsController < Dashboard::ApplicationController
  before_action :set_youtube_channel, only: %i[ show edit update destroy ]

  def index
    @youtube_channels = Current.user.youtube_channels
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
    redirect_to youtube_channels_path, notice: "Youtube channel was successfully destroyed.", status: :see_other
  end

  private
    def set_youtube_channel
      @youtube_channel = Current.user.youtube_channels.find(params.expect(:id))
    end

    def youtube_channel_params
      params.expect(youtube_channel: [ :nickname, :niche, :language ])
    end
end
