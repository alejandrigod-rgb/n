import { continueRender, delayRender } from "remotion";
import "@fontsource/baloo-2/600.css";
import "@fontsource/baloo-2/800.css";
import "@fontsource/jetbrains-mono/700.css";

export const C = {
  fondo1: "#0f1d33",
  fondo2: "#1d3557",
  texto: "#ffffff",
  tenue: "#a8b8d8",
  amarillo: "#ffd23f",
  rojo: "#ff4d6d",
  cian: "#4cc9f0",
  verde: "#80ed99",
  naranja: "#ff9f1c",
  rosa: "#ff8fab",
  linea: "#1d1530",
  morado: "#53407f",
  moradoClaro: "#6d58a6",
};

export const TITULO = "'Baloo 2', sans-serif";
export const MONO = "'JetBrains Mono', monospace";
export const FPS = 30;
export const CLAMP = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;

if (typeof document !== "undefined") {
  const h = delayRender("Cargando fuentes");
  Promise.all([
    document.fonts.load(`800 60px 'Baloo 2'`),
    document.fonts.load(`600 60px 'Baloo 2'`),
    document.fonts.load(`700 40px 'JetBrains Mono'`),
  ])
    .then(() => continueRender(h))
    .catch(() => continueRender(h));
}
