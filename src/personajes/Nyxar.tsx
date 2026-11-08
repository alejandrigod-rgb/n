/**
 * Nyxar: el gato morado de AEZ (personaje original del usuario), dibujado en vector.
 * Coordenadas en un lienzo de 600×620 (la cabeza ocupa ~100-470 × 20-335).
 * El componente es "tonto": recibe la pose, la apertura de la boca y el fotograma,
 * y cada video decide cómo se mueve.
 */
import { random } from "remotion";
import { AGARRES, OBJETOS, TipoObjeto } from "./objetos";

export type PoseNyxar = {
  /** Ángulos de brazo: 0 = colgando, 90 = hacia fuera, 160 = arriba. Negativo = hacia dentro. */
  brazoI: number;
  brazoD: number;
  cabeza: number;
  inclinar: number;
  salto: number;
  x: number;
  /** Hacia dónde mira (-1 a 1). */
  mirarX: number;
  mirarY: number;
  sombrero: number;
  cascos: number;
  carta: number;
  /** 0-1: cuánto se ve el objeto que sostiene (aparece con un pop). */
  objeto: number;
};

export const POSE_BASE: PoseNyxar = {
  brazoI: 12,
  brazoD: 12,
  cabeza: 0,
  inclinar: 0,
  salto: 0,
  x: 0,
  mirarX: 0,
  mirarY: 0,
  sombrero: 0,
  cascos: 0,
  carta: 0,
  objeto: 0,
};

export const mezclarPoses = (a: PoseNyxar, b: PoseNyxar, t: number): PoseNyxar => {
  const r = { ...a };
  (Object.keys(a) as (keyof PoseNyxar)[]).forEach((k) => {
    r[k] = a[k] + (b[k] - a[k]) * t;
  });
  return r;
};

const LINEA = "#1d1530";
const PIEL = "#54418e";
const PIEL_CLARA = "#6d58a6";

const OJO_I = "M166 184 C200 182 240 200 262 228 C266 248 246 264 216 264 C186 264 166 246 164 220 C163 205 164 192 166 184 Z";
const OJO_D = "M398 186 C364 184 324 202 302 230 C298 250 318 265 348 265 C378 265 398 247 400 221 C401 206 400 193 398 186 Z";

/** Parpadeo cada 3-5 s (a 30 fps), con un patrón fijo y natural. */
export const parpadeoNyxar = (frame: number, fps = 30) => {
  const f = Math.round((frame * 30) / fps);
  const k = Math.floor(f / 110);
  for (const j of [k, k - 1]) {
    const inicio = j * 110 + Math.floor(random(`parpadeo-${j}`) * 70);
    const d = f - inicio;
    if (d >= 0 && d < 7) return [0.3, 0.8, 1, 1, 0.8, 0.4, 0][d];
  }
  return 0;
};

/** Pequeño tic de orejas de vez en cuando. */
const ticOreja = (frame: number, lado: string) => {
  const k = Math.floor(frame / 150);
  const inicio = k * 150 + Math.floor(random(`oreja-${lado}-${k}`) * 100);
  const d = frame - inicio;
  if (d < 0 || d > 10) return 0;
  return Math.sin((d / 10) * Math.PI) * 9;
};

/** Brazo con pata. `enMano` se dibuja entre el brazo y la pata, para que la pata lo agarre. */
const Brazo: React.FC<{
  x: number;
  y: number;
  angulo: number;
  children?: React.ReactNode;
  enMano?: React.ReactNode;
  /** "brazo" o "pata" dibujan solo esa parte (para meter un objeto entre ambas). */
  parte?: "todo" | "brazo" | "pata";
}> = ({ x, y, angulo, children, enMano, parte = "todo" }) => (
  <g transform={`translate(${x} ${y}) rotate(${angulo})`}>
    {parte !== "pata" ? (
      <path d="M-17 0 L-15 100 A16 16 0 0 0 15 100 L17 0 Z" fill={PIEL} stroke={LINEA} strokeWidth={6} strokeLinejoin="round" />
    ) : null}
    {enMano}
    {parte !== "brazo" ? (
      <>
        <circle cx={0} cy={110} r={23} fill={PIEL_CLARA} stroke={LINEA} strokeWidth={6} />
        <path d="M-8 122 L-8 130 M0 124 L0 133 M8 122 L8 130" stroke={LINEA} strokeWidth={3} strokeLinecap="round" />
      </>
    ) : null}
    {children}
  </g>
);

