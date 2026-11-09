"""
Narración gratuita con las voces neuronales de Microsoft (edge-tts), como alternativa a ElevenLabs.

Lee src/<carpeta>/guion.json y, para cada escena, genera public/<carpeta>/voz-<id>.mp3
y los tiempos de cada palabra y letra en src/<carpeta>/tiempos.json (para subtítulos y boca de Nyxar).

Campos opcionales en guion.json:
  "vozEdge": "es-ES-AlvaroNeural"   (voz; por defecto Álvaro, España)
  "velocidad": "+12%"              (ritmo; la marca pide ~3 palabras por segundo)
  "tono": "+0Hz"
Las etiquetas entre corchetes del texto ("[susurrando]") se quitan: edge-tts no las interpreta.

Uso: python3 scripts/voz-edge.py <carpeta> [--forzar]
Requiere: pip install edge-tts, y acceso a speech.platform.bing.com.
"""
import asyncio
import importlib.util
import json
import os
import re
import subprocess
import sys

import edge_tts

CARPETA = sys.argv[1]
FORZAR = "--forzar" in sys.argv
guion = json.load(open(f"src/{CARPETA}/guion.json", encoding="utf-8"))
SALIDA = f"public/{guion['carpeta']}"
TIEMPOS = f"src/{CARPETA}/tiempos.json"
VOZ = guion.get("vozEdge", "es-ES-AlvaroNeural")
VELOCIDAD = guion.get("velocidad", "+12%")
TONO = guion.get("tono", "+0Hz")
os.makedirs(SALIDA, exist_ok=True)

# Reutiliza el cuadre de palabras de tiempos-whisper.py
_spec = importlib.util.spec_from_file_location("tw", os.path.join(os.path.dirname(__file__), "tiempos-whisper.py"))


def _cargar_tw():
    # tiempos-whisper.py ejecuta su programa al importarse; solo copiamos sus funciones.
    codigo = open(_spec.origin, encoding="utf-8").read().split("alineaciones = {}")[0]
    codigo = codigo.replace("CARPETA = sys.argv[1]", "CARPETA = None").replace("EXTRA = sys.argv[2:]", "EXTRA = []")
    codigo = re.sub(r'guion = json\.load\(.*\n', "", codigo)
    codigo = codigo.replace("SALIDA = f\"public/{guion['carpeta']}\"", "")
    ns = {}
    exec(codigo, ns)
    return ns


TW = _cargar_tw()


def duracion(archivo):
    return float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", archivo]).decode())


async def generar(texto, archivo):
    c = edge_tts.Communicate(texto, VOZ, rate=VELOCIDAD, pitch=TONO, boundary="WordBoundary", proxy=os.environ.get("HTTPS_PROXY"))
    palabras = []
    with open(archivo, "wb") as f:
        async for ch in c.stream():
            if ch["type"] == "audio":
                f.write(ch["data"])
            elif ch["type"] == "WordBoundary":
                palabras.append((ch["text"], ch["offset"] / 1e7, (ch["offset"] + ch["duration"]) / 1e7))
    return palabras


previos = json.load(open(TIEMPOS, encoding="utf-8")) if os.path.exists(TIEMPOS) else {"voz": {}, "sfx": {}}
tiempos = {"voz": dict(previos.get("voz", {})), "sfx": {}}

for e in guion["escenas"]:
    texto = TW["sin_etiquetas"](e["texto"])
    archivo = f"{SALIDA}/voz-{e['id']}.mp3"
    previo = previos["voz"].get(e["id"])
    if not FORZAR and os.path.exists(archivo) and previo and previo.get("texto") == texto and previo.get("motor") == "edge":
        continue
    wpal = asyncio.run(generar(texto, archivo))
    palabras = TW["cuadrar"](texto, wpal)
    letras, li, lf = TW["letras_de"](palabras, texto)
    tiempos["voz"][e["id"]] = {"texto": texto, "duracion": duracion(archivo), "palabras": palabras, "letras": letras, "ini": li, "fin": lf, "motor": "edge"}
    json.dump({**tiempos, "sfx": previos.get("sfx", {})}, open(TIEMPOS, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("✓", archivo, f"{tiempos['voz'][e['id']]['duracion']:.2f}s")

for f in sorted(os.listdir(SALIDA)):
    if f.startswith("sfx-") and f.endswith(".mp3"):
        tiempos["sfx"][f[4:-4]] = duracion(f"{SALIDA}/{f}")
json.dump(tiempos, open(TIEMPOS, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("Escrito", TIEMPOS)
