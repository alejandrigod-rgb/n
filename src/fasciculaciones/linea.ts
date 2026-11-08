import { crearLinea, Tiempos } from "../marca/linea";
import { FPS } from "../marca/tema";
import tiempos from "./tiempos.json";

export const IDS = ["gancho", "que", "causas", "sueno", "teoria", "remate", "pregunta"] as const;
export type IdEscena = (typeof IDS)[number];
export const TIEMPOS = tiempos as Tiempos;
export const TRANSICION = Math.round(FPS * 0.5);
export const CARPETA = "fasciculaciones";

export const LINEA = crearLinea<IdEscena>({
  tiempos: TIEMPOS,
  ids: IDS,
  fps: FPS,
  pre: { gancho: 0, que: 0.2, causas: 0.2, sueno: 0.2, teoria: 0.2, remate: 0.2, pregunta: 0.2 },
  extra: { gancho: 0.1, pregunta: 2.6 },
  transicion: TRANSICION,
});
