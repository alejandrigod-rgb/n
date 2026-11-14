/**
 * Dibujos del video de la sartén (AEZ): la cocina de noche (fondo), la sartén con llamas, el corte por dentro
 * (aceite, gotas de agua que se hunden y vapor) y los objetos (vaso, tapa, botes). Mismo trazo que Nyxar.
 */
import React from "react";
import { AbsoluteFill, random } from "remotion";
import { C } from "../marca/tema";

const L = "#1d1530";
const W = 1080,
  H = 1920;

/** Cocina de noche con los colores de la marca: azulejos azul noche, armarios, ventana con luna y ciudad, nevera y fogones. */
export const CocinaNoche: React.FC<{ s: number }> = ({ s }) => (
  <AbsoluteFill>
    <svg width={W} height={H} viewBox={`0 0 ${W} ${H}`}>
      <defs>
        <radialGradient id="pared" cx="0.5" cy="0.35" r="0.9">
          <stop offset="0" stopColor="#15306a" />
          <stop offset="1" stopColor={C.abismo} />
        </radialGradient>
      </defs>
      <rect width={W} height={H} fill="url(#pared)" />
      {/* azulejos */}
      {Array.from({ length: 13 }, (_, i) => (
        <path key={`v${i}`} d={`M${i * 90} 560 V1260`} stroke="#ffffff10" strokeWidth={3} />
      ))}
      {Array.from({ length: 8 }, (_, j) => (
        <path key={`h${j}`} d={`M0 ${560 + j * 90} H${W}`} stroke="#ffffff10" strokeWidth={3} />
      ))}
      {/* ventana con luna y ciudad */}
      <rect x={380} y={600} width={320} height={300} rx={14} fill="#0b1c44" stroke={L} strokeWidth={10} />
      <circle cx={630} cy={670} r={34} fill="#f1f5ff" opacity={0.9} />
      {Array.from({ length: 6 }, (_, i) => (
        <rect key={i} x={390 + i * 52} y={800 - (i % 3) * 40} width={44} height={100 + (i % 3) * 40} fill="#14244f" />
      ))}
      {Array.from({ length: 10 }, (_, i) => (
        <rect key={`w${i}`} x={400 + (i % 6) * 52} y={820 - (i % 3) * 30 + Math.floor(i / 6) * 40} width={10} height={14} fill={C.cascabel} opacity={0.5 + 0.4 * Math.sin(s * 0.7 + i)} />
      ))}
      <path d="M540 600 V900 M380 750 H700" stroke={L} strokeWidth={8} />
      {/* armarios de arriba con tiradores menta */}
      <rect x={-10} y={180} width={1100} height={340} fill="#1b2f5c" stroke={L} strokeWidth={10} />
      {[0, 1, 2, 3].map((k) => (
        <g key={k}>
          <rect x={20 + k * 265} y={200} width={245} height={300} rx={10} fill="#22396d" stroke={L} strokeWidth={6} />
          <rect x={k % 2 ? 40 + k * 265 : 225 + k * 265} y={320} width={12} height={60} rx={6} fill={C.menta} opacity={0.8} />
        </g>
      ))}
      {/* ollas colgadas */}
      {[180, 860].map((x, k) => (
        <g key={x} transform={`rotate(${Math.sin(s * 1.2 + k) * 2} ${x} 540)`}>
          <path d={`M${x} 520 V560`} stroke={L} strokeWidth={5} />
          <circle cx={x} cy={610} r={50} fill="#3a4f80" stroke={L} strokeWidth={7} />
        </g>
      ))}
      {/* encimera, fogones y muebles de abajo */}
      <rect x={-10} y={1250} width={1100} height={60} fill="#2c4478" stroke={L} strokeWidth={10} />
      <rect x={-10} y={1310} width={1100} height={620} fill="#14244f" stroke={L} strokeWidth={10} />
      {[0, 1, 2, 3].map((k) => (
        <g key={k}>
          <rect x={20 + k * 265} y={1340} width={245} height={300} rx={10} fill="#1b2f5c" stroke={L} strokeWidth={6} />
          <rect x={120 + k * 265} y={1360} width={50} height={10} rx={5} fill={C.menta} opacity={0.7} />
        </g>
      ))}
      {/* nevera a la derecha, con imanes */}
      <rect x={880} y={560} width={220} height={690} rx={24} fill="#2a3f70" stroke={L} strokeWidth={9} />
      <path d="M880 860 H1100" stroke={L} strokeWidth={7} />
      <circle cx={940} cy={640} r={14} fill={C.panuelo} />
      <circle cx={990} cy={700} r={12} fill={C.cascabel} />
    </svg>
  </AbsoluteFill>
);

