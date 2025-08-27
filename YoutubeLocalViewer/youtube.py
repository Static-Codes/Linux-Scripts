requirements = """
# python3 -m venv venv
# source venv/bin/activate
# pip install yt-dlp
# sudo apt-get install ffmpeg xdotool
# """



from ctypes import pythonapi
from os import getcwd, path, remove, system
from subprocess import PIPE, Popen
from threading import Thread
from time import sleep
from yt_dlp import YoutubeDL

FILE_LOC = path.join(getcwd(), "playback.mp4")

class Youtube:
    def __init__(self, video_url: str = None, quality = '1080', format='mp4:m4a', byte_limit=13110000, previous_url: str = None):
        self.byte_limit = byte_limit
        self.format = format
        self.quality = quality
        self.previous_url = previous_url
        self.is_open = False
        self.is_paused = False
        self.is_playing = False
        self.error = None
        self.pid = None

        if video_url is None:
            print("Invalid video link supplied.")
            exit()

        elif video_url.startswith("https://youtu.be/"):
            vid = video_url.replace("https://youtu.be/", "")
            video_url = f"https://youtube.com/watch?v={vid}"
        
        self.video_url = video_url

        


    def check_for_package_update(self):
        try:
            system('yt-dlp -U')
        except Exception as e:
            print("Unhandled Exception of type:")
            print(f'{type(e)}\n')
            print("in check_for_package_update()")
            print("Exception:\n")
            print(e)

    def download_video(self):
        dl_options = {
            'format_sort': [f'res:{self.quality}', f'ext:{self.format}'], # 1080p quality + mp4 format
            'outtmpl': FILE_LOC,
            'limit_rate': self.byte_limit #100Mbps
        }
        try:
            if path.exists(FILE_LOC):
                remove(FILE_LOC)
        except:
            try:
                system(f'rm {FILE_LOC}')
            except Exception as e:    
                print(f'Unable to delete existing file, please try again.\n\nError:\n{e}')
                return None

        try:
            with YoutubeDL(dl_options) as ydl:
                return ydl.download([self.video_url]) == 0
        except Exception as e:
            print("Unhandled Exception of type:")
            print(f'{type(e)}\n')
            print("in download_video()")
            print("Exception:\n")
            print(e)
            return False

    def open_video(self):
        try:
            if not path.exists(FILE_LOC):
                print("No video found")
                return False
            
            cmd = Popen(['ffplay', '-fs', f'{FILE_LOC}', '-loglevel', 'quiet'])
            self.pid = cmd.pid
            self.get_player_pid() # Used as a backup if cmd.pid returns None
            sleep(.50)
            self.is_open = True
            self.is_playing = True
            return True
        except Exception as e:
            print("Unhandled Exception of type:")
            print(f'{type(e)}\n')
            print("in open_video()")
            print("Exception:\n")
            print(e)
            self.is_open = False
            return False

    def change_playback_status(self):
        if not self.is_open:
            return "No open video found"

        try:
            proc = Popen(['xdotool', 'key', 'p'], stdin=PIPE)
            if self.is_paused and not self.is_playing:
                self.is_paused = False
                self.is_playing = True
                return "Playback started successfully!"

            elif self.is_playing and not self.is_paused:
                self.is_paused = True
                self.is_playing = False
                return "Playback paused successfully!"

        except Exception as e:
            print("Unhandled Exception of type:")
            print(f'{type(e)}\n')
            print("in change_playback_status()")
            print("Exception:\n")
            print(e)
            return "Exception"

    def get_player_pid(self):
        if self.pid is None:
            sleep(.25)
            cmd = Popen(['pidof', 'ffplay'], stdin=PIPE, text=True, bufsize=1)
            cmd.wait()
            if not cmd.stdout:
                return "Unable to get PID of player"
                
    def kill_player(self):
        self.get_player_pid()
        if self.pid is None:
            return "Unable to kill player"
        try:
            cmd = Popen(['pkill', self.pid])
            result = cmd.returncode
            return result == 0
        except Exception as e:
            print("Unhandled Exception of type:")
            print(f'{type(e)}\n')
            print("in kill_player()")
            print("Exception:\n")
            print(e)
            return False