
from youtube import Youtube, Popen
from sys import argv

if len(argv) != 2:
    print("Invalid command format ytdl 'https://youtube.com/watch?v=1231311'")
    exit(1)

youtube_instance = Youtube(argv[1], previous_url=None)
youtube_instance.check_for_package_update()
try:
    youtube_instance.download_video()
except Exception as e:
    print(f"Unable to download the provided video.\n\nException: {e}")
    exit(1)