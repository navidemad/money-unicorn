class Dashboard::Youtube::Channels::ShortsController < Dashboard::Youtube::Channels::ApplicationController
  before_action :set_youtube_short, only: %i[ show edit update destroy ]

  def index
    @youtube_shorts = @youtube_channel.shorts
  end

  def show
  end

  def new
    @youtube_short = @youtube_channel.build_short
  end

  def edit
  end

  def create
    @youtube_short = @youtube_channel.build_short(youtube_short_params)

    if @youtube_short.save
      redirect_to dashboard_youtube_channel_short_path(account_id: @youtube_channel.id, id: @youtube_short.id), notice: "Youtube short was successfully created."
    else
      render :new, status: :unprocessable_entity
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

  private
    def set_youtube_short
      @youtube_short = @youtube_channel.shorts.find(params.expect(:id))
    end

    def youtube_short_params
      params.expect(youtube_short: [ :title, :description, :url ])
    end
end
