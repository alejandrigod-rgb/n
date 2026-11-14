/**
 * Versión inmersiva del video de la sartén (petición del usuario: "no hay movimiento, es todo quieto"):
 * una sola cocina con cámara viva (planos generales, primeros planos, se mete dentro de la sartén, sacudidas),
 * Nyxar solo en los planos generales y su pata morada haciendo las cosas en los primeros planos,
 * rebobinado para volver atrás y una foto real a pantalla completa en el "¡bum!". Sin títulos: solo subtítulos.
 */
import React from "react";
import { AbsoluteFill, Html5Audio, Img, interpolate, random, Sequence, spring, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { IcoBien, IcoHuella, IcoMal } from "../marca/iconos";
import { Pop, Rafaga, Respira, Sfx, Subtitulos } from "../marca/kit";
import { C, CLAMP, F, FPS } from "../marca/tema";
import { Nyxar, POSE_BASE, type Expresion, type PoseNyxar } from "../personajes/Nyxar";
import { Bote, CocinaNoche, Corte, Sarten, Vaso } from "./dibujos";
import { CARPETA, IdEscena, LINEA, TIEMPOS } from "./linea";

const L = "#1d1530";
const PIEL = "#54418e";
const PIEL_CLARA = "#6d58a6";

const mk = (id: IdEscena) => (w: string, def = 0) => {
  try {
    return LINEA.marcas(id)(w);
  } catch {
    return def;
  }
};
const S: React.FC<{ id: string; en: number; volumen?: number; dur?: number }> = (p) => <Sfx carpeta={CARPETA} {...p} />;

/* ---------- cámara ---------- */
type Cam = { x: number; y: number; s: number };
export const CAM = {
  general: { x: 540, y: 1000, s: 1 },
  sarten: { x: 380, y: 1060, s: 2.3 },
  sartenMuy: { x: 380, y: 1080, s: 3.4 },
  mando: { x: 440, y: 1300, s: 3.2 },
  fregadero: { x: 780, y: 1150, s: 2.2 },
  nyxar: { x: 760, y: 980, s: 1.7 },
} satisfies Record<string, Cam>;

/** Mueve la cámara entre planos en los fotogramas dados (con muelle). `cortes`: [fotograma, plano]. */
export const camara = (f: number, cortes: [number, Cam][], suave = true): Cam => {
  let c = cortes[0][1];
  for (let i = 1; i < cortes.length; i++) {
    const [en, dest] = cortes[i];
    if (f < en) break;
    const t = suave ? spring({ frame: f - en, fps: FPS, config: { damping: 18, mass: 0.9 } }) : 1;
    c = { x: c.x + (dest.x - c.x) * t, y: c.y + (dest.y - c.y) * t, s: c.s + (dest.s - c.s) * t };
  }
  return c;
};

/** Sacudida de cámara (px) con fuerza 0-1. */
const sacudida = (f: number, fuerza: number) => ({ x: Math.sin(f * 2.7) * 18 * fuerza + Math.sin(f * 7.1) * 8 * fuerza, y: Math.cos(f * 3.3) * 14 * fuerza });

const Camara: React.FC<{ cam: Cam; temblor?: number; children: React.ReactNode }> = ({ cam, temblor = 0, children }) => {
  const f = useCurrentFrame();
  const sh = sacudida(f, temblor);
  // deriva lenta: la cámara nunca está quieta
  const dx = Math.sin(f / 70) * 6,
    dy = Math.cos(f / 90) * 5;
  return (
    <AbsoluteFill style={{ overflow: "hidden" }}>
      <AbsoluteFill style={{ transformOrigin: "0 0", transform: `translate(${540 + sh.x + dx}px, ${960 + sh.y + dy}px) scale(${cam.s}) translate(${-cam.x}px, ${-cam.y}px)` }}>{children}</AbsoluteFill>
    </AbsoluteFill>
  );
};

/* ---------- la pata de Nyxar (para los primeros planos) ---------- */
/** Brazo morado con rayas que entra desde fuera de plano; la mano queda en (x, y) y lleva lo que sostiene. */
export const Pata: React.FC<{ x: number; y: number; giro?: number; desde?: "derecha" | "abajo"; largo?: number; children?: React.ReactNode }> = ({ x, y, giro = 0, desde = "derecha", largo = 900, children }) => {
  const ang = desde === "derecha" ? 0 : -90;
  return (
    <div style={{ position: "absolute", left: x, top: y, transform: `rotate(${giro}deg)`, transformOrigin: "0 0" }}>
      <svg width={largo + 120} height={200} viewBox={`-60 -100 ${largo + 120} 200`} style={{ position: "absolute", left: -60, top: -100, overflow: "visible", transform: `rotate(${ang}deg)`, transformOrigin: "60px 100px" }}>
        <path d={`M0 -46 L${largo} -60 L${largo} 60 L0 46 Z`} fill={PIEL} stroke={L} strokeWidth={10} strokeLinejoin="round" />
        {[120, 230, 340, 450].map((k) => (
          <path key={k} d={`M${k} -50 q14 50 0 100`} fill="none" stroke={PIEL_CLARA} strokeWidth={14} />
        ))}
        <ellipse cx={-6} cy={0} rx={62} ry={56} fill={PIEL} stroke={L} strokeWidth={10} />
        {[-34, -6, 22].map((dy, k) => (
          <ellipse key={k} cx={-46} cy={dy} rx={14} ry={11} fill="#f2a6c0" />
        ))}
      </svg>
      {children ? <div style={{ position: "absolute", left: 0, top: 0 }}>{children}</div> : null}
    </div>
  );
};

/* ---------- el mundo: la cocina con el fogón, la sartén, el mando, el fregadero y Nyxar detrás de la encimera ---------- */
const Fregadero: React.FC<{ chorro?: boolean; f: number }> = ({ chorro, f }) => (
  <svg width={300} height={300} viewBox="0 0 300 300" style={{ position: "absolute", left: 640, top: 950, overflow: "visible" }}>
    <path d="M190 40 V10 Q190 -10 160 -10 H120" fill="none" stroke="#9aa6b8" strokeWidth={18} strokeLinecap="round" />
    {chorro ? <rect x={110} y={-4} width={16} height={250} fill="#7fc8ff" opacity={0.8 + 0.2 * Math.sin(f)} /> : null}
    <path d="M20 250 L280 250 L260 300 L40 300 Z" fill="#c9d3e0" stroke={L} strokeWidth={10} />
    <rect x={40} y={244} width={220} height={16} rx={8} fill="#7f8ba0" />
  </svg>
);

const Mando: React.FC<{ giro: number }> = ({ giro }) => (
  <svg width={120} height={120} viewBox="-60 -60 120 120" style={{ position: "absolute", left: 380, top: 1240, overflow: "visible" }}>
    <circle r={50} fill="#2b2f45" stroke={L} strokeWidth={8} />
    <g transform={`rotate(${giro})`}>
      <rect x={-12} y={-46} width={24} height={92} rx={10} fill="#d8dfe8" stroke={L} strokeWidth={6} />
      <circle cy={-34} r={6} fill={C.panuelo} />
    </g>
  </svg>
);

type EstadoMundo = {
  llamas: number;
  tapa?: number;
  humo?: number;
  quemador?: number;
  mando?: number;
  chorro?: boolean;
  nyxar?: { pose: PoseNyxar; expresion: Expresion } | null;
  f: number;
};

export const Mundo: React.FC<EstadoMundo> = ({ llamas, tapa = 0, humo = 0, quemador = 1, mando = 0, chorro, nyxar, f }) => {
  const s = f / FPS;
  return (
    <AbsoluteFill style={{ width: 1080, height: 1920 }}>
      <CocinaNoche s={s} />
      <AbsoluteFill style={{ background: "rgba(2,8,20,0.22)" }} />
      {/* luz del fuego en la pared */}
      <div style={{ position: "absolute", left: 0, top: 500, width: 900, height: 900, borderRadius: "50%", background: `radial-gradient(circle, ${C.cascabel}66 0%, transparent 65%)`, opacity: llamas * (0.7 + 0.3 * Math.sin(s * 11) * Math.sin(s * 6.3)), mixBlendMode: "screen" }} />
      {/* Nyxar detrás de la encimera (solo en los planos generales) */}
      {nyxar ? (
        <div style={{ position: "absolute", left: 590, top: 690 }}>
          <Nyxar ancho={430} pose={nyxar.pose} boca={LINEA.aperturaBoca(f)} frame={f} fps={FPS} expresion={nyxar.expresion} />
        </div>
      ) : null}
      {/* encimera de delante y muebles */}
      <svg width={1080} height={700} viewBox="0 0 1080 700" style={{ position: "absolute", left: 0, top: 1220 }}>
        <rect x={-10} y={20} width={1100} height={64} fill="#2c4478" stroke={L} strokeWidth={10} />
        <rect x={-10} y={84} width={1100} height={640} fill="#14244f" stroke={L} strokeWidth={10} />
        {[0, 1, 2, 3].map((k) => (
          <rect key={k} x={20 + k * 265} y={120} width={245} height={300} rx={10} fill="#1b2f5c" stroke={L} strokeWidth={6} />
        ))}
        {/* placa del fogón */}
        <rect x={150} y={8} width={440} height={30} rx={8} fill="#1b1e2d" stroke={L} strokeWidth={8} />
      </svg>
      <Fregadero chorro={chorro} f={f} />
      <Mando giro={mando} />
      {/* sartén sobre el fuego */}
      <div style={{ position: "absolute", left: 155, top: 870 }}>
        <Sarten s={s} llamas={llamas} tapa={tapa} humo={humo} ancho={520} />
      </div>
      {quemador > 0 ? <div style={{ position: "absolute", left: 230, top: 1218, width: 300, height: 16, borderRadius: 8, background: C.menta, opacity: quemador * (0.5 + 0.2 * Math.sin(s * 14)), boxShadow: `0 0 30px ${C.menta}` }} /> : null}
    </AbsoluteFill>
  );
};

const pose = (p: Partial<PoseNyxar>): PoseNyxar => ({ ...POSE_BASE, ...p });

/* ---------- efectos de montaje ---------- */
/** Pausa con el mundo en gris, barras de pausa y la X roja. */
const Pausa: React.FC<{ f: number }> = ({ f }) =>
  f < 0 ? null : (
    <AbsoluteFill style={{ pointerEvents: "none" }}>
      <AbsoluteFill style={{ background: C.panuelo, opacity: interpolate(f, [0, 3, 10], [0.6, 0.35, 0.18], CLAMP) }} />
      <div style={{ position: "absolute", left: 70, top: 520, display: "flex", gap: 16, opacity: Math.floor(f / 15) % 2 ? 0.4 : 1 }}>
        <div style={{ width: 34, height: 110, background: C.hueso, borderRadius: 8 }} />
        <div style={{ width: 34, height: 110, background: C.hueso, borderRadius: 8 }} />
      </div>
      <div style={{ position: "absolute", left: 540, top: 1000, transform: `translate(-50%,-50%) scale(${spring({ frame: f, fps: FPS, config: { damping: 9 } })})` }}>
        <IcoMal tamano={420} />
      </div>
    </AbsoluteFill>
  );

/** Rebobinado de vídeo: rayas horizontales, temblor y el símbolo de rebobinar dibujado. */
const Rebobina: React.FC<{ f: number; dura: number }> = ({ f, dura }) =>
  f < 0 || f > dura ? null : (
    <AbsoluteFill style={{ pointerEvents: "none" }}>
      {Array.from({ length: 14 }, (_, i) => (
        <div key={i} style={{ position: "absolute", left: 0, right: 0, top: ((random(`r${i}`) * 1920 + f * 90) % 1920) - 40, height: 10 + random(`rh${i}`) * 30, background: "#ffffff", opacity: 0.18 }} />
      ))}
      <svg width={220} height={120} viewBox="0 0 220 120" style={{ position: "absolute", left: 70, top: 520 }}>
        <path d="M110 10 L10 60 L110 110 Z M210 10 L110 60 L210 110 Z" fill={C.hueso} />
      </svg>
      <div style={{ position: "absolute", left: 320, top: 548, fontFamily: F.cifra, fontWeight: 700, fontSize: 60, color: C.hueso }}>REBOBINA</div>
    </AbsoluteFill>
  );

const Destello: React.FC<{ f: number; color?: string }> = ({ f, color = "#ffffff" }) => (f < 0 || f > 14 ? null : <AbsoluteFill style={{ background: color, opacity: interpolate(f, [0, 2, 14], [0, 1, 0], CLAMP) }} />);

const Sello: React.FC<{ f: number; texto: string; y?: number; color?: string }> = ({ f, texto, y = 700, color = C.panuelo }) =>
  f < 0 ? null : (
    <div style={{ position: "absolute", left: 540, top: y, transform: `translate(-50%,-50%) rotate(-8deg) scale(${interpolate(f, [0, 5, 9], [2.6, 0.92, 1], CLAMP)})`, background: color, border: `6px solid ${C.hueso}`, borderRadius: 26, padding: "10px 34px 4px", display: "flex", alignItems: "center", gap: 16, boxShadow: `0 0 40px ${color}` }}>
      <IcoMal tamano={70} color={C.abismo} />
      <span style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 76, color: C.hueso, whiteSpace: "nowrap" }}>{texto}</span>
    </div>
  );

