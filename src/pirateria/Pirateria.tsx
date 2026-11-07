import { linearTiming, TransitionPresentation, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";
import { wipe } from "@remotion/transitions/wipe";
import { AbsoluteFill, Html5Audio, interpolate, staticFile } from "remotion";
import { Fondo } from "./comunes";
import { Gato } from "./Gato";
import { Intro, Imprenta, Nombre, Que } from "./escenas/Historia1";
import { Cintas, Ley, Software } from "./escenas/Historia2";
import { Cierre, Final, Internet, Riesgos, Streaming } from "./escenas/Historia3";
import { DURACION_TOTAL, DURACIONES, IDS, TRANSICION } from "./linea";
import { CLAMP } from "./tema";

const COMPONENTES = [Intro, Que, Nombre, Imprenta, Ley, Cintas, Software, Internet, Cierre, Streaming, Riesgos, Final];
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const PRESENTACIONES: TransitionPresentation<any>[] = [
  slide({ direction: "from-right" }),
  wipe({ direction: "from-left" }),
  fade(),
  slide({ direction: "from-bottom" }),
];

const volumenMusica = (f: number) => interpolate(f, [0, 20, DURACION_TOTAL - 60, DURACION_TOTAL], [0, 0.06, 0.06, 0], CLAMP);

export const Pirateria: React.FC = () => (
  <AbsoluteFill>
    <Fondo />
    <TransitionSeries>
      {IDS.flatMap((id, i) => {
        const Comp = COMPONENTES[i];
        const items = [
          <TransitionSeries.Sequence key={id} durationInFrames={DURACIONES[i]}>
            <Comp />
          </TransitionSeries.Sequence>,
        ];
        if (i < IDS.length - 1) {
          items.push(
            <TransitionSeries.Transition key={`${id}-t`} presentation={PRESENTACIONES[i % PRESENTACIONES.length]} timing={linearTiming({ durationInFrames: TRANSICION })} />,
          );
        }
        return items;
      })}
    </TransitionSeries>
    {/* El gato vive fuera de las transiciones para moverse de forma continua. */}
    <div style={{ position: "absolute", left: 540 - 250, top: 1120 }}>
      <Gato ancho={500} />
    </div>
    <Html5Audio loop loopVolumeCurveBehavior="extend" src={staticFile("pirateria/sfx-musica.mp3")} volume={volumenMusica} />
  </AbsoluteFill>
);
