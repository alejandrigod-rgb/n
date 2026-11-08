import { linearTiming, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { AbsoluteFill, Html5Audio, interpolate, spring, staticFile, useCurrentFrame } from "remotion";
import { Fondo } from "../marca/kit";
import { CLAMP, FPS } from "../marca/tema";
import { Escenario, Lado, Tramo } from "../personajes/Escenario";
import { Expresion, Nyxar, POSE_BASE, PoseNyxar } from "../personajes/Nyxar";
import { TipoObjeto } from "../personajes/objetos";
import { Exito, Gancho, Online, Pregunta, Rdr, Remate, Retrasos } from "./escenas";
import { CARPETA, IdEscena, IDS, LINEA, TRANSICION } from "./linea";

const COMPONENTES = [Gancho, Exito, Online, Rdr, Retrasos, Remate, Pregunta];

const LADOS: Record<IdEscena, Lado> = {
  gancho: "asomadoIzquierda",
  exito: "derecha",
  online: "izquierda",
  rdr: "centro",
  retrasos: "derecha",
  remate: "izquierda",
  pregunta: "centro",
};

/** Objetos solo donde tienen sentido: el mando al hablar de jugar y la lupa al "pulir". */
const OBJETOS: Partial<Record<IdEscena, { objeto: TipoObjeto; palabra: string }>> = {
  online: { objeto: "Mando", palabra: "jugando" },
  remate: { objeto: "Lupa", palabra: "pulirlo" },
};

const sen = (s: number, periodo: number) => Math.sin((s * Math.PI * 2) / periodo);
const saltito = (s: number, desde: number, alto = 60) => {
  const d = s - desde;
  return d < 0 || d > 0.35 ? 0 : Math.sin((d / 0.35) * Math.PI) * alto;
};

type Estado = { pose: PoseNyxar; expresion: Expresion; parpadeo?: number };

const estado = (id: IdEscena, local: number): Estado => {
  const s = local / FPS;
  const m = (w: string) => LINEA.marcas(id)(w) / FPS;
  const base = { ...POSE_BASE };
  switch (id) {
    case "gancho":
      return {
        pose: {
          ...base,
          brazoI: 150 + 8 * sen(s, 0.8),
          brazoD: 150 - 8 * sen(s, 0.8),
          mirarX: 0.5,
          mirarY: -0.5,
          cabeza: -6,
          salto: saltito(s, m("trece")),
        },
        expresion: s >= m("tanto") ? "pensativo" : "sorprendido",
      };
    case "exito":
      return {
        pose: { ...base, brazoI: 150 + 10 * sen(s, 0.6), brazoD: 150 - 10 * sen(s, 0.6), salto: 14 * Math.abs(sen(s, 0.8)) },
        expresion: "feliz",
      };
    case "online":
      return { pose: { ...base, cabeza: 4 * sen(s, 0.8), salto: 6 * Math.abs(sen(s, 0.6)) }, expresion: "feliz" };
    case "rdr":
      return {
        pose: { ...base, brazoD: 128 + 5 * sen(s, 1.4), brazoI: 18, mirarX: 0.4, mirarY: -0.7, salto: saltito(s, m("enorme")) },
        expresion: "sorprendido",
      };
    case "retrasos":
      return {
        pose: { ...base, brazoI: 40, brazoD: 40, cabeza: -4, salto: saltito(s, m("noviembre"), 50) },
        expresion: s >= m("noviembre") ? "feliz" : s >= m("retrasaron") ? "enfadado" : "normal",
      };
    case "remate":
      return { pose: { ...base, cabeza: 4 * sen(s, 2) }, expresion: s >= m("fans") ? "feliz" : "pensativo" };
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
  const obj = OBJETOS[id];
  if (obj) e.pose.objeto = spring({ frame: local - LINEA.marcas(id)(obj.palabra), fps: FPS, config: { damping: 13 } });
  return (
    <Escenario tramos={TRAMOS} fps={FPS}>
      {(ancho) => (
        <Nyxar
          ancho={ancho}
          pose={e.pose}
          boca={LINEA.aperturaBoca(frame)}
          frame={frame}
          fps={FPS}
          objeto={obj?.objeto}
          expresion={e.expresion}
          parpadeo={e.parpadeo}
        />
      )}
    </Escenario>
  );
};

const volumenMusica = (f: number) => interpolate(f, [0, 30, LINEA.total - 90, LINEA.total], [0.05, 0.06, 0.06, 0], CLAMP);

export const DURACION_ESPERA = LINEA.total;

export const EsperaGTA: React.FC = () => (
  <AbsoluteFill>
    <Fondo />
    <TransitionSeries>
      {IDS.flatMap((id, i) => {
        const Comp = COMPONENTES[i];
        const items = [
          <TransitionSeries.Sequence key={id} durationInFrames={LINEA.duraciones[i]}>
            <Comp />
          </TransitionSeries.Sequence>,
        ];
        if (i < IDS.length - 1)
          items.push(
            <TransitionSeries.Transition key={`${id}-t`} presentation={fade()} timing={linearTiming({ durationInFrames: TRANSICION })} />,
          );
        return items;
      })}
    </TransitionSeries>
    <NyxarEnEscena />
    <Html5Audio loop loopVolumeCurveBehavior="extend" src={staticFile(`${CARPETA}/sfx-musica.mp3`)} volume={volumenMusica} />
  </AbsoluteFill>
);
