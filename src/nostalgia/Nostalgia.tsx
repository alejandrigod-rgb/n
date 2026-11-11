import { linearTiming, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { AbsoluteFill, Html5Audio, interpolate, random, spring, staticFile, useCurrentFrame } from "remotion";
import { Sfx } from "../marca/kit";
import { C, CLAMP, FPS } from "../marca/tema";
import { Backrooms, Cuarto } from "../backrooms/mundos";
import { Escenario, Lado, Tramo } from "../personajes/Escenario";
import { Expresion, Nyxar, POSE_BASE, PoseNyxar } from "../personajes/Nyxar";
import { Cerebro, Filtro, Gancho, Giro, Origen, Polaroid, Pregunta, Tristeza } from "./escenas";
import { CARPETA, IdEscena, IDS, LINEA, TRANSICION } from "./linea";

const COMPONENTES = [Gancho, Origen, Cerebro, Filtro, Tristeza, Giro, Pregunta];

const LADOS: Record<IdEscena, Lado> = {
  gancho: "asomadoIzquierda",
  origen: "derecha",
  cerebro: "centro",
  filtro: "centro",
  tristeza: "derecha",
  giro: "izquierda",
  pregunta: "derecha",
};

const sen = (s: number, periodo: number) => Math.sin((s * Math.PI * 2) / periodo);
const saltito = (s: number, desde: number, alto = 60) => {
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
      return { pose: { ...base, brazoI: 150 + 8 * sen(s, 0.8), brazoD: 150 - 8 * sen(s, 0.8), mirarX: 0.6, mirarY: -0.3, cabeza: -6, salto: saltito(s, m("pasado")) }, expresion: s >= m("por") ? "pensativo" : "sorprendido" };
    case "origen":
      return { pose: { ...base, brazoD: 128 + 5 * sen(s, 1.4), brazoI: 18, mirarX: 0.5, mirarY: -0.6 }, expresion: s >= m("enfermedad") ? "sorprendido" : "normal" };
    case "cerebro":
      return { pose: { ...base, mirarY: -0.8, salto: saltito(s, m("recompensa"), 50) }, expresion: s >= m("recompensa") ? "feliz" : "pensativo" };
    case "filtro":
      return { pose: { ...base, cabeza: 4 * sen(s, 1.6), mirarY: -0.7 }, expresion: s >= m("mejor") ? "guino" : "pensativo" };
    case "tristeza":
      return { pose: { ...base, cabeza: -4, mirarX: 0.4, mirarY: -0.3 }, expresion: "triste" };
    case "giro":
      return { pose: { ...base, brazoI: 150 + 10 * sen(s, 0.6), brazoD: 150 - 10 * sen(s, 0.6), salto: saltito(s, m("refugio"), 50) }, expresion: "feliz" };
    case "pregunta":
      return { pose: { ...base, brazoD: 150 + 22 * sen(s, 0.65), brazoI: 18, cabeza: 6 * sen(s, 2.4) }, expresion: "guino" };
  }
};

const TRAMOS: Tramo[] = IDS.map((id, i) => ({
  inicio: LINEA.inicios[i],
  fin: LINEA.inicios[i] + LINEA.duraciones[i] - TRANSICION,
  lado: LADOS[id],
  sinEntrada: i === 0,
}));

/* Final: cae una foto vieja... de los Backrooms. */
const F_FOTO = LINEA.total - Math.round(FPS * 2.2);
const F_NEGRO = LINEA.total - Math.round(FPS * 0.3);

const NyxarEnEscena: React.FC = () => {
  const frame = useCurrentFrame();
  const { id, local } = LINEA.escenaEn(frame);
  const e = estado(id, local);
  if (frame >= F_FOTO + 40) {
    e.expresion = "sorprendido";
    e.pose = { ...e.pose, brazoD: 18, mirarX: -0.6, mirarY: 0.6, cabeza: -8 };
  }
  return (
    <Escenario tramos={TRAMOS} fps={FPS}>
      {(ancho) => <Nyxar ancho={ancho} pose={e.pose} boca={LINEA.aperturaBoca(frame)} frame={frame} fps={FPS} expresion={e.expresion} />}
    </Escenario>
  );
};