export type Expresion = "normal" | "feliz" | "sorprendido" | "enfadado" | "pensativo" | "guino" | "triste";
export const EXPRESIONES: Expresion[] = ["normal", "feliz", "sorprendido", "enfadado", "pensativo", "guino", "triste"];

/** Párpado inclinado (enfado o tristeza): tapa la parte del ojo por encima de la línea (x1,y1)-(x2,y2). */
const ParpadoInclinado: React.FC<{ x1: number; y1: number; x2: number; y2: number }> = ({ x1, y1, x2, y2 }) => (
  <>
    <polygon points={`${x1 - 20},150 ${x2 + 20},150 ${x2 + 20},${y2} ${x1 - 20},${y1}`} fill={PIEL} />
    <line x1={x1 - 20} y1={y1} x2={x2 + 20} y2={y2} stroke={LINEA} strokeWidth={6} />
  </>
);

/** Ojo cerrado contento: un arco "^". */
const OjoFeliz: React.FC<{ cx: number }> = ({ cx }) => (
  <path d={`M${cx - 42} 236 Q${cx} 196 ${cx + 42} 236`} stroke={LINEA} strokeWidth={8} fill="none" strokeLinecap="round" />
);

const Cabeza: React.FC<{
  frame: number;
  boca: number;
  parpadeo: number;
  mirarX: number;
  mirarY: number;
  id: string;
  expresion: Expresion;
}> = ({ frame, boca, parpadeo, mirarX, mirarY, id, expresion }) => {
  const anchoBoca = 13 + 9 * boca;
  const altoBoca = 4 + 30 * boca;
  const mx = expresion === "pensativo" ? -0.7 : mirarX;
  const my = expresion === "pensativo" ? -0.9 : expresion === "triste" ? 0.7 : mirarY;
  const px = mx * 9;
  const py = my * 7;
  const pupilaRy = expresion === "sorprendido" ? 11 : 25;
  const pupilaRx = expresion === "sorprendido" ? 9 : 8;
  const cerradoI = expresion === "feliz";
  const cerradoD = expresion === "feliz" || expresion === "guino";
  const lid = (y0: number) => (
    <>
      <rect x={140} y={y0} width={290} height={100 * parpadeo} fill={PIEL} />
      <rect x={140} y={y0 + 100 * parpadeo - 3} width={290} height={6} fill={LINEA} />
    </>
  );
  return (
    <g>
      <defs>
        <linearGradient id={`${id}-pelo`} x1="0" y1="0" x2="0.3" y2="1">
          <stop offset="0" stopColor="#6852ab" />
          <stop offset="0.55" stopColor="#54418e" />
          <stop offset="1" stopColor="#45347c" />
        </linearGradient>
        <radialGradient id={`${id}-rubor`} cx="0.5" cy="0.5" r="0.5">
          <stop offset="0" stopColor="#d06a9a" stopOpacity="0.35" />
          <stop offset="1" stopColor="#d06a9a" stopOpacity="0" />
        </radialGradient>
        <clipPath id={`${id}-ojoI`}>
          <path d={OJO_I} />
        </clipPath>
        <clipPath id={`${id}-ojoD`}>
          <path d={OJO_D} />
        </clipPath>
      </defs>
      {/* Orejas */}
      <g transform={`rotate(${-ticOreja(frame, "i")} 180 160)`}>
        <path d="M222 128 L124 58 L136 182 Z" fill={`url(#${id}-pelo)`} stroke={LINEA} strokeWidth={6} strokeLinejoin="round" />
        <path d="M196 124 L138 80 L146 160 Z" fill="#b8708a" />
      </g>
      <g transform={`rotate(${ticOreja(frame, "d")} 390 160)`}>
        <path d="M356 122 L418 62 L430 186 Z" fill={`url(#${id}-pelo)`} stroke={LINEA} strokeWidth={6} strokeLinejoin="round" />
        <path d="M374 120 L408 84 L416 160 Z" fill="#b8708a" />
      </g>
      {/* Cabeza con pelo de punta y mechones */}
      <path
        fill={`url(#${id}-pelo)`}
        stroke={LINEA}
        strokeWidth={6}
        strokeLinejoin="round"
        d="M196 128 L222 104 C240 80 262 45 286 22 C292 36 294 60 296 78 C312 60 332 46 358 38 C350 56 340 70 334 84 C352 90 372 104 386 124 C408 150 432 180 446 206 L466 222 L448 234 L472 256 L446 262 L460 290 L426 290 C410 302 390 314 360 320 L350 332 L330 324 C305 334 255 334 230 324 L210 332 L198 320 C170 314 150 302 134 290 L102 292 L118 266 L94 256 L120 240 L104 222 L128 208 C140 176 166 148 196 128 Z"
      />
      <ellipse cx={180} cy={276} rx={30} ry={16} fill={`url(#${id}-rubor)`} />
      <ellipse cx={388} cy={278} rx={30} ry={16} fill={`url(#${id}-rubor)`} />
      {/* Rizo */}
      <ellipse cx={352} cy={96} rx={28} ry={12} transform="rotate(14 352 96)" fill="#5c489c" stroke={LINEA} strokeWidth={5} />
      <path d="M332 92 C342 88 356 90 366 96" stroke="#ffffff" strokeOpacity={0.35} strokeWidth={3} fill="none" strokeLinecap="round" />
      {/* Rayas */}
      <g stroke={LINEA} strokeWidth={7} strokeLinecap="round" fill="none">
        <path d="M272 42 C270 70 268 92 266 116" />
        <path d="M314 62 C312 80 310 96 308 112" />
        <path d="M226 106 C232 112 236 118 240 126" />
      </g>
      {/* Brillos */}
      <g stroke="#ffffff" strokeOpacity={0.32} strokeWidth={4} strokeLinecap="round" fill="none">
        <path d="M250 70 C262 52 272 40 282 30" />
        <path d="M150 170 C160 156 172 146 186 136" />
        <path d="M110 254 L120 246" />
      </g>
      {/* Ojos con pupilas que miran y párpados que siguen su forma */}
      {cerradoI ? (
        <OjoFeliz cx={214} />
      ) : (
        <>
          <path d={OJO_I} fill="#fff" />
          <g clipPath={`url(#${id}-ojoI)`}>
            <ellipse cx={210 + px} cy={226 + py} rx={pupilaRx} ry={pupilaRy} fill="#1b2f7a" />
            <ellipse
              cx={207 + px}
              cy={(expresion === "sorprendido" ? 221 : 214) + py}
              rx={2.5}
              ry={expresion === "sorprendido" ? 3 : 6}
              fill="#fff"
              opacity={0.85}
            />
            {expresion === "enfadado" ? <ParpadoInclinado x1={166} y1={196} x2={264} y2={228} /> : null}
            {expresion === "triste" ? <ParpadoInclinado x1={166} y1={222} x2={264} y2={200} /> : null}
            {parpadeo > 0 ? lid(176) : null}
          </g>
          <path d={OJO_I} fill="none" stroke={LINEA} strokeWidth={6} strokeLinejoin="round" />
        </>
      )}
      {cerradoD ? (
        <OjoFeliz cx={350} />
      ) : (
        <>
          <path d={OJO_D} fill="#fff" />
          <g clipPath={`url(#${id}-ojoD)`}>
            <ellipse cx={352 + px} cy={226 + py} rx={pupilaRx} ry={pupilaRy} fill="#1b2f7a" />
            <ellipse
              cx={349 + px}
              cy={(expresion === "sorprendido" ? 221 : 214) + py}
              rx={2.5}
              ry={expresion === "sorprendido" ? 3 : 6}
              fill="#fff"
              opacity={0.85}
            />
            {expresion === "enfadado" ? <ParpadoInclinado x1={300} y1={230} x2={398} y2={198} /> : null}
            {expresion === "triste" ? <ParpadoInclinado x1={300} y1={202} x2={398} y2={224} /> : null}
            {parpadeo > 0 ? lid(178) : null}
          </g>
          <path d={OJO_D} fill="none" stroke={LINEA} strokeWidth={6} strokeLinejoin="round" />
        </>
      )}
      {/* Cejas (solo en algunas expresiones; Nyxar normalmente no tiene) */}
      <g stroke={LINEA} strokeWidth={9} strokeLinecap="round" fill="none">
        {expresion === "enfadado" ? (
          <>
            <path d="M170 172 L258 200" />
            <path d="M306 202 L394 174" />
          </>
        ) : null}
        {expresion === "sorprendido" ? (
          <>
            <path d="M176 164 Q214 144 254 162" />
            <path d="M310 164 Q350 144 388 164" />
          </>
        ) : null}
        {expresion === "triste" ? (
          <>
            <path d="M172 184 L256 168" />
            <path d="M308 168 L392 186" />
          </>
        ) : null}
        {expresion === "pensativo" ? (
          <>
            <path d="M176 178 L256 182" />
            <path d="M310 168 Q350 146 390 160" />
          </>
        ) : null}
      </g>
      {/* Nariz */}
      <path
        d="M266 268 C276 263 294 263 302 269 C298 278 286 282 279 285 C272 281 266 275 266 268 Z"
        fill="#1d3a7a"
        stroke="#0f1d44"
        strokeWidth={2}
      />
      {/* Boca: :3 cerrada, se abre al hablar */}
      {boca > 0.08 ? (
        <g>
          <path
            d={`M${280 - anchoBoca} 297 C${280 - anchoBoca} ${297 + altoBoca * 1.3} ${280 + anchoBoca} ${297 + altoBoca * 1.3} ${280 + anchoBoca} 297 Z`}
            fill="#2a0d1c"
            stroke={LINEA}
            strokeWidth={4}
            strokeLinejoin="round"
          />
          <ellipse cx={280} cy={297 + altoBoca * 0.82} rx={anchoBoca * 0.55} ry={Math.min(7, altoBoca * 0.3)} fill="#e0607e" />
        </g>
      ) : null}
      {boca <= 0.08 && expresion === "feliz" ? (
        <g>
          <path d="M246 292 Q280 338 314 292 Z" fill="#2a0d1c" stroke={LINEA} strokeWidth={4} strokeLinejoin="round" />
          <ellipse cx={280} cy={312} rx={14} ry={6} fill="#e0607e" />
        </g>
      ) : null}
      {boca <= 0.08 && expresion === "sorprendido" ? (
        <ellipse cx={280} cy={308} rx={11} ry={14} fill="#2a0d1c" stroke={LINEA} strokeWidth={4} />
      ) : null}
      {expresion === "enfadado" || expresion === "triste" ? (
        boca <= 0.08 ? (
          <path d="M248 308 Q280 288 312 308" stroke={LINEA} strokeWidth={5} fill="none" strokeLinecap="round" />
        ) : null
      ) : expresion === "pensativo" ? (
        boca <= 0.08 ? (
          <path d="M258 304 Q284 298 306 292" stroke={LINEA} strokeWidth={5} fill="none" strokeLinecap="round" />
        ) : null
      ) : expresion === "guino" ? (
        <path d="M236 290 Q260 312 282 296 Q306 314 330 284" stroke={LINEA} strokeWidth={5} fill="none" strokeLinecap="round" />
      ) : (
        <path d="M234 288 Q257 312 280 295 Q303 312 326 288" stroke={LINEA} strokeWidth={5} fill="none" strokeLinecap="round" />
      )}
      {/* Bigotes */}
      <g stroke={LINEA} strokeWidth={3} strokeLinecap="round">
        <line x1={196} y1={282} x2={236} y2={290} />
        <line x1={192} y1={296} x2={234} y2={298} />
        <line x1={200} y1={310} x2={236} y2={304} />
        <line x1={334} y1={298} x2={374} y2={294} />
        <line x1={336} y1={306} x2={378} y2={312} />
        <line x1={332} y1={314} x2={368} y2={326} />
      </g>
    </g>
  );
};

