import { crearLinea, Tiempos } from "../marca/linea";
import { FPS } from "../marca/tema";
import tiempos from "./tiempos.json";

export const IDS = ["gancho", "que", "regla", "comparar", "datos", "remate", "pregunta"] as const;
export type IdEscena = (typeof IDS)[number];
export const TIEMPOS = tiempos as Tiempos;
export const TRANSICION = Math.round(FPS * 0.5);
export const CARPETA = "hipergamia";

export const LINEA = crearLinea<IdEscena>({
  tiempos: TIEMPOS,
  ids: IDS,
  fps: FPS,
  pre: { gancho: 0, que: 0.2, regla: 0.2, comparar: 0.2, datos: 0.2, remate: 0.3, pregunta: 0.3 },
  extra: { gancho: 0.3, regla: 0.5, comparar: 0.3, remate: 0.6, pregunta: 3.0 },
  transicion: TRANSICION,
});
