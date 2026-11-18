#!/usr/bin/env python3
"""Genera la música y los efectos originales de Crónicas de Vael (sin muestras externas: todo sintetizado).

Uso:  python3 herramientas/generar-audio.py   (desde la carpeta roblox/cronicas-de-vael)
Crea en audio/:
  vael-efectos.ogg            todos los efectos en un solo archivo (los tramos están en src/shared/Sonidos.luau)
  vael-musica-ciudad.ogg      ciudad y menú (alegre, marimba y pizzicato)
  vael-musica-aventura.ogg    pradera, pantano y bosque (aventura con flauta cuadrada)
  vael-musica-combate.ogg     combate (tenso pero con humor: fagot y kazoo)
  vael-musica-jefe.ogg        ruinas, cueva y Rey Hongo (tuba, coro y timbales)
Solo necesita numpy y ffmpeg.
"""
import os
import subprocess
import wave

import numpy as np

SR = 44100
RNG = np.random.default_rng(2026)
AQUI = os.path.dirname(os.path.abspath(__file__))
SALIDA = os.path.join(AQUI, "..", "audio")


# ---------------------------------------------------------------- utilidades
def t(dur):
    return np.arange(int(dur * SR)) / SR


def nota(n):
    """Número MIDI → Hz."""
    return 440.0 * 2 ** ((n - 69) / 12)


def env(n, a=0.005, d=0.1, s=0.6, r=0.1, dur=None):
    """Envolvente ADSR de n muestras."""
    total = n
    a_n, d_n, r_n = int(a * SR), int(d * SR), int(r * SR)
    s_n = max(0, total - a_n - d_n - r_n)
    e = np.concatenate([
        np.linspace(0, 1, max(1, a_n)),
        np.linspace(1, s, max(1, d_n)),
        np.full(s_n, s),
        np.linspace(s, 0, max(1, r_n)),
    ])
    return e[:total] if len(e) >= total else np.pad(e, (0, total - len(e)))


def paso_bajo(x, corte):
    """Filtro paso bajo de un polo (aplicado dos veces para que sea más suave)."""
    a = np.exp(-2 * np.pi * corte / SR)
    for _ in range(2):
        y = np.empty_like(x)
        acc = 0.0
        b = 1 - a
        for i in range(len(x)):
            acc = b * x[i] + a * acc
            y[i] = acc
        x = y
    return x


def paso_alto(x, corte):
    return x - paso_bajo(x, corte)


def ruido(dur):
    return RNG.uniform(-1, 1, int(dur * SR))


def seno(f, dur, fase=0.0):
    tt = t(dur)
    if np.ndim(f) == 0:
        return np.sin(2 * np.pi * f * tt + fase)
    return np.sin(2 * np.pi * np.cumsum(f) / SR + fase)


def sierra(f, dur):
    ff = np.full(int(dur * SR), f) if np.ndim(f) == 0 else f
    fase = np.cumsum(ff) / SR
    return 2 * (fase - np.floor(fase + 0.5))


def cuadrada(f, dur, ancho=0.5):
    ff = np.full(int(dur * SR), f) if np.ndim(f) == 0 else f
    fase = np.cumsum(ff) / SR
    return np.where((fase % 1) < ancho, 1.0, -1.0)


def triangular(f, dur):
    return 2 * np.abs(sierra(f, dur)) - 1


def cuerda(f, dur, brillo=0.5):
    """Cuerda pulsada (Karplus-Strong): pizzicato, guitarra."""
    n = int(dur * SR)
    periodo = max(2, int(SR / f))
    buf = RNG.uniform(-1, 1, periodo)
    buf = paso_bajo(buf, 2000 + brillo * 6000) if periodo > 8 else buf
    out = np.empty(n)
    for i in range(n):
        j = i % periodo
        out[i] = buf[j]
        buf[j] = 0.5 * (buf[j] + buf[(j + 1) % periodo]) * 0.996
    return out


def normalizar(x, pico=0.89):
    m = np.max(np.abs(x)) or 1
    return x / m * pico


def mezclar(destino, sonido, inicio, vol=1.0):
    i = int(inicio * SR)
    if i >= len(destino):
        return
    fin = min(len(destino), i + len(sonido))
    destino[i:fin] += sonido[: fin - i] * vol


def guardar_ogg(x, nombre, estereo=None):
    os.makedirs(SALIDA, exist_ok=True)
    tmp = os.path.join(SALIDA, nombre + ".wav")
    x = np.clip(x, -1, 1)
    if estereo is not None:
        datos = np.stack([x, np.clip(estereo, -1, 1)], axis=1)
        canales = 2
    else:
        datos = x
        canales = 1
    with wave.open(tmp, "wb") as w:
        w.setnchannels(canales)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((datos * 32767).astype("<i2").tobytes())
    destino = os.path.join(SALIDA, nombre + ".ogg")
    filtro = ["-af", "loudnorm=I=-15:TP=-1.5:LRA=11"] if estereo is not None else []  # misma sonoridad en todas las canciones
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", tmp, *filtro, "-ar", str(SR), "-c:a", "libvorbis", "-q:a", "5", destino], check=True)
    os.remove(tmp)
    print("  ✓", destino)


# ---------------------------------------------------------------- instrumentos
def marimba(f, dur):
    tt = t(dur)
    x = np.sin(2 * np.pi * f * tt) + 0.35 * np.sin(2 * np.pi * f * 4 * tt) * np.exp(-tt * 30)
    return x * np.exp(-tt * 7)


