// Adaptado de la skill «animaciones» (github.com/remonkevin99-collab/animaciones), licencia MIT: ver LICENSE en esta carpeta.
// El diorama de papel (pared de rayas, guirnalda, suelo de tablas, planta de delante) y el golpe (estrella desplegable y letras pegadas).
import "@fontsource/lilita-one";
import React from "react";
import { continueRender, delayRender } from "remotion";
import { clamp, rng, type P } from "./curvas";
import { cuadratica } from "./corte";
import { hojaPts, recorte, rectPts } from "./geo";
import { f, type Tinta } from "./tintas";

export const LILITA = "'Lilita One', sans-serif";
if (typeof document !== "undefined") {
  const h = delayRender("Lilita One");
  document.fonts
    .load(`400 80px 'Lilita One'`)
    .then(() => continueRender(h))
    .catch(() => continueRender(h));
}

export const PASOS = 12;
/** Donde el suelo se junta con la pared. */
export const FONDO_SUELO = 1540;

let semilla = 100;
const S = () => (semilla += 37);

/** Una pieza de papel cortada: su forma, su cartulina y la sombra que deja (cortar SIEMPRE fuera del render). */
export const pz = (pts: P[], t: Tinta, s: string | null = "s1", amp = 1.5, props?: React.SVGProps<SVGPathElement>, paso = 18) => (
  <path key={semilla} d={recorte(pts, S(), amp, paso)} fill={f(t)} filter={s ? `url(#gpp-${s})` : undefined} {...props} />
);

/** El recolocado a mano de cada paso: hasta ±a px y ±g grados sobre su articulación. */
export const toque = (r: () => number, ancla: P, a = 1.3, g = 0.55) => {
  const jx = (r() - 0.5) * 2 * a,
    jy = (r() - 0.5) * 2 * a,
    jr = (r() - 0.5) * 2 * g;
  return `translate(${jx.toFixed(2)} ${jy.toFixed(2)}) rotate(${jr.toFixed(2)} ${ancla[0].toFixed(1)} ${ancla[1].toFixed(1)})`;
};

export const hojasPlanta = (base: P, alto: number, ancho: number, sem: number, n = 9, abre = 125) => {
  const r = rng(sem);
  const hojas: { orden: number; pts: P[]; mitad: P[]; i: number }[] = [];
  for (let i = 0; i < n; i++) {
    const lado = i / (n - 1) - 0.5;
    const ang = (-90 + lado * abre + (r() - 0.5) * 14) * (Math.PI / 180);
    const largo = alto * (1 - Math.abs(lado) * 0.75) * (0.85 + r() * 0.25);
    const curva = lado * (0.9 + r() * 0.5);
    const w = Math.max(8, ancho * (0.17 + r() * 0.05));
    const b: P = [base[0] + lado * ancho * 0.18, base[1] + 4];
    hojas.push({ orden: Math.abs(lado) + r() * 0.05, pts: hojaPts(b, ang, largo, w, curva), mitad: hojaPts(b, ang, largo, w, curva, true), i });
  }
  return hojas.sort((a, b) => b.orden - a.orden);
};

/* ---------- la guirnalda de banderines ---------- */
const G_Y0 = 64,
  G_COMBA = 92;
const gB = (x: number): P => [x, G_Y0 + (4 * G_COMBA * x * (1080 - x)) / (1080 * 1080)];
const G_COLORES: Tinta[] = ["coral", "mostaza", "menta", "crema", "lila", "verde3", "azul"];
const BANDERINES = Array.from({ length: 13 }, (_, i) => {
  const x = 30 + i * 85;
  const b = gB(x);
  const d = (4 * G_COMBA * (1080 - 2 * x)) / (1080 * 1080);
  const a = Math.atan(d);
  const tx = Math.cos(a),
    ty = Math.sin(a),
    nx = -Math.sin(a),
    ny = Math.cos(a);
  const pts: P[] = [
    [b[0] - tx * 27, b[1] - ty * 27],
    [b[0] + tx * 27, b[1] + ty * 27],
    [b[0] + nx * 66, b[1] + ny * 66],
  ];
  return { b, d: recorte(pts, 300 + i * 7, 1.2, 14), t: G_COLORES[i % G_COLORES.length] };
});
const CUERDA = cuadratica([-40, gB(-40)[1]], [540, G_Y0 + 2 * G_COMBA], [1120, gB(1120)[1]], 24)
  .map((q, i) => `${i ? "L" : "M"} ${q[0].toFixed(1)} ${q[1].toFixed(1)}`)
  .join(" ");
