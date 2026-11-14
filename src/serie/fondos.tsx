/**
 * Fondos detallados de la serie de Marco (cuenta Marcoglowup, no AEZ), todos de 1080×1920 y con el mismo trazo:
 * la casa de sus padres, el pasillo, la cocina, el baño y la calle. Reutilizables en todos los episodios.
 * `f` (fotograma) mueve las nubes, el humo y los detalles vivos.
 */
import React from "react";
import { AbsoluteFill, random } from "remotion";

const L = "#1c1a22";
const W = 1080,
  H = 1920;

const Nube: React.FC<{ x: number; y: number; s?: number }> = ({ x, y, s = 1 }) => (
  <g transform={`translate(${x} ${y}) scale(${s})`} fill="#fff" stroke={L} strokeWidth={6}>
    <path d="M0 40 Q0 0 40 4 Q60 -24 96 -4 Q130 -16 140 20 Q170 24 166 50 Q166 70 140 70 L20 70 Q0 68 0 40 Z" />
  </g>
);

const Flor: React.FC<{ x: number; y: number; c: string }> = ({ x, y, c }) => (
  <g>
    {[0, 72, 144, 216, 288].map((a) => (
      <circle key={a} cx={x + Math.cos((a * Math.PI) / 180) * 9} cy={y + Math.sin((a * Math.PI) / 180) * 9} r={7} fill={c} stroke={L} strokeWidth={2} />
    ))}
    <circle cx={x} cy={y} r={5} fill="#ffd34a" />
  </g>
);

const Arbusto: React.FC<{ x: number; y: number; w: number }> = ({ x, y, w }) => (
  <g stroke={L} strokeWidth={6}>
    <path d={`M${x} ${y} Q${x} ${y - w * 0.45} ${x + w * 0.25} ${y - w * 0.4} Q${x + w * 0.4} ${y - w * 0.7} ${x + w * 0.62} ${y - w * 0.45} Q${x + w} ${y - w * 0.5} ${x + w} ${y} Z`} fill="#5f9a4a" />
    <path d={`M${x + w * 0.2} ${y - w * 0.2} q10 -10 20 0 M${x + w * 0.6} ${y - w * 0.28} q10 -10 20 0`} fill="none" stroke="#86c06a" strokeWidth={5} />
  </g>
);

