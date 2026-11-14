import { crearLinea, Tiempos } from "../marca/linea";
import { FPS } from "../marca/tema";
import tiempos from "./tiempos.json";

export const IDS = ["gancho", "instinto", "hunde", "hierve", "bola", "tapa", "aire", "bicarbonato", "pregunta"] as const;
export type IdEscena = (typeof IDS)[number];
export const TIEMPOS = tiempos as Tiempos;
export const TRANSICION = Math.round(FPS * 0.12);
export const CARPETA = "sarten";

export const LINEA = crearLinea<IdEscena>({
  tiempos: TIEMPOS,
  ids: IDS,
  fps: FPS,
  pre: { gancho: 0, instinto: 0.2, hunde: 0.2, hierve: 0.2, bola: 0.2, tapa: 0.2, aire: 0.2, bicarbonato: 0.2, pregunta: 0.2 },
  extra: { gancho: 0.1, bola: 0.3, pregunta: 2.4 },
  transicion: TRANSICION,
});
