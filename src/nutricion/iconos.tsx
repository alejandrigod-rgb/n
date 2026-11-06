import { C } from "./tema";

type P = { tamano: number };
const Svg: React.FC<P & { children: React.ReactNode }> = ({ tamano, children }) => (
  <svg width={tamano} height={tamano} viewBox="0 0 100 100">
    {children}
  </svg>
);

export const Manzana: React.FC<P> = ({ tamano }) => (
  <Svg tamano={tamano}>
    <path d="M50 30 C40 20 15 22 15 50 C15 75 35 92 50 85 C65 92 85 75 85 50 C85 22 60 20 50 30 Z" fill={C.rojo} stroke="#7a1520" strokeWidth={3} />
    <path d="M28 45 C30 38 35 34 40 33" stroke="#ff8a95" strokeWidth={5} fill="none" strokeLinecap="round" />
    <path d="M50 30 C50 22 52 16 56 12" stroke="#6b3e1d" strokeWidth={5} fill="none" strokeLinecap="round" />
    <path d="M55 20 C62 8 78 10 80 14 C74 24 62 24 55 20 Z" fill={C.verde} stroke={C.verdeOsc} strokeWidth={2} />
  </Svg>
);

export const Corazon: React.FC<P> = ({ tamano }) => (
  <Svg tamano={tamano}>
    <path d="M50 88 C20 66 8 50 10 33 C12 18 30 10 42 20 L50 27 L58 20 C70 10 88 18 90 33 C92 50 80 66 50 88 Z" fill={C.rojo} stroke="#7a1520" strokeWidth={3} />
    <polyline points="18,50 36,50 42,38 50,62 56,44 60,50 82,50" fill="none" stroke="#fff" strokeWidth={5} strokeLinejoin="round" strokeLinecap="round" />
  </Svg>
);

export const Rayo: React.FC<P> = ({ tamano }) => (
  <Svg tamano={tamano}>
    <polygon points="58,6 22,56 46,56 38,94 78,40 54,40 66,6" fill={C.amarillo} stroke="#5c4500" strokeWidth={4} strokeLinejoin="round" />
  </Svg>
);

export const Personas: React.FC<P> = ({ tamano }) => (
  <Svg tamano={tamano}>
    <g fill="#fff" stroke="#3d2470" strokeWidth={3}>
      <circle cx={24} cy={38} r={10} />
      <path d="M8 72 C8 56 40 56 40 72 Z" />
      <circle cx={76} cy={38} r={10} />
      <path d="M60 72 C60 56 92 56 92 72 Z" />
      <circle cx={50} cy={32} r={13} />
      <path d="M28 80 C28 58 72 58 72 80 Z" />
    </g>
  </Svg>
);

export const Portapapeles: React.FC<P> = ({ tamano }) => (
  <Svg tamano={tamano}>
    <rect x={18} y={12} width={64} height={82} rx={8} fill="#c98a4b" stroke="#6b3e1d" strokeWidth={3} />
    <rect x={26} y={22} width={48} height={64} rx={4} fill="#fff" />
    <rect x={36} y={6} width={28} height={14} rx={5} fill="#888" />
    {[36, 52, 68].map((y) => (
      <g key={y}>
        <polyline points={`31,${y} 35,${y + 4} 42,${y - 4}`} fill="none" stroke={C.verde} strokeWidth={4} strokeLinecap="round" />
        <line x1={47} y1={y} x2={68} y2={y} stroke="#bbb" strokeWidth={4} strokeLinecap="round" />
      </g>
    ))}
  </Svg>
);

export const Pizarra: React.FC<P> = ({ tamano }) => (
  <Svg tamano={tamano}>
    <line x1={30} y1={70} x2={20} y2={96} stroke="#6b3e1d" strokeWidth={5} />
    <line x1={70} y1={70} x2={80} y2={96} stroke="#6b3e1d" strokeWidth={5} />
    <rect x={8} y={10} width={84} height={62} rx={6} fill="#fff" stroke="#6b3e1d" strokeWidth={4} />
    <rect x={20} y={46} width={10} height={16} fill={C.azul} />
    <rect x={36} y={36} width={10} height={26} fill={C.verde} />
    <rect x={52} y={26} width={10} height={36} fill={C.naranja} />
    <circle cx={76} cy={30} r={8} fill={C.rojo} />
  </Svg>
);

