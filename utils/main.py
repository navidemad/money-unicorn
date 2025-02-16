from constants import *
from classes.Tts import TTS
from classes.YouTube import YouTube

youtube = YouTube(
    selected_account["id"],
    selected_account["nickname"],
    selected_account["firefox_profile"],
    selected_account["niche"],
    selected_account["language"]
)

tts = TTS()

youtube.generate_video(tts)
videos = youtube.get_videos()    
