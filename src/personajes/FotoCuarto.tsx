/**
 * Ilustración fija: Nyxar de cuerpo entero en su cuarto, con más detalle que el fondo de los videos.
 * Misma perspectiva que el Cuarto de los videos (punto de fuga en 540, 860; pared del fondo 300–780 × 640–1080).
 * Se renderiza con --scale=2 para tener 2160×3840.
 */
import { AbsoluteFill, random } from "remotion";
import { C, F } from "../marca/tema";
import { Nyxar, POSE_BASE } from "./Nyxar";

const LINEA = "#1d1530";

/** Puntos repartidos a lo largo de un segmento (para guirnaldas). */
const puntos = (x1: number, y1: number, x2: number, y2: number, n: number) =>
  new Array(n).fill(0).map((_, k) => {
    const t = (k + 0.5) / n;
    return [x1 + (x2 - x1) * t, y1 + (y2 - y1) * t + Math.sin(t * Math.PI * 6) * 6] as const;
  });

const Libro: React.FC<{ x: number; y: number; w: number; h: number; c: string; inclinado?: number }> = ({ x, y, w, h, c, inclinado = 0 }) => (
  <g transform={`rotate(${inclinado} ${x + w / 2} ${y + h})`}>
    <rect x={x} y={y} width={w} height={h} rx={3} fill={c} stroke={LINEA} strokeWidth={3} />
    <rect x={x + 3} y={y + h * 0.18} width={w - 6} height={4} fill="#ffffff55" />
    <rect x={x + 3} y={y + h * 0.75} width={w - 6} height={4} fill="#ffffff33" />
  </g>
);


/** Punto en la pared izquierda (t: 0 delante → 1 fondo; h: 0 suelo → 1 techo). Derecha con espejo. */
const pIzq = (t: number, h: number) => {
  const x = 300 * t;
  const arriba = 640 * t;
  const abajo = 1920 - 840 * t;
  return [x, abajo + (arriba - abajo) * h] as const;
};
const pDer = (t: number, h: number) => {
  const [x, y] = pIzq(t, h);
  return [1080 - x, y] as const;
};
const quad = (f: typeof pIzq, t1: number, t2: number, h1: number, h2: number) =>
  [f(t1, h1), f(t2, h1), f(t2, h2), f(t1, h2)].map((q) => q.join(",")).join(" ");