/** Llamas vivas: lenguas de fuego que bailan. `fuerza` 0-1 (0 = apagadas). */
export const Llamas: React.FC<{ s: number; fuerza: number; ancho?: number; alto?: number }> = ({ s, fuerza, ancho = 420, alto = 360 }) => {
  if (fuerza <= 0.01) return null;
  const lenguas = 7;
  return (
    <svg width={ancho} height={alto} viewBox="0 0 420 360" style={{ overflow: "visible" }}>
      <defs>
        <radialGradient id="halo">
          <stop offset="0" stopColor={C.cascabel} stopOpacity={0.55} />
          <stop offset="1" stopColor={C.cascabel} stopOpacity={0} />
        </radialGradient>
      </defs>
      <ellipse cx={210} cy={300} rx={260 * fuerza} ry={200 * fuerza} fill="url(#halo)" />
      {[
        ["#C2334D", 1],
        ["#FF7A3A", 0.78],
        [C.cascabel, 0.55],
        ["#FFF1B8", 0.3],
      ].map(([col, esc], capa) =>
        Array.from({ length: lenguas }, (_, i) => {
          const x = 40 + (i / (lenguas - 1)) * 340;
          const centro = 1 - Math.abs(i / (lenguas - 1) - 0.5) * 1.4;
          const h = (120 + 200 * centro + 40 * Math.sin(s * 9 + i * 1.7 + capa)) * (esc as number) * fuerza;
          const w = (52 + 20 * Math.sin(s * 7 + i)) * (0.6 + (esc as number) * 0.5);
          const bal = 18 * Math.sin(s * 6 + i * 2.3);
          return <path key={`${capa}-${i}`} d={`M${x - w / 2} 330 Q${x - w / 2} ${330 - h * 0.5} ${x + bal} ${330 - h} Q${x + w / 2} ${330 - h * 0.5} ${x + w / 2} 330 Z`} fill={col as string} />;
        }),
      )}
    </svg>
  );
};

