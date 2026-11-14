// Adaptado de la skill «animaciones» (github.com/remonkevin99-collab/animaciones), estilo 9 · Acuarela. Licencia MIT: ver LICENSE en esta carpeta.
// La piel de la acuarela: papel cálido con fibras, grano, borde rasgado, aguadas de borde roto que «hierven», pigmento en el borde
// y lápiz suelto corrido. Aquí los filtros llevan ids fijos (`acu-…`) para poder aplicarlos también con `filter: url(#…)` de CSS
// a piezas que no son de este estilo (Nyxar, la sartén, el fuego…).
import "@fontsource/caveat/500.css";
import "@fontsource/caveat/700.css";
import React from "react";
import { continueRender, delayRender } from "remotion";

export const MANO = "'Caveat', cursive";
if (typeof document !== "undefined") {
  const h = delayRender("Caveat");
  Promise.all([document.fonts.load(`700 80px 'Caveat'`), document.fonts.load(`500 40px 'Caveat'`)])
    .then(() => continueRender(h))
    .catch(() => continueRender(h));
}

export type P = [number, number];
export const PAPEL = "#F8F3E8";
export const BAJO_HOJA = "#D3C4A8";
export const GRAFITO = "#433B35";

/* ---------- ayudas ---------- */
export const clamp = (x: number, a = 0, b = 1) => Math.min(b, Math.max(a, x));
export const mix = (a: number, b: number, k: number) => a + (b - a) * k;
export const rng = (semilla: number) => {
  let s = semilla | 0;
  return () => {
    s = (s + 0x6d2b79f5) | 0;
    let r = Math.imul(s ^ (s >>> 15), 1 | s);
    r = (r + Math.imul(r ^ (r >>> 7), 61 | r)) ^ r;
    return ((r ^ (r >>> 14)) >>> 0) / 4294967296;
  };
};
export const f1 = (n: number) => n.toFixed(1);
export const ruta = (pts: P[], cerrar = false) => "M " + pts.map(([x, y]) => `${f1(x)} ${f1(y)}`).join(" L ") + (cerrar ? " Z" : "");
export const rectD = (x: number, y: number, w: number, h: number) => `M ${f1(x)} ${f1(y)} H ${f1(x + w)} V ${f1(y + h)} H ${f1(x)} Z`;
export const circD = (c: P, r: number) => `M ${f1(c[0] - r)} ${f1(c[1])} A ${f1(r)} ${f1(r)} 0 1 0 ${f1(c[0] + r)} ${f1(c[1])} A ${f1(r)} ${f1(r)} 0 1 0 ${f1(c[0] - r)} ${f1(c[1])} Z`;
export const elipD = (c: P, rx: number, ry: number, ang = 0) => {
  const pts: P[] = [];
  for (let i = 0; i < 40; i++) {
    const a = (i / 40) * Math.PI * 2;
    const x = Math.cos(a) * rx,
      y = Math.sin(a) * ry;
    pts.push([c[0] + x * Math.cos(ang) - y * Math.sin(ang), c[1] + x * Math.sin(ang) + y * Math.cos(ang)]);
  }
  return ruta(pts, true);
};
/** Rectángulo de esquinas redondeadas. */
export const redD = (x: number, y: number, w: number, h: number, r: number) =>
  `M ${x + r} ${y} H ${x + w - r} Q ${x + w} ${y} ${x + w} ${y + r} V ${y + h - r} Q ${x + w} ${y + h} ${x + w - r} ${y + h} H ${x + r} Q ${x} ${y + h} ${x} ${y + h - r} V ${y + r} Q ${x} ${y} ${x + r} ${y} Z`;

/** El pigmento acumulado en el borde: más oscuro y saturado (curva gamma). Solo #RRGGBB. */
const rgb = (h: string) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16));
export const pigmento = (h: string, g = 1.8, k = 0.9) => `rgb(${rgb(h).map((v) => Math.round(255 * k * (v / 255) ** g)).join(",")})`;