def silbido(f, dur):
    tt = t(dur)
    vib = 1 + 0.008 * np.sin(2 * np.pi * 5.5 * tt) * np.clip(tt * 3, 0, 1)
    x = seno(f * vib, dur) + 0.04 * ruido(dur)
    return x * env(len(tt), 0.03, 0.05, 0.85, 0.08)


def flauta_cuadrada(f, dur):
    tt = t(dur)
    vib = 1 + 0.01 * np.sin(2 * np.pi * 6 * tt) * np.clip(tt * 2, 0, 1)
    x = paso_bajo(cuadrada(f * vib, dur, 0.3), 3000)
    return x * env(len(tt), 0.01, 0.08, 0.7, 0.06)


def fagot(f, dur):
    tt = t(dur)
    x = paso_bajo(sierra(f, dur), 900)
    return x * env(len(tt), 0.01, 0.06, 0.6, 0.05)


def kazoo(f, dur):
    """Kazoo: sierra con vibrato y zumbido (el toque de humor)."""
    tt = t(dur)
    vib = 1 + 0.02 * np.sin(2 * np.pi * 7 * tt)
    x = sierra(f * vib, dur) + 0.3 * cuadrada(f * 2 * vib, dur, 0.2)
    x = paso_bajo(x, 1800) * (1 + 0.3 * np.sin(2 * np.pi * 30 * tt))
    return x * env(len(tt), 0.02, 0.05, 0.75, 0.06)


def tuba(f, dur):
    tt = t(dur)
    x = paso_bajo(cuadrada(f, dur, 0.4) + 0.5 * sierra(f, dur), 600)
    return x * env(len(tt), 0.03, 0.1, 0.7, 0.08)


def bajo(f, dur):
    tt = t(dur)
    return paso_bajo(triangular(f, dur), 800) * env(len(tt), 0.005, 0.15, 0.5, 0.05)


def pad(fs, dur):
    tt = t(dur)
    x = np.zeros(len(tt))
    for f in fs:
        for d in (-0.15, 0.15):
            x += sierra(f * (1 + d / 100), dur)
    x = paso_bajo(x / (len(fs) * 2), 1200)
    return x * env(len(tt), 0.4, 0.2, 0.8, 0.5)


def bombo(dur=0.35, grave=1.0):
    tt = t(dur)
    f = (120 * np.exp(-tt * 25) + 45) * grave
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-tt * 9)


def caja(dur=0.2):
    tt = t(dur)
    return (paso_alto(ruido(dur), 1200) * 0.8 + 0.4 * np.sin(2 * np.pi * 190 * tt)) * np.exp(-tt * 22)


def charles(dur=0.06):
    tt = t(dur)
    return paso_alto(ruido(dur), 6000) * np.exp(-tt * 60)


def maraca(dur=0.08):
    tt = t(dur)
    return paso_alto(ruido(dur), 4000) * np.exp(-tt * 40) * 0.6


def timbal(f, dur=0.8):
    tt = t(dur)
    return (np.sin(2 * np.pi * f * tt) + 0.3 * paso_bajo(ruido(dur), 400)) * np.exp(-tt * 4)


# ---------------------------------------------------------------- música
ESCALA_MAYOR = [0, 2, 4, 5, 7, 9, 11]
ESCALA_MENOR = [0, 2, 3, 5, 7, 8, 10]


def grado(tonica, escala, g, octava=0):
    o, i = divmod(g, 7)
    return tonica + escala[i] + 12 * (o + octava)


def acorde(tonica, escala, g):
    return [grado(tonica, escala, g), grado(tonica, escala, g + 2), grado(tonica, escala, g + 4)]


def bucle(compases, bpm, render):
    """Renderiza y pliega la cola del final al principio para que el bucle no se note."""
    negra = 60 / bpm
    dur = compases * 4 * negra
    cola = 2.0
    buf = np.zeros(int((dur + cola) * SR))
    render(buf, negra)
    n = int(dur * SR)
    out = buf[:n].copy()
    out[: len(buf) - n] += buf[n:]
    return out


def melodia_desde(motivo, tonica, escala, octava):
    return [(grado(tonica, escala, g, octava) if g is not None else None, d) for g, d in motivo]


def musica_ciudad():
    bpm, ton, esc = 112, 60, ESCALA_MAYOR  # Do mayor
    progresion = [0, 5, 3, 4]  # I vi IV V
    motivo = [(4, 1), (4, 0.5), (5, 0.5), (4, 1), (2, 1), (0, 1.5), (1, 0.5), (2, 2),
              (4, 1), (4, 0.5), (5, 0.5), (7, 1), (6, 1), (4, 1.5), (5, 0.5), (4, 2)]
    motivo_b = [(7, 1.5), (6, 0.5), (5, 1), (4, 1), (5, 1), (4, 0.5), (2, 0.5), (0, 2),
                (2, 1), (4, 1), (5, 1), (6, 1), (7, 3), (None, 1)]

    def render(buf, q):
        for compas in range(32):
            g = progresion[compas % 4]
            ac = acorde(ton, esc, g)
            inicio = compas * 4 * q
            # marimba arpegiada
            for k, n in enumerate([ac[0], ac[1], ac[2], ac[1]] * 2):
                mezclar(buf, marimba(nota(n + 12), q * 0.9), inicio + k * q / 2, 0.22)
            # pizzicato de bajo
            for k, n in enumerate([ac[0] - 12, ac[2] - 12, ac[0] - 12, ac[2] - 12]):
                mezclar(buf, cuerda(nota(n), q * 0.8, 0.3), inicio + k * q, 0.35)
            # maraca
            for k in range(8):
                mezclar(buf, maraca(), inicio + k * q / 2 + (0.02 if k % 2 else 0), 0.15 if k % 2 else 0.08)
            if compas % 4 == 0:
                mezclar(buf, bombo(0.3, 1.2), inicio, 0.35)
        # melodía silbada (A A B A)
        pos = 0.0
        for parte in (motivo, motivo, motivo_b, motivo) * 2:
            for n, d in melodia_desde(parte, ton, esc, 1):
                if n is not None:
                    mezclar(buf, silbido(nota(n), d * q * 0.95), pos, 0.28)
                pos += d * q
    return bucle(32, bpm, render)


