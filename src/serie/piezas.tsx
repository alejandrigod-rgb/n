/**
 * Piezas compartidas de la serie de Marco (cuenta alternativa, no AEZ): subtítulos gigantes palabra a palabra,
 * onomatopeyas, contador de días, sello REC y cartas de votación. Sin emojis ni logos de apps reales.
 */
import React from "react";
import { interpolate, spring } from "remotion";
import "../marca/tema"; // Baloo 2
import type { Palabra } from "../marca/linea";

export const FUENTE = "'Baloo 2', sans-serif";
export const TINTA = "#141218";
export const AMARILLO = "#ffd400";
const CL = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;

const norm = (s: string) => s.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/[^a-z0-9]/g, "");

/** Texto con contorno grueso (el de los subtítulos grandes). */
export const Gordo: React.FC<{ children: React.ReactNode; tam: number; color?: string; borde?: number; style?: React.CSSProperties }> = ({ children, tam, color = "#fff", borde, style }) => (
  <span
    style={{
      fontFamily: FUENTE,
      fontWeight: 800,
      fontSize: tam,
      lineHeight: 1,
      color,
      WebkitTextStroke: `${borde ?? Math.round(tam * 0.16)}px ${TINTA}`,
      paintOrder: "stroke fill",
      textShadow: `0 ${Math.round(tam * 0.07)}px 0 ${TINTA}`,
      letterSpacing: -1,
      whiteSpace: "nowrap",
      ...style,
    }}
  >
    {children}
  </span>
);

/**
 * Subtítulo gigante de UNA palabra (la que se está diciendo), a dos tercios de la pantalla.
 * `t` = segundos desde que empieza la voz de la escena. Las palabras clave salen en amarillo.
 */
export const Subtitulo: React.FC<{ palabras: Palabra[]; t: number; fps: number; claves: string[]; cambiar?: Record<string, string>; y?: number; fin?: number }> = ({
  palabras,
  t,
  fps,
  claves,
  cambiar = {},
  y = 1250,
  fin,
}) => {
  let k = -1;
  for (let i = 0; i < palabras.length; i++) if (t >= palabras[i].ini - 0.03) k = i;
  if (k < 0) return null;
  const w = palabras[k];
  if (fin !== undefined && t > fin) return null;
  if (k === palabras.length - 1 && t > w.fin + 0.45) return null;
  const limpio = w.p.replace(/[.,:;!?¡¿…"]/g, "");
  const texto = (cambiar[norm(limpio)] ?? limpio).toUpperCase();
  const clave = claves.includes(norm(limpio)) || claves.includes(norm(texto));
  const tam = Math.min(clave ? 168 : 150, 960 / Math.max(1, texto.length * 0.6));
  const f = (t - w.ini) * fps;
  const s = spring({ frame: f, fps, config: { damping: 11, stiffness: 260, mass: 0.5 } });
  const esc = interpolate(s, [0, 1], [0.55, 1]);
  return (
    <div style={{ position: "absolute", left: 0, right: 0, top: y, display: "flex", justifyContent: "center", transform: `translateY(-50%) scale(${esc}) rotate(${clave ? -3 : 0}deg)` }}>
      <Gordo tam={tam} color={clave ? AMARILLO : "#fff"}>
        {texto}
      </Gordo>
    </div>
  );
};

/** Onomatopeya de cómic que entra de golpe y tiembla un poco. */
export const Ono: React.FC<{ texto: string; f: number; x: number; y: number; giro?: number; color?: string; tam?: number; dura?: number }> = ({ texto, f, x, y, giro = -10, color = AMARILLO, tam = 190, dura = 40 }) => {
  if (f < 0 || f > dura) return null;
  const e = interpolate(f, [0, 3, 6, Math.max(7, dura - 4), Math.max(8, dura)], [0.2, 1.25, 1, 1, 0], CL);
  const temb = Math.sin(f * 1.7) * 4;
  return (
    <div style={{ position: "absolute", left: x, top: y, transform: `translate(-50%,-50%) rotate(${giro + temb * 0.3}deg) scale(${e})` }}>
      <Gordo tam={tam} color={color} borde={Math.round(tam * 0.13)}>
        {texto}
      </Gordo>
    </div>
  );
};

/** Chapita del contador de días ("DÍA 0/30"), arriba a la izquierda (fuera de la interfaz de TikTok). */
export const ContadorDia: React.FC<{ dia: number; total?: number; f: number }> = ({ dia, total = 30, f }) => {
  const e = interpolate(f, [0, 6, 10], [0, 1.15, 1], CL);
  return (
    <div style={{ position: "absolute", left: 50, top: 210, transform: `scale(${e}) rotate(-4deg)`, transformOrigin: "left center", background: AMARILLO, border: `7px solid ${TINTA}`, borderRadius: 22, padding: "4px 26px 0", boxShadow: `0 9px 0 ${TINTA}` }}>
      <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 64, color: TINTA }}>
        DÍA {dia}
        <span style={{ opacity: 0.55 }}>/{total}</span>
      </span>
    </div>
  );
};

