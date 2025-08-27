# Local Youtube Playback Project

This project was a result of my desire to watch Youtube in bed without ads.

There are definitely better solutions, however this works for my personal needs.

## How it works

1. Download a Debian based distro (Linux Mint or Ubuntu are the most beginner friendly)
2. Connect your linux machine to your tv of choice (Wired connection is recommended)
3. Ensure your linux machine's screen is being displayed on the tv
4. Open a terminal session and navigate to the `YoutubeLocalViewer` directory.
5. Run the command `pip install -r requirements.txt`.
6. Run the command `python main.py` (This will be running on `http://localhost:5000`)
7. Please take note of the IP:Port the server is running on, it will be displayed in the terminal.
8. On your phone copy the video url on choice (`youtu.be` links are also supported)
9. Go to `http://<YourLinuxMachineIP>:5000` (Replace <YourLinuxMachineIP> with the IP displayed in Step 7)
10. Paste the video URL from Step 8 and click `Start/Stop`
11. Your video will be downloaded to your linux machine under the filename `playback.mp4` then will automatically play.
12. Click Start/Stop to cancel or go to `http://<YourLinuxMachineIP>:5000/cancel`
13. If any issues arise restart the server by visiting `http://<YourLinuxMachineIP>:5000/restart` and waiting 10 seconds.
14. Repeat Steps 10-13 until you decide it's time to do something other than watch Youtube :)

## Minimum specs:
- 2GB DDR3 RAM
- 2 Core CPU with AVX2 support (this is almost any CPU made in the last 15 years)
- 35GB of storage.