/* ---------- el lápiz ---------- */
export const rayaLapiz = (a: P, b: P, r: () => number, sobra = 7) => {
  const dx = b[0] - a[0],
    dy = b[1] - a[1];
  const d = Math.hypot(dx, dy) || 1;
  const ux = dx / d,
    uy = dy / d;
  const s0 = sobra * (0.2 + r()),
    s1 = sobra * (0.2 + r());
  const A: P = [a[0] - ux * s0 + (r() - 0.5) * 1.6, a[1] - uy * s0 + (r() - 0.5) * 1.6];
  const B: P = [b[0] + ux * s1 + (r() - 0.5) * 1.6, b[1] + uy * s1 + (r() - 0.5) * 1.6];
  const comba = (r() - 0.5) * Math.min(5, d * 0.025);
  const C: P = [(A[0] + B[0]) / 2 - uy * comba, (A[1] + B[1]) / 2 + ux * comba];
  return `M ${f1(A[0])} ${f1(A[1])} Q ${f1(C[0])} ${f1(C[1])} ${f1(B[0])} ${f1(B[1])}`;
};
export const lineaLapiz = (pts: P[], r: () => number, cerrar = true, sobra = 6) => {
  const out: string[] = [];
  const m = cerrar ? pts.length : pts.length - 1;
  for (let i = 0; i < m; i++) out.push(rayaLapiz(pts[i], pts[(i + 1) % pts.length], r, sobra));
  return out.join(" ");
};
export const aroLapiz = (c: P, rr: number, r: () => number) => {
  const n = Math.max(26, Math.round(rr * 0.45));
  const a0 = r() * Math.PI * 2,
    extra = 0.1 + r() * 0.12,
    fase = r() * 6;
  const pts: P[] = [];
  for (let i = 0; i <= n; i++) {
    const a = a0 + (i / n) * Math.PI * 2 * (1 + extra);
    const q = rr * (1 + 0.02 * Math.sin(a * 2 + fase)) + (i / n) * 3;
    pts.push([c[0] + Math.cos(a) * q, c[1] + Math.sin(a) * q]);
  }
  return ruta(pts);
};

/* ---------- un «lienzo» para pintar cosas: aguadas + lápiz ---------- */
export type Pintada = { agua: React.ReactNode[]; lapiz: string };
export const lienzo = (semilla: number) => {
  const agua: React.ReactNode[] = [];
  const lapiz: string[] = [];
  const r = rng(semilla);
  let n = 0;
  const mancha = (d: string, color: string, op = 0.95, borde = 5) =>
    agua.push(<path key={n++} d={d} fill={color} fillOpacity={op} stroke={borde ? (color.startsWith("#") ? pigmento(color) : "#6F93BC") : "none"} strokeWidth={borde} strokeOpacity={0.5} strokeLinejoin="round" />);
  const raya = (d: string, color: string, w: number, op = 1) => agua.push(<path key={n++} d={d} fill="none" stroke={color} strokeWidth={w} strokeOpacity={op} strokeLinecap="round" strokeLinejoin="round" />);
  const linea = (pts: P[], cerrar = true, sobra = 6) => lapiz.push(lineaLapiz(pts, r, cerrar, sobra));
  const caja = (x: number, y: number, w: number, h: number) =>
    linea(
      [
        [x, y],
        [x + w, y],
        [x + w, y + h],
        [x, y + h],
      ],
      true,
      Math.min(9, Math.min(w, h) * 0.3),
    );
  const aro = (c: P, rr: number) => lapiz.push(aroLapiz(c, rr, r));
  const texto = (x: number, y: number, t: string, tam: number, color: string, giro = 0) =>
    agua.push(
      <text key={n++} x={x} y={y} fontFamily={MANO} fontWeight={700} fontSize={tam} fill={color} textAnchor="middle" transform={`rotate(${giro} ${x} ${y})`}>
        {t}
      </text>,
    );
  const fin = (): Pintada => ({ agua, lapiz: lapiz.join(" ") });
  return { agua, lapiz, r, mancha, raya, linea, caja, aro, texto, fin };
};