/** Envoltorio de cada toma: la imagen, los subtítulos arriba y la voz. */
const Toma: React.FC<{ id: IdEscena; claves: string[]; children: React.ReactNode }> = ({ id, claves, children }) => {
  const pre = LINEA.preDe(id);
  return (
    <AbsoluteFill>
      {children}
      <Subtitulos palabras={TIEMPOS.voz[id].palabras} pre={pre} claves={claves} />
      <Sequence from={pre} layout="none">
        <Html5Audio src={staticFile(`${CARPETA}/voz-${id}.mp3`)} volume={1} />
      </Sequence>
    </AbsoluteFill>
  );
};

/* =================== LAS TOMAS =================== */

/* 1 · Primer plano de la sartén ardiendo y la cámara se aleja: Nyxar, aterrado */
export const Gancho: React.FC = () => {
  const f = useCurrentFrame();
  const m = mk("gancho");
  const atras = Math.max(18, m("fuego", 50) - 4);
  const cam = camara(f, [
    [0, { x: 380, y: 1050, s: 2.6 }],
    [atras, CAM.general],
  ]);
  const s = f / FPS;
  return (
    <Toma id="gancho" claves={["fuego"]}>
      <Camara cam={cam} temblor={f < atras ? 0.6 : 0.15}>
        <Mundo f={f} llamas={1} nyxar={{ pose: pose({ brazoI: 150 + 10 * Math.sin(s * 9), brazoD: 150 - 10 * Math.sin(s * 9), mirarX: -0.8, mirarY: 0.2, salto: f > atras ? Math.abs(Math.sin(s * 8)) * 30 : 0 }), expresion: "sorprendido" }} />
      </Camara>
      <div style={{ position: "absolute", left: 540, top: 1440, transform: `translateX(-50%) rotate(-5deg) scale(${1 + 0.04 * Math.sin(s * 7)})` }}>
        <div style={{ background: C.panuelo, borderRadius: 999, padding: "10px 36px 4px", display: "flex", alignItems: "center", gap: 14, boxShadow: `0 0 40px ${C.panuelo}` }}>
          <IcoMal tamano={64} color={C.abismo} />
          <span style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 80, color: C.hueso, whiteSpace: "nowrap" }}>NUNCA AGUA</span>
        </div>
      </div>
      <S id="golpe" en={0} volumen={0.5} />
      <S id="cascabel" en={2} volumen={0.4} />
      <S id="whoosh" en={atras} volumen={0.3} />
    </Toma>
  );
};

