import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

export const HelloWorld: React.FC<{ titulo: string }> = ({ titulo }) => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames } = useVideoConfig();

  const escala = spring({ frame, fps, config: { damping: 200 } });
  const opacidad = interpolate(
    frame,
    [0, 20, durationInFrames - 20, durationInFrames],
    [0, 1, 1, 0],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" },
  );

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#0b1020",
        justifyContent: "center",
        alignItems: "center",
      }}
    >
      <h1
        style={{
          color: "white",
          fontFamily: "sans-serif",
          fontSize: 120,
          opacity: opacidad,
          transform: `scale(${escala})`,
        }}
      >
        {titulo}
      </h1>
    </AbsoluteFill>
  );
};