/** Fachada de la casa de sus padres: tejado de tejas, chimenea con humo, cortinas, macetas, valla, buzón y camino. */
export const Casa: React.FC<{ abierta: boolean; f?: number }> = ({ abierta, f = 0 }) => (
  <AbsoluteFill>
    <svg width={W} height={H} viewBox={`0 0 ${W} ${H}`}>
      <defs>
        <linearGradient id="cieloCasa" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#7fbbe8" />
          <stop offset="1" stopColor="#d9eef9" />
        </linearGradient>
      </defs>
      <rect width={W} height={H} fill="url(#cieloCasa)" />
      <circle cx={900} cy={160} r={70} fill="#ffe27a" stroke={L} strokeWidth={6} />
      <Nube x={60 + ((f * 0.4) % 1200) - 200} y={120} s={1.1} />
      <Nube x={600 + ((f * 0.25) % 1200) - 400} y={60} s={0.8} />
      {/* césped */}
      <rect y={1150} width={W} height={H - 1150} fill="#7cb35a" />
      {Array.from({ length: 40 }, (_, i) => (
        <path key={i} d={`M${random(`hx${i}`) * W} ${1200 + random(`hy${i}`) * 700} l6 -14 l6 14`} fill="none" stroke="#5f9a4a" strokeWidth={4} />
      ))}
      {/* chimenea con humo */}
      <rect x={760} y={240} width={80} height={170} fill="#a6463a" stroke={L} strokeWidth={8} />
      <rect x={748} y={226} width={104} height={30} fill="#8a3a30" stroke={L} strokeWidth={7} />
      {[0, 1, 2].map((k) => {
        const t = (f * 0.8 + k * 50) % 150;
        return <circle key={k} cx={800 + Math.sin((f + k * 40) / 20) * 14} cy={210 - t} r={20 + t * 0.15} fill="#e9eef2" stroke={L} strokeWidth={4} opacity={1 - t / 150} />;
      })}
      {/* paredes con listones */}
      <rect x={90} y={470} width={900} height={700} fill="#f0d9b5" stroke={L} strokeWidth={10} />
      {Array.from({ length: 13 }, (_, i) => (
        <path key={i} d={`M95 ${520 + i * 50} H985`} stroke="#dcc39c" strokeWidth={4} />
      ))}
      {/* tejado de tejas */}
      <path d="M40 480 L540 220 L1040 480 Z" fill="#b8483a" stroke={L} strokeWidth={10} />
      {Array.from({ length: 5 }, (_, i) => {
        const y = 270 + i * 45;
        const half = ((y - 220) / 260) * 500;
        return <path key={i} d={`M${540 - half} ${y} H${540 + half}`} stroke="#93372c" strokeWidth={5} />;
      })}
      {/* ventana redonda del desván */}
      <circle cx={540} cy={370} r={44} fill="#bfe3ff" stroke={L} strokeWidth={8} />
      <path d="M540 326 V414 M496 370 H584" stroke={L} strokeWidth={6} />
      {/* ventanas con cortinas y jardineras */}
      {[150, 730].map((x) => (
        <g key={x}>
          <rect x={x} y={560} width={200} height={180} fill="#bfe3ff" stroke={L} strokeWidth={9} />
          <path d={`M${x} ${560} Q${x + 40} ${640} ${x + 20} ${740} L${x} ${740} Z M${x + 200} ${560} Q${x + 160} ${640} ${x + 180} ${740} L${x + 200} ${740} Z`} fill="#f29bb4" stroke={L} strokeWidth={5} />
          <path d={`M${x + 100} 560 V740 M${x} 650 H${x + 200}`} stroke={L} strokeWidth={6} />
          <path d={`M${x + 30} 580 l40 -12`} stroke="#fff" strokeWidth={6} opacity={0.7} />
          <rect x={x - 14} y={744} width={228} height={44} fill="#a0663c" stroke={L} strokeWidth={7} />
          {[0, 1, 2, 3, 4].map((k) => (
            <Flor key={k} x={x + 10 + k * 45} y={740} c={k % 2 ? "#e86a7a" : "#f3a33a"} />
          ))}
        </g>
      ))}
      {/* puerta con marco, llamador y número */}
      <rect x={404} y={744} width={272} height={432} fill="#e9d7b6" stroke={L} strokeWidth={9} />
      <rect x={420} y={760} width={240} height={410} fill={abierta ? "#3a2a22" : "#7a4a2a"} stroke={L} strokeWidth={10} />
      {abierta ? (
        <>
          <rect x={430} y={770} width={220} height={390} fill="#e8d3a8" />
          {Array.from({ length: 6 }, (_, i) => (
            <path key={i} d={`M${440 + i * 38} 770 V1160`} stroke="#d8bf90" strokeWidth={10} />
          ))}
          <path d="M430 1060 H650 V1160 H430 Z" fill="#8a5a3a" />
        </>
      ) : (
        <>
          <rect x={448} y={790} width={80} height={150} rx={6} fill="none" stroke="#5e381f" strokeWidth={6} />
          <rect x={552} y={790} width={80} height={150} rx={6} fill="none" stroke="#5e381f" strokeWidth={6} />
          <rect x={448} y={980} width={184} height={150} rx={6} fill="none" stroke="#5e381f" strokeWidth={6} />
          <circle cx={630} cy={970} r={14} fill="#ffd34a" stroke={L} strokeWidth={5} />
          <circle cx={540} cy={880} r={22} fill="none" stroke="#ffd34a" strokeWidth={8} />
        </>
      )}
      <rect x={500} y={690} width={80} height={46} rx={8} fill="#fff" stroke={L} strokeWidth={6} />
      <text x={540} y={726} textAnchor="middle" fontFamily="'Baloo 2', sans-serif" fontWeight={800} fontSize={40} fill={L}>
        7
      </text>
      {/* felpudo y camino de piedras */}
      <rect x={430} y={1170} width={220} height={36} rx={8} fill="#c48a3a" stroke={L} strokeWidth={6} />
      {[
        [470, 1270, 70],
        [590, 1360, 80],
        [460, 1470, 90],
        [600, 1600, 100],
        [450, 1760, 120],
      ].map(([x, y, r], k) => (
        <ellipse key={k} cx={x} cy={y} rx={r} ry={r * 0.4} fill="#c9c2b4" stroke={L} strokeWidth={6} />
      ))}
      <Arbusto x={90} y={1176} w={260} />
      <Arbusto x={720} y={1176} w={270} />
      {/* buzón */}
      <rect x={880} y={1260} width={18} height={200} fill="#6b4a2e" stroke={L} strokeWidth={5} />
      <path d="M840 1200 Q840 1160 889 1160 Q938 1160 938 1200 L938 1268 L840 1268 Z" fill="#2f62b5" stroke={L} strokeWidth={7} />
      <rect x={930} y={1180} width={10} height={50} fill="#e0453b" stroke={L} strokeWidth={4} />
      {/* valla blanca delante */}
      {Array.from({ length: 11 }, (_, i) => (
        <path key={i} d={`M${i * 100 - 20} 1880 V1730 L${i * 100 + 10} 1700 L${i * 100 + 40} 1730 V1880 Z`} fill="#fbf6ec" stroke={L} strokeWidth={6} />
      ))}
      <rect x={-10} y={1760} width={W + 20} height={26} fill="#fbf6ec" stroke={L} strokeWidth={6} />
    </svg>
  </AbsoluteFill>
);

