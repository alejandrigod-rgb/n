/**
 * La madre de Marco (serie de la cuenta Marcoglowup, no AEZ): unos 55 años, cariñosa. Pelo castaño en moño con un mechón canoso,
 * gafas colgadas al cuello, rebeca lila sobre vestido de flores, delantal de cocina y zapatillas.
 * Mismo estilo y encuadre que MarcoGordo (viewBox 400×700, cara hacia (200, 180)).
 */
import React from "react";
import "../marca/tema";

const L = "#1c1a22";
const PIEL = "#f1c8a8";
const PIEL_S = "#dca686";
const PELO = "#7a4a2e";
const PELO_S = "#5a3420";
const REBECA = "#b28ad6";
const REBECA_S = "#8f69b5";
const VESTIDO = "#f6e2a8";

export type ExpresionMama = "sonrisa" | "susto" | "lagrimas" | "preocupada" | "enfado";

export const Mama: React.FC<{ ancho?: number; expresion?: ExpresionMama; abraza?: boolean; frame?: number }> = ({ ancho = 400, expresion = "sonrisa", abraza = false, frame = 0 }) => {
  const ojosCerrados = expresion === "lagrimas";
  return (
    <svg width={ancho} height={ancho * 1.75} viewBox="0 0 400 700" style={{ overflow: "visible" }}>
      <g strokeLinejoin="round" strokeLinecap="round">
        <ellipse cx={200} cy={688} rx={115} ry={14} fill="#000" opacity={0.18} />
        {/* Piernas y zapatillas */}
        <path d="M164 540 L160 650 L192 650 L196 540 Z" fill={PIEL} stroke={L} strokeWidth={6} />
        <path d="M236 540 L240 650 L208 650 L204 540 Z" fill={PIEL} stroke={L} strokeWidth={6} />
        <path d="M140 644 L196 644 L198 676 L132 676 Q126 660 140 644 Z" fill="#e07a9a" stroke={L} strokeWidth={6} />
        <path d="M260 644 L204 644 L202 676 L268 676 Q274 660 260 644 Z" fill="#e07a9a" stroke={L} strokeWidth={6} />
        {/* Vestido de flores */}
        <path d="M144 310 Q200 296 256 310 L280 560 Q200 576 120 560 Z" fill={VESTIDO} stroke={L} strokeWidth={7} />
        {[
          [150, 520],
          [210, 540],
          [254, 510],
          [176, 470],
          [240, 460],
        ].map(([x, y], k) => (
          <g key={k}>
            {[0, 72, 144, 216, 288].map((a) => (
              <circle key={a} cx={x + Math.cos((a * Math.PI) / 180) * 7} cy={y + Math.sin((a * Math.PI) / 180) * 7} r={5} fill="#e86a7a" />
            ))}
            <circle cx={x} cy={y} r={4} fill="#ffd34a" />
          </g>
        ))}
        {/* Delantal */}
        <path d="M164 380 L236 380 L246 540 Q200 552 154 540 Z" fill="#ffffff" stroke={L} strokeWidth={6} />
        <path d="M150 384 H250" stroke="#e86a7a" strokeWidth={8} />
        <rect x={180} y={450} width={40} height={34} rx={6} fill="#fbe4ea" stroke={L} strokeWidth={4} />
        <path d="M164 400 L236 400 M160 430 L240 430" stroke="#f3c6d0" strokeWidth={4} strokeDasharray="6 8" />
        {/* Rebeca lila */}
        <path d="M140 312 Q160 302 178 304 L168 470 L132 460 Z" fill={REBECA} stroke={L} strokeWidth={6} />
        <path d="M260 312 Q240 302 222 304 L232 470 L268 460 Z" fill={REBECA} stroke={L} strokeWidth={6} />
        {/* Brazos: abajo o abiertos para abrazar */}
        {abraza ? (
          <>
            <path d="M138 320 Q70 330 40 270 L62 252 Q90 296 148 296 Z" fill={REBECA} stroke={L} strokeWidth={7} />
            <circle cx={46} cy={256} r={18} fill={PIEL} stroke={L} strokeWidth={6} />
            <path d="M262 320 Q330 330 360 270 L338 252 Q310 296 252 296 Z" fill={REBECA} stroke={L} strokeWidth={7} />
            <circle cx={354} cy={256} r={18} fill={PIEL} stroke={L} strokeWidth={6} />
          </>
        ) : (
          <>
            <path d="M138 318 Q106 400 116 470 L144 470 Q142 410 160 352 Z" fill={REBECA} stroke={L} strokeWidth={7} />
            <path d="M120 456 H142" stroke={REBECA_S} strokeWidth={8} />
            <circle cx={130} cy={482} r={18} fill={PIEL} stroke={L} strokeWidth={6} />
            <path d="M262 318 Q294 400 284 470 L256 470 Q258 410 240 352 Z" fill={REBECA} stroke={L} strokeWidth={7} />
            <path d="M258 456 H280" stroke={REBECA_S} strokeWidth={8} />
            <circle cx={270} cy={482} r={18} fill={PIEL} stroke={L} strokeWidth={6} />
          </>
        )}
        {/* Cuello y gafas colgadas con cadenita */}
        <path d="M182 262 L182 304 L218 304 L218 262 Z" fill={PIEL_S} stroke={L} strokeWidth={6} />
        <path d="M168 300 Q200 350 232 300" fill="none" stroke="#d9a93f" strokeWidth={3} />
        <g transform="translate(200 342)">
          <circle cx={-14} cy={0} r={11} fill="#bfe3ff" fillOpacity={0.4} stroke={L} strokeWidth={4} />
          <circle cx={14} cy={0} r={11} fill="#bfe3ff" fillOpacity={0.4} stroke={L} strokeWidth={4} />
          <path d="M-3 0 H3" stroke={L} strokeWidth={4} />
        </g>
        {/* Cara redonda */}
        <path d="M126 164 Q124 84 200 78 Q276 84 274 164 Q274 230 238 262 Q200 286 162 262 Q126 230 126 164 Z" fill={PIEL} stroke={L} strokeWidth={7} />
        {/* Pendientes de perla */}
        <circle cx={126} cy={204} r={7} fill="#fff8ec" stroke={L} strokeWidth={3} />
        <circle cx={274} cy={204} r={7} fill="#fff8ec" stroke={L} strokeWidth={3} />
        {/* Mejillas */}
        <ellipse cx={154} cy={212} rx={20} ry={11} fill="#ff9bb0" opacity={0.55} />
        <ellipse cx={246} cy={212} rx={20} ry={11} fill="#ff9bb0" opacity={0.55} />
        {/* Arruguitas de sonreír */}
        <path d="M128 168 l-8 -4 M128 178 l-9 2 M272 168 l8 -4 M272 178 l9 2" stroke={PIEL_S} strokeWidth={3} />
        {/* Ojos */}
        {ojosCerrados ? (
          <>
            <path d="M148 178 Q166 164 184 178" fill="none" stroke={L} strokeWidth={6} />
            <path d="M216 178 Q234 164 252 178" fill="none" stroke={L} strokeWidth={6} />
            {/* Lágrimas de alegría */}
            <path d={`M146 186 q-8 ${18 + (frame % 20)} 0 ${26 + (frame % 20)} q8 -8 0 -${26 + (frame % 20)} Z`} fill="#8fd0ff" stroke={L} strokeWidth={2} />
            <path d={`M254 186 q-8 ${18 + ((frame + 10) % 20)} 0 ${26 + ((frame + 10) % 20)} q8 -8 0 -${26 + ((frame + 10) % 20)} Z`} fill="#8fd0ff" stroke={L} strokeWidth={2} />
          </>
        ) : (
          [166, 234].map((x) => (
            <g key={x}>
              <ellipse cx={x} cy={174} rx={expresion === "susto" ? 17 : 14} ry={expresion === "susto" ? 19 : 15} fill="#fff" stroke={L} strokeWidth={5} />
              <circle cx={x + 1} cy={176} r={expresion === "susto" ? 5 : 7} fill="#5a3a24" />
              <circle cx={x - 2} cy={172} r={2.5} fill="#fff" />
            </g>
          ))
        )}
        {/* Cejas */}
        <path
          d={expresion === "preocupada" ? "M146 146 Q166 140 186 134" : expresion === "susto" ? "M146 136 Q166 124 186 136" : expresion === "enfado" ? "M146 136 L186 150" : "M146 146 Q166 138 186 146"}
          fill="none"
          stroke={PELO_S}
          strokeWidth={7}
        />
        <path
          d={expresion === "preocupada" ? "M214 134 Q234 140 254 146" : expresion === "susto" ? "M214 136 Q234 124 254 136" : expresion === "enfado" ? "M254 136 L214 150" : "M214 146 Q234 138 254 146"}
          fill="none"
          stroke={PELO_S}
          strokeWidth={7}
        />
        {/* Nariz */}
        <path d="M198 192 Q190 212 202 216" fill="none" stroke={PIEL_S} strokeWidth={5} />
        {/* Boca con pintalabios */}
        {expresion === "susto" ? (
          <ellipse cx={200} cy={242} rx={13} ry={16} fill="#8a2438" stroke={L} strokeWidth={5} />
        ) : expresion === "lagrimas" ? (
          <path d="M174 230 Q200 266 226 230 Z" fill="#8a2438" stroke={L} strokeWidth={5} />
        ) : expresion === "preocupada" || expresion === "enfado" ? (
          <path d="M182 244 Q200 234 218 244" fill="none" stroke="#c4506a" strokeWidth={6} />
        ) : (
          <path d="M178 232 Q200 254 222 232" fill="none" stroke="#c4506a" strokeWidth={7} />
        )}
        {/* Pelo: moño alto con mechón canoso y horquilla */}
        <circle cx={200} cy={54} r={34} fill={PELO} stroke={L} strokeWidth={7} />
        <path d="M178 40 Q200 28 222 40" fill="none" stroke={PELO_S} strokeWidth={5} />
        <path d="M120 170 Q108 76 200 70 Q292 76 280 170 Q272 118 236 104 Q214 122 190 108 Q156 116 138 130 Q124 146 120 170 Z" fill={PELO} stroke={L} strokeWidth={7} />
        <path d="M200 72 Q214 88 236 104" fill="none" stroke="#e6e2da" strokeWidth={8} />
        <path d="M160 80 Q180 72 196 74" fill="none" stroke="#a06a46" strokeWidth={5} />
        <rect x={222} y={30} width={30} height={9} rx={4} fill="#e86a7a" stroke={L} strokeWidth={3} transform="rotate(25 237 34)" />
      </g>
    </svg>
  );
};

/** Hoja de diseño de la madre. */
export const DisenoMama: React.FC = () => (
  <div style={{ width: 1900, height: 900, background: "#f6eef4", display: "flex", alignItems: "flex-end", justifyContent: "space-around", padding: 30, boxSizing: "border-box", fontFamily: "'Baloo 2', sans-serif" }}>
    {(["sonrisa", "susto", "lagrimas", "preocupada", "enfado"] as ExpresionMama[]).map((e) => (
      <div key={e} style={{ display: "flex", flexDirection: "column", alignItems: "center" }}>
        <Mama ancho={290} expresion={e} abraza={e === "lagrimas"} frame={8} />
        <div style={{ fontWeight: 800, fontSize: 34, color: "#1c1a22" }}>{e === "lagrimas" ? "lágrimas de alegría" : e}</div>
      </div>
    ))}
  </div>
);