/* ---------- la hoja ---------- */
export const Papel: React.FC = React.memo(() => {
  const r = rng(77);
  const fibras: string[] = [];
  for (let i = 0; i < 260; i++) {
    const x = r() * 1080,
      y = r() * 1920,
      a = r() * Math.PI,
      l = 8 + r() * 22,
      cv = (r() - 0.5) * 8;
    const ex = x + Math.cos(a) * l,
      ey = y + Math.sin(a) * l;
    fibras.push(`M ${f1(x)} ${f1(y)} Q ${f1((x + ex) / 2 - Math.sin(a) * cv)} ${f1((y + ey) / 2 + Math.cos(a) * cv)} ${f1(ex)} ${f1(ey)}`);
  }
  return (
    <svg viewBox="0 0 1080 1920" style={{ position: "absolute", inset: 0, width: "100%", height: "100%" }}>
      <defs>
        <filter id="acu-pliegues" x="0" y="0" width="100%" height="100%" colorInterpolationFilters="sRGB">
          <feTurbulence type="fractalNoise" baseFrequency="0.0026 0.0034" numOctaves={4} seed={5} />
          <feColorMatrix type="matrix" values="0 0 0 0 0.66  0 0 0 0 0.56  0 0 0 0 0.42  0 0 0 1.5 -0.66" />
        </filter>
      </defs>
      <rect width={1080} height={1920} fill={PAPEL} />
      <rect width={1080} height={1920} filter="url(#acu-pliegues)" opacity={0.4} />
      <path d={fibras.join(" ")} fill="none" stroke="#C9B99E" strokeWidth={0.9} strokeOpacity={0.3} />
    </svg>
  );
});

export const Grano: React.FC = React.memo(() => (
  <svg viewBox="0 0 1080 1920" style={{ position: "absolute", inset: 0, width: "100%", height: "100%", mixBlendMode: "multiply", pointerEvents: "none" }}>
    <defs>
      <filter id="acu-grano" x="0" y="0" width="100%" height="100%" colorInterpolationFilters="sRGB">
        <feTurbulence type="fractalNoise" baseFrequency="0.36" numOctaves={2} seed={8} result="fino" />
        <feTurbulence type="fractalNoise" baseFrequency="0.07" numOctaves={2} seed={3} result="grueso" />
        <feComposite in="fino" in2="grueso" operator="arithmetic" k2={0.6} k3={0.4} />
        <feColorMatrix type="matrix" values="1.3 0 0 0 0.25  1.3 0 0 0 0.23  1.3 0 0 0 0.19  0 0 0 0 1" />
      </filter>
    </defs>
    <rect width={1080} height={1920} filter="url(#acu-grano)" opacity={0.34} />
  </svg>
));

const ANCHO_PAPEL = 14;
export const Borde: React.FC = React.memo(() => {
  const marco = `M -60 -60 H 1140 V 1980 H -60 Z M ${ANCHO_PAPEL} ${ANCHO_PAPEL} V ${1920 - ANCHO_PAPEL} H ${1080 - ANCHO_PAPEL} V ${ANCHO_PAPEL} Z`;
  return (
    <svg viewBox="0 0 1080 1920" style={{ position: "absolute", inset: 0, width: "100%", height: "100%", pointerEvents: "none" }}>
      <defs>
        <filter id="acu-rasgado" x="-5%" y="-5%" width="110%" height="110%">
          <feTurbulence type="fractalNoise" baseFrequency="0.05" numOctaves={3} seed={21} result="n" />
          <feDisplacementMap in="SourceGraphic" in2="n" scale={13} xChannelSelector="R" yChannelSelector="G" />
        </filter>
        <filter id="acu-sombraBorde" x="-5%" y="-5%" width="110%" height="110%">
          <feTurbulence type="fractalNoise" baseFrequency="0.05" numOctaves={3} seed={21} result="n" />
          <feDisplacementMap in="SourceGraphic" in2="n" scale={13} xChannelSelector="R" yChannelSelector="G" result="d" />
          <feGaussianBlur in="d" stdDeviation={3} />
        </filter>
      </defs>
      <path d={marco} fillRule="evenodd" fill="#7A6A52" opacity={0.35} filter="url(#acu-sombraBorde)" transform="translate(3 4)" />
      <path d={marco} fillRule="evenodd" fill={BAJO_HOJA} filter="url(#acu-rasgado)" />
    </svg>
  );
});

