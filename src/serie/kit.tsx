/** Kit de dibujo compartido por los episodios de la serie de Marco (cuenta Marcoglowup, no AEZ). */
import React from "react";
import { AbsoluteFill, interpolate } from "remotion";
import { MarcoGordo, type ExpresionGordo } from "./MarcoGordo";
import { AMARILLO, FUENTE, TINTA } from "./piezas";

const CL = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;
export type M = (p: string) => number;

/** Marca de una palabra, o un valor de reserva si Whisper no la encontró. */
export const marca = (m: M, p: string, def: number) => {
  try {
    return m(p);
  } catch {
    return def;
  }
};

/* ---------- ayudas de dibujo ---------- */

/** Marco (2026) colocado por la posición de su cara (cx, cy) en pantalla. */
export const MarcoEn: React.FC<{ cx: number; cy: number; ancho: number; expresion: ExpresionGordo; f: number; movil?: boolean; brazoD?: number; olor?: boolean }> = ({ cx, cy, ancho, f, ...p }) => (
  <div style={{ position: "absolute", left: cx - ancho / 2, top: cy - ancho * 0.45 }}>
    <MarcoGordo ancho={ancho} frame={f / 2} {...p} />
  </div>
);

export const Fondo: React.FC<{ a: string; b: string }> = ({ a, b }) => <AbsoluteFill style={{ background: `radial-gradient(circle at 50% 38%, ${a} 0%, ${b} 85%)` }} />;

/** Etiqueta con flecha (para señalar los granos y la papada). */
export const Etiqueta: React.FC<{ texto: string; x: number; y: number; ax: number; ay: number; f: number; giro?: number }> = ({ texto, x, y, ax, ay, f, giro = -4 }) => {
  if (f < 0) return null;
  const e = interpolate(f, [0, 5, 9], [0, 1.15, 1], CL);
  const p = interpolate(f, [0, 10], [0, 1], CL);
  return (
    <>
      <svg style={{ position: "absolute", left: 0, top: 0 }} width={1080} height={1920}>
        <line x1={x} y1={y} x2={x + (ax - x) * p} y2={y + (ay - y) * p} stroke={TINTA} strokeWidth={16} strokeLinecap="round" />
        <line x1={x} y1={y} x2={x + (ax - x) * p} y2={y + (ay - y) * p} stroke={AMARILLO} strokeWidth={7} strokeLinecap="round" />
        {p >= 1 ? <circle cx={ax} cy={ay} r={16} fill={AMARILLO} stroke={TINTA} strokeWidth={6} /> : null}
      </svg>
      <div style={{ position: "absolute", left: x, top: y, transform: `translate(-50%,-50%) rotate(${giro}deg) scale(${e})`, background: AMARILLO, border: `7px solid ${TINTA}`, borderRadius: 20, padding: "6px 24px 0", boxShadow: `0 8px 0 ${TINTA}` }}>
        <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 62, color: TINTA, whiteSpace: "nowrap" }}>{texto}</span>
      </div>
    </>
  );
};

