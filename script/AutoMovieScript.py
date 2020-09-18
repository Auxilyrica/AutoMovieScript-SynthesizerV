import time
import cv2
import sys
import pyautogui
import numpy as np
import ctypes
import os
import winsound

# synthVを前面に
class ForegroundSynthV:
    def __init__(self):
        self.message = "not found"
        self.user32 = ctypes.WinDLL("user32")
        self.windowText = ctypes.create_unicode_buffer(1024)
        self.doForeground = True
        self.EnumWindowsProc = ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.c_void_p, ctypes.c_void_p)

    def callback(self, hWnd, lParam):
        self.user32.GetWindowTextW(hWnd, self.windowText, len(self.windowText))

        if "Synthesizer V Studio Pro -" in self.windowText.value:
            if self.doForeground:
                ctypes.windll.user32.SetForegroundWindow(hWnd)
            self.message = "complete"
            if self.windowText.value[0] == "*":
                self.message = "not save"
        return True

    def foreground(self, doF=True):
        self.doForeground = doF
        self.user32.EnumWindows(self.EnumWindowsProc(self.callback), None)
        return self.message


def log(log):
    txt = open("script/log.txt", "a")
    txt.write(str(log) + "\n")
    txt.close()


def save_frame_sec(video_path, result_path, refresh_rate=1.0, movie_fps=15, size=24, test=False):
    cap = cv2.VideoCapture(video_path)

    if not cap.isOpened():
        return

    fps = cap.get(cv2.CAP_PROP_FPS)

    sec = 0
    if test:
        sec = 10

    startTime = time.time()
    log("start")
    while True:
        state = ForegroundSynthV().foreground()
        if state == "not found":
            winsound.Beep(1000, 200)
            time.sleep(0.1)
            winsound.Beep(1000, 200)
            time.sleep(0.1)
            winsound.Beep(1000, 200)
            log("not found")
            break


        cap.set(cv2.CAP_PROP_POS_FRAMES, round(fps * sec))
        ret, frame = cap.read()

        if ret:
            frame = cv2.resize(frame, (int(size / 3 * 4), size))
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            frame = np.asarray(frame)
            frame[frame < 128] = 0
            frame[frame >= 128] = 1

            # print(frame)
            line = ""
            for i in range(size):
                diff_base = np.insert(frame[i], 0, frame[i][0])
                to_frame = np.insert(frame[i], int(size / 3 * 4), frame[i][int(size / 3 * 4) - 1])
                diff_base = (diff_base != to_frame)
                diff_index = np.where(diff_base)[0]
                diff_index = np.insert(diff_index, 0, frame[i][0])
                diff = str(diff_index)[1:-1] + ","
                if diff[0] == " ": diff = diff[1:]
                line += diff

            log(line[:-1])
            while startTime + refresh_rate > time.time():
                time.sleep(0.01)
            startTime += refresh_rate

            with open(result_path + "\movie.txt", "w") as f:
                f.write(line[:-1])

            pyautogui.keyDown('altleft')
            pyautogui.press('b')
            pyautogui.keyUp('altleft')
            log(sec)

        else:
            return
        sec += 1 / movie_fps

        if test and sec > 15:
            return


if __name__ == '__main__':
    if os.path.exists("script/log.txt"):
        os.remove("script/log.txt")

    log(str(sys.argv))

    size = int(float(sys.argv[1]))
    movie_fps = int(float(sys.argv[2]))
    refresh_rate = float(sys.argv[3])
    test = True
    if sys.argv[4] == "false":
        test = False

    save_frame_sec(sys.argv[5], "script", size=size, movie_fps=movie_fps, refresh_rate=refresh_rate, test=test)

    log("end")