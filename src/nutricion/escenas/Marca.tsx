import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { Fondo, Hoja, Pop, Sfx, t, usePop, Voz } from "../comunes";
import { FiguraLogo, Megafono } from "../iconos";
import { C, CLAMP, TITULO } from "../tema";

export const Logo: React.FC<{ escala?: number }> = ({ escala = 1 }) => (
  <div style={{ display: "flex", alignItems: "center", gap: 10 * escala }}>
    <div style={{ textAlign: "right", fontFamily: TITULO, lineHeight: 1 }}>
      <div style={{ fontSize: 86 * escala, fontWeight: 600, color: "#2a8fc4" }}>alimentación</div>
      <div style={{ fontSize: 86 * escala, fontWeight: 600, color: C.verde }}>y equilibrio</div>
      <div style={{ fontSize: 36 * escala, fontWeight: 800, color: "#2a6fb0", marginTop: 8 * escala }}>De Giovanna Olivas</div>
    </div>
    <FiguraLogo tamano={230 * escala} />
  </div>
);

const Etiqueta: React.FC<{ texto: string; color: string; desde: number }> = ({ texto, color, desde }) => (
  <Pop desde={desde}>
    <div
      style={{
        background: color,
        color: "#fff",
        fontFamily: TITULO,
        fontWeight: 800,
        fontSize: 56,
        padding: "8px 38px",
        borderRadius: 999,
        boxShadow: "0 10px 24px rgba(0,0,0,0.15)",
      }}
    >
      {texto}
    </div>
  </Pop>
);

export const Marca: React.FC = () => {
  const frame = useCurrentFrame();
  const logo = usePop(t(0), 13);
  const banda = interpolate(frame, [t(1.9), t(2.4)], [0, 1], CLAMP);
  const megafono = Math.sin(frame / 2.5) * (frame > t(1.9) && frame < t(5) ? 6 : 0);
  return (
    <Fondo arriba={C.crema} abajo="#e7f6dc">
      <Hoja x={-80} y={-60} tamano={300} rot={140} color={C.verdeClaro} />
      <Hoja x={860} y={1650} tamano={320} rot={-30} />
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
        <div style={{ transform: `scale(${logo})`, opacity: Math.min(1, logo * 2) }}>
          <Logo />
        </div>
        <div style={{ marginTop: 130, display: "flex", alignItems: "center", gap: 10, opacity: banda }}>
          <div style={{ transform: `rotate(${-10 + megafono}deg) scale(${banda})` }}>
            <Megafono tamano={170} />
          </div>
          <div
            style={{
              background: C.verde,
              color: "#fff",
              fontFamily: TITULO,
              fontWeight: 800,
              fontSize: 64,
              lineHeight: 1.05,
              padding: "26px 46px",
              borderRadius: "30px 60px 30px 60px",
              transform: `rotate(-2deg) translateX(${(1 - banda) * 300}px)`,
              boxShadow: "0 14px 30px rgba(23,89,42,0.3)",
            }}
          >
            Campañas preventivas
            <br />
            <span style={{ color: C.amarillo }}>corporativas</span>
          </div>
        </div>
        <div style={{ marginTop: 120, fontFamily: TITULO, fontWeight: 600, fontSize: 52, color: C.texto, opacity: interpolate(frame, [t(5.4), t(5.8)], [0, 1], CLAMP) }}>
          Para cuidar de tu equipo:
        </div>
        <div style={{ display: "flex", gap: 26, marginTop: 34 }}>
          <Etiqueta texto="Nutrición" color={C.verde} desde={t(6.0)} />
          <Etiqueta texto="Salud" color={C.rojo} desde={t(7.2)} />
          <Etiqueta texto="Energía" color={C.azul} desde={t(8.4)} />
        </div>
      </AbsoluteFill>
      <Voz id="marca" />
      <Sfx id="brillo" en={t(0)} volumen={0.5} />
      <Sfx id="whoosh" en={t(1.9)} volumen={0.5} />
      <Sfx id="pop" en={t(6.0)} />
      <Sfx id="pop" en={t(7.2)} />
      <Sfx id="pop" en={t(8.4)} />
    </Fondo>
  );
};