export const CuartoDetallado: React.FC = () => {
  const colores = [C.panuelo, C.menta, C.cascabel, C.azul, "#9b7fe0", "#ff8da1", C.niebla];
  return (
    <svg width={1080} height={1920} viewBox="0 0 1080 1920" style={{ position: "absolute", inset: 0 }}>
      <defs>
        <linearGradient id="fd-fondo" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#30245e" />
          <stop offset="1" stopColor="#251b4b" />
        </linearGradient>
        <linearGradient id="fd-izq" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0" stopColor="#1f173f" />
          <stop offset="1" stopColor="#2a2052" />
        </linearGradient>
        <linearGradient id="fd-der" x1="1" y1="0" x2="0" y2="0">
          <stop offset="0" stopColor="#1f173f" />
          <stop offset="1" stopColor="#2a2052" />
        </linearGradient>
        <linearGradient id="fd-suelo" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#3b2a4c" />
          <stop offset="1" stopColor="#4a3358" />
        </linearGradient>
        <linearGradient id="fd-cielo" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#0a1236" />
          <stop offset="1" stopColor="#2a2a6e" />
        </linearGradient>
        <radialGradient id="fd-lampara" cx="0.7" cy="0.52" r="0.45">
          <stop offset="0" stopColor="#ffb547" stopOpacity="0.38" />
          <stop offset="0.5" stopColor="#ffb547" stopOpacity="0.1" />
          <stop offset="1" stopColor="#ffb547" stopOpacity="0" />
        </radialGradient>
        <radialGradient id="fd-monitor" cx="0.62" cy="0.47" r="0.2">
          <stop offset="0" stopColor="#5ee7c4" stopOpacity="0.22" />
          <stop offset="1" stopColor="#5ee7c4" stopOpacity="0" />
        </radialGradient>
        <radialGradient id="fd-vineta" cx="0.5" cy="0.55" r="0.75">
          <stop offset="0.55" stopColor="#000" stopOpacity="0" />
          <stop offset="1" stopColor="#05030f" stopOpacity="0.7" />
        </radialGradient>
        <pattern id="fd-papel" width={40} height={40} patternUnits="userSpaceOnUse">
          <rect width={40} height={40} fill="none" />
          <circle cx={10} cy={10} r={2.2} fill="#ffffff10" />
          <circle cx={30} cy={30} r={2.2} fill="#ffffff10" />
        </pattern>
      </defs>

      {/* Techo y paredes */}
      <polygon points="0,0 1080,0 780,640 300,640" fill="#1a1336" />
      <polygon points="0,0 300,640 300,1080 0,1920" fill="url(#fd-izq)" />
      <polygon points="1080,0 780,640 780,1080 1080,1920" fill="url(#fd-der)" />
      <rect x={300} y={640} width={480} height={440} fill="url(#fd-fondo)" />
      <rect x={300} y={640} width={480} height={440} fill="url(#fd-papel)" />
      {/* Rodapiés */}
      <polygon points="300,1062 780,1062 780,1080 300,1080" fill="#1a1336" />
      <polygon points="0,1880 300,1062 300,1080 0,1920" fill="#1a1336" />
      <polygon points="1080,1880 780,1062 780,1080 1080,1920" fill="#1a1336" />

      {/* Suelo de madera */}
      <polygon points="0,1920 300,1080 780,1080 1080,1920" fill="url(#fd-suelo)" />
      {new Array(13).fill(0).map((_, k) => {
        const xb = 300 + (k * 480) / 12;
        const xf = -120 + (k * 1320) / 12;
        return <line key={k} x1={xb} y1={1080} x2={xf} y2={1920} stroke="#2e2140" strokeWidth={3} />;
      })}
      {[1150, 1260, 1420, 1640].map((y, k) => {
        const t = (y - 1080) / 840;
        const xl = 300 - 300 * t;
        const xr = 780 + 300 * t;
        return (
          <g key={y}>
            {new Array(6).fill(0).map((_, j) => {
              const x = xl + ((xr - xl) * (j + (k % 2) * 0.5 + 0.25)) / 6;
              return <line key={j} x1={x} y1={y} x2={x} y2={y + 10 + t * 30} stroke="#2e2140" strokeWidth={2} opacity={0.7} />;
            })}
          </g>
        );
      })}


      {/* Pegatinas de estrellas que brillan en el techo */}
      {[
        [300, 120], [460, 220], [620, 90], [760, 260], [540, 400], [380, 470], [700, 470], [220, 300], [860, 160],
      ].map(([x, y], k) => (
        <path key={k} transform={`translate(${x} ${y}) scale(${0.7 + (k % 3) * 0.25}) rotate(${k * 17})`} d="M0 -16 L4 -5 L16 -5 L6 2 L10 14 L0 7 L-10 14 L-6 2 L-16 -5 L-4 -5 Z" fill="#d8ffcf" opacity={0.55} />
      ))}
      {/* Lámpara colgante */}
      <line x1={540} y1={0} x2={540} y2={300} stroke="#120d26" strokeWidth={5} />
      <circle cx={540} cy={360} r={150} fill="#ffb547" opacity={0.08} />
      <path d="M480 300 H600 L630 360 H450 Z" fill="#3b2f6b" stroke={LINEA} strokeWidth={5} />
      <ellipse cx={540} cy={362} rx={40} ry={12} fill="#ffe1a8" />
      {/* Cuadro de Nyxar en píxeles en la pared izquierda */}
      <polygon points={quad(pIzq, 0.42, 0.7, 0.5, 0.74)} fill="#0e0b1f" stroke="#c9a46a" strokeWidth={8} strokeLinejoin="round" />
      <polygon points={quad(pIzq, 0.44, 0.68, 0.53, 0.72)} fill="#1b2d5a" />
      <polygon points={[pIzq(0.44, 0.53), pIzq(0.53, 0.66), pIzq(0.6, 0.6), pIzq(0.68, 0.69), pIzq(0.68, 0.53)].map((q) => q.join(",")).join(" ")} fill="#3aa77a" />
      <polygon points={[pIzq(0.5, 0.53), pIzq(0.58, 0.62), pIzq(0.66, 0.53)].map((q) => q.join(",")).join(" ")} fill="#2f8a64" />
      <ellipse cx={pIzq(0.6, 0.69)[0]} cy={pIzq(0.6, 0.69)[1]} rx={9} ry={16} fill="#f3e9c6" transform={`rotate(-20 ${pIzq(0.6, 0.69)[0]} ${pIzq(0.6, 0.69)[1]})`} />
      {/* Letrero de neón con huella en la pared derecha */}
      {(() => {
        const [cx, cy] = pDer(0.33, 0.72);
        return (
          <g transform={`translate(${cx} ${cy}) skewY(-25) scale(0.75 1)`}>
            {[18, 7].map((w, k) => (
              <g key={k} stroke={k ? "#fff0f6" : "#ff8da1"} strokeWidth={w} opacity={k ? 1 : 0.35} fill="none">
                <path d="M0 40 C26 40 44 62 42 78 C40 94 22 90 0 90 C-22 90 -40 94 -42 78 C-44 62 -26 40 0 40 Z" />
                <ellipse cx={-44} cy={20} rx={14} ry={18} />
                <ellipse cx={-16} cy={-6} rx={14} ry={18} />
                <ellipse cx={16} cy={-6} rx={14} ry={18} />
                <ellipse cx={44} cy={20} rx={14} ry={18} />
              </g>
            ))}
          </g>
        );
      })()}
      {/* Guirnalda de luces en el borde del techo */}
      <polyline points="0,0 300,640 780,640 1080,0" fill="none" stroke={C.menta} strokeWidth={6} opacity={0.6} />
      <polyline points="0,0 300,640 780,640 1080,0" fill="none" stroke={C.menta} strokeWidth={26} opacity={0.08} />
      {[...puntos(20, 40, 300, 640, 9), ...puntos(300, 640, 780, 640, 8), ...puntos(780, 640, 1060, 40, 9)].map(([x, y], k) => (
        <g key={k}>
          <circle cx={x} cy={y + 14} r={16} fill={[C.cascabel, C.menta, "#ff8da1"][k % 3]} opacity={0.18} />
          <circle cx={x} cy={y + 14} r={6} fill={[C.cascabel, C.menta, "#ff8da1"][k % 3]} />
        </g>
      ))}

      {/* Ventana con ciudad de noche */}
      <g>
        <rect x={322} y={690} width={200} height={210} rx={10} fill="url(#fd-cielo)" stroke="#120d26" strokeWidth={10} />
        <circle cx={480} cy={730} r={22} fill="#f3e9c6" />
        <circle cx={472} cy={724} r={22} fill="#0a1236" opacity={0.0} />
        {new Array(10).fill(0).map((_, k) => (
          <circle key={k} cx={335 + random(`ve${k}`) * 175} cy={700 + random(`vy${k}`) * 90} r={1.8} fill="#fff" opacity={0.6} />
        ))}
        {[
          [327, 820, 34, 75],
          [361, 790, 30, 105],
          [391, 835, 40, 60],
          [431, 800, 26, 95],
          [457, 825, 38, 70],
          [495, 805, 22, 90],
        ].map(([x, y, w, h], k) => (
          <g key={k}>
            <rect x={x} y={y} width={w} height={h} fill="#151a3d" />
            {new Array(6).fill(0).map((_, j) => (
              <rect key={j} x={x + 5 + (j % 2) * (w / 2 - 2)} y={y + 8 + Math.floor(j / 2) * 16} width={6} height={7} fill={random(`w${k}${j}`) > 0.45 ? "#ffd27a" : "#2a2f5a"} />
            ))}
          </g>
        ))}
        <line x1={422} y1={690} x2={422} y2={900} stroke="#120d26" strokeWidth={8} />
        <line x1={322} y1={790} x2={522} y2={790} stroke="#120d26" strokeWidth={8} />
        {/* Cortinas */}
        <path d="M306 676 C330 760 300 860 318 930 L346 930 C334 850 352 760 340 676 Z" fill="#6a4fb3" stroke={LINEA} strokeWidth={4} />
        <path d="M538 676 C514 760 544 860 526 930 L498 930 C510 850 492 760 504 676 Z" fill="#6a4fb3" stroke={LINEA} strokeWidth={4} />
        <rect x={296} y={668} width={252} height={12} rx={6} fill="#3a2a5e" />
        {/* Alféizar con planta pequeña */}
        <rect x={316} y={900} width={212} height={14} rx={4} fill="#3a2a5e" />
        <path d="M462 900 L468 878 H494 L500 900 Z" fill="#c2334d" stroke={LINEA} strokeWidth={3} />
        <path d="M481 878 C470 856 474 846 480 840 M481 878 C492 860 496 852 502 848 M481 878 C480 862 486 854 490 846" stroke="#4fbf8f" strokeWidth={6} fill="none" strokeLinecap="round" />
      </g>

      {/* Póster AEZ y reloj */}
      <g transform="translate(570 690)">
        <rect width={170} height={220} rx={10} fill="#0e0b1f" stroke={C.menta} strokeWidth={5} />
        <text x={85} y={92} textAnchor="middle" fontFamily={F.titulo} fontWeight={800} fontSize={64} fill={C.menta}>
          AEZ
        </text>
        <path d="M45 190 L60 130 L80 160 L100 160 L120 130 L135 190 Z" fill={C.pelaje} />
        <circle cx={78} cy={170} r={5} fill="#fff" />
        <circle cx={102} cy={170} r={5} fill="#fff" />
      </g>
      <g transform="translate(755 680)">
        <circle r={16} fill="#f1f5ff" stroke={LINEA} strokeWidth={4} />
        <line x1={0} y1={0} x2={0} y2={-10} stroke={LINEA} strokeWidth={3} strokeLinecap="round" />
        <line x1={0} y1={0} x2={8} y2={3} stroke={LINEA} strokeWidth={3} strokeLinecap="round" />
      </g>

      {/* Escritorio con monitor de código, teclado, taza y lámpara */}
      <g>
        <rect x={588} y={958} width={190} height={20} rx={6} fill="#6b4a33" stroke={LINEA} strokeWidth={4} />
        <rect x={600} y={978} width={14} height={100} fill="#523826" />
        <rect x={752} y={978} width={14} height={100} fill="#523826" />
        <rect x={622} y={872} width={116} height={74} rx={8} fill="#121a33" stroke={LINEA} strokeWidth={5} />
        <rect x={629} y={879} width={102} height={60} rx={4} fill="#0b1f2a" />
        {[0, 1, 2, 3, 4, 5].map((k) => (
          <rect key={k} x={634 + (k % 3 === 0 ? 0 : 8)} y={884 + k * 9} width={20 + random(`cod${k}`) * 60} height={4} rx={2} fill={[C.menta, C.cascabel, "#ff8da1", C.azul][k % 4]} />
        ))}
        <rect x={672} y={946} width={16} height={12} fill="#2b3350" />
        <rect x={640} y={951} width={80} height={9} rx={3} fill="#2b3350" stroke={LINEA} strokeWidth={2} />
        <rect x={732} y={940} width={18} height={18} rx={4} fill={C.panuelo} stroke={LINEA} strokeWidth={3} />
        <path d="M750 944 C758 944 758 954 750 954" fill="none" stroke={LINEA} strokeWidth={3} />
        <path d="M600 958 L604 920 L590 900" fill="none" stroke="#2b2244" strokeWidth={5} strokeLinecap="round" />
        <path d="M576 908 L604 892 L612 906 Z" fill={C.cascabel} stroke={LINEA} strokeWidth={3} />
        {/* Silla */}
        <path d="M640 1010 C640 980 720 980 720 1010 L716 1050 H644 Z" fill="#3b2f6b" stroke={LINEA} strokeWidth={4} />
        <rect x={676} y={1050} width={8} height={30} fill="#2b2244" />
        <path d="M650 1080 H710" stroke="#2b2244" strokeWidth={6} strokeLinecap="round" />
      </g>

      {/* Cama a la izquierda con manta, almohada y peluche */}
      <g>
        <polygon points="300,990 300,1085 96,1330 96,1200" fill="#4b3480" stroke={LINEA} strokeWidth={4} />
        <polygon points="96,1200 300,990 300,1050 96,1268" fill="#8a73d0" stroke={LINEA} strokeWidth={4} />
        <polygon points="130,1215 300,1040 300,1070 130,1250" fill="#a993e6" opacity={0.6} />
        <ellipse cx={252} cy={1040} rx={44} ry={20} transform="rotate(-42 252 1040)" fill="#f1f5ff" stroke={LINEA} strokeWidth={4} />
        {/* Peluche de ratón */}
        <g transform="translate(176 1150)">
          <ellipse cx={0} cy={0} rx={26} ry={18} fill={C.niebla} stroke={LINEA} strokeWidth={3} />
          <circle cx={-16} cy={-16} r={9} fill={C.niebla} stroke={LINEA} strokeWidth={3} />
          <circle cx={4} cy={-18} r={9} fill={C.niebla} stroke={LINEA} strokeWidth={3} />
          <circle cx={-20} cy={-2} r={3} fill={LINEA} />
          <path d="M26 4 C40 8 44 -4 54 2" stroke={LINEA} strokeWidth={3} fill="none" />
        </g>
        <polygon points="96,1330 96,1380 300,1130 300,1085" fill="#3a2766" />
      </g>

      {/* Estantería a la derecha con libros, juegos, trofeo y planta */}
      <g>
        <rect x={812} y={930} width={210} height={470} rx={8} fill="#5a3e2b" stroke={LINEA} strokeWidth={5} />
        <rect x={826} y={944} width={182} height={442} fill="#3a281c" />
        {[1050, 1160, 1270].map((y) => (
          <rect key={y} x={826} y={y} width={182} height={12} fill="#5a3e2b" />
        ))}
        {/* Balda 1: libros */}
        {new Array(7).fill(0).map((_, k) => (
          <Libro key={k} x={834 + k * 24} y={972 + (k % 3) * 8} w={20} h={78 - (k % 3) * 8} c={colores[k % colores.length]} inclinado={k === 6 ? 12 : 0} />
        ))}
        {/* Balda 2: cajas de juegos y mando */}
        {[0, 1, 2].map((k) => (
          <rect key={k} x={836 + k * 30} y={1082} width={26} height={78} rx={3} fill={["#2b3350", "#1b2d5a", "#3d1b33"][k]} stroke={LINEA} strokeWidth={3} />
        ))}
        <rect x={840} y={1094} width={18} height={8} fill={C.menta} />
        <rect x={870} y={1094} width={18} height={8} fill={C.cascabel} />
        <rect x={900} y={1094} width={18} height={8} fill="#ff8da1" />
        <path d="M940 1150 H996 C1006 1150 1010 1130 1000 1124 C994 1120 990 1126 986 1132 H950 C946 1126 942 1120 936 1124 C926 1130 930 1150 940 1150 Z" fill={C.cascabel} stroke={LINEA} strokeWidth={3} />
        {/* Balda 3: trofeo y figura */}
        <path d="M850 1262 H882 V1252 H876 V1236 C890 1232 892 1214 890 1200 H842 C840 1214 842 1232 856 1236 V1252 H850 Z" fill={C.cascabel} stroke={LINEA} strokeWidth={3} />
        <g transform="translate(930 1206)">
          <path d="M0 56 L6 18 L18 32 L32 32 L44 18 L50 56 Z" fill={C.pelaje} stroke={LINEA} strokeWidth={3} />
          <circle cx={18} cy={44} r={3} fill="#fff" />
          <circle cx={32} cy={44} r={3} fill="#fff" />
        </g>
        {/* Balda 4: cesta con ovillos */}
        <path d="M840 1330 H990 L980 1384 H850 Z" fill="#8a6a46" stroke={LINEA} strokeWidth={3} />
        <circle cx={880} cy={1322} r={20} fill={C.menta} stroke={LINEA} strokeWidth={3} />
        <circle cx={926} cy={1326} r={16} fill="#ff8da1" stroke={LINEA} strokeWidth={3} />
        <path d="M866 1312 C880 1330 890 1306 898 1328" stroke="#ffffff88" strokeWidth={2} fill="none" />
        {/* Planta encima */}
        <path d="M900 930 L906 896 H946 L952 930 Z" fill={C.panuelo} stroke={LINEA} strokeWidth={3} />
        {[-50, -20, 10, 40].map((a, k) => (
          <path key={k} d={`M926 896 Q${926 + a * 0.6} ${850 - k * 4} ${926 + a} ${830 - (k % 2) * 20}`} stroke="#4fbf8f" strokeWidth={9} fill="none" strokeLinecap="round" />
        ))}
      </g>

      {/* Planta grande en la esquina delantera izquierda */}
      <g>
        <path d="M60 1760 L84 1640 H220 L244 1760 Z" fill="#c2334d" stroke={LINEA} strokeWidth={6} />
        <rect x={74} y={1628} width={156} height={22} rx={8} fill="#a52a40" stroke={LINEA} strokeWidth={5} />
        {[
          [-90, 1440, -40],
          [-40, 1380, -15],
          [10, 1360, 5],
          [60, 1400, 25],
          [100, 1470, 45],
          [-110, 1530, -60],
        ].map(([dx, y, giro], k) => (
          <g key={k} transform={`rotate(${giro} 152 1630)`}>
            <path d={`M152 1630 Q${152 + dx * 0.4} ${(1630 + y) / 2} ${152 + dx * 0.2} ${y}`} stroke="#2f8a64" strokeWidth={6} fill="none" />
            <path d={`M${152 + dx * 0.2} ${y} C${152 + dx * 0.2 - 40} ${y + 40} ${152 + dx * 0.2 - 30} ${y + 110} ${152 + dx * 0.25} ${y + 130} C${152 + dx * 0.2 + 30} ${y + 110} ${152 + dx * 0.2 + 40} ${y + 40} ${152 + dx * 0.2} ${y} Z`} fill={k % 2 ? "#4fbf8f" : "#3aa77a"} stroke={LINEA} strokeWidth={4} />
            <path d={`M${152 + dx * 0.2} ${y + 10} L${152 + dx * 0.22} ${y + 118}`} stroke="#ffffff44" strokeWidth={3} />
          </g>
        ))}
      </g>

      {/* Alfombra redonda */}
      <ellipse cx={560} cy={1690} rx={420} ry={140} fill="#4a3a7a" stroke={LINEA} strokeWidth={5} />
      <ellipse cx={560} cy={1690} rx={340} ry={108} fill="none" stroke={C.menta} strokeWidth={8} opacity={0.5} />
      <ellipse cx={560} cy={1690} rx={250} ry={78} fill="none" stroke={C.cascabel} strokeWidth={5} opacity={0.35} strokeDasharray="18 14" />

      {/* Cosas en el suelo: puf, mando, ovillo, caja de juego */}
      <g>
        <path d="M800 1560 C760 1560 742 1620 760 1660 C780 1700 900 1710 950 1680 C990 1650 980 1580 940 1560 C900 1540 840 1545 800 1560 Z" fill="#c2334d" stroke={LINEA} strokeWidth={5} />
        <path d="M790 1580 C820 1600 900 1600 940 1576" stroke="#ffffff40" strokeWidth={5} fill="none" strokeLinecap="round" />
        <g transform="translate(655 1805) rotate(12)">
          <path d="M0 0 H70 C88 0 96 26 90 40 C84 54 70 50 62 40 H8 C0 50 -14 54 -20 40 C-26 26 -18 0 0 0 Z" fill={C.cascabel} stroke={LINEA} strokeWidth={4} />
          <path d="M6 14 V26 M0 20 H12" stroke={LINEA} strokeWidth={4} />
          <circle cx={62} cy={16} r={4} fill={LINEA} />
          <circle cx={72} cy={24} r={4} fill={LINEA} />
        </g>
        <circle cx={760} cy={1770} r={30} fill={C.menta} stroke={LINEA} strokeWidth={4} />
        <path d="M738 1756 C752 1780 770 1750 784 1772 M742 1786 C758 1770 776 1790 786 1780" stroke="#ffffff88" strokeWidth={3} fill="none" />
        <path d="M790 1772 C830 1790 860 1760 900 1800" stroke={C.menta} strokeWidth={4} fill="none" />
      </g>

      {/* Luz cálida de la lámpara, brillo del monitor y polvo flotando */}
      <rect width={1080} height={1920} fill="url(#fd-lampara)" />
      <rect width={1080} height={1920} fill="url(#fd-monitor)" />
      {new Array(26).fill(0).map((_, k) => (
        <circle key={k} cx={420 + random(`p${k}`) * 520} cy={760 + random(`q${k}`) * 700} r={1.5 + random(`r${k}`) * 2.5} fill="#ffe1a8" opacity={0.25 + random(`o${k}`) * 0.35} />
      ))}
    </svg>
  );
};

