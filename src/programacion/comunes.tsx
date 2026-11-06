import {
  AbsoluteFill,
  Html5Audio,
  interpolate,
  random,
  Sequence,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { C, CLAMP, FPS, MONO, SANS } from "./tema";
import tiemposJson from "./tiempos.json";

type Palabra = { p: string; ini: number; fin: number };
type Tiempos = { voz: Record<string, { texto: string; duracion: number; palabras: Palabra[] }>; sfx: Record<string, number> };
export const TIEMPOS = tiemposJson as Tiempos;

/** Fotogramas de silencio antes de que empiece la voz en cada escena. */
export const PRE = 12;

const normalizar = (s: string) =>
  s.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/[^a-z0-9]/g, "");

/** Devuelve el fotograma (dentro de la escena) en que el narrador dice `palabra`. */
export const marcas = (id: string) => (palabra: string, n = 0) => {
  let c = 0;
  for (const w of TIEMPOS.voz[id].palabras) {
    if (normalizar(w.p) === normalizar(palabra)) {
      if (c === n) return PRE + Math.round(w.ini * FPS);
      c++;
    }
  }
  throw new Error(`"${palabra}" no aparece en la narración de "${id}"`);
};

export const duracionEscena = (id: string, extra = 0) =>
  PRE + Math.ceil((TIEMPOS.voz[id].duracion + 0.9 + extra) * FPS);

export const usePop = (desde: number, damping = 12) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  return spring({ frame: frame - desde, fps, config: { damping } });
};

export const Pop: React.FC<{ desde: number; children: React.ReactNode; style?: React.CSSProperties }> = ({ desde, children, style }) => {
  const s = usePop(desde);
  return <div style={{ transform: `scale(${s})`, opacity: Math.min(1, s * 2), ...style }}>{children}</div>;
};

export const Aparecer: React.FC<{ desde: number; children: React.ReactNode; dy?: number; style?: React.CSSProperties }> = ({ desde, children, dy = 30, style }) => {
  const s = usePop(desde, 200);
  return <div style={{ opacity: s, transform: `translateY(${(1 - s) * dy}px)`, ...style }}>{children}</div>;
};

export const Sfx: React.FC<{ id: string; en: number; volumen?: number; dur?: number }> = ({ id, en, volumen = 0.4, dur }) => (
  <Sequence from={Math.max(0, Math.round(en))} durationInFrames={dur} layout="none">
    <Html5Audio src={staticFile(`programacion/sfx-${id}.mp3`)} volume={volumen} />
  </Sequence>
);

const Voz: React.FC<{ id: string }> = ({ id }) => (
  <Sequence from={PRE} layout="none">
    <Html5Audio src={staticFile(`programacion/voz-${id}.mp3`)} volume={1} />
  </Sequence>
);

/** Subtítulos tipo karaoke a partir de las marcas de tiempo de ElevenLabs. */
const Subtitulos: React.FC<{ id: string }> = ({ id }) => {
  const frame = useCurrentFrame();
  const t = (frame - PRE) / FPS;
  const palabras = TIEMPOS.voz[id].palabras;
  const grupos: Palabra[][] = [];
  let actual: Palabra[] = [];
  palabras.forEach((w) => {
    actual.push(w);
    if (/[,.:;?!]$/.test(w.p) || actual.length >= 7) {
      grupos.push(actual);
      actual = [];
    }
  });
  if (actual.length) grupos.push(actual);
  const i = grupos.findIndex((g, k) => {
    const fin = grupos[k + 1] ? grupos[k + 1][0].ini - 0.05 : g[g.length - 1].fin + 0.6;
    return t >= g[0].ini - 0.05 && t < fin;
  });
  if (i < 0) return null;
  const g = grupos[i];
  const op = interpolate(t, [g[0].ini - 0.05, g[0].ini + 0.1], [0, 1], CLAMP);
  return (
    <div style={{ position: "absolute", bottom: 56, left: 0, right: 0, display: "flex", justifyContent: "center" }}>
      <div
        style={{
          opacity: op,
          background: "rgba(5, 9, 22, 0.72)",
          border: `1px solid ${C.borde}`,
          borderRadius: 16,
          padding: "12px 30px",
          fontFamily: SANS,
          fontWeight: 500,
          fontSize: 42,
          color: C.texto,
          display: "flex",
          gap: 12,
        }}
      >
        {g.map((w, k) => {
          const dicha = t >= w.ini;
          const ahora = dicha && t < w.fin + 0.08;
          return (
            <span key={k} style={{ color: ahora ? C.cian : dicha ? C.texto : "#ffffff59" }}>
              {w.p}
            </span>
          );
        })}
      </div>
    </div>
  );
};

const Titulo: React.FC<{ etiqueta: string; titulo: string; color: string }> = ({ etiqueta, titulo, color }) => {
  const s = usePop(0, 200);
  return (
    <div style={{ position: "absolute", top: 64, left: 0, right: 0, textAlign: "center", opacity: s, transform: `translateY(${(1 - s) * -30}px)` }}>
      <div style={{ fontFamily: MONO, fontWeight: 700, fontSize: 26, letterSpacing: 4, color }}>{etiqueta}</div>
      <div style={{ fontFamily: SANS, fontWeight: 700, fontSize: 68, color: C.texto, marginTop: 4 }}>{titulo}</div>
    </div>
  );
};

