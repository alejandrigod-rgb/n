import { Composition } from "remotion";
import { Celulas, DURACION_CELULAS } from "./celulas/Celulas";
import { HelloWorld } from "./HelloWorld";

export const RemotionRoot: React.FC = () => {
  return (
    <>
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