export const FotoCuarto: React.FC = () => {
  const pose = { ...POSE_BASE, brazoD: 148, brazoI: 22, cabeza: -5, mirarX: 0, mirarY: 0 };
  return (
    <AbsoluteFill style={{ background: C.abismo }}>
      <CuartoDetallado />
      {/* Sombra en la alfombra */}
      <svg width={1080} height={1920} style={{ position: "absolute", inset: 0 }}>
        <ellipse cx={545} cy={1752} rx={170} ry={30} fill="#0b0716" opacity={0.45} />
      </svg>
      <div style={{ position: "absolute", left: 540 - 250, top: 1150, width: 500 }}>
        <Nyxar ancho={500} pose={pose} boca={0.35} frame={0} fps={30} id="foto" expresion="feliz" parpadeo={0} />
      </div>
      {/* Viñeta */}
      <svg width={1080} height={1920} style={{ position: "absolute", inset: 0 }}>
        <defs>
          <radialGradient id="fc-vineta" cx="0.5" cy="0.55" r="0.78">
            <stop offset="0.6" stopColor="#000" stopOpacity="0" />
            <stop offset="1" stopColor="#05030f" stopOpacity="0.65" />
          </radialGradient>
        </defs>
        <rect width={1080} height={1920} fill="url(#fc-vineta)" />
      </svg>
    </AbsoluteFill>
  );
};
