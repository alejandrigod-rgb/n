import { AbsoluteFill } from "remotion";
import { POSE_BASE } from "../personajes/Nyxar";
import { FiltroPapelNyxar, NyxarPapel } from "./NyxarPapel";
import { FONDO, frente, guirnalda, LetrasPegadas, LILITA, pz } from "./papel/decorado";
import { rectPts } from "./papel/geo";
import { DEFS } from "./papel/tintas";

const TARJETA = pz(rectPts(-300, -170, 600, 340, 14), "crema", "s4", 1.6);

export const PruebaPapel: React.FC = () => (
  <AbsoluteFill>
    <FiltroPapelNyxar />
    <svg viewBox="0 0 1080 1920" width={1080} height={1920} style={{ position: "absolute", inset: 0 }}>
      {DEFS}
      {FONDO}
      {guirnalda(0)}
      <g transform="translate(540 760)">
        {TARJETA}
        <text x={0} y={20} textAnchor="middle" fontFamily={LILITA} fontSize={96} fill="#3A2416">THE BEST</text>
      </g>
      <LetrasPegadas texto="¡2024!" c={[540, 520]} tam={110} esc={1} n={0} />
    </svg>
    <div style={{ position: "absolute", left: 560, top: 1080 }}>
      <NyxarPapel ancho={470} pose={{ ...POSE_BASE }} boca={0.2} frame={0} fps={60} expresion="triste" parpadeo={0} />
    </div>
    <svg viewBox="0 0 1080 1920" width={1080} height={1920} style={{ position: "absolute", inset: 0 }}>
      {frente(0)}
      <rect width={1080} height={1920} fill="url(#gpp-luz)" />
      <rect width={1080} height={1920} fill="url(#gpp-vineta)" />
    </svg>
  </AbsoluteFill>
);
