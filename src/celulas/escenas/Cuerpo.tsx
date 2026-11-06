import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { Escena } from "../Escena";
import { CLAMP, COLORES } from "../tema";

const COLS = 15;
const FILAS = 6;

export const Cuerpo: React.FC<{ duracion: number }> = ({ duracion }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const cuenta = interpolate(frame, [110, 200], [0, 37], CLAMP);

  return (
    <Escena
      duracion={duracion}
      etiqueta="La unidad de la vida"
      titulo="Todo está hecho de células"
      color={COLORES.membrana}
      subtitulos={[
        { desde: 10, texto: "Plantas, animales y personas: todos los seres vivos están formados por células." },
        { desde: 110, texto: "Tu cuerpo tiene unos 37 billones, y cada una trabaja sin parar." },
      ]}
    >
      <div style={{ position: "relative", marginTop: -60 }}>
        <svg width={1480} height={560}>
          {new Array(COLS * FILAS).fill(0).map((_, i) => {
            const c = i % COLS;
            const f = Math.floor(i / COLS);
            const dist = Math.hypot(c - COLS / 2, f - FILAS / 2);
            const s = spring({
              frame: frame - 10 - dist * 6,
              fps,
              config: { damping: 12 },
            });
            const x = 60 + c * 92 + (f % 2) * 46;
            const y = 50 + f * 92;
            const latido = 1 + 0.04 * Math.sin(frame / 10 + i);
            return (
              <g key={i} transform={`translate(${x} ${y}) scale(${s * latido})`}>
                <circle r={40} fill={COLORES.citoplasma} stroke={COLORES.membrana} strokeWidth={4} />
                <circle cx={-6} cy={-4} r={14} fill={COLORES.nucleo} />
              </g>
            );
          })}
        </svg>
        <div
          style={{
            position: "absolute",
            inset: 0,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            opacity: interpolate(frame, [100, 120], [0, 1], CLAMP),
          }}
        >
          <div
            style={{
              background: "rgba(2, 8, 20, 0.85)",
              borderRadius: 30,
              padding: "24px 60px",
              textAlign: "center",
              border: `3px solid ${COLORES.membrana}`,
            }}
          >
            <div style={{ color: COLORES.membrana, fontSize: 140, fontWeight: 800, lineHeight: 1 }}>
              ≈ {Math.round(cuenta)}
            </div>
            <div style={{ color: COLORES.texto, fontSize: 40 }}>billones de células</div>
          </div>
        </div>
      </div>
    </Escena>
  );
};
