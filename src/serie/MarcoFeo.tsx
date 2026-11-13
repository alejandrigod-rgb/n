/**
 * Marco definitivo (versión "congelado" elegida por el usuario, más feo): 10 años congelado desde 2016.
 * Piel verdosa con manchas de moho, setas creciendo en la gorra y el hombro, nariz roja por el frío, dientes torcidos,
 * ojeras, uniceja, barba con hielo y musgo y un moco congelado. Personaje original de la cuenta alternativa (no es de AEZ).
 */
import React from "react";
import "../marca/tema";

const L = "#1c1a22";
const PIEL = "#d5d9b8";
const PIEL_S = "#b3b893";
const MOHO = "#7fa04a";
const MOHO_O = "#4f6e2c";
const PELO = "#4e3626";
const PELO_S = "#33221a";
const SUD = "#c94a39";
const SUD_S = "#9b3529";
const VAQ = "#3d5a8a";
const GORRA = "#2b2f45";
const HIELO = "#cfeeff";

export type ExpresionMarco = "confuso" | "asco" | "susto" | "triste" | "dormido" | "ilusion";

/** Mancha de moho: círculo verde con borde peludo y puntitos. */
const Moho: React.FC<{ x: number; y: number; r: number }> = ({ x, y, r }) => (
  <g>
    <circle cx={x} cy={y} r={r} fill={MOHO} opacity={0.85} />
    <circle cx={x} cy={y} r={r} fill="none" stroke={MOHO_O} strokeWidth={2} strokeDasharray="2 3" />
    <circle cx={x - r * 0.3} cy={y - r * 0.2} r={r * 0.18} fill={MOHO_O} />
    <circle cx={x + r * 0.35} cy={y + r * 0.25} r={r * 0.14} fill={MOHO_O} />
    <circle cx={x + r * 0.1} cy={y - r * 0.45} r={r * 0.1} fill="#c8e08a" />
  </g>
);

/** Seta: pie crema y sombrero rojizo con lunares. */
const Seta: React.FC<{ x: number; y: number; s?: number; giro?: number }> = ({ x, y, s = 1, giro = 0 }) => (
  <g transform={`translate(${x} ${y}) rotate(${giro}) scale(${s})`}>
    <path d="M-6 0 Q-7 -14 -5 -22 H5 Q7 -14 6 0 Z" fill="#f2e6cc" stroke={L} strokeWidth={3} />
    <path d="M-20 -20 Q-18 -40 0 -42 Q18 -40 20 -20 Q0 -14 -20 -20 Z" fill="#c8553d" stroke={L} strokeWidth={3} />
    <circle cx={-8} cy={-30} r={3.5} fill="#f6eedd" />
    <circle cx={7} cy={-33} r={3} fill="#f6eedd" />
    <circle cx={1} cy={-24} r={2.5} fill="#f6eedd" />
  </g>
);

