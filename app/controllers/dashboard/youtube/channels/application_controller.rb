class Dashboard::Youtube::Channels::ApplicationController < Dashboard::ApplicationController
  before_action :set_youtube_channel

  private
    def set_youtube_channel
      @youtube_channel = YoutubeChannel.find(params.expect(:channel_id))
    end
end
