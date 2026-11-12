import { crearLinea, Tiempos } from "../marca/linea";
import { FPS } from "../marca/tema";
import tiempos from "./tiempos.json";

export const IDS = ["gancho", "antes", "ahora", "bloque", "plan", "remate", "pregunta"] as const;
export type IdEscena = (typeof IDS)[number];
export const TIEMPOS = tiempos as Tiempos;
export const TRANSICION = Math.round(FPS * 0.5);
export const CARPETA = "portugal";

export const LINEA = crearLinea<IdEscena>({
  tiempos: TIEMPOS,
  ids: IDS,
  fps: FPS,
  pre: { gancho: 0, antes: 0.2, ahora: 0.2, bloque: 0.2, plan: 0.2, remate: 0.3, pregunta: 0.3 },
  extra: { gancho: 0.3, ahora: 0.3, plan: 0.4, remate: 0.6, pregunta: 2.8 },
  transicion: TRANSICION,
});
