/**
 * Marco: protagonista de la serie interactiva de la cuenta alternativa (no es de AEZ, no lleva Nyxar).
 * Despierta tras 10 años y tiene 30 días antes de ver a su familia o a la chica a la que nunca se declaró.
 * Personaje original, en vector, de frente. Variantes para elegir el diseño.
 */
import React from "react";
import "../marca/tema"; // carga las letras Baloo 2

const L = "#1c1a22"; // contorno
export type VarianteMarco = "congelado" | "despeinado" | "cueva";

type Paleta = { piel: string; pielS: string; pelo: string; peloS: string; sudadera: string; sudaderaS: string; pantalon: string; gorra?: string; extra?: string };
const PALETAS: Record<VarianteMarco, Paleta> = {
  congelado: { piel: "#e9d6cf", pielS: "#cdb4b0", pelo: "#5a3b2a", peloS: "#3f281c", sudadera: "#e2553f", sudaderaS: "#b8402e", pantalon: "#3d5a8a", gorra: "#2b2f45", extra: "#cfeeff" },
  despeinado: { piel: "#f1c9a5", pielS: "#d9a985", pelo: "#2d2420", peloS: "#1a1412", sudadera: "#4aa497", sudaderaS: "#357d73", pantalon: "#6b4f3a" },
  cueva: { piel: "#e7cdb8", pielS: "#c9ab95", pelo: "#8a5a2e", peloS: "#6a4220", sudadera: "#7a6fb0", sudaderaS: "#5d5390", pantalon: "#4b4b55" },
};