export const MarcoFeo: React.FC<{
  ancho?: number;
  boca?: number;
  expresion?: ExpresionMarco;
  /** Ángulo del brazo derecho (pantalla) en grados: 0 = abajo, 150 = arriba. */
  brazoD?: number;
  brazoI?: number;
  /** Lleva el móvil en la mano derecha. */
  movil?: boolean;
  /** 0-1: tiembla de frío. */
  tirita?: number;
  frame?: number;
}> = ({ ancho = 400, boca = 0, expresion = "confuso", brazoD = 0, brazoI = 0, movil = false, tirita = 0, frame = 0 }) => {
  const tx = tirita * Math.sin(frame * 2.1) * 3;
  const resp = Math.sin(frame / 18) * 2;
  const ojoGrande = expresion === "susto" ? 1.35 : expresion === "ilusion" ? 1.15 : 1;
  const bocaAbierta = Math.max(boca, expresion === "susto" ? 0.7 : expresion === "asco" ? 0.25 : 0);
  return (
    <svg width={ancho} height={ancho * 1.75} viewBox="0 0 400 700" style={{ overflow: "visible" }}>
      <g strokeLinejoin="round" strokeLinecap="round" transform={`translate(${tx} 0)`}>
        <ellipse cx={200} cy={688} rx={120} ry={14} fill="#000" opacity={0.18} />
        {/* Piernas y zapatillas */}
        <path d="M150 470 L140 650 L185 650 L195 500 Z" fill={VAQ} stroke={L} strokeWidth={7} />
        <path d="M250 470 L260 650 L215 650 L205 500 Z" fill={VAQ} stroke={L} strokeWidth={7} />
        <path d="M152 560 l12 18 M232 600 l10 -14" stroke="#2b4066" strokeWidth={5} />
        <path d="M128 646 L190 646 L194 676 L118 676 Q112 660 128 646 Z" fill="#e8e2d0" stroke={L} strokeWidth={7} />
        <path d="M272 646 L210 646 L206 676 L282 676 Q288 660 272 646 Z" fill="#e8e2d0" stroke={L} strokeWidth={7} />
        <Moho x={150} y={662} r={9} />
        {/* Brazo izquierdo (pantalla) */}
        <g transform={`rotate(${brazoI} 140 320)`}>
          <path d="M120 315 Q85 400 96 470 L128 470 Q126 410 150 345 Z" fill={SUD} stroke={L} strokeWidth={7} />
          <circle cx={112} cy={482} r={20} fill={PIEL} stroke={L} strokeWidth={7} />
          <Moho x={106} y={486} r={7} />
        </g>
        {/* Brazo derecho (pantalla), con móvil opcional */}
        <g transform={`rotate(${-brazoD} 260 320)`}>
          <path d="M280 315 Q315 400 304 470 L272 470 Q274 410 250 345 Z" fill={SUD} stroke={L} strokeWidth={7} />
          {movil ? (
            <g transform="translate(288 470) rotate(8)">
              <rect x={-26} y={-58} width={52} height={92} rx={8} fill="#22252f" stroke={L} strokeWidth={5} />
              <rect x={-20} y={-50} width={40} height={70} rx={3} fill="#9fd6ff" />
              <path d="M-14 -40 H14 M-14 -30 H8 M-14 -20 H12" stroke="#2f62b5" strokeWidth={4} />
              <path d="M-20 -50 L20 20" stroke="#fff" strokeWidth={2} opacity={0.6} />
            </g>
          ) : null}
          <circle cx={288} cy={482} r={20} fill={PIEL} stroke={L} strokeWidth={7} />
        </g>
        {/* Sudadera con moho y la seta del hombro */}
        <g transform={`translate(0 ${resp * 0.4})`}>
          <path d="M130 300 Q200 280 270 300 L262 490 Q200 505 138 490 Z" fill={SUD} stroke={L} strokeWidth={7} />
          <path d="M140 470 Q200 482 260 470" fill="none" stroke={SUD_S} strokeWidth={10} />
          <path d="M172 300 L176 360 M228 300 L224 360" stroke="#efe6d6" strokeWidth={5} />
          <path d="M160 410 H240 L232 450 H168 Z" fill={SUD_S} stroke={L} strokeWidth={5} />
          <text x={200} y={392} textAnchor="middle" fontFamily="'Baloo 2', sans-serif" fontWeight={800} fontSize={30} fill="#efe6d6">
            #YOLO
          </text>
          <Moho x={240} y={430} r={16} />
          <Moho x={156} y={330} r={11} />
          <Moho x={196} y={470} r={9} />
          <Seta x={262} y={306} s={0.9} giro={18} />
          <Seta x={276} y={318} s={0.6} giro={30} />
          {/* Auriculares de 2016 */}
          <path d="M150 300 Q200 330 250 300" fill="none" stroke="#2b2f45" strokeWidth={9} />
        </g>
        {/* Cuello */}
        <path d="M180 265 L180 298 L220 298 L220 265 Z" fill={PIEL_S} stroke={L} strokeWidth={6} />
        {/* Pelo largo de detrás, con musgo */}
        <path d="M106 140 Q92 262 126 334 L274 334 Q308 262 294 140 Z" fill={PELO_S} stroke={L} strokeWidth={7} />
        <Moho x={118} y={300} r={10} />
        <Moho x={286} y={286} r={8} />
        {/* Cabeza (un poco torcida) */}
        <g transform={`rotate(${expresion === "triste" ? -4 : 2} 200 200)`}>
          <path d="M116 152 Q114 68 202 64 Q286 70 284 152 L278 214 Q268 274 198 284 Q128 272 122 212 Z" fill={PIEL} stroke={L} strokeWidth={7} />
          {/* Orejas (una más grande) */}
          <ellipse cx={113} cy={180} rx={15} ry={24} fill={PIEL} stroke={L} strokeWidth={6} />
          <ellipse cx={287} cy={176} rx={19} ry={28} fill={PIEL} stroke={L} strokeWidth={6} />
          <Moho x={290} y={186} r={6} />
          {/* Manchas de moho y granos en la cara */}
          <Moho x={140} y={214} r={14} />
          <Moho x={252} y={110} r={9} />
          <circle cx={262} cy={214} r={6} fill="#e08a7a" stroke={L} strokeWidth={2} />
          <circle cx={176} cy={120} r={5} fill="#e08a7a" stroke={L} strokeWidth={2} />
          {/* Ojeras enormes */}
          <path d="M140 188 Q164 214 192 192 M210 194 Q238 216 262 190" fill="none" stroke="#8d8f6a" strokeWidth={9} opacity={0.7} />
          {/* Ojos (desiguales, con venitas) */}
          {expresion === "dormido" ? (
            <>
              <path d="M146 168 Q166 178 186 168" fill="none" stroke={L} strokeWidth={6} />
              <path d="M214 170 Q236 180 256 170" fill="none" stroke={L} strokeWidth={6} />
            </>
          ) : (
            <>
              <ellipse cx={166} cy={164} rx={22 * ojoGrande} ry={24 * ojoGrande} fill="#fffbe6" stroke={L} strokeWidth={5} />
              <ellipse cx={236} cy={168} rx={15 * ojoGrande} ry={16 * ojoGrande} fill="#fffbe6" stroke={L} strokeWidth={5} />
              <path d="M150 156 l8 4 M148 172 l9 -2 M252 162 l-6 4" stroke="#d9534f" strokeWidth={2} />
              <circle cx={expresion === "asco" ? 160 : 172} cy={expresion === "triste" ? 174 : 168} r={expresion === "susto" ? 5 : 8} fill={L} />
              <circle cx={expresion === "asco" ? 232 : 230} cy={expresion === "triste" ? 176 : 170} r={expresion === "susto" ? 4 : 6} fill={L} />
              {expresion === "ilusion" ? (
                <>
                  <circle cx={176} cy={162} r={3} fill="#fff" />
                  <circle cx={233} cy={165} r={2.5} fill="#fff" />
                </>
              ) : null}
            </>
          )}
          {/* Uniceja */}
          <path
            d={
              expresion === "triste"
                ? "M142 132 Q170 142 200 136 Q228 142 258 130"
                : expresion === "asco" || expresion === "susto"
                  ? "M140 124 Q170 110 200 126 Q230 112 258 124"
                  : "M140 132 Q170 120 200 132 Q230 122 258 134"
            }
            fill="none"
            stroke={PELO_S}
            strokeWidth={12}
          />
          {/* Nariz roja por el frío y moco congelado */}
          <path d="M196 172 Q182 206 200 214 Q218 210 206 176" fill="#e06a6a" stroke={L} strokeWidth={5} />
          <path d="M206 214 L210 236 L214 214 Z" fill={HIELO} stroke={L} strokeWidth={3} />
          {/* Barba con hielo y musgo */}
          <path d="M126 206 Q128 304 198 336 Q270 304 274 206 Q262 282 198 286 Q136 282 126 206 Z" fill={PELO} stroke={L} strokeWidth={6} />
          <path d="M170 242 Q186 232 200 240 Q214 232 230 242" fill="none" stroke={PELO} strokeWidth={9} />
          <path d="M150 292 l6 18 l6 -18 M232 294 l5 16 l5 -16 M190 324 l5 16 l5 -16" fill={HIELO} stroke={L} strokeWidth={3} />
          <Moho x={244} y={296} r={10} />
          <Moho x={160} y={304} r={7} />
          {/* Boca con dientes torcidos */}
          {bocaAbierta > 0.05 ? (
            <g>
              <path d={`M178 254 Q200 ${256 + bocaAbierta * 34} 224 254 Q200 246 178 254 Z`} fill="#4a1a24" stroke={L} strokeWidth={5} />
              <path d="M184 253 h8 v8 h-8 Z M196 251 h7 v10 h-7 Z M207 252 h9 v7 h-9 Z" fill="#e8d98a" stroke={L} strokeWidth={2} />
            </g>
          ) : expresion === "ilusion" ? (
            <g>
              <path d="M178 250 Q200 270 224 250 Z" fill="#4a1a24" stroke={L} strokeWidth={5} />
              <path d="M188 251 h8 v7 h-8 Z M204 251 h9 v8 h-9 Z" fill="#e8d98a" stroke={L} strokeWidth={2} />
            </g>
          ) : (
            <path d={expresion === "triste" ? "M180 262 Q200 248 222 260" : "M180 254 Q202 248 222 258"} fill="none" stroke={L} strokeWidth={6} />
          )}
          {/* Gorra plana de 2016 con setas y carámbanos */}
          <path d="M110 128 Q116 56 200 50 Q284 56 290 128 Z" fill={GORRA} stroke={L} strokeWidth={7} />
          <path d="M200 120 L342 120 Q352 132 338 140 L200 140 Z" fill={GORRA} stroke={L} strokeWidth={7} />
          <path d="M110 128 Q96 172 102 214 M290 128 Q304 172 298 214" fill="none" stroke={PELO} strokeWidth={14} />
          {[128, 156, 186, 216, 246, 300, 326].map((x, k) => (
            <path key={k} d={`M${x} ${k > 4 ? 140 : 128} L${x + 6} ${(k > 4 ? 158 : 148) + (k % 2) * 10} L${x + 12} ${k > 4 ? 140 : 128} Z`} fill={HIELO} stroke={L} strokeWidth={3} />
          ))}
          <Moho x={160} y={84} r={12} />
          <Seta x={232} y={60} s={1.1} giro={-8} />
          <Seta x={262} y={70} s={0.7} giro={14} />
          <Seta x={140} y={70} s={0.55} giro={-20} />
        </g>
        {/* Moscas zumbando */}
        {[0, 1].map((k) => (
          <g key={k} transform={`translate(${300 + Math.sin(frame / 7 + k * 3) * 30} ${80 + Math.cos(frame / 5 + k) * 20 + k * 40})`}>
            <ellipse cx={0} cy={0} rx={5} ry={4} fill={L} />
            <ellipse cx={-4} cy={-5} rx={4} ry={3} fill="#ffffff" opacity={0.7} />
            <ellipse cx={4} cy={-5} rx={4} ry={3} fill="#ffffff" opacity={0.7} />
          </g>
        ))}
      </g>
    </svg>
  );
};

/** Hoja de expresiones de Marco feo. */
export const ExpresionesMarco: React.FC = () => (
  <div style={{ width: 1800, height: 900, background: "#e9eef2", display: "flex", alignItems: "flex-end", justifyContent: "space-around", padding: 30, boxSizing: "border-box", fontFamily: "'Baloo 2', sans-serif" }}>
    {(["confuso", "asco", "susto", "triste", "ilusion", "dormido"] as ExpresionMarco[]).map((e, k) => (
      <div key={e} style={{ display: "flex", flexDirection: "column", alignItems: "center" }}>
        <MarcoFeo ancho={270} expresion={e} frame={k * 10} brazoD={k === 4 ? 140 : 0} movil={k === 2} />
        <div style={{ fontWeight: 800, fontSize: 34, color: "#1c1a22" }}>{e}</div>
      </div>
    ))}
  </div>
);
