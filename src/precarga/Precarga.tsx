import { linearTiming, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { AbsoluteFill, Html5Audio, interpolate, spring, staticFile, useCurrentFrame } from "remotion";
import { Sfx } from "../marca/kit";
import { C, CLAMP, FPS } from "../marca/tema";
import { Cuarto } from "../backrooms/mundos";
import { Escenario, Lado, Tramo } from "../personajes/Escenario";
import { Expresion, Nyxar, POSE_BASE, PoseNyxar } from "../personajes/Nyxar";
import { TipoObjeto } from "../personajes/objetos";
import { Candados, Estatica, Fechas, Final, Gancho, LlaveLlega, Pregunta, Remate, Servidores } from "./escenas";
import { CARPETA, IdEscena, IDS, LINEA, TRANSICION } from "./linea";

const COMPONENTES = [Gancho, Fechas, Servidores, Candados, LlaveLlega, Remate, Pregunta, Final];

const LADOS: Record<IdEscena, Lado> = {
  gancho: "asomadoIzquierda",
  fechas: "derecha",
  servidores: "izquierda",
  candado: "derecha",
  llave: "centro",
  remate: "izquierda",
  pregunta: "derecha",
  final: "centro",
};

/** El mando solo cuando dice "jugando". */
const OBJETOS: Partial<Record<IdEscena, { objeto: TipoObjeto; palabra: string }>> = {
  llave: { objeto: "Mando", palabra: "jugando" },
};

const sen = (s: number, periodo: number) => Math.sin((s * Math.PI * 2) / periodo);
const saltito = (s: number, desde: number, alto = 60) => {
  const d = s - desde;
  return d < 0 || d > 0.35 ? 0 : Math.sin((d / 0.35) * Math.PI) * alto;
};

/* Momentos del final (fotogramas globales) */
const INICIO_FINAL = LINEA.inicios[IDS.indexOf("final")];
const F_BACKROOMS = INICIO_FINAL + LINEA.marcas("final")("backrooms");
const F_VERDAD = INICIO_FINAL + LINEA.marcas("final")("verdad");
const F_APAGON = F_VERDAD + Math.round(FPS * 1.0);
const F_CERCA = F_VERDAD + Math.round(FPS * 1.6);
const F_NEGRO = F_VERDAD + Math.round(FPS * 2.05);

type Estado = { pose: PoseNyxar; expresion: Expresion };

const estado = (id: IdEscena, local: number): Estado => {
  const s = local / FPS;
  const m = (w: string) => LINEA.marcas(id)(w) / FPS;
  const base = { ...POSE_BASE };
  switch (id) {
    case "gancho":
      return {
        pose: { ...base, brazoI: 150 + 8 * sen(s, 0.8), brazoD: 150 - 8 * sen(s, 0.8), mirarX: 0.6, mirarY: -0.3, cabeza: -6, salto: saltito(s, m("jugarlo")) },
        expresion: s >= m("jugarlo") ? "enfadado" : "sorprendido",
      };
    case "fechas":
      return { pose: { ...base, brazoD: 128 + 5 * sen(s, 1.4), brazoI: 18, mirarX: 0.5, mirarY: -0.6, salto: saltito(s, m("diecinueve"), 40) }, expresion: "normal" };
    case "servidores":
      return {
        pose: { ...base, brazoI: 40 + 6 * sen(s, 0.5), brazoD: 40 - 6 * sen(s, 0.5), mirarX: 0.4, mirarY: -0.7, salto: saltito(s, m("revientan"), 70) },
        expresion: s >= m("revientan") ? "sorprendido" : "pensativo",
      };
    case "candado":
      return { pose: { ...base, cabeza: 4 * sen(s, 1.6), mirarX: 0.5, mirarY: -0.5 }, expresion: s >= m("llave") ? "guino" : "pensativo" };
    case "llave":
      return { pose: { ...base, salto: saltito(s, m("jugando"), 50) + 6 * Math.abs(sen(s, 0.7)) }, expresion: s >= m("medianoche") ? "feliz" : "normal" };
    case "remate":
      return { pose: { ...base, brazoI: 150 + 10 * sen(s, 0.6), brazoD: 150 - 10 * sen(s, 0.6), salto: saltito(s, m("vez"), 60) }, expresion: "feliz" };
    case "pregunta":
      return { pose: { ...base, brazoD: 150 + 22 * sen(s, 0.65), brazoI: 18, cabeza: 6 * sen(s, 2.4) }, expresion: "guino" };
    case "final":
      return {
        pose: { ...base, brazoD: s < m("menos") ? 150 + 20 * sen(s, 0.6) : 18, brazoI: 18, cabeza: s >= m("verdad") ? -5 : 3 * sen(s, 2), mirarX: 0, mirarY: 0 },
        expresion: s >= m("verdad") ? "sorprendido" : "feliz",
      };
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
        <Nyxar ancho={ancho} pose={e.pose} boca={LINEA.aperturaBoca(frame)} frame={frame} fps={FPS} objeto={obj?.objeto} expresion={e.expresion} />
      )}
    </Escenario>
  );
};

