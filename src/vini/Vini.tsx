/**
 * "¿Por qué Vini no volvió a ser el de 2024?" en el estilo PAPEL RECORTADO (skill animaciones, MIT).
 * Tema triste: Nyxar gris (de cartulina). Todo lo que se ve va a 12 pasos por segundo (stop motion) con <Freeze>;
 * la voz y los efectos van fuera, a velocidad normal. La canción del usuario se mezcla después (mezclar-cancion.sh).
 */
import React from "react";
import { AbsoluteFill, Freeze, Html5Audio, Sequence, staticFile, useCurrentFrame } from "remotion";
import { crearLinea, type Tiempos } from "../marca/linea";
import { POSE_BASE, type Expresion, type PoseNyxar } from "../personajes/Nyxar";
import { FiltroPapelNyxar, NyxarPapel } from "./NyxarPapel";
import { rng, type P } from "./papel/curvas";
import { ESTRELLA, escalaLetras, FONDO, frente, guirnalda, LetrasPegadas, LILITA, PASOS, sacudida, subeEstrella } from "./papel/decorado";
import { DEFS, f } from "./papel/tintas";
import { Balon, BOTON_NO, BOTON_SI, Camiseta, Cinta, Contrato, ETIQUETA, FOCO, Huella, Pegado, Rotulo, Tablilla, tarjeta, TIRA, Trofeo } from "./piezas";
import tiempos from "./tiempos.json";

const FPS = 60;
const FRAMES_PASO = FPS / PASOS; // 5
export const CARPETA = "vini";
const IDS = ["gancho", "cima", "mbappe", "alonso", "mundial", "hoy", "remate", "pregunta"] as const;
type Id = (typeof IDS)[number];
const TIEMPOS = tiempos as Tiempos;
const LINEA = crearLinea<Id>({
  tiempos: TIEMPOS,
  ids: IDS,
  fps: FPS,
  pre: { gancho: 0, cima: 0.25, mbappe: 0.25, alonso: 0.25, mundial: 0.25, hoy: 0.25, remate: 0.3, pregunta: 0.3 },
  extra: { gancho: 0.4, cima: 0.5, alonso: 0.3, mundial: 0.5, hoy: 0.3, remate: 0.6, pregunta: 2.6 },
  transicion: 0,
});
export const DURACION_VINI = LINEA.total;

/** Segundo (de la escena) en que se dice una palabra. */
const M = (id: Id, palabra: string, k = 0) => LINEA.marcas(id)(palabra, k) / FPS;
/** Segundo global de una palabra. */
const G = (id: Id, palabra: string, k = 0) => (LINEA.inicios[IDS.indexOf(id)] + LINEA.marcas(id)(palabra, k)) / FPS;

/* Golpes: estrella desplegable + letras pegadas + sacudida */
type Golpe = { t: number; texto: string; c: P; tam: number; dura?: number };
const GOLPES: Golpe[] = [
  { t: G("cima", "Oro."), texto: "¡CASI!", c: [760, 600], tam: 104 },
  { t: G("mundial", "octavos"), texto: "¡FUERA!", c: [540, 560], tam: 120 },
  { t: G("remate", "confianza."), texto: "CONFIANZA", c: [540, 560], tam: 92, dura: 1.2 },
];
const T_FINAL = LINEA.total / FPS - 1.5;

/* Subtítulos en una tira de cartulina: trozos de hasta 4 palabras */
const CLAVES = new Set(["mejor", "champions,", "best.", "oro.", "mbappé.", "protagonista.", "alonso", "atascó", "brasil,", "octavos", "2032.", "marca.", "talento.", "confianza.", "sí", "no."]);
/** Junta "dos mil veinticuatro" → "2024" y "dos mil treinta y dos" → "2032" para que se lean con cifras. */
const conCifras = (pal: Tiempos["voz"][string]["palabras"]) => {
  const out: typeof pal = [];
  for (let i = 0; i < pal.length; i++) {
    const w = (k: number) => (pal[i + k]?.p ?? "").toLowerCase();
    if (w(0) === "dos" && w(1) === "mil" && w(2).startsWith("veinticuatro")) {
      out.push({ p: "2024" + pal[i + 2].p.slice(12), ini: pal[i].ini, fin: pal[i + 2].fin });
      i += 2;
    } else if (w(0) === "dos" && w(1) === "mil" && w(2) === "treinta" && w(3) === "y" && w(4).startsWith("dos")) {
      out.push({ p: "2032" + pal[i + 4].p.slice(3), ini: pal[i].ini, fin: pal[i + 4].fin });
      i += 4;
    } else out.push(pal[i]);
  }
  return out;
};
const trozos = (id: Id) => {
  const pal = conCifras(TIEMPOS.voz[id].palabras);
  const out: { ini: number; fin: number; ws: typeof pal }[] = [];
  let cur: typeof pal = [];
  pal.forEach((w, i) => {
    cur.push(w);
    const corte = cur.length >= 4 || /[.,?!:]$/.test(w.p) || i === pal.length - 1;
    if (corte) {
      out.push({ ini: cur[0].ini, fin: pal[i + 1] ? pal[i + 1].ini : w.fin + 0.6, ws: cur });
      cur = [];
    }
  });
  return out;
};
const TROZOS = Object.fromEntries(IDS.map((id) => [id, trozos(id)])) as Record<Id, ReturnType<typeof trozos>>;

