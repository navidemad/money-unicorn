
# Money Unicorn

## Description

Ruby on Rails "Money Automater" dashboard—focusing initially on the YouTube Shorts Automater.

## Prompt

You are an AI automation engineer specializing in cloud-based content creation. Your task is to develop a Python-based pipeline for generating and uploading high-quality YouTube Shorts, Tiktok Shorts, using Google Cloud Text-to-Speech (TTS) for voiceovers. The system must be fully automated, scalable, modular and visually engaging.

1. Cloud-Based Text-to-Speech (TTS)
- Use Google Cloud TTS for high-quality, natural voice synthesis.
- Support different languages and voices based on input.
- Optimize SSML tags for better pronunciation, pacing, and emphasis.
- Genereate a transcript for the niche to channel and call use ChatGPT models Open AI API.

2. Subtitles & On-Screen Text
- Use AssemblyAI API (assembly_ai_api_key) to transcribe audio.
- Auto-format subtitles using srt_equalizer (limit characters per line).
- Add rounded background behind subtitles for better visibility.
- Implement word-by-word highlighting in sync with TTS narration.

3. Video Generation & Editing
- Use MoviePy to merge visuals, text, and audio.
- Reduce fast cuts, slow down pacing, and enhance clarity.
- Use G4F (SDXL Turbo) to generate AI-powered visuals.
- add dynamically a background musics free of rights.
- Make possible to add a background music

4. Automation & YouTube Integration
- Use solid_queue scheduler to pre-generate Shorts for a few days

Requirements:
- Cloud-based and scalable solution.
- Error handling for API failures and network issues.
- Modular Ruby on Rails code with clean structure.
- Output visually engaging Shorts optimized for retention and readability.
- Efficient API handling with retries and error management.

Ask me for more details if you need before giving me any code.