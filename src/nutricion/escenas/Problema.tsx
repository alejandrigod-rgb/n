import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { Fondo, Pop, Sfx, t, Voz } from "../comunes";
import { Hamburguesa, Nube, Zzz } from "../iconos";
import { C, CLAMP, MANUSCRITA, TITULO } from "../tema";

const Bateria: React.FC<{ nivel: number }> = ({ nivel }) => {
  const color = nivel > 0.6 ? C.verde : nivel > 0.3 ? C.naranja : C.rojo;
  return (
    <svg width={300} height={520} viewBox="0 0 300 520">
      <rect x={110} y={0} width={80} height={40} rx={10} fill="#5b6472" />
      <rect x={20} y={30} width={260} height={480} rx={40} fill="#fff" stroke="#5b6472" strokeWidth={16} />
      <rect x={44} y={54 + 432 * (1 - nivel)} width={212} height={432 * nivel} rx={22} fill={color} />
      <text x={150} y={300} textAnchor="middle" fontSize={84} fontWeight={800} fontFamily="'Baloo 2'" fill={C.texto}>
        {Math.round(nivel * 100)}%
      </text>
    </svg>
  );
};

const Etiqueta: React.FC<{ icono: React.ReactNode; texto: string; desde: number; lado: "izq" | "der" }> = ({ icono, texto, desde, lado }) => (
  <Pop desde={desde}>
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: 20,
        background: "#fff",
        borderRadius: 999,
        padding: "14px 40px 14px 18px",
        boxShadow: "0 12px 30px rgba(30,40,60,0.18)",
        transform: `rotate(${lado === "izq" ? -4 : 4}deg)`,
      }}
    >
      {icono}
      <span style={{ fontFamily: TITULO, fontWeight: 800, fontSize: 58, color: "#3b4252" }}>{texto}</span>
    </div>
  </Pop>
);

export const Problema: React.FC = () => {
  const frame = useCurrentFrame();
  const nivel = interpolate(frame, [t(0.2), t(3.6)], [1, 0.12], CLAMP);
  const tiembla = frame > t(3.6) ? Math.sin(frame * 1.5) * 4 : 0;
  return (
    <Fondo arriba="#cfd9e4" abajo="#eef2f6">
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
        <div style={{ fontFamily: MANUSCRITA, fontWeight: 700, fontSize: 76, color: "#3b4252", transform: "rotate(-3deg)" }}>
          ¿Tu equipo se siente así?
        </div>
        <div style={{ marginTop: 70, transform: `translateX(${tiembla}px)` }}>
          <Bateria nivel={nivel} />
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: 34, marginTop: 70, alignItems: "center" }}>
          <Etiqueta icono={<Nube tamano={100} />} texto="Estrés" desde={t(0.1)} lado="izq" />
          <Etiqueta icono={<Zzz tamano={100} />} texto="Cansancio" desde={t(0.9)} lado="der" />
          <Etiqueta icono={<Hamburguesa tamano={100} />} texto="Mala alimentación" desde={t(1.9)} lado="izq" />
        </div>
      </AbsoluteFill>
      <Voz id="problema" />
      <Sfx id="whoosh" en={0} volumen={0.5} />
      <Sfx id="pop" en={t(0.1)} />
      <Sfx id="pop" en={t(0.9)} />
      <Sfx id="pop" en={t(1.9)} />
      <Sfx id="desinflar" en={t(3.0)} volumen={0.55} />
    </Fondo>
  );
};
