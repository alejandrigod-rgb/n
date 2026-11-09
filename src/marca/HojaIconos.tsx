import { AbsoluteFill } from "remotion";
import { ICONOS } from "./iconos";
import { C, F } from "./tema";

/** Hoja con los iconos propios de AEZ (sustituyen a los emojis). */
export const HojaIconos: React.FC = () => (
  <AbsoluteFill style={{ background: C.noche, padding: 50, display: "flex", flexDirection: "column", gap: 30 }}>
    <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 56, color: C.hueso }}>Iconos AEZ</div>
    <div style={{ display: "grid", gridTemplateColumns: "repeat(5, 1fr)", gap: 34 }}>
      {Object.entries(ICONOS).map(([nombre, Ico]) => (
        <div key={nombre} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 12 }}>
          <Ico tamano={130} />
          <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 24, color: C.niebla }}>{nombre}</div>
        </div>
      ))}
    </div>
  </AbsoluteFill>
);
