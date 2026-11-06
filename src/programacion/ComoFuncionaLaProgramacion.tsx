import { linearTiming, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";
import { AbsoluteFill, Html5Audio, interpolate, staticFile } from "remotion";
import { duracionEscena, Fondo } from "./comunes";
import { Algoritmo } from "./escenas/Algoritmo";
import { Binario } from "./escenas/Binario";
import { Bucles } from "./escenas/Bucles";
import { Bugs } from "./escenas/Bugs";
import { Condiciones } from "./escenas/Condiciones";
import { Final } from "./escenas/Final";
import { Intro } from "./escenas/Intro";
import { Lenguajes } from "./escenas/Lenguajes";
import { Que } from "./escenas/Que";
import { Variables } from "./escenas/Variables";
import { CLAMP } from "./tema";

const TRANSICION = 15;

const ESCENAS: { id: string; C: React.FC; extra?: number }[] = [
  { id: "intro", C: Intro, extra: 0.6 },
  { id: "que", C: Que },
  { id: "algoritmo", C: Algoritmo },
  { id: "lenguajes", C: Lenguajes, extra: 0.4 },
  { id: "binario", C: Binario },
  { id: "variables", C: Variables, extra: 0.4 },
  { id: "condiciones", C: Condiciones },
  { id: "bucles", C: Bucles },
  { id: "bugs", C: Bugs },
  { id: "final", C: Final, extra: 3 },
];

export const DURACION_PROGRAMACION =
  ESCENAS.reduce((a, e) => a + duracionEscena(e.id, e.extra), 0) - TRANSICION * (ESCENAS.length - 1);

const volumenMusica = (f: number) =>
  interpolate(f, [0, 20, DURACION_PROGRAMACION - 60, DURACION_PROGRAMACION], [0, 0.07, 0.07, 0], CLAMP);

export const ComoFuncionaLaProgramacion: React.FC = () => (
  <AbsoluteFill>
    <Fondo />
    <TransitionSeries>
      {ESCENAS.flatMap(({ id, C, extra }, i) => {
        const items = [
          <TransitionSeries.Sequence key={id} durationInFrames={duracionEscena(id, extra)}>
            <C />
          </TransitionSeries.Sequence>,
        ];
        if (i < ESCENAS.length - 1) {
          items.push(
            <TransitionSeries.Transition
              key={`${id}-t`}
              presentation={i % 3 === 2 ? slide({ direction: "from-right" }) : fade()}
              timing={linearTiming({ durationInFrames: TRANSICION })}
            />,
          );
        }
        return items;
      })}
    </TransitionSeries>
    <Html5Audio loop loopVolumeCurveBehavior="extend" src={staticFile("programacion/sfx-musica.mp3")} volume={volumenMusica} />
  </AbsoluteFill>
);
