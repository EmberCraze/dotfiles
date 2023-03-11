import os
import requests
from datetime import timedelta
import sys

WRITE_PIPE = "/tmp/pomodoro_client_to_daemon.pipe"
READ_PIPE = "/tmp/pomodoro_daemon_to_client.pipe"


def get_pomodoro_time():
    url = "https://pomodoro-tracker.com/api/v1/timer"
    headers = {
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/110.0",
        "Accept": "application/json",
        "Accept-Language": "en-US,en;q=0.5",
        "Accept-Encoding": "gzip, deflate, br",
        "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxOTM3NjAsImFjdGlvbiI6ImFwaSIsImV4cCI6MTY4MzM2NzM5N30.ZnqFqGxzN1eSdOA3RQTwQ0zPEB9K5BJpEmAgMoghpro",
        "Cookie": "pomodoro=gAAAAABkBwvln1GBitjiLuOU-hnawlAwiXG46UXMfxbCfm4BVfLDOGMUyAbmgpP3nOsnqK87T3f6d2H_VscPeapF9AQ2x65E1Q==; timezone=Europe/Brussels; theme=dark; lang=en",
    }

    response = requests.get(url, headers=headers)
    content = response.json()

    if content == {}:
        # No timer is started
        print("25:00")
        return

    time_remaining = timedelta(milliseconds=response.json()["remains"])
    print(time_remaining)


# get_pomodoro_time()

def read_from_pipe():
    rpipe = os.open(READ_PIPE, os.O_RDONLY)# | os.O_NONBLOCK)
    message = os.read(rpipe, 1024).decode("utf-8")
    os.close(rpipe)
    return message
    
    
def write_to_pipe(message):
    wpipe = os.open(WRITE_PIPE, os.O_WRONLY)
    os.write(wpipe, message.encode())
    os.close(wpipe)
    return True


def start(period):
    write_to_pipe(f"start {period}\n")
    print(read_from_pipe())
    
def stop():
    print("stop")
    write_to_pipe(b'stop\n')
    print(read_from_pipe())

def pause():
    print("pause")
    write_to_pipe("pause\n")
    print(read_from_pipe())
    
def exit():
    write_to_pipe("exit\n")


# Parsing args
if sys.argv[1] == "start":
    if len(sys.argv) < 3:
        print("The period argument is missing, it should be an integer that represents minutes")
    else:
        start(sys.argv[2])
