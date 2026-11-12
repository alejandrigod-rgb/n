import { linearTiming, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { AbsoluteFill, interpolate, random, useCurrentFrame } from "remotion";
import { Sfx } from "../marca/kit";
import { C, CLAMP, FPS } from "../marca/tema";
import { Cuarto } from "../backrooms/mundos";
import { Escenario, Lado, Tramo } from "../personajes/Escenario";
import { Expresion, Nyxar, POSE_BASE, PoseNyxar } from "../personajes/Nyxar";
import { Comparar, Datos, Gancho, Pregunta, Que, Regla, Remate } from "./escenas";
import { CARPETA, IdEscena, IDS, LINEA, TRANSICION } from "./linea";

/** Tema triste: Nyxar gris, cuarto frío y lluvia. La canción se mezcla después con scripts/mezclar-cancion.sh. */
const COMPONENTES = [Gancho, Que, Regla, Comparar, Datos, Remate, Pregunta];

const LADOS: Record<IdEscena, Lado> = {
  gancho: "asomadoIzquierda",
  que: "derecha",
  regla: "derecha",
  comparar: "derecha",
  datos: "izquierda",
  remate: "derecha",
  pregunta: "derecha",
};

const sen = (s: number, periodo: number) => Math.sin((s * Math.PI * 2) / periodo);
const saltito = (s: number, desde: number, alto = 50) => {
  const d = s - desde;
  return d < 0 || d > 0.35 ? 0 : Math.sin((d / 0.35) * Math.PI) * alto;
};

type Estado = { pose: PoseNyxar; expresion: Expresion };

const estado = (id: IdEscena, local: number): Estado => {
  const s = local / FPS;
  const m = (w: string) => LINEA.marcas(id)(w) / FPS;
  const base = { ...POSE_BASE };
  switch (id) {
    case "gancho":
      return { pose: { ...base, brazoI: 30, brazoD: 30, mirarX: 0.6, mirarY: -0.3, cabeza: -6 }, expresion: s >= m("deprime") ? "triste" : "sorprendido" };
    case "que":
      return { pose: { ...base, brazoD: 128 + 4 * sen(s, 1.6), brazoI: 18, mirarX: 0.5, mirarY: -0.6 }, expresion: "pensativo" };
    case "regla":
      return { pose: { ...base, cabeza: -5, mirarY: 0.5 }, expresion: "triste" };
    case "comparar":
      return { pose: { ...base, cabeza: -4 + 2 * sen(s, 3), mirarX: 0.6, mirarY: -0.2 }, expresion: s >= m("suficiente") ? "triste" : "normal" };
    case "datos":
      return { pose: { ...base, brazoD: 140, brazoI: 18, salto: saltito(s, m("ella")) }, expresion: s >= m("datos") ? "sorprendido" : "pensativo" };
    case "remate":
      return { pose: { ...base, cabeza: 3 * sen(s, 2.4) }, expresion: s >= m("casa") ? "feliz" : "normal" };
    case "pregunta":
      return { pose: { ...base, brazoD: 140 + 14 * sen(s, 0.9), brazoI: 18, cabeza: 5 * sen(s, 2.4) }, expresion: "guino" };
  }
};

const TRAMOS: Tramo[] = IDS.map((id, i) => ({
  inicio: LINEA.inicios[i],
  fin: LINEA.inicios[i] + LINEA.duraciones[i] - TRANSICION,
  lado: LADOS[id],
  sinEntrada: i === 0,
}));

/* Final: en el reflejo de la ventana aparece el Nyxar "Still Life", y corte. */
const F_REFLEJO = LINEA.total - Math.round(FPS * 1.8);
const F_NEGRO = LINEA.total - Math.round(FPS * 0.3);

const NyxarEnEscena: React.FC = () => {
  const frame = useCurrentFrame();
  const { id, local } = LINEA.escenaEn(frame);
  const e = estado(id, local);
  return (
    <Escenario tramos={TRAMOS} fps={FPS}>
      {(ancho) => <Nyxar ancho={ancho} pose={e.pose} boca={LINEA.aperturaBoca(frame)} frame={frame} fps={FPS} expresion={e.expresion} paleta="gris" />}
    </Escenario>
  );
};

/** Lluvia sobre la ventana y por la pantalla, muy suave. */
const Lluvia: React.FC = () => {
  const frame = useCurrentFrame();
  const t = frame / FPS;
  return (
    <svg width={1080} height={1920} style={{ position: "absolute", inset: 0, opacity: 0.35, pointerEvents: "none" }}>
      {new Array(70).fill(0).map((_, k) => {
        const x = random(`lx${k}`) * 1180 - 50;
        const v = 900 + random(`lv${k}`) * 700;
        const y = ((random(`ly${k}`) * 2200 + t * v) % 2200) - 200;
        return <line key={k} x1={x} y1={y} x2={x - 14} y2={y + 60} stroke="#bcd4ff" strokeWidth={2} strokeLinecap="round" opacity={0.4 + random(`lo${k}`) * 0.5} />;
      })}
    </svg>
  );
};

const Reflejo: React.FC = () => {
  const frame = useCurrentFrame();
  if (frame < F_REFLEJO || frame >= F_NEGRO) return null;
  const d = frame - F_REFLEJO;
  const visible = d < 16 ? (Math.floor(d / 4) % 2 ? 0 : 1) : 1;
  return (
    <div style={{ position: "absolute", left: 360, top: 720, width: 130, opacity: visible * 0.6, filter: "sepia(1) saturate(2.4) hue-rotate(-14deg) brightness(0.75) contrast(1.35) blur(0.6px)" }}>
      <Nyxar ancho={130} pose={{ ...POSE_BASE, brazoI: 8, brazoD: 8 }} boca={0} frame={0} fps={FPS} id="reflejo" expresion="normal" parpadeo={0} />
    </div>
  );
};

export const DURACION_HIPERGAMIA = LINEA.total;

export const Hipergamia: React.FC = () => {
  const frame = useCurrentFrame();
  const t = frame / FPS;
  const parpadeoFinal = frame >= F_REFLEJO && frame < F_NEGRO ? (Math.floor((frame - F_REFLEJO) / 5) % 3 === 0 ? 0.5 : 0) : 0;
  return (
    <AbsoluteFill style={{ background: C.abismo }}>
      <AbsoluteFill style={{ transform: `scale(${1.04 + 0.01 * Math.sin(t / 3)})`, filter: "saturate(0.45) hue-rotate(15deg) brightness(0.85)" }}>
        <Cuarto s={t} />
      </AbsoluteFill>
      <AbsoluteFill style={{ background: "rgba(6,12,30,0.62)" }} />
      <Reflejo />
      <Lluvia />
      <AbsoluteFill style={{ opacity: interpolate(frame, [F_REFLEJO - 10, F_REFLEJO + 6], [1, 0], CLAMP) }}>
      <TransitionSeries>
        {IDS.flatMap((id, i) => {
          const Comp = COMPONENTES[i];
          const items = [
            <TransitionSeries.Sequence key={id} durationInFrames={LINEA.duraciones[i]}>
              <Comp />
            </TransitionSeries.Sequence>,
          ];
          if (i < IDS.length - 1) items.push(<TransitionSeries.Transition key={`${id}-t`} presentation={fade()} timing={linearTiming({ durationInFrames: TRANSICION })} />);
          return items;
        })}
      </TransitionSeries>
      </AbsoluteFill>
      <NyxarEnEscena />
      <AbsoluteFill style={{ background: "radial-gradient(circle at 50% 50%, transparent 55%, #02050ecc 100%)", pointerEvents: "none" }} />
      <AbsoluteFill style={{ background: "#000", opacity: parpadeoFinal }} />
      {frame >= F_NEGRO ? <AbsoluteFill style={{ background: "#000" }} /> : null}
      <Sfx carpeta={CARPETA} id="parpadeo" en={F_REFLEJO} volumen={0.3} />
      <Sfx carpeta={CARPETA} id="latido" en={F_REFLEJO + 20} volumen={0.35} />
      <Sfx carpeta={CARPETA} id="estatica" en={F_NEGRO - 8} volumen={0.3} dur={0.3} />
    </AbsoluteFill>
  );
};
