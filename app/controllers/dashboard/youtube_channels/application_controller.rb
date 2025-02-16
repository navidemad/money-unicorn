class Dashboard::YoutubeChannels::ApplicationController < Dashboard::ApplicationController
  before_action :set_youtube_channel

  private
    def set_youtube_channel
      @youtube_channel = YoutubeChannel.find(params.expect(:youtube_channel_id))
    end
end
