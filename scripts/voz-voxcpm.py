"""
Narración local y gratis con VoxCPM2 (openbmb, licencia Apache-2.0), sin servicios externos.

- Diseña una voz con el campo "controlVox" de guion.json (por defecto: chico joven, acento de España)
  y la guarda en public/<carpeta>/voz-referencia.wav; las demás escenas la clonan para que suene igual.
  Si ya existe ese archivo, se reutiliza (se puede copiar de otro video para mantener la voz del canal).
- "ritmoVox" en guion.json ajusta la velocidad (0.9 por defecto: un poco más lenta, mismo tono).
- Los tiempos de palabras y letras salen de Whisper (como tiempos-whisper.py).

Uso: HF_HUB_DISABLE_XET=1 ~/vox/bin/python scripts/voz-voxcpm.py <carpeta> [--forzar]
Instalación (una vez, ~7 GB): python3 -m venv ~/vox && ~/vox/bin/pip install torch torchaudio voxcpm
En CPU tarda unos 4 s por cada segundo de audio y 3 min en cargar el modelo.
"""
import json
import os
import re
import subprocess
import sys

import soundfile as sf
from voxcpm import VoxCPM

CARPETA = sys.argv[1]
FORZAR = "--forzar" in sys.argv
guion = json.load(open(f"src/{CARPETA}/guion.json", encoding="utf-8"))
SALIDA = f"public/{guion['carpeta']}"
TIEMPOS = f"src/{CARPETA}/tiempos.json"
CONTROL = guion.get("controlVox", "Voz masculina joven, enérgica y cercana, acento de España, castellano de Madrid, ritmo rápido")
REF = f"{SALIDA}/voz-referencia.wav"
# Ritmo: 1.0 = natural; 0.9 = un 10 % más lenta (sin cambiar el tono). Por defecto 0.9, como pidió el usuario.
RITMO = float(guion.get("ritmoVox", 0.9))
os.makedirs(SALIDA, exist_ok=True)

# Funciones de tiempos-whisper.py (sin ejecutar su programa)
codigo = open(os.path.join(os.path.dirname(__file__), "tiempos-whisper.py"), encoding="utf-8").read().split("alineaciones = {}")[0]
codigo = codigo.replace("CARPETA = sys.argv[1]", "CARPETA = None").replace("EXTRA = sys.argv[2:]", "EXTRA = []")
codigo = re.sub(r"guion = json\.load\(.*\n", "", codigo).replace("SALIDA = f\"public/{guion['carpeta']}\"", "")
TW = {}
exec(codigo, TW)

modelo = VoxCPM.from_pretrained("openbmb/VoxCPM2", load_denoiser=False, optimize=False, device="cpu")
previos = json.load(open(TIEMPOS, encoding="utf-8")) if os.path.exists(TIEMPOS) else {"voz": {}, "sfx": {}}
tiempos = {"voz": dict(previos.get("voz", {})), "sfx": {}}

for e in guion["escenas"]:
    texto = TW["sin_etiquetas"](e["texto"])
    mp3 = f"{SALIDA}/voz-{e['id']}.mp3"
    previo = previos["voz"].get(e["id"])
    if not FORZAR and os.path.exists(mp3) and previo and previo.get("texto") == texto and previo.get("motor") == "voxcpm" and previo.get("ritmo") == RITMO:
        continue
    if os.path.exists(REF):
        wav = modelo.generate(text=texto, reference_wav_path=REF)
    else:
        wav = modelo.generate(text=f"({CONTROL}){texto}")
        sf.write(REF, wav, 48000)
    sf.write(f"{SALIDA}/tmp.wav", wav, 48000)
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", f"{SALIDA}/tmp.wav", "-af", f"atempo={RITMO}", "-b:a", "192k", mp3], check=True)
    os.remove(f"{SALIDA}/tmp.wav")
    palabras = TW["cuadrar"](texto, TW["palabras_whisper"](mp3))
    letras, li, lf = TW["letras_de"](palabras, texto)
    tiempos["voz"][e["id"]] = {"texto": texto, "duracion": TW["duracion"](mp3), "palabras": palabras, "letras": letras, "ini": li, "fin": lf, "motor": "voxcpm", "ritmo": RITMO}
    json.dump({**tiempos, "sfx": previos.get("sfx", {})}, open(TIEMPOS, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("✓", mp3, f"{tiempos['voz'][e['id']]['duracion']:.2f}s")

for f in sorted(os.listdir(SALIDA)):
    if f.startswith("sfx-") and f.endswith(".mp3"):
        tiempos["sfx"][f[4:-4]] = TW["duracion"](f"{SALIDA}/{f}")
json.dump(tiempos, open(TIEMPOS, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("Escrito", TIEMPOS)
