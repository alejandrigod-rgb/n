// Piezas de cartulina del video de Vini (cortadas UNA vez aquí, con semilla fija). Sin escudos, patrocinadores ni caras reales.
import React from "react";
import { rng, type P } from "./papel/curvas";
import { elipsePts, tf } from "./papel/corte";
import { circuloPts, recorte, rectPts } from "./papel/geo";
import { f, type Tinta } from "./papel/tintas";
import { LILITA, PASOS } from "./papel/decorado";

let sem = 20000;
const S = () => (sem += 41);
/** Corta una pieza (fuera del render) y la devuelve lista para pintar con su cartulina y sombra. */
export const pieza = (pts: P[], t: Tinta, s: string | null = "s2", amp = 1.4, paso = 16) => {
  const d = recorte(pts, S(), amp, paso);
  return (props?: React.SVGProps<SVGPathElement>) => <path d={d} fill={f(t)} filter={s ? `url(#gpp-${s})` : undefined} {...props} />;
};

/** Entra "pegándose": por pasos 1.22 → 0.9 → 1.05 → 1. */
export const pega = (tq: number, t0: number) => {
  const k = Math.round((tq - t0) * PASOS);
  if (k < 0) return 0;
  return [1.22, 0.9, 1.05, 1][Math.min(k, 3)];
};

/** Temblor de recolocado a mano por paso. */
export const mano = (n: number, s: number, a = 1.2, g = 0.5) => {
  const r = rng(s * 97 + n * 13);
  return `translate(${((r() - 0.5) * 2 * a).toFixed(2)} ${((r() - 0.5) * 2 * a).toFixed(2)}) rotate(${((r() - 0.5) * 2 * g).toFixed(2)})`;
};

/** Grupo colocado en c, que se pega en t0 y tiembla a mano. */
export const Pegado: React.FC<{ c: P; tq: number; t0: number; n: number; s: number; giro?: number; children: React.ReactNode }> = ({ c, tq, t0, n, s, giro = 0, children }) => {
  const e = pega(tq, t0);
  if (e <= 0) return null;
  return (
    <g transform={`translate(${c[0]} ${c[1]}) rotate(${giro}) scale(${e}) ${mano(n, s)}`}>
      {children}
    </g>
  );
};

/** Texto de cartulina (Lilita), oscuro o de color. */
export const Rotulo: React.FC<{ texto: string; y?: number; tam?: number; color?: string; x?: number; anchor?: "middle" | "start" | "end" }> = ({ texto, y = 0, tam = 56, color = "#3A2416", x = 0, anchor = "middle" }) => (
  <text x={x} y={y} textAnchor={anchor} fontFamily={LILITA} fontSize={tam} fill={color}>
    {texto}
  </text>
);

/* ---------- tarjetas ---------- */
export const tarjeta = (w: number, h: number, t: Tinta = "crema", s = "s4") => pieza(rectPts(-w / 2, -h / 2, w, h, 14), t, s, 1.6, 18);

/* ---------- trofeo genérico ---------- */
const COPA = pieza(
  [
    [-70, -110], [70, -110], [62, -40], [36, 0], [14, 14], [14, 50], [-14, 50], [-14, 14], [-36, 0], [-62, -40],
  ],
  "oro",
  "s3",
);
const ASA_I = pieza(elipsePts(26, 34, 24, [-78, -70]), "oro", "s2");
const ASA_D = pieza(elipsePts(26, 34, 24, [78, -70]), "oro", "s2");
const HUECO_I = pieza(elipsePts(13, 20, 18, [-80, -70]), "pared", null);
const HUECO_D = pieza(elipsePts(13, 20, 18, [80, -70]), "pared", null);
const PEANA = pieza(rectPts(-46, 50, 92, 40, 6), "madera", "s2");
const BRILLO_COPA = pieza(rectPts(-44, -98, 14, 70, 7), "blanco", null);
export const Trofeo: React.FC = () => (
  <g>
    {ASA_I()}
    {ASA_D()}
    {HUECO_I()}
    {HUECO_D()}
    {COPA()}
    {BRILLO_COPA({ opacity: 0.45 })}
    {PEANA()}
  </g>
);

/* ---------- balón de papel ---------- */
const BALON = pieza(circuloPts([0, 0], 46, 36), "blanco", "s2");
const PENTA = [
  [0, -16], [15, -5], [9, 13], [-9, 13], [-15, -5],
].map(([x, y]) => [x, y] as P);
const PENT_C = pieza(PENTA, "tinta", null, 0.6, 6);
export const Balon: React.FC<{ r?: number }> = ({ r = 1 }) => (
  <g transform={`scale(${r})`}>
    {BALON()}
    {PENT_C()}
  </g>
);