/* 2 · La pata llena un vaso en el fregadero, corre a la sartén… ¡PAUSA! */
export const Instinto: React.FC = () => {
  const f = useCurrentFrame();
  const m = mk("instinto");
  const corre = m("y", 90);
  const no = m("no", 150);
  const cam = camara(f, [
    [0, CAM.fregadero],
    [corre, CAM.sarten],
  ]);
  const pausa = f >= no;
  const fr = pausa ? no : f;
  const giro = interpolate(fr, [corre + 10, no], [0, -55], CLAMP);
  return (
    <Toma id="instinto" claves={["agua", "no"]}>
      <AbsoluteFill style={{ filter: pausa ? "grayscale(1) brightness(0.7)" : undefined }}>
        <Camara cam={cam} temblor={pausa ? 0 : f >= corre ? 0.35 : 0.05}>
          <Mundo f={fr} llamas={1} chorro={fr < corre} />
          {fr < corre ? (
            <Pata x={770} y={1110} giro={-8}>
              <div style={{ position: "absolute", left: -90, top: -150 }}>
                <Vaso tamano={140} />
              </div>
            </Pata>
          ) : (
            <Pata x={540 + interpolate(fr, [corre, corre + 14], [200, 0], CLAMP)} y={900} giro={-14}>
              <div style={{ position: "absolute", left: -110, top: -170 }}>
                <Vaso tamano={150} giro={giro} />
              </div>
            </Pata>
          )}
        </Camara>
      </AbsoluteFill>
      <Pausa f={f - no} />
      <S id="clic" en={6} volumen={0.3} />
      <S id="whoosh" en={corre} volumen={0.3} />
      <S id="error" en={no} volumen={0.5} />
      <S id="golpe" en={no} volumen={0.4} />
    </Toma>
  );
};

