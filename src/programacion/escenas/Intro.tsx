import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { Escena, marcas, Pop, Sfx, usePop } from "../comunes";
import { C, CLAMP, MONO, SANS } from "../tema";

const m = marcas("intro");

const Telefono = () => (
  <svg width={180} height={260} viewBox="0 0 180 260">
    <rect x={10} y={10} width={160} height={240} rx={28} fill="#1e293b" stroke={C.cian} strokeWidth={6} />
    {[0, 1, 2, 3, 4, 5].map((i) => (
      <rect key={i} x={36 + (i % 2) * 60} y={50 + Math.floor(i / 2) * 60} width={46} height={46} rx={12} fill={[C.cian, C.violeta, C.verde, C.ambar, C.rosa, C.naranja][i]} />
    ))}
  </svg>
);
const Control = () => (
  <svg width={280} height={200} viewBox="0 0 280 200">
    <path d="M60 40 H220 C260 40 275 90 270 140 C266 180 230 190 210 160 L190 130 H90 L70 160 C50 190 14 180 10 140 C5 90 20 40 60 40 Z" fill="#1e293b" stroke={C.violeta} strokeWidth={6} />
    <rect x={62} y={78} width={14} height={46} rx={4} fill={C.violeta} />
    <rect x={46} y={94} width={46} height={14} rx={4} fill={C.violeta} />
    <circle cx={200} cy={84} r={12} fill={C.verde} />
    <circle cx={226} cy={108} r={12} fill={C.rosa} />
    <circle cx={174} cy={108} r={12} fill={C.ambar} />
  </svg>
);
const Navegador = () => (
  <svg width={280} height={210} viewBox="0 0 280 210">
    <rect x={8} y={8} width={264} height={194} rx={18} fill="#1e293b" stroke={C.verde} strokeWidth={6} />
    <line x1={8} y1={48} x2={272} y2={48} stroke={C.verde} strokeWidth={4} />
    {[30, 52, 74].map((x, i) => <circle key={x} cx={x} cy={28} r={7} fill={["#f87171", "#fbbf24", "#4ade80"][i]} />)}
    <rect x={30} y={70} width={120} height={16} rx={8} fill="#ffffff55" />
    <rect x={30} y={100} width={220} height={12} rx={6} fill="#ffffff22" />
    <rect x={30} y={124} width={190} height={12} rx={6} fill="#ffffff22" />
    <rect x={30} y={150} width={90} height={32} rx={10} fill={C.verde} />
  </svg>
);

export const Intro: React.FC = () => {
  const frame = useCurrentFrame();
  const junta = interpolate(frame, [m("todo"), m("todo") + 18], [0, 1], CLAMP);
  const marca = usePop(m("todo") + 10, 10);
  const titulo = usePop(m("programacion"), 200);
  const iconos = [
    { C: Telefono, en: m("aplicaciones"), x: -520 },
    { C: Control, en: m("videojuegos"), x: 0 },
    { C: Navegador, en: m("paginas"), x: 520 },
  ];
  return (
    <Escena id="intro">
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
        {iconos.map(({ C: I, en, x }, i) => (
          <div
            key={i}
            style={{
              position: "absolute",
              inset: 0,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              transform: `translateX(${x * (1 - junta)}px) translateY(${Math.sin(frame / 20 + i) * 10 - 40}px) scale(${1 - junta * 0.7})`,
              opacity: 1 - junta,
            }}
          >
            <Pop desde={en}>
              <I />
            </Pop>
          </div>
        ))}
        <div style={{ position: "absolute", textAlign: "center", transform: `scale(${marca})`, opacity: Math.min(1, marca * 2), marginTop: -80 }}>
          <div style={{ fontFamily: MONO, fontWeight: 700, fontSize: 220, color: C.cian, textShadow: `0 0 ${40 + 15 * Math.sin(frame / 8)}px ${C.cian}88` }}>
            {"</>"}
          </div>
        </div>
        <div style={{ position: "absolute", top: 640, fontFamily: SANS, fontWeight: 700, fontSize: 84, color: C.texto, opacity: titulo, transform: `translateY(${(1 - titulo) * 30}px)` }}>
          ¿Cómo funciona la <span style={{ color: C.cian }}>programación</span>?
        </div>
      </AbsoluteFill>
      <Sfx id="pop" en={m("aplicaciones")} />
      <Sfx id="pop" en={m("videojuegos")} />
      <Sfx id="pop" en={m("paginas")} />
      <Sfx id="whoosh" en={m("todo")} volumen={0.45} />
      <Sfx id="encendido" en={m("todo") + 8} volumen={0.35} />
      <Sfx id="brillo" en={m("programacion")} volumen={0.35} />
    </Escena>
  );
};
