import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { Codigo, Escena, marcas, Pop, Segmento, Sfx, usePop } from "../comunes";
import { C, CLAMP, MONO, SANS } from "../tema";

const m = marcas("final");
const PIEZAS = [
  { texto: "Instrucciones", color: C.cian, en: "instrucciones" },
  { texto: "Decisiones", color: C.violeta, en: "decisiones" },
  { texto: "Repeticiones", color: C.verde, en: "repeticiones" },
];
const HOLA: Segmento[][] = [[["print", C.violeta], ["(", C.texto], ['"¡Hola, mundo!"', C.verde], [")", C.texto]]];

export const Final: React.FC = () => {
  const frame = useCurrentFrame();
  const juntar = interpolate(frame, [m("construye"), m("construye") + 20], [0, 1], CLAMP);
  const salida = interpolate(frame, [m("te") - 10, m("te")], [1, 0], CLAMP);
  const terminal = usePop(m("te"), 200);
  const iconos = ["📱", "🎮", "🌐", "🚗", "🏥", "🛰️"];
  return (
    <Escena id="final" etiqueta="RESUMEN" titulo="Las piezas de todo el software" color={C.ambar}>
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", opacity: salida }}>
        <div style={{ display: "flex", gap: 30 - 30 * juntar, alignItems: "flex-end" }}>
          {PIEZAS.map((p, i) => (
            <Pop key={p.texto} desde={m(p.en)}>
              <div
                style={{
                  width: 380,
                  height: 140,
                  background: `${p.color}26`,
                  border: `4px solid ${p.color}`,
                  borderRadius: 24 - 12 * juntar,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  fontFamily: SANS,
                  fontWeight: 700,
                  fontSize: 46,
                  color: p.color,
                  transform: `translateY(${Math.sin(frame / 15 + i) * 6 * (1 - juntar)}px)`,
                }}
              >
                {p.texto}
              </div>
            </Pop>
          ))}
        </div>
        <div style={{ display: "flex", gap: 50, marginBottom: 40, order: -1 }}>
          {iconos.map((ic, i) => (
            <Pop key={ic} desde={m("software") + i * 3}>
              <div style={{ fontSize: 90 }}>{ic}</div>
            </Pop>
          ))}
        </div>
      </AbsoluteFill>
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", opacity: terminal }}>
        <div style={{ fontFamily: SANS, fontWeight: 700, fontSize: 80, color: C.texto, marginBottom: 50, transform: `translateY(${(1 - terminal) * 30}px)` }}>
          ¿Te animas a escribir tu <span style={{ color: C.cian }}>primera línea</span>?
        </div>
        <div style={{ background: "#050914", border: `2px solid ${C.borde}`, borderRadius: 20, padding: "30px 44px", fontFamily: MONO }}>
          <Codigo lineas={HOLA} desde={m("escribir")} cps={14} tamano={52} />
        </div>
      </AbsoluteFill>
      {PIEZAS.map((p) => <Sfx key={p.texto} id="pop" en={m(p.en)} />)}
      <Sfx id="whoosh" en={m("construye")} volumen={0.35} />
      <Sfx id="brillo" en={m("software")} volumen={0.35} />
      <Sfx id="teclado" en={m("escribir")} volumen={0.3} dur={60} />
      <Sfx id="exito" en={m("escribir") + 70} volumen={0.35} />
    </Escena>
  );
};