const Subtitulos: React.FC<{ id: Id; local: number; n: number }> = ({ id, local, n }) => {
  const pre = LINEA.preDe(id) / FPS;
  const tv = local - pre;
  const tr = TROZOS[id].find((t) => tv >= t.ini - 0.05 && tv < t.fin);
  if (!tr) return null;
  const texto = tr.ws.map((w) => w.p);
  return (
    <g transform={`translate(540 330) ${`rotate(${((rng(n * 7 + 1)() - 0.5) * 0.8).toFixed(2)})`}`}>
      {TIRA()}
      <text x={0} y={20} textAnchor="middle" fontFamily={LILITA} fontSize={54}>
        {texto.map((w, i) => (
          <tspan key={i} fill={CLAVES.has(w.toLowerCase()) ? "#E2553F" : "#3A2416"}>
            {w + (i < texto.length - 1 ? " " : "")}
          </tspan>
        ))}
      </text>
    </g>
  );
};

/* Etiqueta de la escena (cinta mostaza) */
const ETIQ: Record<Id, string> = {
  gancho: "",
  cima: "2024: LA CIMA",
  mbappe: "2024-25",
  alonso: "2025-26",
  mundial: "MUNDIAL 2026",
  hoy: "HOY",
  remate: "LA CLAVE",
  pregunta: "¿Y TÚ?",
};

/* ---------- el contenido de cada escena (en la pared) ---------- */
const TARJ_BEST = tarjeta(560, 250);
const TARJ_PEQ = tarjeta(300, 230);
const TARJ_ANCHA = tarjeta(640, 170);