export const Marco: React.FC<{ variante?: VarianteMarco; ancho?: number; boca?: number; ojos?: "abiertos" | "confusos" | "cerrados"; joven?: boolean }> = ({ variante = "congelado", ancho = 400, boca = 0, ojos = "confusos", joven = false }) => {
  // joven: Marco en 2016, antes de congelarse (sin barba, sin melena y sin hielo)
  const p = PALETAS[variante];
  const largo = variante !== "despeinado" && !joven; // pelo largo de 10 años
  const barba = variante !== "despeinado" ? 1 : 0.55;
  return (
    <svg width={ancho} height={ancho * 1.75} viewBox="0 0 400 700" style={{ overflow: "visible" }}>
      <g strokeLinejoin="round" strokeLinecap="round">
        {/* Sombra */}
        <ellipse cx={200} cy={688} rx={120} ry={14} fill="#000" opacity={0.18} />
        {/* Piernas: vaqueros pitillo de 2016 */}
        <path d="M150 470 L140 650 L185 650 L195 500 Z" fill={p.pantalon} stroke={L} strokeWidth={7} />
        <path d="M250 470 L260 650 L215 650 L205 500 Z" fill={p.pantalon} stroke={L} strokeWidth={7} />
        {/* Zapatillas */}
        <path d="M128 646 L190 646 L194 676 L118 676 Q112 660 128 646 Z" fill="#f4f1ea" stroke={L} strokeWidth={7} />
        <path d="M272 646 L210 646 L206 676 L282 676 Q288 660 272 646 Z" fill="#f4f1ea" stroke={L} strokeWidth={7} />
        <path d="M120 668 H194 M206 668 H280" stroke={p.sudadera} strokeWidth={6} />
        {/* Brazos */}
        <path d="M120 315 Q85 400 96 470 L128 470 Q126 410 150 345 Z" fill={p.sudadera} stroke={L} strokeWidth={7} />
        <path d="M280 315 Q315 400 304 470 L272 470 Q274 410 250 345 Z" fill={p.sudadera} stroke={L} strokeWidth={7} />
        <circle cx={112} cy={482} r={20} fill={p.piel} stroke={L} strokeWidth={7} />
        <circle cx={288} cy={482} r={20} fill={p.piel} stroke={L} strokeWidth={7} />
        {/* Sudadera */}
        <path d="M130 300 Q200 280 270 300 L262 490 Q200 505 138 490 Z" fill={p.sudadera} stroke={L} strokeWidth={7} />
        <path d="M140 470 Q200 482 260 470" fill="none" stroke={p.sudaderaS} strokeWidth={10} />
        <path d="M172 300 L176 360 M228 300 L224 360" stroke="#f4f1ea" strokeWidth={5} />
        {/* Bolsillo y texto de 2016 */}
        <path d="M160 410 H240 L232 450 H168 Z" fill={p.sudaderaS} stroke={L} strokeWidth={5} />
        <text x={200} y={392} textAnchor="middle" fontFamily="'Baloo 2', sans-serif" fontWeight={800} fontSize={30} fill="#f4f1ea">
          #YOLO
        </text>
        {/* Auriculares al cuello (2016) */}
        <path d="M150 300 Q200 330 250 300" fill="none" stroke="#2b2f45" strokeWidth={9} />
        <rect x={136} y={288} width={26} height={34} rx={9} fill="#2b2f45" stroke={L} strokeWidth={5} />
        <rect x={238} y={288} width={26} height={34} rx={9} fill="#2b2f45" stroke={L} strokeWidth={5} />
        {/* Cuello */}
        <path d="M180 265 L180 298 L220 298 L220 265 Z" fill={p.pielS} stroke={L} strokeWidth={6} />
        {/* Pelo de atrás (largo: 10 años sin cortar) */}
        {largo ? <path d="M108 140 Q96 260 128 330 L272 330 Q304 260 292 140 Z" fill={p.peloS} stroke={L} strokeWidth={7} /> : null}
        {/* Cabeza */}
        <path d="M118 150 Q118 70 200 66 Q282 70 282 150 L278 210 Q270 270 200 282 Q130 270 122 210 Z" fill={p.piel} stroke={L} strokeWidth={7} />
        {/* Orejas */}
        <ellipse cx={116} cy={178} rx={14} ry={22} fill={p.piel} stroke={L} strokeWidth={6} />
        <ellipse cx={284} cy={178} rx={14} ry={22} fill={p.piel} stroke={L} strokeWidth={6} />
        {/* Barba */}
        {joven ? null : <path d={`M128 200 Q132 ${262 + barba * 40} 200 ${282 + barba * 46} Q268 ${262 + barba * 40} 272 200 Q256 238 200 240 Q144 238 128 200 Z`} fill={p.pelo} stroke={L} strokeWidth={6} opacity={0.95} />}
        {joven ? null : <path d="M168 228 Q200 214 232 228" fill="none" stroke={p.peloS} strokeWidth={8} />}
        {/* Boca */}
        {boca > 0.05 ? (
          <ellipse cx={200} cy={250} rx={16} ry={6 + boca * 14} fill="#5a1f2a" stroke={L} strokeWidth={5} />
        ) : (
          <path d="M184 252 Q200 246 216 254" fill="none" stroke={L} strokeWidth={6} />
        )}
        {/* Nariz */}
        <path d="M200 176 Q192 206 204 210" fill="none" stroke={L} strokeWidth={5} />
        {/* Ojos */}
        {ojos === "cerrados" ? (
          <>
            <path d="M150 168 Q166 176 182 168" fill="none" stroke={L} strokeWidth={6} />
            <path d="M218 168 Q234 176 250 168" fill="none" stroke={L} strokeWidth={6} />
          </>
        ) : (
          <>
            <ellipse cx={166} cy={166} rx={ojos === "confusos" ? 20 : 17} ry={ojos === "confusos" ? 22 : 18} fill="#fff" stroke={L} strokeWidth={5} />
            <ellipse cx={234} cy={166} rx={17} ry={18} fill="#fff" stroke={L} strokeWidth={5} />
            <circle cx={ojos === "confusos" ? 172 : 168} cy={170} r={7} fill={L} />
            <circle cx={ojos === "confusos" ? 228 : 236} cy={168} r={ojos === "confusos" ? 5 : 7} fill={L} />
            {/* ojeras */}
            <path d="M150 192 Q166 200 182 192 M218 192 Q234 200 250 192" fill="none" stroke={p.pielS} strokeWidth={5} />
          </>
        )}
        {/* Cejas */}
        <path d={ojos === "confusos" ? "M146 132 Q166 118 186 134" : "M148 138 Q166 130 184 138"} fill="none" stroke={p.peloS} strokeWidth={9} />
        <path d={ojos === "confusos" ? "M214 142 Q234 138 252 144" : "M216 138 Q234 130 252 138"} fill="none" stroke={p.peloS} strokeWidth={9} />
        {/* Pelo de arriba */}
        {variante === "congelado" ? (
          <>
            {/* Gorra plana de 2016 con el pelo saliendo por los lados */}
            <path d="M112 128 Q118 58 200 52 Q282 58 288 128 Z" fill={p.gorra} stroke={L} strokeWidth={7} />
            <path d="M200 120 L340 120 Q350 132 336 140 L200 140 Z" fill={p.gorra} stroke={L} strokeWidth={7} />
            <path d="M112 128 Q98 170 104 210 M288 128 Q302 170 296 210" fill="none" stroke={p.pelo} strokeWidth={14} />
            {/* Escarcha: carámbanos y brillos */}
            {!joven && [130, 160, 190, 220, 250].map((x, k) => (
              <path key={k} d={`M${x} 128 L${x + 6} ${148 + (k % 2) * 10} L${x + 12} 128 Z`} fill={p.extra} stroke={L} strokeWidth={3} />
            ))}
            {joven ? null : <path d="M126 92 l6 -10 l6 10 l-6 10 Z M262 80 l5 -8 l5 8 l-5 8 Z" fill="#fff" />}
          </>
        ) : variante === "despeinado" ? (
          <>
            <path d="M112 150 Q100 60 200 52 Q300 60 288 150 Q270 104 240 120 Q220 84 196 112 Q170 84 150 120 Q126 108 112 150 Z" fill={p.pelo} stroke={L} strokeWidth={7} />
            {/* Gafas grandes */}
            <rect x={140} y={140} width={54} height={50} rx={14} fill="none" stroke={L} strokeWidth={6} />
            <rect x={206} y={140} width={54} height={50} rx={14} fill="none" stroke={L} strokeWidth={6} />
            <path d="M194 160 H206" stroke={L} strokeWidth={6} />
          </>
        ) : (
          <>
            {/* Melena enredada con una ramita */}
            <path d="M104 170 Q86 50 200 44 Q314 50 296 170 Q284 120 262 132 Q250 92 220 112 Q200 78 178 112 Q148 94 138 132 Q116 122 104 170 Z" fill={p.pelo} stroke={L} strokeWidth={7} />
            <path d="M250 70 L282 40 M266 56 L284 62" stroke="#6b4f3a" strokeWidth={6} />
            <ellipse cx={286} cy={38} rx={10} ry={6} fill="#63b967" stroke={L} strokeWidth={3} />
            {/* Mancha de tierra en la mejilla */}
            <ellipse cx={244} cy={212} rx={16} ry={8} fill="#8a6a46" opacity={0.6} />
          </>
        )}
      </g>
    </svg>
  );
};

/** Hoja para elegir el diseño de Marco: las tres versiones. */
export const DisenoMarco: React.FC = () => (
  <div style={{ width: 1500, height: 1000, background: "#efe7da", display: "flex", alignItems: "flex-end", justifyContent: "space-around", padding: "40px 30px", boxSizing: "border-box", fontFamily: "'Baloo 2', sans-serif" }}>
    {(
      [
        ["congelado", "1 · CONGELADO", "gorra plana, carámbanos"],
        ["despeinado", "2 · DESPEINADO", "gafas, barba a medias"],
        ["cueva", "3 · DE LA CUEVA", "melena con ramita"],
      ] as [VarianteMarco, string, string][]
    ).map(([v, t, d]) => (
      <div key={v} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 6 }}>
        <Marco variante={v} ancho={380} ojos="confusos" />
        <div style={{ fontWeight: 800, fontSize: 44, color: "#1c1a22" }}>{t}</div>
        <div style={{ fontWeight: 600, fontSize: 28, color: "#6b6170" }}>{d}</div>
      </div>
    ))}
  </div>
);
