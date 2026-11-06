import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { Brocha, Fondo, Rayitas, Sfx, t, usePop, Voz } from "../comunes";
import { Corazon, Manzana, Personas, Rayo } from "../iconos";
import { C, CLAMP, MANUSCRITA } from "../tema";

const ITEMS = [
  { icono: Manzana, linea1: "Mejor", linea2: "alimentación", fondo: "#a6e07a", color: C.verde, en: 1.07, sfx: "mordida" },
  { icono: Corazon, linea1: "Más", linea2: "salud", fondo: "#ffe46b", color: "#e0a800", en: 2.29, sfx: "latido" },
  { icono: Rayo, linea1: "Más", linea2: "energía", fondo: "#7fd0f7", color: C.azul, en: 3.0, sfx: "energia" },
  { icono: Personas, linea1: "Equipos", linea2: "más fuertes", fondo: "#c4a6ec", color: C.morado, en: 4.38, sfx: "aplausos" },
];

const Beneficio: React.FC<{ item: (typeof ITEMS)[number]; indice: number }> = ({ item, indice }) => {
  const frame = useCurrentFrame();
  const desde = t(item.en);
  const s = usePop(desde, 9);
  const rayas = interpolate(frame, [desde + 5, desde + 15], [0, 1], CLAMP);
  const Icono = item.icono;
  // Animación propia de cada icono.
  const vivo = frame - desde;
  const extra =
    indice === 1
      ? 1 + 0.08 * Math.max(0, Math.sin(vivo / 4))
      : indice === 2
        ? 1 + (vivo % 20 < 3 ? 0.12 : 0)
        : 1 + 0.03 * Math.sin(vivo / 6);
  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", width: 460, opacity: Math.min(1, s * 2) }}>
      <div style={{ position: "relative", transform: `scale(${s})` }}>
        <Rayitas color={item.color} radio={170} progreso={rayas} />
        <div
          style={{
            width: 340,
            height: 340,
            borderRadius: 999,
            background: item.fondo,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            boxShadow: `inset 0 -16px 0 ${item.color}55`,
          }}
        >
          <div style={{ transform: `scale(${extra})` }}>
            <Icono tamano={220} />
          </div>
        </div>
      </div>
      <div style={{ fontFamily: MANUSCRITA, fontWeight: 700, fontSize: 64, color: C.texto, textAlign: "center", lineHeight: 1.05, marginTop: 30, transform: "rotate(-3deg)" }}>
        {item.linea1}
        <br />
        {item.linea2}
      </div>
    </div>
  );
};

export const Beneficios: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Fondo arriba={C.crema} abajo="#fff7d6">
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
        <Brocha tamano={110} progreso={interpolate(frame, [t(0), t(0.5)], [0, 1], CLAMP)}>
          El resultado
        </Brocha>
        <div style={{ display: "flex", flexWrap: "wrap", width: 960, justifyContent: "space-between", rowGap: 80, marginTop: 120 }}>
          {ITEMS.map((it, i) => (
            <Beneficio key={it.linea2} item={it} indice={i} />
          ))}
        </div>
      </AbsoluteFill>
      <Voz id="beneficios" />
      <Sfx id="whoosh" en={0} volumen={0.45} />
      {ITEMS.map((it) => (
        <Sfx key={it.sfx} id={it.sfx} en={t(it.en)} volumen={0.6} />
      ))}
      {ITEMS.map((it) => (
        <Sfx key={`p${it.sfx}`} id="pop" en={t(it.en)} volumen={0.4} />
      ))}
    </Fondo>
  );
};
