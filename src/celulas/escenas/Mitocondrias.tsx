import { interpolate, useCurrentFrame } from "remotion";
import { Mitocondria } from "../Celula";
import { Escena } from "../Escena";
import { CLAMP, COLORES } from "../tema";

const PERIODO = 70;

export const Mitocondrias: React.FC<{ duracion: number }> = ({ duracion }) => {
  const frame = useCurrentFrame();
  const pulso = 1 + 0.03 * Math.sin(frame / 6);

  const entradas = new Array(4).fill(0).map((_, i) => {
    const c = ((frame + i * (PERIODO / 4)) % PERIODO) / PERIODO;
    return {
      x: interpolate(c, [0, 1], [-720, -230]),
      y: -60 + (i % 2) * 120 + Math.sin(c * 6) * 20,
      op: interpolate(c, [0, 0.15, 0.8, 1], [0, 1, 1, 0], CLAMP),
      glucosa: i % 2 === 0,
    };
  });
  const salidas = new Array(5).fill(0).map((_, i) => {
    const c = ((frame + i * (PERIODO / 5)) % PERIODO) / PERIODO;
    return {
      x: interpolate(c, [0, 1], [220, 700]),
      y: -140 + i * 70,
      op: interpolate(c, [0, 0.15, 0.75, 1], [0, 1, 1, 0], CLAMP),
      s: interpolate(c, [0, 0.2], [0.4, 1], CLAMP),
    };
  });

  return (
    <Escena
      duracion={duracion}
      etiqueta="4 · Mitocondrias"
      titulo="Las centrales de energía"
      color={COLORES.mitocondria}
      subtitulos={[
        { desde: 10, texto: "Las mitocondrias usan glucosa y oxígeno de los alimentos y el aire que respiras..." },
        { desde: 135, texto: "...y los convierten en ATP, la energía que la célula usa para todo." },
      ]}
    >
      <svg width={1500} height={560} viewBox="-750 -280 1500 560">
        {entradas.map((e, i) =>
          e.glucosa ? (
            <polygon
              key={i}
              opacity={e.op}
              transform={`translate(${e.x} ${e.y}) rotate(${frame * 2})`}
              points={new Array(6)
                .fill(0)
                .map((_, k) => `${Math.cos((k * Math.PI) / 3) * 28},${Math.sin((k * Math.PI) / 3) * 28}`)
                .join(" ")}
              fill="#fde68a"
            />
          ) : (
            <g key={i} opacity={e.op} transform={`translate(${e.x} ${e.y})`}>
              <circle cx={-14} r={18} fill="#93c5fd" />
              <circle cx={14} r={18} fill="#93c5fd" />
            </g>
          ),
        )}
        <g style={{ filter: `drop-shadow(0 0 ${20 + 10 * Math.sin(frame / 6)}px ${COLORES.mitocondria})` }}>
          <Mitocondria x={0} y={0} rot={0} escala={4.6 * pulso} />
        </g>
        {salidas.map((s, i) => (
          <g key={i} opacity={s.op} transform={`translate(${s.x} ${s.y}) scale(${s.s})`}>
            <rect x={-60} y={-26} width={120} height={52} rx={26} fill="#fbbf24" />
            <text textAnchor="middle" y={13} fontSize={36} fontWeight={800} fill="#1c1917">
              ATP
            </text>
          </g>
        ))}
        <text x={-720} y={250} fontSize={36} fill={COLORES.texto}>Glucosa + O₂</text>
        <text x={720} y={250} fontSize={36} fill={COLORES.texto} textAnchor="end">
          Energía (ATP)
        </text>
      </svg>
    </Escena>
  );
};
