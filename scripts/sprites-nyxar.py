"""
Convierte los sprites renderizados de Nyxar en paquetes listos para usar.

Uso:
  npx remotion render SpritesNyxar <carpeta>/png --sequence --image-format=png --browser-executable=/opt/pw-browsers/chromium
  python3 scripts/sprites-nyxar.py <carpeta>/png public/marca/sprites

Genera:
  pngtuber/     7 expresiones × (callado/hablando) × (ojos abiertos/cerrados), alineados y del mismo tamaño
  expresiones/  caras sueltas + hoja de personaje
  poses/        poses de cuerpo entero (saludo, señalar, objetos...)
  stickers/     512×512 con borde blanco, en PNG y WebP (WhatsApp/Telegram)
  pixel/        versión pixel art: caras, poses y animaciones en tiras + JSON
"""
import json
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ORIGEN, DESTINO = sys.argv[1], sys.argv[2]
LISTA = json.load(open("src/personajes/sprites.json", encoding="utf-8"))

NOCHE = (7, 23, 51, 255)
ABISMO = (2, 8, 20, 255)
MENTA = (94, 231, 196, 255)
HUESO = (241, 245, 255, 255)
NIEBLA = (154, 171, 201, 255)


def fuente(tam, gruesa=True):
    for f in [
        "node_modules/@fontsource/baloo-2/files/baloo-2-latin-800-normal.woff",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    ]:
        try:
            return ImageFont.truetype(f, tam)
        except OSError:
            continue
    return ImageFont.load_default()


def carga(nombre):
    i = next(k for k, x in enumerate(LISTA) if x["nombre"] == nombre)
    return Image.open(os.path.join(ORIGEN, f"element-{i:02d}.png")).convert("RGBA")


def caja_union(imgs, margen=16):
    cajas = [im.getchannel("A").getbbox() for im in imgs]
    x0 = min(c[0] for c in cajas) - margen
    y0 = min(c[1] for c in cajas) - margen
    x1 = max(c[2] for c in cajas) + margen
    y1 = max(c[3] for c in cajas) + margen
    w, h = imgs[0].size
    return (max(0, x0), max(0, y0), min(w, x1), min(h, y1))


def solo_pieza_principal(im):
    """Deja solo la pieza más grande (quita restos sueltos como la punta de la cola)."""
    import cv2

    a = (np.array(im.getchannel("A")) > 20).astype(np.uint8)
    n, etiquetas, stats, _ = cv2.connectedComponentsWithStats(a, 8)
    if n <= 2:
        return im
    mayor = 1 + int(np.argmax(stats[1:, cv2.CC_STAT_AREA]))
    arr = np.array(im)
    arr[..., 3] = np.where(etiquetas == mayor, arr[..., 3], 0)
    return Image.fromarray(arr, "RGBA")


def guarda(im, ruta):
    os.makedirs(os.path.dirname(ruta), exist_ok=True)
    im.save(ruta, optimize=True)


def nombres(grupo):
    return [x["nombre"] for x in LISTA if x["grupo"] == grupo]


# Recorte común de cabeza (para caras y PNGTuber): desde arriba de las orejas hasta el pañuelo.
CABEZA = None


# ---------- PNGTuber ----------
def pngtuber():
    ns = nombres("pngtuber")
    imgs = [carga(n) for n in ns]
    caja = caja_union(imgs)
    for n, im in zip(ns, imgs):
        guarda(im.crop(caja), f"{DESTINO}/pngtuber/{n}.png")
    return caja


# ---------- Expresiones y hoja de personaje ----------
ETIQUETAS = {
    "normal": "Normal",
    "feliz": "Feliz",
    "sorprendido": "Sorprendido",
    "enfadado": "Enfadado",
    "pensativo": "Pensativo",
    "guino": "Guiño",
    "triste": "Triste",
}
POSES = {
    "pose-saludo": "Saludo",
    "pose-senalar": "Señalar",
    "pose-celebrar": "Celebrar",
    "pose-encogerse": "¿Quién sabe?",
    "pose-pensar": "Pensar",
    "pose-enfadado": "Enfadado",
    "pose-portatil": "Portátil",
    "pose-libro": "Libro",
    "pose-mando": "Mando",
    "pose-movil": "Móvil",
    "pose-lupa": "Lupa",
    "pose-idea": "¡Idea!",
}


