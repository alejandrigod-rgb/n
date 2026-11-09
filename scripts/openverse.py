"""
Busca y descarga audio con licencia libre (CC0 por defecto) desde Openverse.

Uso:
  python3 scripts/openverse.py buscar "whoosh"            # lista resultados CC0
  python3 scripts/openverse.py bajar "lofi loop" musica public/<carpeta> [--licencia cc0,by] [--min 20] [--max 120]
    → descarga el primer resultado como public/<carpeta>/sfx-<nombre>.mp3 y anota la licencia en creditos.txt

Licencias: CC0 = dominio público (uso libre, también comercial, sin crédito).
CC BY = libre pero hay que citar al autor (queda escrito en creditos.txt).
"""
import json
import os
import subprocess
import sys
import urllib.parse
import urllib.request

API = "https://api.openverse.org/v1/audio/"


def buscar(q, licencia="cc0", n=10, dmin=None, dmax=None):
    params = {"q": q, "license": licencia, "page_size": str(n)}
    url = API + "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={"User-Agent": "aez-videos/1.0 (+https://github.com/alejandrigod-rgb/n)"})
    with urllib.request.urlopen(req, timeout=40) as r:
        res = json.load(r)["results"]
    if dmin is not None:
        res = [x for x in res if (x.get("duration") or 0) >= dmin * 1000]
    if dmax is not None:
        res = [x for x in res if (x.get("duration") or 10**9) <= dmax * 1000]
    return res


def args_opt(nombre, defecto=None, tipo=str):
    if nombre in sys.argv:
        return tipo(sys.argv[sys.argv.index(nombre) + 1])
    return defecto


if __name__ == "__main__":
    accion = sys.argv[1]
    lic = args_opt("--licencia", "cc0")
    dmin = args_opt("--min", None, float)
    dmax = args_opt("--max", None, float)
    if accion == "buscar":
        for x in buscar(sys.argv[2], lic, 15, dmin, dmax):
            print(f"{x['license']:4} {(x.get('duration') or 0) / 1000:6.1f}s  {x['title'][:50]:50}  {x['creator'] or '-'}  {x['url']}")
    elif accion == "bajar":
        q, nombre, carpeta = sys.argv[2], sys.argv[3], sys.argv[4]
        res = buscar(q, lic, 20, dmin, dmax)
        if not res:
            sys.exit(f"Sin resultados para «{q}»")
        x = res[0]
        os.makedirs(carpeta, exist_ok=True)
        crudo = os.path.join(carpeta, f".{nombre}.orig")
        req = urllib.request.Request(x["url"], headers={"User-Agent": "aez-videos/1.0"})
        with urllib.request.urlopen(req, timeout=120) as r, open(crudo, "wb") as f:
            f.write(r.read())
        destino = os.path.join(carpeta, f"sfx-{nombre}.mp3")
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", crudo, "-ac", "2", "-ar", "44100", "-c:a", "libmp3lame", "-b:a", "160k", destino], check=True)
        os.remove(crudo)
        with open(os.path.join(carpeta, "creditos.txt"), "a", encoding="utf-8") as f:
            f.write(f"sfx-{nombre}.mp3: «{x['title']}» de {x['creator'] or 'desconocido'} ({x['source']}), licencia {x['license'].upper()} {x.get('license_version') or ''} — {x['foreign_landing_url']}\n")
        print("✓", destino, "·", x["license"], "·", x["title"])