const Escena: React.FC<{ id: Id; tq: number; n: number }> = ({ id, tq, n }) => {
  const m = (w: string, k = 0) => M(id, w, k);
  switch (id) {
    case "gancho":
      return (
        <>
          <Pegado c={[540, 760]} tq={tq} t0={-1} n={n} s={1}>
            {TARJ_BEST()}
            <Rotulo texto="THE BEST" y={-20} tam={92} />
            <Rotulo texto="FIFA · 2024" y={60} tam={52} color="#BE3F2D" />
          </Pegado>
          <Pegado c={[300, 1030]} tq={tq} t0={-1} n={n} s={2} giro={-6}>
            <Trofeo />
          </Pegado>
          <LetrasPegadas texto="¡EL MEJOR!" c={[600, 560]} tam={104} esc={1} n={n} />
        </>
      );
    case "cima":
      return (
        <>
          <Pegado c={[290, 640]} tq={tq} t0={m("final")} n={n} s={3} giro={-3}>
            {TARJ_PEQ()}
            <Balon r={1} />
            <Rotulo texto="GOL EN LA" y={78} tam={34} />
            <Rotulo texto="FINAL" y={-62} tam={40} color="#BE3F2D" />
          </Pegado>
          <Pegado c={[760, 640]} tq={tq} t0={m("Best.")} n={n} s={4} giro={3}>
            {TARJ_PEQ()}
            <g transform="translate(0 0) scale(0.7)">
              <Trofeo />
            </g>
            <Rotulo texto="THE BEST" y={98} tam={38} />
          </Pegado>
          <Pegado c={[540, 980]} tq={tq} t0={m("Balón")} n={n} s={5} giro={-2}>
            {TARJ_ANCHA()}
            <Rotulo texto="BALÓN DE ORO: 2.º" y={18} tam={58} color="#6A6E88" />
          </Pegado>
        </>
      );
    case "mbappe": {
      const foco = tq >= m("protagonista.") ? 1 : 0;
      return (
        <>
          <g transform={`translate(${foco ? 740 : 340} 560) scale(1.3)`}>{FOCO({ opacity: 0.6 })}</g>
          <Pegado c={[330, 820]} tq={tq} t0={m("Entonces")} n={n} s={6} giro={-4}>
            <g opacity={foco ? 0.6 : 1} transform="scale(1.35)">
              <Camiseta tipo="blanca" nombre="VINI" />
            </g>
          </Pegado>
          <Pegado c={[750, 820]} tq={tq} t0={m("Mbappé.")} n={n} s={7} giro={4}>
            <g transform="scale(1.35)">
              <Camiseta tipo="blanca" nombre="MBAPPÉ" />
            </g>
          </Pegado>
        </>
      );
    }
    case "alonso":
      return (
        <>
          <Pegado c={[330, 700]} tq={tq} t0={m("Alonso")} n={n} s={8} giro={-5}>
            <Tablilla numero="7" />
            <Rotulo texto="CAMBIO" y={-104} tam={38} color="#3A2416" />
          </Pegado>
          <Pegado c={[330, 1010]} tq={tq} t0={m("terminaba")} n={n} s={9} giro={2}>
            {tarjeta(330, 110)()}
            <Rotulo texto="9 de 33 completos" y={14} tam={36} />
          </Pegado>
          <Pegado c={[760, 760]} tq={tq} t0={m("renovación")} n={n} s={10} giro={3}>
            <Contrato />
          </Pegado>
          <Pegado c={[760, 780]} tq={tq} t0={m("atascó")} n={n} s={11} giro={-12}>
            <Cinta texto="EN PAUSA" />
          </Pegado>
        </>
      );
    case "mundial":
      return (
        <>
          <Pegado c={[540, 690]} tq={tq} t0={m("Mundial")} n={n} s={12}>
            <g transform="scale(1.15)">
              <Camiseta tipo="amarilla" dorsal="7" />
            </g>
          </Pegado>
          <Pegado c={[540, 915]} tq={tq} t0={m("cuatro")} n={n} s={24} giro={2}>
            {tarjeta(560, 150)()}
            {[0, 1, 2, 3].map((k) => (
              <g key={k} transform={`translate(${-200 + k * 70} 0)`}>
                <Balon r={0.62} />
              </g>
            ))}
            <Rotulo texto="4 GOLES" x={150} y={20} tam={56} color="#2D7C42" />
          </Pegado>
          <Pegado c={[540, 1045]} tq={tq} t0={m("Noruega.")} n={n} s={13} giro={-3}>
            {TARJ_ANCHA()}
            <Rotulo texto="Noruega 2 - 1 Brasil" y={18} tam={54} color="#BE3F2D" />
          </Pegado>
        </>
      );
    case "hoy":
      return (
        <>
          <Pegado c={[330, 760]} tq={tq} t0={m("renovó")} n={n} s={14} giro={-4}>
            <Contrato />
          </Pegado>
          <Pegado c={[330, 800]} tq={tq} t0={m("treinta")} n={n} s={15} giro={10}>
            <Cinta texto="HASTA 2032" color="#2D7C42" />
          </Pegado>
          <Pegado c={[770, 760]} tq={tq} t0={m("apenas")} n={n} s={16} giro={4}>
            {TARJ_PEQ()}
            <g transform="translate(0 -20)">
              <Balon r={0.9} />
            </g>
            <Rotulo texto="¿Y LOS GOLES?" y={84} tam={34} color="#BE3F2D" />
          </Pegado>
        </>
      );
    case "remate":
      return (
        <>
          <Pegado c={[540, 860]} tq={tq} t0={m("talento.")} n={n} s={17} giro={-2}>
            {TARJ_ANCHA()}
            <Rotulo texto="TALENTO: SÍ" y={20} tam={66} color="#2D7C42" />
          </Pegado>
        </>
      );
    case "pregunta": {
      const firma = m("leo.") + 0.3;
      return (
        <>
          <Pegado c={[340, 780]} tq={tq} t0={m("Sí")} n={n} s={18} giro={-5}>
            {BOTON_SI()}
            <Rotulo texto="SÍ" y={34} tam={110} color="#F8EFDD" />
          </Pegado>
          <Pegado c={[740, 780]} tq={tq} t0={m("no.")} n={n} s={19} giro={5}>
            {BOTON_NO()}
            <Rotulo texto="NO" y={34} tam={110} color="#F8EFDD" />
          </Pegado>
          <Pegado c={[540, 1010]} tq={tq} t0={firma} n={n} s={30}>
            {tarjeta(470, 90)()}
            <Rotulo texto="@ithnoir · comenta" y={14} tam={40} x={-30} />
            <g transform="translate(200 -4) scale(0.55)">
              <Huella />
            </g>
          </Pegado>
        </>
      );
    }
  }
};

