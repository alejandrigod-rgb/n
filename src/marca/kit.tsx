/** Piezas visuales de la marca AEZ, reutilizables en cualquier video (ver MARCA.md). */
import { AbsoluteFill, Html5Audio, interpolate, random, Sequence, spring, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import type { Palabra } from "./linea";
import { C, CLAMP, F } from "./tema";

/** Segundos transcurridos (las animaciones van en tiempo, no en fotogramas). */
export const useSeg = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  return frame / fps;
};

export const usePop = (desde: number, damping = 12) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  return spring({ frame: frame - desde, fps, config: { damping } });
};

/** Entrada con muelle (y fundido de salida opcional). */
export const Pop: React.FC<{ desde: number; children: React.ReactNode; style?: React.CSSProperties; giro?: number; hasta?: number }> = ({ desde, children, style, giro = 0, hasta }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const s = spring({ frame: frame - desde, fps, config: { damping: 12 } });
  const fuera = hasta === undefined ? 1 : interpolate(frame, [hasta, hasta + fps * 0.5], [1, 0], CLAMP);
  return <div style={{ transform: `scale(${s}) rotate(${(1 - s) * giro}deg)`, opacity: Math.min(1, s * 2) * fuera, ...style }}>{children}</div>;
};

/** Todo respira: late y flota. */
export const Respira: React.FC<{ children: React.ReactNode; amp?: number; fase?: number; style?: React.CSSProperties }> = ({ children, amp = 0.03, fase = 0, style }) => {
  const s = useSeg();
  return <div style={{ transform: `translateY(${Math.sin(s * 1.6 + fase) * 8}px) scale(${1 + amp * Math.sin(s * 2.4 + fase)})`, ...style }}>{children}</div>;
};

/** Brillo neón que late en un ciclo de 1,5 s. */
export const Brillo: React.FC<{ children: React.ReactNode; color?: string; fuerza?: number }> = ({ children, color = C.menta, fuerza = 1 }) => {
  const s = useSeg();
  const r = (12 + 8 * Math.sin((s * Math.PI * 2) / 1.5)) * fuerza;
  return <div style={{ filter: `drop-shadow(0 0 ${r}px ${color}aa)` }}>{children}</div>;
};

/** Efecto de sonido. `en` en fotogramas locales. */
export const Sfx: React.FC<{ carpeta: string; id: string; en: number; volumen?: number; dur?: number }> = ({ carpeta, id, en, volumen = 0.3, dur }) => (
  <Sequence from={Math.max(0, Math.round(en))} durationInFrames={dur} layout="none">
    <Html5Audio src={staticFile(`${carpeta}/sfx-${id}.mp3`)} volume={volumen} />
  </Sequence>
);

/** Fondo de la marca: noche azul en degradado con burbujas que suben despacio. */
export const Fondo: React.FC = () => {
  const s = useSeg();
  return (
    <AbsoluteFill style={{ background: `radial-gradient(ellipse at 50% 38%, ${C.noche}, ${C.abismo} 78%)` }}>
      {new Array(22).fill(0).map((_, i) => {
        const x = random(`bx${i}`) * 1080;
        const v = 18 + random(`bv${i}`) * 30;
        const y = ((random(`by${i}`) * 2100 - s * v) % 2100 + 2100) % 2100 - 100;
        const r = 12 + random(`br${i}`) * 46;
        return (
          <div
            key={i}
            style={{
              position: "absolute",
              left: x + Math.sin(s * 0.7 + i) * 24,
              top: y,
              width: r,
              height: r,
              borderRadius: r,
              background: i % 3 ? C.menta : C.pelaje,
              opacity: 0.05 + random(`bo${i}`) * 0.05,
            }}
          />
        );
      })}
    </AbsoluteFill>
  );
};

/** Título de escena: etiqueta pequeña en mayúsculas y título en Baloo. */
export const Titulo: React.FC<{ etiqueta: string; titulo: string; color?: string; sinEntrada?: boolean }> = ({ etiqueta, titulo, color = C.menta, sinEntrada }) => {
  const s = usePop(0, 200);
  const e = sinEntrada ? 1 : s;
  return (
    <div style={{ position: "absolute", top: 120, left: 60, right: 60, textAlign: "center", opacity: e, transform: `translateY(${(1 - e) * -24}px)` }}>
      <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 26, letterSpacing: 6, color }}>{etiqueta}</div>
      <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 64, lineHeight: 1.05, color: C.hueso, marginTop: 6, textWrap: "balance" }}>{titulo}</div>
    </div>
  );
};