export const guirnalda = (n: number, apagada = 0) => {
  const r = rng(6000 + n * 29);
  return (
    <g opacity={1 - apagada * 0.5}>
      <path d={CUERDA} fill="none" stroke="#6E5236" strokeWidth={2.4} />
      {BANDERINES.map((b, i) => (
        <path key={i} d={b.d} fill={f(b.t)} filter="url(#gpp-s1)" transform={`rotate(${((r() - 0.5) * 3.2).toFixed(2)} ${b.b[0].toFixed(1)} ${b.b[1].toFixed(1)})`} />
      ))}
    </g>
  );
};

/* ---------- la planta de delante (abajo a la izquierda, cerca de la cámara) ---------- */
const FRENTE_HOJAS = hojasPlanta([40, 2000], 400, 380, 61, 9, 120);
const FRENTE_D = FRENTE_HOJAS.map((h) => ({ d: recorte(h.pts, 6100 + h.i, 1.4, 18), m: recorte(h.mitad, 6200 + h.i, 1, 18), t: (["verdeO1", "verdeO2", "verdeO3"] as Tinta[])[h.i % 3] }));
export const frente = (n: number) => {
  const r = rng(7000 + n * 37);
  return (
    <g transform={`rotate(${((r() - 0.5) * 0.9).toFixed(2)} 40 2000)`}>
      {FRENTE_D.map((h, i) => (
        <g key={i}>
          <path d={h.d} fill={f(h.t)} filter="url(#gpp-s5)" />
          <path d={h.m} fill={f("verde1")} opacity={0.4} />
        </g>
      ))}
    </g>
  );
};

/* ---------- la pared y el suelo de tablas ---------- */
const SUELO = (() => {
  const altos = [38, 44, 50, 58, 66, 76, 88, 100];
  const tintas: Tinta[] = ["suelo1", "suelo2", "suelo3", "suelo4"];
  const r = rng(77);
  const els: React.ReactElement[] = [];
  let y = FONDO_SUELO;
  altos.forEach((h) => {
    let x = -40 - r() * 200,
      prev = -1;
    while (x < 1100) {
      const w = 300 + r() * 330;
      let ti = Math.floor(r() * 4);
      if (ti === prev) ti = (ti + 1) % 4;
      prev = ti;
      els.push(pz(rectPts(x + 1.2, y + 1.4, w - 2.4, h - 2.4), tintas[ti], null, 0.9, undefined, 26));
      x += w;
    }
    y += h;
  });
  return (
    <g>
      <rect x={-20} y={FONDO_SUELO} width={1120} height={1960 - FONDO_SUELO} fill={f("junta")} />
      {els}
      <rect x={-20} y={FONDO_SUELO} width={1120} height={70} fill="url(#gpp-rincon)" />
    </g>
  );
})();

export const FONDO = (
  <g>
    <rect x={-20} y={-20} width={1120} height={FONDO_SUELO + 40} fill={f("pared")} />
    {SUELO}
    {pz(rectPts(-20, FONDO_SUELO - 26, 1120, 32, 2), "zocalo", "s1", 1.6, undefined, 22)}
  </g>
);

