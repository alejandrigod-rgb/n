import { linearTiming, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { AbsoluteFill, getInputProps, Html5Audio, interpolate, staticFile, useCurrentFrame } from "remotion";
import { Sfx } from "../marca/kit";
import { IcoBalon } from "../marca/iconos";
import { C, CLAMP, FPS } from "../marca/tema";
import { Cuarto } from "../backrooms/mundos";
import { Escenario, Lado, Tramo } from "../personajes/Escenario";
import { Expresion, Nyxar, POSE_BASE, PoseNyxar } from "../personajes/Nyxar";
import { Ahora, Antes, Bloque, Gancho, Plan, Pregunta, Remate } from "./escenas";
import { CARPETA, IdEscena, IDS, LINEA, TRANSICION } from "./linea";

const COMPONENTES = [Gancho, Antes, Ahora, Bloque, Plan, Remate, Pregunta];

const LADOS: Record<IdEscena, Lado> = {
  gancho: "asomadoIzquierda",
  antes: "derecha",
  ahora: "izquierda",
  bloque: "derecha",
  plan: "izquierda",
  remate: "derecha",
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
      return { pose: { ...base, brazoI: 150 + 8 * sen(s, 0.8), brazoD: 150 - 8 * sen(s, 0.8), mirarX: 0.6, mirarY: -0.3, cabeza: -6, salto: saltito(s, m("peor")) }, expresion: s >= m("por") ? "pensativo" : "sorprendido" };
    case "antes":
      return { pose: { ...base, brazoI: 150 + 10 * sen(s, 0.6), brazoD: 150 - 10 * sen(s, 0.6), salto: saltito(s, m("semifinales")) }, expresion: "feliz" };
    case "ahora":
      return { pose: { ...base, brazoD: 128, brazoI: 18, mirarX: 0.5, mirarY: -0.6, salto: saltito(s, m("octavos"), 40) }, expresion: s >= m("octavos") ? "sorprendido" : "guino" };
    case "bloque":
      return { pose: { ...base, cabeza: 4 * sen(s, 1.6), mirarX: 0.5, mirarY: -0.5 }, expresion: s >= m("junto") ? "feliz" : "pensativo" };
    case "plan":
      return { pose: { ...base, brazoI: 30, brazoD: 30, mirarX: 0.5, mirarY: -0.4 }, expresion: s >= m("gol") ? "triste" : "enfadado" };
    case "remate":
      return { pose: { ...base, brazoD: 140, brazoI: 18, salto: saltito(s, m("mundiales"), 50) }, expresion: "feliz" };
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

/* Final: un balón amarillo (de los Backrooms) rueda desde la oscuridad. */
const F_BALON = LINEA.total - Math.round(FPS * 2.0);
const F_NEGRO = LINEA.total - Math.round(FPS * 0.3);

const NyxarEnEscena: React.FC = () => {
  const frame = useCurrentFrame();
  const { id, local } = LINEA.escenaEn(frame);
  const e = estado(id, local);
  if (frame >= F_BALON + 45) {
    e.expresion = "sorprendido";
    e.pose = { ...e.pose, brazoD: 30, mirarX: -0.7, mirarY: 0.7 };
  }
  return (
    <Escenario tramos={TRAMOS} fps={FPS}>
      {(ancho) => <Nyxar ancho={ancho} pose={e.pose} boca={LINEA.aperturaBoca(frame)} frame={frame} fps={FPS} expresion={e.expresion} />}
    </Escenario>
  );
};

const BalonFinal: React.FC = () => {
  const frame = useCurrentFrame();
  if (frame < F_BALON || frame >= F_NEGRO) return null;
  const d = frame - F_BALON;
  const p = interpolate(d, [0, 50], [0, 1], { ...CLAMP, easing: (x) => 1 - Math.pow(1 - x, 2) });
  return (
    <div style={{ position: "absolute", left: interpolate(p, [0, 1], [-160, 470]), top: 1700, transform: `rotate(${p * 720}deg)`, filter: "sepia(1) saturate(3) hue-rotate(-10deg) brightness(0.95)" }}>
      <IcoBalon tamano={120} />
    </div>
  );
};

const volumenMusica = (f: number) => interpolate(f, [0, 30, F_BALON - 20, F_BALON], [0.07, 0.08, 0.08, 0], CLAMP);

export const DURACION_PORTUGAL = LINEA.total;

export const Portugal: React.FC = () => {
  const frame = useCurrentFrame();
  const t = frame / FPS;
  const apagon = frame >= F_BALON ? interpolate(frame, [F_BALON, F_BALON + 30], [0, 0.55], CLAMP) : 0;
  const parpadeo = frame >= F_BALON + 60 && Math.floor((frame - F_BALON) / 4) % 3 === 0 ? 0.35 : 0;
  return (
    <AbsoluteFill style={{ background: C.abismo }}>
      <AbsoluteFill style={{ transform: `scale(${1.04 + 0.01 * Math.sin(t / 3)})` }}>
        <Cuarto s={t} />
      </AbsoluteFill>
      <AbsoluteFill style={{ background: "rgba(2,8,20,0.64)" }} />
      <AbsoluteFill style={{ opacity: interpolate(frame, [F_BALON - 10, F_BALON + 10], [1, 0], CLAMP) }}>
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
      <AbsoluteFill style={{ background: "#000", opacity: apagon }} />
      <NyxarEnEscena />
      <BalonFinal />
      <AbsoluteFill style={{ background: "#000", opacity: parpadeo }} />
      {frame >= F_NEGRO ? <AbsoluteFill style={{ background: "#000" }} /> : null}
      {getInputProps().sinMusica ? null : <Html5Audio loop loopVolumeCurveBehavior="extend" src={staticFile(`${CARPETA}/sfx-musica.mp3`)} volume={volumenMusica} />}
      <Sfx carpeta={CARPETA} id="patada" en={F_BALON} volumen={0.3} />
      <Sfx carpeta={CARPETA} id="latido" en={F_BALON + 45} volumen={0.4} />
      <Sfx carpeta={CARPETA} id="parpadeo" en={F_BALON + 60} volumen={0.3} />
      <Sfx carpeta={CARPETA} id="estatica" en={F_NEGRO - 8} volumen={0.3} dur={0.3} />
    </AbsoluteFill>
  );
};
