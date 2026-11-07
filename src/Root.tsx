import { Composition } from "remotion";
import { Celulas, DURACION_CELULAS } from "./celulas/Celulas";
import { HelloWorld } from "./HelloWorld";
import { DURACION_TOTAL } from "./pirateria/linea";
import { Pirateria } from "./pirateria/Pirateria";
import { RetratoNyxar } from "./personajes/RetratoNyxar";
import {
  ComoFuncionaLaProgramacion,
  DURACION_PROGRAMACION,
} from "./programacion/ComoFuncionaLaProgramacion";
import {
  AlimentacionEquilibrio,
  DURACION_NUTRICION,
} from "./nutricion/AlimentacionEquilibrio";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition id="RetratoNyxar" component={RetratoNyxar} durationInFrames={120} fps={30} width={900} height={1100} />
      <Composition
        id="Pirateria"
        component={Pirateria}
        durationInFrames={DURACION_TOTAL}
        fps={30}
        width={1080}
        height={1920}
      />
      <Composition
        id="ComoFuncionaLaProgramacion"
        component={ComoFuncionaLaProgramacion}
        durationInFrames={DURACION_PROGRAMACION}
        fps={30}
        width={1920}
        height={1080}
      />
      <Composition
        id="AlimentacionEquilibrio"
        component={AlimentacionEquilibrio}
        durationInFrames={DURACION_NUTRICION}
        fps={30}
        width={1080}
        height={1920}
      />
      <Composition
        id="Celulas"
        component={Celulas}
        durationInFrames={DURACION_CELULAS}
        fps={30}
        width={1920}
        height={1080}
      />
      <Composition
        id="HelloWorld"
        component={HelloWorld}
        durationInFrames={150}
        fps={30}
        width={1920}
        height={1080}
        defaultProps={{ titulo: "¡Hola, Remotion!" }}
      />
    </>
  );
};
