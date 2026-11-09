import { crearLinea, Tiempos } from "../marca/linea";
import { FPS } from "../marca/tema";
import tiempos from "./tiempos.json";

export const IDS = ["gancho", "contexto", "elliot", "trama", "real", "mente", "premios", "pregunta"] as const;
export type IdEscena = (typeof IDS)[number];
export const TIEMPOS = tiempos as Tiempos;
export const TRANSICION = Math.round(FPS * 0.5);
export const CARPETA = "mrrobot";

export const LINEA = crearLinea<IdEscena>({
  tiempos: TIEMPOS,
  ids: IDS,
  fps: FPS,
  pre: { gancho: 0, contexto: 0.2, elliot: 0.2, trama: 0.2, real: 0.2, mente: 0.2, premios: 0.2, pregunta: 0.2 },
  extra: { gancho: 0.1, premios: 0.8, pregunta: 2.8 },
  transicion: TRANSICION,
});