/** Silueta de persona (Laura lleva coleta; su cara no se ve: es parte del misterio). */
export const Silueta: React.FC<{ ancho: number; color?: string; coleta?: boolean; mono?: boolean; ojos?: "normal" | "susto" | "feliz" | "enfado"; brazoArriba?: boolean }> = ({ ancho, color = "#3a2550", coleta = false, mono = false, ojos, brazoArriba = false }) => (
  <svg width={ancho} height={ancho * 2} viewBox="0 0 200 400" style={{ overflow: "visible" }}>
    <g fill={color} stroke={TINTA} strokeWidth={5} strokeLinejoin="round">
      {coleta ? <path d="M120 40 Q170 60 160 130 Q150 110 132 96 Z" /> : null}
      {mono ? <circle cx={100} cy={22} r={22} /> : null}
      <circle cx={100} cy={70} r={42} />
      <path d="M86 108 L114 108 L116 128 L84 128 Z" />
      <path d={coleta || mono ? "M60 130 Q100 118 140 130 L150 230 L172 330 L28 330 L50 230 Z" : "M54 130 Q100 116 146 130 L150 330 L50 330 Z"} />
      <path d="M62 136 Q36 190 44 250 L60 250 Q58 200 76 160 Z" />
      {brazoArriba ? <path d="M138 136 Q180 110 190 40 L174 34 Q162 96 124 120 Z" /> : <path d="M138 136 Q164 190 156 250 L140 250 Q142 200 124 160 Z" />}
      <path d="M76 330 L72 392 L92 392 L94 330 Z M106 330 L108 392 L128 392 L124 330 Z" />
    </g>
    {ojos === "feliz" ? (
      <path d="M76 70 Q86 58 96 70 M104 70 Q114 58 124 70" fill="none" stroke="#fff" strokeWidth={6} strokeLinecap="round" />
    ) : ojos ? (
      <g>
        <circle cx={84} cy={66} r={ojos === "susto" ? 14 : 10} fill="#fff" />
        <circle cx={116} cy={66} r={ojos === "susto" ? 14 : 10} fill="#fff" />
        <circle cx={84} cy={68} r={ojos === "susto" ? 4 : 5} fill={TINTA} />
        <circle cx={116} cy={68} r={ojos === "susto" ? 4 : 5} fill={TINTA} />
        {ojos === "enfado" ? <path d="M70 48 L98 58 M130 48 L102 58" stroke="#fff" strokeWidth={6} strokeLinecap="round" /> : null}
      </g>
    ) : null}
  </svg>
);

/** Móvil grande dibujado (genérico, sin marca). */
export const Movil: React.FC<{ children: React.ReactNode; top?: number; fondo?: string }> = ({ children, top = 170, fondo = "linear-gradient(180deg,#3b5ca8,#7a4fa8)" }) => (
  <div style={{ position: "absolute", left: 160, top, width: 760, height: 1000, background: "#1c1f2b", border: `10px solid ${TINTA}`, borderRadius: 70, padding: 26, boxSizing: "border-box", boxShadow: `0 18px 0 ${TINTA}` }}>
    <div style={{ width: "100%", height: "100%", borderRadius: 48, overflow: "hidden", background: fondo, position: "relative" }}>{children}</div>
  </div>
);

export const Noti: React.FC<{ quien: string; texto: string; color: string; f: number; y: number; numero?: number }> = ({ quien, texto, color, f, y, numero }) => {
  if (f < 0) return null;
  const e = interpolate(f, [0, 5, 9], [0.6, 1.06, 1], CL);
  const dx = interpolate(f, [0, 6], [-80, 0], CL);
  return (
    <div style={{ position: "absolute", left: 24, right: 24, top: y, height: 132, borderRadius: 30, background: "rgba(255,255,255,0.93)", display: "flex", alignItems: "center", gap: 20, padding: "0 22px", transform: `translateX(${dx}px) scale(${e})`, boxShadow: "0 6px 0 rgba(0,0,0,0.25)" }}>
      <div style={{ width: 84, height: 84, borderRadius: 42, background: color, border: `5px solid ${TINTA}`, flexShrink: 0, display: "flex", alignItems: "center", justifyContent: "center" }}>
        <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 50, color: "#fff", marginTop: 8 }}>{quien[0]}</span>
      </div>
      <div style={{ flex: 1, overflow: "hidden" }}>
        <div style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 40, color: TINTA, lineHeight: 1.1 }}>{quien}</div>
        <div style={{ fontFamily: "'Lexend', sans-serif", fontWeight: 600, fontSize: 30, color: "#4b4b5a", whiteSpace: "nowrap" }}>{texto}</div>
      </div>
      {numero ? (
        <div style={{ minWidth: 70, height: 70, borderRadius: 35, background: "#ff3b3b", display: "flex", alignItems: "center", justifyContent: "center", padding: "0 12px" }}>
          <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 40, color: "#fff", marginTop: 6 }}>{numero}</span>
        </div>
      ) : null}
    </div>
  );
};

/** Sello rojo que cae de golpe. */
export const Sello: React.FC<{ texto: string; f: number; x?: number; y?: number; giro?: number; tam?: number }> = ({ texto, f, x = 540, y = 820, giro = -14, tam = 130 }) =>
  f < 0 ? null : (
    <div style={{ position: "absolute", left: x, top: y, transform: `translate(-50%,-50%) rotate(${giro}deg) scale(${interpolate(f, [0, 5, 9], [3, 0.92, 1], CL)})`, border: "14px solid #ff2a2a", borderRadius: 24, padding: "14px 36px 0", background: "rgba(255,255,255,0.88)" }}>
      <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: tam, color: "#ff2a2a", whiteSpace: "nowrap" }}>{texto}</span>
    </div>
  );

