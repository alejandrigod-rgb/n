import { interpolate, useCurrentFrame } from "remotion";
import { Aparecer, Escena, marcas, Sfx } from "../comunes";
import { C, CLAMP, MONO } from "../tema";

const m = marcas("bucles");
const COLS = 20;
const FILAS = 8;

export const Bucles: React.FC = () => {
  const frame = useCurrentFrame();
  const inicio = m("enviar");
  const fin = m("instante") + 10;
  const progreso = interpolate(frame, [inicio, fin], [0, 1], CLAMP);
  const cuenta = Math.round(progreso * 1000);
  const giro = frame * (frame >= inicio && frame <= fin ? 12 : 2);
  const encendidas = Math.round(progreso * COLS * FILAS);
  return (
    <Escena id="bucles" etiqueta="07 · BUCLES" titulo="Repetir sin cansarse" color={C.verde}>
      <div style={{ display: "flex", alignItems: "center", gap: 110 }}>
        <Aparecer desde={m("bucles")}>
          <div style={{ position: "relative", width: 360, height: 360 }}>
            <svg width={360} height={360} viewBox="-180 -180 360 360" style={{ position: "absolute", transform: `rotate(${giro}deg)` }}>
              <path d="M0 -150 A150 150 0 1 1 -150 0" stroke={C.verde} strokeWidth={22} fill="none" strokeLinecap="round" />
              <polygon points="-150,-40 -190,10 -110,10" fill={C.verde} transform="rotate(0)" />
            </svg>
            <div style={{ position: "absolute", inset: 0, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center" }}>
              <div style={{ fontFamily: MONO, fontWeight: 700, fontSize: 84, color: C.texto }}>{cuenta}</div>
              <div style={{ fontFamily: MONO, fontSize: 26, color: C.tenue }}>/ 1000</div>
            </div>
          </div>
          <div style={{ fontFamily: MONO, fontSize: 30, color: C.tenue, marginTop: 30, textAlign: "center" }}>
            <span style={{ color: C.violeta }}>repetir</span> 1000 veces:
            <br />
            enviar(<span style={{ color: C.verde }}>mensaje</span>)
          </div>
        </Aparecer>
        <Aparecer desde={m("ejemplo")}>
          <div style={{ display: "grid", gridTemplateColumns: `repeat(${COLS}, 36px)`, gap: 12 }}>
            {new Array(COLS * FILAS).fill(0).map((_, i) => {
              const on = i < encendidas;
              return (
                <svg key={i} width={36} height={36} viewBox="0 0 36 36">
                  <circle cx={18} cy={11} r={8} fill={on ? C.verde : "#334155"} />
                  <path d="M3 35 C3 20 33 20 33 35 Z" fill={on ? C.verde : "#334155"} />
                </svg>
              );
            })}
          </div>
        </Aparecer>
      </div>
      <Sfx id="whoosh" en={m("bucles")} volumen={0.35} />
      {[0, 1, 2, 3, 4].map((i) => (
        <Sfx key={i} id="envio" en={inicio + i * Math.round((fin - inicio) / 5)} volumen={0.3} />
      ))}
      <Sfx id="exito" en={fin} volumen={0.35} />
    </Escena>
  );
};
