/**
 * Marco (historia nueva, 13 de noviembre de 2026): lo echaron de casa en 2016 por no trabajar y en 2026 vive en un hostal gratis.
 * Muy gordo, con papada doble, granos, el pelo grasiento con entradas y una coleta de rata, pelusa de bigote,
 * y la sudadera "#YOLO" de 2016 que ya no le cierra (asoma la barriga). Personaje original de la cuenta alternativa (no es de AEZ).
 * Mismo encuadre que antes: viewBox 400×700 y la cara centrada hacia (200, 180).
 */
import React from "react";
import "../marca/tema";

const L = "#1c1a22";
const PIEL = "#efc6a4";
const PIEL_S = "#d6a582";
const ROJO = "#e98a7c";
const PELO = "#3d3122";
const PELO_S = "#2a2117";
const GRASA = "#a6b06a";
const SUD = "#c94a39";
const SUD_S = "#9b3529";
const VAQ = "#3d5a8a";

export type ExpresionGordo = "confuso" | "asco" | "susto" | "triste" | "dormido" | "ilusion" | "pena";

/** Grano: bulto rojo con la punta amarilla. */
const Grano: React.FC<{ x: number; y: number; r?: number }> = ({ x, y, r = 6 }) => (
  <g>
    <circle cx={x} cy={y} r={r * 1.6} fill={ROJO} opacity={0.55} />
    <circle cx={x} cy={y} r={r} fill="#e0675a" stroke={L} strokeWidth={2} />
    <circle cx={x - r * 0.15} cy={y - r * 0.2} r={r * 0.45} fill="#fff1a8" />
  </g>
);

/** Mancha de comida en la sudadera. */
const Mancha: React.FC<{ x: number; y: number; r: number; c?: string }> = ({ x, y, r, c = "#e3a43a" }) => (
  <path d={`M${x - r} ${y} Q${x - r} ${y - r} ${x} ${y - r * 0.8} Q${x + r * 1.2} ${y - r} ${x + r} ${y + r * 0.2} Q${x + r * 0.4} ${y + r} ${x - r * 0.3} ${y + r * 0.7} Q${x - r * 1.2} ${y + r * 0.6} ${x - r} ${y} Z`} fill={c} opacity={0.8} />
);

