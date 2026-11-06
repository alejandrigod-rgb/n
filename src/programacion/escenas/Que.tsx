import { interpolate, useCurrentFrame } from "remotion";
import { Aparecer, Escena, Flecha, marcas, Sfx } from "../comunes";
import { C, CLAMP, MONO, SANS } from "../tema";

const m = marcas("que");
const PASOS = ["1. Abre la puerta", "2. Entra", "3. Cierra la puerta"];

export const Que: React.FC = () => {
  const frame = useCurrentFrame();
  const flecha = interpolate(frame, [m("instrucciones"), m("instrucciones") + 15], [0, 1], CLAMP);
  const confundida = frame >= m("indirectas") && frame < m("hay");
  const pasos = [m("exactamente"), m("que", 1), m("paso")];
  return (
    <Escena id="que" etiqueta="01 · LA IDEA" titulo="¿Qué es programar?" color={C.cian}>
      <div style={{ display: "flex", alignItems: "center", gap: 40 }}>
        <Aparecer desde={0}>
          <svg width={220} height={300} viewBox="0 0 220 300">
            <circle cx={110} cy={80} r={56} fill={C.ambar} />
            <path d="M20 290 C20 170 200 170 200 290 Z" fill={C.cian} />
          </svg>
          <div style={{ fontFamily: SANS, fontSize: 34, color: C.tenue, textAlign: "center" }}>Tú</div>
        </Aparecer>
        <Flecha progreso={flecha} ancho={200} color={C.cian} />
        <div style={{ width: 640, minHeight: 300, background: C.panel, border: `2px solid ${C.borde}`, borderRadius: 24, padding: "30px 40px", position: "relative" }}>
          <div style={{ fontFamily: MONO, fontSize: 26, color: C.tenue, marginBottom: 16 }}>instrucciones.txt</div>
          {frame < m("indirectas") ? (
            <Aparecer desde={m("instrucciones")}>
              <div style={{ fontFamily: MONO, fontSize: 38, color: C.texto }}>"Ya sabes qué hacer..."</div>
            </Aparecer>
          ) : null}
          {PASOS.map((p, i) => (
            <Aparecer key={p} desde={pasos[i]} dy={20}>
              <div style={{ fontFamily: MONO, fontSize: 38, color: C.verde, lineHeight: 1.7 }}>{p}</div>
            </Aparecer>
          ))}
        </div>
        <Flecha progreso={flecha} ancho={200} color={C.cian} />
        <Aparecer desde={0}>
          <svg width={300} height={300} viewBox="0 0 300 300">
            <rect x={20} y={30} width={260} height={180} rx={20} fill="#1e293b" stroke={confundida ? C.rojo : C.cian} strokeWidth={8} />
            <rect x={120} y={210} width={60} height={40} fill="#334155" />
            <rect x={80} y={250} width={140} height={16} rx={8} fill="#334155" />
            <text x={150} y={140} textAnchor="middle" fontFamily="JetBrains Mono" fontSize={64} fontWeight={700} fill={confundida ? C.rojo : C.verde}>
              {confundida ? "???" : frame >= m("paso") ? "OK" : "_"}
            </text>
          </svg>
          <div style={{ fontFamily: SANS, fontSize: 34, color: C.tenue, textAlign: "center" }}>Computadora</div>
        </Aparecer>
      </div>
      <Sfx id="whoosh" en={m("instrucciones")} volumen={0.35} />
      <Sfx id="error" en={m("indirectas")} volumen={0.4} />
      {pasos.map((p) => <Sfx key={p} id="tic" en={p} volumen={0.45} />)}
      <Sfx id="exito" en={m("paso") + 8} volumen={0.35} />
    </Escena>
  );
};
