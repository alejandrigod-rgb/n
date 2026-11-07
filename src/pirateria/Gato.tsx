import { continueRender, delayRender, random, spring, staticFile, useCurrentFrame } from "remotion";
import { aperturaBoca, escenaEn, IdEscena, IDS, INICIOS, marcas } from "./linea";
import { C, FPS } from "./tema";

const CABEZA = staticFile("pirateria/cabeza.png");

// La cabeza va dentro de un <image> SVG: esperamos a que cargue antes de renderizar.
if (typeof window !== "undefined") {
  const h = delayRender("Cargando cabeza del gato");
  const img = new Image();
  img.onload = () => continueRender(h);
  img.onerror = () => continueRender(h);
  img.src = CABEZA;
}

/** Postura del gato. Ángulos en grados: 0 = brazo colgando, 90 = estirado hacia fuera, 160 = arriba. */
export type Pose = {
  brazoI: number;
  brazoD: number;
  cabeza: number;
  inclinar: number;
  salto: number;
  x: number;
  sombrero: number;
  cascos: number;
  carta: number;
};

const BASE: Pose = { brazoI: 12, brazoD: 12, cabeza: 0, inclinar: 0, salto: 0, x: 0, sombrero: 0, cascos: 0, carta: 0 };

const ondaS = (f: number, v: number) => Math.sin(f / v);
const saltito = (f: number, desde: number) => {
  const p = f - desde;
  if (p < 0 || p > 18) return 0;
  return Math.sin((p / 18) * Math.PI) * 60;
};

/** Pose de cada escena en su fotograma local. */
const POSES: Record<IdEscena, (f: number) => Partial<Pose>> = {
  intro: (f) => ({ brazoD: 150 + 22 * ondaS(f, 3.2), brazoI: 18, cabeza: 6 * ondaS(f, 14), salto: saltito(f, 4) }),
  que: (f) => ({ brazoD: 128 + 4 * ondaS(f, 9), brazoI: 18, cabeza: -7, inclinar: 3, x: -60 }),
  nombre: (f) => {
    const m = marcas("nombre");
    return { sombrero: f >= m("piratas") ? 1 : 0, brazoI: 40, brazoD: 40, inclinar: 4 * ondaS(f, 10), cabeza: 5 * ondaS(f, 13), salto: saltito(f, m("piratas")) };
  },
  imprenta: (f) => {
    const m = marcas("imprenta");
    const arriba = f >= m("facilisimo") && f < m("facilisimo") + 40;
    return { brazoI: arriba ? 150 : 20, brazoD: arriba ? 150 : 115, cabeza: arriba ? 0 : -6, salto: saltito(f, m("facilisimo")), x: arriba ? 0 : -50 };
  },
  ley: (f) => ({ brazoI: 28, brazoD: 28, cabeza: 4 * Math.sin(f / 5) * (f % 90 < 30 ? 1 : 0.2), inclinar: 0 }),
  cintas: (f) => ({ cascos: 1, cabeza: 9 * Math.sin(f * 0.42), salto: 10 * Math.abs(Math.sin(f * 0.21)), brazoI: 25 + 18 * Math.sin(f * 0.42), brazoD: 25 - 18 * Math.sin(f * 0.42) }),
  software: (f) => ({ carta: 1, brazoI: 55, brazoD: -128, cabeza: 8 + 3 * ondaS(f, 12), inclinar: -2 }),
  internet: (f) => {
    const m = marcas("internet");
    return { brazoI: 110 + 8 * ondaS(f, 6), brazoD: 110 + 8 * ondaS(f, 6), cabeza: 4 * ondaS(f, 10), salto: saltito(f, m("salto")) + saltito(f, m("napster")) };
  },
  cierre: (f) => {
    const m = marcas("cierre");
    const encoge = f >= m("tarde") - 6;
    return { brazoI: encoge ? 75 : 20, brazoD: encoge ? 75 : 20, cabeza: encoge ? 12 : -3, salto: encoge ? 12 : 0, inclinar: encoge ? -3 : 0 };
  },
  streaming: (f) => {
    const m = marcas("streaming");
    const feliz = f >= m("streaming");
    return { brazoI: feliz ? 150 + 10 * ondaS(f, 4) : 25, brazoD: feliz ? 150 - 10 * ondaS(f, 4) : 125, salto: feliz ? 18 * Math.abs(Math.sin(f / 6)) : 0, cabeza: 5 * ondaS(f, 8) };
  },
  riesgos: (f) => ({ brazoD: 152 + 14 * Math.sin(f / 2.2), brazoI: 15, cabeza: -5, inclinar: 2 }),
  final: (f) => {
    const m = marcas("final");
    const adios = f >= m("vemos") - 10;
    return { brazoD: adios ? 150 + 22 * ondaS(f, 3.2) : 40, brazoI: adios ? 150 - 22 * ondaS(f, 3.2) : 40, salto: saltito(f, m("vemos")), cabeza: 6 * ondaS(f, 12) };
  },
};