def musica_aventura():
    bpm, ton, esc = 128, 55, ESCALA_MAYOR  # Sol mayor
    progresion = [0, 4, 5, 3]  # I V vi IV
    motivo = [(0, 0.5), (2, 0.5), (4, 1), (4, 0.5), (5, 0.5), (7, 1), (6, 0.5), (4, 0.5), (5, 1), (4, 2),
              (2, 0.5), (4, 0.5), (5, 1), (7, 1), (8, 1), (7, 0.5), (5, 0.5), (4, 1), (2, 2), (None, 1)]
    motivo_b = [(7, 1), (9, 1), (8, 0.5), (7, 0.5), (5, 1), (4, 1), (5, 1), (7, 2), (4, 1), (5, 1),
                (4, 0.5), (2, 0.5), (0, 1), (1, 1), (2, 3), (None, 1)]

    def render(buf, q):
        for compas in range(32):
            g = progresion[compas % 4]
            ac = acorde(ton, esc, g)
            inicio = compas * 4 * q
            mezclar(buf, pad([nota(n) for n in ac], 4 * q), inicio, 0.18)
            # guitarra a contratiempo
            for k in range(4):
                for n in ac:
                    mezclar(buf, cuerda(nota(n + 12), q * 0.4, 0.7), inicio + k * q + q / 2, 0.09)
            for k, n in enumerate([ac[0] - 12, ac[0] - 12, ac[2] - 12, ac[1] - 12]):
                mezclar(buf, bajo(nota(n), q * 0.9), inicio + k * q, 0.4)
            for k in range(4):
                mezclar(buf, bombo(0.3), inicio + k * q, 0.4 if k % 2 == 0 else 0.0)
                if k % 2 == 1:
                    mezclar(buf, caja(), inicio + k * q, 0.3)
            for k in range(8):
                mezclar(buf, charles(), inicio + k * q / 2, 0.12)
        pos = 4 * 4 * q  # entra la melodía en el compás 5
        for parte in (motivo, motivo_b, motivo, motivo_b, motivo, motivo_b, motivo):
            for n, d in melodia_desde(parte, ton, esc, 1):
                if n is not None and pos < 32 * 4 * q:
                    mezclar(buf, flauta_cuadrada(nota(n), d * q * 0.9), pos, 0.2)
                pos += d * q
    return bucle(32, bpm, render)


def musica_combate():
    bpm, ton, esc = 150, 57, ESCALA_MENOR  # La menor
    progresion = [0, 5, 6, 0, 0, 5, 3, 4]
    motivo = [(4, 0.5), (None, 0.5), (4, 0.5), (3, 0.5), (4, 1), (None, 1),
              (2, 0.5), (3, 0.5), (4, 0.5), (6, 0.5), (7, 1), (6, 0.5), (4, 0.5),
              (3, 0.5), (None, 0.5), (3, 0.5), (2, 0.5), (3, 1), (1, 1), (0, 2), (None, 2)]

    def render(buf, q):
        for compas in range(32):
            g = progresion[compas % 8]
            ac = acorde(ton, esc, g)
            inicio = compas * 4 * q
            # fagot staccato con bajo cromático (cómico)
            linea = [ac[0] - 12, ac[0] - 12, ac[0] - 11, ac[0] - 10, ac[2] - 12, ac[2] - 12, ac[1] - 12, ac[0] - 13]
            for k, n in enumerate(linea):
                mezclar(buf, fagot(nota(n), q * 0.4), inicio + k * q / 2, 0.35)
            for k in range(4):
                mezclar(buf, bombo(0.25), inicio + k * q, 0.5)
                if k in (1, 3):
                    mezclar(buf, caja(), inicio + k * q, 0.35)
            for k in range(8):
                mezclar(buf, charles(), inicio + k * q / 2, 0.14)
            if compas % 8 == 7:
                for k in range(8):
                    mezclar(buf, caja(0.12), inicio + 2 * q + k * q / 4, 0.18 + k * 0.03)
            mezclar(buf, pad([nota(n) for n in ac], 4 * q), inicio, 0.1)
        pos = 0.0
        while pos < 32 * 4 * q - 1:
            for n, d in melodia_desde(motivo, ton, esc, 1):
                if n is not None and pos < 32 * 4 * q:
                    mezclar(buf, kazoo(nota(n), d * q * 0.85), pos, 0.2)
                pos += d * q
    return bucle(32, bpm, render)


