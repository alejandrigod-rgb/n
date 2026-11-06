import { linearTiming, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";
import { AbsoluteFill, Html5Audio, interpolate, staticFile } from "remotion";
import { PRE } from "./comunes";
import duraciones from "./duraciones.json";
import { Beneficios } from "./escenas/Beneficios";
import { Contacto } from "./escenas/Contacto";
import { Gancho } from "./escenas/Gancho";
import { Marca } from "./escenas/Marca";
import { Problema } from "./escenas/Problema";
import { Productividad } from "./escenas/Productividad";
import { Servicios } from "./escenas/Servicios";
import { FPS } from "./tema";

const TRANSICION = 12;
const voz = duraciones.voz as Record<string, number>;
const largo = (id: string, extra = 0) => PRE + Math.ceil((voz[id] + 0.7 + extra) * FPS);

const ESCENAS = [
  { id: "gancho", C: Gancho, d: largo("gancho", 0.6) },
  { id: "problema", C: Problema, d: largo("problema") },
  { id: "marca", C: Marca, d: largo("marca") },
  { id: "servicios", C: Servicios, d: largo("servicios") },
  { id: "beneficios", C: Beneficios, d: largo("beneficios", 0.4) },
  { id: "productividad", C: Productividad, d: largo("productividad") },
  { id: "contacto", C: Contacto, d: largo("contacto", 2.5) },
];

const PRESENTACIONES = [
  slide({ direction: "from-bottom" }),
  fade(),
  slide({ direction: "from-right" }),
  slide({ direction: "from-left" }),
  fade(),
  slide({ direction: "from-bottom" }),
];

export const DURACION_NUTRICION =
  ESCENAS.reduce((a, e) => a + e.d, 0) - TRANSICION * (ESCENAS.length - 1);

export const AlimentacionEquilibrio: React.FC = () => (
  <AbsoluteFill style={{ backgroundColor: "#fbf8ef" }}>
    <TransitionSeries>
      {ESCENAS.flatMap(({ id, C, d }, i) => {
        const Escena = C as React.FC<{ duracion: number }>;
        const items = [
          <TransitionSeries.Sequence key={id} durationInFrames={d}>
            <Escena duracion={d} />
          </TransitionSeries.Sequence>,
        ];
        if (i < ESCENAS.length - 1) {
          items.push(
            <TransitionSeries.Transition
              key={`${id}-t`}
              presentation={PRESENTACIONES[i]}
              timing={linearTiming({ durationInFrames: TRANSICION })}
            />,
          );
        }
        return items;
      })}
    </TransitionSeries>
    <Html5Audio loop loopVolumeCurveBehavior="extend" src={staticFile("nutricion/sfx-musica.mp3")} volume={volumenMusica} />
  </AbsoluteFill>
);

// La música entra suave y se desvanece al final.
const volumenMusica = (f: number) =>
  interpolate(f, [0, 15, DURACION_NUTRICION - 45, DURACION_NUTRICION], [0, 0.13, 0.13, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