/* ---------- los filtros ---------- */
/** Un material que se mueve: borde roto que hierve, manchas claras y oscuras, pigmento del borde y lápiz del contorno corrido. */
const filtroMaterial = (id: string, semilla: number, escala: number, anillo: number, corrido: P, lapiz = 0.72) => (
  <filter id={id} x="-30%" y="-30%" width="160%" height="160%" colorInterpolationFilters="sRGB">
    <feTurbulence type="fractalNoise" baseFrequency="0.03" numOctaves={3} seed={semilla} result="n" />
    <feTurbulence type="fractalNoise" baseFrequency="0.024" numOctaves={2} seed={41} result="nf" />
    <feDisplacementMap in="SourceGraphic" in2="n" scale={escala} xChannelSelector="R" yChannelSelector="G" result="d" />
    <feComposite in="nf" in2="n" operator="arithmetic" k2={0.55} k3={0.45} result="nm" />
    <feComponentTransfer in="d" result="claro">
      <feFuncR type="linear" slope={0.74} intercept={0.27} />
      <feFuncG type="linear" slope={0.74} intercept={0.27} />
      <feFuncB type="linear" slope={0.74} intercept={0.26} />
    </feComponentTransfer>
    <feColorMatrix in="nm" type="matrix" values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 2.6 0 -1.12" result="mc" />
    <feComposite in="claro" in2="mc" operator="in" result="claros" />
    <feComponentTransfer in="d" result="osc">
      <feFuncR type="gamma" amplitude={0.94} exponent={1.4} offset={0} />
      <feFuncG type="gamma" amplitude={0.93} exponent={1.4} offset={0} />
      <feFuncB type="gamma" amplitude={0.93} exponent={1.4} offset={0} />
    </feComponentTransfer>
    <feColorMatrix in="nm" type="matrix" values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  2.4 0 0 0 -1.25" result="mo" />
    <feComposite in="osc" in2="mo" operator="in" result="oscuros" />
    <feMerge result="c0">
      <feMergeNode in="d" />
      <feMergeNode in="claros" />
      <feMergeNode in="oscuros" />
    </feMerge>
    <feGaussianBlur in="c0" stdDeviation={0.9} result="c" />
    <feGaussianBlur in="d" stdDeviation={6} result="b" />
    <feComposite in="d" in2="b" operator="arithmetic" k2={1} k3={-1} result="r" />
    <feComponentTransfer in="r" result="borde">
      <feFuncR type="gamma" amplitude={0.9} exponent={2} offset={0} />
      <feFuncG type="gamma" amplitude={0.88} exponent={2} offset={0} />
      <feFuncB type="gamma" amplitude={0.86} exponent={2} offset={0} />
      <feFuncA type="linear" slope={2.1} />
    </feComponentTransfer>
    <feMorphology in="SourceAlpha" operator="dilate" radius={anillo} result="dil" />
    <feComposite in="dil" in2="SourceAlpha" operator="out" result="anillo" />
    <feOffset in="anillo" dx={corrido[0]} dy={corrido[1]} result="anilloO" />
    <feFlood floodColor={GRAFITO} floodOpacity={lapiz} />
    <feComposite in2="anilloO" operator="in" result="lapizC" />
    <feMerge>
      <feMergeNode in="c" />
      <feMergeNode in="borde" />
      <feMergeNode in="lapizC" />
    </feMerge>
  </filter>
);

