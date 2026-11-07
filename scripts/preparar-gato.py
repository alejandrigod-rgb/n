"""Prepara el personaje: quita el fondo, recorta la cabeza y borra la boca original
para poder animarla. Uso: python3 scripts/preparar-gato.py <imagen.png> <carpeta-salida>"""
import sys
import cv2
import numpy as np

src, out = sys.argv[1], sys.argv[2]
img = cv2.imread(src, cv2.IMREAD_UNCHANGED)
if img.shape[2] == 3:
    img = cv2.cvtColor(img, cv2.COLOR_BGR2BGRA)
h, w = img.shape[:2]
bgr = img[:, :, :3].copy()

# 1) Fondo: píxeles claros conectados con el borde (los ojos blancos están cerrados por línea negra).
claro = (bgr.min(axis=2) > 190).astype(np.uint8)
mask = np.zeros((h + 2, w + 2), np.uint8)
relleno = claro.copy() * 255
for x, y in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
    if relleno[y, x] == 255:
        cv2.floodFill(relleno, mask, (x, y), 128)
fondo = (relleno == 128).astype(np.uint8)
alpha = (1 - fondo) * 255
alpha = cv2.GaussianBlur(alpha.astype(np.uint8), (3, 3), 0)

# 2) Borrar la boca ":3" (líneas oscuras) rellenando con el pelaje de alrededor.
zona = np.zeros((h, w), np.uint8)
zona[280:318, 228:336] = 1
oscuro = ((bgr.max(axis=2) < 95) & (zona == 1)).astype(np.uint8) * 255
oscuro = cv2.dilate(oscuro, np.ones((5, 5), np.uint8))
sin_boca = cv2.inpaint(bgr, oscuro, 7, cv2.INPAINT_TELEA)

completo = np.dstack([sin_boca, alpha])
cv2.imwrite(f"{out}/gato-completo.png", np.dstack([bgr, alpha]))

# 3) Cabeza: todo lo que está por encima del pañuelo, sin la punta de la cola.
cabeza = completo.copy()
cabeza[332:, :, 3] = 0
cabeza[318:, 382:, 3] = 0
# Desvanecer suavemente el borde inferior del cuello (lo tapa el pañuelo).
for y in range(318, 332):
    cabeza[y, :, 3] = (cabeza[y, :, 3] * (332 - y) / 14).astype(np.uint8)
x0, y0, x1, y1 = 100, 10, 470, 332
cv2.imwrite(f"{out}/cabeza.png", cabeza[y0:y1, x0:x1])
print("cabeza recortada en", (x0, y0, x1, y1))
