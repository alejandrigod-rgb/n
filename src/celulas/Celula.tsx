import { random, useCurrentFrame } from "remotion";
import { blobPath, COLORES } from "./tema";

export type Parte = "membrana" | "nucleo" | "mitocondria" | "ribosoma";

export const Mitocondria: React.FC<{
  x: number;
  y: number;
  rot: number;
  escala?: number;
}> = ({ x, y, rot, escala = 1 }) => {
  let zigzag = "M-30 0";
  for (let i = 0; i < 6; i++) {
    zigzag += ` L${-25 + i * 10} ${i % 2 === 0 ? -10 : 10}`;
  }
  zigzag += " L30 0";
  return (
    <g transform={`translate(${x} ${y}) rotate(${rot}) scale(${escala})`}>
      <ellipse rx={42} ry={20} fill={COLORES.mitocondria} />
      <ellipse rx={36} ry={14} fill="#c2410c" />
      <path
        d={zigzag}
        stroke="#fed7aa"
        strokeWidth={3}
        fill="none"
        strokeLinejoin="round"
      />
    </g>
  );
};

const MITOS = [
  { x: 130, y: -110, rot: 30 },
  { x: 150, y: 90, rot: -20 },
  { x: -150, y: 120, rot: 60 },
  { x: 20, y: 170, rot: 5 },
  { x: -160, y: -110, rot: -40 },
];

const RIBOS = new Array(40).fill(0).map((_, i) => {
  const a = random(`ra${i}`) * Math.PI * 2;
  const r = 120 + random(`rr${i}`) * 100;
  return { x: Math.cos(a) * r, y: Math.sin(a) * r };
});

/**
 * Célula animal estilizada. El sistema de coordenadas va de -400 a 400,
 * con la membrana en un radio de ~250. `children` se dibuja encima.
 */
export const Celula: React.FC<{
  tamano: number;
  resaltar?: Parte;
  escala?: number;
  children?: React.ReactNode;
}> = ({ tamano, resaltar, escala = 1, children }) => {
  const frame = useCurrentFrame();
  const t = frame / 25;
  const op = (p: Parte) => (resaltar && resaltar !== p ? 0.25 : 1);
  const brillo = (p: Parte, color: string) =>
    resaltar === p
      ? `drop-shadow(0 0 ${10 + 6 * Math.sin(frame / 8)}px ${color})`
      : undefined;

  return (
    <svg width={tamano} height={tamano} viewBox="-400 -400 800 800">
      <g transform={`scale(${escala})`}>
        <path
          d={blobPath(250, t)}
          fill={COLORES.citoplasma}
          stroke={COLORES.membrana}
          strokeWidth={14}
          opacity={op("membrana") === 1 ? 1 : 0.8}
          style={{ filter: brillo("membrana", COLORES.membrana) }}
        />
        {/* Retículo endoplasmático */}
        <g opacity={resaltar ? 0.25 : 0.6}>
          {[110, 128, 146].map((r) => (
            <path
              key={r}
              d={`M${-30 + r * Math.cos(2.3)} ${-20 + r * Math.sin(2.3)} A ${r} ${r} 0 0 1 ${-30 + r * Math.cos(3.6)} ${-20 + r * Math.sin(3.6)}`}
              stroke="#38bdf8"
              strokeWidth={6}
              fill="none"
              strokeLinecap="round"
            />
          ))}
        </g>
        <g
          opacity={op("ribosoma")}
          style={{ filter: brillo("ribosoma", COLORES.ribosoma) }}
        >
          {RIBOS.map((r, i) => (
            <circle
              key={i}
              cx={r.x + Math.sin(t + i) * 3}
              cy={r.y + Math.cos(t + i) * 3}
              r={5}
              fill={COLORES.ribosoma}
            />
          ))}
        </g>
        <g
          opacity={op("mitocondria")}
          style={{ filter: brillo("mitocondria", COLORES.mitocondria) }}
        >
          {MITOS.map((m, i) => (
            <Mitocondria
              key={i}
              x={m.x + Math.sin(t * 0.7 + i) * 4}
              y={m.y + Math.cos(t * 0.6 + i) * 4}
              rot={m.rot + Math.sin(t * 0.5 + i) * 6}
            />
          ))}
        </g>
        <g
          opacity={op("nucleo")}
          style={{ filter: brillo("nucleo", COLORES.nucleo) }}
        >
          <path
            d={blobPath(85, -t, 3, 4, -30, -20)}
            fill="#4c1d95"
            stroke={COLORES.nucleo}
            strokeWidth={8}
          />
          <circle cx={-10} cy={-35} r={26} fill={COLORES.nucleo} opacity={0.8} />
        </g>
        {children}
      </g>
    </svg>
  );
};
