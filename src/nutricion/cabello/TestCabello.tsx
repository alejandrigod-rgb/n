/**
 * Cliente "Alimentación y Equilibrio de Giovana Olivas" (Perú): el test de cabello, rediseñado (15 de noviembre de 2026).
 * El usuario pidió rehacer el video de la clienta SIN la chica y SIN Nyxar, inmersivo, con su voz original y su logo.
 * Animación propia en los colores del logo: un viaje continuo en el que la cámara atraviesa cada escena para entrar en la siguiente.
 * La voz es el audio original (public/nutricion-cabello/voz-original.wav); los tiempos de cada palabra salen de Whisper.
 */
import "@fontsource/baloo-2/800.css";
import "@fontsource/lexend/400.css";
import "@fontsource/lexend/600.css";
import React from "react";
import { AbsoluteFill, Html5Audio, interpolate, random, Sequence, spring, staticFile, useCurrentFrame } from "remotion";
import { Brocoli, Fresa, L, Limon, LogoAyE, Manzana, Palta, Zanahoria } from "../Flyer";

const FPS = 60;
export const DURACION_CABELLO = Math.round(34.2 * FPS);
const CL = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;
const TIT = "'Baloo 2', sans-serif";
const LEX = "'Lexend', sans-serif";
const OSC = "#16404a";
const src = (f: string) => staticFile(`nutricion-cabello/${f}`);

/* ---------- la voz: palabras con su inicio (s), de Whisper, con la escritura corregida ---------- */
const PALABRAS: [string, number][] = [
  ["¿Sabías", 0.09], ["que", 0.44], ["con", 0.6], ["5", 0.78], ["pelos", 1.08], ["de", 1.38], ["tu", 1.5], ["cabeza", 1.62],
  ["podemos", 2.06], ["descubrir", 2.41], ["el", 2.94], ["estado", 3.03], ["de", 3.3], ["tu", 3.39], ["salud?", 3.48],
  ["Hola,", 3.88], ["soy", 4.22], ["Giovana", 4.43], ["Olivas", 4.62], ["y", 5.0], ["quiero", 5.06], ["contarte", 5.45],
  ["lo", 6.0], ["último", 6.11], ["de", 6.53], ["nutrición", 6.61], ["en", 7.15], ["el", 7.26], ["Perú.", 7.37],
  ["Este", 7.86], ["test", 8.09], ["evalúa", 8.58], ["la", 9.02], ["sensibilidad", 9.15], ["alimentaria,", 9.97],
  ["nos", 10.96], ["describe", 11.23], ["el", 12.05], ["estado", 12.06], ["de", 12.32], ["salud,", 12.42],
  ["tanto", 13.23], ["en", 13.5], ["factores", 13.58], ["ambientales", 14.0], ["que", 15.03], ["influyen", 15.22], ["en", 15.83], ["él:", 16.06],
  ["vitaminas,", 16.36], ["minerales,", 17.21], ["aminoácidos,", 18.04],
  ["alimentos", 19.14], ["que", 19.84], ["pueden", 20.03], ["ayudar", 20.56], ["a", 21.01], ["optimizar", 21.11], ["tu", 21.75], ["cuerpo.", 21.92],
  ["Igualmente,", 22.62], ["si", 23.08], ["se", 23.21], ["encuentran", 23.28], ["presentes", 23.77], ["microorganismos", 24.21], ["patógenos", 25.0],
  ["como", 25.73], ["virus", 25.86], ["o", 26.19], ["bacterias.", 26.3],
  ["Si", 26.67], ["quieres", 26.75], ["mayor", 27.14], ["información,", 27.43], ["escribe", 28.29], ["a", 28.62], ["los", 28.66], ["números", 28.88],
  ["que", 29.3], ["salen", 29.45], ["en", 29.7], ["la", 29.83], ["descripción.", 29.9],
];
const norm = (w: string) => w.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/[^a-z0-9]/g, "");
/** Segundo en que se dice una palabra (n-ésima aparición). */
const T = (w: string, n = 0) => {
  let c = 0;
  for (const [p, t] of PALABRAS) if (norm(p) === norm(w)) { if (c === n) return t; c++; }
  throw new Error(`Falta "${w}"`);
};
const CLAVES = new Set(["5", "pelos", "salud", "giovana", "olivas", "nutricion", "peru", "test", "sensibilidad", "alimentaria", "ambientales", "vitaminas", "minerales", "aminoacidos", "alimentos", "optimizar", "microorganismos", "patogenos", "virus", "bacterias", "informacion", "numeros", "descripcion"]);

/* ---------- escenas: cada una entra desde lejos y sale atravesándola (la cámara «entra» por su punto focal) ---------- */
type Escena = { ini: number; fin: number; foco: [number, number] };
const E = {
  gancho: { ini: 0, fin: 3.82, foco: [540, 760] },
  logo: { ini: 3.82, fin: 7.8, foco: [540, 820] },
  test: { ini: 7.8, fin: 10.9, foco: [540, 820] },
  salud: { ini: 10.9, fin: 16.3, foco: [540, 760] },
  nutrientes: { ini: 16.3, fin: 19.08, foco: [540, 800] },
  alimentos: { ini: 19.08, fin: 22.55, foco: [540, 820] },
  microbios: { ini: 22.55, fin: 26.6, foco: [540, 780] },
  contacto: { ini: 26.6, fin: 31.0, foco: [540, 820] },
  cierre: { ini: 31.0, fin: 34.3, foco: [540, 800] },
} satisfies Record<string, Escena>;

const Viaje: React.FC<{ e: Escena; t: number; children: (local: number) => React.ReactNode }> = ({ e, t, children }) => {
  if (t < e.ini - 0.25 || t > e.fin + 0.3) return null;
  const entra = e.ini === 0 ? 1 : interpolate(t, [e.ini - 0.25, e.ini + 0.3], [0, 1], { ...CL, easing: (x) => 1 - (1 - x) ** 3 });
  const sale = e.fin > 34 ? 0 : interpolate(t, [e.fin - 0.12, e.fin + 0.3], [0, 1], { ...CL, easing: (x) => x * x });
  const esc = (0.45 + 0.55 * entra) * (1 + sale * 2.6) * (1 + (t - e.ini) * 0.012);
  const op = Math.min(entra * 1.6, 1) * (1 - sale);
  return (
    <AbsoluteFill style={{ opacity: op, transform: `scale(${esc})`, transformOrigin: `${e.foco[0]}px ${e.foco[1]}px`, filter: sale > 0.2 ? `blur(${(sale - 0.2) * 10}px)` : undefined }}>
      {children(t - e.ini)}
    </AbsoluteFill>
  );
};

/** Aparición con muelle cuando llega el segundo `desde`. */
const pop = (t: number, desde: number, d = 12) => (t < desde ? 0 : spring({ frame: (t - desde) * FPS, fps: FPS, config: { damping: d, mass: 0.6 } }));

