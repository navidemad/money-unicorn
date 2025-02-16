# Money Unicorn

## Description

Ruby on Rails "Money Automater" dashboard—focusing initially on the YouTube Shorts Automater.

## Prompt

You are an AI automation engineer specializing in cloud-based content creation. Your task is to develop a Ruby on Rails-based pipeline for generating and uploading high-quality YouTube Shorts, using Google Cloud Text-to-Speech (TTS) for voiceovers, and OpenAI o1 models for content generation. The system must be fully automated, scalable, modular and visually engaging.

1. Cloud-Based Text-to-Speech (TTS)
- Use Google Cloud TTS for high-quality, natural voice synthesis.
- Support different languages and voices based on input.
- Optimize SSML tags for better pronunciation, pacing, and emphasis.
- Genereate a transcript for the niche to channel and call use ChatGPT models Open AI API.

2. Subtitles & On-Screen Text
- Auto-format subtitles service to limit characters per line.
- Add rounded background behind subtitles for better visibility.
- Implement word-by-word highlighting in sync with TTS narration.

1. Video Generation & Editing
- Use a ruby gem vips to merge visuals, text, and audio.
- Reduce fast cuts, slow down pacing, and enhance clarity.
- Use G4F API (SDXL Turbo) to generate AI-powered visuals.
- add dynamically a background musics free of rights.
- Make possible to add a background music

1. Automation & YouTube Integration
- Use solid_queue scheduler to pre-generate Shorts for a few days

Requirements:
- Cloud-based and scalable solution.
- Error handling for API failures and network issues.
- Modular Ruby on Rails code with clean structure.
- Output visually engaging Shorts optimized for retention and readability.
- Efficient API handling with retries and error management.

Ask me for more details if you need before giving me any code.

## YouTube Shorts Automation Pipeline

This Rails-based pipeline automates the generation and uploading of high-quality YouTube Shorts. It integrates the following components:

- **Google Cloud TTS**: Utilizes the google-cloud-text_to_speech gem for high-quality voice synthesis with SSML support.
- **AI Content Generation**: Integrates OpenAI via the openai gem to generate engaging content.
- **Video Composition**: Uses ruby-vips and a placeholder integration with the G4F (SDXL Turbo) API to merge visuals, audio, and subtitles.
- **Subtitle Formatting**: Implements a SubtitleService to format transcripts into readable subtitles, styled with Tailwind CSS in reusable UI components.
- **Background Processing**: Leverages ActiveJob with a solid_queue scheduler for asynchronous video processing, orchestrated through the GenerateYoutubeShortJob.
- **YouTube Integration**: Uploads completed videos to YouTube using a dedicated YouTubeUploaderService.

This pipeline ensures modularity, scalability, and a clean separation of concerns within the Rails application.