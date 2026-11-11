import { crearLinea, Tiempos } from "../marca/linea";
import { FPS } from "../marca/tema";
import tiempos from "./tiempos.json";

export const IDS = ["gancho", "origen", "cerebro", "filtro", "tristeza", "giro", "pregunta"] as const;
export type IdEscena = (typeof IDS)[number];
export const TIEMPOS = tiempos as Tiempos;
export const TRANSICION = Math.round(FPS * 0.5);
export const CARPETA = "nostalgia";

export const LINEA = crearLinea<IdEscena>({
  tiempos: TIEMPOS,
  ids: IDS,
  fps: FPS,
  pre: { gancho: 0, origen: 0.2, cerebro: 0.2, filtro: 0.2, tristeza: 0.2, giro: 0.2, pregunta: 0.2 },
  extra: { gancho: 0.2, tristeza: 0.3, pregunta: 3.2 },
  transicion: TRANSICION,
});
