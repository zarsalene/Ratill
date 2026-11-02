"""Make the four small sound effects of the app: assets/sfx/*.wav.

    python tool/make_sounds.py

The sounds are plain sine tones made by this script, so they have no outside
license: they belong to the project. 16-bit mono, 22.05 kHz, under 40 KB each.
"""

import math
import struct
import wave
from pathlib import Path

RATE = 22050
OUT = Path(__file__).resolve().parent.parent / "assets" / "sfx"


def tone(freq: float, ms: int, volume: float, decay: float, attack_ms: int = 4) -> list[float]:
    """A sine tone with a short fade-in and an exponential fade-out."""
    n = RATE * ms // 1000
    attack = max(1, RATE * attack_ms // 1000)
    out = []
    for i in range(n):
        env = min(1.0, i / attack) * math.exp(-decay * i / n)
        out.append(volume * env * math.sin(2 * math.pi * freq * i / RATE))
    return out


def mix(parts: list[tuple[int, list[float]]]) -> list[float]:
    """Add tones that start at the given offsets (in ms)."""
    length = max(RATE * start // 1000 + len(s) for start, s in parts)
    out = [0.0] * length
    for start, s in parts:
        off = RATE * start // 1000
        for i, v in enumerate(s):
            out[off + i] += v
    return out


def save(name: str, samples: list[float]) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    peak = max(1e-9, max(abs(v) for v in samples))
    scale = min(1.0, 0.8 / peak)  # never clip
    with wave.open(str(OUT / f"{name}.wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(v * scale * 32767)) for v in samples))


SOUNDS = {
    # a soft click
    "tap": mix([(0, tone(1800, 35, 0.4, 6.0, 1))]),
    # a short rising pair: a word read right
    "right": mix([(0, tone(660, 90, 0.5, 3.0)), (80, tone(880, 130, 0.5, 4.0))]),
    # one low, soft tone: a word to repeat
    "wrong": mix([(0, tone(220, 220, 0.5, 3.5, 8))]),
    # four rising notes: a goal is done
    "chime": mix([(i * 120, tone(f, 420, 0.4, 4.0)) for i, f in enumerate([523.25, 659.25, 783.99, 1046.5])]),
}

if __name__ == "__main__":
    for name, samples in SOUNDS.items():
        save(name, samples)
        print(f"{name}: {(OUT / (name + '.wav')).stat().st_size} bytes")