/* ---------- Nyxar: sitio y gesto por escena (cambia de sitio de un salto, por pasos) ---------- */
const SITIO: Record<Id, number> = { gancho: 600, cima: 600, mbappe: 40, alonso: 600, mundial: 620, hoy: 600, remate: 40, pregunta: 600 };
const gesto = (id: Id, local: number): { pose: PoseNyxar; expresion: Expresion } => {
  const s = local;
  const m = (w: string) => M(id, w);
  const b = { ...POSE_BASE };
  switch (id) {
    case "gancho":
      return { pose: { ...b, brazoD: 140, brazoI: 18, mirarX: -0.5, mirarY: -0.5 }, expresion: s > m("mejor") ? "triste" : "normal" };
    case "cima":
      return { pose: { ...b, mirarX: -0.6, mirarY: -0.6 }, expresion: s > m("Oro.") ? "triste" : "normal" };
    case "mbappe":
      return { pose: { ...b, mirarX: 0.6, mirarY: -0.4 }, expresion: "pensativo" };
    case "alonso":
      return { pose: { ...b, cabeza: -5, mirarX: -0.6, mirarY: -0.4 }, expresion: "triste" };
    case "mundial":
      return { pose: { ...b, brazoI: 30, brazoD: 30, mirarX: 0.6, mirarY: -0.5 }, expresion: s > m("octavos") ? "triste" : "sorprendido" };
    case "hoy":
      return { pose: { ...b, mirarX: -0.6, mirarY: -0.4 }, expresion: "pensativo" };
    case "remate":
      return { pose: { ...b, cabeza: -6, mirarY: 0.6 }, expresion: "triste" };
    case "pregunta":
      return { pose: { ...b, brazoD: 140, brazoI: 18 }, expresion: "normal" };
  }
};

