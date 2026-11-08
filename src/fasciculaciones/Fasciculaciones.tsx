import { linearTiming, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { AbsoluteFill, Html5Audio, interpolate, spring, staticFile, useCurrentFrame } from "remotion";
import { Fondo } from "../marca/kit";
import { CLAMP, FPS } from "../marca/tema";
import { Escenario, Lado, Tramo } from "../personajes/Escenario";
import { Expresion, Nyxar, POSE_BASE, PoseNyxar } from "../personajes/Nyxar";
import { TipoObjeto } from "../personajes/objetos";
import { Causas, Gancho, Pregunta, Que, Remate, Sueno, Teoria } from "./escenas";
import { CARPETA, IdEscena, IDS, LINEA, TRANSICION } from "./linea";

const COMPONENTES = [Gancho, Que, Causas, Sueno, Teoria, Remate, Pregunta];

const LADOS: Record<IdEscena, Lado> = {
  gancho: "asomadoIzquierda",
  que: "derecha",
  causas: "izquierda",
  sueno: "centro",
  teoria: "derecha",
  remate: "izquierda",
  pregunta: "centro",
};

/** Solo una escena con objeto: la bombilla de la teoría. */
const OBJETOS: Partial<Record<IdEscena, { objeto: TipoObjeto; palabra: string }>> = {
  teoria: { objeto: "Bombilla", palabra: "teoria" },
};

const sen = (s: number, periodo: number) => Math.sin((s * Math.PI * 2) / periodo);
const saltito = (s: number, desde: number, alto = 60) => {
  const d = s - desde;
  return d < 0 || d > 0.35 ? 0 : Math.sin((d / 0.35) * Math.PI) * alto;
};

type Estado = { pose: PoseNyxar; expresion: Expresion; parpadeo?: number };

const estado = (id: IdEscena, local: number): Estado => {
  const s = local / FPS;
  const m = (w: string) => LINEA.marcas(id)(w) / FPS;
  const base = { ...POSE_BASE };
  switch (id) {
    case "gancho": {
      // Su propio párpado también tiembla al principio.
      const tiembla = s < 2.4 && s % 1.1 < 0.6;
      return {
        pose: {
          ...base,
          brazoI: 150 + 8 * sen(s, 0.8),
          brazoD: 150 - 8 * sen(s, 0.8),
          mirarX: 0.5,
          mirarY: -0.5,
          cabeza: -6,
          salto: saltito(s, m("fasciculacion")),
        },
        expresion: s >= m("normal") ? "feliz" : "sorprendido",
        parpadeo: tiembla ? 0.25 + 0.2 * Math.sin(s * 70) : undefined,
      };
    }
    case "que":
      return { pose: { ...base, brazoD: 128 + 5 * sen(s, 1.4), brazoI: 18, mirarX: 0.6, mirarY: -0.5, cabeza: -6 }, expresion: "normal" };
    case "causas":
      return { pose: { ...base, brazoD: -128, brazoI: 18, cabeza: 6 + 3 * sen(s, 2) }, expresion: "pensativo" };
    case "sueno":
      return {
        pose: {
          ...base,
          brazoI: 120,
          brazoD: 120,
          salto: saltito(s, m("salto"), 90) + saltito(s, m("sacudida"), 90),
          cabeza: 4 * sen(s, 1.5),
        },
        expresion: s >= m("hasta") ? "feliz" : "sorprendido",
      };
    case "teoria":
      return {
        pose: { ...base, cabeza: 5 * sen(s, 2.4), salto: saltito(s, m("tensa"), 40) },
        expresion: s >= m("caes") && s < m("cuerpo") + 0.5 ? "sorprendido" : "pensativo",
      };
    case "remate":
      return {
        pose: { ...base, brazoD: s >= m("pero") ? 120 + 6 * sen(s, 0.6) : 40, brazoI: 18, cabeza: 4 * sen(s, 2) },
        expresion: s >= m("pero") ? "normal" : "feliz",
      };
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

const NyxarEnEscena: React.FC = () => {
  const frame = useCurrentFrame();
  const { id, local } = LINEA.escenaEn(frame);
  const e = estado(id, local);
  const obj = OBJETOS[id];
  if (obj) e.pose.objeto = spring({ frame: local - LINEA.marcas(id)(obj.palabra), fps: FPS, config: { damping: 13 } });
  return (
    <Escenario tramos={TRAMOS} fps={FPS}>
      {(ancho) => (
        <Nyxar
          ancho={ancho}
          pose={e.pose}
          boca={LINEA.aperturaBoca(frame)}
          frame={frame}
          fps={FPS}
          objeto={obj?.objeto}
          expresion={e.expresion}
          parpadeo={e.parpadeo}
        />
      )}
    </Escenario>
  );
};

const volumenMusica = (f: number) => interpolate(f, [0, 30, LINEA.total - 90, LINEA.total], [0.05, 0.06, 0.06, 0], CLAMP);

export const DURACION_FASCICULACIONES = LINEA.total;

export const Fasciculaciones: React.FC = () => (
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
        if (i < IDS.length - 1)
          items.push(
            <TransitionSeries.Transition key={`${id}-t`} presentation={fade()} timing={linearTiming({ durationInFrames: TRANSICION })} />,
          );
        return items;
      })}
    </TransitionSeries>
    <NyxarEnEscena />
    <Html5Audio loop loopVolumeCurveBehavior="extend" src={staticFile(`${CARPETA}/sfx-musica.mp3`)} volume={volumenMusica} />
  </AbsoluteFill>
);