/* 3 · La cámara se mete DENTRO de la sartén: el agua se hunde bajo el aceite */
export const Hunde: React.FC = () => {
  const f = useCurrentFrame();
  const m = mk("hunde");
  const dentro = 22;
  const zoom = interpolate(f, [0, dentro], [2.3, 9], { ...CLAMP, easing: (x) => x * x });
  const g = interpolate(f, [m("pesa", 30), m("fondo", 120) + 10], [0, 1], CLAMP);
  const bajar = interpolate(g, [0, 1], [-120, 160]);
  return (
    <Toma id="hunde" claves={["pesa", "fondo"]}>
      {f < dentro ? (
        <Camara cam={{ x: 380, y: 1090, s: zoom }}>
          <Mundo f={f} llamas={1} />
        </Camara>
      ) : (
        <AbsoluteFill style={{ background: "#3a2410" }}>
          <div style={{ position: "absolute", left: 540, top: 1000, transform: `translate(-50%, -50%) translateY(${-bajar}px) scale(${interpolate(f, [dentro, dentro + 20], [1.8, 1.3], CLAMP)})` }}>
            <Corte s={f / FPS} gotas={g} vapor={0} llamas={0.5} />
            <Pop desde={m("aceite", 60)} style={{ position: "absolute", left: 300, top: 330 }}>
              <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 40, color: C.abismo, background: C.cascabel, padding: "6px 22px 0", borderRadius: 999 }}>ACEITE</div>
            </Pop>
            <Pop desde={m("agua", 30)} style={{ position: "absolute", left: 620, top: 60 }}>
              <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 40, color: C.abismo, background: "#7fc8ff", padding: "6px 22px 0", borderRadius: 999 }}>AGUA</div>
            </Pop>
          </div>
        </AbsoluteFill>
      )}
      <Destello f={f - dentro + 2} color="#ffcf5a" />
      <S id="whoosh" en={0} volumen={0.4} />
      <S id="pop" en={m("fondo", 120)} volumen={0.3} />
    </Toma>
  );
};