def musica_jefe():
    bpm, ton, esc = 140, 50, ESCALA_MENOR  # Re menor
    progresion = [0, 0, 5, 6, 0, 0, 3, 4]
    motivo = [(0, 1), (0, 0.5), (2, 0.5), (3, 1), (4, 1), (5, 1.5), (4, 0.5), (3, 1), (2, 1),
              (0, 1), (-1, 0.5), (0, 0.5), (2, 2), (4, 2), (3, 1), (2, 1), (0, 4)]

    def render(buf, q):
        for compas in range(32):
            g = progresion[compas % 8]
            ac = acorde(ton, esc, g)
            inicio = compas * 4 * q
            for k in range(8):
                n = ac[0] - 12 if k % 2 == 0 else ac[0]
                mezclar(buf, paso_bajo(sierra(nota(n), q * 0.45), 700) * env(int(q * 0.45 * SR), 0.005, 0.1, 0.5, 0.05), inicio + k * q / 2, 0.3)
            mezclar(buf, pad([nota(n + 12) for n in ac], 4 * q), inicio, 0.16)
            mezclar(buf, timbal(nota(ton - 24)), inicio, 0.6)
            mezclar(buf, timbal(nota(ton - 17)), inicio + 2 * q, 0.45)
            for k in range(4):
                mezclar(buf, caja(), inicio + k * q + q / 2, 0.2 if k % 2 else 0.12)
            if compas % 2 == 1:
                for n in ac:
                    mezclar(buf, tuba(nota(n), q * 0.6), inicio + 3 * q, 0.12)
        pos = 2 * 4 * q
        while pos < 32 * 4 * q - 1:
            for n, d in melodia_desde(motivo, ton, esc, 0):
                if n is not None and pos < 32 * 4 * q:
                    mezclar(buf, tuba(nota(n), d * q * 0.9), pos, 0.32)
                pos += d * q
    return bucle(32, bpm, render)


# ---------------------------------------------------------------- efectos
def ef_paso(tono=1.0):
    dur = 0.18
    tt = t(dur)
    golpe = np.sin(2 * np.pi * 140 * tono * tt) * np.exp(-tt * 45)
    papel = paso_bajo(ruido(dur), 2500 * tono) * np.exp(-tt * 35)
    return golpe * 0.7 + papel * 0.6


def ef_boing(dur=0.5, base=220):
    tt = t(dur)
    f = base * (1 + 1.6 * tt / dur) * (1 + 0.12 * np.sin(2 * np.pi * 14 * tt))
    return seno(f, dur) * np.exp(-tt * 5)


def ef_tic(f, dur=0.08):
    tt = t(dur)
    return (np.sin(2 * np.pi * f * tt) + 0.3 * paso_alto(ruido(dur), 3000)) * np.exp(-tt * 70)


def ef_golpe():
    tt = t(0.4)
    return bombo(0.4, 1.3) * 0.9 + paso_bajo(ruido(0.4), 1500) * np.exp(-tt * 18) * 0.6


def ef_corte():
    dur = 0.4
    tt = t(dur)
    fc = np.linspace(800, 6000, len(tt))
    silbo = paso_alto(ruido(dur), 1500) * np.sin(np.pi * tt / dur) ** 2
    anillo = np.sin(2 * np.pi * 2400 * tt) * np.exp(-tt * 12) * (tt > 0.15)
    return silbo * 0.8 + anillo * 0.25 + 0 * fc[: len(tt)]


def ef_fuego():
    dur = 0.8
    tt = t(dur)
    rug = paso_bajo(ruido(dur), 900) * np.minimum(1, tt * 8) * np.exp(-tt * 3)
    chis = paso_alto(ruido(dur), 3000) * np.exp(-tt * 6) * 0.3
    return rug * 1.4 + chis


def ef_rayo():
    dur = 0.8
    tt = t(dur)
    f = 1200 * np.exp(-tt * 6) + 80
    zap = sierra(f, dur) * np.exp(-tt * 4)
    crep = paso_alto(ruido(dur), 2000) * (RNG.uniform(0, 1, len(tt)) > 0.97) * 2
    return zap * 0.6 + crep * np.exp(-tt * 3)


def ef_flecha():
    dur = 0.5
    tt = t(dur)
    silbo = paso_alto(ruido(dur), 2500) * np.exp(-((tt - 0.12) ** 2) / 0.004)
    toc = np.sin(2 * np.pi * 320 * tt) * np.exp(-(tt - 0.3).clip(0) * 40) * (tt > 0.3)
    return silbo * 0.7 + toc * 0.8


def arpegio(notas, paso, dur_nota, timbre="campana"):
    dur = paso * len(notas) + dur_nota
    out = np.zeros(int(dur * SR))
    for k, n in enumerate(notas):
        tt = t(dur_nota)
        if timbre == "campana":
            s = (np.sin(2 * np.pi * nota(n) * tt) + 0.4 * np.sin(2 * np.pi * nota(n) * 2.76 * tt)) * np.exp(-tt * 6)
        elif timbre == "cuadrada":
            s = cuadrada(nota(n), dur_nota, 0.25) * env(len(tt), 0.005, 0.05, 0.6, 0.05) * 0.5
        else:
            s = marimba(nota(n), dur_nota)
        mezclar(out, s, k * paso)
    return out


