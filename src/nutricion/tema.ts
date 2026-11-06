import { continueRender, delayRender } from "remotion";
import "@fontsource/baloo-2/600.css";
import "@fontsource/baloo-2/800.css";
import "@fontsource/kalam/700.css";

export const C = {
  cielo: "#1fa2ef",
  cielo2: "#8fd9ff",
  verde: "#2ea84a",
  verdeOsc: "#17592a",
  verdeClaro: "#8bd35a",
  amarillo: "#ffd60a",
  crema: "#fbf8ef",
  texto: "#163a22",
  rojo: "#e63946",
  azul: "#3bb4f2",
  morado: "#9b6fd6",
  naranja: "#ff9f1c",
  blanco: "#ffffff",
};

export const TITULO = "'Baloo 2', sans-serif";
export const MANUSCRITA = "'Kalam', cursive";

export const CLAMP = {
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
} as const;

export const FPS = 30;

// Espera a que las fuentes estén listas antes de renderizar fotogramas.
if (typeof document !== "undefined") {
  const h = delayRender("Cargando fuentes");
  Promise.all([
    document.fonts.load(`800 60px 'Baloo 2'`),
    document.fonts.load(`600 60px 'Baloo 2'`),
    document.fonts.load(`700 60px 'Kalam'`),
  ])
    .then(() => continueRender(h))
    .catch(() => continueRender(h));
}
