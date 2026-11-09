import { AbsoluteFill, useCurrentFrame } from "remotion";
import { C, F } from "../marca/tema";
import { Expresion, Nyxar, POSE_BASE } from "./Nyxar";

/**
 * Foto de perfil del canal (1080×1080). TikTok la recorta en círculo:
 * todo lo importante va dentro del círculo central.
 * Variante = frame: 0 feliz, 1 guiño, 2 feliz con la etiqueta AEZ.
 */
const VARIANTES: { expresion: Expresion; aez: boolean }[] = [
  { expresion: "feliz", aez: false },
  { expresion: "guino", aez: false },
  { expresion: "feliz", aez: true },
];

export const FotoPerfil: React.FC = () => {
  const variante = useCurrentFrame();
  const v = VARIANTES[variante] ?? VARIANTES[0];
  const pose = { ...POSE_BASE, brazoD: 150, brazoI: 18, cabeza: -6, mirarX: 0, mirarY: 0 };
  return (
    <AbsoluteFill style={{ background: `radial-gradient(circle at 50% 42%, #1b2f6b 0%, ${C.noche} 55%, ${C.abismo} 100%)`, overflow: "hidden" }}>
      {/* Halo menta detrás de la cabeza */}
      <div style={{ position: "absolute", left: 540 - 380, top: 480 - 380, width: 760, height: 760, borderRadius: "50%", background: `radial-gradient(circle, ${C.menta}55 0%, ${C.menta}00 70%)` }} />
      <div style={{ position: "absolute", left: 540 - 330, top: 480 - 330, width: 660, height: 660, borderRadius: "50%", border: `14px solid ${C.menta}`, opacity: 0.9 }} />
      {/* Chispas de la marca */}
      {[
        [190, 250, 34, C.cascabel],
        [880, 300, 26, C.menta],
        [850, 760, 20, C.cascabel],
        [215, 720, 18, C.menta],
      ].map(([x, y, r, col], k) => (
        <svg key={k} width={r as number * 2} height={r as number * 2} viewBox="-1 -1 2 2" style={{ position: "absolute", left: (x as number) - (r as number), top: (y as number) - (r as number) }}>
          <path d="M0 -1 Q0.12 -0.12 1 0 Q0.12 0.12 0 1 Q-0.12 0.12 -1 0 Q-0.12 -0.12 0 -1 Z" fill={col as string} />
        </svg>
      ))}
      {/* Nyxar: cabeza grande y hombros */}
      <div style={{ position: "absolute", left: 130, top: 55 }}>
        <Nyxar ancho={940} pose={pose} boca={0} frame={0} fps={30} id="perfil" expresion={v.expresion} parpadeo={0} />
      </div>
      {v.aez && (
        <div style={{ position: "absolute", left: 0, right: 0, bottom: 120, display: "flex", justifyContent: "center" }}>
          <div style={{ background: C.menta, color: C.noche, fontFamily: F.titulo, fontWeight: 800, fontSize: 110, lineHeight: 1, padding: "14px 46px 4px", borderRadius: 40, transform: "rotate(-4deg)", boxShadow: "0 10px 0 #02081488" }}>AEZ</div>
        </div>
      )}
    </AbsoluteFill>
  );
};