def ef_veneno():
    out = np.zeros(int(0.7 * SR))
    for k in range(6):
        tt = t(0.09)
        f = (200 + RNG.uniform(0, 150)) * (1 + tt * 6)
        mezclar(out, seno(f, 0.09) * np.exp(-tt * 30), k * 0.1, 0.8)
    return out


def ef_escudo():
    dur = 0.6
    tt = t(dur)
    mod = np.sin(2 * np.pi * 880 * 1.41 * tt) * 3 * np.exp(-tt * 4)
    return np.sin(2 * np.pi * 880 * tt + mod) * np.exp(-tt * 5)


def ef_trombon_triste():
    """Wah wah wah waaah (derrota)."""
    out = np.zeros(int(2.6 * SR))
    notas = [(62, 0.45), (61, 0.45), (60, 0.45), (59, 1.2)]
    pos = 0.0
    for k, (n, d) in enumerate(notas):
        tt = t(d)
        vib = 1 + (0.025 * np.sin(2 * np.pi * 6 * tt) if k == 3 else 0)
        x = sierra(nota(n - 12) * vib, d)
        # "wah": el filtro se abre y se cierra
        corte = 300 + 1500 * np.sin(np.pi * np.clip(tt / d, 0, 1))
        y = np.zeros_like(x)
        acc = 0.0
        for i in range(len(x)):
            a = np.exp(-2 * np.pi * corte[i] / SR)
            acc = (1 - a) * x[i] + a * acc
            y[i] = acc
        mezclar(out, y * env(len(tt), 0.04, 0.1, 0.8, 0.1), pos, 0.9)
        pos += d
    return out


def ef_psst():
    dur = 0.6
    tt = t(dur)
    p = np.exp(-tt * 200) * 0.6 * RNG.uniform(-1, 1, len(tt))
    s = paso_alto(ruido(dur), 4000) * np.clip((tt - 0.05) * 10, 0, 1) * np.exp(-np.clip(tt - 0.25, 0, None) * 12)
    return p + s * 0.7


def ef_explosion():
    dur = 0.9
    tt = t(dur)
    return bombo(0.9, 0.6) * 0.9 + paso_bajo(ruido(dur), 700) * np.exp(-tt * 4) * 1.2


def efectos():
    total = 36.0
    buf = np.zeros(int(total * SR))

    def pon(seg, x, vol=1.0, largo=0.95):
        x = normalizar(x, 0.89 * vol)
        x = x[: int(largo * SR)]
        mezclar(buf, x, seg)

    pon(0, ef_paso(1.0), 0.8)
    pon(1, ef_paso(1.18), 0.8)
    pon(2, ef_boing(0.45, 260))
    pon(3, ef_tic(1800), 0.7)
    pon(4, ef_tic(2600, 0.06), 0.4)
    pon(5, ef_golpe())
    pon(6, ef_corte())
    pon(7, ef_fuego())
    pon(8, ef_rayo())
    pon(9, ef_flecha())
    pon(10, arpegio([72, 76, 79, 84, 88], 0.08, 0.5), 0.8)
    pon(11, ef_veneno())
    pon(12, ef_escudo(), 0.8)
    pon(13, ef_golpe() * 0.8 + np.pad(arpegio([84], 0.1, 0.6), (0, 0))[: int(0.4 * SR)], 1.0)
    pon(14, arpegio([83, 88], 0.07, 0.35), 0.8)
    creak = paso_bajo(sierra(60 + 20 * np.sin(2 * np.pi * 3 * t(0.4)), 0.4), 1200) * 0.5
    pon(15, np.concatenate([creak, arpegio([72, 76, 79, 84], 0.06, 0.4, "cuadrada")]))
    pon(16, arpegio([67, 71, 74, 79, 83, 86, 91], 0.06, 0.5), 0.85)
    pon(17, arpegio([60, 64, 67, 72, 67, 72, 76], 0.1, 0.35, "cuadrada"))
    # victoria: fanfarria corta
    vic = np.zeros(int(2.6 * SR))
    for k, (n, d, p) in enumerate([(72, 0.15, 0), (72, 0.15, 0.15), (72, 0.15, 0.3), (76, 0.5, 0.45), (74, 0.3, 0.95), (76, 0.3, 1.25), (79, 1.0, 1.55)]):
        mezclar(vic, flauta_cuadrada(nota(n), d), p, 0.6)
        mezclar(vic, cuadrada(nota(n - 12), d, 0.5) * env(int(d * SR), 0.01, 0.05, 0.5, 0.05) * 0.25, p)
    mezclar(vic, timbal(nota(48), 1.0), 1.55, 0.6)
    pon(18, vic, 1.0, 2.6)
    pon(21, ef_trombon_triste(), 1.0, 2.6)
    pon(24, cuadrada(880, 0.06, 0.5) * env(int(0.06 * SR), 0.002, 0.02, 0.5, 0.02), 0.35, 0.08)
    pon(25, arpegio([67, 71, 74, 79, 74, 79, 83], 0.07, 0.45, "cuadrada"))
    pon(26, arpegio([96, 91, 100, 96], 0.09, 0.4), 0.7)
    pon(27, np.concatenate([ef_golpe()[: int(0.15 * SR)], np.concatenate([ef_tic(900, 0.05) for _ in range(5)])]), 0.8)
    swish = paso_alto(ruido(0.3), 1200) * np.sin(np.pi * t(0.3) / 0.3) ** 2
    pon(28, swish, 0.6)
    pon(29, ef_boing(0.6, 120))
    pon(30, ef_explosion())
    pop = seno(900 * np.exp(-t(0.12) * 25) + 200, 0.12) * np.exp(-t(0.12) * 30)
    pon(31, pop, 0.7)
    pon(32, paso_bajo(ruido(0.6), 1200) * np.exp(-t(0.6) * 7), 0.7)
    pon(33, arpegio([79, 84], 0.12, 0.3), 0.6)
    pon(34, ef_psst(), 0.8)
    return buf