/* ---------- fondo vivo: degradado claro, manchas de color con profundidad y partículas que vienen hacia la cámara ---------- */
const Fondo: React.FC<{ t: number }> = ({ t }) => {
  // en cada cambio de escena las partículas se aceleran (sensación de viaje)
  const cortes = Object.values(E).map((e) => e.fin);
  let empuje = 0;
  for (const c of cortes) empuje = Math.max(empuje, Math.exp(-((t - c) ** 2) / 0.04));
  return (
    <AbsoluteFill style={{ background: "linear-gradient(170deg, #f2fbfd 0%, #eaf7f3 55%, #f3f9e8 100%)", overflow: "hidden" }}>
      {[
        [180, 300, 420, L.azul],
        [900, 620, 380, L.verde],
        [300, 1500, 460, L.verde],
        [880, 1600, 360, L.azul],
      ].map(([x, y, r, c], k) => (
        <div key={k} style={{ position: "absolute", left: (x as number) - (r as number) + Math.sin(t * 0.4 + k) * 40, top: (y as number) - (r as number) + Math.cos(t * 0.3 + k) * 40, width: (r as number) * 2, height: (r as number) * 2, borderRadius: "50%", background: c as string, opacity: 0.13, filter: "blur(60px)" }} />
      ))}
      {Array.from({ length: 9 }, (_, i) => {
        const x = random(`hx${i}`) * 1080 + Math.sin(t * 0.5 + i) * 30;
        const y = ((random(`hy${i}`) * 2100 - t * (18 + random(`hv${i}`) * 20)) % 2100 + 2100) % 2100 - 100;
        return (
          <div key={`h${i}`} style={{ position: "absolute", left: x, top: y, opacity: 0.16, transform: `rotate(${t * 20 + i * 40}deg)` }}>
            {i % 3 === 2 ? <Molecula tam={110} color={L.azul} /> : <Hoja tam={70 + (i % 3) * 20} color={i % 2 ? L.verde : L.azul} />}
          </div>
        );
      })}
      {Array.from({ length: 46 }, (_, i) => {
        const fase = (random(`z${i}`) + t * (0.08 + empuje * 0.9) + random(`v${i}`) * t * 0.05) % 1;
        const ang = random(`a${i}`) * Math.PI * 2;
        const d = 60 + fase ** 2 * 1100;
        const x = 540 + Math.cos(ang) * d,
          y = 900 + Math.sin(ang) * d * 1.3;
        const r = 3 + fase * 14;
        return <div key={i} style={{ position: "absolute", left: x, top: y, width: r, height: r * (1 + empuje * 4), borderRadius: r, background: i % 2 ? L.azul : L.verde, opacity: 0.12 + fase * 0.35, transform: `rotate(${(ang * 180) / Math.PI + 90}deg)` }} />;
      })}
    </AbsoluteFill>
  );
};

/* ---------- piezas dibujadas (con luz y sombra para que tengan volumen) ---------- */
const Esfera: React.FC<{ r: number; c1: string; c2: string; children?: React.ReactNode }> = ({ r, c1, c2, children }) => (
  <div style={{ width: r * 2, height: r * 2, borderRadius: "50%", background: `radial-gradient(circle at 35% 30%, #ffffffcc 0%, ${c1} 28%, ${c2} 100%)`, boxShadow: `0 ${r * 0.25}px ${r * 0.5}px ${c2}55, inset -${r * 0.12}px -${r * 0.16}px ${r * 0.3}px #00000022`, display: "flex", alignItems: "center", justifyContent: "center", position: "relative" }}>
    {children}
  </div>
);

const Etiqueta: React.FC<{ texto: string; color?: string; tam?: number }> = ({ texto, color = L.azul, tam = 44 }) => (
  <div style={{ fontFamily: TIT, fontWeight: 800, fontSize: tam, color: "#fff", background: color, padding: "8px 26px 2px", borderRadius: 999, whiteSpace: "nowrap", boxShadow: `0 10px 26px ${color}55` }}>{texto}</div>
);

/** Un pelo: curva castaña con brillo. */
const Pelo: React.FC<{ d: string; ancho?: number }> = ({ d, ancho = 10 }) => (
  <g>
    <path d={d} fill="none" stroke="#4a2d1e" strokeWidth={ancho} strokeLinecap="round" />
    <path d={d} fill="none" stroke="#a0704d" strokeWidth={ancho * 0.3} strokeLinecap="round" opacity={0.7} transform="translate(-2 -2)" />
  </g>
);