/** Todos los filtros del video. `paso` cambia 10 veces por segundo: es lo que hace «hervir» los bordes. */
export const Filtros: React.FC<{ paso: number }> = ({ paso }) => (
  <svg width={0} height={0} style={{ position: "absolute" }}>
    <defs>
      <filter id="acu-fondo" x="-6%" y="-6%" width="112%" height="112%" colorInterpolationFilters="sRGB">
        <feTurbulence type="fractalNoise" baseFrequency="0.008" numOctaves={4} seed={3} result="n1" />
        <feTurbulence type="fractalNoise" baseFrequency="0.035" numOctaves={2} seed={200 + paso} result="n2" />
        <feDisplacementMap in="SourceGraphic" in2="n1" scale={34} xChannelSelector="R" yChannelSelector="G" result="d1" />
        <feDisplacementMap in="d1" in2="n2" scale={6} xChannelSelector="R" yChannelSelector="G" result="d" />
        <feComposite in="n1" in2="n2" operator="arithmetic" k2={0.8} k3={0.2} result="nm" />
        <feColorMatrix in="nm" type="matrix" values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 1.2 0 0.3" result="m" />
        <feComposite in="d" in2="m" operator="in" result="cuerpo" />
        <feComponentTransfer in="d" result="osc">
          <feFuncR type="gamma" amplitude={0.97} exponent={1.3} offset={0} />
          <feFuncG type="gamma" amplitude={0.96} exponent={1.3} offset={0} />
          <feFuncB type="gamma" amplitude={0.94} exponent={1.3} offset={0} />
        </feComponentTransfer>
        <feColorMatrix in="n1" type="matrix" values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  2.4 0 0 0 -1.25" result="mk" />
        <feComposite in="osc" in2="mk" operator="in" result="manchas0" />
        <feGaussianBlur in="manchas0" stdDeviation={8} result="manchas" />
        <feGaussianBlur in="d" stdDeviation={10} result="b" />
        <feComposite in="d" in2="b" operator="arithmetic" k2={1} k3={-1} result="r" />
        <feComponentTransfer in="r" result="borde">
          <feFuncR type="gamma" amplitude={0.95} exponent={1.55} offset={0} />
          <feFuncG type="gamma" amplitude={0.93} exponent={1.55} offset={0} />
          <feFuncB type="gamma" amplitude={0.9} exponent={1.55} offset={0} />
          <feFuncA type="linear" slope={1.15} />
        </feComponentTransfer>
        <feMerge result="todo">
          <feMergeNode in="cuerpo" />
          <feMergeNode in="manchas" />
          <feMergeNode in="borde" />
        </feMerge>
        <feGaussianBlur in="todo" stdDeviation={1.3} />
      </filter>
      <filter id="acu-cosa" x="-14%" y="-14%" width="128%" height="128%" colorInterpolationFilters="sRGB">
        <feTurbulence type="fractalNoise" baseFrequency="0.022" numOctaves={3} seed={12} result="n1" />
        <feTurbulence type="fractalNoise" baseFrequency="0.055" numOctaves={2} seed={60 + paso} result="n2" />
        <feDisplacementMap in="SourceGraphic" in2="n1" scale={10} xChannelSelector="R" yChannelSelector="G" result="d1" />
        <feDisplacementMap in="d1" in2="n2" scale={5} xChannelSelector="G" yChannelSelector="B" result="d" />
        <feComposite in="n1" in2="n2" operator="arithmetic" k2={0.7} k3={0.3} result="nm" />
        <feComponentTransfer in="d" result="claro">
          <feFuncR type="linear" slope={0.72} intercept={0.29} />
          <feFuncG type="linear" slope={0.72} intercept={0.28} />
          <feFuncB type="linear" slope={0.72} intercept={0.25} />
        </feComponentTransfer>
        <feColorMatrix in="nm" type="matrix" values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 2.6 0 -1.12" result="mc" />
        <feComposite in="claro" in2="mc" operator="in" result="claros" />
        <feComponentTransfer in="d" result="osc">
          <feFuncR type="gamma" amplitude={0.95} exponent={1.45} offset={0} />
          <feFuncG type="gamma" amplitude={0.93} exponent={1.45} offset={0} />
          <feFuncB type="gamma" amplitude={0.92} exponent={1.45} offset={0} />
        </feComponentTransfer>
        <feColorMatrix in="nm" type="matrix" values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  2.4 0 0 0 -1.25" result="mo" />
        <feComposite in="osc" in2="mo" operator="in" result="oscuros" />
        <feMerge result="c">
          <feMergeNode in="d" />
          <feMergeNode in="claros" />
          <feMergeNode in="oscuros" />
        </feMerge>
        <feGaussianBlur in="c" stdDeviation={1.1} />
      </filter>
      {/* Nyxar y su pata: borde que hierve y lápiz corrido */}
      {filtroMaterial("acu-nyxar", 40 + paso, 7, 2.1, [4, -3], 0.5)}
      {/* los objetos que se mueven (sartén, tapa, vaso, botes, mando) */}
      {filtroMaterial("acu-objeto", 90 + paso, 6, 2, [3.5, -2.5], 0.6)}
      {/* el fuego: muy roto y sin lápiz */}
      <filter id="acu-fuego" x="-30%" y="-30%" width="160%" height="160%" colorInterpolationFilters="sRGB">
        <feTurbulence type="fractalNoise" baseFrequency="0.04" numOctaves={3} seed={300 + paso} result="n" />
        <feDisplacementMap in="SourceGraphic" in2="n" scale={22} xChannelSelector="R" yChannelSelector="G" result="d" />
        <feGaussianBlur in="d" stdDeviation={2.2} result="s" />
        <feGaussianBlur in="d" stdDeviation={6} result="b" />
        <feComposite in="d" in2="b" operator="arithmetic" k2={1} k3={-1} result="r" />
        <feComponentTransfer in="r" result="borde">
          <feFuncR type="gamma" amplitude={0.9} exponent={1.6} offset={0} />
          <feFuncG type="gamma" amplitude={0.7} exponent={1.6} offset={0} />
          <feFuncB type="gamma" amplitude={0.6} exponent={1.6} offset={0} />
          <feFuncA type="linear" slope={1.6} />
        </feComponentTransfer>
        <feMerge>
          <feMergeNode in="s" />
          <feMergeNode in="borde" />
        </feMerge>
      </filter>
      <filter id="acu-vapor" x="-40%" y="-20%" width="180%" height="140%">
        <feTurbulence type="fractalNoise" baseFrequency="0.03" numOctaves={2} seed={9 + paso} result="n" />
        <feDisplacementMap in="SourceGraphic" in2="n" scale={14} xChannelSelector="R" yChannelSelector="G" result="d" />
        <feGaussianBlur in="d" stdDeviation={4.5} />
      </filter>
      {[3, 8, 14, 22].map((s) => (
        <filter key={s} id={`acu-b${s}`} x="-30%" y="-60%" width="160%" height="220%">
          <feGaussianBlur stdDeviation={s} />
        </filter>
      ))}
    </defs>
  </svg>
);

/** Una cosa pintada: la aguada corrida bajo su filtro y el lápiz encima. */
export const Cosa: React.FC<{ pt: Pintada; filtro?: string; op?: number }> = ({ pt, filtro = "acu-cosa", op = 0.7 }) => (
  <g>
    <g transform="translate(-4 3)" filter={`url(#${filtro})`}>
      {pt.agua}
    </g>
    <path d={pt.lapiz} fill="none" stroke={GRAFITO} strokeWidth={2.1} strokeOpacity={op} strokeLinecap="round" />
  </g>
);
