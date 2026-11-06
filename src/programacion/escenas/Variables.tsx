import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { Aparecer, Codigo, Escena, marcas, Pop, Segmento, Sfx } from "../comunes";
import { C, CLAMP, MONO } from "../tema";

const m = marcas("variables");
const LINEA: Segmento[][] = [[["edad", C.cian], [" = ", C.texto], ["15", C.ambar]]];

export const Variables: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const caida = spring({ frame: frame - m("quince"), fps, config: { damping: 12 } });
  const etiqueta = frame >= m("edad");
  const tapa = interpolate(frame, [m("quince") + 12, m("quince") + 22], [0, 1], CLAMP);
  return (
    <Escena id="variables" etiqueta="05 · VARIABLES" titulo="Cajas que guardan datos" color={C.cian}>
      <div style={{ display: "flex", alignItems: "center", gap: 140 }}>
        <Pop desde={m("cajas")}>
          <svg width={460} height={480} viewBox="0 0 460 480">
            <text x={230} y={-40 + 420 * caida} textAnchor="middle" fontFamily="JetBrains Mono" fontWeight={700} fontSize={110} fill={C.ambar} opacity={frame >= m("quince") - 5 ? 1 : 0}>
              15
            </text>
            <polygon points="60,200 230,260 400,200 400,420 230,480 60,420" fill="#1d4f7a" />
            <polygon points="230,260 400,200 400,420 230,480" fill="#16405f" />
            <polygon points={`60,200 230,${140 + 120 * tapa} 400,200 230,260`} fill="#2a6ea8" opacity={0.6 + 0.4 * tapa} />
            <g opacity={etiqueta ? 1 : 0}>
              <rect x={95} y={300} width={140} height={64} rx={12} fill="#fff" transform="skewY(19)" />
              <text x={165} y={346} textAnchor="middle" fontFamily="JetBrains Mono" fontWeight={700} fontSize={36} fill="#0b1022" transform="skewY(19)">
                edad
              </text>
            </g>
          </svg>
        </Pop>
        <div>
          <Aparecer desde={m("nombre")}>
            <div style={{ fontFamily: MONO, fontSize: 34, color: C.tenue, marginBottom: 20 }}>nombre = valor</div>
          </Aparecer>
          <Aparecer desde={m("edad")}>
            <div style={{ background: C.panel, border: `2px solid ${C.borde}`, borderRadius: 18, padding: "24px 34px" }}>
              <Codigo lineas={LINEA} desde={m("edad")} cps={8} tamano={56} cursor={false} />
            </div>
          </Aparecer>
        </div>
      </div>
      <Sfx id="pop" en={m("cajas")} />
      <Sfx id="tic" en={m("edad")} volumen={0.45} />
      <Sfx id="pop" en={m("quince") + 8} volumen={0.5} />
      <Sfx id="exito" en={m("quince") + 22} volumen={0.3} />
    </Escena>
  );
};