/** Grano y viñeta de grabación antigua. */
export const GranoFilm: React.FC<{ f: number }> = ({ f }) => (
  <AbsoluteFill style={{ pointerEvents: "none" }}>
    <svg width={1080} height={1920} style={{ position: "absolute", opacity: 0.22, mixBlendMode: "overlay" }}>
      <filter id="grano">
        <feTurbulence type="fractalNoise" baseFrequency={0.85} numOctaves={2} seed={Math.floor(f / 3) % 20} />
      </filter>
      <rect width={1080} height={1920} filter="url(#grano)" />
    </svg>
    <AbsoluteFill style={{ background: "radial-gradient(circle at 50% 45%, transparent 45%, rgba(0,0,0,0.65) 100%)" }} />
    <div style={{ position: "absolute", left: 0, right: 0, top: (f * 9) % 1920, height: 6, background: "rgba(255,255,255,0.12)" }} />
  </AbsoluteFill>
);

/** Fachada de la casa de sus padres (puerta abierta o cerrada). */
export const Casa: React.FC<{ abierta: boolean }> = ({ abierta }) => (
  <>
    <AbsoluteFill style={{ background: "linear-gradient(180deg,#9fc7e8 0%,#d9ecf7 60%,#7c9b5a 60%,#5d7a40 100%)" }} />
    <div style={{ position: "absolute", left: 90, top: 470, width: 900, height: 700, background: "#f0d9b5", border: `10px solid ${TINTA}` }} />
    <div style={{ position: "absolute", left: 40, top: 220, width: 1000, height: 260, background: "#b8483a", border: `10px solid ${TINTA}`, clipPath: "polygon(50% 0,100% 100%,0 100%)" }} />
    <div style={{ position: "absolute", left: 150, top: 560, width: 200, height: 180, background: "#bfe3ff", border: `9px solid ${TINTA}` }} />
    <div style={{ position: "absolute", left: 730, top: 560, width: 200, height: 180, background: "#bfe3ff", border: `9px solid ${TINTA}` }} />
    <div style={{ position: "absolute", left: 420, top: 760, width: 240, height: 410, background: abierta ? "#2a1e18" : "#7a4a2a", border: `10px solid ${TINTA}` }}>
      {abierta ? null : <div style={{ position: "absolute", right: 26, top: 200, width: 30, height: 30, borderRadius: 15, background: AMARILLO, border: `5px solid ${TINTA}` }} />}
    </div>
  </>
);

/** Habitación del hostal: literas, papel despegado y el letrero. */
export const Hostal: React.FC = () => (
  <>
    <AbsoluteFill style={{ background: "linear-gradient(180deg,#8d9a7a 0%,#a7b18f 70%,#6e5a46 70%,#5a4838 100%)" }} />
    {[0, 1].map((k) => (
      <div key={k} style={{ position: "absolute", left: k ? 760 : 30, top: 560, width: 290, height: 820 }}>
        <div style={{ position: "absolute", left: 0, top: 0, width: 24, height: 820, background: "#5c6470", border: `5px solid ${TINTA}` }} />
        <div style={{ position: "absolute", right: 0, top: 0, width: 24, height: 820, background: "#5c6470", border: `5px solid ${TINTA}` }} />
        {[150, 560].map((y) => (
          <div key={y} style={{ position: "absolute", left: 10, right: 10, top: y, height: 70, background: "#d9d2c0", border: `6px solid ${TINTA}`, borderRadius: 10 }} />
        ))}
      </div>
    ))}
    <div style={{ position: "absolute", left: 230, top: 320, width: 620, height: 130, background: "#2b2440", border: `8px solid ${TINTA}`, borderRadius: 20, display: "flex", alignItems: "center", justifyContent: "center", boxShadow: "0 0 40px rgba(255,90,170,0.6)" }}>
      <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 74, color: "#ff7ac0", textShadow: "0 0 16px #ff4fa8", marginTop: 10, whiteSpace: "nowrap" }}>HOSTAL GRATIS</span>
    </div>
  </>
);