export const Plato: React.FC<P> = ({ tamano }) => (
  <Svg tamano={tamano}>
    <circle cx={50} cy={50} r={44} fill="#fff" stroke="#999" strokeWidth={3} />
    <circle cx={50} cy={50} r={34} fill="#f3f3f3" />
    <path d="M50 50 L50 16 A34 34 0 0 1 84 50 Z" fill={C.verdeClaro} />
    <path d="M50 50 L84 50 A34 34 0 0 1 50 84 Z" fill={C.naranja} />
    <path d="M50 50 L50 84 A34 34 0 0 1 16 50 Z" fill="#e9c46a" />
    <path d="M50 50 L16 50 A34 34 0 0 1 50 16 Z" fill={C.rojo} />
  </Svg>
);

export const Megafono: React.FC<P> = ({ tamano }) => (
  <Svg tamano={tamano}>
    <path d="M18 40 L60 18 L60 82 L18 60 Z" fill="#fff" stroke={C.verdeOsc} strokeWidth={4} strokeLinejoin="round" />
    <rect x={8} y={38} width={14} height={24} rx={3} fill={C.verde} stroke={C.verdeOsc} strokeWidth={3} />
    <path d="M28 62 L36 86 L46 84 L40 66" fill={C.verde} stroke={C.verdeOsc} strokeWidth={3} />
    <g stroke={C.amarillo} strokeWidth={5} strokeLinecap="round">
      <line x1={70} y1={34} x2={86} y2={26} />
      <line x1={72} y1={50} x2={92} y2={50} />
      <line x1={70} y1={66} x2={86} y2={74} />
    </g>
  </Svg>
);

export const Chat: React.FC<P> = ({ tamano }) => (
  <Svg tamano={tamano}>
    <path d="M50 8 C26 8 8 25 8 47 C8 56 11 64 16 70 L10 92 L33 84 C38 86 44 87 50 87 C74 87 92 69 92 47 C92 25 74 8 50 8 Z" fill="#fff" />
    <path d="M36 30 C33 30 30 34 31 39 C33 50 46 64 58 67 C63 68 67 65 67 62 L67 57 L58 53 L54 57 C48 54 44 50 41 44 L45 40 L41 31 Z" fill={C.verde} />
  </Svg>
);

export const Nube: React.FC<P> = ({ tamano }) => (
  <Svg tamano={tamano}>
    <path d="M25 60 C10 60 10 40 25 40 C25 22 50 18 56 32 C64 24 82 30 80 44 C92 46 92 60 80 60 Z" fill="#8a96a8" stroke="#4b5566" strokeWidth={3} />
    <polygon points="52,60 42,78 50,78 44,94 62,72 54,72 60,60" fill={C.amarillo} />
  </Svg>
);

export const Hamburguesa: React.FC<P> = ({ tamano }) => (
  <Svg tamano={tamano}>
    <path d="M14 46 C14 22 86 22 86 46 Z" fill="#e0a050" stroke="#7a4a14" strokeWidth={3} />
    <rect x={10} y={50} width={80} height={8} rx={4} fill="#6dbb3c" />
    <rect x={12} y={58} width={76} height={12} rx={5} fill="#6b3e1d" />
    <path d="M14 72 L86 72 C86 84 14 84 14 72 Z" fill="#e0a050" stroke="#7a4a14" strokeWidth={3} />
  </Svg>
);

export const Zzz: React.FC<P> = ({ tamano }) => (
  <Svg tamano={tamano}>
    <circle cx={50} cy={50} r={44} fill="#c7d2fe" />
    <text x={22} y={70} fontSize={40} fontWeight={800} fill="#3730a3" fontFamily="sans-serif">Z</text>
    <text x={50} y={52} fontSize={28} fontWeight={800} fill="#3730a3" fontFamily="sans-serif">z</text>
    <text x={68} y={36} fontSize={20} fontWeight={800} fill="#3730a3" fontFamily="sans-serif">z</text>
  </Svg>
);

/** Logotipo: figura saltando formada por hojas. */
export const FiguraLogo: React.FC<P> = ({ tamano }) => (
  <Svg tamano={tamano}>
    <circle cx={58} cy={14} r={8} fill={C.azul} />
    <path d="M56 26 C40 40 38 62 46 92 C60 70 64 46 56 26 Z" fill={C.verde} />
    <path d="M54 30 C66 22 80 10 92 4 C86 20 72 32 54 30 Z" fill={C.verdeClaro} />
    <path d="M52 32 C40 26 26 18 14 8 C22 26 36 34 52 32 Z" fill={C.azul} />
    <path d="M50 62 C62 70 70 82 74 96 C60 90 52 78 50 62 Z" fill={C.azul} />
  </Svg>
);
