import { linearTiming, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { AbsoluteFill, Html5Audio, interpolate, random, spring, staticFile, useCurrentFrame } from "remotion";
import { Sfx } from "../marca/kit";
import { C, CLAMP, F, FPS } from "../marca/tema";
import { Cuarto } from "../backrooms/mundos";
import { Escenario, Lado, Tramo } from "../personajes/Escenario";
import { Expresion, Nyxar, POSE_BASE, PoseNyxar } from "../personajes/Nyxar";
import { TipoObjeto } from "../personajes/objetos";
import { Contexto, Elliot, Gancho, Mente, Pregunta, Premios, Real, Trama } from "./escenas";
import { CARPETA, IdEscena, IDS, LINEA, TRANSICION } from "./linea";

const COMPONENTES = [Gancho, Contexto, Elliot, Trama, Real, Mente, Premios, Pregunta];

const LADOS: Record<IdEscena, Lado> = {
  gancho: "asomadoIzquierda",
  contexto: "centro",
  elliot: "derecha",
  trama: "centro",
  real: "izquierda",
  mente: "derecha",
  premios: "derecha",
  pregunta: "derecha",
};

/** El portátil solo cuando habla de los hackeos reales. */
const OBJETOS: Partial<Record<IdEscena, { objeto: TipoObjeto; palabra: string }>> = {
  real: { objeto: "Portatil", palabra: "reales" },
};

const sen = (s: number, periodo: number) => Math.sin((s * Math.PI * 2) / periodo);
const saltito = (s: number, desde: number, alto = 60) => {
  const d = s - desde;
  return d < 0 || d > 0.35 ? 0 : Math.sin((d / 0.35) * Math.PI) * alto;
};

type Estado = { pose: PoseNyxar; expresion: Expresion };

const estado = (id: IdEscena, local: number): Estado => {
  const s = local / FPS;
  const m = (w: string) => LINEA.marcas(id)(w) / FPS;
  const base = { ...POSE_BASE };
  switch (id) {
    case "gancho":
      return { pose: { ...base, brazoI: 150 + 8 * sen(s, 0.8), brazoD: 150 - 8 * sen(s, 0.8), mirarX: 0.6, mirarY: -0.3, cabeza: -6, salto: saltito(s, m("aprueban")) }, expresion: "sorprendido" };
    case "contexto":
      return { pose: { ...base, brazoD: 128 + 5 * sen(s, 1.4), brazoI: 18, mirarY: -0.8, salto: saltito(s, m("cuatro"), 40) }, expresion: "feliz" };
    case "elliot":
      return { pose: { ...base, cabeza: 4 * sen(s, 1.6), mirarX: 0.5, mirarY: -0.5 }, expresion: s >= m("hacker") ? "guino" : "normal" };
    case "trama":
      return { pose: { ...base, brazoI: 40, brazoD: 40, mirarY: -0.8, salto: saltito(s, m("tumbar"), 60) }, expresion: s >= m("enorme") ? "sorprendido" : "pensativo" };
    case "real":
      return { pose: { ...base, salto: 4 * Math.abs(sen(s, 0.7)) }, expresion: "feliz" };
    case "mente":
      return { pose: { ...base, cabeza: 5 * sen(s, 2.2), mirarX: 0.5, mirarY: -0.4 }, expresion: s >= m("narrador") ? "pensativo" : "triste" };
    case "premios":
      return { pose: { ...base, brazoI: 150 + 10 * sen(s, 0.6), brazoD: 150 - 10 * sen(s, 0.6), salto: saltito(s, m("emmy"), 60) }, expresion: "feliz" };
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

/* Final: la pantalla del cuarto se "hackea" y saluda a Nyxar, y corte. */
const F_HOLA = LINEA.total - Math.round(FPS * 1.6);
const F_NEGRO = LINEA.total - Math.round(FPS * 0.35);

const NyxarEnEscena: React.FC = () => {
  const frame = useCurrentFrame();
  const { id, local } = LINEA.escenaEn(frame);
  const e = estado(id, local);
  const obj = OBJETOS[id];
  if (obj) e.pose.objeto = spring({ frame: local - LINEA.marcas(id)(obj.palabra), fps: FPS, config: { damping: 13 } });
  return (
    <Escenario tramos={TRAMOS} fps={FPS}>
      {(ancho) => <Nyxar ancho={ancho} pose={e.pose} boca={LINEA.aperturaBoca(frame)} frame={frame} fps={FPS} objeto={obj?.objeto} expresion={e.expresion} />}
    </Escenario>
  );
};

const Hackeo: React.FC = () => {
  const frame = useCurrentFrame();
  if (frame < F_HOLA) return null;
  const d = frame - F_HOLA;
  const texto = "hola, Nyxar.";
  const n = Math.min(texto.length, Math.floor(d / 4));
  const temblor = (random(`h${Math.floor(frame / 2)}`) - 0.5) * 16;
  return (
    <AbsoluteFill style={{ background: "#020509", alignItems: "center", justifyContent: "center", opacity: interpolate(d, [0, 3], [0, 1], CLAMP) }}>
      <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 96, color: C.menta, transform: `translateX(${temblor}px)`, textShadow: `0 0 30px ${C.menta}` }}>
        {texto.slice(0, n)}
        <span style={{ display: "inline-block", width: "0.55em", height: "0.9em", marginLeft: 6, verticalAlign: "-0.1em", background: C.menta, opacity: Math.floor(d / 15) % 2 ? 0 : 1 }} />
      </div>
      {new Array(10).fill(0).map((_, k) => (
        <div key={k} style={{ position: "absolute", left: 0, right: 0, top: random(`l${frame}-${k}`) * 1920, height: 3 + random(`a${frame}-${k}`) * 10, background: k % 2 ? "#ff547055" : `${C.menta}44` }} />
      ))}
    </AbsoluteFill>
  );
};

const volumenMusica = (f: number) => interpolate(f, [0, 30, F_HOLA - 20, F_HOLA], [0.07, 0.08, 0.08, 0], CLAMP);

export const DURACION_MRROBOT = LINEA.total;

export const MrRobot: React.FC = () => {
  const frame = useCurrentFrame();
  const t = frame / FPS;
  return (
    <AbsoluteFill style={{ background: C.abismo }}>
      <AbsoluteFill style={{ transform: `scale(${1.04 + 0.01 * Math.sin(t / 3)})` }}>
        <Cuarto s={t} />
      </AbsoluteFill>
      <AbsoluteFill style={{ background: "rgba(2,8,20,0.66)" }} />
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
      <Hackeo />
      {frame >= F_NEGRO ? <AbsoluteFill style={{ background: "#000" }} /> : null}
      <Html5Audio loop loopVolumeCurveBehavior="extend" src={staticFile(`${CARPETA}/sfx-musica.mp3`)} volume={volumenMusica} />
      <Sfx carpeta={CARPETA} id="glitch" en={F_HOLA} volumen={0.35} />
      <Sfx carpeta={CARPETA} id="clic" en={F_HOLA + 20} volumen={0.3} />
      <Sfx carpeta={CARPETA} id="estatica" en={F_NEGRO - 6} volumen={0.3} dur={0.3} />
    </AbsoluteFill>
  );
};
