/**
 * El padre de Marco (serie de la cuenta Marcoglowup, no AEZ): unos 58 años, calvo por arriba con canas a los lados,
 * bigote gris enorme, gafas, polo verde metido en el pantalón, barriguita, cinturón y zapatillas de casa.
 * Mismo estilo y encuadre que MarcoGordo (viewBox 400×700, cara hacia (200, 180)).
 */
import React from "react";
import "../marca/tema";

const L = "#1c1a22";
const PIEL = "#eec3a0";
const PIEL_S = "#d8a07c";
const CANA = "#c9c6c0";
const CANA_S = "#9d9a94";
const POLO = "#4f7d5a";
const POLO_S = "#3c6246";
const PANT = "#8a7a62";

export type ExpresionPapa = "serio" | "susto" | "enfado" | "confuso" | "orgullo";

export const Papa: React.FC<{ ancho?: number; expresion?: ExpresionPapa; apunta?: boolean; frame?: number }> = ({ ancho = 400, expresion = "serio", apunta = false, frame = 0 }) => {
  const dedo = apunta ? Math.sin(frame / 4) * 4 : 0;
  const ojoR = expresion === "susto" ? 15 : 11;
  return (
    <svg width={ancho} height={ancho * 1.75} viewBox="0 0 400 700" style={{ overflow: "visible" }}>
      <g strokeLinejoin="round" strokeLinecap="round">
        <ellipse cx={200} cy={688} rx={120} ry={14} fill="#000" opacity={0.18} />
        {/* Pantalón y zapatillas de casa */}
        <path d="M146 480 L138 650 L190 650 L198 510 Z" fill={PANT} stroke={L} strokeWidth={7} />
        <path d="M254 480 L262 650 L210 650 L202 510 Z" fill={PANT} stroke={L} strokeWidth={7} />
        <path d="M124 644 L194 644 L196 678 L114 678 Q108 660 124 644 Z" fill="#7a3b3b" stroke={L} strokeWidth={7} />
        <path d="M276 644 L206 644 L204 678 L286 678 Q292 660 276 644 Z" fill="#7a3b3b" stroke={L} strokeWidth={7} />
        {/* Brazo izquierdo (pantalla) */}
        <path d="M124 318 Q90 400 98 474 L128 474 Q128 414 150 352 Z" fill={POLO} stroke={L} strokeWidth={7} />
        <circle cx={112} cy={486} r={20} fill={PIEL} stroke={L} strokeWidth={6} />
        {/* Brazo derecho: abajo o apuntando hacia arriba */}
        {apunta ? (
          <g transform={`rotate(${dedo} 272 322)`}>
            <path d="M268 312 Q330 280 344 200 L316 192 Q306 252 252 290 Z" fill={POLO} stroke={L} strokeWidth={7} />
            <circle cx={332} cy={186} r={20} fill={PIEL} stroke={L} strokeWidth={6} />
            <path d="M334 170 L340 132" stroke={L} strokeWidth={16} />
            <path d="M334 170 L340 132" stroke={PIEL} strokeWidth={8} />
          </g>
        ) : (
          <>
            <path d="M276 318 Q310 400 302 474 L272 474 Q272 414 250 352 Z" fill={POLO} stroke={L} strokeWidth={7} />
            <circle cx={288} cy={486} r={20} fill={PIEL} stroke={L} strokeWidth={6} />
          </>
        )}
        {/* Polo metido en el pantalón, con barriguita */}
        <path d="M134 302 Q200 284 266 302 Q290 400 262 488 Q200 500 138 488 Q110 400 134 302 Z" fill={POLO} stroke={L} strokeWidth={7} />
        <path d="M180 300 L200 336 L220 300" fill="none" stroke={POLO_S} strokeWidth={7} />
        <circle cx={200} cy={350} r={4} fill="#efe6d6" />
        <circle cx={200} cy={372} r={4} fill="#efe6d6" />
        {/* Bolígrafo en el bolsillo */}
        <rect x={226} y={340} width={30} height={30} rx={4} fill={POLO_S} stroke={L} strokeWidth={4} />
        <path d="M234 330 L234 352" stroke="#2f62b5" strokeWidth={6} />
        {/* Cinturón */}
        <rect x={136} y={474} width={128} height={20} fill="#3a2a1e" stroke={L} strokeWidth={5} />
        <rect x={188} y={472} width={24} height={24} rx={3} fill="#e0b84a" stroke={L} strokeWidth={4} />
        {/* Cuello */}
        <path d="M180 262 L180 300 L220 300 L220 262 Z" fill={PIEL_S} stroke={L} strokeWidth={6} />
        {/* Cabeza: calva brillante */}
        <path d="M122 160 Q120 76 200 70 Q280 76 278 160 Q278 230 244 262 Q200 290 156 262 Q122 230 122 160 Z" fill={PIEL} stroke={L} strokeWidth={7} />
        <path d="M168 92 Q190 82 214 86" fill="none" stroke="#fff" strokeWidth={8} opacity={0.6} />
        {expresion === "enfado" ? <path d="M180 118 l8 10 M196 114 l0 12 M212 118 l-8 10" stroke="#d9534f" strokeWidth={5} /> : null}
        {/* Canas a los lados y orejas */}
        <path d="M124 130 Q108 160 116 214 Q126 196 134 168 Z" fill={CANA} stroke={L} strokeWidth={5} />
        <path d="M276 130 Q292 160 284 214 Q274 196 266 168 Z" fill={CANA} stroke={L} strokeWidth={5} />
        <ellipse cx={118} cy={190} rx={13} ry={20} fill={PIEL} stroke={L} strokeWidth={5} />
        <ellipse cx={282} cy={190} rx={13} ry={20} fill={PIEL} stroke={L} strokeWidth={5} />
        {/* Cejas grises pobladas */}
        <path
          d={expresion === "enfado" ? "M144 138 L188 154" : expresion === "susto" ? "M144 126 Q166 112 188 128" : expresion === "confuso" ? "M144 140 Q166 132 188 142" : "M144 142 Q166 136 188 144"}
          fill="none"
          stroke={CANA_S}
          strokeWidth={12}
        />
        <path
          d={expresion === "enfado" ? "M256 138 L212 154" : expresion === "susto" ? "M212 128 Q234 112 256 126" : expresion === "confuso" ? "M212 130 Q234 118 256 132" : "M212 144 Q234 136 256 142"}
          fill="none"
          stroke={CANA_S}
          strokeWidth={12}
        />
        {/* Ojos detrás de las gafas */}
        {expresion === "orgullo" ? (
          <>
            <path d="M152 176 Q166 166 180 176" fill="none" stroke={L} strokeWidth={5} />
            <path d="M220 176 Q234 166 248 176" fill="none" stroke={L} strokeWidth={5} />
          </>
        ) : (
          <>
            <circle cx={166} cy={176} r={ojoR} fill="#fff" stroke={L} strokeWidth={4} />
            <circle cx={234} cy={176} r={ojoR} fill="#fff" stroke={L} strokeWidth={4} />
            <circle cx={expresion === "confuso" ? 162 : 167} cy={178} r={expresion === "susto" ? 4 : 5.5} fill={L} />
            <circle cx={expresion === "confuso" ? 230 : 233} cy={178} r={expresion === "susto" ? 4 : 5.5} fill={L} />
          </>
        )}
        {/* Gafas */}
        <rect x={140} y={156} width={52} height={42} rx={12} fill="#bfe3ff" fillOpacity={0.25} stroke={L} strokeWidth={6} />
        <rect x={208} y={156} width={52} height={42} rx={12} fill="#bfe3ff" fillOpacity={0.25} stroke={L} strokeWidth={6} />
        <path d="M192 174 H208 M140 170 L122 166 M260 170 L278 166" stroke={L} strokeWidth={5} />
        <path d="M148 164 l12 -4 M216 164 l12 -4" stroke="#fff" strokeWidth={4} opacity={0.8} />
        {/* Nariz grande */}
        <path d="M196 186 Q182 216 196 222 Q206 226 212 216" fill={PIEL_S} stroke={L} strokeWidth={5} />
        {/* Boca */}
        {expresion === "susto" ? (
          <ellipse cx={200} cy={250} rx={14} ry={14} fill="#4a1a24" stroke={L} strokeWidth={5} />
        ) : expresion === "enfado" ? (
          <path d="M178 254 Q200 240 222 254 L222 258 Q200 248 178 258 Z" fill="#4a1a24" stroke={L} strokeWidth={5} />
        ) : expresion === "orgullo" ? (
          <path d="M180 246 Q200 262 220 246" fill="none" stroke={L} strokeWidth={6} />
        ) : (
          <path d="M184 252 L216 252" stroke={L} strokeWidth={6} />
        )}
        {/* Bigote gris enorme */}
        <path d="M150 238 Q170 220 200 230 Q230 220 250 238 Q240 250 222 244 Q210 240 200 244 Q190 240 178 244 Q160 250 150 238 Z" fill={CANA} stroke={L} strokeWidth={5} />
        <path d="M172 234 l-4 8 M186 232 l-2 8 M214 232 l2 8 M228 234 l4 8" stroke={CANA_S} strokeWidth={3} />
      </g>
    </svg>
  );
};

/** Hoja de diseño del padre. */
export const DisenoPapa: React.FC = () => (
  <div style={{ width: 1900, height: 900, background: "#eef1ec", display: "flex", alignItems: "flex-end", justifyContent: "space-around", padding: 30, boxSizing: "border-box", fontFamily: "'Baloo 2', sans-serif" }}>
    {(["serio", "susto", "enfado", "confuso", "orgullo"] as ExpresionPapa[]).map((e) => (
      <div key={e} style={{ display: "flex", flexDirection: "column", alignItems: "center" }}>
        <Papa ancho={290} expresion={e} apunta={e === "enfado"} frame={0} />
        <div style={{ fontWeight: 800, fontSize: 34, color: "#1c1a22" }}>{e}</div>
      </div>
    ))}
  </div>
);
