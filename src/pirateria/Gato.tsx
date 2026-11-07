import { spring, useCurrentFrame } from "remotion";
import { mezclarPoses, Nyxar, POSE_BASE, PoseNyxar } from "../personajes/Nyxar";
import { aperturaBoca, escenaEn, IdEscena, IDS, INICIOS, marcas } from "./linea";
import { FPS } from "./tema";

type Pose = PoseNyxar;

const ondaS = (f: number, v: number) => Math.sin(f / v);
const saltito = (f: number, desde: number) => {
  const p = f - desde;
  if (p < 0 || p > 18) return 0;
  return Math.sin((p / 18) * Math.PI) * 60;
};

/** Pose de cada escena en su fotograma local. */
/** Pose de Nyxar en cada escena, en su fotograma local. */
const POSES: Record<IdEscena, (f: number) => Partial<Pose>> = {
  intro: (f) => ({ brazoD: 150 + 22 * ondaS(f, 3.2), brazoI: 18, cabeza: 6 * ondaS(f, 14), salto: saltito(f, 4) }),
  que: (f) => ({ brazoD: 128 + 4 * ondaS(f, 9), brazoI: 18, cabeza: -7, inclinar: 3, x: -60, mirarX: 0.6, mirarY: -0.6 }),
  nombre: (f) => {
    const m = marcas("nombre");
    return { sombrero: f >= m("piratas") ? 1 : 0, brazoI: 40, brazoD: 40, inclinar: 4 * ondaS(f, 10), cabeza: 5 * ondaS(f, 13), salto: saltito(f, m("piratas")) };
  },
  imprenta: (f) => {
    const m = marcas("imprenta");
    const arriba = f >= m("facilisimo") && f < m("facilisimo") + 40;
    return { brazoI: arriba ? 150 : 20, brazoD: arriba ? 150 : 115, cabeza: arriba ? 0 : -6, salto: saltito(f, m("facilisimo")), x: arriba ? 0 : -50, mirarX: arriba ? 0 : 0.6, mirarY: arriba ? 0 : -0.5 };
  },
  ley: (f) => ({ brazoI: 28, brazoD: 28, cabeza: 4 * Math.sin(f / 5) * (f % 90 < 30 ? 1 : 0.2), inclinar: 0 }),
  cintas: (f) => ({ cascos: 1, cabeza: 9 * Math.sin(f * 0.42), salto: 10 * Math.abs(Math.sin(f * 0.21)), brazoI: 25 + 18 * Math.sin(f * 0.42), brazoD: 25 - 18 * Math.sin(f * 0.42) }),
  software: (f) => ({ carta: 1, brazoI: 55, brazoD: -128, cabeza: 8 + 3 * ondaS(f, 12), inclinar: -2, mirarX: -0.7, mirarY: -0.8 }),
  internet: (f) => {
    const m = marcas("internet");
    return { brazoI: 110 + 8 * ondaS(f, 6), brazoD: 110 + 8 * ondaS(f, 6), cabeza: 4 * ondaS(f, 10), salto: saltito(f, m("salto")) + saltito(f, m("napster")) };
  },
  cierre: (f) => {
    const m = marcas("cierre");
    const encoge = f >= m("tarde") - 6;
    return { brazoI: encoge ? 75 : 20, brazoD: encoge ? 75 : 20, cabeza: encoge ? 12 : -3, salto: encoge ? 12 : 0, inclinar: encoge ? -3 : 0 };
  },
  streaming: (f) => {
    const m = marcas("streaming");
    const feliz = f >= m("streaming");
    return { brazoI: feliz ? 150 + 10 * ondaS(f, 4) : 25, brazoD: feliz ? 150 - 10 * ondaS(f, 4) : 125, salto: feliz ? 18 * Math.abs(Math.sin(f / 6)) : 0, cabeza: 5 * ondaS(f, 8) };
  },
  riesgos: (f) => ({ brazoD: 152 + 14 * Math.sin(f / 2.2), brazoI: 15, cabeza: -5, inclinar: 2 }),
  final: (f) => {
    const m = marcas("final");
    const adios = f >= m("vemos") - 10;
    return { brazoD: adios ? 150 + 22 * ondaS(f, 3.2) : 40, brazoI: adios ? 150 - 22 * ondaS(f, 3.2) : 40, salto: saltito(f, m("vemos")), cabeza: 6 * ondaS(f, 12) };
  },
};

const pose = (id: IdEscena, f: number): Pose => ({ ...POSE_BASE, ...POSES[id](f) });

/** Nyxar presentando el video: pasa de una pose a otra con suavidad entre escenas. */
export const Gato: React.FC<{ ancho: number }> = ({ ancho }) => {
  const frame = useCurrentFrame();
  const { i, id, local } = escenaEn(frame);
  let p = pose(id, local);
  if (i > 0 && local < 20) {
    const previa = pose(IDS[i - 1], frame - INICIOS[i - 1]);
    const t = spring({ frame: local, fps: FPS, config: { damping: 15 } });
    p = mezclarPoses(previa, p, Math.min(1, t));
  }
  return <Nyxar ancho={ancho} pose={p} boca={aperturaBoca(frame)} frame={frame} fps={FPS} />;
};
