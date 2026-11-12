import { AbsoluteFill } from "remotion";
import { C, F } from "../marca/tema";
import { Nyxar, POSE_BASE } from "./Nyxar";

/** Comparación de paletas: normal y gris (temas tristes), con varias expresiones. */
export const PaletasNyxar: React.FC = () => (
  <AbsoluteFill style={{ background: "#e9e9ef", flexDirection: "row", alignItems: "flex-end", justifyContent: "space-around", padding: 30 }}>
    {[
      { p: "normal" as const, e: "feliz" as const, t: "normal" },
      { p: "gris" as const, e: "normal" as const, t: "gris" },
      { p: "gris" as const, e: "triste" as const, t: "gris · triste" },
      { p: "gris" as const, e: "pensativo" as const, t: "gris · pensativo" },
    ].map((x, k) => (
      <div key={k} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 10 }}>
        <Nyxar ancho={300} pose={{ ...POSE_BASE, brazoD: 148, brazoI: 18 }} boca={0.3} frame={0} fps={30} id={`pal${k}`} expresion={x.e} parpadeo={0} paleta={x.p} />
        <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 26, color: C.noche }}>{x.t}</div>
      </div>
    ))}
  </AbsoluteFill>
);
