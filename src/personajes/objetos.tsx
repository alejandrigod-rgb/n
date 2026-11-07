/**
 * Objetos que Nyxar puede sostener, relacionados con el tema de cada escena.
 * Cada objeto se dibuja centrado en (0, 0), con ~140 px de ancho, en el estilo de la marca:
 * contorno oscuro como Nyxar y detalles en menta neón.
 */
const LINEA = "#1d1530";
const MENTA = "#5ee7c4";
const AMBAR = "#ffb547";

/** Portátil abierto con código en pantalla (cómputo, programación, internet). */
export const Portatil: React.FC<{ frame: number }> = ({ frame }) => {
  const lineas = [46, 70, 34, 58, 40];
  const visibles = Math.floor(frame / 6) % (lineas.length + 2);
  return (
    <g>
      <rect x={-78} y={-70} width={156} height={100} rx={10} fill="#1b2238" stroke={LINEA} strokeWidth={6} />
      <rect x={-68} y={-60} width={136} height={80} rx={4} fill="#071733" />
      {lineas.map((w, k) => (
        <rect
          key={k}
          x={-58}
          y={-52 + k * 14}
          width={k < visibles ? w : 0}
          height={7}
          rx={3.5}
          fill={k % 2 ? MENTA : "#8fb3ff"}
          opacity={0.9}
        />
      ))}
      <path d="M-92 30 L92 30 L104 46 L-104 46 Z" fill="#2b3350" stroke={LINEA} strokeWidth={6} strokeLinejoin="round" />
      <rect x={-20} y={34} width={40} height={6} rx={3} fill="#3c4566" />
      <rect x={-68} y={-60} width={136} height={80} rx={4} fill={MENTA} opacity={0.06 + 0.04 * Math.sin(frame / 8)} />
    </g>
  );
};

/** Móvil con una notificación que late (redes, apps, mensajes). */
export const Movil: React.FC<{ frame: number }> = ({ frame }) => (
  <g>
    <rect x={-40} y={-75} width={80} height={150} rx={16} fill="#1b2238" stroke={LINEA} strokeWidth={6} />
    <rect x={-32} y={-62} width={64} height={122} rx={8} fill="#071733" />
    <rect
      x={-24}
      y={-50}
      width={48}
      height={22}
      rx={6}
      fill={MENTA}
      opacity={0.85}
      transform={`scale(${1 + 0.05 * Math.sin(frame / 5)})`}
    />
    {[0, 1, 2].map((k) => (
      <rect key={k} x={-24} y={-18 + k * 18} width={48 - k * 10} height={8} rx={4} fill="#8fb3ff" opacity={0.6} />
    ))}
    <circle cx={30} cy={-66} r={10} fill="#ff4d6d" stroke={LINEA} strokeWidth={3} />
  </g>
);

/** Mando de videojuegos. */
export const Mando: React.FC<{ frame: number }> = ({ frame }) => (
  <g>
    <path
      d="M-60 -24 H60 C88 -24 98 10 94 34 C90 58 64 62 52 42 L40 24 H-40 L-52 42 C-64 62 -90 58 -94 34 C-98 10 -88 -24 -60 -24 Z"
      fill="#2b3350"
      stroke={LINEA}
      strokeWidth={6}
      strokeLinejoin="round"
    />
    <rect x={-60} y={-6} width={10} height={32} rx={3} fill={MENTA} />
    <rect x={-71} y={5} width={32} height={10} rx={3} fill={MENTA} />
    <circle cx={50} cy={-2} r={7} fill={frame % 30 < 15 ? AMBAR : "#ff4d6d"} />
    <circle cx={66} cy={12} r={7} fill="#8fb3ff" />
    <circle cx={34} cy={12} r={7} fill="#c08cff" />
  </g>
);

/** Libro abierto (historia, leyes, datos). */
export const Libro: React.FC<{ frame: number }> = () => (
  <g>
    <path
      d="M0 -40 C-30 -54 -70 -54 -92 -44 L-92 50 C-70 40 -30 40 0 54 Z"
      fill="#f1f5ff"
      stroke={LINEA}
      strokeWidth={6}
      strokeLinejoin="round"
    />
    <path
      d="M0 -40 C30 -54 70 -54 92 -44 L92 50 C70 40 30 40 0 54 Z"
      fill="#e6ecfa"
      stroke={LINEA}
      strokeWidth={6}
      strokeLinejoin="round"
    />
    {[0, 1, 2, 3].map((k) => (
      <g key={k} stroke="#9aabc9" strokeWidth={5} strokeLinecap="round">
        <line x1={-76} y1={-26 + k * 18} x2={-16} y2={-22 + k * 18} />
        <line x1={16} y1={-22 + k * 18} x2={76} y2={-26 + k * 18} />
      </g>
    ))}
  </g>
);

