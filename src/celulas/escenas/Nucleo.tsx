import { interpolate, useCurrentFrame } from "remotion";
import { Celula } from "../Celula";
import { Escena } from "../Escena";
import { CLAMP, COLORES } from "../tema";

const PARES = 22;

const Helice: React.FC = () => {
  const frame = useCurrentFrame();
  const elementos = [];
  for (let i = 0; i < PARES; i++) {
    const fase = i * 0.55 + frame * 0.08;
    const x = 40 + i * 32;
    const y = Math.sin(fase) * 110;
    const z = Math.cos(fase);
    const aparece = interpolate(frame, [30 + i * 3, 45 + i * 3], [0, 1], CLAMP);
    elementos.push(
      <g key={i} opacity={aparece}>
        <line x1={x} y1={180 + y} x2={x} y2={180 - y} stroke="#64748b" strokeWidth={5} />
        <circle cx={x} cy={180 + y} r={11 + 4 * z} fill={COLORES.adn1} opacity={0.6 + 0.4 * z} />
        <circle cx={x} cy={180 - y} r={11 - 4 * z} fill={COLORES.adn2} opacity={0.6 - 0.4 * z} />
      </g>,
    );
  }
  return (
    <svg width={760} height={360}>
      {elementos}
    </svg>
  );
};

export const Nucleo: React.FC<{ duracion: number }> = ({ duracion }) => {
  const frame = useCurrentFrame();
  const flecha = interpolate(frame, [20, 40], [0, 1], CLAMP);
  return (
    <Escena
      duracion={duracion}
      etiqueta="2 · Núcleo"
      titulo="El centro de control"
      color={COLORES.nucleo}
      subtitulos={[
        { desde: 10, texto: "El núcleo guarda el ADN: el manual de instrucciones de la célula." },
        { desde: 130, texto: "Los genes del ADN indican qué proteínas fabricar y cuándo." },
      ]}
    >
      <div style={{ display: "flex", alignItems: "center", gap: 20, marginTop: -40 }}>
        <Celula tamano={560} resaltar="nucleo" />
        <div style={{ color: COLORES.nucleo, fontSize: 90, opacity: flecha }}>→</div>
        <div
          style={{
            borderRadius: 40,
            border: `4px solid ${COLORES.nucleo}`,
            background: "rgba(76, 29, 149, 0.35)",
            padding: 20,
            opacity: flecha,
          }}
        >
          <Helice />
          <div style={{ color: COLORES.texto, fontSize: 36, textAlign: "center" }}>ADN</div>
        </div>
      </div>
    </Escena>
  );
};
