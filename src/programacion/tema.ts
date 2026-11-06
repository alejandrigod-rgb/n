import { continueRender, delayRender } from "remotion";
import "@fontsource/space-grotesk/500.css";
import "@fontsource/space-grotesk/700.css";
import "@fontsource/jetbrains-mono/500.css";
import "@fontsource/jetbrains-mono/700.css";

export const C = {
  fondo1: "#0b1022",
  fondo2: "#141d3b",
  panel: "#0f1730",
  borde: "#ffffff1f",
  texto: "#eef2ff",
  tenue: "#8b96b8",
  cian: "#38bdf8",
  violeta: "#a78bfa",
  verde: "#4ade80",
  ambar: "#fbbf24",
  rosa: "#f472b6",
  rojo: "#f87171",
  naranja: "#fb923c",
};

export const SANS = "'Space Grotesk', sans-serif";
export const MONO = "'JetBrains Mono', monospace";
export const FPS = 30;
export const CLAMP = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;

if (typeof document !== "undefined") {
  const h = delayRender("Cargando fuentes");
  Promise.all([
    document.fonts.load(`700 60px 'Space Grotesk'`),
    document.fonts.load(`500 60px 'Space Grotesk'`),
    document.fonts.load(`500 40px 'JetBrains Mono'`),
    document.fonts.load(`700 40px 'JetBrains Mono'`),
  ])
    .then(() => continueRender(h))
    .catch(() => continueRender(h));
}