/** Lupa (investigar, descubrir, el detalle que nadie ve). */
export const Lupa: React.FC<{ frame: number }> = ({ frame }) => (
  <g transform={`rotate(${Math.sin(frame / 12) * 6})`}>
    <line x1={30} y1={30} x2={78} y2={78} stroke={LINEA} strokeWidth={22} strokeLinecap="round" />
    <line x1={30} y1={30} x2={78} y2={78} stroke="#8b5a2b" strokeWidth={12} strokeLinecap="round" />
    <circle r={48} fill={MENTA} fillOpacity={0.18} stroke={LINEA} strokeWidth={10} />
    <circle r={48} fill="none" stroke="#c5cfe6" strokeWidth={4} />
    <path d="M-24 -20 C-16 -32 -4 -36 8 -34" stroke="#fff" strokeWidth={5} fill="none" strokeLinecap="round" opacity={0.7} />
  </g>
);

/** Bombilla encendida (idea, invento, "¡ajá!"). */
export const Bombilla: React.FC<{ frame: number }> = ({ frame }) => {
  const brillo = 0.5 + 0.5 * Math.abs(Math.sin(frame / 6));
  return (
    <g>
      <defs>
        <radialGradient id="halo-bombilla">
          <stop offset="0" stopColor={AMBAR} stopOpacity={0.55 * brillo} />
          <stop offset="1" stopColor={AMBAR} stopOpacity={0} />
        </radialGradient>
      </defs>
      <circle r={95} fill="url(#halo-bombilla)" />
      <path
        d="M0 -62 C34 -62 52 -36 52 -12 C52 10 36 22 28 38 L-28 38 C-36 22 -52 10 -52 -12 C-52 -36 -34 -62 0 -62 Z"
        fill={AMBAR}
        stroke={LINEA}
        strokeWidth={6}
      />
      <rect x={-26} y={38} width={52} height={22} rx={6} fill="#9aabc9" stroke={LINEA} strokeWidth={5} />
      <path d="M-14 10 L-6 -14 L0 4 L6 -14 L14 10" stroke="#fff3c4" strokeWidth={5} fill="none" strokeLinejoin="round" />
    </g>
  );
};

export const OBJETOS = { Portatil, Movil, Mando, Libro, Lupa, Bombilla };
export type TipoObjeto = keyof typeof OBJETOS;

/**
 * Cómo sujeta Nyxar cada objeto. Las posiciones están calculadas para que las patas
 * caigan justo en los puntos de agarre (hombros en 228/332, 368; brazo de 110 px).
 * - "dos": el objeto va delante del pecho y las dos patas lo sujetan por los lados.
 * - "derecha": lo lleva en la pata derecha (dx/dy: dónde queda el centro respecto a la pata).
 * - "encima": no se sujeta; aparece sobre la cabeza y Nyxar lo señala.
 */
export type Agarre = {
  manos: "dos" | "derecha" | "encima";
  brazoI: number;
  brazoD: number;
  x?: number;
  y?: number;
  dx?: number;
  dy?: number;
  escala: number;
  giro: number;
  mirarX: number;
  mirarY: number;
  cabeza: number;
};

export const AGARRES: Record<TipoObjeto, Agarre> = {
  Portatil: { manos: "dos", brazoI: 34, brazoD: 34, x: 280, y: 410, escala: 1.1, giro: 0, mirarX: 0, mirarY: 0.6, cabeza: 0 },
  Libro: { manos: "dos", brazoI: 26, brazoD: 26, x: 280, y: 412, escala: 1.1, giro: 0, mirarX: 0, mirarY: 0.7, cabeza: 4 },
  Mando: { manos: "dos", brazoI: 20, brazoD: 20, x: 280, y: 436, escala: 1.2, giro: 0, mirarX: 0, mirarY: 0.5, cabeza: -3 },
  Movil: { manos: "derecha", brazoI: 12, brazoD: 110, dx: 0, dy: -46, escala: 0.8, giro: -12, mirarX: 0.8, mirarY: 0.2, cabeza: 6 },
  Lupa: { manos: "derecha", brazoI: 12, brazoD: 125, dx: -70, dy: -70, escala: 0.9, giro: 0, mirarX: 0.5, mirarY: 0, cabeza: 3 },
  Bombilla: { manos: "encima", brazoI: 12, brazoD: 162, x: 330, y: -45, escala: 0.85, giro: 8, mirarX: 0.4, mirarY: -1, cabeza: -6 },
};
