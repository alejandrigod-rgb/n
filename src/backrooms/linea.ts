import { crearLinea, Tiempos } from "../marca/linea";
import { FPS } from "../marca/tema";
import tiempos from "./tiempos.json";

export const IDS = ["intro", "negro", "revelacion", "origen", "leyenda", "liminal", "real", "final"] as const;
export type IdEscena = (typeof IDS)[number];
export const TIEMPOS = tiempos as Tiempos;
export const CARPETA = "backrooms";

/** Un solo plano continuo: sin fundidos entre escenas. */
export const LINEA = crearLinea<IdEscena>({
  tiempos: TIEMPOS,
  ids: IDS,
  fps: FPS,
  pre: { intro: 0.15, negro: 0.9, revelacion: 1.1, origen: 0.3, leyenda: 0.2, liminal: 0.2, real: 0.2, final: 0.4 },
  extra: { intro: -0.05, negro: 0.1, final: 3.2 },
  transicion: 0,
});

const i = (id: IdEscena) => IDS.indexOf(id);
const s = (n: number) => Math.round(n * FPS);
/** Fotograma en que se cae el trípode: justo al decir "los…". */
export const CAIDA = LINEA.inicios[i("intro")] + LINEA.preDe("intro") + s(TIEMPOS.voz.intro.duracion) - s(0.1);
export const NEGRO = CAIDA + s(0.45);
/** La cámara vuelve a levantarse, ya en los Backrooms. */
export const LEVANTA = LINEA.inicios[i("revelacion")];
/** Aparece la criatura y se corta el video. */
export const CRIATURA = LINEA.inicios[i("final")] + LINEA.preDe("final") + s(TIEMPOS.voz.final.duracion) + s(0.3);
export const SUSTO = CRIATURA + s(1.4);
export const CORTE = SUSTO + s(0.3);
