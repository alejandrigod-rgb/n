import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { CLAMP, COLORES, FUENTE } from "./tema";

export type Subtitulo = { desde: number; texto: string };

export const Escena: React.FC<{
  duracion: number;
  etiqueta: string;
  titulo: string;
  color: string;
  subtitulos: Subtitulo[];
  children: React.ReactNode;
}> = ({ duracion, etiqueta, titulo, color, subtitulos, children }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const opacidad = interpolate(
    frame,
    [0, 15, duracion - 15, duracion],
    [0, 1, 1, 0],
    CLAMP,
  );
  const entrada = spring({ frame, fps, config: { damping: 200 } });

  const actual = [...subtitulos].reverse().find((s) => frame >= s.desde);
  const opSub = actual
    ? interpolate(frame - actual.desde, [0, 12], [0, 1], CLAMP)
    : 0;

  return (
    <AbsoluteFill style={{ opacity: opacidad, fontFamily: FUENTE }}>
      <div
        style={{
          position: "absolute",
          top: 60,
          left: 0,
          right: 0,
          textAlign: "center",
          transform: `translateY(${(1 - entrada) * -40}px)`,
          opacity: entrada,
        }}
      >
        <div
          style={{
            color,
            fontSize: 30,
            fontWeight: 700,
            letterSpacing: 6,
            textTransform: "uppercase",
          }}
        >
          {etiqueta}
        </div>
        <div
          style={{
            color: COLORES.texto,
            fontSize: 72,
            fontWeight: 800,
            marginTop: 8,
          }}
        >
          {titulo}
        </div>
      </div>
      <AbsoluteFill
        style={{ justifyContent: "center", alignItems: "center", top: 60 }}
      >
        {children}
      </AbsoluteFill>
      {actual ? (
        <div
          style={{
            position: "absolute",
            bottom: 70,
            left: 0,
            right: 0,
            display: "flex",
            justifyContent: "center",
          }}
        >
          <div
            style={{
              opacity: opSub,
              transform: `translateY(${(1 - opSub) * 15}px)`,
              background: "rgba(2, 8, 20, 0.7)",
              border: `2px solid ${color}55`,
              borderRadius: 20,
              padding: "18px 36px",
              color: COLORES.texto,
              fontSize: 44,
              fontWeight: 500,
              maxWidth: 1500,
              textAlign: "center",
            }}
          >
            {actual.texto}
          </div>
        </div>
      ) : null}
    </AbsoluteFill>
  );
};
