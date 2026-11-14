/**
 * AEZ · "Tu sartén arde: nunca le eches agua". Formato nuevo (14 de noviembre de 2026): Nyxar fuera de su cuarto, viviendo la situación
 * (aquí, una cocina de noche), con fotos reales de Openverse en grande cuando hace falta (dominio público).
 * Datos: bomberos de Cambridge y de Mamaroneck, y extensión de la Universidad de Illinois (no usar agua; apagar el fuego;
 * tapa de metal; no mover la sartén; bicarbonato solo si es pequeño; la harina lo empeora).
 */
import { linearTiming, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { AbsoluteFill, Html5Audio, interpolate, staticFile, useCurrentFrame } from "remotion";
import { C, CLAMP, FPS } from "../marca/tema";
import { Escenario, Lado, Tramo } from "../personajes/Escenario";
import { Expresion, Nyxar, POSE_BASE, PoseNyxar } from "../personajes/Nyxar";
import { Brasas, CocinaNoche } from "./dibujos";
import { Aire, Bicarbonato, Bola, Gancho, Hierve, Hunde, Instinto, Pregunta, Tapa } from "./escenas";
import { CARPETA, IdEscena, IDS, LINEA, TRANSICION } from "./linea";

const COMPONENTES = [Gancho, Instinto, Hunde, Hierve, Bola, Tapa, Aire, Bicarbonato, Pregunta];

const LADOS: Record<IdEscena, Lado> = {
  gancho: "asomadoIzquierda",
  instinto: "derecha",
  hunde: "izquierda",
  hierve: "derecha",
  bola: "izquierda",
  tapa: "derecha",
  aire: "izquierda",
  bicarbonato: "derecha",
  pregunta: "centro",
};

const sen = (s: number, periodo: number) => Math.sin((s * Math.PI * 2) / periodo);
const saltito = (s: number, desde: number, alto = 60) => {
  const d = s - desde;
  return d < 0 || d > 0.35 ? 0 : Math.sin((d / 0.35) * Math.PI) * alto;
};
const marcaS = (id: IdEscena, w: string, def: number) => {
  try {
    return LINEA.marcas(id)(w) / FPS;
  } catch {
    return def;
  }
};

const estado = (id: IdEscena, local: number): { pose: PoseNyxar; expresion: Expresion } => {
  const s = local / FPS;
  const m = (w: string, d = 99) => marcaS(id, w, d);
  const base = { ...POSE_BASE };
  switch (id) {
    case "gancho":
      return { pose: { ...base, brazoI: 150 + 8 * sen(s, 0.8), brazoD: 150 - 8 * sen(s, 0.8), mirarX: 0.7, mirarY: -0.2, cabeza: -6, salto: saltito(s, 0, 50) }, expresion: "sorprendido" };
    case "instinto":
      return { pose: { ...base, brazoD: 120 + 6 * sen(s, 1.2), mirarX: -0.6, mirarY: -0.2 }, expresion: s >= m("no") ? "enfadado" : "pensativo" };
    case "hunde":
      return { pose: { ...base, brazoD: 130 + 5 * sen(s, 1.4), mirarX: 0.6, mirarY: -0.4 }, expresion: "pensativo" };
    case "hierve":
      return { pose: { ...base, brazoI: 40 + 6 * sen(s, 0.5), brazoD: 40 - 6 * sen(s, 0.5), mirarX: -0.5, mirarY: -0.4, salto: saltito(s, m("golpe"), 60) }, expresion: s >= m("golpe") ? "sorprendido" : "normal" };
    case "bola":
      return { pose: { ...base, brazoI: 150 + 10 * sen(s, 0.5), brazoD: 150 - 10 * sen(s, 0.5), mirarX: 0.6, mirarY: -0.6, salto: saltito(s, m("fuego"), 80) }, expresion: "sorprendido" };
    case "tapa":
      return { pose: { ...base, brazoD: 130 + 5 * sen(s, 1.4), mirarX: -0.5, mirarY: -0.3, salto: saltito(s, m("tapa"), 40) }, expresion: s >= m("metal") ? "guino" : "feliz" };
    case "aire":
      return { pose: { ...base, brazoD: 120 + 8 * sen(s, 1), mirarX: 0.5, mirarY: -0.3, cabeza: 4 * sen(s, 1.6) }, expresion: s >= m("muevas") ? "enfadado" : "normal" };
    case "bicarbonato":
      return { pose: { ...base, brazoD: 130 + 5 * sen(s, 1.4), mirarX: -0.5, mirarY: -0.2 }, expresion: s >= m("harina") ? "enfadado" : "feliz" };
    case "pregunta":
      return { pose: { ...base, brazoD: 150 + 22 * sen(s, 0.65), brazoI: 18, cabeza: 6 * sen(s, 2.4) }, expresion: "guino" };
  }
};

const TRAMOS: Tramo[] = IDS.map((id, i) => ({
  inicio: LINEA.inicios[i],
  fin: LINEA.inicios[i] + LINEA.duraciones[i] - TRANSICION,
  lado: LADOS[id],
  sinEntrada: i === 0,
}));

const NyxarEnEscena: React.FC = () => {
  const frame = useCurrentFrame();
  const { id, local } = LINEA.escenaEn(frame);
  const e = estado(id, local);
  return (
    <Escenario tramos={TRAMOS} fps={FPS}>
      {(ancho) => <Nyxar ancho={ancho} pose={e.pose} boca={LINEA.aperturaBoca(frame)} frame={frame} fps={FPS} expresion={e.expresion} />}
    </Escenario>
  );
};

/** Cuánto fuego hay en la cocina (luz naranja y brasas): todo arde hasta que se tapa la sartén. */
const INICIO_TAPA = LINEA.inicios[IDS.indexOf("tapa")];
const F_TAPADA = INICIO_TAPA + (() => {
  try {
    return LINEA.marcas("tapa")("tapa") + 20;
  } catch {
    return 100;
  }
})();
const INICIO_BOLA = LINEA.inicios[IDS.indexOf("bola")];

export const DURACION_SARTEN = LINEA.total;

export const SartenArde: React.FC = () => {
  const frame = useCurrentFrame();
  const t = frame / FPS;
  const fuego = interpolate(frame, [F_TAPADA, F_TAPADA + 30], [1, 0], CLAMP);
  const enBola = frame >= INICIO_BOLA && frame < INICIO_TAPA ? 1 : 0;
  const parpadeo = 0.5 + 0.5 * Math.sin(t * 9) * Math.sin(t * 5.3);
  return (
    <AbsoluteFill style={{ background: C.abismo }}>
      <AbsoluteFill style={{ transform: `scale(${1.04 + 0.01 * Math.sin(t / 3)})` }}>
        <CocinaNoche s={t} />
      </AbsoluteFill>
      <AbsoluteFill style={{ background: "rgba(2,8,20,0.28)" }} />
      {/* luz del fuego que baila en la cocina */}
      <AbsoluteFill style={{ background: `radial-gradient(circle at 50% 50%, ${C.cascabel}55 0%, #FF7A3A22 40%, transparent 75%)`, opacity: fuego * (0.5 + 0.3 * parpadeo + enBola * 0.3), mixBlendMode: "screen" }} />
      <Brasas s={t} fuerza={fuego} />
      <TransitionSeries>
        {IDS.flatMap((id, i) => {
          const Comp = COMPONENTES[i];
          const items = [
            <TransitionSeries.Sequence key={id} durationInFrames={LINEA.duraciones[i]}>
              <Comp />
            </TransitionSeries.Sequence>,
          ];
          if (i < IDS.length - 1) items.push(<TransitionSeries.Transition key={`${id}-t`} presentation={fade()} timing={linearTiming({ durationInFrames: TRANSICION })} />);
          return items;
        })}
      </TransitionSeries>
      <NyxarEnEscena />
      <Html5Audio loop loopVolumeCurveBehavior="extend" src={staticFile(`${CARPETA}/sfx-musica.mp3`)} volume={(f) => interpolate(f, [0, 30, LINEA.total - 60, LINEA.total], [0.05, 0.06, 0.07, 0], CLAMP)} />
      <Html5Audio loop src={staticFile(`${CARPETA}/sfx-fuego.mp3`)} volume={(f) => 0.12 * interpolate(f, [F_TAPADA, F_TAPADA + 30], [1, 0], CLAMP)} />
    </AbsoluteFill>
  );
};

