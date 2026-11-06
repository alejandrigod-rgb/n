import {
  AbsoluteFill,
  Html5Audio,
  interpolate,
  Sequence,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { C, CLAMP, FPS, TITULO } from "./tema";

export const PRE = Math.round(0.35 * FPS);

/** Escala con rebote a partir de `desde`. */
export const usePop = (desde: number, damping = 11) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  return spring({ frame: frame - desde, fps, config: { damping } });
};

export const Pop: React.FC<{
  desde: number;
  children: React.ReactNode;
  style?: React.CSSProperties;
}> = ({ desde, children, style }) => {
  const s = usePop(desde);
  return (
    <div style={{ transform: `scale(${s})`, opacity: Math.min(1, s * 2), ...style }}>
      {children}
    </div>
  );
};

export const Sfx: React.FC<{ id: string; en: number; volumen?: number }> = ({
  id,
  en,
  volumen = 0.6,
}) => (
  <Sequence from={Math.max(0, Math.round(en))} layout="none">
    <Html5Audio src={staticFile(`nutricion/sfx-${id}.mp3`)} volume={volumen} />
  </Sequence>
);

export const Voz: React.FC<{ id: string }> = ({ id }) => (
  <Sequence from={PRE} layout="none">
    <Html5Audio src={staticFile(`nutricion/voz-${id}.mp3`)} volume={1} />
  </Sequence>
);

/** Segundos desde el inicio de la voz → fotograma de la escena. */
export const t = (segundos: number) => PRE + Math.round(segundos * FPS);

/** Resaltado amarillo tipo brocha detrás de un texto. */
export const Brocha: React.FC<{
  children: React.ReactNode;
  color?: string;
  colorTexto?: string;
  tamano: number;
  progreso: number;
  rot?: number;
}> = ({ children, color = C.amarillo, colorTexto = C.texto, tamano, progreso, rot = -2 }) => (
  <div style={{ position: "relative", display: "inline-block", transform: `rotate(${rot}deg)` }}>
    <div
      style={{
        position: "absolute",
        left: -24,
        right: -24,
        top: "12%",
        bottom: "6%",
        background: color,
        borderRadius: "40px 18px 46px 14px",
        transformOrigin: "left center",
        transform: `scaleX(${progreso})`,
      }}
    />
    <div
      style={{
        position: "relative",
        fontFamily: TITULO,
        fontWeight: 800,
        fontSize: tamano,
        color: colorTexto,
        lineHeight: 1.05,
        padding: "0 6px",
      }}
    >
      {children}
    </div>
  </div>
);

export const Hoja: React.FC<{
  x: number;
  y: number;
  tamano: number;
  rot: number;
  color?: string;
}> = ({ x, y, tamano, rot, color = C.verde }) => {
  const frame = useCurrentFrame();
  const vaiven = Math.sin(frame / 18 + x) * 6;
  return (
    <svg
      width={tamano}
      height={tamano}
      viewBox="0 0 100 100"
      style={{
        position: "absolute",
        left: x,
        top: y,
        transform: `rotate(${rot + vaiven}deg)`,
      }}
    >
      <path d="M50 96 C10 70 10 30 50 4 C90 30 90 70 50 96 Z" fill={color} />
      <path d="M50 92 L50 10" stroke="#ffffff66" strokeWidth={4} />
    </svg>
  );
};

/** Rayitas decorativas que salen alrededor de un elemento. */
export const Rayitas: React.FC<{ color: string; radio: number; progreso: number }> = ({
  color,
  radio,
  progreso,
}) => (
  <svg
    width={radio * 2 + 120}
    height={radio * 2 + 120}
    viewBox={`${-radio - 60} ${-radio - 60} ${radio * 2 + 120} ${radio * 2 + 120}`}
    style={{ position: "absolute", left: "50%", top: "50%", transform: "translate(-50%, -50%)" }}
  >
    {[200, 230, 260, -20, 10, 40].map((a) => {
      const r = (a * Math.PI) / 180;
      const r1 = radio + 10;
      const r2 = radio + 10 + 40 * progreso;
      return (
        <line
          key={a}
          x1={Math.cos(r) * r1}
          y1={Math.sin(r) * r1}
          x2={Math.cos(r) * r2}
          y2={Math.sin(r) * r2}
          stroke={color}
          strokeWidth={10}
          strokeLinecap="round"
          opacity={progreso}
        />
      );
    })}
  </svg>
);

export const Fondo: React.FC<{ arriba: string; abajo: string; children?: React.ReactNode }> = ({
  arriba,
  abajo,
  children,
}) => (
  <AbsoluteFill style={{ background: `linear-gradient(180deg, ${arriba}, ${abajo})`, overflow: "hidden" }}>
    {children}
  </AbsoluteFill>
);

export const aparecer = (frame: number, desde: number, dur = 12) =>
  interpolate(frame, [desde, desde + dur], [0, 1], CLAMP);