export const Escena: React.FC<{ id: string; etiqueta?: string; titulo?: string; color?: string; children: React.ReactNode }> = ({
  id,
  etiqueta,
  titulo,
  color = C.cian,
  children,
}) => (
  <AbsoluteFill>
    {titulo ? <Titulo etiqueta={etiqueta ?? ""} titulo={titulo} color={color} /> : null}
    <div
      style={{
        position: "absolute",
        left: 0,
        right: 0,
        top: titulo ? 200 : 0,
        bottom: 150,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
      }}
    >
      {children}
    </div>
    <Subtitulos id={id} />
    <Voz id={id} />
  </AbsoluteFill>
);

/** Ventana de editor de código. */
export const Ventana: React.FC<{ titulo: string; ancho: number; children: React.ReactNode; acento?: string; style?: React.CSSProperties }> = ({
  titulo,
  ancho,
  children,
  acento = C.cian,
  style,
}) => (
  <div
    style={{
      width: ancho,
      background: C.panel,
      border: `2px solid ${C.borde}`,
      borderRadius: 20,
      overflow: "hidden",
      boxShadow: `0 30px 80px rgba(0,0,0,0.45), 0 0 0 1px ${acento}22`,
      ...style,
    }}
  >
    <div style={{ display: "flex", alignItems: "center", gap: 10, padding: "14px 20px", background: "#ffffff08", borderBottom: `1px solid ${C.borde}` }}>
      {["#f87171", "#fbbf24", "#4ade80"].map((c) => (
        <div key={c} style={{ width: 16, height: 16, borderRadius: 8, background: c }} />
      ))}
      <div style={{ fontFamily: MONO, fontSize: 22, color: C.tenue, marginLeft: 14 }}>{titulo}</div>
    </div>
    <div style={{ padding: "24px 30px" }}>{children}</div>
  </div>
);

export type Segmento = [string, string];

/** Código que se escribe solo, letra por letra. */
export const Codigo: React.FC<{ lineas: Segmento[][]; desde: number; cps?: number; tamano?: number; cursor?: boolean }> = ({
  lineas,
  desde,
  cps = 22,
  tamano = 34,
  cursor = true,
}) => {
  const frame = useCurrentFrame();
  let restantes = Math.max(0, Math.floor(((frame - desde) / FPS) * cps));
  const total = lineas.reduce((a, l) => a + l.reduce((b, s) => b + s[0].length, 0), 0);
  const escribiendo = restantes < total;
  const parpadeo = Math.floor(frame / 15) % 2 === 0;
  let cursorPuesto = false;
  return (
    <div style={{ fontFamily: MONO, fontWeight: 500, fontSize: tamano, lineHeight: 1.6, whiteSpace: "pre" }}>
      {lineas.map((linea, i) => {
        const largo = linea.reduce((b, s) => b + s[0].length, 0);
        const visibles = Math.min(largo, restantes);
        restantes -= visibles;
        let quedan = visibles;
        const ponerCursor = !cursorPuesto && cursor && (visibles < largo || i === lineas.length - 1) && frame >= desde;
        if (ponerCursor) cursorPuesto = true;
        return (
          <div key={i} style={{ minHeight: tamano * 1.6 }}>
            <span style={{ color: "#ffffff33", marginRight: 26 }}>{i + 1}</span>
            {linea.map(([texto, color], k) => {
              const parte = texto.slice(0, Math.max(0, quedan));
              quedan -= parte.length;
              return (
                <span key={k} style={{ color }}>
                  {parte}
                </span>
              );
            })}
            {ponerCursor && (escribiendo || parpadeo) ? <span style={{ background: C.cian, color: C.cian }}>▍</span> : null}
          </div>
        );
      })}
    </div>
  );
};

export const duracionTipeo = (lineas: Segmento[][], cps = 22) =>
  Math.ceil((lineas.reduce((a, l) => a + l.reduce((b, s) => b + s[0].length, 0), 0) / cps) * FPS);

const GLIFOS = "{ } ( ) < > ; = 0 1 [ ] / * + #".split(" ");

export const Fondo: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill style={{ background: `radial-gradient(ellipse at 50% 35%, ${C.fondo2}, ${C.fondo1} 70%)` }}>
      <AbsoluteFill style={{ backgroundImage: "radial-gradient(#ffffff14 1.5px, transparent 1.5px)", backgroundSize: "44px 44px" }} />
      {new Array(18).fill(0).map((_, i) => {
        const x = random(`gx${i}`) * 1920;
        const v = 0.15 + random(`gv${i}`) * 0.35;
        const y = ((random(`gy${i}`) * 1200 - frame * v) % 1200 + 1200) % 1200 - 60;
        return (
          <div key={i} style={{ position: "absolute", left: x, top: y, fontFamily: MONO, fontSize: 30 + random(`gs${i}`) * 40, color: "#ffffff", opacity: 0.05 }}>
            {GLIFOS[i % GLIFOS.length]}
          </div>
        );
      })}
    </AbsoluteFill>
  );
};

export const Flecha: React.FC<{ progreso: number; ancho?: number; color?: string }> = ({ progreso, ancho = 160, color = C.tenue }) => (
  <svg width={ancho} height={60} viewBox={`0 0 ${ancho} 60`} style={{ opacity: progreso }}>
    <line x1={10} y1={30} x2={10 + (ancho - 40) * progreso} y2={30} stroke={color} strokeWidth={6} strokeLinecap="round" />
    {progreso > 0.9 ? <polygon points={`${ancho - 30},14 ${ancho - 6},30 ${ancho - 30},46`} fill={color} /> : null}
  </svg>
);
