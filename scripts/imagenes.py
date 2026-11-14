"""
Imágenes reales con licencia libre para los videos, vía Openverse (api.openverse.org, sin clave).
Las fotos vienen de Flickr, Wikimedia y otros, pero se bajan a través del servidor de Openverse
(`/thumb/?full_size=true`, ~1024 px), así que no hace falta abrir esos hosts en el entorno.

  python3 scripts/imagenes.py buscar "gato bajo la lluvia" [--n 12] [--libre] [--vertical]
      → lista de resultados y una hoja de contacto en out/imagenes/<consulta>.jpg para elegir
  python3 scripts/imagenes.py bajar <id> [<id> ...] --carpeta public/<video>
      → guarda img-<id8>.jpg y apunta el crédito en public/<video>/creditos-imagenes.txt

--libre: solo CC0 y dominio público (no hay que citar a nadie). Sin --libre: cualquier licencia que permita
uso comercial y modificación (CC BY y CC BY-SA piden citar al autor: copiar creditos-imagenes.txt a la descripción).
Buscar en inglés da muchos más resultados. Nunca usar fotos de personas reales famosas ni logos.
El acceso anónimo de Openverse tiene un límite diario bajo: buscar con cabeza.
"""
import argparse
import io
import json
import os
import re
import sys
import urllib.parse
import urllib.request

from PIL import Image, ImageDraw

API = "https://api.openverse.org/v1/images/"
UA = {"User-Agent": "videos-remotion/1.0"}


def pedir(url: str) -> bytes:
    with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60) as r:
        return r.read()


def buscar(a):
    p = {"q": a.consulta, "page_size": str(a.n), "mature": "false"}
    if a.libre:
        p["license"] = "cc0,pdm"
    else:
        p["license_type"] = "commercial,modification"
    if a.vertical:
        p["aspect_ratio"] = "tall"
    d = json.loads(pedir(API + "?" + urllib.parse.urlencode(p)))
    res = d.get("results", [])
    if not res:
        print("Sin resultados. Prueba en inglés o sin --libre.")
        return
    print(f"{d.get('result_count')} resultados; primeros {len(res)}:")
    miniaturas = []
    for k, r in enumerate(res):
        print(f"[{k + 1}] {r['id']}  {r['license'].upper():6} {r.get('width')}x{r.get('height')}  {r.get('title', '')[:50]!r}  de {r.get('creator') or '?'} ({r['source']})")
        try:
            miniaturas.append(Image.open(io.BytesIO(pedir(API + r["id"] + "/thumb/"))).convert("RGB"))
        except Exception as e:  # una miniatura rota no para la búsqueda
            print("   (sin miniatura:", e, ")")
            miniaturas.append(Image.new("RGB", (300, 300), "#444"))
    # hoja de contacto numerada
    col, lado = 4, 300
    filas = (len(miniaturas) + col - 1) // col
    hoja = Image.new("RGB", (col * lado, filas * lado), "#111")
    dib = ImageDraw.Draw(hoja)
    for k, im in enumerate(miniaturas):
        im.thumbnail((lado - 8, lado - 8))
        x, y = (k % col) * lado, (k // col) * lado
        hoja.paste(im, (x + 4, y + 4))
        dib.rectangle([x + 4, y + 4, x + 54, y + 44], fill="#ffd400")
        dib.text((x + 12, y + 12), str(k + 1), fill="#000")
    os.makedirs("out/imagenes", exist_ok=True)
    ruta = f"out/imagenes/{re.sub(r'[^a-z0-9]+', '-', a.consulta.lower()).strip('-')}.jpg"
    hoja.save(ruta, quality=85)
    print("Hoja de contacto:", ruta)


def bajar(a):
    os.makedirs(a.carpeta, exist_ok=True)
    creditos = os.path.join(a.carpeta, "creditos-imagenes.txt")
    for i in a.ids:
        r = json.loads(pedir(API + i + "/"))
        datos = pedir(API + i + "/thumb/?full_size=true&compressed=false")
        im = Image.open(io.BytesIO(datos)).convert("RGB")
        nombre = os.path.join(a.carpeta, f"img-{i[:8]}.jpg")
        im.save(nombre, quality=92)
        lic = r["license"].upper() + (" " + r["license_version"] if r.get("license_version") else "")
        linea = f"{os.path.basename(nombre)}: \"{r.get('title', '')}\" de {r.get('creator') or 'autor desconocido'}, {lic} ({r.get('foreign_landing_url')})"
        with open(creditos, "a", encoding="utf-8") as f:
            f.write(linea + "\n")
        print("✓", nombre, im.size, "·", lic)
    print("Créditos en", creditos, "(con CC BY / BY-SA, ponerlos en la descripción del video)")


ap = argparse.ArgumentParser()
sub = ap.add_subparsers(dest="cmd", required=True)
b = sub.add_parser("buscar")
b.add_argument("consulta")
b.add_argument("--n", type=int, default=12)
b.add_argument("--libre", action="store_true")
b.add_argument("--vertical", action="store_true")
d = sub.add_parser("bajar")
d.add_argument("ids", nargs="+")
d.add_argument("--carpeta", required=True)
a = ap.parse_args()
buscar(a) if a.cmd == "buscar" else bajar(a)
