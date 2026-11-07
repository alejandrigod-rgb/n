import { AbsoluteFill, useCurrentFrame } from "remotion";
import { Nyxar, POSE_BASE } from "./Nyxar";

/** Nyxar saludando, con fondo transparente: para miniaturas, portadas y la hoja de marca. */
export const RetratoNyxar: React.FC = () => {
  const frame = useCurrentFrame();
  const pose = { ...POSE_BASE, brazoD: 150 + 22 * Math.sin(frame / 3.2), brazoI: 18, cabeza: 5 * Math.sin(frame / 14) };
  const boca = Math.max(0, Math.sin(frame / 3)) * 0.8;
  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <Nyxar ancho={760} pose={pose} boca={boca} frame={frame} />
    </AbsoluteFill>
  );
};