/** Pasillo de la casa: papel pintado de rayas, cuadros de la familia, perchero, lámpara y suelo de madera. */
export const Pasillo: React.FC = () => (
  <AbsoluteFill>
    <svg width={W} height={H} viewBox={`0 0 ${W} ${H}`}>
      <rect width={W} height={H} fill="#e9d9b8" />
      {Array.from({ length: 18 }, (_, i) => (
        <rect key={i} x={i * 64} y={0} width={30} height={1250} fill="#dcc89f" />
      ))}
      {/* friso */}
      <rect y={1050} width={W} height={200} fill="#8a6a4a" stroke={L} strokeWidth={8} />
      {Array.from({ length: 6 }, (_, i) => (
        <rect key={i} x={30 + i * 180} y={1080} width={140} height={140} fill="none" stroke="#6b4f36" strokeWidth={6} />
      ))}
      {/* suelo de madera */}
      <rect y={1250} width={W} height={H - 1250} fill="#b07a4a" />
      {Array.from({ length: 8 }, (_, i) => (
        <path key={i} d={`M0 ${1300 + i * 85} H${W}`} stroke="#8f5f38" strokeWidth={6} />
      ))}
      {/* cuadros */}
      <g stroke={L} strokeWidth={8}>
        <rect x={80} y={300} width={220} height={170} fill="#f6e8c8" />
        <rect x={100} y={320} width={180} height={130} fill="#9fcde8" />
        <path d="M100 450 L170 380 L220 420 L280 360 V450 Z" fill="#7cb35a" strokeWidth={4} />
        <rect x={800} y={260} width={180} height={230} fill="#c99a4a" />
        <rect x={820} y={280} width={140} height={190} fill="#f3e3c3" />
        {/* foto familiar de siluetas */}
        <circle cx={860} cy={360} r={18} fill="#6b5a4a" strokeWidth={0} />
        <circle cx={920} cy={350} r={20} fill="#6b5a4a" strokeWidth={0} />
        <circle cx={890} cy={400} r={13} fill="#6b5a4a" strokeWidth={0} />
        <path d="M836 470 Q860 380 884 470 Z M896 470 Q920 370 946 470 Z" fill="#6b5a4a" strokeWidth={0} />
      </g>
      {/* lámpara de techo */}
      <path d="M540 0 V120" stroke={L} strokeWidth={6} />
      <path d="M470 180 L500 120 H580 L610 180 Z" fill="#f6c95a" stroke={L} strokeWidth={7} />
      <ellipse cx={540} cy={200} rx={160} ry={60} fill="#fff3c0" opacity={0.35} />
      {/* perchero con abrigo */}
      <rect x={60} y={620} width={20} height={630} fill="#6b4a2e" stroke={L} strokeWidth={5} />
      <path d="M30 660 L110 640" stroke={L} strokeWidth={8} />
      <path d="M50 660 Q30 760 40 880 L120 880 Q130 760 100 660 Z" fill="#4f6f8f" stroke={L} strokeWidth={6} />
    </svg>
  </AbsoluteFill>
);

