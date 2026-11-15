/**
 * Textos animados de la serie de Marco (mismas reglas que pidió el usuario para el video del Test Epigenético):
 * `TituloEntra` entra desde la izquierda con ease-in-out y estela de movimiento (y puede salir por la derecha);
 * `Revela` muestra un texto desde una máscara. Tiempos en segundos LOCALES de la escena.
 */
import React from "react";
import { Easing, interpolate } from "remotion";
import { AMARILLO, FUENTE, TINTA } from "./piezas";

const CL = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;
const io = Easing.inOut(Easing.cubic);
const FPS = 60;

export const TituloEntra: React.FC<{ s: number; desde: number; hasta?: number; y: number; tam?: number; children: React.ReactNode }> = ({ s, desde, hasta, y, tam = 110, children }) => {
  const dur = 0.6;
  const pos = (tt: number) => {
    const entra = -1300 * (1 - interpolate(tt, [desde, desde + dur], [0, 1], { ...CL, easing: io }));
    const va = hasta === undefined ? 0 : 1400 * interpolate(tt, [hasta - dur * 0.7, hasta], [0, 1], { ...CL, easing: Easing.in(Easing.cubic) });
    return entra + va;
  };
  if (s < desde && desde >= 0) return null;
  const x = pos(s);
  const v = (x - pos(s - 1 / FPS)) * FPS;
  const estela = Math.min(1, Math.abs(v) / 3000);
  const capa = (op: number, dx: number, k: number) => (
    <div key={k} style={{ position: "absolute", left: 0, right: 0, top: y, display: "flex", justifyContent: "center", transform: `translateX(${x - dx}px) skewX(${-v / 600}deg) rotate(-3deg)`, opacity: op, filter: estela > 0.05 ? `blur(${estela * 6}px)` : undefined }}>
      <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: tam, lineHeight: 1, color: "#fff", WebkitTextStroke: `${Math.round(tam * 0.15)}px ${TINTA}`, paintOrder: "stroke fill", textShadow: `0 ${Math.round(tam * 0.07)}px 0 ${TINTA}`, whiteSpace: "nowrap" }}>{children}</span>
    </div>
  );
  return (
    <>
      {estela > 0.05 ? [4, 3, 2, 1].map((k) => capa(0.14 * estela, (v / FPS) * k * 1.6, k)) : null}
      {capa(1, 0, 0)}
    </>
  );
};

/** Texto en una placa que se revela desde una máscara (la placa se abre desde el centro y el texto sube). */
export const Revela: React.FC<{ s: number; desde: number; y: number; tam?: number; fondo?: string; color?: string; giro?: number; children: React.ReactNode }> = ({ s, desde, y, tam = 90, fondo = AMARILLO, color = TINTA, giro = -3, children }) => {
  if (s < desde - 0.05) return null;
  const abre = interpolate(s, [desde, desde + 0.3], [0, 1], { ...CL, easing: Easing.out(Easing.cubic) });
  const sube = interpolate(s, [desde + 0.1, desde + 0.5], [0, 1], { ...CL, easing: Easing.out(Easing.cubic) });
  return (
    <div style={{ position: "absolute", left: 0, right: 0, top: y, display: "flex", justifyContent: "center", transform: `rotate(${giro}deg)` }}>
      <div style={{ overflow: "hidden", background: fondo, border: `8px solid ${TINTA}`, borderRadius: 26, padding: "8px 34px 0", boxShadow: `0 10px 0 ${TINTA}`, clipPath: `inset(0 ${(1 - abre) * 50}% 0 ${(1 - abre) * 50}% round 26px)` }}>
        <div style={{ transform: `translateY(${(1 - sube) * 110}%)`, fontFamily: FUENTE, fontWeight: 800, fontSize: tam, color, whiteSpace: "nowrap", lineHeight: 1.1 }}>{children}</div>
      </div>
    </div>
  );
};