/** Corazón con latido (estado de salud). */
const Corazon: React.FC<{ t: number; tam?: number }> = ({ t, tam = 160 }) => {
  const lat = 1 + 0.08 * Math.max(0, Math.sin(t * 7)) ** 6;
  return (
    <svg width={tam} height={tam} viewBox="0 0 100 100" style={{ transform: `scale(${lat})`, overflow: "visible" }}>
      <path d="M50 88 C20 66 8 50 10 32 C12 16 32 8 50 26 C68 8 88 16 90 32 C92 50 80 66 50 88 Z" fill="#e8546a" />
      <path d="M22 32 C24 24 30 20 36 20" stroke="#fff" strokeWidth={6} fill="none" strokeLinecap="round" opacity={0.6} />
      <path d="M18 50 H36 L42 38 L50 62 L56 46 H82" stroke="#fff" strokeWidth={5} fill="none" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
};

/** Hoja suave (decoración). */
const Hoja: React.FC<{ tam: number; color: string }> = ({ tam, color }) => (
  <svg width={tam} height={tam} viewBox="0 0 100 100">
    <path d="M50 6 C80 22 88 60 50 94 C12 60 20 22 50 6 Z" fill={color} />
    <path d="M50 14 V88 M50 40 L34 30 M50 56 L66 44 M50 70 L36 62" stroke="#ffffff88" strokeWidth={3} fill="none" strokeLinecap="round" />
  </svg>
);
/** Molécula de hexágonos (decoración). */
const Molecula: React.FC<{ tam: number; color: string }> = ({ tam, color }) => (
  <svg width={tam} height={tam} viewBox="0 0 120 100">
    {[[30, 30], [62, 48], [30, 66], [94, 30]].map(([x, y], k) => (
      <polygon key={k} points={Array.from({ length: 6 }, (_, i) => `${x + Math.cos((i * Math.PI) / 3) * 16},${y + Math.sin((i * Math.PI) / 3) * 16}`).join(" ")} fill="none" stroke={color} strokeWidth={4} />
    ))}
  </svg>
);
/** Cápsula de dos colores. */
const Capsula: React.FC<{ c1: string; c2: string; tam?: number }> = ({ c1, c2, tam = 70 }) => (
  <svg width={tam} height={tam * 0.45} viewBox="0 0 100 44">
    <rect x={2} y={2} width={96} height={40} rx={20} fill={c2} />
    <path d="M22 2 H50 V42 H22 A20 20 0 0 1 22 2 Z" fill={c1} />
    <rect x={12} y={8} width={30} height={7} rx={3.5} fill="#ffffff88" />
  </svg>
);
/** Destellos alrededor de un punto. */
const Destellos: React.FC<{ t: number; desde: number; x: number; y: number; color?: string }> = ({ t, desde, x, y, color = L.verde }) => {
  if (t < desde || t > desde + 1.2) return null;
  const p = (t - desde) / 1.2;
  return (
    <>
      {Array.from({ length: 10 }, (_, k) => {
        const a = (k / 10) * Math.PI * 2;
        const d = 60 + p * 220;
        return <div key={k} style={{ position: "absolute", left: x + Math.cos(a) * d - 8, top: y + Math.sin(a) * d - 8, width: 16, height: 16, borderRadius: 8, background: k % 2 ? color : "#ffd84a", opacity: 1 - p }} />;
      })}
    </>
  );
};
/** Cajita de texto pequeña bajo un icono. */
const Rotulo: React.FC<{ texto: string }> = ({ texto }) => (
  <div style={{ fontFamily: LEX, fontWeight: 600, fontSize: 26, color: OSC, background: "#ffffffdd", padding: "4px 14px", borderRadius: 999, whiteSpace: "nowrap", boxShadow: "0 4px 12px #00000012" }}>{texto}</div>
);

/* =================== ESCENAS =================== */

/** 1 · Cinco pelos y la cámara entra en uno hasta ver su ADN. */
const Gancho: React.FC<{ t: number }> = ({ t }) => {
  const dentro = interpolate(t, [T("podemos"), T("estado")], [0, 1], { ...CL, easing: (x) => x * x * (3 - 2 * x) });
  const pelos = [
    "M180 980 C260 820 300 700 260 560",
    "M330 1000 C360 860 420 760 420 600",
    "M500 1010 C520 860 560 720 540 560",
    "M680 1000 C660 860 640 740 700 600",
    "M840 980 C800 840 760 720 820 580",
  ];
  return (
    <AbsoluteFill>
      {/* título desde el fotograma 0 */}
      <div style={{ position: "absolute", top: 220, left: 0, right: 0, display: "flex", flexDirection: "column", alignItems: "center", opacity: 1 - dentro }}>
        <div style={{ fontFamily: TIT, fontWeight: 800, fontSize: 150, color: OSC, lineHeight: 0.95 }}>
          <span style={{ color: L.azul }}>5</span> PELOS
        </div>
        <div style={{ fontFamily: TIT, fontWeight: 800, fontSize: 92, color: L.verdeOsc, lineHeight: 1 }}>= TU SALUD</div>
      </div>
      {/* los cinco pelos, que se van contando */}
      <AbsoluteFill style={{ transform: `scale(${1 + dentro * 6})`, transformOrigin: "540px 760px", opacity: 1 - dentro * 0.9 }}>
        <svg width={1080} height={1920} style={{ position: "absolute" }}>
          {pelos.map((d, k) => {
            const p = interpolate(t, [0.1 + k * 0.12, 0.5 + k * 0.12], [0, 1], CL);
            return (
              <g key={k} style={{ opacity: p }} transform={`translate(0 ${(1 - p) * 60}) rotate(${Math.sin(t * 2 + k) * 2} 540 1000)`}>
                <Pelo d={d} />
              </g>
            );
          })}
        </svg>
        <div style={{ position: "absolute", left: 600 + Math.sin(t * 1.6) * 160, top: 560 + Math.cos(t * 1.3) * 60, opacity: interpolate(t, [0.6, 0.9], [0, 0.9], CL) }}>
          <svg width={210} height={210} viewBox="0 0 100 100">
            <circle cx={40} cy={40} r={28} fill="#ffffff55" stroke={OSC} strokeWidth={6} />
            <path d="M60 60 L90 90" stroke={OSC} strokeWidth={10} strokeLinecap="round" />
            <path d="M26 30 Q30 22 40 20" stroke="#fff" strokeWidth={4} fill="none" strokeLinecap="round" />
          </svg>
        </div>
        {pelos.map((_, k) => {
          const e = pop(t, T("5") + k * 0.07);
          return (
            <div key={k} style={{ position: "absolute", left: [180, 330, 500, 680, 840][k] - 34, top: 1030, transform: `scale(${e})` }}>
              <Esfera r={34} c1={L.azul} c2="#1f7f9b">
                <span style={{ fontFamily: TIT, fontWeight: 800, fontSize: 40, color: "#fff", marginTop: 6 }}>{k + 1}</span>
              </Esfera>
            </div>
          );
        })}
      </AbsoluteFill>
      {/* dentro del pelo: la doble hélice y el estado de salud */}
      {dentro > 0.05 ? (
        <AbsoluteFill style={{ opacity: dentro }}>
          <AbsoluteFill style={{ background: "radial-gradient(circle at 50% 42%, #e8f8fb 0%, #c9ecf4 60%, #a9dce9 100%)" }} />
          <svg width={1080} height={1920} style={{ position: "absolute" }}>
            {Array.from({ length: 26 }, (_, i) => {
              const y = 260 + i * 40;
              const fase = i * 0.5 + t * 3;
              const x1 = 540 + Math.sin(fase) * 170,
                x2 = 540 - Math.sin(fase) * 170;
              const delante = Math.cos(fase) > 0;
              return (
                <g key={i} opacity={0.4 + 0.6 * Math.abs(Math.cos(fase))}>
                  <line x1={x1} y1={y} x2={x2} y2={y} stroke={i % 2 ? L.verde : L.azul} strokeWidth={8} strokeLinecap="round" />
                  <circle cx={x1} cy={y} r={delante ? 16 : 11} fill={L.azul} />
                  <circle cx={x2} cy={y} r={delante ? 11 : 16} fill={L.verdeOsc} />
                </g>
              );
            })}
          </svg>
          {Array.from({ length: 8 }, (_, k) => (
            <div key={k} style={{ position: "absolute", left: (k % 2 ? 820 : 120) + Math.sin(t + k) * 30, top: 300 + k * 140 + Math.cos(t * 1.2 + k) * 20, width: 70 + (k % 3) * 20, height: 70 + (k % 3) * 20, borderRadius: "50%", background: `radial-gradient(circle at 35% 30%, #ffffff, ${k % 2 ? L.verde : L.azul}66)`, opacity: 0.6 }} />
          ))}
          <div style={{ position: "absolute", left: 540, top: 760, transform: `translate(-50%,-50%) scale(${pop(t, T("salud?") - 0.1)})` }}>
            <Corazon t={t} tam={220} />
          </div>
        </AbsoluteFill>
      ) : null}
    </AbsoluteFill>
  );
};

/** 2 · El logo, "lo último en nutrición" y el sello de Perú. */
const Logo: React.FC<{ t: number }> = ({ t }) => {
  const g = T("hola") - E.logo.ini;
  return (
    <AbsoluteFill>
      {[0, 1, 2].map((k) => {
        const p = ((t * 0.7 + k / 3) % 1) ** 0.8;
        return <div key={k} style={{ position: "absolute", left: 540 - 200 - p * 360, top: 760 - 200 - p * 360, width: 400 + p * 720, height: 400 + p * 720, borderRadius: "50%", border: `6px solid ${k % 2 ? L.verde : L.azul}`, opacity: (1 - p) * 0.35 }} />;
      })}
      {[Manzana, Palta, Brocoli, Limon, Fresa, Zanahoria].map((C, k) => {
        const a = t * 0.5 + (k / 6) * Math.PI * 2;
        return (
          <div key={k} style={{ position: "absolute", left: 540 + Math.cos(a) * 420 - 45, top: 720 + Math.sin(a) * 300 - 45, opacity: 0.85 * pop(t, g + 0.2 + k * 0.08), transform: `scale(${0.7 + 0.3 * (Math.sin(a) + 1) / 2})` }}>
            <C t={90} />
          </div>
        );
      })}
      <div style={{ position: "absolute", left: 540, top: 720, transform: `translate(-50%,-50%) scale(${0.85 * pop(t, g) + 0.02 * Math.sin(t * 2)})` }}>
        <LogoAyE escala={0.95} />
      </div>
      <div style={{ position: "absolute", left: 0, right: 0, top: 1080, display: "flex", justifyContent: "center", gap: 20, transform: `scale(${pop(t, T("ultimo") - E.logo.ini)})` }}>
        <Etiqueta texto="LO ÚLTIMO EN NUTRICIÓN" color={L.verdeOsc} tam={46} />
      </div>
      <div style={{ position: "absolute", left: 0, right: 0, top: 1180, display: "flex", justifyContent: "center", transform: `scale(${pop(t, T("peru") - E.logo.ini)})` }}>
        <div style={{ display: "flex", alignItems: "center", gap: 16, background: "#fff", borderRadius: 999, padding: "10px 28px", boxShadow: "0 10px 30px #00000018" }}>
          <div style={{ display: "flex", width: 72, height: 48, borderRadius: 8, overflow: "hidden", border: "2px solid #ddd" }}>
            <div style={{ flex: 1, background: "#D91023" }} />
            <div style={{ flex: 1, background: "#fff" }} />
            <div style={{ flex: 1, background: "#D91023" }} />
          </div>
          <span style={{ fontFamily: TIT, fontWeight: 800, fontSize: 48, color: OSC, marginTop: 6 }}>PERÚ</span>
        </div>
      </div>
    </AbsoluteFill>
  );
};

/** Alimentos con sensibilidad: pan, leche y huevo (dibujados). */
const Pan: React.FC<{ t: number }> = ({ t }) => (
  <svg width={t} height={t} viewBox="0 0 100 100">
    <path d="M14 46 C14 26 30 18 50 18 C70 18 86 26 86 46 C86 54 80 56 78 56 L78 86 L22 86 L22 56 C20 56 14 54 14 46 Z" fill="#e3a65a" />
    <path d="M26 56 L26 80 L74 80 L74 56 C80 54 82 50 82 46 C82 30 68 24 50 24 C32 24 18 30 18 46 C18 50 20 54 26 56 Z" fill="#f8dcac" />
  </svg>
);
const Leche: React.FC<{ t: number }> = ({ t }) => (
  <svg width={t} height={t} viewBox="0 0 100 100">
    <path d="M30 10 H70 L74 24 L80 34 V92 H20 V34 L26 24 Z" fill="#f4f8fb" stroke="#bcd3e1" strokeWidth={4} />
    <rect x={20} y={46} width={60} height={28} fill={L.azul} />
    <path d="M40 58 h20" stroke="#fff" strokeWidth={5} strokeLinecap="round" />
  </svg>
);
const Huevo: React.FC<{ t: number }> = ({ t }) => (
  <svg width={t} height={t} viewBox="0 0 100 100">
    <ellipse cx={50} cy={56} rx={30} ry={38} fill="#fbf1e2" stroke="#e6d3b5" strokeWidth={4} />
    <ellipse cx={40} cy={40} rx={7} ry={11} fill="#fff" opacity={0.8} />
  </svg>
);

/** 3 · El tubo de ensayo con el pelo y la sensibilidad alimentaria. */
const Test: React.FC<{ t: number }> = ({ t }) => {
  const s0 = E.test.ini;
  const sens = T("sensibilidad") - s0;
  const comidas = [
    { C: Pan, nivel: 0.82, color: "#e8546a" },
    { C: Leche, nivel: 0.55, color: "#f2a33a" },
    { C: Huevo, nivel: 0.25, color: L.verde },
  ];
  return (
    <AbsoluteFill>
      {/* tubo de ensayo */}
      <div style={{ position: "absolute", left: 160, top: 360, transform: `rotate(${-8 + Math.sin(t * 2) * 2}deg)` }}>
        <svg width={220} height={640} viewBox="0 0 220 640" style={{ overflow: "visible" }}>
          <rect x={40} y={0} width={140} height={34} rx={10} fill="#cfdfe6" />
          <path d="M54 30 V540 A56 56 0 0 0 166 540 V30" fill="#ffffffaa" stroke="#9fc4d2" strokeWidth={8} />
          <path d="M60 250 V540 A50 50 0 0 0 160 540 V250 Z" fill={L.azul} opacity={0.75} />
          <path d="M60 250 Q110 238 160 250" fill="none" stroke="#bdeaf5" strokeWidth={6} />
          {Array.from({ length: 8 }, (_, i) => {
            const y = 560 - ((t * 120 + i * 50) % 300);
            return <circle key={i} cx={80 + (i * 23) % 60} cy={y} r={5 + (i % 3) * 3} fill="#e6f8fc" opacity={0.85} />;
          })}
          <path d="M110 120 C80 220 140 320 100 440" fill="none" stroke="#4a2d1e" strokeWidth={7} strokeLinecap="round" />
          <path d="M74 60 V500" stroke="#fff" strokeWidth={10} strokeLinecap="round" opacity={0.6} />
        </svg>
      </div>
      <svg width={1080} height={1920} style={{ position: "absolute" }}>
        {/* pipeta que gotea en el tubo */}
        <g transform={`translate(${290 + Math.sin(t * 2) * 6} 180)`}>
          <rect x={-14} y={0} width={28} height={120} rx={10} fill="#cfdfe6" />
          <path d="M-10 120 L10 120 L2 170 L-2 170 Z" fill="#e6f1f5" stroke="#9fc4d2" strokeWidth={3} />
          <circle cx={0} cy={180 + ((t * 300) % 200)} r={8} fill={L.azul} opacity={0.8} />
        </g>
        {/* gradilla con tres tubos pequeños */}
        <g transform="translate(120 1080)">
          <rect x={0} y={60} width={300} height={22} rx={8} fill="#c8a57a" />
          {[0, 1, 2].map((k) => (
            <g key={k} transform={`translate(${30 + k * 90} 0)`}>
              <path d="M10 0 V110 A20 20 0 0 0 50 110 V0" fill="#ffffffcc" stroke="#9fc4d2" strokeWidth={5} />
              <path d={`M14 ${60 - k * 10} V110 A16 16 0 0 0 46 110 V${60 - k * 10} Z`} fill={[L.verde, "#f2a33a", "#e8546a"][k]} opacity={0.8} />
            </g>
          ))}
          <rect x={0} y={130} width={300} height={22} rx={8} fill="#b38e62" />
        </g>
      </svg>
      <div style={{ position: "absolute", left: 120, top: 290, transform: `scale(${pop(t, T("test") - s0)})` }}>
        <Etiqueta texto="TEST DE CABELLO" />
      </div>
      {/* tarjeta de sensibilidad */}
      <div style={{ position: "absolute", left: 440, top: 470, width: 540, background: "#fff", borderRadius: 40, padding: "36px 34px", boxShadow: "0 30px 60px #16404a22", transform: `scale(${pop(t, sens - 0.2)}) rotate(2deg)` }}>
        <div style={{ fontFamily: LEX, fontWeight: 600, fontSize: 34, color: OSC, marginBottom: 20 }}>Sensibilidad alimentaria</div>
        {comidas.map(({ C, nivel, color }, k) => {
          const p = interpolate(t, [sens + k * 0.25, sens + 0.8 + k * 0.25], [0, nivel], CL);
          return (
            <div key={k} style={{ display: "flex", alignItems: "center", gap: 18, marginBottom: 18 }}>
              <C t={90} />
              <div style={{ flex: 1, height: 26, borderRadius: 13, background: "#edf3f4", overflow: "hidden" }}>
                <div style={{ width: `${p * 100}%`, height: "100%", borderRadius: 13, background: color }} />
              </div>
            </div>
          );
        })}
        <svg width={470} height={90} viewBox="0 0 470 90" style={{ marginTop: 6 }}>
          <path d={`M0 70 ${Array.from({ length: 12 }, (_, i) => `L${i * 42} ${70 - (Math.sin(i * 1.3) + 1) * 22 * interpolate(t, [sens, sens + 1.2], [0, 1], CL)}`).join(" ")}`} fill="none" stroke={L.azul} strokeWidth={5} strokeLinejoin="round" />
          <path d="M0 86 H470" stroke="#e1ebee" strokeWidth={3} />
        </svg>
      </div>
    </AbsoluteFill>
  );
};

/** Iconos de factores ambientales. */
const IcoAmbiente: React.FC<{ tipo: "sol" | "aire" | "humo" | "sueno" | "estres"; t: number }> = ({ tipo, t }) => (
  <Esfera r={70} c1={tipo === "humo" || tipo === "estres" ? "#f2a33a" : tipo === "sueno" ? "#7f8fd6" : L.verde} c2={tipo === "humo" || tipo === "estres" ? "#c76d1c" : tipo === "sueno" ? "#4f5ea8" : L.verdeOsc}>
    <svg width={90} height={90} viewBox="0 0 100 100">
      {tipo === "sol" ? (
        <g transform={`rotate(${t * 30} 50 50)`}>
          <circle cx={50} cy={50} r={18} fill="#fff" />
          {Array.from({ length: 8 }, (_, k) => (
            <path key={k} d="M50 14 V24" stroke="#fff" strokeWidth={7} strokeLinecap="round" transform={`rotate(${k * 45} 50 50)`} />
          ))}
        </g>
      ) : tipo === "aire" ? (
        <path d={`M14 40 H62 A12 12 0 1 0 50 28 M14 58 H76 A12 12 0 1 1 64 70 M14 76 H44`} fill="none" stroke="#fff" strokeWidth={7} strokeLinecap="round" transform={`translate(${Math.sin(t * 3) * 4} 0)`} />
      ) : tipo === "humo" ? (
        <g>
          <path d="M16 86 V50 L36 60 V50 L56 60 V30 H72 V86 Z" fill="#fff" />
          <circle cx={64} cy={20 - ((t * 20) % 12)} r={9} fill="#fff" opacity={0.7} />
        </g>
      ) : tipo === "sueno" ? (
        <path d="M62 16 A34 34 0 1 0 84 66 A28 28 0 0 1 62 16 Z" fill="#fff" />
      ) : (
        <path d="M56 10 L26 56 H48 L40 90 L74 40 H52 Z" fill="#fff" />
      )}
    </svg>
  </Esfera>
);

/** 4 · Silueta escaneada y factores ambientales alrededor. */
const Salud: React.FC<{ t: number }> = ({ t }) => {
  const s0 = E.salud.ini;
  const scan = 380 + ((t * 0.45) % 1) * 760;
  const amb = T("ambientales") - s0;
  const iconos: { tipo: "sol" | "aire" | "humo" | "sueno" | "estres"; x: number; y: number }[] = [
    { tipo: "sol", x: 150, y: 420 },
    { tipo: "aire", x: 930, y: 460 },
    { tipo: "humo", x: 140, y: 860 },
    { tipo: "sueno", x: 940, y: 880 },
    { tipo: "estres", x: 540, y: 1170 },
  ];
  return (
    <AbsoluteFill>
      {/* silueta neutra (sin rasgos de persona real) */}
      <svg width={1080} height={1920} style={{ position: "absolute" }}>
        <defs>
          <linearGradient id="cuerpo" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0" stopColor="#bfe9f3" />
            <stop offset="1" stopColor="#7cc9dc" />
          </linearGradient>
          <clipPath id="cuerpoClip">
            <circle cx={540} cy={450} r={80} />
            <path d="M420 560 Q540 520 660 560 L700 900 L620 910 L610 1130 L470 1130 L460 910 L380 900 Z" />
          </clipPath>
        </defs>
        <g clipPath="url(#cuerpoClip)">
          <rect x={300} y={300} width={480} height={900} fill="url(#cuerpo)" />
          <rect x={300} y={scan - 30} width={480} height={30} fill="#ffffff" opacity={0.7} />
          {Array.from({ length: 18 }, (_, i) => (
            <path key={i} d={`M300 ${360 + i * 46} H780`} stroke="#ffffff" strokeOpacity={0.25} strokeWidth={2} />
          ))}
        </g>
        <line x1={360} y1={scan} x2={720} y2={scan} stroke={L.verde} strokeWidth={5} />
        {iconos.map((ic, k) => {
          const p = interpolate(t, [amb + k * 0.15, amb + 0.5 + k * 0.15], [0, 1], CL);
          return <line key={k} x1={540} y1={700} x2={540 + (ic.x - 540) * p} y2={700 + (ic.y - 700) * p} stroke={L.azul} strokeWidth={4} strokeDasharray="10 12" strokeDashoffset={-t * 60} opacity={0.6} />;
        })}
      </svg>
      <div style={{ position: "absolute", left: 540, top: 700, transform: "translate(-50%,-50%)" }}>
        <Corazon t={t} tam={110} />
      </div>
      {[0, 1].map((k) => {
        const p = (t * 0.8 + k * 0.5) % 1;
        return <div key={k} style={{ position: "absolute", left: 540 - 60 - p * 120, top: 700 - 60 - p * 120, width: 120 + p * 240, height: 120 + p * 240, borderRadius: "50%", border: "4px solid #e8546a", opacity: (1 - p) * 0.5 }} />;
      })}
      {iconos.map((ic, k) => (
        <div key={k} style={{ position: "absolute", left: ic.x - 70, top: ic.y - 70 + Math.sin(t * 2 + k) * 10, transform: `scale(${pop(t, amb + k * 0.15)})`, display: "flex", flexDirection: "column", alignItems: "center", gap: 8, width: 140 }}>
          <IcoAmbiente tipo={ic.tipo} t={t} />
          <Rotulo texto={{ sol: "Sol", aire: "Aire", humo: "Contaminación", sueno: "Sueño", estres: "Estrés" }[ic.tipo]} />
        </div>
      ))}
      <svg width={1080} height={160} viewBox="0 0 1080 160" style={{ position: "absolute", left: 0, top: 1215, opacity: 0.35 }}>
        <path d={`M0 80 ${Array.from({ length: 28 }, (_, i) => { const x = i * 40 - ((t * 160) % 40); const pico = i % 7 === 3; return `L${x} ${pico ? 20 : i % 7 === 4 ? 130 : 80}`; }).join(" ")}`} fill="none" stroke="#e8546a" strokeWidth={5} strokeLinejoin="round" />
      </svg>
      <div style={{ position: "absolute", left: 0, right: 0, top: 240, display: "flex", justifyContent: "center", transform: `scale(${pop(t, T("estado", 1) - s0 - 0.2)})` }}>
        <Etiqueta texto="ESTADO DE SALUD" color={L.verdeOsc} tam={54} />
      </div>
    </AbsoluteFill>
  );
};

/** 5 · Tres esferas: vitaminas, minerales y aminoácidos. */
const Nutrientes: React.FC<{ t: number }> = ({ t }) => {
  const s0 = E.nutrientes.ini;
  const capsulas = Array.from({ length: 7 }, (_, k) => (
    <div key={`c${k}`} style={{ position: "absolute", left: [80, 860, 120, 900, 760, 180, 920][k] + Math.sin(t * 1.5 + k) * 20, top: [360, 300, 900, 640, 1180, 1260, 1000][k] + Math.cos(t + k) * 20, transform: `rotate(${t * 40 + k * 50}deg)`, opacity: 0.85 * pop(t, 0.1 + k * 0.08) }}>
      <Capsula c1={[L.azul, L.verde, "#f2a33a"][k % 3]} c2="#ffffff" tam={90} />
    </div>
  ));
  const items = [
    { w: "vitaminas", txt: "VITAMINAS", c1: "#ffbf47", c2: "#e08a12", y: 430, letras: ["A", "B", "C", "D"] },
    { w: "minerales", txt: "MINERALES", c1: L.azul, c2: "#1f7f9b", y: 760, letras: ["Fe", "Zn", "Mg", "Ca"] },
    { w: "aminoacidos", txt: "AMINOÁCIDOS", c1: L.verde, c2: L.verdeOsc, y: 1090, letras: [] },
  ];
  return (
    <AbsoluteFill>
      {capsulas}
      {items.map((it, k) => {
        const e = pop(t, T(it.w) - s0 - 0.1, 10);
        const x = k === 1 ? 640 : 440;
        return (
          <div key={it.w} style={{ position: "absolute", left: x - 150, top: it.y - 150 + Math.sin(t * 1.8 + k) * 12, transform: `scale(${e})` }}>
            <Esfera r={150} c1={it.c1} c2={it.c2}>
              <span style={{ fontFamily: TIT, fontWeight: 800, fontSize: it.txt.length > 9 ? 44 : 52, color: "#fff", marginTop: 8, textShadow: "0 3px 8px #00000033" }}>{it.txt}</span>
              {it.letras.map((l, j) => {
                const a = t * 1.4 + (j * Math.PI) / 2;
                return (
                  <div key={l} style={{ position: "absolute", left: 150 + Math.cos(a) * 200 - 34, top: 150 + Math.sin(a) * 90 - 34, width: 68, height: 68, borderRadius: 34, background: "#fff", boxShadow: "0 6px 16px #00000022", display: "flex", alignItems: "center", justifyContent: "center", zIndex: Math.sin(a) > 0 ? 2 : 0 }}>
                    <span style={{ fontFamily: TIT, fontWeight: 800, fontSize: 32, color: it.c2, marginTop: 4 }}>{l}</span>
                  </div>
                );
              })}
              {it.letras.length === 0
                ? Array.from({ length: 7 }, (_, j) => {
                    const a = t * 1.2 + j * 0.9;
                    return <div key={j} style={{ position: "absolute", left: 150 + Math.cos(a) * 210 - 18, top: 150 + Math.sin(a) * 100 - 18, width: 36, height: 36, borderRadius: 18, background: j % 2 ? "#fff" : L.azul, boxShadow: "0 4px 10px #00000022" }} />;
                  })
                : null}
            </Esfera>
          </div>
        );
      })}
    </AbsoluteFill>
  );
};

/** 6 · Los alimentos caen en un bol y se llena la barra "tu cuerpo". */
const Alimentos: React.FC<{ t: number }> = ({ t }) => {
  const s0 = E.alimentos.ini;
  const caen = [Manzana, Palta, Brocoli, Zanahoria, Limon, Fresa];
  const opt = T("optimizar") - s0;
  const barra = interpolate(t, [opt - 0.2, opt + 1.2], [0.15, 1], { ...CL, easing: (x) => 1 - (1 - x) ** 3 });
  return (
    <AbsoluteFill>
      {caen.map((C, k) => {
        const t0 = 0.15 + k * 0.22;
        const p = interpolate(t, [t0, t0 + 0.5], [0, 1], { ...CL, easing: (x) => x * x });
        const x = 300 + (k % 3) * 120 + (k > 2 ? 60 : 0);
        const y = -200 + p * (820 + (k > 2 ? -60 : 0));
        return (
          <div key={k} style={{ position: "absolute", left: x, top: y, transform: `rotate(${(1 - p) * (k % 2 ? 90 : -90)}deg)` }}>
            <C t={150} />
          </div>
        );
      })}
      {/* el bol */}
      <svg width={1080} height={1920} style={{ position: "absolute" }}>
        <defs>
          <linearGradient id="bol" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stopColor={L.azul} />
            <stop offset="1" stopColor="#1f7f9b" />
          </linearGradient>
        </defs>
        <ellipse cx={540} cy={1040} rx={340} ry={40} fill="#16404a" opacity={0.12} />
        <path d="M200 760 H880 Q870 1000 540 1010 Q210 1000 200 760 Z" fill="url(#bol)" />
        <ellipse cx={540} cy={760} rx={340} ry={36} fill="#7fd0e3" />
        <path d="M250 800 Q300 940 420 980" stroke="#ffffff66" strokeWidth={14} fill="none" strokeLinecap="round" />
      </svg>
      <svg width={170} height={230} viewBox="0 0 100 135" style={{ position: "absolute", left: 860, top: 820 }}>
        <path d="M14 10 H86 L78 128 H22 Z" fill="#e9f8fc" stroke="#9fc4d2" strokeWidth={4} />
        <path d={`M20 ${50 + Math.sin(t * 3) * 3} Q50 ${44 - Math.sin(t * 3) * 3} 82 ${50 + Math.sin(t * 3) * 3} L78 124 H22 Z`} fill={L.azul} opacity={0.55} />
        <path d="M26 20 L30 110" stroke="#fff" strokeWidth={5} strokeLinecap="round" />
      </svg>
      <div style={{ position: "absolute", left: 50, top: 850, transform: `rotate(${-20 + Math.sin(t * 2) * 6}deg)` }}><Hoja tam={140} color={L.verde} /></div>
      <div style={{ position: "absolute", left: 130, top: 940, transform: `rotate(${30 + Math.sin(t * 2 + 1) * 6}deg)` }}><Hoja tam={100} color={L.verdeOsc} /></div>
      <Destellos t={t} desde={opt + 0.2} x={540} y={760} />
      {/* la barra del cuerpo */}
      <div style={{ position: "absolute", left: 140, right: 140, top: 1110, transform: `scale(${pop(t, T("ayudar") - s0 - 0.3)})` }}>
        <div style={{ display: "flex", justifyContent: "space-between", fontFamily: TIT, fontWeight: 800, fontSize: 46, color: OSC }}>
          <span>TU CUERPO</span>
          <span style={{ color: L.verdeOsc }}>{Math.round(barra * 100)}%</span>
        </div>
        <div style={{ height: 44, borderRadius: 22, background: "#ffffff", boxShadow: "inset 0 4px 10px #00000018", overflow: "hidden", marginTop: 8 }}>
          <div style={{ width: `${barra * 100}%`, height: "100%", borderRadius: 22, background: `linear-gradient(90deg, ${L.azul}, ${L.verde})` }} />
        </div>
      </div>
      <div style={{ position: "absolute", left: 0, right: 0, top: 300, display: "flex", justifyContent: "center", transform: `scale(${pop(t, 0)})` }}>
        <Etiqueta texto="ALIMENTOS PARA TI" color={L.verdeOsc} tam={54} />
      </div>
    </AbsoluteFill>
  );
};

/** Microbios: virus (espinoso) y bacteria (cápsula con flagelos). */
const Virus: React.FC<{ t: number; tam?: number }> = ({ t, tam = 120 }) => (
  <svg width={tam} height={tam} viewBox="0 0 100 100" style={{ transform: `rotate(${t * 40}deg)`, overflow: "visible" }}>
    {Array.from({ length: 12 }, (_, k) => (
      <g key={k} transform={`rotate(${k * 30} 50 50)`}>
        <path d="M50 22 V8" stroke="#c0406a" strokeWidth={5} strokeLinecap="round" />
        <circle cx={50} cy={7} r={5} fill="#e8546a" />
      </g>
    ))}
    <circle cx={50} cy={50} r={28} fill="#e8546a" />
    <circle cx={42} cy={42} r={6} fill="#ffffff66" />
    <circle cx={58} cy={58} r={5} fill="#c0406a" />
  </svg>
);
const Bacteria: React.FC<{ t: number; tam?: number }> = ({ t, tam = 150 }) => (
  <svg width={tam} height={tam * 0.6} viewBox="0 0 160 96" style={{ overflow: "visible" }}>
    <path d={`M20 48 Q${4 + Math.sin(t * 8) * 6} 30 -10 ${44 + Math.sin(t * 8) * 6} M20 48 Q${4 - Math.sin(t * 8) * 6} 66 -12 ${60 - Math.sin(t * 8) * 6}`} stroke="#5b9a3a" strokeWidth={4} fill="none" strokeLinecap="round" />
    <rect x={20} y={22} width={130} height={52} rx={26} fill="#8cc63e" />
    <rect x={34} y={30} width={60} height={12} rx={6} fill="#ffffff66" />
    <circle cx={100} cy={52} r={7} fill="#5b9a3a" />
    <circle cx={70} cy={58} r={5} fill="#5b9a3a" />
  </svg>
);

/** 7 · El microscopio: virus y bacterias. */
const Microbios: React.FC<{ t: number }> = ({ t }) => {
  const s0 = E.microbios.ini;
  const vir = T("virus") - s0,
    bac = T("bacterias") - s0;
  return (
    <AbsoluteFill>
      {/* la lente */}
      <div style={{ position: "absolute", left: 90, top: 330, width: 900, height: 900, borderRadius: "50%", background: "radial-gradient(circle at 45% 40%, #f3fcff 0%, #cdeef6 55%, #8fd2e3 100%)", boxShadow: "0 0 0 26px #ffffff, 0 0 0 34px #cfe3ea, 0 40px 80px #16404a33", overflow: "hidden" }}>
        {Array.from({ length: 14 }, (_, k) => (
          <div key={`g${k}`} style={{ position: "absolute", left: random(`gx${k}`) * 820 + Math.sin(t * 0.5 + k) * 30, top: random(`gy${k}`) * 820 + Math.cos(t * 0.4 + k) * 30, width: 70, height: 70, borderRadius: "50%", background: "radial-gradient(circle, #f6c4c9 30%, #ef9aa4 70%)", opacity: 0.35 }} />
        ))}
        {Array.from({ length: 12 }, (_, k) => {
          const x = 120 + random(`mx${k}`) * 660 + Math.sin(t * 0.8 + k) * 40,
            y = 120 + random(`my${k}`) * 660 + Math.cos(t * 0.7 + k) * 40;
          const esV = k % 2 === 0;
          const e = pop(t, T("microorganismos") - E.microbios.ini - 0.3 + k * 0.09);
          return (
            <div key={k} style={{ position: "absolute", left: x - 60, top: y - 40, transform: `scale(${e * (0.6 + random(`ms${k}`) * 0.6)}) rotate(${random(`mr${k}`) * 360}deg)`, opacity: 0.95 }}>
              {esV ? <Virus t={t} /> : <Bacteria t={t} />}
            </div>
          );
        })}
        {/* anillo que escanea */}
        <div style={{ position: "absolute", inset: 0, borderRadius: "50%", background: `conic-gradient(from ${t * 120}deg, transparent 0deg, ${L.azul}33 40deg, transparent 80deg)` }} />
      </div>
      <div style={{ position: "absolute", left: 120, top: 280, transform: `scale(${pop(t, T("microorganismos") - s0)}) rotate(-4deg)` }}>
        <Etiqueta texto="MICROORGANISMOS" color="#c0406a" tam={50} />
      </div>
      <div style={{ position: "absolute", left: 130, top: 1150, transform: `scale(${pop(t, vir)})` }}>
        <Etiqueta texto="VIRUS" color="#e8546a" tam={50} />
      </div>
      <div style={{ position: "absolute", left: 640, top: 1150, transform: `scale(${pop(t, bac)})` }}>
        <Etiqueta texto="BACTERIAS" color="#5b9a3a" tam={50} />
      </div>
    </AbsoluteFill>
  );
};

/** 8 · El móvil con el mensaje y el número, y la flecha a la descripción. */
const Contacto: React.FC<{ t: number }> = ({ t }) => {
  const s0 = E.contacto.ini;
  const num = T("numeros") - s0;
  return (
    <AbsoluteFill>
      <div style={{ position: "absolute", left: 250, top: 300, width: 580, height: 880, borderRadius: 70, background: "#1c2a30", padding: 22, boxSizing: "border-box", boxShadow: "0 40px 80px #16404a44", transform: `rotate(${-4 + Math.sin(t * 1.5) * 1.5}deg)` }}>
        <div style={{ width: "100%", height: "100%", borderRadius: 50, background: "linear-gradient(180deg,#e9f6f8,#f6fbf2)", overflow: "hidden", position: "relative" }}>
          <div style={{ height: 120, background: L.azulTexto, display: "flex", alignItems: "center", gap: 18, padding: "0 28px" }}>
            <div style={{ width: 70, height: 70, borderRadius: 35, background: "#fff", display: "flex", alignItems: "center", justifyContent: "center", overflow: "hidden" }}>
              <svg width={56} height={56} viewBox="0 0 100 100">
                <circle cx={50} cy={50} r={40} fill={L.verde} />
                <path d="M50 26 C62 26 70 36 70 50 C70 64 60 74 50 74 C40 74 30 64 30 50 C30 36 38 26 50 26 Z" fill="#fff" opacity={0.5} />
              </svg>
            </div>
            <div style={{ fontFamily: LEX, fontWeight: 600, fontSize: 30, color: "#fff", lineHeight: 1.1 }}>
              Alimentación y Equilibrio
              <div style={{ fontWeight: 400, fontSize: 22, opacity: 0.85 }}>en línea</div>
            </div>
          </div>
          <div style={{ position: "absolute", right: 24, top: 170, maxWidth: 380, background: "#d9f5c6", borderRadius: "28px 28px 6px 28px", padding: "18px 24px", fontFamily: LEX, fontSize: 30, color: OSC, transform: `scale(${pop(t, T("informacion") - s0 - 0.2)})`, transformOrigin: "right top" }}>
            Hola, quiero más información del test de cabello
          </div>
          <div style={{ position: "absolute", left: 24, top: 360, maxWidth: 380, background: "#fff", borderRadius: "28px 28px 28px 6px", padding: "18px 24px", fontFamily: LEX, fontSize: 30, color: OSC, boxShadow: "0 6px 16px #00000012", transform: `scale(${pop(t, T("escribe") - s0 + 0.2)})`, transformOrigin: "left top" }}>
            ¡Claro! Te cuento
            <span style={{ display: "inline-flex", gap: 6, marginLeft: 10 }}>
              {[0, 1, 2].map((k) => (
                <span key={k} style={{ width: 10, height: 10, borderRadius: 5, background: L.azul, opacity: 0.4 + 0.6 * Math.abs(Math.sin(t * 5 + k)) }} />
              ))}
            </span>
          </div>
        </div>
      </div>
      {Array.from({ length: 6 }, (_, k) => {
        const p = ((t * 0.5 + k / 6) % 1);
        const x = k % 2 ? 870 : 140;
        return (
          <div key={k} style={{ position: "absolute", left: x + Math.sin(t * 2 + k) * 20, top: 1000 - p * 700, opacity: Math.sin(p * Math.PI) * 0.8 }}>
            {k % 3 === 0 ? (
              <svg width={60} height={60} viewBox="0 0 100 100"><path d="M50 88 C20 66 8 50 10 32 C12 16 32 8 50 26 C68 8 88 16 90 32 C92 50 80 66 50 88 Z" fill="#e8546a" /></svg>
            ) : (
              <div style={{ width: 80, height: 56, borderRadius: 20, background: k % 2 ? L.verde : L.azul, display: "flex", alignItems: "center", justifyContent: "center", gap: 6 }}>
                {[0, 1, 2].map((j) => <span key={j} style={{ width: 9, height: 9, borderRadius: 5, background: "#fff" }} />)}
              </div>
            )}
          </div>
        );
      })}
      <div style={{ position: "absolute", left: 640, top: 250, transform: `scale(${pop(t, 0.4)}) rotate(4deg)` }}>
        <Etiqueta texto="RESPUESTA RÁPIDA" color={L.verdeOsc} tam={36} />
      </div>
      {/* el número grande */}
      <div style={{ position: "absolute", left: 0, right: 0, top: 1060, display: "flex", justifyContent: "center", transform: `scale(${pop(t, num - 0.1, 9)}) rotate(-2deg)` }}>
        <div style={{ display: "flex", alignItems: "center", gap: 20, background: `linear-gradient(90deg, ${L.azul}, ${L.verde})`, borderRadius: 999, padding: "16px 44px 10px", boxShadow: `0 20px 40px ${L.azul}55` }}>
          <svg width={64} height={64} viewBox="0 0 100 100">
            <path d="M30 14 L42 38 L34 46 C40 60 50 70 62 76 L70 66 L92 76 L86 92 C50 92 12 56 10 20 Z" fill="#fff" />
          </svg>
          <span style={{ fontFamily: TIT, fontWeight: 800, fontSize: 92, color: "#fff", letterSpacing: 2 }}>990 103 447</span>
        </div>
      </div>
      {/* flecha a la descripción */}
      <div style={{ position: "absolute", left: 0, right: 0, top: 1230, display: "flex", flexDirection: "column", alignItems: "center", opacity: pop(t, T("descripcion") - s0 - 0.3), transform: `translateY(${Math.sin(t * 6) * 10}px)` }}>
        <span style={{ fontFamily: TIT, fontWeight: 800, fontSize: 44, color: OSC }}>EN LA DESCRIPCIÓN</span>
        <svg width={70} height={70} viewBox="0 0 100 100">
          <path d="M50 10 V80 M22 54 L50 84 L78 54" stroke={L.verdeOsc} strokeWidth={12} fill="none" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </div>
    </AbsoluteFill>
  );
};

/** 9 · Cierre: el logo con la web y el WhatsApp. */
const Cierre: React.FC<{ t: number }> = ({ t }) => (
  <AbsoluteFill>
    {[Manzana, Palta, Brocoli, Limon, Fresa, Zanahoria, Manzana, Limon].map((C, k) => {
      const a = -t * 0.35 + (k / 8) * Math.PI * 2;
      return (
        <div key={k} style={{ position: "absolute", left: 540 + Math.cos(a) * 440 - 40, top: 760 + Math.sin(a) * 440 - 40, opacity: 0.8 * pop(t, 0.3 + k * 0.06) }}>
          <C t={80} />
        </div>
      );
    })}
    <div style={{ position: "absolute", left: 540, top: 760, transform: `translate(-50%,-50%) scale(${0.95 * pop(t, 0.1) + 0.015 * Math.sin(t * 2)})` }}>
      <LogoAyE escala={1} />
    </div>
    <div style={{ position: "absolute", left: 0, right: 0, top: 1150, display: "flex", flexDirection: "column", alignItems: "center", gap: 18, transform: `scale(${pop(t, 0.5)})` }}>
      <Etiqueta texto="WhatsApp 990 103 447" color={L.verdeOsc} tam={50} />
      <div style={{ fontFamily: LEX, fontWeight: 600, fontSize: 40, color: L.azulTexto }}>alimentacionyequilibrio.com</div>
    </div>
  </AbsoluteFill>
);

/* ---------- subtítulos: 2-3 palabras grandes, la que suena resaltada y las clave en color ---------- */
const Subtitulos: React.FC<{ t: number }> = ({ t }) => {
  const grupos: [string, number][][] = [];
  let g: [string, number][] = [];
  PALABRAS.forEach((w) => {
    g.push(w);
    if (/[,.:;?!]$/.test(w[0]) || g.length >= 3) {
      grupos.push(g);
      g = [];
    }
  });
  if (g.length) grupos.push(g);
  const i = grupos.findIndex((gr, k) => t >= gr[0][1] - 0.05 && t < (grupos[k + 1] ? grupos[k + 1][0][1] - 0.05 : gr[gr.length - 1][1] + 0.8));
  if (i < 0 || t > 30.9) return null;
  const gr = grupos[i];
  const e = interpolate(t, [gr[0][1] - 0.05, gr[0][1] + 0.08], [0.85, 1], CL);
  return (
    <div style={{ position: "absolute", left: 60, right: 60, top: 1390, display: "flex", justifyContent: "center", flexWrap: "wrap", gap: "0 18px", transform: `scale(${e})` }}>
      {gr.map(([w, ini], k) => {
        const limpio = w.replace(/[¿?,.:;!]/g, "");
        const clave = CLAVES.has(norm(limpio));
        const suena = t >= ini - 0.03;
        return (
          <span key={k} style={{ fontFamily: TIT, fontWeight: 800, fontSize: 92, lineHeight: 1.05, color: clave ? (k % 2 ? L.verdeOsc : L.azulTexto) : OSC, opacity: suena ? 1 : 0.35, textTransform: "uppercase", WebkitTextStroke: "10px #ffffff", paintOrder: "stroke fill", filter: "drop-shadow(0 6px 10px #16404a33)" }}>
            {limpio}
          </span>
        );
      })}
    </div>
  );
};

/* ---------- sonidos: uno por cada cosa que aparece ---------- */
const SFX: [string, number, number][] = [
  ["whoosh", 0, 0.4],
  ...[0, 1, 2, 3, 4].map((k) => ["pop", T("5") + k * 0.07, 0.25] as [string, number, number]),
  ["subida", T("podemos"), 0.3],
  ["latido", T("salud?") - 0.1, 0.4],
  ["whoosh", E.logo.ini - 0.2, 0.35],
  ["brillo", T("hola"), 0.35],
  ["pop", T("peru"), 0.3],
  ["whoosh", E.test.ini - 0.2, 0.35],
  ["tic", T("sensibilidad") - 0.2, 0.3],
  ["whoosh", E.salud.ini - 0.2, 0.35],
  ["pop", T("ambientales"), 0.3],
  ["whoosh", E.nutrientes.ini - 0.2, 0.35],
  ["pop", T("vitaminas") - 0.1, 0.3],
  ["pop", T("minerales") - 0.1, 0.3],
  ["pop", T("aminoacidos") - 0.1, 0.3],
  ["whoosh", E.alimentos.ini - 0.2, 0.35],
  ["exito", T("optimizar"), 0.3],
  ["whoosh", E.microbios.ini - 0.2, 0.35],
  ["pop", T("virus"), 0.3],
  ["pop", T("bacterias"), 0.3],
  ["whoosh", E.contacto.ini - 0.2, 0.35],
  ["clic", T("informacion") - 0.2, 0.4],
  ["exito", T("numeros"), 0.35],
  ["brillo", E.cierre.ini + 0.1, 0.4],
];

export const TestCabello: React.FC = () => {
  const f = useCurrentFrame();
  const t = f / FPS;
  return (
    <AbsoluteFill style={{ background: "#f2fbfd" }}>
      <Fondo t={t} />
      <Viaje e={E.gancho} t={t}>{(l) => <Gancho t={l} />}</Viaje>
      <Viaje e={E.logo} t={t}>{(l) => <Logo t={l} />}</Viaje>
      <Viaje e={E.test} t={t}>{(l) => <Test t={l} />}</Viaje>
      <Viaje e={E.salud} t={t}>{(l) => <Salud t={l} />}</Viaje>
      <Viaje e={E.nutrientes} t={t}>{(l) => <Nutrientes t={l} />}</Viaje>
      <Viaje e={E.alimentos} t={t}>{(l) => <Alimentos t={l} />}</Viaje>
      <Viaje e={E.microbios} t={t}>{(l) => <Microbios t={l} />}</Viaje>
      <Viaje e={E.contacto} t={t}>{(l) => <Contacto t={l} />}</Viaje>
      <Viaje e={E.cierre} t={t}>{(l) => <Cierre t={l} />}</Viaje>
      <Subtitulos t={t} />
      <Html5Audio src={src("voz-original.wav")} volume={1.6} />
      <Html5Audio loop src={src("musica.mp3")} volume={0.08} />
      {SFX.map(([id, en, vol], k) => (
        <Sequence key={k} from={Math.max(0, Math.round(en * FPS))} durationInFrames={FPS * 3}>
          <Html5Audio src={src(`sfx-${id}.mp3`)} volume={vol} />
        </Sequence>
      ))}
    </AbsoluteFill>
  );
};
