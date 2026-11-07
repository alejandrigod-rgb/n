import { AbsoluteFill, Html5Audio, interpolate, random, Sequence, spring, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { IdEscena, Palabra, PRE, TIEMPOS } from "./linea";
import { C, CLAMP, FPS, MONO, TITULO } from "./tema";

export const usePop = (desde: number, damping = 11) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  return spring({ frame: frame - desde, fps, config: { damping } });
};

export const Pop: React.FC<{ desde: number; children: React.ReactNode; style?: React.CSSProperties; giro?: number }> = ({ desde, children, style, giro = 0 }) => {
  const s = usePop(desde);
  return <div style={{ transform: `scale(${s}) rotate(${(1 - s) * giro}deg)`, opacity: Math.min(1, s * 2), ...style }}>{children}</div>;
};

export const Sfx: React.FC<{ id: string; en: number; volumen?: number; dur?: number }> = ({ id, en, volumen = 0.35, dur }) => (
  <Sequence from={Math.max(0, Math.round(en))} durationInFrames={dur} layout="none">
    <Html5Audio src={staticFile(`pirateria/sfx-${id}.mp3`)} volume={volumen} />
  </Sequence>
);

/** Onda expansiva de motion graphics para acentuar un momento. */
export const Rafaga: React.FC<{ en: number; color: string; x?: number; y?: number; tamano?: number }> = ({ en, color, x = 0, y = 0, tamano = 420 }) => {
  const frame = useCurrentFrame();
  const p = interpolate(frame, [en, en + 18], [0, 1], CLAMP);
  if (p <= 0 || p >= 1) return null;
  return (
    <svg width={tamano} height={tamano} viewBox="-100 -100 200 200" style={{ position: "absolute", left: "50%", top: "50%", transform: `translate(calc(-50% + ${x}px), calc(-50% + ${y}px))`, pointerEvents: "none" }}>
      <circle r={20 + 75 * p} fill="none" stroke={color} strokeWidth={6 * (1 - p)} opacity={1 - p} />
      {new Array(10).fill(0).map((_, k) => {
        const a = (k / 10) * Math.PI * 2;
        const r1 = 30 + 60 * p;
        const r2 = r1 + 14 * (1 - p);
        return <line key={k} x1={Math.cos(a) * r1} y1={Math.sin(a) * r1} x2={Math.cos(a) * r2} y2={Math.sin(a) * r2} stroke={color} strokeWidth={5} strokeLinecap="round" opacity={1 - p} />;
      })}
    </svg>
  );
};

/** Sello "SIN PERMISO" que cae de golpe. */
export const Sello: React.FC<{ en: number; texto: string; color?: string; giro?: number; tamano?: number }> = ({ en, texto, color = C.rojo, giro = -12, tamano = 70 }) => {
  const frame = useCurrentFrame();
  const p = interpolate(frame, [en, en + 7], [0, 1], { ...CLAMP });
  if (frame < en) return null;
  const temblor = frame < en + 12 ? Math.sin(frame * 3) * (12 - (frame - en)) * 0.6 : 0;
  return (
    <div
      style={{
        position: "absolute",
        left: "50%",
        top: "50%",
        transform: `translate(-50%, -50%) translate(${temblor}px, 0) rotate(${giro}deg) scale(${2.4 - 1.4 * p})`,
        opacity: p,
        border: `8px solid ${color}`,
        color,
        borderRadius: 18,
        padding: "6px 30px",
        fontFamily: TITULO,
        fontWeight: 800,
        fontSize: tamano,
        letterSpacing: 4,
        background: "rgba(15,29,51,0.75)",
        whiteSpace: "nowrap",
      }}
    >
      {texto}
    </div>
  );
};

export const Chip: React.FC<{ texto: string; color: string; desde: number }> = ({ texto, color, desde }) => (
  <Pop desde={desde}>
    <div style={{ display: "inline-block", fontFamily: MONO, fontWeight: 700, fontSize: 34, color: "#0f1d33", background: color, padding: "8px 24px", borderRadius: 999 }}>{texto}</div>
  </Pop>
);