const pose = (id: IdEscena, f: number): Pose => ({ ...BASE, ...POSES[id](f) });

const mezclar = (a: Pose, b: Pose, t: number): Pose => {
  const r = { ...a };
  (Object.keys(a) as (keyof Pose)[]).forEach((k) => {
    r[k] = a[k] + (b[k] - a[k]) * t;
  });
  return r;
};

/** Parpadeo cada 3-5 s, en un patrón fijo y natural. */
const parpadeo = (frame: number) => {
  const k = Math.floor(frame / 110);
  for (const j of [k, k - 1]) {
    const inicio = j * 110 + Math.floor(random(`parpadeo-${j}`) * 70);
    const d = frame - inicio;
    if (d >= 0 && d < 7) return [0.3, 0.8, 1, 1, 0.8, 0.4, 0][d];
  }
  return 0;
};

const Brazo: React.FC<{ x: number; y: number; angulo: number; children?: React.ReactNode }> = ({ x, y, angulo, children }) => (
  <g transform={`translate(${x} ${y}) rotate(${angulo})`}>
    <path d="M-17 0 L-15 100 A16 16 0 0 0 15 100 L17 0 Z" fill={C.morado} stroke={C.linea} strokeWidth={6} strokeLinejoin="round" />
    <circle cx={0} cy={110} r={23} fill={C.moradoClaro} stroke={C.linea} strokeWidth={6} />
    <path d="M-8 122 L-8 130 M0 124 L0 133 M8 122 L8 130" stroke={C.linea} strokeWidth={3} strokeLinecap="round" />
    {children}
  </g>
);

