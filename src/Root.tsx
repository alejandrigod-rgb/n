import { Composition } from "remotion";
import { Celulas, DURACION_CELULAS } from "./celulas/Celulas";
import { HelloWorld } from "./HelloWorld";
import { DURACION_TOTAL } from "./pirateria/linea";
import { Pirateria } from "./pirateria/Pirateria";
import { RetratoNyxar } from "./personajes/RetratoNyxar";
import { SPRITES, SpritesNyxar } from "./personajes/SpritesNyxar";
import { DURACION_GTA, GtaVI } from "./gta/GtaVI";
import { DURACION_ESPERA, EsperaGTA } from "./espera/EsperaGTA";
import { BackroomsVideo, DURACION_BACKROOMS } from "./backrooms/Backrooms";
import { DURACION_FASCICULACIONES, Fasciculaciones } from "./fasciculaciones/Fasciculaciones";
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
      <Composition id="Backrooms" component={BackroomsVideo} durationInFrames={DURACION_BACKROOMS} fps={60} width={1080} height={1920} />
      <Composition id="EsperaGTA" component={EsperaGTA} durationInFrames={DURACION_ESPERA} fps={60} width={1080} height={1920} />
      <Composition id="Fasciculaciones" component={Fasciculaciones} durationInFrames={DURACION_FASCICULACIONES} fps={60} width={1080} height={1920} />
      <Composition id="SpritesNyxar" component={SpritesNyxar} durationInFrames={SPRITES.length} fps={30} width={900} height={1260} />
      <Composition id="GtaVI" component={GtaVI} durationInFrames={DURACION_GTA} fps={60} width={1080} height={1920} />
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
