import { AbsoluteFill, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { Brocha, Fondo, Sfx, t, Voz } from "../comunes";
import { Pizarra, Plato, Portapapeles } from "../iconos";
import { C, MANUSCRITA, TITULO } from "../tema";

const SERVICIOS = [
  { icono: Portapapeles, titulo: "Evaluación nutricional", detalle: "para cada colaborador", color: C.verde, en: 0 },
  { icono: Pizarra, titulo: "Charlas y talleres", detalle: "prácticos y dinámicos", color: C.naranja, en: 2.07 },
  { icono: Plato, titulo: "Planes de alimentación", detalle: "hechos a la medida", color: C.azul, en: 5.03 },
];

export const Servicios: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  return (
    <Fondo arriba="#ffffff" abajo={C.crema}>
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
        <Brocha tamano={110} progreso={spring({ frame, fps, config: { damping: 200 } })} color={C.verdeClaro}>
          ¿Qué hacemos?
        </Brocha>
        <div style={{ display: "flex", flexDirection: "column", gap: 56, marginTop: 110 }}>
          {SERVICIOS.map((s, i) => {
            const p = spring({ frame: frame - t(s.en), fps, config: { damping: 14 } });
            const Icono = s.icono;
            return (
              <div
                key={s.titulo}
                style={{
                  width: 900,
                  display: "flex",
                  alignItems: "center",
                  gap: 40,
                  background: "#fff",
                  borderRadius: 44,
                  padding: "34px 40px",
                  borderLeft: `22px solid ${s.color}`,
                  boxShadow: "0 18px 40px rgba(22,58,34,0.14)",
                  transform: `translateX(${(1 - p) * (i % 2 ? -1100 : 1100)}px) rotate(${(i % 2 ? 1 : -1) * 1.5}deg)`,
                }}
              >
                <div style={{ background: `${s.color}22`, borderRadius: 999, padding: 20 }}>
                  <Icono tamano={160} />
                </div>
                <div>
                  <div style={{ fontFamily: TITULO, fontWeight: 800, fontSize: 64, color: C.texto, lineHeight: 1.05 }}>{s.titulo}</div>
                  <div style={{ fontFamily: MANUSCRITA, fontWeight: 700, fontSize: 48, color: s.color, marginTop: 6 }}>{s.detalle}</div>
                </div>
              </div>
            );
          })}
        </div>
      </AbsoluteFill>
      <Voz id="servicios" />
      {SERVICIOS.map((s) => (
        <Sfx key={s.titulo} id="whoosh" en={t(s.en)} volumen={0.45} />
      ))}
    </Fondo>
  );
};