export const Gato: React.FC<{ ancho: number }> = ({ ancho }) => {
  const frame = useCurrentFrame();
  const { i, id, local } = escenaEn(frame);
  let p = pose(id, local);
  // Transición suave desde la pose anterior.
  if (i > 0 && local < 20) {
    const previa = pose(IDS[i - 1], frame - INICIOS[i - 1]);
    const t = spring({ frame: local, fps: FPS, config: { damping: 15 } });
    p = mezclar(previa, p, Math.min(1, t));
  }

  const boca = aperturaBoca(frame);
  const respira = Math.sin(frame / 22);
  const parpa = parpadeo(frame);
  const colaOnda = Math.sin(frame / 14);
  const cascabel = Math.sin(frame / 7) * 12 + p.salto * 0.2;
  const asentir = boca * 2.5;

  const ancho_boca = 13 + 9 * boca;
  const alto_boca = 4 + 30 * boca;

  return (
    <svg width={ancho} height={ancho * (620 / 460)} viewBox="70 -20 460 620" style={{ overflow: "visible" }}>
      <defs>
        <clipPath id="ojoI">
          <ellipse cx={216} cy={221} rx={54} ry={45} />
        </clipPath>
        <clipPath id="ojoD">
          <ellipse cx={348} cy={222} rx={52} ry={44} />
        </clipPath>
        <linearGradient id="cuerpo" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#5d4891" />
          <stop offset="1" stopColor="#3f2f6c" />
        </linearGradient>
      </defs>
      {/* Sombra en el suelo */}
      <ellipse cx={280 + p.x} cy={596} rx={150 - p.salto * 0.8} ry={18} fill="#000" opacity={0.28} />
      <g transform={`translate(${p.x} ${-p.salto}) rotate(${p.inclinar} 280 580)`}>
        {/* Cola rayada */}
        <g>
          <path d={`M345 520 C420 530 ${455 + colaOnda * 12} 480 ${448 + colaOnda * 18} 420 C${445 + colaOnda * 22} 390 ${462 + colaOnda * 26} 370 ${480 + colaOnda * 28} 382`} stroke={C.linea} strokeWidth={38} fill="none" strokeLinecap="round" />
          <path d={`M345 520 C420 530 ${455 + colaOnda * 12} 480 ${448 + colaOnda * 18} 420 C${445 + colaOnda * 22} 390 ${462 + colaOnda * 26} 370 ${480 + colaOnda * 28} 382`} stroke={C.morado} strokeWidth={26} fill="none" strokeLinecap="round" />
          <path d={`M345 520 C420 530 ${455 + colaOnda * 12} 480 ${448 + colaOnda * 18} 420 C${445 + colaOnda * 22} 390 ${462 + colaOnda * 26} 370 ${480 + colaOnda * 28} 382`} stroke={C.linea} strokeWidth={26} fill="none" strokeDasharray="5 17" opacity={0.85} />
        </g>
        {/* Patas */}
        <ellipse cx={240} cy={575} rx={40} ry={21} fill={C.moradoClaro} stroke={C.linea} strokeWidth={6} />
        <ellipse cx={320} cy={575} rx={40} ry={21} fill={C.moradoClaro} stroke={C.linea} strokeWidth={6} />
        {/* Torso */}
        <g transform={`translate(280 560) scale(${1 + respira * 0.012} ${1 - respira * 0.012}) translate(-280 -560)`}>
          <path d="M235 316 C198 360 184 440 191 500 C197 556 250 574 280 574 C310 574 363 556 369 500 C376 440 362 360 325 316 Z" fill="url(#cuerpo)" stroke={C.linea} strokeWidth={6} />
          <ellipse cx={280} cy={478} rx={52} ry={66} fill="#7a66b8" opacity={0.45} />
          <path d="M252 560 L252 540 M308 560 L308 540" stroke={C.linea} strokeWidth={4} strokeLinecap="round" opacity={0.6} />
        </g>
        {/* Pañuelo y cascabel */}
        <path d="M206 318 L354 318 L292 398 Z" fill="#8b2332" stroke={C.linea} strokeWidth={5} strokeLinejoin="round" />
        <path d="M206 318 L170 300 L178 334 Z M206 318 L176 344 L200 352 Z" fill="#7a1d2b" stroke={C.linea} strokeWidth={4} strokeLinejoin="round" />
        <circle cx={208} cy={322} r={10} fill="#a12b3c" stroke={C.linea} strokeWidth={4} />
        <g transform={`rotate(${cascabel} 288 352)`}>
          <line x1={288} y1={340} x2={288} y2={354} stroke={C.linea} strokeWidth={4} />
          <circle cx={288} cy={370} r={16} fill="#e9b53b" stroke={C.linea} strokeWidth={4} />
          <path d="M281 368 C281 360 295 360 295 368 C295 376 284 376 284 369" stroke="#8a5a10" strokeWidth={3} fill="none" />
        </g>
        {/* Cabeza */}
        <g transform={`rotate(${p.cabeza + asentir * 0.4} 280 330) translate(0 ${-asentir})`}>
          <image href={CABEZA} x={100} y={10} width={370} height={322} />
          {/* Párpados */}
          {parpa > 0 ? (
            <>
              <g clipPath="url(#ojoI)">
                <rect x={150} y={170} width={140} height={100 * parpa} fill="#4f3c86" />
                <line x1={150} y1={170 + 100 * parpa} x2={290} y2={170 + 100 * parpa} stroke={C.linea} strokeWidth={5} />
              </g>
              <g clipPath="url(#ojoD)">
                <rect x={286} y={172} width={140} height={100 * parpa} fill="#4f3c86" />
                <line x1={286} y1={172 + 100 * parpa} x2={426} y2={172 + 100 * parpa} stroke={C.linea} strokeWidth={5} />
              </g>
            </>
          ) : null}
          {/* Boca animada */}
          {boca > 0.08 ? (
            <g>
              <path
                d={`M${280 - ancho_boca} 296 C${280 - ancho_boca} ${296 + alto_boca * 1.3} ${280 + ancho_boca} ${296 + alto_boca * 1.3} ${280 + ancho_boca} 296 Z`}
                fill="#2a0d1c"
                stroke={C.linea}
                strokeWidth={4}
                strokeLinejoin="round"
              />
              <ellipse cx={280} cy={296 + alto_boca * 0.82} rx={ancho_boca * 0.55} ry={Math.min(7, alto_boca * 0.3)} fill="#e0607e" />
            </g>
          ) : null}
          <path d="M250 290 Q265 306 280 294 Q295 306 310 290" stroke={C.linea} strokeWidth={5} fill="none" strokeLinecap="round" />
          {/* Sombrero pirata */}
          {p.sombrero > 0.01 ? (
            <g transform={`translate(280 70) scale(${p.sombrero}) rotate(${-8 + (1 - p.sombrero) * 30})`}>
              <path d="M-150 20 C-110 -50 -60 -80 0 -82 C60 -80 110 -50 150 20 C90 0 -90 0 -150 20 Z" fill="#14121c" stroke="#000" strokeWidth={5} />
              <path d="M-150 20 C-90 0 90 0 150 20" stroke={C.amarillo} strokeWidth={8} fill="none" />
              <circle cx={0} cy={-36} r={20} fill="#f1f1f1" />
              <rect x={-10} y={-22} width={20} height={10} rx={3} fill="#f1f1f1" />
              <circle cx={-7} cy={-38} r={5} fill="#14121c" />
              <circle cx={7} cy={-38} r={5} fill="#14121c" />
              <path d="M-26 -6 L26 6 M-26 6 L26 -6" stroke="#f1f1f1" strokeWidth={6} strokeLinecap="round" />
            </g>
          ) : null}
          {p.cascos > 0.01 ? (
            <g opacity={p.cascos}>
              <path d="M133 220 C120 -40 440 -40 427 220" stroke={C.linea} strokeWidth={30} fill="none" strokeLinecap="round" />
              <path d="M133 220 C120 -40 440 -40 427 220" stroke={C.rojo} strokeWidth={18} fill="none" strokeLinecap="round" />
              <rect x={108} y={200} width={50} height={90} rx={22} fill={C.rojo} stroke={C.linea} strokeWidth={6} />
              <rect x={402} y={200} width={50} height={90} rx={22} fill={C.rojo} stroke={C.linea} strokeWidth={6} />
            </g>
          ) : null}
        </g>
        {/* Brazos (encima del cuerpo) */}
        <Brazo x={228} y={368} angulo={p.brazoI}>
          {p.carta > 0.01 ? (
            <g opacity={p.carta} transform={`translate(0 120) rotate(${-p.brazoI + 8}) scale(${p.carta})`}>
              <rect x={-55} y={-120} width={110} height={140} rx={6} fill="#fdf6e3" stroke={C.linea} strokeWidth={5} />
              {[0, 1, 2, 3, 4].map((k) => (
                <line key={k} x1={-38} y1={-95 + k * 22} x2={38 - (k % 2) * 18} y2={-95 + k * 22} stroke="#9a8f7a" strokeWidth={5} strokeLinecap="round" />
              ))}
            </g>
          ) : null}
        </Brazo>
        <Brazo x={332} y={368} angulo={-p.brazoD} />
      </g>
    </svg>
  );
};