/* 4 · Dentro: el agua hierve de golpe y todo tiembla cada vez más */
export const Hierve: React.FC = () => {
  const f = useCurrentFrame();
  const m = mk("hierve");
  const golpe = m("golpe", 90);
  const v = interpolate(f, [golpe - 6, golpe + 30], [0, 1], CLAMP);
  const tiembla = interpolate(f, [m("grados", 30), golpe + 30], [0.05, 1], CLAMP);
  const sh = sacudida(f, tiembla);
  return (
    <Toma id="hierve" claves={["grados", "golpe"]}>
      <AbsoluteFill style={{ background: "#3a2410" }}>
        <div style={{ position: "absolute", left: 540 + sh.x, top: 1000 + sh.y, transform: `translate(-50%, -50%) translateY(-160px) scale(${1.3 + v * 0.25})` }}>
          <Corte s={f / FPS} gotas={1} vapor={v} llamas={0.6 + v * 0.4} />
          <Pop desde={m("grados", 30)} style={{ position: "absolute", left: 230, top: -130 }}>
            <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 46, color: C.hueso, background: C.panuelo, padding: "8px 24px 2px", borderRadius: 999, whiteSpace: "nowrap" }}>CIENTOS DE GRADOS</div>
          </Pop>
        </div>
      </AbsoluteFill>
      <S id="tic" en={m("grados", 30)} volumen={0.3} />
      <S id="subida" en={golpe - 6} volumen={0.4} />
    </Toma>
  );
};