const FotoFinal: React.FC = () => {
  const frame = useCurrentFrame();
  if (frame < F_FOTO) return null;
  const d = frame - F_FOTO;
  const cae = spring({ frame: d, fps: FPS, config: { damping: 16, mass: 0.9 } });
  const temblor = d > 70 ? (random(`t${frame}`) - 0.5) * 10 : 0;
  return (
    <AbsoluteFill>
      <AbsoluteFill style={{ background: "#000", opacity: interpolate(d, [0, 20], [0, 0.55], CLAMP) }} />
      <div style={{ position: "absolute", left: 300 + temblor, top: interpolate(cae, [0, 1], [-700, 640]) }}>
        <Polaroid ancho={480} giro={interpolate(cae, [0, 1], [-30, 8])} fecha="?? ?? ????" filtro="sepia(0.2) contrast(1.1)">
          <div style={{ position: "absolute", left: 0, top: 0, width: 1080, height: 1920, transform: "scale(0.4)", transformOrigin: "0 0", marginTop: -140 }}>
            <Backrooms s={frame / FPS} parpadeo={d > 70 ? (Math.floor(d / 3) % 2 ? 0.6 : 0) : 0} />
          </div>
          <div style={{ position: "absolute", left: 175, top: 170, filter: "sepia(1) saturate(2.4) hue-rotate(-14deg) brightness(0.7) contrast(1.35)" }}>
            <Nyxar ancho={80} pose={{ ...POSE_BASE, brazoI: 8, brazoD: 8 }} boca={0} frame={0} fps={FPS} id="foto-still" expresion="normal" parpadeo={0} />
          </div>
        </Polaroid>
      </div>
    </AbsoluteFill>
  );
};

/** Grano de película y fugas de luz cálidas (aspecto nostálgico). */
const Pelicula: React.FC = () => {
  const frame = useCurrentFrame();
  const t = frame / FPS;
  return (
    <AbsoluteFill style={{ pointerEvents: "none" }}>
      <AbsoluteFill style={{ background: `radial-gradient(circle at ${20 + 10 * Math.sin(t / 2)}% 15%, #ff9a3c33 0%, transparent 45%)` }} />
      <AbsoluteFill style={{ background: "radial-gradient(circle at 50% 50%, transparent 55%, #120a0099 100%)" }} />
      <svg width={1080} height={1920} style={{ position: "absolute", inset: 0, opacity: 0.08 }}>
        <filter id="grano">
          <feTurbulence type="fractalNoise" baseFrequency="0.85" numOctaves={2} seed={frame % 12} />
          <feColorMatrix type="saturate" values="0" />
        </filter>
        <rect width={1080} height={1920} filter="url(#grano)" />
      </svg>
    </AbsoluteFill>
  );
};

const volumenMusica = (f: number) => interpolate(f, [0, 30, F_FOTO + 40, F_FOTO + 70], [0.08, 0.1, 0.1, 0], CLAMP);

export const DURACION_NOSTALGIA = LINEA.total;

export const Nostalgia: React.FC = () => {
  const frame = useCurrentFrame();
  const t = frame / FPS;
  return (
    <AbsoluteFill style={{ background: C.abismo }}>
      <AbsoluteFill style={{ transform: `scale(${1.04 + 0.01 * Math.sin(t / 3)})`, filter: "sepia(0.35) saturate(1.1)" }}>
        <Cuarto s={t} />
      </AbsoluteFill>
      <AbsoluteFill style={{ background: "rgba(10,6,24,0.62)" }} />
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
      <NyxarEnEscena />
      <FotoFinal />
      <Pelicula />
      {frame >= F_NEGRO ? <AbsoluteFill style={{ background: "#000" }} /> : null}
      <Html5Audio loop loopVolumeCurveBehavior="extend" src={staticFile(`${CARPETA}/sfx-musica.mp3`)} volume={volumenMusica} />
      <Sfx carpeta={CARPETA} id="whoosh" en={F_FOTO} volumen={0.3} />
      <Sfx carpeta={CARPETA} id="golpe" en={F_FOTO + 22} volumen={0.3} />
      <Sfx carpeta={CARPETA} id="latido" en={F_FOTO + 50} volumen={0.4} />
      <Sfx carpeta={CARPETA} id="glitch" en={F_FOTO + 70} volumen={0.3} />
      <Sfx carpeta={CARPETA} id="estatica" en={F_NEGRO - 8} volumen={0.3} dur={0.3} />
    </AbsoluteFill>
  );
};