/** Sartén de lado con su mango; `llamas` 0-1, `tapa` 0-1 (la tapa de metal entra desde arriba a la izquierda), `humo` 0-1. */
export const Sarten: React.FC<{ s: number; llamas: number; tapa?: number; humo?: number; ancho?: number }> = ({ s, llamas, tapa = 0, humo = 0, ancho = 760 }) => (
  <div style={{ position: "relative", width: ancho, height: ancho * 0.75 }}>
    <svg width={ancho} height={ancho * 0.75} viewBox="0 0 760 570" style={{ position: "absolute", left: 0, top: 0, overflow: "visible" }}>
      {/* humo cuando se apaga */}
      {humo > 0
        ? [0, 1, 2, 3].map((k) => {
            const t = (s * 0.6 + k * 0.25) % 1;
            return <circle key={k} cx={300 + Math.sin(s * 2 + k) * 40} cy={330 - t * 300} r={30 + t * 60} fill="#9aabc9" opacity={(1 - t) * 0.5 * humo} />;
          })
        : null}
      {/* fuego del fogón */}
      <ellipse cx={300} cy={540} rx={200} ry={22} fill={C.menta} opacity={0.25 + 0.1 * Math.sin(s * 10)} />
      {/* cuerpo de la sartén */}
      <path d="M90 400 L510 400 L480 500 Q300 530 120 500 Z" fill="#2b2f45" stroke={L} strokeWidth={12} />
      <ellipse cx={300} cy={400} rx={210} ry={40} fill="#3a3f5a" stroke={L} strokeWidth={10} />
      <ellipse cx={300} cy={402} rx={190} ry={30} fill="#e0a53a" />
      <ellipse cx={260} cy={396} rx={80} ry={8} fill="#fff1b8" opacity={0.6} />
      {/* mango */}
      <path d="M500 420 L740 380 Q756 378 756 394 L756 404 Q756 416 740 418 L510 452 Z" fill="#1b1e2d" stroke={L} strokeWidth={10} />
    </svg>
    <div style={{ position: "absolute", left: (90 / 760) * ancho, top: (60 / 570) * ancho * 0.75, width: (420 / 760) * ancho, height: (360 / 570) * ancho * 0.75 }}>
      <Llamas s={s} fuerza={llamas} ancho={(420 / 760) * ancho} alto={(360 / 570) * ancho * 0.75} />
    </div>
    {tapa > 0 ? (
      <svg width={ancho} height={ancho * 0.75} viewBox="0 0 760 570" style={{ position: "absolute", left: 0, top: 0, overflow: "visible" }}>
        <g transform={`translate(${(1 - tapa) * -420} ${(1 - tapa) * -320}) rotate(${(1 - tapa) * -30} 300 380)`}>
          <path d="M80 400 Q300 250 520 400 Z" fill="#9aa6b8" stroke={L} strokeWidth={12} />
          <path d="M140 372 Q300 290 460 372" fill="none" stroke="#dfe6ef" strokeWidth={10} opacity={0.7} />
          <rect x={270} y={290} width={60} height={30} rx={12} fill="#1b1e2d" stroke={L} strokeWidth={8} />
        </g>
      </svg>
    ) : null}
  </div>
);

/** Corte de la sartén por dentro: aceite caliente, gotas de agua que bajan (`gotas` 0-1) y burbujas de vapor que crecen (`vapor` 0-1). */
export const Corte: React.FC<{ s: number; gotas: number; vapor: number; llamas?: number }> = ({ s, gotas, vapor, llamas = 0.6 }) => (
  <div style={{ position: "relative", width: 860, height: 620 }}>
    <svg width={860} height={620} viewBox="0 0 860 620" style={{ position: "absolute", inset: 0, overflow: "visible" }}>
      <defs>
        <linearGradient id="aceite" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#ffcf5a" />
          <stop offset="1" stopColor="#c47a1a" />
        </linearGradient>
      </defs>
      {/* paredes de la sartén cortada */}
      <path d="M60 220 L120 560 L740 560 L800 220" fill="none" stroke="#3a3f5a" strokeWidth={30} strokeLinejoin="round" />
      <path d="M80 250 L132 540 L728 540 L780 250 Z" fill="url(#aceite)" />
      {/* ondas del aceite */}
      <path d={`M80 250 Q${200} ${240 + 6 * Math.sin(s * 4)} 320 250 T560 250 T780 250`} fill="none" stroke="#fff1b8" strokeWidth={6} opacity={0.7} />
      {/* gotas de agua azules: caen desde arriba y se hunden hasta el fondo */}
      {[230, 430, 600].map((x, k) => {
        const p = Math.max(0, Math.min(1, gotas * 1.3 - k * 0.15));
        if (p <= 0) return null;
        const y = 80 + p * 430;
        return (
          <g key={k} transform={`translate(${x} ${y})`} opacity={vapor > 0.25 ? 1 - vapor : 1}>
            <path d="M0 -36 Q26 0 22 14 Q14 34 0 34 Q-14 34 -22 14 Q-26 0 0 -36 Z" fill="#7fc8ff" stroke={L} strokeWidth={6} />
            <path d="M-8 -6 Q-12 6 -6 16" fill="none" stroke="#fff" strokeWidth={5} />
          </g>
        );
      })}
      {/* vapor: burbujas que crecen desde el fondo y empujan hacia arriba */}
      {vapor > 0
        ? Array.from({ length: 9 }, (_, i) => {
            const x = 180 + i * 62 + 20 * Math.sin(i * 3);
            const t = Math.min(1, vapor * 1.4 - (i % 3) * 0.12);
            if (t <= 0) return null;
            return <circle key={i} cx={x} cy={520 - t * 340 - 30 * Math.sin(s * 8 + i)} r={20 + t * 50} fill="#eef6ff" stroke="#9aabc9" strokeWidth={5} opacity={0.85} />;
          })
        : null}
    </svg>
    <div style={{ position: "absolute", left: 220, top: -150 }}>
      <Llamas s={s} fuerza={llamas} ancho={420} alto={360} />
    </div>
  </div>
);