/** Sello de grabación de cámara antigua: punto rojo que parpadea, REC y la fecha. */
export const Rec: React.FC<{ f: number; fecha: string }> = ({ f, fecha }) => (
  <>
    <div style={{ position: "absolute", left: 70, top: 220, display: "flex", alignItems: "center", gap: 18 }}>
      <div style={{ width: 46, height: 46, borderRadius: 23, background: "#ff2a2a", opacity: Math.floor(f / 30) % 2 ? 0.15 : 1 }} />
      <span style={{ fontFamily: "'JetBrains Mono', monospace", fontWeight: 700, fontSize: 62, color: "#fff", textShadow: "0 0 8px #000" }}>REC</span>
    </div>
    <div style={{ position: "absolute", right: 150, top: 1560, fontFamily: "'JetBrains Mono', monospace", fontWeight: 700, fontSize: 52, color: "#fff", textShadow: "0 0 8px #000" }}>{fecha}</div>
    {/* esquinas del visor */}
    {[
      [60, 180, "0 0"],
      [1020, 180, "90"],
      [60, 1660, "-90"],
      [1020, 1660, "180"],
    ].map(([x, y, g], i) => (
      <div key={i} style={{ position: "absolute", left: (x as number) - 40, top: (y as number) - 40, width: 80, height: 80, transform: `rotate(${g === "0 0" ? 0 : g}deg)`, borderLeft: "8px solid #fff", borderTop: "8px solid #fff", opacity: 0.85 }} />
    ))}
  </>
);

/** Carta de votación (las dos del final). */
export const CartaVoto: React.FC<{ n: number; titulo: string; color: string; icono: React.ReactNode; f: number; giro: number; x: number }> = ({ n, titulo, color, icono, f, giro, x }) => {
  const e = interpolate(f, [0, 7, 12], [0, 1.12, 1], CL);
  const flota = Math.sin(f / 14 + n) * 8;
  return (
    <div
      style={{
        position: "absolute",
        left: x,
        top: 570 + flota,
        width: 430,
        height: 600,
        transform: `translateX(-50%) rotate(${giro}deg) scale(${e})`,
        background: color,
        border: `9px solid ${TINTA}`,
        borderRadius: 40,
        boxShadow: `0 16px 0 ${TINTA}`,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "space-between",
        padding: "28px 0 36px",
        boxSizing: "border-box",
      }}
    >
      <div style={{ width: 120, height: 120, borderRadius: 60, background: "#fff", border: `8px solid ${TINTA}`, display: "flex", alignItems: "center", justifyContent: "center" }}>
        <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 96, color: TINTA, marginTop: 14 }}>{n}</span>
      </div>
      {icono}
      <Gordo tam={titulo.length > 6 ? 84 : 100}>{titulo}</Gordo>
    </div>
  );
};

/** Corte seco con "punch" de cámara: escala que baja de 1.08 a 1 en los primeros fotogramas del plano. */
export const punch = (f: number) => interpolate(f, [0, 9], [1.08, 1], { ...CL, easing: (x) => 1 - (1 - x) ** 3 });
