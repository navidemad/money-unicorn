"""
This file contains all the constants used in the program.
"""
import g4f

# YouTube Section
YOUTUBE_TEXTBOX_ID = "textbox"
YOUTUBE_MADE_FOR_KIDS_NAME = "VIDEO_MADE_FOR_KIDS_MFK"
YOUTUBE_NOT_MADE_FOR_KIDS_NAME = "VIDEO_MADE_FOR_KIDS_NOT_MFK"
YOUTUBE_NEXT_BUTTON_ID = "next-button"
YOUTUBE_RADIO_BUTTON_XPATH = "//*[@id=\"radioLabel\"]"
YOUTUBE_DONE_BUTTON_ID = "done-button"

def parse_model(model_name: str) -> any:
    if model_name == "gpt4":
        return g4f.models.gpt_4
    elif model_name == "gpt35_turbo":
        return g4f.models.gpt_4o_mini
    elif model_name == "llama2_7b":
        return g4f.models.llama2_7b
    elif model_name == "llama2_13b":
        return g4f.models.llama2_13b
    elif model_name == "llama2_70b":
        return g4f.models.llama2_70b
    elif model_name == "mixtral_8x7b":
        return g4f.models.mixtral_8x7b
    else:
        # Default model is gpt3.5-turbo
        return g4f.models.gpt_4o_mini