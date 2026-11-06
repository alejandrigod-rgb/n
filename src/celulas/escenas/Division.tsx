import { Easing, interpolate, useCurrentFrame } from "remotion";
import { Escena } from "../Escena";
import { CLAMP, COLORES } from "../tema";

export const Division: React.FC<{ duracion: number }> = ({ duracion }) => {
  const frame = useCurrentFrame();
  const p = interpolate(frame, [50, 200], [0, 1], {
    ...CLAMP,
    easing: Easing.inOut(Easing.cubic),
  });
  const dx = p * 250;
  const r = 230 - 40 * p;
  // Los cromosomas se alinean y luego se separan.
  const alinear = interpolate(frame, [15, 50], [0, 1], CLAMP);

  return (
    <Escena
      duracion={duracion}
      etiqueta="5 · División celular"
      titulo="Una célula se convierte en dos"
      color={COLORES.bien}
      subtitulos={[
        { desde: 10, texto: "Para crecer y reparar tejidos, la célula copia su ADN..." },
        { desde: 110, texto: "...y se divide en dos células hijas idénticas. Esto se llama mitosis." },
      ]}
    >
      <svg width={1400} height={600} viewBox="-700 -300 1400 600">
        <defs>
          <filter id="pegajoso">
            <feGaussianBlur in="SourceGraphic" stdDeviation={18} result="blur" />
            <feColorMatrix
              in="blur"
              mode="matrix"
              values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 30 -12"
            />
          </filter>
        </defs>
        <g filter="url(#pegajoso)">
          <circle cx={-dx} r={r} fill={COLORES.membrana} />
          <circle cx={dx} r={r} fill={COLORES.membrana} />
        </g>
        <g filter="url(#pegajoso)">
          <circle cx={-dx} r={r - 14} fill={COLORES.citoplasma} />
          <circle cx={dx} r={r - 14} fill={COLORES.citoplasma} />
        </g>
        {[-1, 1].map((lado) => (
          <g key={lado} transform={`translate(${lado * dx} 0)`}>
            {p > 0.6 ? (
              <circle
                r={70}
                fill="#4c1d95"
                stroke={COLORES.nucleo}
                strokeWidth={6}
                opacity={interpolate(p, [0.6, 0.9], [0, 1], CLAMP)}
              />
            ) : null}
            {[-60, -20, 20, 60].map((y, i) => {
              const x = lado * interpolate(p, [0, 0.6], [6, 30], CLAMP);
              const yy = interpolate(alinear, [0, 1], [y * 0.6 + (i % 2 ? 25 : -25), y]);
              return (
                <rect
                  key={i}
                  x={x - 8 + (1 - alinear) * (i % 2 ? 30 : -30)}
                  y={yy - 14}
                  width={16}
                  height={28}
                  rx={8}
                  fill={i % 2 ? COLORES.adn1 : COLORES.adn2}
                />
              );
            })}
          </g>
        ))}
      </svg>
    </Escena>
  );
};
