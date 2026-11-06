import { interpolate, useCurrentFrame } from "remotion";
import { Escena } from "../Escena";
import { CLAMP, COLORES } from "../tema";

const AMINO = ["#f472b6", "#60a5fa", "#4ade80", "#c084fc", "#fb923c"];
const INICIO = 30;
const FIN = 230;
const ANCHO = 1500;

export const Ribosomas: React.FC<{ duracion: number }> = ({ duracion }) => {
  const frame = useCurrentFrame();
  const xRibo = interpolate(frame, [INICIO, FIN], [-620, 620], CLAMP);
  const cuentas = Math.floor(interpolate(frame, [INICIO, FIN], [0, 40], CLAMP));
  const cuentasProt = new Array(cuentas).fill(0).map((_, k) => {
    const x = -620 + (k / 40) * 1240;
    const y = -150 - 40 * Math.sin(k * 0.6 + frame * 0.03);
    return { x, y, color: AMINO[k % AMINO.length] };
  });

  return (
    <Escena
      duracion={duracion}
      etiqueta="3 · Ribosomas"
      titulo="Las fábricas de proteínas"
      color={COLORES.ribosoma}
      subtitulos={[
        { desde: 10, texto: "Una copia del gen (ARN mensajero) sale del núcleo hacia los ribosomas." },
        { desde: 135, texto: "El ribosoma la lee y une aminoácidos, uno a uno, para formar una proteína." },
      ]}
    >
      <svg width={ANCHO} height={560} viewBox="-750 -330 1500 560">
        {/* ARN mensajero */}
        <line x1={-700} y1={60} x2={700} y2={60} stroke="#e2e8f0" strokeWidth={8} />
        {new Array(47).fill(0).map((_, i) => (
          <rect
            key={i}
            x={-690 + i * 30}
            y={60}
            width={18}
            height={26}
            rx={4}
            fill={AMINO[(i * 7) % 4]}
            opacity={0.8}
          />
        ))}
        <text x={-700} y={140} fill={COLORES.tenue} fontSize={34}>ARN mensajero</text>
        {/* Proteína */}
        {cuentasProt.length > 1 ? (
          <polyline
            points={[...cuentasProt.map((c) => `${c.x},${c.y}`), `${xRibo},${-40}`].join(" ")}
            fill="none"
            stroke="#cbd5e1"
            strokeWidth={4}
          />
        ) : null}
        {cuentasProt.map((c, k) => (
          <circle key={k} cx={c.x} cy={c.y} r={16} fill={c.color} />
        ))}
        <text
          x={-700}
          y={-260}
          fill={COLORES.texto}
          fontSize={34}
          opacity={interpolate(frame, [80, 100], [0, 1], CLAMP)}
        >
          Proteína en construcción
        </text>
        {/* Ribosoma */}
        <g transform={`translate(${xRibo} 0)`} style={{ filter: `drop-shadow(0 0 14px ${COLORES.ribosoma})` }}>
          <ellipse cx={0} cy={-15} rx={85} ry={60} fill={COLORES.ribosoma} />
          <ellipse cx={0} cy={95} rx={70} ry={38} fill="#ca8a04" />
        </g>
      </svg>
    </Escena>
  );
};
