import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { Fondo, Hoja, Pop, Sfx, t, Voz } from "../comunes";
import { C, CLAMP, MANUSCRITA, TITULO } from "../tema";

const BARRAS = [0.3, 0.45, 0.62, 0.8, 1];

export const Productividad: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const flecha = interpolate(frame, [t(2.6), t(3.6)], [0, 1], CLAMP);
  const subrayado = interpolate(frame, [t(5.6), t(6.4)], [0, 1], CLAMP);
  return (
    <Fondo arriba="#2fb457" abajo="#16743a">
      <Hoja x={-70} y={1500} tamano={320} rot={30} color={C.verdeClaro} />
      <Hoja x={850} y={-50} tamano={280} rot={200} color={C.verdeClaro} />
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", textAlign: "center" }}>
        <Pop desde={t(0)}>
          <div style={{ fontFamily: TITULO, fontWeight: 800, fontSize: 104, color: "#fff", lineHeight: 1.02 }}>
            ¡Tu mejor
            <br />
            <span style={{ color: C.amarillo }}>versión!</span>
          </div>
        </Pop>
        <svg width={860} height={620} viewBox="0 0 860 620" style={{ marginTop: 60 }}>
          <line x1={40} y1={580} x2={820} y2={580} stroke="#ffffff88" strokeWidth={8} strokeLinecap="round" />
          {BARRAS.map((b, i) => {
            const p = spring({ frame: frame - t(1.6) - i * 5, fps, config: { damping: 13 } });
            const h = 480 * b * p;
            return <rect key={i} x={70 + i * 150} y={570 - h} width={110} height={h} rx={18} fill={i === 4 ? C.amarillo : "#ffffffdd"} />;
          })}
          <path
            d="M90 470 L270 400 L420 330 L570 230 L760 80"
            stroke={C.amarillo}
            strokeWidth={18}
            fill="none"
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeDasharray={900}
            strokeDashoffset={900 * (1 - flecha)}
          />
          <polygon points="790,50 720,70 770,120" fill={C.amarillo} opacity={flecha > 0.95 ? 1 : 0} />
        </svg>
        <div style={{ fontFamily: TITULO, fontWeight: 600, fontSize: 54, color: "#e8ffe9", marginTop: 20, opacity: interpolate(frame, [t(2.6), t(3.0)], [0, 1], CLAMP) }}>
          + productividad laboral
        </div>
        <Pop desde={t(4.5)} style={{ marginTop: 90 }}>
          <div style={{ background: "#fff", borderRadius: 40, padding: "26px 50px", transform: "rotate(-3deg)", boxShadow: "0 18px 40px rgba(0,0,0,0.2)" }}>
            <div style={{ fontFamily: MANUSCRITA, fontWeight: 700, fontSize: 70, color: C.verdeOsc, lineHeight: 1.1 }}>
              Tu bienestar también
              <br />
              es productividad
            </div>
            <div style={{ height: 12, background: C.amarillo, borderRadius: 6, marginTop: 8, transformOrigin: "left", transform: `scaleX(${subrayado})` }} />
          </div>
        </Pop>
      </AbsoluteFill>
      <Voz id="productividad" />
      <Sfx id="whoosh" en={0} volumen={0.45} />
      <Sfx id="pop" en={t(1.6)} volumen={0.4} />
      <Sfx id="energia" en={t(2.6)} volumen={0.35} />
      <Sfx id="brillo" en={t(4.5)} volumen={0.5} />
    </Fondo>
  );
};
