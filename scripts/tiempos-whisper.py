"""
Reconstruye src/<carpeta>/tiempos.json cuando faltan las marcas de tiempo de ElevenLabs
(por ejemplo, si se cortó la generación por falta de créditos).

- Para cada voz con alineación guardada (JSON de ElevenLabs con `texto` y `alignment`), la usa.
- Para el resto, transcribe con Whisper palabra por palabra y cuadra esas palabras con el texto
  del guion (las que no coinciden, como los números escritos en letra, se interpolan).

Uso: python3 scripts/tiempos-whisper.py <carpeta> [alineacion-id.json ...]
"""
import difflib
import json
import os
import re
import subprocess
import sys
import tempfile
import unicodedata

CARPETA = sys.argv[1]
EXTRA = sys.argv[2:]
MODELO = os.path.expanduser("~/.cache/hyperframes/whisper/models/ggml-small.bin")
guion = json.load(open(f"src/{CARPETA}/guion.json", encoding="utf-8"))
SALIDA = f"public/{guion['carpeta']}"


def norm(s):
    s = unicodedata.normalize("NFD", s.lower())
    s = "".join(c for c in s if unicodedata.category(c) != "Mn")
    return re.sub(r"[^a-z0-9]", "", s)


def sin_etiquetas(t):
    return re.sub(r"\[[^\]]*\]\s*", "", t).strip()


def duracion(archivo):
    return float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", archivo]).decode())


def palabras_whisper(mp3):
    with tempfile.TemporaryDirectory() as d:
        wav = os.path.join(d, "a.wav")
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", mp3, "-ar", "16000", "-ac", "1", wav], check=True)
        base = os.path.join(d, "out")
        subprocess.run(["whisper-cli", "-m", MODELO, "-l", "es", "-f", wav, "-ml", "1", "-sow", "-oj", "-of", base], check=True, capture_output=True)
        js = json.load(open(base + ".json", encoding="utf-8"))
    out = []
    for seg in js["transcription"]:
        txt = seg["text"].strip()
        if not txt:
            continue
        out.append((txt, seg["offsets"]["from"] / 1000, seg["offsets"]["to"] / 1000))
    return out


def cuadrar(texto, wpal):
    """Asigna inicio y fin a cada palabra del guion usando las de Whisper como anclas."""
    guion_p = texto.split()
    a = [norm(p) for p in guion_p]
    b = [norm(w[0]) for w in wpal]
    ini = [None] * len(guion_p)
    fin = [None] * len(guion_p)
    for bloque in difflib.SequenceMatcher(None, a, b, autojunk=False).get_matching_blocks():
        for k in range(bloque.size):
            ini[bloque.a + k] = wpal[bloque.b + k][1]
            fin[bloque.a + k] = wpal[bloque.b + k][2]
    total = wpal[-1][2] if wpal else 1.0
    # Interpolar huecos entre anclas
    i = 0
    while i < len(guion_p):
        if ini[i] is not None:
            i += 1
            continue
        j = i
        while j < len(guion_p) and ini[j] is None:
            j += 1
        t0 = fin[i - 1] if i > 0 else (wpal[0][1] if wpal else 0.0)
        t1 = ini[j] if j < len(guion_p) else total
        pesos = [max(1, len(norm(guion_p[k]))) for k in range(i, j)]
        acum = t0
        for k, w in zip(range(i, j), pesos):
            paso = (t1 - t0) * w / sum(pesos)
            ini[k], fin[k] = acum, acum + paso
            acum += paso
        i = j
    return [{"p": p, "ini": round(s, 3), "fin": round(e, 3)} for p, s, e in zip(guion_p, ini, fin)]


def letras_de(palabras, texto):
    """Reparte cada palabra en sus letras a lo largo de su duración (para la boca)."""
    letras, li, lf = [], [], []
    for k, w in enumerate(palabras):
        n = len(w["p"])
        for c_i, c in enumerate(w["p"]):
            letras.append(c)
            li.append(round(w["ini"] + (w["fin"] - w["ini"]) * c_i / n, 3))
            lf.append(round(w["ini"] + (w["fin"] - w["ini"]) * (c_i + 1) / n, 3))
        if k < len(palabras) - 1:
            letras.append(" ")
            li.append(w["fin"])
            lf.append(palabras[k + 1]["ini"])
    return "".join(letras), li, lf


def desde_alineacion(js):
    texto = js["texto"]
    al = js["alignment"]
    chars, ini, fin = al["characters"], al["character_start_times_seconds"], al["character_end_times_seconds"]
    c2, i2, f2 = [], [], []
    dentro = False
    for c, s, e in zip(chars, ini, fin):
        if c == "[":
            dentro = True
            continue
        if c == "]":
            dentro = False
            continue
        if dentro or (not c2 and c.isspace()):
            continue
        c2.append(c)
        i2.append(s)
        f2.append(e)
    palabras, actual = [], None
    for c, s, e in zip(c2, i2, f2):
        if c.isspace():
            if actual:
                palabras.append(actual)
            actual = None
            continue
        if not actual:
            actual = {"p": "", "ini": s, "fin": e}
        actual["p"] += c
        actual["fin"] = e
    if actual:
        palabras.append(actual)
    return sin_etiquetas(texto), palabras, "".join(c2), i2, f2


alineaciones = {}
for ruta in EXTRA:
    nombre = os.path.basename(ruta)
    m = re.match(r"align-(.+)\.json", nombre)
    if m:
        alineaciones[m.group(1)] = json.load(open(ruta, encoding="utf-8"))

tiempos = {"voz": {}, "sfx": {}}
for e in guion["escenas"]:
    mp3 = f"{SALIDA}/voz-{e['id']}.mp3"
    if e["id"] in alineaciones:
        texto, palabras, letras, li, lf = desde_alineacion(alineaciones[e["id"]])
    else:
        texto = sin_etiquetas(e["texto"])
        palabras = cuadrar(texto, palabras_whisper(mp3))
        letras, li, lf = letras_de(palabras, texto)
    tiempos["voz"][e["id"]] = {"texto": texto, "duracion": duracion(mp3), "palabras": palabras, "letras": letras, "ini": li, "fin": lf}
    print(e["id"], " ".join(f"{w['p']}@{w['ini']:.2f}" for w in palabras))

for f in sorted(os.listdir(SALIDA)):
    if f.startswith("sfx-") and f.endswith(".mp3"):
        tiempos["sfx"][f[4:-4]] = duracion(f"{SALIDA}/{f}")

json.dump(tiempos, open(f"src/{CARPETA}/tiempos.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("Escrito", f"src/{CARPETA}/tiempos.json")