/** Luz del cuarto en el final: parpadea y se vuelve amarilla, como en los Backrooms. */
const luzFinal = (frame: number) => {
  if (frame < F_BACKROOMS) return { apagon: 0, amarillo: 0 };
  const d = frame - F_BACKROOMS;
  const parpadeo = d < 18 ? (Math.floor(d / 4) % 2 ? 0.7 : 0) : frame >= F_APAGON && frame < F_CERCA ? (Math.floor((frame - F_APAGON) / 3) % 2 ? 0.8 : 0.1) : 0;
  return { apagon: parpadeo, amarillo: interpolate(d, [0, 30], [0, 1], CLAMP) };
};

/** El otro Nyxar: quieto como un cuadro, sin parpadear, con la luz amarilla de los Backrooms. */
const NyxarStillLife: React.FC = () => {
  const frame = useCurrentFrame();
  if (frame < F_BACKROOMS || frame >= F_NEGRO) return null;
  const d = frame - F_BACKROOMS;
  // Aparece entre parpadeos de luz y luego se queda.
  const visible = d < 18 ? (Math.floor(d / 4) % 2 ? 0 : 1) : 1;
  const cerca = frame >= F_CERCA;
  const pose = { ...POSE_BASE, brazoI: 8, brazoD: 8, mirarX: 0, mirarY: 0 };
  const filtro = "sepia(1) saturate(2.4) hue-rotate(-14deg) brightness(0.7) contrast(1.35)";
  return (
    <div
      style={{
        position: "absolute",
        left: cerca ? 190 : 250,
        top: cerca ? 520 : 815,
        width: cerca ? 700 : 210,
        opacity: visible * 0.92,
        filter: `${filtro} blur(${cerca ? 0 : 0.6}px)`,
      }}
    >
      <div style={{ position: "absolute", inset: "-10% -20%", background: `radial-gradient(circle, ${C.cascabel}33 0%, transparent 65%)` }} />
      <Nyxar ancho={cerca ? 700 : 210} pose={pose} boca={0} frame={0} fps={FPS} id="stilllife" expresion="normal" parpadeo={0} />
    </div>
  );
};

const volumenMusica = (f: number) => interpolate(f, [0, 30, F_BACKROOMS - 30, F_BACKROOMS], [0.05, 0.06, 0.06, 0], CLAMP);

export const DURACION_PRECARGA = LINEA.total;

export const Precarga: React.FC = () => {
  const frame = useCurrentFrame();
  const t = frame / FPS;
  const oscuro = interpolate(frame, [INICIO_FINAL, INICIO_FINAL + 30], [0.64, 0.12], CLAMP);
  const luz = luzFinal(frame);
  const estatica = frame >= F_CERCA ? interpolate(frame, [F_CERCA, F_NEGRO], [0.25, 0.9], CLAMP) : 0;
  return (
    <AbsoluteFill style={{ background: C.abismo }}>
      <AbsoluteFill style={{ transform: `scale(${1.04 + 0.01 * Math.sin(t / 3)})` }}>
        <Cuarto s={t} />
      </AbsoluteFill>
      <NyxarStillLife />
      <AbsoluteFill style={{ background: `rgba(2,8,20,${oscuro})` }} />
      <AbsoluteFill style={{ background: "#e8c84a", mixBlendMode: "multiply", opacity: luz.amarillo * 0.45 }} />
      <TransitionSeries>
        {IDS.flatMap((id, i) => {
          const Comp = COMPONENTES[i];
          const items = [
            <TransitionSeries.Sequence key={id} durationInFrames={LINEA.duraciones[i]}>
              <Comp />
            </TransitionSeries.Sequence>,
          ];
          if (i < IDS.length - 1)
            items.push(<TransitionSeries.Transition key={`${id}-t`} presentation={fade()} timing={linearTiming({ durationInFrames: TRANSICION })} />);
          return items;
        })}
      </TransitionSeries>
      {frame < F_CERCA ? <NyxarEnEscena /> : null}
      <AbsoluteFill style={{ background: "#000", opacity: luz.apagon }} />
      <Estatica fuerza={estatica} />
      {frame >= F_NEGRO ? <AbsoluteFill style={{ background: "#000" }} /> : null}
      <Html5Audio loop loopVolumeCurveBehavior="extend" src={staticFile(`${CARPETA}/sfx-musica.mp3`)} volume={volumenMusica} />
      <Sfx carpeta={CARPETA} id="glitch" en={F_APAGON} volumen={0.3} />
      <Sfx carpeta={CARPETA} id="golpe" en={F_CERCA} volumen={0.5} />
      <Sfx carpeta={CARPETA} id="estatica" en={F_CERCA} volumen={0.45} dur={0.5} />
    </AbsoluteFill>
  );
};
