import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { aparecer, Brocha, Fondo, Hoja, Pop, Sfx, t, usePop, Voz } from "../comunes";
import { C, CLAMP, TITULO } from "../tema";

const Sol: React.FC = () => {
  const frame = useCurrentFrame();
  const s = usePop(0, 9);
  return (
    <svg
      width={420}
      height={420}
      viewBox="-210 -210 420 420"
      style={{ position: "absolute", left: 60, top: 120, transform: `scale(${s}) translateY(${Math.sin(frame / 10) * 8}px)` }}
    >
      <g transform={`rotate(${frame * 0.8})`}>
        {new Array(12).fill(0).map((_, i) => (
          <rect key={i} x={-12} y={-195} width={24} height={60} rx={12} fill={C.amarillo} transform={`rotate(${i * 30})`} />
        ))}
      </g>
      <circle r={115} fill="#ffe14d" stroke="#f4b400" strokeWidth={8} />
      <circle cx={-38} cy={-22} r={12} fill={C.texto} />
      <circle cx={38} cy={-22} r={12} fill={C.texto} />
      <circle cx={-62} cy={18} r={16} fill="#ff9aa2" opacity={0.7} />
      <circle cx={62} cy={18} r={16} fill="#ff9aa2" opacity={0.7} />
      <path d="M-45 25 Q0 75 45 25" stroke={C.texto} strokeWidth={10} fill="none" strokeLinecap="round" />
    </svg>
  );
};

const Nube: React.FC<{ y: number; vel: number; escala: number; desfase: number }> = ({ y, vel, escala, desfase }) => {
  const frame = useCurrentFrame();
  const x = ((desfase + frame * vel) % 1500) - 300;
  return (
    <svg width={300 * escala} height={140 * escala} viewBox="0 0 300 140" style={{ position: "absolute", left: x, top: y, opacity: 0.9 }}>
      <path d="M50 120 C10 120 10 70 55 70 C60 25 130 20 145 60 C165 30 230 40 225 85 C270 85 270 120 240 120 Z" fill="#fff" />
    </svg>
  );
};

const Linea: React.FC<{ texto: string; desde: number; contorno?: boolean }> = ({ texto, desde, contorno = true }) => {
  const s = usePop(desde, 12);
  return (
    <div
      style={{
        fontFamily: TITULO,
        fontWeight: 800,
        fontSize: 118,
        lineHeight: 1.05,
        color: C.blanco,
        WebkitTextStroke: contorno ? `14px ${C.verdeOsc}` : undefined,
        paintOrder: "stroke fill",
        transform: `scale(${s}) rotate(-3deg)`,
        opacity: Math.min(1, s * 2),
        textShadow: "0 10px 0 rgba(0,0,0,0.12)",
      }}
    >
      {texto}
    </div>
  );
};

export const Gancho: React.FC = () => {
  const frame = useCurrentFrame();
  const brocha = interpolate(frame, [t(0.9), t(1.3)], [0, 1], CLAMP);
  return (
    <Fondo arriba={C.cielo} abajo={C.cielo2}>
      <Nube y={700} vel={1.2} escala={1.2} desfase={200} />
      <Nube y={1450} vel={0.8} escala={0.9} desfase={900} />
      <Nube y={300} vel={0.6} escala={0.7} desfase={1300} />
      <Sol />
      <Hoja x={830} y={-40} tamano={260} rot={210} />
      <Hoja x={940} y={110} tamano={180} rot={250} color={C.verdeClaro} />
      <Hoja x={-60} y={1600} tamano={300} rot={40} />
      <Hoja x={120} y={1720} tamano={200} rot={10} color={C.verdeClaro} />
      <AbsoluteFill style={{ justifyContent: "center", alignItems: "center", textAlign: "center", paddingTop: 200 }}>
        <Linea texto="¿Quieres saber" desde={t(0)} />
        <Pop desde={t(0.8)} style={{ margin: "18px 0" }}>
          <Brocha tamano={150} progreso={brocha} rot={-4}>
            cómo estás
          </Brocha>
        </Pop>
        <Linea texto="comenzando" desde={t(1.4)} />
        <Linea texto="el verano?" desde={t(1.8)} />
        <div
          style={{
            marginTop: 40,
            height: 14,
            width: 620,
            borderRadius: 7,
            background: C.amarillo,
            transform: `scaleX(${aparecer(frame, t(2.2), 15)})`,
          }}
        />
      </AbsoluteFill>
      <Voz id="gancho" />
      <Sfx id="whoosh" en={0} volumen={0.5} />
      <Sfx id="pop" en={t(0)} />
      <Sfx id="pop" en={t(0.8)} />
      <Sfx id="pop" en={t(1.4)} />
      <Sfx id="brillo" en={t(2.1)} volumen={0.45} />
    </Fondo>
  );
};
