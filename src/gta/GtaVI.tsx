import { linearTiming, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { AbsoluteFill, Html5Audio, interpolate, spring, staticFile, useCurrentFrame } from "remotion";
import { Fondo } from "../marca/kit";
import { CLAMP, FPS } from "../marca/tema";
import { Escenario, Lado, Tramo } from "../personajes/Escenario";
import { Nyxar, POSE_BASE, PoseNyxar } from "../personajes/Nyxar";
import { TipoObjeto } from "../personajes/objetos";
import { Gancho, Giro, Mapa, Pregunta, Remate, Sonido, Texturas } from "./escenas";
import { CARPETA, IdEscena, IDS, LINEA, TRANSICION } from "./linea";

const COMPONENTES = [Gancho, Texturas, Sonido, Mapa, Giro, Remate, Pregunta];

/** Dónde aparece Nyxar en cada escena (nunca dos veces seguidas en el mismo sitio). */
const LADOS: Record<IdEscena, Lado> = {
  gancho: "asomadoIzquierda",
  texturas: "derecha",
  sonido: "izquierda",
  mapa: "centro",
  giro: "derecha",
  remate: "izquierda",
  pregunta: "centro",
};

/** Objeto del tema (solo en algunas escenas) y palabra en la que aparece. */
const OBJETOS: Partial<Record<IdEscena, { objeto: TipoObjeto; palabra: string }>> = {
  texturas: { objeto: "Lupa", palabra: "pared" },
  mapa: { objeto: "Mando", palabra: "ciudad" },
};

const sen = (s: number, periodo: number) => Math.sin((s * Math.PI * 2) / periodo);
const saltito = (s: number, desde: number) => {
  const d = s - desde;
  return d < 0 || d > 0.35 ? 0 : Math.sin((d / 0.35) * Math.PI) * 60;
};

/** Pose de Nyxar en cada escena; `s` y las marcas en segundos locales. */
const pose = (id: IdEscena, local: number): PoseNyxar => {
  const s = local / FPS;
  const m = (w: string, n = 0) => LINEA.marcas(id)(w, n) / FPS;
  const base = { ...POSE_BASE };
  switch (id) {
    case "gancho":
      return { ...base, brazoI: 150 + 8 * sen(s, 0.8), brazoD: 150 - 8 * sen(s, 0.8), mirarX: 0.5, mirarY: -0.7, salto: saltito(s, m("doscientos")) + saltito(s, m("tanto")), cabeza: -6 };
    case "texturas":
      return { ...base, mirarX: 0.5, cabeza: 4 * sen(s, 3) };
    case "sonido":
      return { ...base, cascos: 1, cabeza: 9 * sen(s, 0.5), salto: 10 * Math.abs(sen(s, 1)), brazoI: 25 + 15 * sen(s, 0.5), brazoD: 25 - 15 * sen(s, 0.5) };
    case "mapa":
      return { ...base, cabeza: 3 * sen(s, 1.2), salto: saltito(s, m("enorme")) };
    case "giro":
      return { ...base, brazoD: 128 + 5 * sen(s, 1.4), brazoI: 18, mirarX: 0.6, mirarY: -0.6, cabeza: -6, salto: saltito(s, m("rapido")) };
    case "remate":
      return { ...base, brazoI: 150 + 10 * sen(s, 0.6), brazoD: 150 - 10 * sen(s, 0.6), salto: 16 * Math.abs(sen(s, 0.8)), cabeza: 5 * sen(s, 1) };
    case "pregunta":
      return { ...base, brazoD: 150 + 22 * sen(s, 0.65), brazoI: 18, cabeza: 6 * sen(s, 2.4), mirarY: -0.2 };
  }
};

const TRAMOS: Tramo[] = IDS.map((id, i) => ({
  inicio: LINEA.inicios[i],
  fin: LINEA.inicios[i] + LINEA.duraciones[i] - TRANSICION,
  lado: LADOS[id],
}));

const NyxarEnEscena: React.FC = () => {
  const frame = useCurrentFrame();
  const { id, local } = LINEA.escenaEn(frame);
  const p = pose(id, local);
  const obj = OBJETOS[id];
  if (obj) {
    const desde = LINEA.marcas(id)(obj.palabra);
    p.objeto = spring({ frame: local - desde, fps: FPS, config: { damping: 13 } });
  }
  return (
    <Escenario tramos={TRAMOS} fps={FPS}>
      {(ancho) => <Nyxar ancho={ancho} pose={p} boca={LINEA.aperturaBoca(frame)} frame={frame} fps={FPS} objeto={obj?.objeto} />}
    </Escenario>
  );
};

const volumenMusica = (f: number) => interpolate(f, [0, 30, LINEA.total - 90, LINEA.total], [0.05, 0.06, 0.06, 0], CLAMP);

export const DURACION_GTA = LINEA.total;

export const GtaVI: React.FC = () => (
  <AbsoluteFill>
    <Fondo />
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
    <Html5Audio loop loopVolumeCurveBehavior="extend" src={staticFile(`${CARPETA}/sfx-musica.mp3`)} volume={volumenMusica} />
  </AbsoluteFill>
);
