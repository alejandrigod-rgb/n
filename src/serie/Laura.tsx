/**
 * Laura (serie de Marco, cuenta Marcoglowup, no AEZ): la chica de su vida. Rubia, ojos azules, muy guapa.
 * Mismo estilo que Marco (contorno grueso oscuro, colores planos). Hasta que aparece en persona, sale en silueta.
 * viewBox 400×700, cara centrada hacia (200, 180), igual que MarcoGordo.
 */
import React from "react";
import "../marca/tema";
import { MarcoGordo } from "./MarcoGordo";

const L = "#1c1a22";
const PIEL = "#f6d9c4";
const PIEL_S = "#e8bfa5";
const PELO = "#f3cf6b";
const PELO_S = "#d9a93f";
const PELO_B = "#fff1b8";
const OJO = "#3f8fe0";
const CHAQ = "#7fb0e0";
const CHAQ_S = "#5d8cc0";
const JERSEI = "#fbf3e6";

export type ExpresionLaura = "sonrisa" | "sorpresa" | "risa" | "seria" | "guino";

export const Laura: React.FC<{ ancho?: number; expresion?: ExpresionLaura; frame?: number; saluda?: boolean }> = ({ ancho = 400, expresion = "sonrisa", frame = 0, saluda = false }) => {
  const viento = Math.sin(frame / 20) * 4;
  const ojosAbiertos = expresion !== "risa";
  const pup = expresion === "sorpresa" ? 9 : 12;
  return (
    <svg width={ancho} height={ancho * 1.75} viewBox="0 0 400 700" style={{ overflow: "visible" }}>
      <g strokeLinejoin="round" strokeLinecap="round">
        <ellipse cx={200} cy={688} rx={110} ry={13} fill="#000" opacity={0.18} />
        {/* Melena de atrás, larga y ondulada */}
        <path d={`M112 150 Q86 260 ${100 + viento} 380 Q130 410 160 390 L240 390 Q270 410 ${300 + viento} 380 Q314 260 288 150 Z`} fill={PELO_S} stroke={L} strokeWidth={7} />
        {/* Piernas: vaqueros y zapatillas blancas */}
        <path d="M160 470 L152 650 L192 650 L198 500 Z" fill="#4a6fa8" stroke={L} strokeWidth={7} />
        <path d="M240 470 L248 650 L208 650 L202 500 Z" fill="#4a6fa8" stroke={L} strokeWidth={7} />
        <path d="M140 646 L194 646 L196 676 L132 676 Q126 660 140 646 Z" fill="#ffffff" stroke={L} strokeWidth={7} />
        <path d="M260 646 L206 646 L204 676 L268 676 Q274 660 260 646 Z" fill="#ffffff" stroke={L} strokeWidth={7} />
        {/* Brazos (chaqueta vaquera) */}
        <path d="M134 316 Q104 400 112 470 L140 470 Q140 410 158 350 Z" fill={CHAQ} stroke={L} strokeWidth={7} />
        <circle cx={126} cy={480} r={17} fill={PIEL} stroke={L} strokeWidth={6} />
        <g transform={`rotate(${saluda ? -140 + Math.sin(frame / 5) * 12 : 0} 262 322)`}>
          <path d="M266 316 Q296 400 288 470 L260 470 Q260 410 242 350 Z" fill={CHAQ} stroke={L} strokeWidth={7} />
          <circle cx={274} cy={480} r={17} fill={PIEL} stroke={L} strokeWidth={6} />
        </g>
        {/* Jersey crema y chaqueta vaquera abierta */}
        <path d="M150 300 Q200 286 250 300 L254 486 Q200 496 146 486 Z" fill={JERSEI} stroke={L} strokeWidth={7} />
        <path d="M140 304 Q160 296 176 298 L170 488 L140 484 Z" fill={CHAQ} stroke={L} strokeWidth={6} />
        <path d="M260 304 Q240 296 224 298 L230 488 L260 484 Z" fill={CHAQ} stroke={L} strokeWidth={6} />
        <path d="M148 380 H166 M234 380 H252" stroke={CHAQ_S} strokeWidth={5} />
        {/* Collar fino con una estrellita */}
        <path d="M184 300 Q200 324 216 300" fill="none" stroke="#d9a93f" strokeWidth={3} />
        <path d="M200 320 l3 6 l6 1 l-5 4 l1 6 l-5 -3 l-5 3 l1 -6 l-5 -4 l6 -1 Z" fill="#ffd34a" stroke={L} strokeWidth={2} />
        {/* Cuello */}
        <path d="M184 262 L184 300 L216 300 L216 262 Z" fill={PIEL_S} stroke={L} strokeWidth={6} />
        {/* Cara */}
        <path d="M128 160 Q126 84 200 78 Q274 84 272 160 Q272 228 236 260 Q200 284 164 260 Q128 228 128 160 Z" fill={PIEL} stroke={L} strokeWidth={7} />
        {/* Pendientes */}
        <circle cx={128} cy={200} r={6} fill="#ffd34a" stroke={L} strokeWidth={3} />
        <circle cx={272} cy={200} r={6} fill="#ffd34a" stroke={L} strokeWidth={3} />
        {/* Mejillas */}
        <ellipse cx={156} cy={210} rx={18} ry={10} fill="#ff9bb0" opacity={0.55} />
        <ellipse cx={244} cy={210} rx={18} ry={10} fill="#ff9bb0" opacity={0.55} />
        {/* Ojos azules grandes con pestañas */}
        {ojosAbiertos ? (
          [166, 234].map((x, k) =>
            expresion === "guino" && k === 1 ? (
              <path key={k} d="M216 176 Q234 164 252 176" fill="none" stroke={L} strokeWidth={6} />
            ) : (
              <g key={k}>
                <ellipse cx={x} cy={172} rx={20} ry={expresion === "sorpresa" ? 25 : 22} fill="#fff" stroke={L} strokeWidth={5} />
                <circle cx={x + 1} cy={175} r={pup + 2} fill={OJO} />
                <circle cx={x + 1} cy={175} r={pup - 5} fill="#16305a" />
                <circle cx={x - 5} cy={168} r={5} fill="#fff" />
                <circle cx={x + 6} cy={181} r={2.5} fill="#fff" />
                {/* pestañas */}
                <path d={k === 0 ? `M${x - 20} 162 l-9 -6 M${x - 14} 154 l-6 -8` : `M${x + 20} 162 l9 -6 M${x + 14} 154 l6 -8`} stroke={L} strokeWidth={4} />
              </g>
            ),
          )
        ) : (
          <>
            <path d="M148 176 Q166 162 184 176" fill="none" stroke={L} strokeWidth={6} />
            <path d="M216 176 Q234 162 252 176" fill="none" stroke={L} strokeWidth={6} />
          </>
        )}
        {/* Cejas finas */}
        <path d={expresion === "seria" ? "M146 140 Q166 136 186 142" : expresion === "sorpresa" ? "M146 132 Q166 122 186 132" : "M146 138 Q166 130 186 138"} fill="none" stroke={PELO_S} strokeWidth={5} />
        <path d={expresion === "seria" ? "M214 142 Q234 136 254 140" : expresion === "sorpresa" ? "M214 132 Q234 122 254 132" : "M214 138 Q234 130 254 138"} fill="none" stroke={PELO_S} strokeWidth={5} />
        {/* Nariz pequeña */}
        <path d="M198 196 Q194 210 202 212" fill="none" stroke={PIEL_S} strokeWidth={4} />
        {/* Boca */}
        {expresion === "sorpresa" ? (
          <ellipse cx={200} cy={236} rx={10} ry={13} fill="#a8324a" stroke={L} strokeWidth={4} />
        ) : expresion === "risa" ? (
          <g>
            <path d="M176 226 Q200 262 224 226 Z" fill="#a8324a" stroke={L} strokeWidth={4} />
            <path d="M180 228 H220" stroke="#fff" strokeWidth={6} />
          </g>
        ) : expresion === "seria" ? (
          <path d="M186 236 Q200 232 214 236" fill="none" stroke="#c4506a" strokeWidth={5} />
        ) : (
          <path d="M180 228 Q200 248 220 228" fill="none" stroke="#c4506a" strokeWidth={6} />
        )}
        {/* Flequillo y melena de delante, con brillos */}
        <path d={`M120 172 Q110 70 200 64 Q290 70 280 172 Q270 120 244 106 Q226 128 196 118 Q170 130 150 112 Q130 126 120 172 Z`} fill={PELO} stroke={L} strokeWidth={7} />
        <path d={`M122 160 Q104 240 ${118 + viento} 330 Q134 300 140 250 Q140 200 134 168 Z`} fill={PELO} stroke={L} strokeWidth={6} />
        <path d={`M278 160 Q296 240 ${282 + viento} 330 Q266 300 260 250 Q260 200 266 168 Z`} fill={PELO} stroke={L} strokeWidth={6} />
        <path d="M150 86 Q170 76 192 78 M236 90 Q254 98 262 112" fill="none" stroke={PELO_B} strokeWidth={6} />
        {/* Horquilla */}
        <rect x={238} y={104} width={26} height={8} rx={4} fill="#ff7aa8" stroke={L} strokeWidth={3} transform="rotate(-20 251 108)" />
      </g>
    </svg>
  );
};

/** Hoja de diseño de Laura: expresiones y comparación de tamaño con Marco. */
export const DisenoLaura: React.FC = () => (
  <div style={{ width: 2100, height: 1000, background: "#fdf2f5", display: "flex", alignItems: "flex-end", justifyContent: "space-around", padding: 30, boxSizing: "border-box", fontFamily: "'Baloo 2', sans-serif" }}>
    {(["sonrisa", "risa", "sorpresa", "guino", "seria"] as ExpresionLaura[]).map((e, k) => (
      <div key={e} style={{ display: "flex", flexDirection: "column", alignItems: "center" }}>
        <Laura ancho={280} expresion={e} frame={k * 10} saluda={k === 0} />
        <div style={{ fontWeight: 800, fontSize: 34, color: "#1c1a22" }}>{e === "guino" ? "guiño" : e}</div>
      </div>
    ))}
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center" }}>
      <div style={{ display: "flex", alignItems: "flex-end", gap: 0 }}>
        <MarcoGordo ancho={300} expresion="susto" frame={20} />
        <Laura ancho={270} expresion="sorpresa" frame={20} />
      </div>
      <div style={{ fontWeight: 800, fontSize: 34, color: "#1c1a22" }}>con Marco</div>
    </div>
  </div>
);
