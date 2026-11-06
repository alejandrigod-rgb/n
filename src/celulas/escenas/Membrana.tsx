import { interpolate, useCurrentFrame } from "remotion";
import { Celula } from "../Celula";
import { Escena } from "../Escena";
import { CLAMP, COLORES } from "../tema";

const PARTICULAS = new Array(14).fill(0).map((_, i) => ({
  angulo: (i / 14) * Math.PI * 2 + 0.2,
  entra: i % 3 !== 0,
  fase: (i * 17) % 90,
}));

export const Membrana: React.FC<{ duracion: number }> = ({ duracion }) => {
  const frame = useCurrentFrame();
  return (
    <Escena
      duracion={duracion}
      etiqueta="1 · Membrana celular"
      titulo="La frontera de la célula"
      color={COLORES.membrana}
      subtitulos={[
        { desde: 10, texto: "La membrana envuelve la célula y la separa del exterior." },
        { desde: 120, texto: "Decide qué entra (nutrientes, agua) y qué se queda fuera." },
      ]}
    >
      <div style={{ display: "flex", alignItems: "center", gap: 60, marginTop: -40 }}>
        <Celula tamano={660} resaltar="membrana">
          {PARTICULAS.map((p, i) => {
            const ciclo = ((frame + p.fase) % 90) / 90;
            const r = p.entra
              ? interpolate(ciclo, [0, 1], [390, 150])
              : interpolate(ciclo, [0, 0.5, 1], [390, 268, 390]);
            const op = interpolate(ciclo, [0, 0.1, 0.85, 1], [0, 1, 1, 0], CLAMP);
            return (
              <circle
                key={i}
                cx={Math.cos(p.angulo) * r}
                cy={Math.sin(p.angulo) * r}
                r={11}
                fill={p.entra ? COLORES.bien : COLORES.mal}
                opacity={op}
              />
            );
          })}
        </Celula>
        <div style={{ display: "flex", flexDirection: "column", gap: 30, fontSize: 40, color: COLORES.texto }}>
          <Leyenda color={COLORES.bien} texto="Pasa" />
          <Leyenda color={COLORES.mal} texto="No pasa" />
        </div>
      </div>
    </Escena>
  );
};

const Leyenda: React.FC<{ color: string; texto: string }> = ({ color, texto }) => (
  <div style={{ display: "flex", alignItems: "center", gap: 20 }}>
    <div style={{ width: 36, height: 36, borderRadius: 18, background: color }} />
    {texto}
  </div>
);