# ---------------------------------------------------------------- música por zona (v2.0)
ESCALA_DORICA = [0, 2, 3, 5, 7, 9, 10]
ESCALA_FRIGIA = [0, 1, 3, 5, 7, 8, 10]
ESCALA_LIDIA = [0, 2, 4, 6, 7, 9, 11]


def tocar_melodia(buf, partes, ton, esc, octava, q, instrumento, vol, desde=0.0, hasta=None):
    pos = desde
    for parte in partes:
        for n, d in melodia_desde(parte, ton, esc, octava):
            if n is not None and (hasta is None or pos < hasta):
                mezclar(buf, instrumento(nota(n), d * q * 0.92), pos, vol)
            pos += d * q
    return pos


def musica_aldea():
    """Aldea de Brezo: vals tranquilo de pueblo (3/4), flauta y acordeón, con pájaros."""
    bpm, ton, esc = 96, 65, ESCALA_MAYOR  # Fa mayor
    progresion = [0, 3, 4, 0, 5, 3, 1, 4]
    motivo = [(4, 1), (5, 0.5), (4, 0.5), (2, 1), (0, 2), (1, 1), (2, 2), (None, 1),
              (4, 1), (5, 0.5), (7, 0.5), (6, 1), (5, 2), (4, 1), (2, 2), (None, 1)]
    motivo_b = [(7, 2), (6, 1), (5, 1.5), (4, 0.5), (5, 1), (4, 2), (2, 1), (1, 1.5), (2, 0.5), (4, 1), (0, 3)]

    def render(buf, q):
        compas = 3 * q
        for c in range(32):
            ac = acorde(ton, esc, progresion[c % 8])
            ini = c * compas
            mezclar(buf, bajo(nota(ac[0] - 12), q * 0.9), ini, 0.4)
            for k in (1, 2):
                for n in ac:
                    mezclar(buf, cuerda(nota(n), q * 0.5, 0.4), ini + k * q, 0.07)
            mezclar(buf, pad([nota(n) for n in ac], compas), ini, 0.12)
            if c % 4 == 2:  # un pajarito
                mezclar(buf, silbido(nota(ton + 31), 0.12), ini + 0.3, 0.08)
                mezclar(buf, silbido(nota(ton + 34), 0.1), ini + 0.45, 0.06)
        tocar_melodia(buf, (motivo, motivo_b, motivo, motivo_b), ton, esc, 1, q, flauta_cuadrada, 0.18, desde=4 * compas, hasta=32 * compas)

    # vals: 32 compases de 3 tiempos (bucle() cuenta en compases de 4, así que se pasa 24)
    return bucle(24, bpm, render)


def musica_pantano():
    """Pantano Brumoso: lento y un poco cómico-tenebroso. Fagot, gotas de marimba y croar de ranas."""
    bpm, ton, esc = 76, 50, ESCALA_DORICA  # Re dórico
    progresion = [0, 0, 3, 4]
    motivo = [(0, 1), (2, 0.5), (3, 0.5), (4, 2), (3, 1), (2, 1), (0, 2), (None, 2),
              (4, 1), (5, 0.5), (4, 0.5), (3, 1), (2, 1), (1, 2), (0, 2), (None, 2)]

    def render(buf, q):
        for c in range(24):
            ac = acorde(ton, esc, progresion[c % 4])
            ini = c * 4 * q
            mezclar(buf, pad([nota(ac[0] - 12), nota(ac[2] - 12)], 4 * q), ini, 0.16)
            for k in range(4):
                mezclar(buf, cuerda(nota(ac[0] - 24 + (7 if k % 2 else 0)), q * 0.8, 0.2), ini + k * q, 0.3)
            # gotas
            for k in (1, 3):
                n = ac[(c + k) % 3] + 24
                mezclar(buf, marimba(nota(n), q * 0.6), ini + k * q + q * 0.5, 0.1)
                mezclar(buf, marimba(nota(n), q * 0.6), ini + k * q + q * 0.8, 0.04)  # eco
            if c % 3 == 1:  # una rana
                tt = t(0.25)
                croac = paso_bajo(cuadrada(110 * (1 + 0.3 * np.sin(2 * np.pi * 25 * tt)), 0.25, 0.3), 700) * np.exp(-tt * 8)
                mezclar(buf, croac, ini + 2.5 * q, 0.15)
        tocar_melodia(buf, (motivo, motivo, motivo), ton, esc, 0, q, fagot, 0.22, desde=4 * 4 * q, hasta=24 * 4 * q)

    return bucle(24, bpm, render)


