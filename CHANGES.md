## [Unreleased]
- Updated Gemfile with dependencies: google-cloud-text_to_speech, ruby-vips, and openai.
- Created a reusable subtitles UI component at app/views/components/_subtitles_component.html.erb using Tailwind CSS.
- Added service objects: GoogleCloudTtsService for TTS synthesis, SubtitleService for formatting subtitles, VideoComposerService for video composition, and YouTubeUploaderService for video uploading.
- Generated a migration for the short_videos table with fields: title, transcript, status, video_url, timestamps and added an index on status.
- Implemented GenerateYoutubeShortJob to orchestrate the video generation pipeline including audio synthesis, subtitle formatting, video composition, and uploading to YouTube.
- Refactored CleanupTempFileJob to replace hard-coded retry values with constants RETRY_WAIT_TIME (5.minutes) and MAX_RETRY_ATTEMPTS (3).
- Updated Openai::TextToSpeechService#store_with_active_storage to create a YoutubeShort record (using YoutubeChannel.first as placeholder) and attach the audio file to its video_files association instead of using TtsAudio.
