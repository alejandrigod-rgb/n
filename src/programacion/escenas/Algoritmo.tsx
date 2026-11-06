import { interpolate, useCurrentFrame } from "remotion";
import { Aparecer, Escena, marcas, Pop, Sfx } from "../comunes";
import { C, CLAMP, MONO, SANS } from "../tema";

const m = marcas("algoritmo");

export const Algoritmo: React.FC = () => {
  const frame = useCurrentFrame();
  const pasos = [
    { texto: "Calentar el agua", en: m("primero"), color: C.naranja },
    { texto: "Agregar el café", en: m("luego"), color: C.ambar },
    { texto: "Servir", en: m("final"), color: C.verde },
  ];
  const nivel = interpolate(frame, [m("luego"), m("luego") + 40], [0, 1], CLAMP);
  const vapor = frame >= m("final");
  return (
    <Escena id="algoritmo" etiqueta="02 · ALGORITMOS" titulo="Una receta para la computadora" color={C.ambar}>
      <div style={{ display: "flex", alignItems: "center", gap: 120 }}>
        <div>
          <Pop desde={m("algoritmo")}>
            <div style={{ fontFamily: SANS, fontWeight: 700, fontSize: 64, color: C.ambar }}>
              Algoritmo <span style={{ color: C.tenue, fontWeight: 500 }}>= lista de pasos</span>
            </div>
          </Pop>
          <div style={{ marginTop: 40, display: "flex", flexDirection: "column", gap: 22 }}>
            {pasos.map((p, i) => {
              const hecho = frame >= p.en;
              return (
                <Aparecer key={p.texto} desde={m("receta") + i * 4}>
                  <div style={{ display: "flex", alignItems: "center", gap: 24, background: C.panel, border: `2px solid ${hecho ? p.color : C.borde}`, borderRadius: 18, padding: "18px 28px", width: 620 }}>
                    <div style={{ width: 54, height: 54, borderRadius: 27, background: hecho ? p.color : "#ffffff14", display: "flex", alignItems: "center", justifyContent: "center", fontFamily: MONO, fontWeight: 700, fontSize: 30, color: hecho ? "#111" : C.tenue }}>
                      {hecho ? "✓" : i + 1}
                    </div>
                    <div style={{ fontFamily: SANS, fontWeight: 500, fontSize: 44, color: hecho ? C.texto : C.tenue }}>{p.texto}</div>
                  </div>
                </Aparecer>
              );
            })}
          </div>
        </div>
        <Aparecer desde={m("receta")}>
          <svg width={380} height={420} viewBox="0 0 380 420">
            {vapor
              ? [0, 1, 2].map((i) => (
                  <path key={i} d={`M${130 + i * 50} 110 C${110 + i * 50} 80 ${150 + i * 50} 60 ${130 + i * 50} ${30 - ((frame / 2 + i * 10) % 20)}`} stroke="#ffffff66" strokeWidth={8} fill="none" strokeLinecap="round" />
                ))
              : null}
            <defs>
              <clipPath id="taza">
                <path d="M60 130 H300 L280 360 C276 390 250 400 220 400 H140 C110 400 84 390 80 360 Z" />
              </clipPath>
            </defs>
            <path d="M60 130 H300 L280 360 C276 390 250 400 220 400 H140 C110 400 84 390 80 360 Z" fill="#e2e8f0" />
            <rect x={40} y={400 - 260 * nivel} width={300} height={270} fill="#7c4a24" clipPath="url(#taza)" />
            <path d="M300 170 C370 170 370 290 290 290" stroke="#e2e8f0" strokeWidth={22} fill="none" />
          </svg>
        </Aparecer>
      </div>
      <Sfx id="pop" en={m("algoritmo")} />
      {pasos.map((p) => <Sfx key={p.texto} id="tic" en={p.en} volumen={0.45} />)}
      <Sfx id="cafe" en={m("luego") + 4} volumen={0.45} />
      <Sfx id="exito" en={m("sirves")} volumen={0.35} />
    </Escena>
  );
};
