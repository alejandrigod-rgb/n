/**
 * Los dos "mundos" que ve la cámara: el cuarto de Nyxar y los Backrooms.
 * Lienzo de 1080×1920 con perspectiva de un punto (punto de fuga en 540, 860).
 */
import { random } from "remotion";
import { C, F } from "../marca/tema";

export const Cuarto: React.FC<{ s: number }> = ({ s }) => {
  return (
    <svg width={1080} height={1920} viewBox="0 0 1080 1920" style={{ position: "absolute", inset: 0 }}>
      <defs>
        <linearGradient id="cuarto-fondo" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#2c2156" />
          <stop offset="1" stopColor="#221a46" />
        </linearGradient>
        <radialGradient id="cuarto-lampara" cx="0.78" cy="0.55" r="0.4">
          <stop offset="0" stopColor="#ffb547" stopOpacity="0.28" />
          <stop offset="1" stopColor="#ffb547" stopOpacity="0" />
        </radialGradient>
      </defs>
      {/* Techo, paredes y suelo */}
      <polygon points="0,0 1080,0 780,640 300,640" fill="#1a1336" />
      <polygon points="0,0 300,640 300,1080 0,1920" fill="#241b4a" />
      <polygon points="1080,0 780,640 780,1080 1080,1920" fill="#241b4a" />
      <rect x={300} y={640} width={480} height={440} fill="url(#cuarto-fondo)" />
      <polygon points="0,1920 300,1080 780,1080 1080,1920" fill="#3a2a4f" />
      {/* Tablas del suelo */}
      {new Array(9).fill(0).map((_, k) => {
        const xb = 300 + (k * 480) / 8;
        const xf = (k * 1080) / 8;
        return <line key={k} x1={xb} y1={1080} x2={xf} y2={1920} stroke="#2a1d3c" strokeWidth={4} />;
      })}
      {/* Luces LED menta en el borde del techo */}
      <polyline points="0,0 300,640 780,640 1080,0" fill="none" stroke={C.menta} strokeWidth={8} opacity={0.75 + 0.15 * Math.sin(s * 2)} />
      <polyline points="0,0 300,640 780,640 1080,0" fill="none" stroke={C.menta} strokeWidth={30} opacity={0.12} />
      {/* Ventana con luna */}
      <rect x={330} y={690} width={170} height={170} rx={8} fill="#0b1640" stroke="#1d1530" strokeWidth={8} />
      <circle cx={450} cy={735} r={26} fill="#f3e9c6" />
      {[0, 1, 2, 3].map((k) => (
        <circle
          key={k}
          cx={350 + random(`ex${k}`) * 140}
          cy={705 + random(`ey${k}`) * 140}
          r={2.5}
          fill="#fff"
          opacity={0.5 + 0.5 * Math.sin(s * 3 + k)}
        />
      ))}
      <line x1={415} y1={690} x2={415} y2={860} stroke="#1d1530" strokeWidth={6} />
      <line x1={330} y1={775} x2={500} y2={775} stroke="#1d1530" strokeWidth={6} />
      {/* Póster de AEZ */}
      <g transform="translate(560 690)">
        <rect width={170} height={220} rx={10} fill="#0e0b1f" stroke={C.menta} strokeWidth={5} />
        <text x={85} y={92} textAnchor="middle" fontFamily={F.titulo} fontWeight={800} fontSize={64} fill={C.menta}>
          AEZ
        </text>
        <path d="M45 190 L60 130 L80 160 L100 160 L120 130 L135 190 Z" fill={C.pelaje} />
        <circle cx={78} cy={170} r={5} fill="#fff" />
        <circle cx={102} cy={170} r={5} fill="#fff" />
      </g>
      {/* Escritorio con portátil y lámpara */}
      <rect x={600} y={960} width={170} height={20} rx={6} fill="#5a3e2b" />
      <rect x={612} y={980} width={14} height={100} fill="#4a3222" />
      <rect x={744} y={980} width={14} height={100} fill="#4a3222" />
      <rect x={640} y={900} width={90} height={58} rx={6} fill="#1b2238" stroke="#0e0b1f" strokeWidth={4} />
      <rect x={646} y={906} width={78} height={46} rx={3} fill={C.menta} opacity={0.35 + 0.1 * Math.sin(s * 4)} />
      <rect x={630} y={956} width={110} height={8} rx={4} fill="#2b3350" />
      <rect width={1080} height={1920} fill="url(#cuarto-lampara)" />
      {/* Cama */}
      <polygon points="300,1000 300,1080 120,1300 120,1180" fill="#5a3f8f" />
      <polygon points="120,1180 300,1000 300,1060 120,1250" fill="#7a63c0" />
      <rect x={250} y={990} width={50} height={36} rx={10} fill="#f1f5ff" opacity={0.9} />
      {/* Alfombra */}
      <ellipse cx={540} cy={1640} rx={380} ry={120} fill="#4a3a7a" opacity={0.7} />
      <ellipse cx={540} cy={1640} rx={300} ry={90} fill="none" stroke={C.menta} strokeWidth={6} opacity={0.4} />
    </svg>
  );
};