/** Subtítulos estilo TikTok: pocas palabras, la que suena resaltada. */
const Subtitulos: React.FC<{ id: IdEscena }> = ({ id }) => {
  const frame = useCurrentFrame();
  const t = (frame - PRE) / FPS;
  const palabras = TIEMPOS.voz[id].palabras;
  const grupos: Palabra[][] = [];
  let actual: Palabra[] = [];
  palabras.forEach((w) => {
    actual.push(w);
    if (/[,.:;?!]$/.test(w.p) || actual.length >= 4) {
      grupos.push(actual);
      actual = [];
    }
  });
  if (actual.length) grupos.push(actual);
  const i = grupos.findIndex((g, k) => {
    const fin = grupos[k + 1] ? grupos[k + 1][0].ini - 0.03 : g[g.length - 1].fin + 0.5;
    return t >= g[0].ini - 0.03 && t < fin;
  });
  if (i < 0) return null;
  const g = grupos[i];
  const entrada = interpolate(t, [g[0].ini - 0.03, g[0].ini + 0.1], [0.85, 1], CLAMP);
  return (
    <div style={{ position: "absolute", top: 985, left: 40, right: 40, display: "flex", justifyContent: "center", flexWrap: "wrap", gap: "0 30px", transform: `scale(${entrada})` }}>
      {g.map((w, k) => {
        const ahora = t >= w.ini && t < w.fin + 0.06;
        return (
          <span
            key={k}
            style={{
              fontFamily: TITULO,
              fontWeight: 800,
              fontSize: 76,
              lineHeight: 1.1,
              color: ahora ? C.amarillo : C.texto,
              WebkitTextStroke: "12px #0b1424",
              paintOrder: "stroke fill",
              display: "inline-block",
              transform: `scale(${ahora ? 1.06 : 1}) translateY(${ahora ? -4 : 0}px)`,
              margin: "0 4px",
            }}
          >
            {w.p}
          </span>
        );
      })}
    </div>
  );
};

const Voz: React.FC<{ id: IdEscena }> = ({ id }) => (
  <Sequence from={PRE} layout="none">
    <Html5Audio src={staticFile(`pirateria/voz-${id}.mp3`)} volume={1} />
  </Sequence>
);

const Titulo: React.FC<{ etiqueta: string; titulo: string; color: string }> = ({ etiqueta, titulo, color }) => {
  const s = usePop(0, 14);
  return (
    <div style={{ position: "absolute", top: 120, left: 40, right: 40, textAlign: "center" }}>
      <div style={{ display: "inline-block", transform: `scale(${s})`, background: color, color: "#0f1d33", fontFamily: MONO, fontWeight: 700, fontSize: 30, padding: "6px 22px", borderRadius: 999, letterSpacing: 2 }}>{etiqueta}</div>
      <div style={{ fontFamily: TITULO, fontWeight: 800, fontSize: 84, lineHeight: 1.05, color: C.texto, marginTop: 14, opacity: s, transform: `translateY(${(1 - s) * 40}px)`, textShadow: "0 8px 0 rgba(0,0,0,0.25)" }}>
        {titulo}
      </div>
    </div>
  );
};

export const Escena: React.FC<{ id: IdEscena; etiqueta: string; titulo: string; color: string; children: React.ReactNode }> = ({ id, etiqueta, titulo, color, children }) => (
  <AbsoluteFill>
    <Titulo etiqueta={etiqueta} titulo={titulo} color={color} />
    <div style={{ position: "absolute", top: 340, height: 620, left: 0, right: 0, display: "flex", alignItems: "center", justifyContent: "center" }}>{children}</div>
    <Subtitulos id={id} />
    <Voz id={id} />
    <Sfx id="whoosh" en={0} volumen={0.25} />
  </AbsoluteFill>
);

/** Fondo animado: degradado, rejilla de puntos y burbujas que flotan. */
export const Fondo: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill style={{ background: `radial-gradient(ellipse at 50% 30%, ${C.fondo2}, ${C.fondo1} 75%)` }}>
      <AbsoluteFill style={{ backgroundImage: "radial-gradient(#ffffff12 2px, transparent 2px)", backgroundSize: "54px 54px", backgroundPosition: `0 ${-frame * 0.4}px` }} />
      {new Array(14).fill(0).map((_, i) => {
        const x = random(`fx${i}`) * 1080;
        const v = 0.3 + random(`fv${i}`) * 0.6;
        const y = ((random(`fy${i}`) * 2100 - frame * v) % 2100 + 2100) % 2100 - 100;
        const r = 10 + random(`fr${i}`) * 40;
        return <div key={i} style={{ position: "absolute", left: x + Math.sin(frame / 40 + i) * 30, top: y, width: r, height: r, borderRadius: r, background: [C.cian, C.amarillo, C.rosa][i % 3], opacity: 0.07 }} />;
      })}
      {/* Foco y suelo para el gato */}
      <div style={{ position: "absolute", left: 140, right: 140, top: 1180, height: 700, background: "radial-gradient(ellipse at 50% 85%, rgba(76,201,240,0.22), transparent 65%)" }} />
    </AbsoluteFill>
  );
};

export { C };