def musica_bosque():
    """Bosque Susurrante: misterioso, arpa en 6/8 y flauta."""
    bpm, ton, esc = 104, 64, ESCALA_MENOR  # Mi menor
    progresion = [0, 5, 2, 6]
    motivo = [(4, 1.5), (3, 0.5), (2, 1), (4, 1), (7, 2), (None, 2),
              (6, 1.5), (5, 0.5), (4, 1), (2, 1), (3, 3), (None, 1)]
    motivo_b = [(7, 1), (8, 1), (7, 1), (6, 1), (4, 2), (2, 2), (3, 1), (4, 1), (2, 1), (1, 1), (0, 4)]

    def render(buf, q):
        for c in range(32):
            ac = acorde(ton, esc, progresion[c % 4])
            ini = c * 4 * q
            mezclar(buf, pad([nota(n - 12) for n in ac], 4 * q), ini, 0.12)
            arpe = [ac[0], ac[1], ac[2], ac[1] + 12, ac[2], ac[1]]
            for k, n in enumerate(arpe * 2):
                mezclar(buf, cuerda(nota(n), q * 0.9, 0.8), ini + k * (4 * q / 12), 0.1)
            mezclar(buf, bajo(nota(ac[0] - 24), 2 * q), ini, 0.3)
            mezclar(buf, timbal(nota(ac[0] - 24), 0.6), ini, 0.12)
        tocar_melodia(buf, (motivo, motivo_b, motivo, motivo_b, motivo), ton, esc, 1, q, silbido, 0.2, desde=4 * 4 * q, hasta=32 * 4 * q)

    return bucle(32, bpm, render)


def musica_ruinas():
    """Ruinas de Ceniza: antiguo y solemne. Tambores lentos, modo frigio y coro de pad."""
    bpm, ton, esc = 84, 52, ESCALA_FRIGIA  # Mi frigio
    progresion = [0, 1, 0, 6]
    motivo = [(0, 2), (1, 1), (3, 1), (4, 2), (3, 1), (1, 1), (0, 4),
              (4, 1), (5, 1), (4, 1), (3, 1), (1, 2), (3, 2), (0, 4)]

    def render(buf, q):
        for c in range(24):
            ac = acorde(ton, esc, progresion[c % 4])
            ini = c * 4 * q
            mezclar(buf, pad([nota(n) for n in ac] + [nota(ac[0] - 12)], 4 * q), ini, 0.2)
            mezclar(buf, timbal(nota(ac[0] - 24), 1.2), ini, 0.3)
            mezclar(buf, timbal(nota(ac[0] - 24), 0.6), ini + 2.5 * q, 0.18)
            mezclar(buf, bombo(0.4, 0.8), ini + 3 * q, 0.2)
            for k in range(4):
                mezclar(buf, maraca(0.12), ini + k * q + q / 2, 0.06)
        tocar_melodia(buf, (motivo, motivo, motivo), ton, esc, 1, q, fagot, 0.18, desde=8 * q, hasta=24 * 4 * q)
        tocar_melodia(buf, (motivo,), ton, esc, 2, q, flauta_cuadrada, 0.1, desde=12 * 4 * q, hasta=24 * 4 * q)

    return bucle(24, bpm, render)


def musica_picos():
    """Picos Nevados: helado y brillante. Celesta (marimba aguda), cascabeles y modo lidio."""
    bpm, ton, esc = 112, 59, ESCALA_LIDIA  # Si lidio
    progresion = [0, 1, 0, 4]
    motivo = [(4, 1), (6, 1), (7, 2), (6, 1), (4, 1), (2, 2), (3, 1), (4, 1), (1, 2), (0, 4),
              (7, 1), (8, 1), (9, 2), (8, 1), (7, 1), (6, 2), (4, 1), (3, 1), (4, 4), (None, 2)]

    def render(buf, q):
        for c in range(32):
            ac = acorde(ton, esc, progresion[c % 4])
            ini = c * 4 * q
            mezclar(buf, pad([nota(n) for n in ac], 4 * q), ini, 0.14)
            for k, n in enumerate([ac[0], ac[2], ac[1] + 12, ac[2]] * 2):
                mezclar(buf, marimba(nota(n + 24), q * 0.5), ini + k * q / 2, 0.1)
            mezclar(buf, bajo(nota(ac[0] - 12), 4 * q * 0.9), ini, 0.3)
            for k in range(8):  # cascabeles de trineo
                mezclar(buf, charles(0.09), ini + k * q / 2, 0.1 if k % 2 == 0 else 0.05)
        tocar_melodia(buf, (motivo, motivo, motivo), ton, esc, 1, q, silbido, 0.19, desde=4 * 4 * q, hasta=32 * 4 * q)

    return bucle(32, bpm, render)


def musica_callejon():
    """Callejón del Gato: sigiloso, de puntillas. Contrabajo caminando y fagot a saltitos."""
    bpm, ton, esc = 100, 57, ESCALA_MENOR  # La menor
    progresion = [0, 3, 0, 4]
    motivo = [(0, 0.5), (None, 0.5), (2, 0.5), (None, 0.5), (3, 0.5), (None, 0.5), (4, 1), (None, 1),
              (6, 0.5), (4, 0.5), (3, 0.5), (2, 0.5), (0, 2), (None, 2)]

    def render(buf, q):
        for c in range(32):
            ac = acorde(ton, esc, progresion[c % 4])
            ini = c * 4 * q
            camino = [ac[0], ac[0] + 2, ac[1], ac[2]]
            for k, n in enumerate(camino):
                mezclar(buf, cuerda(nota(n - 24), q * 0.7, 0.2), ini + k * q, 0.4)
            for k in range(4):
                mezclar(buf, charles(0.08), ini + k * q + q * 0.66, 0.08)
                if k in (1, 3):
                    mezclar(buf, caja(0.12), ini + k * q, 0.1)
            if c % 8 == 7:  # un maullido
                tt = t(0.5)
                miau = seno(700 + 300 * np.sin(np.pi * tt / 0.5), 0.5) * env(len(tt), 0.05, 0.1, 0.6, 0.2)
                mezclar(buf, miau, ini + 2 * q, 0.06)
        tocar_melodia(buf, (motivo,) * 6, ton, esc, 0, q, fagot, 0.2, desde=4 * 4 * q, hasta=32 * 4 * q)

    return bucle(32, bpm, render)