/** Los Backrooms: amarillo, fluorescentes, moqueta y salas que no acaban. */
export const Backrooms: React.FC<{ s: number; parpadeo: number }> = ({ s, parpadeo }) => {
  const luz = 1 - parpadeo * 0.6;
  const filas = [0.18, 0.42, 0.66, 0.86];
  return (
    <svg width={1080} height={1920} viewBox="0 0 1080 1920" style={{ position: "absolute", inset: 0 }}>
      <defs>
        <pattern id="papel" width={36} height={36} patternUnits="userSpaceOnUse">
          <rect width={36} height={36} fill="#cdb85f" />
          <line x1={18} y1={0} x2={18} y2={36} stroke="#b7a14c" strokeWidth={3} />
          <path d="M6 18 l6 -6 l6 6 l-6 6 Z" fill="#c2ad55" />
        </pattern>
        <filter id="moqueta" x="0" y="0" width="100%" height="100%">
          <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves={2} seed={3} result="ruido" />
          <feColorMatrix type="saturate" values="0" in="ruido" result="gris" />
          <feComponentTransfer in="gris" result="suave">
            <feFuncA type="linear" slope={0.35} />
          </feComponentTransfer>
          <feComposite in="suave" in2="SourceGraphic" operator="in" />
        </filter>
        <radialGradient id="vineta" cx="0.5" cy="0.45" r="0.75">
          <stop offset="0.55" stopColor="#000" stopOpacity="0" />
          <stop offset="1" stopColor="#1a1400" stopOpacity="0.65" />
        </radialGradient>
      </defs>
      {/* Techo */}
      <polygon points="0,0 1080,0 780,640 300,640" fill="#ddd3a0" />
      {filas.map((u, k) => {
        const y = u * 640;
        const xl = 0 + 300 * u;
        const xr = 1080 - 300 * u;
        const w = (xr - xl) * 0.22;
        const h = 40 * (1 - u * 0.7);
        const encendida = k === 1 ? luz * (0.6 + 0.4 * Math.abs(Math.sin(s * 23))) : luz;
        return (
          <g key={k}>
            {[-1, 1].map((lado) => (
              <rect
                key={lado}
                x={540 + lado * (xr - xl) * 0.2 - w / 2}
                y={y - h / 2}
                width={w}
                height={h}
                fill="#fffbe8"
                opacity={encendida}
              />
            ))}
          </g>
        );
      })}
      {/* Paredes con papel pintado */}
      <polygon points="0,0 300,640 300,1080 0,1920" fill="url(#papel)" />
      <polygon points="0,0 300,640 300,1080 0,1920" fill="#000" opacity={0.12} />
      <polygon points="1080,0 780,640 780,1080 1080,1920" fill="url(#papel)" />
      <polygon points="1080,0 780,640 780,1080 1080,1920" fill="#000" opacity={0.12} />
      <rect x={300} y={640} width={480} height={440} fill="url(#papel)" />
      {/* Puerta al fondo con más salas */}
      <rect x={470} y={800} width={140} height={280} fill="#a99848" />
      <rect x={500} y={850} width={80} height={230} fill="#8f7f3a" />
      <rect x={520} y={890} width={40} height={190} fill="#6f6229" />
      {/* Suelo: moqueta */}
      <polygon points="0,1920 300,1080 780,1080 1080,1920" fill="#a8943f" />
      <polygon points="0,1920 300,1080 780,1080 1080,1920" fill="#a8943f" filter="url(#moqueta)" />
      {/* Rodapiés */}
      <line x1={300} y1={1080} x2={780} y2={1080} stroke="#8a7a33" strokeWidth={8} />
      <line x1={0} y1={1920} x2={300} y2={1080} stroke="#8a7a33" strokeWidth={8} />
      <line x1={1080} y1={1920} x2={780} y2={1080} stroke="#8a7a33" strokeWidth={8} />
      {/* Luz general que parpadea y viñeta */}
      <rect width={1080} height={1920} fill="#000" opacity={0.08 + parpadeo * 0.45} />
      <rect width={1080} height={1920} fill="url(#vineta)" />
    </svg>
  );
};

/** Criatura original: sombra alta y delgada con ojos brillantes. */
export const Criatura: React.FC<{ s: number; ancho?: number }> = ({ s, ancho = 200 }) => (
  <svg width={ancho} height={ancho * 2.1} viewBox="0 0 200 420">
    <g transform={`rotate(${Math.sin(s * 9) * 2} 100 400)`}>
      <path
        d="M100 30 C70 30 62 70 70 100 C40 120 30 200 44 300 L36 410 L60 410 L76 300 L100 320 L124 300 L140 410 L164 410 L156 300 C170 200 160 120 130 100 C138 70 130 30 100 30 Z"
        fill="#0b0904"
      />
      <path d="M70 120 C30 170 20 240 14 320" stroke="#0b0904" strokeWidth={14} strokeLinecap="round" fill="none" />
      <path d="M130 120 C170 170 180 240 186 320" stroke="#0b0904" strokeWidth={14} strokeLinecap="round" fill="none" />
      <ellipse cx={86} cy={70} rx={8} ry={5} fill="#f1f5ff" />
      <ellipse cx={114} cy={70} rx={8} ry={5} fill="#f1f5ff" />
      <path d="M80 92 Q100 104 120 92" stroke="#f1f5ff" strokeWidth={3} fill="none" opacity={0.8} />
    </g>
  </svg>
);
