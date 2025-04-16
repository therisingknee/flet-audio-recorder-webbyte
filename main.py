import flet as ft
from flet_soundbyte import FletSoundbyte
import base64
import io


def main(page: ft.Page):
    def on_event(e: ft.ControlEvent):
        print("Received event from Dart:")
        print("Event name:", e.name)
        print("Data size:", len(e.data))
        print("Preview:", e.data[:100], "...")

        audio_bytes = base64.b64decode(e.data)
        with open("recording.webm", "wb") as f:
            f.write(audio_bytes)
        print("Audio file saved!")

        file_like = io.BytesIO(audio_bytes)
        file_like.name = "audio.webm"

        return file_like

    soundbyte = FletSoundbyte(on_event=on_event)
    page.add(soundbyte)


ft.app(target=main)