def caras_y_hoja():
    ns = nombres("expresiones")
    imgs = [carga(n) for n in ns]
    # Solo la cabeza: cortar a la altura del pañuelo.
    caja = caja_union(imgs)
    alto_cabeza = int((caja[3] - caja[1]) * 0.62)
    caja_cab = (caja[0], caja[1], caja[2], caja[1] + alto_cabeza)
    caras = []
    for n, im in zip(ns, imgs):
        c = solo_pieza_principal(im.crop(caja_cab))
        guarda(c, f"{DESTINO}/expresiones/{n}.png")
        caras.append(c)

    ps = list(POSES.keys())
    pimgs = [carga(n) for n in ps]
    pcaja = caja_union(pimgs)
    poses = []
    for n, im in zip(ps, pimgs):
        c = im.crop(pcaja)
        guarda(c, f"{DESTINO}/poses/{n.replace('pose-', '')}.png")
        poses.append(c)

    # Hoja de personaje
    W = 2400
    celda_c = W // 7
    celda_p = W // 6
    esc_c = celda_c / caras[0].width
    hc = int(caras[0].height * esc_c)
    esc_p = (celda_p - 20) / poses[0].width
    hp = int(poses[0].height * esc_p)
    H = 260 + hc + 90 + 2 * (hp + 80) + 120
    hoja = Image.new("RGBA", (W, H), ABISMO)
    # Degradado radial de la marca
    yy, xx = np.mgrid[0:H, 0:W]
    d = np.sqrt(((xx - W / 2) / (W * 0.7)) ** 2 + ((yy - H * 0.35) / (H * 0.7)) ** 2).clip(0, 1)[..., None]
    fondo = (np.array(NOCHE[:3]) * (1 - d) + np.array(ABISMO[:3]) * d).astype(np.uint8)
    hoja = Image.fromarray(np.dstack([fondo, np.full((H, W), 255, np.uint8)]), "RGBA")
    dib = ImageDraw.Draw(hoja)
    dib.text((80, 70), "NYXAR", font=fuente(110), fill=HUESO)
    dib.text((84, 190), "HOJA DE PERSONAJE · AEZ · @ithnoir", font=fuente(38), fill=MENTA)
    y = 260
    for k, (n, c) in enumerate(zip(ns, caras)):
        cc = c.resize((celda_c, hc), Image.LANCZOS)
        hoja.alpha_composite(cc, (k * celda_c, y))
        t = ETIQUETAS[n.replace("cara-", "")]
        w = dib.textlength(t, font=fuente(40))
        dib.text((k * celda_c + (celda_c - w) / 2, y + hc + 10), t, font=fuente(40), fill=NIEBLA)
    y += hc + 90
    for fila in range(2):
        for k in range(6):
            i = fila * 6 + k
            pc = poses[i].resize((int(poses[i].width * esc_p), hp), Image.LANCZOS)
            hoja.alpha_composite(pc, (k * celda_p + 10, y))
            t = list(POSES.values())[i]
            w = dib.textlength(t, font=fuente(40))
            dib.text((k * celda_p + (celda_p - w) / 2, y + hp + 4), t, font=fuente(40), fill=NIEBLA)
        y += hp + 80
    guarda(hoja.convert("RGB"), f"{DESTINO}/hoja-de-personaje-nyxar.png")
    return caras, poses


# ---------- Stickers ----------
def sticker(im, lado=512, borde=14):
    bb = im.getchannel("A").getbbox()
    im = im.crop(bb)
    esc = (lado - 2 * borde - 16) / max(im.size)
    im = im.resize((max(1, int(im.width * esc)), max(1, int(im.height * esc))), Image.LANCZOS)
    lienzo = Image.new("RGBA", (lado, lado), (0, 0, 0, 0))
    x, y = (lado - im.width) // 2, (lado - im.height) // 2
    a = Image.new("L", (lado, lado), 0)
    a.paste(im.getchannel("A"), (x, y))
    contorno = a.filter(ImageFilter.MaxFilter(borde * 2 + 1)).point(lambda v: 255 if v > 30 else 0)
    sombra = contorno.filter(ImageFilter.GaussianBlur(6)).point(lambda v: int(v * 0.35))
    lienzo.paste((0, 0, 0, 255), (4, 6), sombra)
    lienzo.paste((255, 255, 255, 255), (0, 0), contorno)
    lienzo.alpha_composite(im, (x, y))
    return lienzo