/* ---------- la imagen (se congela a 12 pasos por segundo) ---------- */
const Imagen: React.FC = () => {
  const frame = useCurrentFrame();
  const n = Math.floor(frame / FRAMES_PASO);
  const tq = n / PASOS;
  const { id, local } = LINEA.escenaEn(frame);
  const lq = tq - LINEA.inicios[IDS.indexOf(id)] / FPS;
  const sac = sacudida(tq, GOLPES.map((g) => g.t));
  const g = gesto(id, lq);
  const final = tq >= T_FINAL;
  const apagon = final ? Math.min(0.55, (tq - T_FINAL) * 0.9) : 0;
  const parpadeo = rng(400 + n)() * 0.035 + (final && n % 3 === 0 ? 0.25 : 0);
  const golpe = GOLPES.find((gg) => tq >= gg.t - 0.001 && tq < gg.t + (gg.dura ?? 0.8) + 0.3);
  return (
    <AbsoluteFill>
      <FiltroPapelNyxar />
      <svg viewBox="0 0 1080 1920" width={1080} height={1920} style={{ position: "absolute", inset: 0 }}>
        {DEFS}
        <g transform={`translate(${sac[0]} ${sac[1]})`}>
          {FONDO}
          {guirnalda(n)}
          {golpe ? (
            <g transform={`translate(${golpe.c[0]} ${golpe.c[1] + 150}) scale(1 ${subeEstrella(tq, golpe.t, (golpe.dura ?? 0.8) - 0.3)})`}>
              {ESTRELLA.map((e, i) => (
                <path key={i} d={e.d} fill={f(e.t)} filter={`url(#gpp-${e.s})`} />
              ))}
            </g>
          ) : null}
          {!final ? (
            <>
              {ETIQ[id] ? <g transform="translate(540 440)">
                {ETIQUETA()}
                <text x={0} y={14} textAnchor="middle" fontFamily={LILITA} fontSize={34} fill="#3A2416">
                  {ETIQ[id]}
                </text>
              </g> : null}
              <g transform="translate(540 790) scale(1.3) translate(-540 -790)">
                <Escena id={id} tq={lq} n={n} />
              </g>
            </>
          ) : null}
        </g>
      </svg>
      {/* Nyxar de cartulina, fuera del SVG para usar el componente vectorial */}
      <div style={{ position: "absolute", left: SITIO[id] + sac[0], top: 1180 + sac[1], width: 440, transform: `rotate(${((rng(n * 3 + 5)() - 0.5) * 1.2).toFixed(2)}deg)` }}>
        <NyxarPapel ancho={440} pose={g.pose} boca={LINEA.aperturaBoca(frame)} frame={frame} fps={FPS} expresion={final ? "sorprendido" : g.expresion} />
      </div>
      {/* el Still Life de cartulina en la pared, solo al final (lore) */}
      {final && n % 4 !== 1 ? (
        <div style={{ position: "absolute", left: SITIO[id] === 40 ? 700 : 120, top: 820, width: 220, filter: "sepia(1) saturate(2.4) hue-rotate(-14deg) brightness(0.8) contrast(1.3)" }}>
          <NyxarPapel ancho={220} pose={{ ...POSE_BASE, brazoI: 8, brazoD: 8 }} boca={0} frame={0} fps={FPS} expresion="normal" parpadeo={0} />
        </div>
      ) : null}
      <svg viewBox="0 0 1080 1920" width={1080} height={1920} style={{ position: "absolute", inset: 0 }}>
        <g transform={`translate(${sac[0]} ${sac[1]})`}>
          {!final ? <Subtitulos id={id} local={local / FPS} n={n} /> : null}
          {golpe ? <LetrasPegadas texto={golpe.texto} c={golpe.c} tam={golpe.tam} esc={escalaLetras(tq, golpe.t, golpe.dura ?? 0.8)} n={n} /> : null}
          {frente(n)}
        </g>
        <rect width={1080} height={1920} fill="url(#gpp-luz)" />
        <rect width={1080} height={1920} fill="url(#gpp-vineta)" />
        <rect width={1080} height={1920} fill="#1E1006" opacity={0.012 + parpadeo + apagon} />
      </svg>
    </AbsoluteFill>
  );
};

/* ---------- sonido (sin congelar) ---------- */
const s = (t: number) => Math.round(t * FPS);
const Sfx: React.FC<{ id: string; t: number; v?: number }> = ({ id, t, v = 0.3 }) => (
  <Sequence from={Math.max(0, s(t))} layout="none">
    <Html5Audio src={staticFile(`${CARPETA}/sfx-${id}.mp3`)} volume={v} />
  </Sequence>
);
const PEGADOS: [Id, string][] = [
  ["cima", "final"], ["cima", "Best."], ["cima", "Balón"], ["mbappe", "Entonces"], ["mbappe", "Mbappé."], ["alonso", "Alonso"], ["alonso", "terminaba"], ["alonso", "renovación"],
  ["mundial", "Mundial"], ["mundial", "cuatro"], ["mundial", "Noruega."], ["hoy", "renovó"], ["hoy", "treinta"], ["hoy", "apenas"], ["remate", "talento."], ["pregunta", "Sí"], ["pregunta", "no."],
];

export const Vini: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill style={{ background: "#2a1606" }}>
      <Freeze frame={Math.floor(frame / FRAMES_PASO) * FRAMES_PASO}>
        <Imagen />
      </Freeze>
      {IDS.map((id, i) => (
        <Sequence key={id} from={LINEA.inicios[i] + LINEA.preDe(id)} layout="none">
          <Html5Audio src={staticFile(`${CARPETA}/voz-${id}.mp3`)} volume={1} />
        </Sequence>
      ))}
      <Sfx id="golpe" t={0} v={0.3} />
      <Sfx id="papel" t={0.05} v={0.4} />
      {PEGADOS.map(([id, w], k) => (
        <Sfx key={k} id="papel" t={G(id, w)} v={0.35} />
      ))}
      {GOLPES.map((g, k) => (
        <React.Fragment key={k}>
          <Sfx id="golpe" t={g.t} v={0.3} />
          <Sfx id="pop" t={g.t + 0.05} v={0.25} />
        </React.Fragment>
      ))}
      <Sfx id="latido" t={T_FINAL} v={0.4} />
      <Sfx id="estatica" t={LINEA.total / FPS - 0.3} v={0.25} />
    </AbsoluteFill>
  );
};