/** Cocina: azulejos, armarios, ventana, reloj, nevera con imanes y una sartén. `nota` pinta algo pegado en la nevera. */
export const Cocina: React.FC<{ f?: number; nota?: React.ReactNode }> = ({ f = 0, nota }) => (
  <AbsoluteFill>
    <svg width={W} height={H} viewBox={`0 0 ${W} ${H}`}>
      <rect width={W} height={H} fill="#f4efe2" />
      {Array.from({ length: 12 }, (_, i) =>
        Array.from({ length: 10 }, (_, j) => <rect key={`${i}-${j}`} x={i * 92} y={600 + j * 92} width={88} height={88} fill={(i + j) % 2 ? "#dff0ea" : "#ffffff"} />),
      )}
      {/* armarios de arriba */}
      <rect x={0} y={200} width={680} height={300} fill="#8fbf9f" stroke={L} strokeWidth={8} />
      {[0, 1, 2].map((k) => (
        <g key={k}>
          <rect x={20 + k * 220} y={220} width={200} height={260} fill="#a6d1b4" stroke={L} strokeWidth={6} />
          <rect x={160 + k * 220} y={330} width={14} height={50} rx={6} fill="#e0b84a" stroke={L} strokeWidth={3} />
        </g>
      ))}
      {/* reloj */}
      <circle cx={540} cy={110} r={64} fill="#fff" stroke={L} strokeWidth={8} />
      <path d={`M540 110 L${540 + Math.cos(f / 60) * 40} ${110 + Math.sin(f / 60) * 40} M540 110 L540 70`} stroke={L} strokeWidth={6} />
      {/* encimera */}
      <rect x={0} y={1180} width={720} height={60} fill="#d8cdb8" stroke={L} strokeWidth={8} />
      <rect x={0} y={1240} width={720} height={680} fill="#8fbf9f" stroke={L} strokeWidth={8} />
      {[0, 1, 2].map((k) => (
        <rect key={k} x={30 + k * 230} y={1290} width={200} height={300} fill="#a6d1b4" stroke={L} strokeWidth={6} />
      ))}
      {/* sartén y tarro */}
      <ellipse cx={180} cy={1170} rx={90} ry={22} fill="#2b2f45" stroke={L} strokeWidth={6} />
      <path d="M270 1166 L380 1150" stroke={L} strokeWidth={14} />
      <rect x={480} y={1080} width={90} height={100} rx={14} fill="#f3c46a" stroke={L} strokeWidth={6} />
      <rect x={470} y={1070} width={110} height={24} rx={8} fill="#e0453b" stroke={L} strokeWidth={5} />
      {/* nevera */}
      <rect x={740} y={380} width={320} height={1200} rx={30} fill="#eef3f6" stroke={L} strokeWidth={9} />
      <path d="M740 820 H1060" stroke={L} strokeWidth={7} />
      <rect x={770} y={600} width={18} height={140} rx={8} fill="#b8c4cc" stroke={L} strokeWidth={4} />
      <rect x={770} y={880} width={18} height={180} rx={8} fill="#b8c4cc" stroke={L} strokeWidth={4} />
      {[
        [830, 440, "#e0453b"],
        [990, 470, "#2f62b5"],
        [880, 1300, "#ffd34a"],
        [1000, 1200, "#7cb35a"],
      ].map(([x, y, c], k) => (
        <circle key={k} cx={x as number} cy={y as number} r={16} fill={c as string} stroke={L} strokeWidth={4} />
      ))}
      {/* suelo */}
      <rect y={1580} width={W} height={H - 1580} fill="#c9b48e" />
      {Array.from({ length: 6 }, (_, i) => (
        <path key={i} d={`M${i * 200} 1580 L${i * 200 - 120} ${H}`} stroke="#b09a72" strokeWidth={5} />
      ))}
    </svg>
    {nota}
  </AbsoluteFill>
);

