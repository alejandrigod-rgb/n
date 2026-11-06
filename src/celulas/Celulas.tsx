import { AbsoluteFill, Series } from "remotion";
import { Fondo } from "./Fondo";
import { Cuerpo } from "./escenas/Cuerpo";
import { Division } from "./escenas/Division";
import { Intro } from "./escenas/Intro";
import { Membrana } from "./escenas/Membrana";
import { Mitocondrias } from "./escenas/Mitocondrias";
import { Nucleo } from "./escenas/Nucleo";
import { Resumen } from "./escenas/Resumen";
import { Ribosomas } from "./escenas/Ribosomas";

const ESCENAS = [
  { C: Intro, d: 150 },
  { C: Cuerpo, d: 240 },
  { C: Membrana, d: 270 },
  { C: Nucleo, d: 270 },
  { C: Ribosomas, d: 270 },
  { C: Mitocondrias, d: 270 },
  { C: Division, d: 270 },
  { C: Resumen, d: 240 },
];

export const DURACION_CELULAS = ESCENAS.reduce((a, e) => a + e.d, 0);

export const Celulas: React.FC = () => (
  <AbsoluteFill>
    <Fondo />
    <Series>
      {ESCENAS.map(({ C, d }, i) => (
        <Series.Sequence key={i} durationInFrames={d}>
          <C duracion={d} />
        </Series.Sequence>
      ))}
    </Series>
  </AbsoluteFill>
);
