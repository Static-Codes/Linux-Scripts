from platform import system as platform_name


def check_os():
    try:
        name = platform_name()
        if name != "Linux":
            print(
                """
            This script was designed for Debian based Linux distributions.
            
            While you don't have to use Ubuntu/Mint Linux, they are the most beginner friendly.
            """
            )
            exit()

    except Exception as e:
        print("Unhandled Exception of type:")
        print(f"{type(e)}\n")
        print("in check_os()")
        print("Exception:\n")
        print(e)


async def get_current_machine_ip():
    from aiohttp import ClientSession

    try:
        async with ClientSession() as session:
            response = await session.get("https://httpbin.io/ip")
            content = await response.json()
            origin = content["origin"]
            ip = origin.split(":")[0]
            return ip

    except Exception as e:
        print(e)
        exit()


check_os()


import os
import psutil
from asyncio import run
from flask import Flask, request
from youtube import Youtube, Popen


ip = run(get_current_machine_ip())


LOG_FILE = os.path.join(os.getcwd(), "logs", "log.txt")
PORT_IP = f"{ip}:5000"
APP_NAME = "server:app"
app = Flask(__name__)
youtube_instance = None
GUNICORN_PID_FILE = "/tmp/gunicorn.pid"

print(f"Running on: http://{PORT_IP}")


def gunicorn_running() -> bool:
    for proc in psutil.process_iter(["pid", "name"]):
        try:
            if "gunicorn" in proc.info["name"].lower():
                for arg in psutil.Process(proc.info["pid"]).cmdline():
                    if arg == GUNICORN_PID_FILE:
                        return True
        except psutil.ZombieProcess:
            try:
                proc.kill()  # This will kill the zombie process gracefully
            except:
                print(
                    "Unable to kill zombie process related to gunicorn, if this starts to affect functionality, please consider using:\n\nkillall gunicorn."
                )
            continue
    return False


if not gunicorn_running():
    Popen(
        [
            "gunicorn",
            "--workers",
            "3",
            "--bind",
            PORT_IP,
            "--daemon",
            "--pid",
            GUNICORN_PID_FILE,
            "--graceful-timeout",
            "60",
            "--timeout",
            "60",
            # "--log-file", "/home/pihole-server/Desktop/log.txt",
            "--access-logfile",
            "-",
            "--error-logfile",
            "-",
            APP_NAME,
        ]
    )


@app.route("/", methods=["GET"])
def root():
    return """Browser session restarted.<br><br>Gunicorn workers are being restarted.<br><br><form action="/watch" method="get">
  <input type="text" name="url" placeholder="Enter YouTube URL">
  <button type="submit">Send</button>
</form>"""


@app.route("/cancel")
def cancel():
    global youtube_instance
    if not youtube_instance:
        return """<html><head>
        <title>Redirecting...</title>
        <meta http-equiv="refresh" content="2; url=/"></head>
        <body>
        <p>No active download was found, redirecting... if you are not redirected within 2 seconds, <a href="/">click here</a>.</p>
        </body>
        </html>
        """
    if youtube_instance.kill_download():
        return """<html><head>
        <title>Redirecting...</title>
        <meta http-equiv="refresh" content="2; url=/"></head>
        <body>
        <p>Download killed successfully, redirecting... if you are not redirected within 2 seconds, <a href="/">click here</a>.</p>
        </body>
        </html>
        """
    else:
        return """<html><head>
        <title>Redirecting...</title>
        <meta http-equiv="refresh" content="2; url=/"></head>
        <body>
        <p>Unable to kill active download, redirecting... if you are not redirected within 2 seconds, <a href="/">click here</a>.</p>
        </body>
        </html>
        """


@app.route("/watch", methods=["GET"])
def watch():
    global youtube_instance
    video_url = request.args.get("url")
    if not isinstance(video_url, str):
        return """<h1>Invalid URL Provided</h1><br><form action="/watch" method="get">
  <input type="text" name="url" placeholder="Enter YouTube URL" />
  <button type="submit">Send</button>
</form>
    """

    previous_url = None
    if youtube_instance:
        previous_url = youtube_instance.previous_url
        youtube_instance.kill_player()

    youtube_instance = Youtube(video_url, previous_url=previous_url)
    youtube_instance.check_for_package_update()
    try:
        youtube_instance.download_video()
    except Exception as e:
        youtube_instance.is_paused = False
        youtube_instance.is_playing = False
        youtube_instance.is_open = False
        return """<h1>Download Error, try again.<h1><br><br><form action="/watch" method="get">
  <input type="text" name="url" placeholder="Enter YouTube URL">
  <button type="submit">Send</button>
</form>"""

    if not youtube_instance.open_video():
        return """<h1>Display Error, try again.<h1><br><br><form action="/watch" method="get">
  <input type="text" name="url" placeholder="Enter YouTube URL">
  <button type="submit">Send</button>
</form>"""

    return """<h1>Loaded!<h1><br><br><form action="/watch" method="get">
  <input type="text" name="url" placeholder="Enter YouTube URL">
  <button type="submit">Send</button>
</form>"""