/** Baño: azulejos, espejo, lavabo, toalla, planta, váter y alfombrilla. */
export const Bano: React.FC = () => (
  <AbsoluteFill>
    <svg width={W} height={H} viewBox={`0 0 ${W} ${H}`}>
      <rect width={W} height={H} fill="#e4f2f6" />
      {Array.from({ length: 12 }, (_, i) =>
        Array.from({ length: 14 }, (_, j) => <rect key={`${i}-${j}`} x={i * 92 + 2} y={j * 92 + 2} width={88} height={88} fill={j > 8 ? "#bfe0ea" : "#f2fafc"} stroke="#cfe3ea" strokeWidth={3} />),
      )}
      {/* espejo y lavabo */}
      <rect x={60} y={300} width={260} height={340} rx={30} fill="#d8f1fb" stroke={L} strokeWidth={9} />
      <path d="M100 360 L180 320 M100 420 L240 340" stroke="#fff" strokeWidth={10} />
      <path d="M50 780 H330 Q330 880 190 880 Q50 880 50 780 Z" fill="#fff" stroke={L} strokeWidth={8} />
      <rect x={170} y={880} width={40} height={300} fill="#fff" stroke={L} strokeWidth={7} />
      <path d="M170 740 V700 Q170 680 200 680 H220" fill="none" stroke="#9aa6ad" strokeWidth={12} />
      {/* toalla */}
      <rect x={820} y={300} width={200} height={14} rx={7} fill="#9aa6ad" stroke={L} strokeWidth={4} />
      <path d="M840 310 H1000 V600 Q920 620 840 600 Z" fill="#f29bb4" stroke={L} strokeWidth={7} />
      <path d="M840 560 H1000" stroke="#fff" strokeWidth={10} />
      {/* planta */}
      <path d="M900 1060 L940 1060 L950 1140 L890 1140 Z" fill="#c4704a" stroke={L} strokeWidth={6} />
      {[-40, -15, 10, 35].map((a, k) => (
        <ellipse key={k} cx={920 + Math.sin((a * Math.PI) / 180) * 50} cy={1000 - Math.cos((a * Math.PI) / 180) * 40} rx={18} ry={50} fill="#5f9a4a" stroke={L} strokeWidth={5} transform={`rotate(${a} ${920 + Math.sin((a * Math.PI) / 180) * 50} ${1000 - Math.cos((a * Math.PI) / 180) * 40})`} />
      ))}
      {/* váter */}
      <rect x={800} y={1180} width={200} height={220} rx={20} fill="#fff" stroke={L} strokeWidth={8} />
      <path d="M780 1400 H1020 Q1020 1520 900 1530 Q780 1520 780 1400 Z" fill="#fff" stroke={L} strokeWidth={8} />
      {/* suelo y alfombrilla */}
      <rect y={1560} width={W} height={H - 1560} fill="#9fb7c0" />
      <rect x={260} y={1600} width={560} height={140} rx={60} fill="#7fb0e0" stroke={L} strokeWidth={7} />
      <rect x={290} y={1625} width={500} height={90} rx={45} fill="none" stroke="#fff" strokeWidth={5} strokeDasharray="14 12" />
    </svg>
  </AbsoluteFill>
);