def stickers(caras, poses):
    for n, c in zip(nombres("expresiones"), caras):
        s = sticker(c)
        base = f"{DESTINO}/stickers/{n.replace('cara-', 'cara-')}"
        guarda(s, base + ".png")
        s.save(base + ".webp", "WEBP", quality=80, method=6)
    for n, p in zip(POSES.keys(), poses):
        s = sticker(p)
        base = f"{DESTINO}/stickers/{n}"
        guarda(s, base + ".png")
        s.save(base + ".webp", "WEBP", quality=80, method=6)


# ---------- Pixel art ----------
PALETA = [
    (29, 21, 48), (69, 52, 124), (84, 65, 142), (104, 82, 171), (122, 102, 184), (184, 112, 138),
    (255, 255, 255), (27, 47, 122), (29, 58, 122), (139, 35, 50), (122, 29, 43), (233, 181, 59),
    (42, 13, 28), (224, 96, 126), (94, 231, 196), (143, 179, 255), (255, 181, 71), (241, 245, 255),
]


def a_pixel(im, alto=96, ampliar=6):
    bb = im.getchannel("A").getbbox()
    return a_pixel_caja(im, bb, alto, ampliar)


def a_pixel_caja(im, caja, alto=96, ampliar=6):
    im = im.crop(caja)
    ancho = max(1, round(im.width * alto / im.height))
    peq = im.resize((ancho, alto), Image.BOX)
    arr = np.array(peq).astype(np.int32)
    alfa = arr[..., 3] > 110
    rgb = arr[..., :3]
    pal = np.array(PALETA)
    dist = ((rgb[:, :, None, :] - pal[None, None, :, :]) ** 2).sum(-1)
    idx = dist.argmin(-1)
    out = np.zeros((alto, ancho, 4), np.uint8)
    out[..., :3] = pal[idx]
    out[..., 3] = np.where(alfa, 255, 0)
    # Contorno de 1 px en el color de la línea
    borde = np.zeros_like(alfa)
    for dy, dx in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
        borde |= np.roll(np.roll(alfa, dy, 0), dx, 1)
    borde &= ~alfa
    out[borde] = (29, 21, 48, 255)
    p = Image.fromarray(out, "RGBA")
    return p, p.resize((p.width * ampliar, p.height * ampliar), Image.NEAREST)


def pixel():
    os.makedirs(f"{DESTINO}/pixel", exist_ok=True)
    meta = {"fps": 10, "escala_ampliada": 6, "animaciones": {}}
    # Animaciones en tiras horizontales, con el mismo recorte para que no "salten".
    anims = {}
    for x in LISTA:
        if x["grupo"] == "animaciones":
            anims.setdefault(x["anim"]["tipo"], []).append(x["nombre"])
    todas = [carga(n) for ns in anims.values() for n in ns]
    caja = caja_union(todas, margen=8)
    for tipo, ns in anims.items():
        fr = [a_pixel_caja(carga(n), caja) for n in ns]
        w, h = fr[0][0].size
        tira = Image.new("RGBA", (w * len(fr), h))
        tira6 = Image.new("RGBA", (w * 6 * len(fr), h * 6))
        for k, (p, p6) in enumerate(fr):
            tira.paste(p, (k * w, 0))
            tira6.paste(p6, (k * w * 6, 0))
        guarda(tira, f"{DESTINO}/pixel/anim-{tipo}.png")
        guarda(tira6, f"{DESTINO}/pixel/anim-{tipo}-x6.png")
        # GIF de vista previa
        cuadros = []
        for _, p6 in fr:
            bg = Image.new("RGBA", p6.size, NOCHE)
            bg.alpha_composite(p6)
            cuadros.append(bg.convert("P", palette=Image.ADAPTIVE))
        cuadros[0].save(f"{DESTINO}/pixel/anim-{tipo}.gif", save_all=True, append_images=cuadros[1:], duration=100, loop=0, disposal=2)
        meta["animaciones"][tipo] = {"archivo": f"anim-{tipo}.png", "cuadros": len(fr), "ancho": w, "alto": h}
    for n in nombres("expresiones") + list(POSES.keys()):
        p, p6 = a_pixel(carga(n))
        guarda(p, f"{DESTINO}/pixel/{n}.png")
        guarda(p6, f"{DESTINO}/pixel/{n}-x6.png")
    json.dump(meta, open(f"{DESTINO}/pixel/animaciones.json", "w"), indent=1, ensure_ascii=False)


if __name__ == "__main__":
    pngtuber()
    caras, poses = caras_y_hoja()
    stickers(caras, poses)
    pixel()
    print("Sprites generados en", DESTINO)
