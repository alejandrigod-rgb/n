import { interpolate, useCurrentFrame } from "remotion";
import { Aparecer, Codigo, duracionTipeo, Escena, marcas, Segmento, Sfx, Ventana } from "../comunes";
import { C, CLAMP, MONO } from "../tema";

const m = marcas("lenguajes");

const PY: Segmento[][] = [
  [["nombre", C.cian], [" = ", C.texto], ['"Ana"', C.verde]],
  [["print", C.violeta], ["(", C.texto], ['"¡Hola, "', C.verde], [" + nombre)", C.texto]],
];
const JS: Segmento[][] = [
  [["const ", C.rosa], ["nombre", C.cian], [" = ", C.texto], ['"Ana"', C.verde], [";", C.texto]],
  [["console", C.cian], [".", C.texto], ["log", C.violeta], ["(", C.texto], ['"¡Hola, "', C.verde], [" + nombre);", C.texto]],
];

export const Lenguajes: React.FC = () => {
  const frame = useCurrentFrame();
  const salida = frame >= m("computadora");
  const flecha = interpolate(frame, [m("computadora") - 10, m("computadora")], [0, 1], CLAMP);
  return (
    <Escena id="lenguajes" etiqueta="03 · LENGUAJES" titulo="Idiomas para hablar con la máquina" color={C.violeta}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 26 }}>
        <div style={{ display: "flex", gap: 40 }}>
          <Aparecer desde={m("python")}>
            <Ventana titulo="hola.py — Python" ancho={760} acento={C.ambar}>
              <Codigo lineas={PY} desde={m("python") + 6} tamano={30} cursor={false} />
            </Ventana>
          </Aparecer>
          <Aparecer desde={m("javascript")}>
            <Ventana titulo="hola.js — JavaScript" ancho={860} acento={C.ambar}>
              <Codigo lineas={JS} desde={m("javascript") + 6} tamano={30} cursor={false} />
            </Ventana>
          </Aparecer>
        </div>
        <div style={{ fontFamily: MONO, fontSize: 40, color: C.tenue, opacity: flecha }}>↓ la computadora lo traduce y lo ejecuta</div>
        <Aparecer desde={m("computadora")}>
          <div style={{ width: 760, background: "#050914", border: `2px solid ${C.verde}55`, borderRadius: 18, padding: "20px 30px", fontFamily: MONO, fontSize: 40, color: C.verde }}>
            {"> "}
            {salida ? "¡Hola, Ana!" : ""}
          </div>
        </Aparecer>
      </div>
      <Sfx id="teclado" en={m("python") + 6} volumen={0.3} dur={duracionTipeo(PY)} />
      <Sfx id="teclado" en={m("javascript") + 6} volumen={0.3} dur={duracionTipeo(JS)} />
      <Sfx id="exito" en={m("computadora") + 4} volumen={0.35} />
    </Escena>
  );
};
