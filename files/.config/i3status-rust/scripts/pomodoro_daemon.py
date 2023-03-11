import os
# import daemon
import time
from collections import deque
from datetime import datetime

class CountDownTimer:

    start_time = 0
    period = 0 # In seconds
    state = "STOPPED"  


    def time_left(self):
        if self.state == "PAUSED":
            time_left  = self.period
        elif self.start_time and self.period:
            time_left = self.period - (datetime.now() - self.start_time).total_seconds()
        else:
            time_left = 0
        
        if time_left <= 0:
            self.stop_timer()
        
        return time_left
        
    def start_timer(self, period):
        """Set the initial state"""
        self.start_time = datetime.now() 
        self.period = self.period or period
        self.state = "STARTED"
        
    def pause_timer(self):
        """Save the time left and mark the sate as paused"""
        self.period = self.time_left()
        self.state = "PAUSED"

    def stop_timer(self):
        """Reset everything"""
        self.start_time = 0
        self.state = "STOPPED"
        self.period = 0


READ_PIPE = "/tmp/pomodoro_client_to_daemon.pipe"
WRITE_PIPE = "/tmp/pomodoro_daemon_to_client.pipe"


def read_from_pipe():
    try:
        rpipe = os.open(READ_PIPE, os.O_RDONLY | os.O_NONBLOCK)
        message = os.read(rpipe, 1024).decode("utf-8").split('\n')
        os.close(rpipe)
    except BlockingIOError:
        return []
    return list(filter(None, message))

def write_to_pipe(message):
    try:
        wpipe = os.open(WRITE_PIPE, os.O_WRONLY | os.O_NONBLOCK)

        os.write(wpipe, message)
        os.close(wpipe)
        return True
    except OSError:
        return False

def pomodoro_daemon():
    # print the PID of the daemon process
    print("Daemon process ID:", os.getpid())

    # create bidirectional named pipes
    if not os.path.exists(READ_PIPE):
        os.mkfifo(READ_PIPE)

    if not os.path.exists(WRITE_PIPE):
        os.mkfifo(WRITE_PIPE)
    
    # Initialize timer
    timer = CountDownTimer()

    commands = deque()
    while True:
        print(timer.start_time, timer.period, timer.state)
        if message_from_pipe:=read_from_pipe():
            for command in message_from_pipe:
                if command:
                    commands.append(command.split())
        if len(commands) > 0:
            command = commands.popleft()
            command_name = command[0]
            if command_name == "exit":
                break
            if command_name == "stop":

                # Stop the timer, respond, then exit
                timer.stop_timer()
                write_to_pipe(b"Stopping timer and exiting daemon!")
                break
            if command_name == "start":

                # Start the count down then respond
                timer.start_timer(int(command[1]))
                write_to_pipe(str(timer.time_left()).encode())
                # write_to_pipe(b"Count down started!")
            if command_name == "pause":

                # Pause the time if there is one started
                timer.pause_timer()
                write_to_pipe(str(timer.time_left()).encode())
                pass
        time.sleep(1)


if __name__ == "__main__":
    # with daemon.DaemonContext():
    pomodoro_daemon()