export const MarcoGordo: React.FC<{
  ancho?: number;
  boca?: number;
  expresion?: ExpresionGordo;
  /** Ángulo del brazo derecho (pantalla): 0 = abajo, 150 = arriba. */
  brazoD?: number;
  brazoI?: number;
  movil?: boolean;
  /** Olor (líneas verdes que suben). */
  olor?: boolean;
  frame?: number;
}> = ({ ancho = 400, boca = 0, expresion = "confuso", brazoD = 0, brazoI = 0, movil = false, olor = true, frame = 0 }) => {
  const resp = Math.sin(frame / 16) * 3;
  const ojo = expresion === "susto" ? 1.35 : expresion === "ilusion" ? 1.15 : 1;
  const bocaA = Math.max(boca, expresion === "susto" ? 0.75 : expresion === "asco" ? 0.25 : 0);
  return (
    <svg width={ancho} height={ancho * 1.75} viewBox="0 0 400 700" style={{ overflow: "visible" }}>
      <g strokeLinejoin="round" strokeLinecap="round">
        <ellipse cx={200} cy={688} rx={190} ry={16} fill="#000" opacity={0.2} />
        {/* Piernas cortas y gruesas */}
        <path d="M130 520 L126 652 L194 652 L198 540 Z" fill={VAQ} stroke={L} strokeWidth={7} />
        <path d="M270 520 L274 652 L206 652 L202 540 Z" fill={VAQ} stroke={L} strokeWidth={7} />
        <path d="M150 600 l14 14 M240 580 l12 -10" stroke="#2b4066" strokeWidth={5} />
        {/* Chanclas con calcetín */}
        <path d="M118 646 L198 646 L200 678 L106 678 Q100 660 118 646 Z" fill="#f2f0ea" stroke={L} strokeWidth={7} />
        <path d="M282 646 L202 646 L200 678 L294 678 Q300 660 282 646 Z" fill="#f2f0ea" stroke={L} strokeWidth={7} />
        <path d="M108 670 H200 M200 670 H292" stroke="#2f62b5" strokeWidth={7} />
        {/* Barriga que asoma por debajo de la sudadera */}
        <g transform={`translate(0 ${resp * 0.6})`}>
          <ellipse cx={200} cy={506} rx={168} ry={74} fill={PIEL} stroke={L} strokeWidth={7} />
          <path d="M196 508 q4 8 8 0" fill="none" stroke={L} strokeWidth={4} />
          <path d="M180 530 q4 -6 6 2 M214 526 q4 -6 6 2 M196 486 q3 -6 6 1" fill="none" stroke={PELO} strokeWidth={3} />
        </g>
        {/* Brazos rechonchos */}
        <g transform={`rotate(${brazoI} 78 340)`}>
          <path d="M84 322 Q20 410 34 496 L84 498 Q84 430 108 370 Z" fill={SUD} stroke={L} strokeWidth={7} />
          <circle cx={56} cy={508} r={28} fill={PIEL} stroke={L} strokeWidth={7} />
        </g>
        <g transform={`rotate(${-brazoD} 322 340)`}>
          <path d="M316 322 Q380 410 366 496 L316 498 Q316 430 292 370 Z" fill={SUD} stroke={L} strokeWidth={7} />
          {movil ? (
            <g transform="translate(346 496) rotate(8)">
              <rect x={-26} y={-60} width={52} height={92} rx={8} fill="#22252f" stroke={L} strokeWidth={5} />
              <rect x={-20} y={-52} width={40} height={70} rx={3} fill="#9fd6ff" />
              <path d="M-20 -52 L8 -20 L-6 0 L20 18" stroke="#fff" strokeWidth={2.5} fill="none" />
            </g>
          ) : null}
          <circle cx={344} cy={508} r={28} fill={PIEL} stroke={L} strokeWidth={7} />
        </g>
        {/* Sudadera #YOLO de 2016, que ya no le cierra */}
        <g transform={`translate(0 ${resp * 0.4})`}>
          <path d="M92 316 Q200 284 308 316 Q376 400 330 472 Q200 498 70 472 Q24 400 92 316 Z" fill={SUD} stroke={L} strokeWidth={7} />
          <path d="M78 464 Q200 490 322 464" fill="none" stroke={SUD_S} strokeWidth={10} />
          <path d="M176 312 L180 360 M224 312 L220 360" stroke="#efe6d6" strokeWidth={5} />
          <text x={200} y={404} textAnchor="middle" fontFamily="'Baloo 2', sans-serif" fontWeight={800} fontSize={36} fill="#efe6d6" transform="scale(1.15 1) translate(-26 0)">
            #YOLO
          </text>
          <Mancha x={150} y={430} r={14} />
          <Mancha x={262} y={356} r={10} c="#7a3b1e" />
          <Mancha x={236} y={440} r={8} c="#e3a43a" />
          {/* costura que revienta */}
          <path d="M300 420 l8 -6 l4 8 l8 -6" fill="none" stroke="#efe6d6" strokeWidth={3} />
        </g>
        {/* Cabeza */}
        <g transform={`rotate(${expresion === "triste" || expresion === "pena" ? -4 : 1} 200 200)`}>
          {/* Coleta de rata detrás */}
          <path d="M268 230 Q296 280 284 330 Q276 300 260 266 Z" fill={PELO_S} stroke={L} strokeWidth={5} />
          {/* Cara ancha */}
          <path d="M104 162 Q102 70 200 64 Q298 70 296 162 Q304 244 262 282 Q200 304 138 282 Q96 244 104 162 Z" fill={PIEL} stroke={L} strokeWidth={7} />
          {/* Papada doble */}
          <path d="M118 258 Q200 344 282 258 Q286 326 200 344 Q114 326 118 258 Z" fill={PIEL} stroke={L} strokeWidth={6} />
          <path d="M136 312 Q200 360 264 312 Q258 362 200 372 Q142 362 136 312 Z" fill={PIEL_S} stroke={L} strokeWidth={5} />
          {/* Orejas */}
          <ellipse cx={101} cy={182} rx={16} ry={24} fill={PIEL} stroke={L} strokeWidth={6} />
          <ellipse cx={299} cy={182} rx={16} ry={24} fill={PIEL} stroke={L} strokeWidth={6} />
          {/* Mofletes rojos */}
          <ellipse cx={138} cy={222} rx={26} ry={16} fill={ROJO} opacity={0.5} />
          <ellipse cx={262} cy={222} rx={26} ry={16} fill={ROJO} opacity={0.5} />
          {/* Granos */}
          <Grano x={150} y={108} r={6} />
          <Grano x={238} y={98} r={5} />
          <Grano x={268} y={208} r={7} />
          <Grano x={130} y={240} r={5} />
          <Grano x={210} y={276} r={6} />
          <Grano x={176} y={226} r={4} />
          <Grano x={252} y={240} r={4} />
          {/* Ojos pequeños y hundidos, con bolsas */}
          <path d="M140 186 Q164 206 190 188 M210 188 Q236 206 260 186" fill="none" stroke={PIEL_S} strokeWidth={8} />
          {expresion === "dormido" ? (
            <>
              <path d="M148 170 Q166 178 184 170" fill="none" stroke={L} strokeWidth={6} />
              <path d="M216 170 Q234 178 252 170" fill="none" stroke={L} strokeWidth={6} />
            </>
          ) : (
            <>
              <ellipse cx={166} cy={170} rx={14 * ojo} ry={12 * ojo} fill="#fffbe6" stroke={L} strokeWidth={5} />
              <ellipse cx={234} cy={172} rx={12 * ojo} ry={11 * ojo} fill="#fffbe6" stroke={L} strokeWidth={5} />
              <circle cx={expresion === "asco" ? 162 : 168} cy={expresion === "triste" || expresion === "pena" ? 175 : 171} r={expresion === "susto" ? 4 : 6} fill={L} />
              <circle cx={expresion === "asco" ? 230 : 232} cy={expresion === "triste" || expresion === "pena" ? 177 : 173} r={expresion === "susto" ? 4 : 5} fill={L} />
              {expresion === "ilusion" ? (
                <>
                  <circle cx={171} cy={167} r={2.5} fill="#fff" />
                  <circle cx={235} cy={169} r={2} fill="#fff" />
                </>
              ) : null}
              {expresion === "pena" ? <path d="M252 182 q6 14 0 22 q-6 -8 0 -22 Z" fill="#8fd0ff" stroke={L} strokeWidth={2} /> : null}
            </>
          )}
          {/* Uniceja */}
          <path
            d={
              expresion === "triste" || expresion === "pena"
                ? "M142 146 Q170 152 200 146 Q230 152 258 144"
                : expresion === "asco" || expresion === "susto"
                  ? "M142 138 Q170 124 200 140 Q230 126 258 138"
                  : "M142 148 Q170 136 200 146 Q230 136 258 148"
            }
            fill="none"
            stroke={PELO_S}
            strokeWidth={11}
          />
          {/* Nariz de patata con grano */}
          <path d="M188 182 Q170 214 192 222 Q200 226 210 222 Q232 214 212 182" fill={PIEL_S} stroke={L} strokeWidth={5} />
          <circle cx={190} cy={216} r={4} fill={L} />
          <circle cx={210} cy={216} r={4} fill={L} />
          <Grano x={206} y={198} r={5} />
          {/* Pelusa de bigote */}
          <path d="M176 234 l3 -4 M184 236 l2 -5 M192 237 l1 -5 M200 237 l0 -5 M208 237 l-1 -5 M216 236 l-2 -5 M224 234 l-3 -4" stroke={PELO} strokeWidth={3} />
          {/* Boca */}
          {bocaA > 0.05 ? (
            <g>
              <path d={`M180 250 Q200 ${252 + bocaA * 34} 222 250 Q200 242 180 250 Z`} fill="#4a1a24" stroke={L} strokeWidth={5} />
              <path d="M186 249 h8 v8 h-8 Z M198 247 h7 v10 h-7 Z M208 248 h8 v7 h-8 Z" fill="#e8d98a" stroke={L} strokeWidth={2} />
            </g>
          ) : expresion === "ilusion" ? (
            <path d="M180 248 Q200 268 222 248 Z" fill="#4a1a24" stroke={L} strokeWidth={5} />
          ) : (
            <path d={expresion === "triste" || expresion === "pena" ? "M182 258 Q200 246 220 258" : "M182 252 Q202 246 220 256"} fill="none" stroke={L} strokeWidth={6} />
          )}
          {/* Migas en la barbilla */}
          <path d="M170 276 l5 0 M226 282 l4 2 M196 290 l4 0" stroke="#d8a54a" strokeWidth={5} />
          {/* Pelo grasiento: raya en medio, entradas y mechones pegados */}
          <path d="M108 150 Q100 58 200 52 Q300 58 292 150 Q284 120 266 112 Q262 140 252 150 Q246 112 228 96 Q214 104 202 90 Q186 104 172 96 Q154 112 148 150 Q138 140 134 112 Q116 120 108 150 Z" fill={PELO} stroke={L} strokeWidth={7} />
          <path d="M202 58 L202 92" stroke={PELO_S} strokeWidth={5} />
          <path d="M150 74 Q140 100 142 130 M252 74 Q262 100 258 130 M176 64 Q170 84 172 98" fill="none" stroke={GRASA} strokeWidth={4} opacity={0.8} />
          {/* Remolino de pelo de punta */}
          <path d="M214 56 Q220 26 236 22 Q226 36 228 54" fill={PELO} stroke={L} strokeWidth={5} />
          {/* Gota de sudor */}
          <path d="M290 122 q8 14 0 22 q-8 -8 0 -22 Z" fill="#8fd0ff" stroke={L} strokeWidth={3} />
        </g>
        {/* Olor */}
        {olor
          ? [0, 1, 2].map((k) => {
              const y = 340 - ((frame * 1.2 + k * 40) % 120);
              return <path key={k} d={`M${60 + k * 140} ${y} q-10 -14 0 -28 q10 -14 0 -28`} fill="none" stroke="#8fae4a" strokeWidth={5} opacity={0.75 * (1 - ((frame * 1.2 + k * 40) % 120) / 120)} />;
            })
          : null}
        {/* Una mosca */}
        <g transform={`translate(${310 + Math.sin(frame / 7) * 30} ${90 + Math.cos(frame / 5) * 20})`}>
          <ellipse cx={0} cy={0} rx={5} ry={4} fill={L} />
          <ellipse cx={-4} cy={-5} rx={4} ry={3} fill="#ffffff" opacity={0.7} />
          <ellipse cx={4} cy={-5} rx={4} ry={3} fill="#ffffff" opacity={0.7} />
        </g>
      </g>
    </svg>
  );
};

/** Hoja de expresiones del Marco nuevo. */
export const ExpresionesGordo: React.FC = () => (
  <div style={{ width: 2100, height: 900, background: "#e9eef2", display: "flex", alignItems: "flex-end", justifyContent: "space-around", padding: 30, boxSizing: "border-box", fontFamily: "'Baloo 2', sans-serif" }}>
    {(["confuso", "asco", "susto", "triste", "pena", "ilusion", "dormido"] as ExpresionGordo[]).map((e, k) => (
      <div key={e} style={{ display: "flex", flexDirection: "column", alignItems: "center" }}>
        <MarcoGordo ancho={270} expresion={e} frame={k * 10} brazoD={k === 5 ? 140 : 0} movil={k === 2} />
        <div style={{ fontWeight: 800, fontSize: 34, color: "#1c1a22" }}>{e}</div>
      </div>
    ))}
  </div>
);
