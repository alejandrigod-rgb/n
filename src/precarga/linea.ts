import { crearLinea, Tiempos } from "../marca/linea";
import { FPS } from "../marca/tema";
import tiempos from "./tiempos.json";

export const IDS = ["gancho", "fechas", "servidores", "candado", "llave", "remate", "pregunta", "final"] as const;
export type IdEscena = (typeof IDS)[number];
export const TIEMPOS = tiempos as Tiempos;
export const TRANSICION = Math.round(FPS * 0.5);
export const CARPETA = "precarga";

export const LINEA = crearLinea<IdEscena>({
  tiempos: TIEMPOS,
  ids: IDS,
  fps: FPS,
  pre: { gancho: 0, fechas: 0.2, servidores: 0.2, candado: 0.2, llave: 0.2, remate: 0.2, pregunta: 0.2, final: 0.4 },
  extra: { gancho: 0.1, pregunta: 1.4, final: 2.6 },
  transicion: TRANSICION,
});