def musica_taberna():
    """Taberna El Hongo Feliz: giga rápida y gamberra con kazoo, tuba y palmas."""
    bpm, ton, esc = 150, 62, ESCALA_MAYOR  # Re mayor
    progresion = [0, 4, 0, 4, 3, 0, 4, 0]
    motivo = [(0, 0.5), (2, 0.5), (4, 0.5), (4, 0.5), (5, 0.5), (4, 0.5), (2, 1), (4, 0.5), (2, 0.5), (0, 1), (1, 1),
              (2, 0.5), (4, 0.5), (7, 0.5), (7, 0.5), (6, 0.5), (4, 0.5), (5, 1), (4, 0.5), (2, 0.5), (0, 2)]

    def render(buf, q):
        for c in range(32):
            ac = acorde(ton, esc, progresion[c % 8])
            ini = c * 4 * q
            for k in range(4):
                n = ac[0] if k % 2 == 0 else ac[2]
                mezclar(buf, tuba(nota(n - 24), q * 0.5), ini + k * q, 0.35)
                for m in ac:
                    mezclar(buf, cuerda(nota(m), q * 0.3, 0.6), ini + k * q + q / 2, 0.06)
            for k in (1, 3):  # palmas
                mezclar(buf, caja(0.1), ini + k * q, 0.18)
            for k in range(8):
                mezclar(buf, maraca(), ini + k * q / 2, 0.08)
        tocar_melodia(buf, (motivo,) * 8, ton, esc, 1, q, kazoo, 0.15, desde=2 * 4 * q, hasta=32 * 4 * q)

    return bucle(32, bpm, render)


def musica_bodegas():
    """Bodegas del Gran Guiso: tensa y con ritmo, para las oleadas."""
    bpm, ton, esc = 132, 53, ESCALA_MENOR  # Fa menor
    progresion = [0, 0, 5, 4]
    motivo = [(0, 0.5), (0, 0.5), (2, 0.5), (3, 0.5), (4, 1), (3, 0.5), (2, 0.5), (0, 1), (None, 1),
              (4, 0.5), (4, 0.5), (5, 0.5), (6, 0.5), (7, 1), (6, 0.5), (5, 0.5), (4, 2)]

    def render(buf, q):
        for c in range(32):
            ac = acorde(ton, esc, progresion[c % 4])
            ini = c * 4 * q
            for k in range(8):  # ostinato grave
                mezclar(buf, bajo(nota(ac[0] - 12 + (12 if k % 4 == 3 else 0)), q * 0.45), ini + k * q / 2, 0.3)
            mezclar(buf, pad([nota(n) for n in ac], 4 * q), ini, 0.12)
            for k in range(4):
                mezclar(buf, bombo(0.3), ini + k * q, 0.35)
                if k % 2 == 1:
                    mezclar(buf, caja(), ini + k * q, 0.25)
                mezclar(buf, charles(), ini + k * q + q / 2, 0.1)
            if c % 4 == 3:
                mezclar(buf, timbal(nota(ac[0] - 24), 0.8), ini + 3.5 * q, 0.25)
        tocar_melodia(buf, (motivo,) * 7, ton, esc, 1, q, flauta_cuadrada, 0.16, desde=4 * 4 * q, hasta=32 * 4 * q)

    return bucle(32, bpm, render)


NUEVAS = {
    "aldea": musica_aldea, "pantano": musica_pantano, "bosque": musica_bosque, "ruinas": musica_ruinas,
    "picos": musica_picos, "callejon": musica_callejon, "taberna": musica_taberna, "bodegas": musica_bodegas,
}


def main():
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == "zonas":
        # solo las canciones nuevas de cada zona (v2.0)
        for nombre, f in NUEVAS.items():
            print("Componiendo música:", nombre, "…")
            x = normalizar(f(), 0.8)
            retardo = int(0.012 * SR)
            der = np.concatenate([np.zeros(retardo), x[:-retardo]]) * 0.9 + x * 0.1
            guardar_ogg(x, "vael-musica-" + nombre, der)
        return
    print("Generando efectos…")
    guardar_ogg(efectos(), "vael-efectos")
    for nombre, f in (("ciudad", musica_ciudad), ("aventura", musica_aventura), ("combate", musica_combate), ("jefe", musica_jefe)):
        print("Componiendo música:", nombre, "…")
        x = normalizar(f(), 0.8)
        # estéreo sencillo: un poco de eco a la derecha para dar amplitud
        retardo = int(0.012 * SR)
        der = np.concatenate([np.zeros(retardo), x[:-retardo]]) * 0.9 + x * 0.1
        guardar_ogg(x, "vael-musica-" + nombre, der)


if __name__ == "__main__":
    main()
