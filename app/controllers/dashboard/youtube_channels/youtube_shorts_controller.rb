class Dashboard::YoutubeChannels::YoutubeShortsController < Dashboard::YoutubeChannels::ApplicationController
  before_action :set_youtube_short, only: %i[ edit update destroy regenerate ]

  def index
    @youtube_shorts = @youtube_channel.youtube_shorts
  end

  def edit
  end

  def create
    @youtube_short = @youtube_channel.youtube_shorts.build(youtube_short_params)

    if @youtube_short.save
      redirect_to dashboard_youtube_channel_short_path(account_id: @youtube_channel.id, id: @youtube_short.id), notice: "Youtube short was successfully created."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update
    if @youtube_short.update(youtube_short_params)
      redirect_to dashboard_youtube_channel_short_path(account_id: @youtube_channel.id, id: @youtube_short.id), notice: "Youtube short was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @youtube_short.destroy!
    redirect_to youtube_shorts_path, notice: "Youtube short was successfully destroyed.", status: :see_other
  end

  def regenerate
    GenerateYoutubeShortJob.perform_later(youtube_channel_id: @youtube_channel.id, youtube_short_id: @youtube_short.id)
    flash.now[:notice] = "Youtube short was enqueued for regeneration."
  end

  private
    def set_youtube_short
      @youtube_short = @youtube_channel.youtube_shorts.find(params.expect(:id))
    end

    def youtube_short_params
      params.expect(youtube_short: [ :title, :description, :url ])
    end
end
