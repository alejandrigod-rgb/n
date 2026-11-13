/**
 * Fotos de perfil de la cuenta de la serie de Marco (cuenta alternativa, no AEZ). 1080×1080, pensadas para el círculo de TikTok:
 * cara grande y centrada, fondo de un color liso y vivo. Tres versiones: 1 confuso, 2 susto con móvil, 3 ilusión con "0/30".
 */
import React from "react";
import { AbsoluteFill } from "remotion";
import { MarcoGordo, type ExpresionGordo } from "./MarcoGordo";
import { AMARILLO, FUENTE, TINTA } from "./piezas";

const V: Record<number, { exp: ExpresionGordo; a: string; b: string; movil?: boolean; chapa?: boolean }> = {
  1: { exp: "confuso", a: "#ffe066", b: "#f0a020" },
  2: { exp: "susto", a: "#ff9cc2", b: "#d0457b", movil: true },
  3: { exp: "ilusion", a: "#8fc0ff", b: "#2f62b5", chapa: true },
};

export const FotoPerfilMarco: React.FC<{ v?: number }> = ({ v = 1 }) => {
  const c = V[v];
  const ancho = 1350;
  return (
    <AbsoluteFill style={{ background: `radial-gradient(circle at 50% 40%, ${c.a} 0%, ${c.b} 80%)`, overflow: "hidden" }}>
      {/* rayos de fondo */}
      <svg width={1080} height={1080} style={{ position: "absolute", opacity: 0.18 }}>
        {Array.from({ length: 16 }, (_, i) => {
          const a1 = (i / 16) * Math.PI * 2,
            a2 = a1 + Math.PI / 16;
          return <path key={i} d={`M540 520 L${540 + Math.cos(a1) * 1000} ${520 + Math.sin(a1) * 1000} L${540 + Math.cos(a2) * 1000} ${520 + Math.sin(a2) * 1000} Z`} fill="#fff" />;
        })}
      </svg>
      <div style={{ position: "absolute", left: 540 - ancho / 2, top: 560 - 180 * (ancho / 400) }}>
        <MarcoGordo ancho={ancho} expresion={c.exp} frame={40} movil={c.movil} brazoD={c.movil ? 120 : 0} olor={false} />
      </div>
      {c.chapa ? (
        <div style={{ position: "absolute", left: 640, top: 790, transform: "rotate(-8deg)", background: AMARILLO, border: `12px solid ${TINTA}`, borderRadius: 34, padding: "4px 30px 0", boxShadow: `0 12px 0 ${TINTA}` }}>
          <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 120, color: TINTA }}>0/30</span>
        </div>
      ) : null}
    </AbsoluteFill>
  );
};

/** Las tres versiones recortadas en círculo, como se verán en TikTok. */
export const PerfilesMarco: React.FC = () => (
  <AbsoluteFill style={{ background: "#f2f2f4", flexDirection: "row", alignItems: "center", justifyContent: "space-around", fontFamily: FUENTE }}>
    {[1, 2, 3].map((v) => (
      <div key={v} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 20 }}>
        <div style={{ width: 540, height: 540, borderRadius: 270, overflow: "hidden", position: "relative" }}>
          <div style={{ width: 1080, height: 1080, transform: "scale(0.5)", transformOrigin: "0 0" }}>
            <FotoPerfilMarco v={v} />
          </div>
        </div>
        <div style={{ width: 120, height: 120, borderRadius: 60, overflow: "hidden", position: "relative" }}>
          <div style={{ width: 1080, height: 1080, transform: `scale(${120 / 1080})`, transformOrigin: "0 0" }}>
            <FotoPerfilMarco v={v} />
          </div>
        </div>
        <div style={{ fontWeight: 800, fontSize: 56, color: TINTA }}>{v}</div>
      </div>
    ))}
  </AbsoluteFill>
);
