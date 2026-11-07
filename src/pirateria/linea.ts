import { FPS } from "./tema";
import tiemposJson from "./tiempos.json";

export type Palabra = { p: string; ini: number; fin: number };
type Voz = { texto: string; duracion: number; palabras: Palabra[]; letras: string; ini: number[]; fin: number[] };
export const TIEMPOS = tiemposJson as { voz: Record<string, Voz>; sfx: Record<string, number> };

/** Silencio antes de que hable el gato en cada escena. */
export const PRE = 10;
export const TRANSICION = 14;

export const IDS = [
  "intro", "que", "nombre", "imprenta", "ley", "cintas",
  "software", "internet", "cierre", "streaming", "riesgos", "final",
] as const;
export type IdEscena = (typeof IDS)[number];

const EXTRA: Partial<Record<IdEscena, number>> = { intro: 0.3, final: 2.5 };

export const DURACIONES = IDS.map((id) => PRE + Math.ceil((TIEMPOS.voz[id].duracion + 0.7 + (EXTRA[id] ?? 0)) * FPS));
export const INICIOS = DURACIONES.map((_, i) => DURACIONES.slice(0, i).reduce((a, d) => a + d - TRANSICION, 0));
export const DURACION_TOTAL = INICIOS[IDS.length - 1] + DURACIONES[IDS.length - 1];

/** Escena "activa" en un fotograma global (la más reciente que ya empezó). */
export const escenaEn = (frame: number) => {
  let i = 0;
  for (let k = 0; k < IDS.length; k++) if (frame >= INICIOS[k]) i = k;
  return { i, id: IDS[i], local: frame - INICIOS[i] };
};

const normalizar = (s: string) =>
  s.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/[^a-z0-9]/g, "");

/** Fotograma local (dentro de la escena) en que se dice `palabra`. */
export const marcas = (id: IdEscena) => (palabra: string, n = 0) => {
  let c = 0;
  for (const w of TIEMPOS.voz[id].palabras) {
    if (normalizar(w.p) === normalizar(palabra)) {
      if (c === n) return PRE + Math.round(w.ini * FPS);
      c++;
    }
  }
  throw new Error(`"${palabra}" no aparece en "${id}"`);
};

/** Cuánto abre la boca una letra (vocales abiertas, labiales cerradas). */
const valorLetra = (c: string) => {
  const l = c.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "");
  if (l === "a") return 1;
  if (l === "e" || l === "o") return 0.75;
  if (l === "i" || l === "u") return 0.45;
  if ("mbpfv".includes(l)) return 0.05;
  if (/[a-z]/.test(l)) return 0.3;
  return 0;
};

const aperturaEn = (v: Voz, t: number) => {
  for (let k = 0; k < v.letras.length; k++) {
    if (t >= v.ini[k] && t < v.fin[k]) return valorLetra(v.letras[k]);
  }
  return 0;
};

/** Apertura de la boca (0-1) en un fotograma global, suavizada. */
export const aperturaBoca = (frame: number) => {
  for (let i = 0; i < IDS.length; i++) {
    const v = TIEMPOS.voz[IDS[i]];
    const t = (frame - INICIOS[i] - PRE) / FPS;
    if (t >= -0.05 && t <= v.duracion + 0.05) {
      const m = [-0.035, 0, 0.035].map((d) => aperturaEn(v, t + d));
      return m[0] * 0.25 + m[1] * 0.5 + m[2] * 0.25;
    }
  }
  return 0;
};