/** Calle del barrio: edificios al fondo, árboles, farolas, acera y carretera. `avance` desplaza el decorado (caminar). */
export const Calle: React.FC<{ avance?: number; f?: number; tarde?: boolean }> = ({ avance = 0, f = 0, tarde = false }) => (
  <AbsoluteFill>
    <svg width={W} height={H} viewBox={`0 0 ${W} ${H}`}>
      <defs>
        <linearGradient id="cieloCalle" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor={tarde ? "#ff9a5a" : "#7fbbe8"} />
          <stop offset="1" stopColor={tarde ? "#ffd9a0" : "#d9eef9"} />
        </linearGradient>
      </defs>
      <rect width={W} height={H} fill="url(#cieloCalle)" />
      <Nube x={100 + ((f * 0.3) % 1300) - 300} y={150} />
      {/* edificios del fondo */}
      <g transform={`translate(${-(avance * 0.3) % 600} 0)`}>
        {Array.from({ length: 8 }, (_, i) => {
          const x = i * 300 - 300,
            h = 380 + random(`ed${i}`) * 300,
            col = ["#c98a6a", "#e0b48a", "#a8b4c8", "#d6c08a"][i % 4];
          return (
            <g key={i}>
              <rect x={x} y={1100 - h} width={260} height={h} fill={col} stroke={L} strokeWidth={7} />
              {Array.from({ length: Math.floor(h / 110) }, (_, r) =>
                [0, 1, 2].map((c) => <rect key={`${r}-${c}`} x={x + 30 + c * 75} y={1100 - h + 40 + r * 110} width={50} height={64} fill="#ffeaa0" stroke={L} strokeWidth={4} opacity={random(`v${i}${r}${c}`) > 0.4 ? 1 : 0.4} />),
              )}
            </g>
          );
        })}
      </g>
      {/* acera */}
      <rect y={1100} width={W} height={300} fill="#cfc8bb" />
      {Array.from({ length: 10 }, (_, i) => (
        <path key={i} d={`M${i * 160 - ((avance * 1) % 160)} 1100 V1400`} stroke="#b5ad9e" strokeWidth={5} />
      ))}
      <rect y={1396} width={W} height={24} fill="#9a9284" stroke={L} strokeWidth={5} />
      {/* carretera */}
      <rect y={1420} width={W} height={H - 1420} fill="#4d5058" />
      {Array.from({ length: 7 }, (_, i) => (
        <rect key={i} x={i * 220 - ((avance * 1.4) % 220)} y={1640} width={120} height={20} fill="#f2f0ea" />
      ))}
      {/* árboles y farolas delante */}
      <g transform={`translate(${-(avance * 1) % 700} 0)`}>
        {[0, 700, 1400].map((x) => (
          <g key={x}>
            <rect x={x + 120} y={760} width={40} height={380} fill="#7a5233" stroke={L} strokeWidth={6} />
            <circle cx={x + 140} cy={700} r={150} fill="#5f9a4a" stroke={L} strokeWidth={7} />
            <circle cx={x + 80} cy={660} r={30} fill="#86c06a" />
            <rect x={x + 470} y={600} width={20} height={520} fill="#3b4450" stroke={L} strokeWidth={5} />
            <path d={`M${x + 480} 610 Q${x + 480} 560 ${x + 540} 560`} fill="none" stroke="#3b4450" strokeWidth={14} />
            <path d={`M${x + 520} 560 h50 l-10 30 h-30 Z`} fill="#ffe27a" stroke={L} strokeWidth={5} />
          </g>
        ))}
      </g>
    </svg>
  </AbsoluteFill>
);