export const Nyxar: React.FC<{
  ancho: number;
  pose: PoseNyxar;
  /** Apertura de la boca, 0-1. */
  boca: number;
  frame: number;
  fps?: number;
  /** Identificador único si hay varios Nyxar en pantalla. */
  id?: string;
  /** Objeto relacionado con el tema que sostiene delante del pecho (portátil, móvil, mando...). */
  objeto?: TipoObjeto;
  /** Cara de Nyxar (por defecto "normal"). */
  expresion?: Expresion;
  /** Fuerza el parpadeo (0 abierto, 1 cerrado); si no, parpadea solo. */
  parpadeo?: number;
}> = ({ ancho, pose: entrada, boca, frame, fps = 30, id = "nyxar", objeto, expresion = "normal", parpadeo: parpadeoFijo }) => {
  const f = (frame * 30) / fps; // las oscilaciones van en tiempo, no en fotogramas
  // Con un objeto, los brazos, la mirada y la cabeza van hacia la postura de agarre.
  const agarre = objeto ? AGARRES[objeto] : null;
  const t = agarre ? Math.min(1, Math.max(0, entrada.objeto)) : 0;
  const mez = (a: number, b: number) => a + (b - a) * t;
  const p: PoseNyxar = agarre
    ? {
        ...entrada,
        brazoI: mez(entrada.brazoI, agarre.brazoI),
        brazoD: mez(entrada.brazoD, agarre.brazoD),
        mirarX: mez(entrada.mirarX, agarre.mirarX),
        mirarY: mez(entrada.mirarY, agarre.mirarY),
        cabeza: mez(entrada.cabeza, agarre.cabeza),
      }
    : entrada;
  const Obj = objeto ? OBJETOS[objeto] : null;
  const verObjeto = agarre && Obj && p.objeto > 0.01;
  const respira = Math.sin(f / 22);
  const colaOnda = Math.sin(f / 14);
  const cascabel = Math.sin(f / 7) * 12 + p.salto * 0.2;
  const asentir = boca * 2.5;
  const parpadeo = parpadeoFijo ?? parpadeoNyxar(frame, fps);
  const cola = `M345 520 C420 530 ${455 + colaOnda * 12} 480 ${448 + colaOnda * 18} 420 C${445 + colaOnda * 22} 390 ${462 + colaOnda * 26} 370 ${480 + colaOnda * 28} 382`;

  return (
    <svg width={ancho} height={ancho * (620 / 460)} viewBox="70 -20 460 620" style={{ overflow: "visible" }}>
      <defs>
        <linearGradient id={`${id}-cuerpo`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#5d4891" />
          <stop offset="1" stopColor="#3f2f6c" />
        </linearGradient>
      </defs>
      <ellipse cx={280 + p.x} cy={596} rx={150 - p.salto * 0.8} ry={18} fill="#000" opacity={0.28} />
      <g transform={`translate(${p.x} ${-p.salto}) rotate(${p.inclinar} 280 580)`}>
        {/* Cola rayada */}
        <path d={cola} stroke={LINEA} strokeWidth={38} fill="none" strokeLinecap="round" />
        <path d={cola} stroke={PIEL} strokeWidth={26} fill="none" strokeLinecap="round" />
        <path d={cola} stroke={LINEA} strokeWidth={26} fill="none" strokeDasharray="5 17" opacity={0.85} />
        {/* Patas */}
        <ellipse cx={240} cy={575} rx={40} ry={21} fill={PIEL_CLARA} stroke={LINEA} strokeWidth={6} />
        <ellipse cx={320} cy={575} rx={40} ry={21} fill={PIEL_CLARA} stroke={LINEA} strokeWidth={6} />
        {/* Torso */}
        <g transform={`translate(280 560) scale(${1 + respira * 0.012} ${1 - respira * 0.012}) translate(-280 -560)`}>
          <path
            d="M235 316 C198 360 184 440 191 500 C197 556 250 574 280 574 C310 574 363 556 369 500 C376 440 362 360 325 316 Z"
            fill={`url(#${id}-cuerpo)`}
            stroke={LINEA}
            strokeWidth={6}
          />
          <ellipse cx={280} cy={478} rx={52} ry={66} fill="#7a66b8" opacity={0.45} />
          <path d="M252 560 L252 540 M308 560 L308 540" stroke={LINEA} strokeWidth={4} strokeLinecap="round" opacity={0.6} />
        </g>
        {/* Pañuelo y cascabel */}
        <path d="M206 318 L354 318 L292 398 Z" fill="#8b2332" stroke={LINEA} strokeWidth={5} strokeLinejoin="round" />
        <path
          d="M206 318 L170 300 L178 334 Z M206 318 L176 344 L200 352 Z"
          fill="#7a1d2b"
          stroke={LINEA}
          strokeWidth={4}
          strokeLinejoin="round"
        />
        <circle cx={208} cy={322} r={10} fill="#a12b3c" stroke={LINEA} strokeWidth={4} />
        <g transform={`rotate(${cascabel} 288 352)`}>
          <line x1={288} y1={340} x2={288} y2={354} stroke={LINEA} strokeWidth={4} />
          <circle cx={288} cy={370} r={16} fill="#e9b53b" stroke={LINEA} strokeWidth={4} />
          <path d="M281 368 C281 360 295 360 295 368 C295 376 284 376 284 369" stroke="#8a5a10" strokeWidth={3} fill="none" />
        </g>
        {/* Cabeza y accesorios */}
        <g transform={`rotate(${p.cabeza + asentir * 0.4} 280 330) translate(0 ${-asentir})`}>
          <Cabeza frame={frame} boca={boca} parpadeo={parpadeo} mirarX={p.mirarX} mirarY={p.mirarY} id={id} expresion={expresion} />
          {p.sombrero > 0.01 ? (
            <g transform={`translate(280 70) scale(${p.sombrero}) rotate(${-8 + (1 - p.sombrero) * 30})`}>
              <path
                d="M-150 20 C-110 -50 -60 -80 0 -82 C60 -80 110 -50 150 20 C90 0 -90 0 -150 20 Z"
                fill="#14121c"
                stroke="#000"
                strokeWidth={5}
              />
              <path d="M-150 20 C-90 0 90 0 150 20" stroke="#ffd23f" strokeWidth={8} fill="none" />
              <circle cx={0} cy={-36} r={20} fill="#f1f1f1" />
              <rect x={-10} y={-22} width={20} height={10} rx={3} fill="#f1f1f1" />
              <circle cx={-7} cy={-38} r={5} fill="#14121c" />
              <circle cx={7} cy={-38} r={5} fill="#14121c" />
              <path d="M-26 -6 L26 6 M-26 6 L26 -6" stroke="#f1f1f1" strokeWidth={6} strokeLinecap="round" />
            </g>
          ) : null}
          {p.cascos > 0.01 ? (
            <g opacity={p.cascos}>
              <path d="M133 220 C120 -40 440 -40 427 220" stroke={LINEA} strokeWidth={30} fill="none" strokeLinecap="round" />
              <path d="M133 220 C120 -40 440 -40 427 220" stroke="#ff4d6d" strokeWidth={18} fill="none" strokeLinecap="round" />
              <rect x={108} y={200} width={50} height={90} rx={22} fill="#ff4d6d" stroke={LINEA} strokeWidth={6} />
              <rect x={402} y={200} width={50} height={90} rx={22} fill="#ff4d6d" stroke={LINEA} strokeWidth={6} />
            </g>
          ) : null}
        </g>
        {/* Brazos. Con un objeto de dos manos: brazos, luego el objeto y encima las patas que lo agarran. */}
        {verObjeto && agarre.manos === "dos" ? (
          <>
            <Brazo x={228} y={368} angulo={p.brazoI} parte="brazo" />
            <Brazo x={332} y={368} angulo={-p.brazoD} parte="brazo" />
            <g
              transform={`translate(${agarre.x} ${(agarre.y ?? 0) + Math.sin(f / 18) * 2}) scale(${agarre.escala * p.objeto}) rotate(${agarre.giro + (1 - p.objeto) * -20})`}
            >
              <Obj frame={f} />
            </g>
            <Brazo x={228} y={368} angulo={p.brazoI} parte="pata" />
            <Brazo x={332} y={368} angulo={-p.brazoD} parte="pata" />
          </>
        ) : null}
        {!(verObjeto && agarre.manos === "dos") ? (
          <>
            <Brazo x={228} y={368} angulo={p.brazoI}>
              {p.carta > 0.01 ? (
                <g opacity={p.carta} transform={`translate(0 120) rotate(${-p.brazoI + 8}) scale(${p.carta})`}>
                  <rect x={-55} y={-120} width={110} height={140} rx={6} fill="#fdf6e3" stroke={LINEA} strokeWidth={5} />
                  {[0, 1, 2, 3, 4].map((k) => (
                    <line
                      key={k}
                      x1={-38}
                      y1={-95 + k * 22}
                      x2={38 - (k % 2) * 18}
                      y2={-95 + k * 22}
                      stroke="#9a8f7a"
                      strokeWidth={5}
                      strokeLinecap="round"
                    />
                  ))}
                </g>
              ) : null}
            </Brazo>
            <Brazo
              x={332}
              y={368}
              angulo={-p.brazoD}
              enMano={
                verObjeto && agarre.manos === "derecha" ? (
                  <g
                    transform={`translate(0 110) rotate(${p.brazoD + agarre.giro}) translate(${agarre.dx ?? 0} ${agarre.dy ?? 0}) scale(${agarre.escala * p.objeto})`}
                  >
                    <Obj frame={f} />
                  </g>
                ) : null
              }
            />
          </>
        ) : null}
        {/* Objeto que aparece sobre la cabeza (la bombilla de la idea) */}
        {verObjeto && agarre.manos === "encima" ? (
          <g
            transform={`translate(${agarre.x} ${(agarre.y ?? 0) + Math.sin(f / 10) * 6}) scale(${agarre.escala * p.objeto}) rotate(${agarre.giro})`}
          >
            <Obj frame={f} />
          </g>
        ) : null}
      </g>
    </svg>
  );
};
