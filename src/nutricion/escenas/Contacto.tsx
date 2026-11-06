import { AbsoluteFill, Easing, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { Fondo, Pop, Sfx, t, Voz } from "../comunes";
import { Chat, Manzana } from "../iconos";
import { C, CLAMP, TITULO } from "../tema";
import { Logo } from "./Marca";

const GRUPOS = [
  { texto: "990", en: 1.59 },
  { texto: "103", en: 3.03 },
  { texto: "447", en: 4.17 },
];

const Verduras: React.FC<{ progreso: number }> = ({ progreso }) => (
  <svg width={1080} height={420} viewBox="0 0 1080 420" style={{ position: "absolute", bottom: 0, transform: `translateY(${(1 - progreso) * 420}px)` }}>
    <path d="M0 180 C300 90 700 260 1080 140 L1080 420 L0 420 Z" fill={C.verde} />
    <path d="M0 260 C320 180 760 320 1080 230 L1080 420 L0 420 Z" fill={C.verdeOsc} opacity={0.5} />
    {/* Lechuga */}
    {[0, 1, 2, 3, 4].map((i) => (
      <ellipse key={i} cx={820 + i * 45} cy={200 - (i % 2) * 30} rx={70} ry={50} fill={i % 2 ? "#5dbb3a" : "#7ed957"} />
    ))}
    {/* Pimiento */}
    <path d="M960 250 C920 250 920 340 960 360 C990 380 1040 370 1050 320 C1060 270 1010 240 960 250 Z" fill={C.naranja} />
    <rect x={985} y={225} width={14} height={30} rx={6} fill={C.verdeOsc} />
    {/* Zanahoria */}
    <path d="M120 300 L250 200 L270 225 Z" fill="#ff8c1a" />
    <path d="M255 205 L300 180 M260 210 L300 210 M258 200 L280 165" stroke={C.verde} strokeWidth={8} strokeLinecap="round" />
  </svg>
);

export const Contacto: React.FC<{ duracion: number }> = ({ duracion }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const boton = spring({ frame: frame - t(0), fps, config: { damping: 12 } });
  const clic = t(1.1);
  const cursor = interpolate(frame, [t(0.2), clic], [0, 1], { ...CLAMP, easing: Easing.out(Easing.cubic) });
  const presion = frame >= clic && frame < clic + 6 ? 0.94 : 1;
  const latido = 1 + 0.03 * Math.sin(frame / 5);
  const fin = spring({ frame: frame - t(5.7), fps, config: { damping: 200 } });

  return (
    <Fondo arriba={C.cielo2} abajo={C.crema}>
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
        <div style={{ fontFamily: TITULO, fontWeight: 800, fontSize: 92, color: C.texto, textAlign: "center", lineHeight: 1.05, opacity: boton }}>
          ¡Agenda tu campaña
          <br />
          <span style={{ color: C.verde }}>corporativa hoy!</span>
        </div>
        <div style={{ position: "relative", marginTop: 90, transform: `scale(${boton * presion * latido})` }}>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 30,
              background: `linear-gradient(180deg, #3cc95f, ${C.verde})`,
              border: "8px solid #fff",
              borderRadius: 999,
              padding: "30px 60px 30px 36px",
              boxShadow: "0 24px 50px rgba(23,89,42,0.35)",
            }}
          >
            <div style={{ background: C.verdeOsc, borderRadius: 999, padding: 14 }}>
              <Chat tamano={150} />
            </div>
            <div style={{ fontFamily: TITULO, color: "#fff", lineHeight: 1 }}>
              <div style={{ fontSize: 56, fontWeight: 600 }}>Escríbenos al WhatsApp</div>
              <div style={{ display: "flex", gap: 18, fontSize: 108, fontWeight: 800, marginTop: 6 }}>
                {GRUPOS.map((g) => {
                  const s = spring({ frame: frame - t(g.en), fps, config: { damping: 10 } });
                  return (
                    <span key={g.texto} style={{ display: "inline-block", transform: `scale(${0.6 + 0.4 * s}) translateY(${(1 - s) * 20}px)`, color: s > 0.5 ? C.amarillo : "#ffffff55" }}>
                      {g.texto}
                    </span>
                  );
                })}
              </div>
            </div>
          </div>
          <svg width={110} height={130} viewBox="0 0 110 130" style={{ position: "absolute", right: -40 + (1 - cursor) * 300, bottom: -70 - (1 - cursor) * 250, opacity: cursor }}>
            <path d="M10 10 L10 100 L34 78 L52 118 L70 110 L52 72 L86 72 Z" fill="#fff" stroke="#111" strokeWidth={7} strokeLinejoin="round" />
          </svg>
        </div>
        <div style={{ marginTop: 130, opacity: fin, transform: `translateY(${(1 - fin) * 60}px)` }}>
          <Logo escala={0.95} />
        </div>
        <Pop desde={t(7.4)} style={{ marginTop: 50 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
            <Manzana tamano={70} />
            <span style={{ fontFamily: TITULO, fontWeight: 800, fontSize: 48, color: C.texto }}>Tu bienestar también es productividad</span>
          </div>
        </Pop>
      </AbsoluteFill>
      <Verduras progreso={interpolate(frame, [t(5.7), t(6.5)], [0, 1], { ...CLAMP, easing: Easing.out(Easing.back(1.4)) })} />
      <Voz id="contacto" />
      <Sfx id="whoosh" en={0} volumen={0.45} />
      <Sfx id="clic" en={clic} volumen={0.7} />
      <Sfx id="mensaje" en={clic + 3} volumen={0.6} />
      {GRUPOS.map((g) => (
        <Sfx key={g.texto} id="pop" en={t(g.en)} volumen={0.35} />
      ))}
      <Sfx id="brillo" en={t(5.7)} volumen={0.5} />
      <Sfx id="aplausos" en={duracion - 75} volumen={0.3} />
    </Fondo>
  );
};
