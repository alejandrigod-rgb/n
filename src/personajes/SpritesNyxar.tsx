/**
 * Fábrica de sprites de Nyxar: cada fotograma dibuja un sprite de `sprites.json`
 * con fondo transparente. Se renderiza como secuencia PNG y `scripts/sprites-nyxar.py`
 * lo convierte en PNGTuber, hojas de expresiones, stickers y pixel art.
 */
import { AbsoluteFill, useCurrentFrame } from "remotion";
import { Expresion, Nyxar, POSE_BASE, PoseNyxar } from "./Nyxar";
import { TipoObjeto } from "./objetos";
import lista from "./sprites.json";

type Sprite = {
  nombre: string;
  expresion: string;
  pose: string;
  boca: number;
  parpadeo: number;
  objeto?: string | null;
  anim?: { tipo: string; i: number; n: number };
};
export const SPRITES = lista as Sprite[];

const POSES: Record<string, Partial<PoseNyxar>> = {
  base: {},
  saludo: { brazoD: 160, brazoI: 18, cabeza: 6 },
  senalar: { brazoD: 128, brazoI: 18, cabeza: -7, mirarX: 0.6, mirarY: -0.6 },
  celebrar: { brazoI: 155, brazoD: 155, salto: 20 },
  encogerse: { brazoI: 75, brazoD: 75, cabeza: 12 },
  pensar: { brazoD: -128, brazoI: 18, cabeza: 8 },
  jarras: { brazoI: 40, brazoD: 40, cabeza: -4 },
  idea: { brazoD: 162, brazoI: 12 },
};

const poseAnim = (tipo: string, i: number, n: number): { pose: Partial<PoseNyxar>; boca: number; parpadeo: number } => {
  const u = i / n;
  const ciclo = Math.sin(u * Math.PI * 2);
  switch (tipo) {
    case "quieto":
      return { pose: { cabeza: 2 * ciclo, salto: 3 + 3 * ciclo }, boca: 0, parpadeo: i >= 8 && i <= 9 ? 1 : i === 7 || i === 10 ? 0.5 : 0 };
    case "hablar":
      return { pose: { cabeza: 3 * ciclo }, boca: [0, 0.5, 0.95, 0.6, 0.2, 0.8, 0.4, 0.1][i % 8], parpadeo: 0 };
    case "saludar":
      return { pose: { brazoD: 150 + 24 * ciclo, brazoI: 18, cabeza: 4 * ciclo }, boca: 0, parpadeo: 0 };
    case "saltar":
      return { pose: { salto: Math.max(0, Math.sin(u * Math.PI)) * 120, brazoI: 60 + 90 * Math.sin(u * Math.PI), brazoD: 60 + 90 * Math.sin(u * Math.PI) }, boca: 0, parpadeo: 0 };
    default:
      return { pose: { brazoI: 150 + 12 * ciclo, brazoD: 150 - 12 * ciclo, salto: 18 * Math.abs(ciclo) }, boca: 0, parpadeo: 0 };
  }
};

export const SpritesNyxar: React.FC = () => {
  const frame = useCurrentFrame();
  const sp = SPRITES[Math.min(frame, SPRITES.length - 1)];
  let pose: PoseNyxar = { ...POSE_BASE, ...POSES[sp.pose] };
  let boca = sp.boca;
  let parpadeo = sp.parpadeo;
  if (sp.anim) {
    const a = poseAnim(sp.anim.tipo, sp.anim.i, sp.anim.n);
    pose = { ...POSE_BASE, ...a.pose };
    boca = a.boca;
    parpadeo = a.parpadeo;
  }
  if (sp.objeto) pose.objeto = 1;
  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "flex-end", paddingBottom: 40 }}>
      <Nyxar
        ancho={700}
        pose={pose}
        boca={boca}
        frame={40}
        parpadeo={parpadeo}
        expresion={sp.expresion as Expresion}
        objeto={(sp.objeto ?? undefined) as TipoObjeto | undefined}
      />
    </AbsoluteFill>
  );
};