/* 5 · ¡BUM!: foto real a pantalla completa (dominio público), sacudida y ráfaga */
const FotoCompleta: React.FC<{ src: string; f: number }> = ({ src, f }) => (
  <AbsoluteFill style={{ overflow: "hidden" }}>
    <Img src={staticFile(`${CARPETA}/${src}`)} style={{ position: "absolute", left: "50%", top: "50%", height: 1920, width: "auto", minWidth: 1080, objectFit: "cover", transform: `translate(-50%,-50%) scale(${1.15 + f * 0.004})` }} />
    <AbsoluteFill style={{ background: "radial-gradient(circle at 50% 50%, transparent 40%, rgba(2,8,20,0.6) 100%)" }} />
  </AbsoluteFill>
);
export const Bola: React.FC = () => {
  const f = useCurrentFrame();
  const m = mk("bola");
  const fuego = m("fuego", 200);
  const sh = sacudida(f, interpolate(f, [0, 30, fuego, fuego + 40], [1, 0.4, 1, 0.3], CLAMP));
  return (
    <Toma id="bola" claves={["vapor", "fuego"]}>
      <AbsoluteFill style={{ transform: `translate(${sh.x}px, ${sh.y}px)` }}>{f < fuego ? <FotoCompleta src="img-99ec5f66.jpg" f={f} /> : <FotoCompleta src="img-958efea7.jpg" f={f - fuego} />}</AbsoluteFill>
      <div style={{ position: "absolute", left: 60, top: 520 }}>
        <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 40, color: C.abismo, background: C.cascabel, padding: "8px 24px 2px", borderRadius: 999 }}>FOTO REAL · DEMOSTRACIÓN</div>
      </div>
      <Destello f={f} />
      <Destello f={f - fuego} color="#ffcf5a" />
      <Rafaga en={fuego} color={C.cascabel} tamano={1000} />
      <S id="fogonazo" en={0} volumen={0.55} />
      <S id="golpe" en={0} volumen={0.5} />
      <S id="fogonazo" en={fuego} volumen={0.45} />
    </Toma>
  );
};

