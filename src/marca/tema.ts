/** Tokens de la marca AEZ (ver MARCA.md). */
import { continueRender, delayRender } from "remotion";
import "@fontsource/baloo-2/800.css";
import "@fontsource/lexend/300.css";
import "@fontsource/lexend/600.css";
import "@fontsource/jetbrains-mono/700.css";

export const FPS = 60;

export const C = {
  noche: "#071733",
  abismo: "#020814",
  pelaje: "#6b4fb3",
  menta: "#5ee7c4",
  cascabel: "#ffb547",
  panuelo: "#c2334d",
  hueso: "#f1f5ff",
  niebla: "#9aabc9",
  azul: "#8fb3ff",
};

export const F = {
  titulo: "'Baloo 2', sans-serif",
  texto: "'Lexend', sans-serif",
  cifra: "'JetBrains Mono', monospace",
};

export const CLAMP = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;

if (typeof document !== "undefined") {
  const h = delayRender("Fuentes de la marca");
  Promise.all([
    document.fonts.load(`800 60px 'Baloo 2'`),
    document.fonts.load(`300 40px 'Lexend'`),
    document.fonts.load(`600 40px 'Lexend'`),
    document.fonts.load(`700 40px 'JetBrains Mono'`),
  ])
    .then(() => continueRender(h))
    .catch(() => continueRender(h));
}
