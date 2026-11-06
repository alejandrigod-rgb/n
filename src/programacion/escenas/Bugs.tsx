import { interpolate, useCurrentFrame } from "remotion";
import { Escena, marcas, Pop, Sfx, Ventana } from "../comunes";
import { C, CLAMP, MONO } from "../tema";

const m = marcas("bugs");

const LINEAS = [
  { t: "precio = 100", c: C.texto },
  { t: "descuento = 20", c: C.texto },
  { t: "total = precio + descuento", ok: "total = precio - descuento", c: C.texto },
  { t: "mostrar(total)", c: C.texto },
];

export const Bugs: React.FC = () => {
  const frame = useCurrentFrame();
  const entra = interpolate(frame, [m("bug") - 15, m("bug") + 10], [0, 1], CLAMP);
  const error = frame >= m("error") && frame < m("corregirlo") + 10;
  const arreglado = frame >= m("corregirlo") + 10;
  const sale = interpolate(frame, [m("corregirlo"), m("corregirlo") + 20], [0, 1], CLAMP);
  const bx = interpolate(entra, [0, 1], [1100, 640]) + sale * 700;
  const by = 190 - sale * 400 + Math.sin(frame / 2) * 4;
  return (
    <Escena id="bugs" etiqueta="08 · ERRORES" titulo="Cazando bugs" color={C.rojo}>
      <div style={{ position: "relative" }}>
        <Ventana titulo="tienda.py" ancho={1000} acento={error ? C.rojo : arreglado ? C.verde : C.cian}>
          {LINEAS.map((l, i) => {
            const marcada = i === 2;
            const fondo = marcada && error ? `${C.rojo}26` : marcada && arreglado ? `${C.verde}22` : "transparent";
            return (
              <div key={i} style={{ fontFamily: MONO, fontSize: 40, lineHeight: 1.8, background: fondo, borderRadius: 8, padding: "0 12px", display: "flex", justifyContent: "space-between" }}>
                <span>
                  <span style={{ color: "#ffffff33", marginRight: 26 }}>{i + 1}</span>
                  <span style={{ color: marcada && error ? C.rojo : C.texto, textDecoration: marcada && error ? "underline wavy" : "none" }}>
                    {marcada && arreglado ? l.ok : l.t}
                  </span>
                </span>
                {marcada && arreglado ? <span style={{ color: C.verde }}>✓</span> : null}
              </div>
            );
          })}
          <div style={{ fontFamily: MONO, fontSize: 32, marginTop: 14, color: arreglado ? C.verde : error ? C.rojo : C.tenue }}>
            {"> "}
            {arreglado ? "total: 80  ✓" : error ? "total: 120  ✗ ¡resultado incorrecto!" : ""}
          </div>
        </Ventana>
        <svg width={120} height={120} viewBox="0 0 120 120" style={{ position: "absolute", left: bx, top: by, opacity: entra * (1 - sale) }}>
          {[-1, 1].map((s) => [30, 55, 80].map((y) => <line key={`${s}${y}`} x1={60} y1={y} x2={60 + s * 50} y2={y + Math.sin(frame + y) * 8} stroke="#1f2937" strokeWidth={6} />))}
          <ellipse cx={60} cy={60} rx={30} ry={40} fill={C.rojo} />
          <circle cx={60} cy={22} r={18} fill="#1f2937" />
          <line x1={60} y1={22} x2={60} y2={100} stroke="#7f1d1d" strokeWidth={4} />
        </svg>
        {arreglado ? (
          <Pop desde={m("corregirlo") + 10} style={{ position: "absolute", right: -60, top: -60 }}>
            <div style={{ width: 120, height: 120, borderRadius: 60, background: C.verde, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 70, color: "#052e16", fontWeight: 700 }}>✓</div>
          </Pop>
        ) : null}
      </div>
      <Sfx id="bicho" en={m("bug") - 15} volumen={0.45} />
      <Sfx id="error" en={m("error")} volumen={0.45} />
      <Sfx id="teclado" en={m("corregirlo") - 5} volumen={0.3} dur={15} />
      <Sfx id="exito" en={m("corregirlo") + 10} volumen={0.4} />
    </Escena>
  );
};
