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
from diffusers import DiffusionPipeline
import torch

from app import GOOGLE_API_KEY,extract_video_id

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
    text_prompt = f"""DExplain the given Thumbnail. Then describe a new thumbnail for me, that is inspired from the thumbnail and is revelant 
    to my script.Point out the similarities between my thumbnail and the given one's Here is the script\n{script}"""

    #also create a prompt for image gen
    image_prompt = f"""Give me just one prompt for an AI so that I can make an image similar to the image and is suitable for my script.
    Here's the script \n{script}"""

    # Prompt the model with text and the previously uploaded image.
    text_response = model.generate_content([thumb, text_prompt])
    image_response = model.generate_content([thumb,image_prompt])
    
    # markdown does not work in vscode and works only n jupter format
    # display(Markdown(">" + response.text))
    return text_response.text, image_response.text

def generate_image(image_prompt):
    # Load the pipeline
    pipeline = DiffusionPipeline.from_pretrained("runwayml/stable-diffusion-v1-5", torch_dtype=torch.float16)

    # Move the pipeline to GPU
    pipeline.to("cuda")

    # Generate an image
    result = pipeline(image_prompt).images[0]

    # Save or display the result
    result.save("output_image.png")

def main():
    url = input("Enter YouTube link: ")
    video_id = extract_video_id(url)
    script = input("Enter the Script")
    video_title = get_video_title(video_id)
    save_thumbnail(url,video_title)
    text,image = generate_from_thumb(video_title,script)

    print("\n",text)
    print("\nHere's a prompt for generating your thumbnail\n",image)

    #generate_image(image);

main()