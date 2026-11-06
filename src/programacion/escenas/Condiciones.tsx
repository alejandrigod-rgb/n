import { interpolate, random, useCurrentFrame } from "remotion";
import { Escena, marcas, Pop, Sfx } from "../comunes";
import { C, CLAMP, MONO, SANS } from "../tema";

const m = marcas("condiciones");

const Rama: React.FC<{ progreso: number; lado: -1 | 1; color: string; texto: string }> = ({ progreso, lado, color, texto }) => (
  <svg width={1200} height={170} viewBox="-600 0 1200 170" style={{ position: "absolute", top: 210 }}>
    <path d={`M0 0 L0 50 L${lado * 360} 50 L${lado * 360} 160`} stroke={color} strokeWidth={8} fill="none" strokeDasharray={600} strokeDashoffset={600 * (1 - progreso)} strokeLinejoin="round" />
    <text x={lado * 190} y={36} textAnchor="middle" fontFamily="JetBrains Mono" fontWeight={700} fontSize={36} fill={color} opacity={progreso}>
      {texto}
    </text>
  </svg>
);

export const Condiciones: React.FC = () => {
  const frame = useCurrentFrame();
  const si = interpolate(frame, [m("llueve") - 4, m("llueve") + 10], [0, 1], CLAMP);
  const no = interpolate(frame, [m("si", 1), m("si", 1) + 12], [0, 1], CLAMP);
  return (
    <Escena id="condiciones" etiqueta="06 · CONDICIONES" titulo="El programa toma decisiones" color={C.violeta}>
      <div style={{ position: "relative", width: 1200, height: 720, display: "flex", justifyContent: "center" }}>
        <Pop desde={m("si")} style={{ position: "absolute", top: 0 }}>
          <svg width={360} height={220} viewBox="0 0 360 220">
            <polygon points="180,10 350,110 180,210 10,110" fill="#2e1f5e" stroke={C.violeta} strokeWidth={8} />
            <text x={180} y={124} textAnchor="middle" fontFamily="Space Grotesk" fontWeight={700} fontSize={44} fill={C.texto}>¿Llueve?</text>
          </svg>
        </Pop>
        <Rama progreso={si} lado={-1} color={C.cian} texto="SÍ" />
        <Rama progreso={no} lado={1} color={C.ambar} texto="NO" />
        <div style={{ position: "absolute", top: 380, left: 600 - 360 - 150, width: 300, textAlign: "center" }}>
          <Pop desde={m("paraguas")}>
            <svg width={300} height={200} viewBox="0 0 300 200">
              {frame >= m("llueve")
                ? new Array(14).fill(0).map((_, i) => {
                    const y = ((frame * 9 + random(`ll${i}`) * 200) % 200) - 40;
                    const x = 20 + random(`lx${i}`) * 260;
                    return <line key={i} x1={x} y1={y} x2={x - 6} y2={y + 22} stroke={C.cian} strokeWidth={4} opacity={y < 50 ? 0.8 : 0} />;
                  })
                : null}
              <path d="M40 110 C40 30 260 30 260 110 Z" fill={C.cian} />
              <line x1={150} y1={110} x2={150} y2={180} stroke="#e2e8f0" strokeWidth={10} />
              <path d="M150 180 C150 198 124 198 124 182" stroke="#e2e8f0" strokeWidth={10} fill="none" strokeLinecap="round" />
            </svg>
            <div style={{ fontFamily: SANS, fontWeight: 700, fontSize: 38, color: C.texto }}>Paraguas</div>
          </Pop>
        </div>
        <div style={{ position: "absolute", top: 380, left: 600 + 360 - 150, width: 300, textAlign: "center" }}>
          <Pop desde={m("lentes")}>
            <svg width={300} height={200} viewBox="0 0 300 200">
              <circle cx={250} cy={40} r={26} fill={C.ambar} opacity={0.9} />
              <rect x={30} y={90} width={100} height={64} rx={26} fill="#111827" stroke={C.ambar} strokeWidth={6} />
              <rect x={170} y={90} width={100} height={64} rx={26} fill="#111827" stroke={C.ambar} strokeWidth={6} />
              <path d="M130 112 C140 100 160 100 170 112" stroke={C.ambar} strokeWidth={6} fill="none" />
            </svg>
            <div style={{ fontFamily: SANS, fontWeight: 700, fontSize: 38, color: C.texto }}>Lentes de sol</div>
          </Pop>
        </div>
        <div style={{ position: "absolute", bottom: 0, fontFamily: MONO, fontSize: 30, color: C.tenue, opacity: interpolate(frame, [m("sol"), m("sol") + 15], [0, 1], CLAMP) }}>
          <span style={{ color: C.violeta }}>si</span> llueve → paraguas · <span style={{ color: C.violeta }}>si no</span> → lentes
        </div>
      </div>
      <Sfx id="pop" en={m("si")} />
      <Sfx id="lluvia" en={m("llueve")} volumen={0.35} />
      <Sfx id="tic" en={m("paraguas")} volumen={0.45} />
      <Sfx id="brillo" en={m("lentes")} volumen={0.35} />
    </Escena>
  );
};