/* ---------- camiseta genérica (sin escudo ni patrocinador) ---------- */
const CAM = (t: Tinta) =>
  pieza(
    [
      [-40, -95], [-95, -65], [-130, -5], [-95, 15], [-75, -20], [-75, 110], [75, 110], [75, -20], [95, 15], [130, -5], [95, -65], [40, -95], [20, -75], [-20, -75],
    ],
    t,
    "s3",
  );
const CAM_BLANCA = CAM("blanco");
const CAM_AMARILLA = CAM("amarillo");
const CUELLO_BL = pieza(elipsePts(26, 12, 20, [0, -88]), "lila", null);
const CUELLO_AM = pieza(elipsePts(26, 12, 20, [0, -88]), "verdeBr", null);
export const Camiseta: React.FC<{ tipo: "blanca" | "amarilla"; nombre?: string; dorsal?: string }> = ({ tipo, nombre, dorsal }) => (
  <g>
    {tipo === "blanca" ? CAM_BLANCA() : CAM_AMARILLA()}
    {tipo === "blanca" ? CUELLO_BL() : CUELLO_AM()}
    {nombre ? <Rotulo texto={nombre} y={-22} tam={30} color={tipo === "blanca" ? "#5B8FCB" : "#2E9B4F"} /> : null}
    {dorsal ? <Rotulo texto={dorsal} y={62} tam={84} color={tipo === "blanca" ? "#5B8FCB" : "#2E9B4F"} /> : null}
  </g>
);

/* ---------- foco (cono de luz de papel de seda) ---------- */
export const FOCO = pieza(
  [
    [-30, -300], [30, -300], [190, 140], [-190, 140],
  ],
  "crema",
  "s0",
  1.2,
  20,
);

/* ---------- tablilla de cambio ---------- */
const TABLILLA = pieza(rectPts(-120, -80, 240, 160, 16), "noche", "s3");
const MANGO = pieza(rectPts(-18, 80, 36, 120, 8), "madera2", "s2");
export const Tablilla: React.FC<{ numero: string }> = ({ numero }) => (
  <g>
    {MANGO()}
    {TABLILLA()}
    <Rotulo texto={numero} y={44} tam={130} color="#E2553F" />
  </g>
);

/* ---------- contrato / hoja ---------- */
const HOJA = pieza(rectPts(-150, -190, 300, 380, 6), "blanco", "s3", 1.2, 14);
const RAYAS = Array.from({ length: 6 }, (_, i) => pieza(rectPts(-110, -110 + i * 42, 200 - (i % 2) * 50, 10, 4), "lamina", null, 0.6, 10));
export const Contrato: React.FC = () => (
  <g>
    {HOJA()}
    <Rotulo texto="CONTRATO" y={-140} tam={44} />
    {RAYAS.map((r, i) => (
      <g key={i}>{r()}</g>
    ))}
  </g>
);
const CINTA = pieza(rectPts(-190, -34, 380, 68, 4), "mostaza", "s2", 1.4, 14);
export const Cinta: React.FC<{ texto: string; color?: string }> = ({ texto, color = "#3A2416" }) => (
  <g>
    {CINTA()}
    <Rotulo texto={texto} y={18} tam={46} color={color} />
  </g>
);

/* ---------- botones de la pregunta ---------- */
export const BOTON_SI = pieza(rectPts(-150, -110, 300, 220, 30), "menta", "s4", 1.6, 18);
export const BOTON_NO = pieza(rectPts(-150, -110, 300, 220, 30), "coral", "s4", 1.6, 18);

/* ---------- tira de subtítulos ---------- */
export const TIRA = pieza(rectPts(-470, -62, 940, 124, 10), "crema", "s4", 1.6, 20);
export const ETIQUETA = pieza(rectPts(-190, -30, 380, 60, 8), "mostaza", "s2", 1.4, 14);

/* ---------- huella ---------- */
const HUELLA_P = pieza(elipsePts(34, 28, 24, [0, 14]), "gris", "s1");
const DEDOS = [
  [-34, -18], [-12, -36], [12, -36], [34, -18],
].map(([x, y], i) => pieza(elipsePts(11, 14, 16, [x, y]), "gris", "s1", 0.8, 8));
export const Huella: React.FC = () => (
  <g>
    {HUELLA_P()}
    {DEDOS.map((d, i) => (
      <g key={i}>{d()}</g>
    ))}
  </g>
);

export { tf };
