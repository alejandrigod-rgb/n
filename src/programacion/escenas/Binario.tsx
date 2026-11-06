import { interpolate, random, useCurrentFrame } from "remotion";
import { Aparecer, Escena, marcas, Sfx } from "../comunes";
import { C, CLAMP, MONO, SANS } from "../tema";

const m = marcas("binario");

export const Binario: React.FC = () => {
  const frame = useCurrentFrame();
  const flujo = interpolate(frame, [m("ceros"), m("ceros") + 20], [0, 1], CLAMP);
  const chip = frame >= m("procesador");
  const brillo = chip ? 0.6 + 0.4 * Math.sin(frame / 3) : 0;
  const cuenta = Math.floor(interpolate(frame, [m("millones"), m("segundo") + 20], [0, 3200000], CLAMP));
  return (
    <Escena id="binario" etiqueta="04 · BAJO EL CAPÓ" titulo="Todo termina en ceros y unos" color={C.verde}>
      <div style={{ display: "flex", alignItems: "center", gap: 30 }}>
        <Aparecer desde={0}>
          <div style={{ background: C.panel, border: `2px solid ${C.borde}`, borderRadius: 18, padding: "26px 30px", fontFamily: MONO, fontSize: 36 }}>
            <span style={{ color: C.violeta }}>print</span>
            <span style={{ color: C.texto }}>(</span>
            <span style={{ color: C.verde }}>"Hola"</span>
            <span style={{ color: C.texto }}>)</span>
          </div>
        </Aparecer>
        <div style={{ width: 640, height: 240, position: "relative", overflow: "hidden", opacity: flujo }}>
          {new Array(60).fill(0).map((_, i) => {
            const fila = i % 5;
            const x = ((random(`bx${i}`) * 640 + (frame - m("ceros")) * (6 + fila)) % 680) - 30;
            return (
              <div key={i} style={{ position: "absolute", left: x, top: 20 + fila * 42, fontFamily: MONO, fontWeight: 700, fontSize: 34, color: fila % 2 ? C.verde : C.cian, opacity: 0.4 + random(`bo${i}`) * 0.6 }}>
                {random(`bb${i}-${Math.floor(frame / 6)}`) > 0.5 ? "1" : "0"}
              </div>
            );
          })}
        </div>
        <Aparecer desde={m("idioma")}>
          <div style={{ display: "flex", flexDirection: "column", alignItems: "center" }}>
            <svg width={300} height={300} viewBox="0 0 300 300" style={{ filter: chip ? `drop-shadow(0 0 ${30 * brillo}px ${C.verde})` : undefined }}>
              {[0, 1, 2, 3, 4, 5].map((i) => (
                <g key={i} stroke="#94a3b8" strokeWidth={8}>
                  <line x1={70 + i * 32} y1={10} x2={70 + i * 32} y2={50} />
                  <line x1={70 + i * 32} y1={250} x2={70 + i * 32} y2={290} />
                  <line x1={10} y1={70 + i * 32} x2={50} y2={70 + i * 32} />
                  <line x1={250} y1={70 + i * 32} x2={290} y2={70 + i * 32} />
                </g>
              ))}
              <rect x={50} y={50} width={200} height={200} rx={24} fill="#1e293b" stroke={chip ? C.verde : "#475569"} strokeWidth={8} />
              <text x={150} y={168} textAnchor="middle" fontFamily="JetBrains Mono" fontWeight={700} fontSize={50} fill={chip ? C.verde : C.tenue}>CPU</text>
            </svg>
            <div style={{ fontFamily: MONO, fontWeight: 700, fontSize: 44, color: C.texto, marginTop: 20, opacity: frame >= m("millones") ? 1 : 0 }}>
              {cuenta.toLocaleString("es")}
            </div>
            <div style={{ fontFamily: SANS, fontSize: 30, color: C.tenue, opacity: frame >= m("millones") ? 1 : 0 }}>instrucciones por segundo</div>
          </div>
        </Aparecer>
      </div>
      <Sfx id="datos" en={m("ceros")} volumen={0.3} />
      <Sfx id="encendido" en={m("procesador")} volumen={0.35} />
      <Sfx id="datos" en={m("millones")} volumen={0.2} />
    </Escena>
  );
};