/* 6 · REBOBINA. Plano general → la pata apaga el mando → la pata pone la tapa */
export const Tapa: React.FC = () => {
  const f = useCurrentFrame();
  const m = mk("tapa");
  const apaga = m("apaga", 40);
  const tapaF = m("tapa", 80);
  const cam = camara(f, [
    [0, CAM.general],
    [apaga - 8, CAM.mando],
    [tapaF - 10, CAM.sarten],
  ]);
  const mando = interpolate(f, [apaga, apaga + 14], [0, -90], CLAMP);
  const tapa = interpolate(f, [tapaF - 4, tapaF + 18], [0, 1], { ...CLAMP, easing: (x) => 1 - (1 - x) ** 3 });
  const llamas = interpolate(f, [tapaF + 14, tapaF + 40], [1, 0], CLAMP);
  const s = f / FPS;
  return (
    <Toma id="tapa" claves={["apaga", "metal"]}>
      <Camara cam={cam} temblor={0.05}>
        <Mundo f={f} llamas={llamas} tapa={tapa} humo={1 - llamas} quemador={f < apaga + 10 ? 1 : 0} mando={mando} nyxar={f < apaga - 8 ? { pose: pose({ brazoD: 120 + 8 * Math.sin(s * 5), mirarX: -0.7 }), expresion: "pensativo" } : null} />
        {f >= apaga - 8 && f < tapaF - 10 ? <Pata x={470} y={1300} giro={-20} /> : null}
        {f >= tapaF - 10 ? <Pata x={interpolate(f, [tapaF - 10, tapaF + 18], [760, 640], CLAMP)} y={interpolate(f, [tapaF - 10, tapaF + 18], [820, 980], CLAMP)} giro={-30} /> : null}
      </Camara>
      <Rebobina f={f} dura={18} />
      <Pop desde={apaga + 6} hasta={tapaF - 10} style={{ position: "absolute", left: 60, top: 520 }}>
        <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 52, color: C.abismo, background: C.menta, padding: "8px 28px 2px", borderRadius: 999 }}>1 · APAGA EL FUEGO</div>
      </Pop>
      <Pop desde={m("metal", 130)} style={{ position: "absolute", left: 60, top: 520 }}>
        <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 52, color: C.abismo, background: C.menta, padding: "8px 28px 2px", borderRadius: 999, display: "flex", gap: 12, alignItems: "center" }}>
          <IcoBien tamano={54} color={C.hueso} /> 2 · TAPA DE METAL
        </div>
      </Pop>
      <S id="glitch" en={0} volumen={0.3} />
      <S id="clic" en={apaga} volumen={0.5} />
      <S id="golpe" en={tapaF + 16} volumen={0.45} />
      <S id="brillo" en={m("metal", 130)} volumen={0.3} />
    </Toma>
  );
};

/* 7 · Sin aire se ahoga; la pata va a coger el mango → NO; la cámara mira al fregadero → NI AHÍ */
export const Aire: React.FC = () => {
  const f = useCurrentFrame();
  const m = mk("aire");
  const muevas = m("muevas", 90);
  const freg = m("fregadero", 140);
  const cam = camara(f, [
    [0, CAM.sarten],
    [muevas - 14, { x: 520, y: 1080, s: 1.9 }],
    [freg - 6, CAM.fregadero],
  ]);
  return (
    <Toma id="aire" claves={["ahoga", "muevas"]}>
      <Camara cam={cam} temblor={0.05}>
        <Mundo f={f} llamas={0} tapa={1} humo={0.8} quemador={0} mando={-90} />
        {f >= muevas - 14 && f < freg - 6 ? <Pata x={interpolate(f, [muevas - 14, muevas], [860, 720], CLAMP)} y={1150} giro={-6} /> : null}
      </Camara>
      <Sello f={f - muevas} texto="NO LA MUEVAS" y={760} />
      <Sello f={f - freg} texto="NI AL FREGADERO" y={900} />
      <S id="whoosh" en={muevas - 14} volumen={0.25} />
      <S id="error" en={muevas} volumen={0.4} />
      <S id="error" en={freg} volumen={0.4} />
    </Toma>
  );
};