/* ---------- el golpe: estrella desplegable, letras pegadas y sacudida ---------- */
const estrellaMedia = (R: number, r0: number, puntas: number, sem: number): P[] => {
  const r = rng(sem);
  const out: P[] = [];
  const N = puntas * 2;
  for (let i = 0; i <= N; i++) {
    const a = Math.PI + (i / N) * Math.PI + (i > 0 && i < N ? (r() - 0.5) * 0.06 : 0);
    const rad = (i % 2 === 1 ? R : r0) * (i > 0 && i < N ? 0.88 + r() * 0.22 : 1);
    out.push([rad * Math.cos(a), Math.min(0, rad * Math.sin(a))]);
  }
  return out;
};
export const ESTRELLA = [
  { d: recorte(estrellaMedia(256, 160, 9, 41), 811, 1.6, 16), t: "mostaza" as Tinta, s: "s3" },
  { d: recorte(estrellaMedia(182, 116, 9, 42), 812, 1.4, 16), t: "crema" as Tinta, s: "s2" },
  { d: recorte(estrellaMedia(104, 66, 7, 43), 813, 1.2, 14), t: "coral" as Tinta, s: "s2" },
];
/** Alto de la estrella desplegable: sube por pasos al golpe y se pliega `dura` segundos después. */
export const subeEstrella = (tq: number, tGolpe: number, dura = 0.5) => {
  const k = Math.round((tq - tGolpe) * PASOS);
  if (k < 0) return 0;
  const sube = [1.22, 0.9, 1.05, 1][Math.min(k, 3)];
  const kb = Math.round((tq - tGolpe - dura) * PASOS);
  const baja = kb < 0 ? 1 : [1, 0.62, 0.22, 0][clamp(kb, 0, 3)];
  return sube * baja;
};
/** Escala de las letras pegadas: entran como la estrella y se van en dos pasos `dura` segundos después. */
export const escalaLetras = (tq: number, tGolpe: number, dura = 0.8) => {
  const k = Math.round((tq - tGolpe) * PASOS);
  if (k < 0) return 0;
  const kb = Math.round((tq - tGolpe - dura) * PASOS);
  if (kb >= 0) return [0.6, 0][clamp(kb, 0, 1)];
  return [1.28, 0.9, 1.05, 1][Math.min(k, 3)];
};
/** La sacudida del decorado en los 3 pasos tras el golpe. */
export const sacudida = (tq: number, golpes: number[]): P => {
  for (const g of golpes) {
    const k = Math.round((tq - g) * PASOS);
    if (k === 0) return [9, -7];
    if (k === 1) return [-6, 4];
    if (k === 2) return [3, -2];
  }
  return [0, 0];
};

/** Onomatopeya o palabra de letras pegadas: cada letra girada y a su altura, coral y cobalto, con borde de papel. */
export const LetrasPegadas: React.FC<{ texto: string; c: P; tam: number; esc: number; n: number; giro?: number }> = ({ texto, c, tam, esc, n, giro = -6 }) => {
  if (esc <= 0) return null;
  const letras = [...texto];
  const anchos = letras.map((l) => (l === " " ? 0.32 : "¡!.,".includes(l) ? 0.34 : "MW".includes(l) ? 0.8 : "IJ1".includes(l) ? 0.42 : 0.62));
  const total = anchos.reduce((a, b) => a + b, 0) * tam;
  const giros = [-8, 5, -4, 7, -6, 9];
  const r = rng(9000 + n * 13);
  let x = -total / 2;
  return (
    <g transform={`translate(${c[0]} ${c[1]}) rotate(${giro}) scale(${esc})`} filter="url(#gpp-s4)">
      {letras.map((l, i) => {
        const w = anchos[i] * tam;
        const cx = x + w / 2;
        x += w;
        if (l === " ") return null;
        const g = giros[i % giros.length] + (r() - 0.5) * 3;
        const dy = ((i % 3) - 1) * tam * 0.05;
        return (
          <text key={i} x={cx} y={dy} transform={`rotate(${g.toFixed(1)} ${cx.toFixed(1)} ${dy.toFixed(1)})`} fontFamily={LILITA} fontSize={tam} textAnchor="middle" fill={i % 2 ? "#2F62B5" : "#E2553F"} stroke="#FBF3E2" strokeWidth={20} strokeLinejoin="round" paintOrder="stroke">
            {l}
          </text>
        );
      })}
    </g>
  );
};