/** Subtítulos de la marca: caja oscura con borde menta, palabra que suena en blanco, clave subrayada en menta. */
export const Subtitulos: React.FC<{ palabras: Palabra[]; pre: number; claves?: string[] }> = ({ palabras, pre, claves = [] }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const t = (frame - pre) / fps;
  const norm = (w: string) => w.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/[^a-z0-9]/g, "");
  const grupos: Palabra[][] = [];
  let actual: Palabra[] = [];
  palabras.forEach((w) => {
    actual.push(w);
    if (/[,.:;?!]$/.test(w.p) || actual.length >= 5) {
      grupos.push(actual);
      actual = [];
    }
  });
  if (actual.length) grupos.push(actual);
  const i = grupos.findIndex((g, k) => {
    const fin = grupos[k + 1] ? grupos[k + 1][0].ini - 0.02 : g[g.length - 1].fin + 0.5;
    return t >= g[0].ini - 0.02 && t < fin;
  });
  if (i < 0) return null;
  const g = grupos[i];
  const entra = interpolate(t, [g[0].ini - 0.02, g[0].ini + 0.12], [0.9, 1], CLAMP);
  return (
    <div style={{ position: "absolute", top: 318, left: 70, right: 70, display: "flex", justifyContent: "center" }}>
      <div
        style={{
          transform: `scale(${entra})`,
          background: "rgba(2,8,20,0.72)",
          border: `2px solid ${C.menta}55`,
          borderRadius: 18,
          padding: "14px 30px",
          display: "flex",
          flexWrap: "wrap",
          justifyContent: "center",
          gap: "4px 16px",
          fontFamily: F.texto,
          fontSize: 50,
          lineHeight: 1.25,
        }}
      >
        {g.map((w, k) => {
          const dicha = t >= w.ini;
          const esClave = claves.includes(norm(w.p));
          const trazo = interpolate(t, [w.ini, w.ini + 0.18], [0, 1], CLAMP);
          return (
            <span key={k} style={{ position: "relative", display: "inline-block", fontWeight: dicha ? 600 : 300, color: dicha ? C.hueso : "rgba(241,245,255,0.45)", zIndex: 0 }}>
              {esClave ? (
                <span
                  style={{
                    position: "absolute",
                    left: -6,
                    right: -6,
                    top: "18%",
                    bottom: "4%",
                    background: C.menta,
                    borderRadius: "10px 5px 12px 6px",
                    transformOrigin: "left center",
                    transform: `scaleX(${trazo}) rotate(-2.5deg) skewX(-6deg)`,
                    zIndex: -1,
                  }}
                />
              ) : null}
              <span style={{ color: esClave && trazo > 0.5 ? C.abismo : undefined }}>{w.p}</span>
            </span>
          );
        })}
      </div>
    </div>
  );
};

/** Contador de cifras en JetBrains Mono, sobre una píldora oscura. */
export const Contador: React.FC<{ hasta: number; inicio: number; dur?: number; sufijo?: string; color?: string; tamano?: number; decimales?: number }> = ({ hasta, inicio, dur = 0.8, sufijo = "", color = C.menta, tamano = 120, decimales = 0 }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const p = interpolate(frame, [inicio, inicio + dur * fps], [0, 1], { ...CLAMP, easing: (x) => 1 - Math.pow(1 - x, 3) });
  const n = (hasta * p).toLocaleString("es-ES", { minimumFractionDigits: decimales, maximumFractionDigits: decimales });
  return (
    <div style={{ display: "inline-block", fontFamily: F.cifra, fontWeight: 700, fontSize: tamano, color, background: "rgba(2,8,20,0.8)", border: `2px solid ${color}55`, borderRadius: 24, padding: "4px 34px", textShadow: `0 0 28px ${color}99`, fontVariantNumeric: "tabular-nums", whiteSpace: "nowrap" }}>
      {n}
      {sufijo}
    </div>
  );
};

/** Onda expansiva para el remate. */
export const Rafaga: React.FC<{ en: number; color?: string; tamano?: number; x?: number; y?: number }> = ({ en, color = C.menta, tamano = 700, x = 0, y = 0 }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const p = interpolate(frame, [en, en + fps * 0.6], [0, 1], CLAMP);
  if (p <= 0 || p >= 1) return null;
  return (
    <svg width={tamano} height={tamano} viewBox="-100 -100 200 200" style={{ position: "absolute", left: "50%", top: "50%", transform: `translate(calc(-50% + ${x}px), calc(-50% + ${y}px))`, pointerEvents: "none" }}>
      <circle r={20 + 75 * p} fill="none" stroke={color} strokeWidth={5 * (1 - p)} opacity={1 - p} />
      {new Array(12).fill(0).map((_, k) => {
        const a = (k / 12) * Math.PI * 2;
        const r1 = 26 + 64 * p;
        return <circle key={k} cx={Math.cos(a) * r1} cy={Math.sin(a) * r1} r={3.5 * (1 - p)} fill={color} />;
      })}
    </svg>
  );
};

/** Plano con zoom lento (1,00 → 1,06) y golpes de zoom (+8 %) en las palabras clave. */
export const Plano: React.FC<{ dur: number; golpes?: number[]; children: React.ReactNode; style?: React.CSSProperties }> = ({ dur, golpes = [], children, style }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const lento = interpolate(frame, [0, dur], [1, 1.06], CLAMP);
  let golpe = 0;
  for (const g of golpes) {
    const d = (frame - g) / fps;
    if (d >= 0 && d < 0.9) golpe = Math.max(golpe, d < 0.2 ? 0.08 * (1 - Math.pow(1 - d / 0.2, 3)) : 0.08 * (1 - (d - 0.2) / 0.7));
  }
  return <div style={{ position: "absolute", inset: 0, transform: `scale(${lento + golpe})`, transformOrigin: "50% 42%", ...style }}>{children}</div>;
};
