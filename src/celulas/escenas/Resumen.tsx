import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { CLAMP, COLORES, FUENTE } from "../tema";

const PARTES = [
  { color: COLORES.membrana, nombre: "Membrana", funcion: "Controla qué entra y sale" },
  { color: COLORES.nucleo, nombre: "Núcleo", funcion: "Guarda el ADN y da las órdenes" },
  { color: COLORES.ribosoma, nombre: "Ribosomas", funcion: "Fabrican proteínas" },
  { color: COLORES.mitocondria, nombre: "Mitocondrias", funcion: "Producen energía (ATP)" },
  { color: COLORES.bien, nombre: "Mitosis", funcion: "Una célula se divide en dos" },
];

export const Resumen: React.FC<{ duracion: number }> = ({ duracion }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const opacidad = interpolate(frame, [0, 15, duracion - 20, duracion], [0, 1, 1, 0], CLAMP);
  const final = spring({ frame: frame - 120, fps, config: { damping: 200 } });

  return (
    <AbsoluteFill
      style={{ fontFamily: FUENTE, opacity: opacidad, justifyContent: "center", alignItems: "center" }}
    >
      <div style={{ color: COLORES.texto, fontSize: 68, fontWeight: 800, marginBottom: 40 }}>
        En resumen
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 22, width: 1100 }}>
        {PARTES.map((p, i) => {
          const s = spring({ frame: frame - 10 - i * 10, fps, config: { damping: 200 } });
          return (
            <div
              key={p.nombre}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 30,
                background: "rgba(255,255,255,0.05)",
                borderLeft: `10px solid ${p.color}`,
                borderRadius: 18,
                padding: "18px 34px",
                opacity: s,
                transform: `translateX(${(1 - s) * -80}px)`,
              }}
            >
              <div style={{ color: p.color, fontSize: 44, fontWeight: 800, width: 340 }}>{p.nombre}</div>
              <div style={{ color: COLORES.texto, fontSize: 40 }}>{p.funcion}</div>
            </div>
          );
        })}
      </div>
      <div
        style={{
          color: COLORES.membrana,
          fontSize: 50,
          fontWeight: 700,
          marginTop: 50,
          opacity: final,
          transform: `scale(${0.9 + 0.1 * final})`,
        }}
      >
        Pequeñas, pero increíbles.
      </div>
    </AbsoluteFill>
  );
};
