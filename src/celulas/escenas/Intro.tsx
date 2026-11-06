import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { Celula } from "../Celula";
import { CLAMP, COLORES, FUENTE } from "../tema";

export const Intro: React.FC<{ duracion: number }> = ({ duracion }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const celula = spring({ frame, fps, config: { damping: 14, mass: 0.8 } });
  const texto = spring({ frame: frame - 25, fps, config: { damping: 200 } });
  const sub = spring({ frame: frame - 45, fps, config: { damping: 200 } });
  const salida = interpolate(frame, [duracion - 15, duracion], [1, 0], CLAMP);

  return (
    <AbsoluteFill
      style={{
        justifyContent: "center",
        alignItems: "center",
        fontFamily: FUENTE,
        opacity: salida,
      }}
    >
      <div style={{ transform: `scale(${celula}) rotate(${frame / 4}deg)` }}>
        <Celula tamano={560} />
      </div>
      <div
        style={{
          color: COLORES.texto,
          fontSize: 100,
          fontWeight: 800,
          opacity: texto,
          transform: `translateY(${(1 - texto) * 40}px)`,
          marginTop: -10,
        }}
      >
        ¿Cómo funcionan las células?
      </div>
      <div
        style={{
          color: COLORES.membrana,
          fontSize: 44,
          fontWeight: 500,
          opacity: sub,
          marginTop: 16,
        }}
      >
        Un viaje al interior de la vida
      </div>
    </AbsoluteFill>
  );
};
