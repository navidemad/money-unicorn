## [Unreleased]
- Updated Gemfile with dependencies: google-cloud-text_to_speech, ruby-vips, and openai.
- Created a reusable subtitles UI component at app/views/components/_subtitles_component.html.erb using Tailwind CSS.
- Added service objects: GoogleCloudTtsService for TTS synthesis, SubtitleService for formatting subtitles, VideoComposerService for video composition, and YouTubeUploaderService for video uploading.
- Generated a migration for the short_videos table with fields: title, transcript, status, video_url, timestamps and added an index on status.
- Implemented GenerateYoutubeShortJob to orchestrate the video generation pipeline including audio synthesis, subtitle formatting, video composition, and uploading to YouTube.