/** Vaso de agua que se inclina (`giro` en grados). */
export const Vaso: React.FC<{ giro?: number; tamano?: number }> = ({ giro = 0, tamano = 220 }) => (
  <svg width={tamano} height={tamano * 1.3} viewBox="0 0 200 260" style={{ overflow: "visible", transform: `rotate(${giro}deg)` }}>
    <path d="M30 20 L170 20 L150 240 L50 240 Z" fill="#cfe9ff" fillOpacity={0.5} stroke={L} strokeWidth={10} strokeLinejoin="round" />
    <path d="M44 90 L156 90 L148 232 L52 232 Z" fill="#7fc8ff" />
    <path d="M60 40 L52 200" stroke="#fff" strokeWidth={8} strokeLinecap="round" opacity={0.7} />
  </svg>
);

/** Bote de cocina con etiqueta. */
export const Bote: React.FC<{ texto: string; color: string; tamano?: number }> = ({ texto, color, tamano = 260 }) => (
  <svg width={tamano} height={tamano * 1.3} viewBox="0 0 200 260" style={{ overflow: "visible" }}>
    <rect x={30} y={10} width={140} height={34} rx={10} fill={color} stroke={L} strokeWidth={9} />
    <rect x={20} y={40} width={160} height={210} rx={26} fill="#f1f5ff" stroke={L} strokeWidth={10} />
    <rect x={20} y={100} width={160} height={80} fill={color} stroke={L} strokeWidth={6} />
    <text x={100} y={152} textAnchor="middle" fontFamily="'Baloo 2', sans-serif" fontWeight={800} fontSize={texto.length > 8 ? 22 : 30} fill="#f1f5ff">
      {texto}
    </text>
    <path d="M40 60 L40 90" stroke="#ffffff" strokeWidth={8} strokeLinecap="round" opacity={0.7} />
  </svg>
);

/** Brasas que suben (partículas de fuego en el aire). */
export const Brasas: React.FC<{ s: number; fuerza: number; n?: number }> = ({ s, fuerza, n = 24 }) =>
  fuerza <= 0 ? null : (
    <AbsoluteFill style={{ pointerEvents: "none" }}>
      {Array.from({ length: n }, (_, i) => {
        const v = 60 + random(`bv${i}`) * 120;
        const y = 1300 - ((s * v + random(`by${i}`) * 1400) % 1400);
        const x = random(`bx${i}`) * 1080 + Math.sin(s * 2 + i) * 30;
        return <div key={i} style={{ position: "absolute", left: x, top: y, width: 8, height: 8, borderRadius: 4, background: i % 2 ? C.cascabel : "#FF7A3A", boxShadow: `0 0 12px ${C.cascabel}`, opacity: fuerza * 0.8 }} />;
      })}
    </AbsoluteFill>
  );