/* 8 · Fuego pequeño: la pata echa bicarbonato y se apaga; la harina, con su X */
export const Bicarbonato: React.FC = () => {
  const f = useCurrentFrame();
  const m = mk("bicarbonato");
  const bic = m("bicarbonato", 60);
  const har = m("harina", 130);
  const llamas = interpolate(f, [bic + 6, bic + 40], [0.4, 0], CLAMP);
  const s = f / FPS;
  return (
    <Toma id="bicarbonato" claves={["pequeno", "bicarbonato", "harina"]}>
      <Camara cam={{ x: 400, y: 1040, s: interpolate(f, [0, 60], [2.6, 2.3], CLAMP) }} temblor={0.04}>
        <Mundo f={f} llamas={llamas} quemador={0} mando={-90} />
        {f >= bic - 20 ? (
          <Pata x={interpolate(f, [bic - 20, bic], [820, 600], CLAMP)} y={860} giro={-40 + Math.sin(s * 20) * (f > bic ? 6 : 0)}>
            <div style={{ position: "absolute", left: -120, top: -200, transform: "rotate(140deg)" }}>
              <Bote texto="BICARBONATO" color="#2f8a64" tamano={150} />
            </div>
          </Pata>
        ) : null}
        {/* polvo blanco que cae */}
        {f > bic
          ? Array.from({ length: 30 }, (_, i) => {
              const t = ((f - bic) * (3 + random(`p${i}`) * 3) + random(`q${i}`) * 200) % 220;
              return <div key={i} style={{ position: "absolute", left: 380 + random(`x${i}`) * 160, top: 880 + t, width: 8, height: 8, borderRadius: 4, background: "#f1f5ff", opacity: 0.9 }} />;
            })
          : null}
      </Camara>
      <Pop desde={har} giro={8} style={{ position: "absolute", left: 640, top: 540 }}>
        <div style={{ position: "relative" }}>
          <Bote texto="HARINA" color={C.panuelo} tamano={220} />
          <div style={{ position: "absolute", right: -40, top: -20 }}>
            <IcoMal tamano={130} />
          </div>
        </div>
      </Pop>
      <S id="pop" en={bic - 20} volumen={0.3} />
      <S id="exito" en={bic + 30} volumen={0.3} />
      <S id="error" en={har} volumen={0.4} />
    </Toma>
  );
};

/* 9 · Plano general con todo apagado: Nyxar aliviado, la pregunta y la firma */
export const Pregunta: React.FC = () => {
  const f = useCurrentFrame();
  const m = mk("pregunta");
  const { fps } = useVideoConfig();
  const firma = m("casa", 150) + Math.round(fps * 0.5);
  const s = f / FPS;
  const cam = camara(f, [
    [0, CAM.nyxar],
    [m("agua", 40), { x: 600, y: 1000, s: 1.15 }],
  ]);
  return (
    <Toma id="pregunta" claves={["agua", "casa"]}>
      <Camara cam={cam} temblor={0.03}>
        <Mundo f={f} llamas={0} tapa={1} humo={0.3} quemador={0} mando={-90} nyxar={{ pose: pose({ brazoD: 150 + 22 * Math.sin(s * 9), brazoI: 18, cabeza: 6 * Math.sin(s * 2.6) }), expresion: "guino" }} />
      </Camara>
      <div style={{ position: "absolute", left: 0, right: 0, top: 520, display: "flex", flexDirection: "column", alignItems: "center", gap: 30 }}>
        <div style={{ display: "flex", gap: 34 }}>
          {[
            { t: "SÍ, AGUA", i: <IcoMal tamano={80} color={C.abismo} />, c: C.panuelo, txt: C.hueso },
            { t: "NI DE BROMA", i: <IcoBien tamano={80} color={C.hueso} />, c: C.menta, txt: C.abismo },
          ].map((b, k) => (
            <Pop key={b.t} desde={m("agua", 40) + k * 8} giro={k ? 8 : -8}>
              <Respira fase={k * 1.5} amp={0.05}>
                <div style={{ width: 300, height: 210, borderRadius: 40, background: b.c, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 8, fontFamily: F.titulo, fontWeight: 800, fontSize: 48, lineHeight: 1, textAlign: "center", color: b.txt, boxShadow: `0 0 40px ${b.c}88` }}>
                  {b.i}
                  {b.t}
                </div>
              </Respira>
            </Pop>
          ))}
        </div>
        <Pop desde={firma}>
          <div style={{ display: "flex", alignItems: "center", gap: 16, fontFamily: F.cifra, fontWeight: 700, fontSize: 40, color: C.hueso, background: "rgba(2,8,20,0.7)", padding: "8px 24px", borderRadius: 999 }}>
            <span style={{ width: 36, height: 36, borderRadius: 18, background: C.pelaje, border: `3px solid ${C.hueso}`, display: "inline-block" }} />
            @ithnoir · comenta <IcoHuella tamano={56} />
          </div>
        </Pop>
      </div>
      <S id="pop" en={m("agua", 40)} volumen={0.3} />
      <S id="cascabel" en={firma} volumen={0.45} />
    </Toma>
  );
};

export const TOMAS = [Gancho, Instinto, Hunde, Hierve, Bola, Tapa, Aire, Bicarbonato, Pregunta];
