import subprocess
import shutil
from flask import Flask, request, jsonify
import re
from youtube_transcript_api import YouTubeTranscriptApi, NoTranscriptFound
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from pytube import YouTube
import os
import time
import yt_dlp as youtube_dl
import google.generativeai as genai
import google.api_core.exceptions

app = Flask(__name__)

# Set your Google API Key here
GOOGLE_API_KEY = 'AIzaSyBHhq8EjXKqTXXrNXoCZ0m4Mpi1iXbAkTs'
os.environ['GOOGLE_API_KEY'] = GOOGLE_API_KEY
genai.configure(api_key=GOOGLE_API_KEY)

# Check if ffmpeg is installed
def is_ffmpeg_installed():
    return shutil.which("ffmpeg") is not None

# Extract video ID from YouTube URL
def extract_video_id(url):
    pattern = r'(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})'
    match = re.search(pattern, url)
    return match.group(1) if match else None

# Function to download YouTube video using yt-dlp
def download_youtube_video(yt_url, download_path='./'):
    if not is_ffmpeg_installed():
        raise EnvironmentError("ffmpeg is not installed. Please install ffmpeg to proceed.")

    ydl_opts = {
        'format': 'best',
        'outtmpl': os.path.join(download_path, '%(title)s.%(ext)s'),
    }
    
    with youtube_dl.YoutubeDL(ydl_opts) as ydl:
        try:
            info_dict = ydl.extract_info(yt_url, download=True)
            file_path = ydl.prepare_filename(info_dict)
        except youtube_dl.utils.DownloadError as e:
            if 'Requested format is not available' in str(e):
                # List available formats
                info_dict = ydl.extract_info(yt_url, download=False)
                formats = info_dict.get('formats', [info_dict])
                available_formats = [f['format_id'] for f in formats]
                # Update ydl_opts with an available format
                ydl_opts['format'] = available_formats[0]
                with youtube_dl.YoutubeDL(ydl_opts) as ydl:
                    info_dict = ydl.extract_info(yt_url, download=True)
                    file_path = ydl.prepare_filename(info_dict)
            else:
                raise e
    return file_path

@app.route('/process_video', methods=['POST'])
def process_video():
    try:
        data = request.json
        url = data['url']
        script_time = data['script_time']
        cultural_reference = data['cultural_reference']
        specific_input = data['specific_input']

        video_id = extract_video_id(url)

        # Fetch video title using YouTube Data API
        youtube = build('youtube', 'v3', developerKey='AIzaSyBPpShSmXuu4sfmkD8PjCaEN-UrQ59G4SI')
        video_response = youtube.videos().list(
            part='snippet',
            id=video_id
        ).execute()

        video_title = video_response['items'][0]['snippet']['title']

        def get_video_duration(url):
            yt = YouTube(url)
            duration = yt.length  # Duration in seconds
            minutes, seconds = divmod(duration, 60)
            return f"{minutes} minutes and {seconds} seconds", duration

        video_duration, total_duration = get_video_duration(url)

        # Download YouTube video
        file_path = download_youtube_video(url)

        # Upload the video file to Google API
        video_file = genai.upload_file(path=file_path)

        # Wait for the video to be processed
        while video_file.state.name == "PROCESSING":
            time.sleep(10)
            video_file = genai.get_file(video_file.name)

        if video_file.state.name == "FAILED":
            return jsonify({"error": "Video processing failed"}), 500

        # Create the prompt
        prompt_sum = "Describe this video, generate it like a summary as a single para with bullet points, then generate another set of texts which deals with the most unique and most shown thing in the video"

        # Set the model to Gemini 1.5 Flash
        model = genai.GenerativeModel(model_name="models/gemini-1.5-pro")

        # Make the LLM request for summary
        response_summary = model.generate_content([prompt_sum, video_file], request_options={"timeout": 600})

        # Function to format time in MM:SS format
        def format_time(seconds):
            minutes, seconds = divmod(seconds, 60)
            return f"{minutes:02d}:{seconds:02d}"

        # Analyze emotions in segments of the video
        emotions = []
        for i in range(4):
            start_time = i * (total_duration // 4)
            end_time = (i + 1) * (total_duration // 4) if i < 3 else total_duration
            prompt = f"What emotions are shown from {format_time(start_time)} to {format_time(end_time)}"
            response_emotion = None

            retry_count = 0
            max_retries = 3

            while retry_count < max_retries:
                try:
                    response_emotion = model.generate_content([prompt, video_file], request_options={"timeout": 600})
                    emotions.append(response_emotion.text)
                    break  # Exit the loop if the request is successful
                except google.api_core.exceptions.ResourceExhausted:
                    retry_count += 1
                    time.sleep(60)  # Wait for 60 seconds before retrying
                except Exception as e:
                    return jsonify({"error": str(e)}), 500

            if not response_emotion:
                return jsonify({"error": "Failed to get a response after multiple attempts."}), 500

        prompt_script = f"Generate a YouTube script for another creator that is similar in content or creates a new content with timestamps, including emotions and background activities. Generate script based on {specific_input}. Generate script starting from 0:00 and end at {script_time}.00, in the script make sure {cultural_reference} movie reference, {cultural_reference} meme reference, few {cultural_reference} words in between, make the script sound very {cultural_reference} and anything related to {cultural_reference} must be added to the script. Finally, suggest similar contents on the internet."

        retry_count = 0
        response_script = None
        max_retries = 3

        while retry_count < max_retries:
            try:
                response_script = model.generate_content([prompt_script, response_emotion.text, response_summary.text, video_file], request_options={"timeout": 600})
                break  # Exit the loop if the request is successful
            except google.api_core.exceptions.ResourceExhausted:
                retry_count += 1
                time.sleep(60)  # Wait for 60 seconds before retrying
            except Exception as e:
                return jsonify({"error": str(e)}), 500

        if not response_script:
            return jsonify({"error": "Failed to get a response after multiple attempts."}), 500

        return jsonify({
            "video_title": video_title,
            "video_duration": video_duration,
            "response_summary": response_summary.text,
            "response_script": response_script.text
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
