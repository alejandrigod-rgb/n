import { AbsoluteFill, random, useCurrentFrame } from "remotion";
import { COLORES } from "./tema";

const BURBUJAS = new Array(28).fill(0).map((_, i) => ({
  x: random(`x${i}`) * 1920,
  y: random(`y${i}`) * 1080,
  r: 6 + random(`r${i}`) * 30,
  v: 0.2 + random(`v${i}`) * 0.6,
  o: 0.04 + random(`o${i}`) * 0.08,
}));

export const Fondo: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(circle at 50% 40%, ${COLORES.fondo1}, ${COLORES.fondo2} 75%)`,
      }}
    >
      <svg width={1920} height={1080}>
        {BURBUJAS.map((b, i) => (
          <circle
            key={i}
            cx={b.x + Math.sin(frame / 60 + i) * 20}
            cy={(((b.y - frame * b.v) % 1180) + 1180) % 1180 - 50}
            r={b.r}
            fill={COLORES.membrana}
            opacity={b.o}
          />
        ))}
      </svg>
    </AbsoluteFill>
  );
};
