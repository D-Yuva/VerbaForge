import google.generativeai as genai
from IPython.display import Markdown,display
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
import re
import urllib.request
from diffusers import StableDiffusionPipeline
import torch
import matplotlib.pyplot as plt
from pytube import YouTube

from app import GOOGLE_API_KEY,extract_video_id

url = input("Enter YouTube link: ")
video_id = extract_video_id(url)
script = input("Enter the Script")

genai.configure(api_key=GOOGLE_API_KEY)

def get_video_title(video_idd):
    # Fetch video title using YouTube Data API
    api_key = "AIzaSyBPpShSmXuu4sfmkD8PjCaEN-UrQ59G4SI"
    youtube = build('youtube', 'v3', developerKey=api_key)
    try:
        video_response = youtube.videos().list(
            part='snippet',
            id=video_idd
        ).execute()

        video_title = video_response['items'][0]['snippet']['title']
        print(f"\nVideo Title: {video_title}")
    except HttpError as e:
        print(f"Error fetching video title: {e}") 

    # clean the title a little bit 
    cleaned_title = re.sub(r'[^a-zA-Z0-9 ]', '', video_title)
    #return the video title to use
    return cleaned_title

def save_thumbnail(link,name_to_save):
  # making the name in proper format
  name_to_save = name_to_save + '.jpg'
  print(f"** Saving File {name_to_save} **\n")
  yt = YouTube(link)
  url = yt.thumbnail_url
  #let's clean the url till .jpg only
  end_index = url.find('.jpg') + 4  # Adding 4 to include '.jpg'
  cleaned_url = url[:end_index]
  urllib.request.urlretrieve(cleaned_url, name_to_save)
  print(f"** {name_to_save} Saved!! **")

def generate_from_thumb(thumbnail_name,script):

    thumb = genai.upload_file(path=f"{thumbnail_name}.jpg")
    print(f"Uploaded file '{thumb.display_name}' as: {thumb.uri}")

    # Choose a Gemini API model.
    model = genai.GenerativeModel(model_name="gemini-1.5-pro-latest")
     
    # create prompts- one for text gen
    text_prompt = f"""Please generate a thumbnail image for a video I'm making that visually combines the essence of the provided image and 
    the content of the provided script. The thumbnail should retain the overall aesthetic and style of the original image 
    while incorporating visual elements that represent the key points of the script.\nHere is the script for the video:\n{script}"""

    # Prompt the model with text and the previously uploaded image.
    text_response = model.generate_content([thumb, text_prompt])
    
    # markdown does not work in vscode and works only n jupter format
    # display(Markdown(">" + response.text))
    return text_response.text



def compile():
    video_title = get_video_title(video_id)
    save_thumbnail(url,video_title)
    response = generate_from_thumb(video_title,script)
    print("\n",response)

compile()