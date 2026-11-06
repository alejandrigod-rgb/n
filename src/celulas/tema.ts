export const COLORES = {
  fondo1: "#071733",
  fondo2: "#020814",
  membrana: "#5ee7c4",
  citoplasma: "#0c2f3a",
  nucleo: "#a78bfa",
  mitocondria: "#fb923c",
  ribosoma: "#facc15",
  adn1: "#60a5fa",
  adn2: "#f472b6",
  texto: "#f1f5f9",
  tenue: "#94a3b8",
  bien: "#4ade80",
  mal: "#f87171",
};

export const FUENTE =
  "'Inter', 'Segoe UI', 'Helvetica Neue', Arial, sans-serif";

export const CLAMP = {
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
} as const;

/** Contorno orgánico que "respira" con el tiempo. */
export const blobPath = (
  r: number,
  t: number,
  amp = 6,
  lobulos = 5,
  cx = 0,
  cy = 0,
  puntos = 72,
) => {
  let d = "";
  for (let i = 0; i <= puntos; i++) {
    const a = (i / puntos) * Math.PI * 2;
    const rr =
      r + amp * Math.sin(lobulos * a + t) + amp * 0.5 * Math.sin(3 * a - t * 1.3);
    const x = cx + rr * Math.cos(a);
    const y = cy + rr * Math.sin(a);
    d += `${i === 0 ? "M" : "L"}${x.toFixed(1)} ${y.toFixed(1)} `;
  }
  return d + "Z";
};
