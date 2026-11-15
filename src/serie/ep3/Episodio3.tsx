/**
 * Serie de Marco (cuenta Marcoglowup, no AEZ) · Episodio 3: ganó GIMNASIO (83 %, 36 votos). Con humor.
 * Reglas del usuario (las del video del Test Epigenético): títulos que entran desde la izquierda con ease-in-out y estela,
 * textos revelados con máscara, máx. 4 palabras por escena aparte de los subtítulos, analogías literales ("salió volando",
 * "arrastrándose", "le duele hasta el pelo"), magnitudes con escala (20 kg contra 200 kg), cámara que sigue la acción,
 * objetos que se transforman para abrir la siguiente escena y cada acción en su palabra.
 */
import React from "react";
import { AbsoluteFill, Audio, Easing, Sequence, getInputProps, interpolate, spring, staticFile, useCurrentFrame } from "remotion";
import { IcoEdificio } from "../../marca/iconos";
import { crearLinea, type Tiempos } from "../../marca/linea";
import { Calle, Casa, Gimnasio, Pasillo } from "../fondos";
import { Fondo, MarcoEn, Silueta, marca, type M } from "../kit";
import { Papa } from "../Papa";
import { AMARILLO, CartaVoto, ContadorDia, FUENTE, Gordo, Ono, Subtitulo, TINTA } from "../piezas";
import { Revela, TituloEntra } from "../movimiento";
import tiemposJson from "./tiempos.json";

const FPS = 60;
const tiempos = tiemposJson as unknown as Tiempos;
const IDS = ["gancho", "ropa", "cinta", "pesas", "entrenador", "casa", "dolor", "voto"] as const;
type Id = (typeof IDS)[number];
const L = crearLinea({ tiempos, ids: IDS, fps: FPS, pre: { gancho: 0.08, ropa: 0.12, cinta: 0.12, pesas: 0.12, entrenador: 0.12, casa: 0.12, dolor: 0.12, voto: 0.12 }, extra: { voto: 1.8, cinta: 0.25, casa: 0.15 }, transicion: 0 });
export const DURACION_EP3 = L.total;
const CL = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;
const io = Easing.inOut(Easing.cubic);
const CLAVES = ["gimnasio", "4", "minutos", "ropa", "deporte", "10", "cinta", "30", "volando", "pesas", "vacia", "200", "kilos", "respirar", "arrastrandose", "trabajo", "2", "pelo", "dieta", "comenta"];
const src = (f: string) => staticFile(`serie-ep3/${f}`);
const s2f = (s: number) => Math.round(s * FPS);
const muelle = (f: number, desde: number, d = 11) => (f < desde ? 0 : spring({ frame: f - desde, fps: FPS, config: { damping: d, mass: 0.6 } }));
const ent = (f: number, a: number, b: number, e = io) => interpolate(f, [a, b], [0, 1], { ...CL, easing: e });

/* ---------- objetos ---------- */
/** Cronómetro: la aguja va de 0 a `seg` segundos; `para` lo pone en rojo. */
const Crono: React.FC<{ seg: number; para?: boolean; tam?: number }> = ({ seg, para, tam = 300 }) => (
  <svg width={tam} height={tam * 1.15} viewBox="0 0 100 115">
    <rect x={42} y={0} width={16} height={12} rx={4} fill={TINTA} />
    <rect x={76} y={14} width={12} height={10} rx={3} fill={TINTA} transform="rotate(40 82 19)" />
    <circle cx={50} cy={62} r={44} fill="#fff" stroke={TINTA} strokeWidth={7} />
    <circle cx={50} cy={62} r={36} fill={para ? "#ffe1e1" : "#f3f6fa"} />
    <path d={`M50 62 L${50 + Math.sin((seg / 60) * Math.PI * 2) * 30} ${62 - Math.cos((seg / 60) * Math.PI * 2) * 30}`} stroke={para ? "#e0453b" : TINTA} strokeWidth={6} strokeLinecap="round" />
    <circle cx={50} cy={62} r={5} fill={TINTA} />
  </svg>
);

/** Cinta de correr: la banda se mueve con `f`. */
const Cinta: React.FC<{ f: number; ancho?: number }> = ({ f, ancho = 760 }) => (
  <svg width={ancho} height={ancho * 0.75} viewBox="0 0 760 570" style={{ overflow: "visible" }}>
    <path d="M560 40 L640 420" stroke="#5c6470" strokeWidth={22} strokeLinecap="round" />
    <rect x={500} y={0} width={220} height={110} rx={20} fill="#2b3346" stroke={TINTA} strokeWidth={8} />
    <rect x={524} y={22} width={172} height={60} rx={10} fill="#1d2a22" />
    <path d="M60 470 L700 420 L720 470 L80 520 Z" fill="#3a3f4b" stroke={TINTA} strokeWidth={8} />
    {Array.from({ length: 12 }, (_, i) => {
      const x = 80 + ((i * 60 - f * 9) % 720 + 720) % 720 * 0.9;
      return <path key={i} d={`M${x} ${505 - (x - 80) * 0.078} l20 -2`} stroke="#5a6070" strokeWidth={6} />;
    })}
    <rect x={40} y={500} width={700} height={40} rx={12} fill="#5c6470" stroke={TINTA} strokeWidth={8} />
  </svg>
);

/** Barra de pesas con discos de tamaño `disco` (0 = vacía). */
const Barra: React.FC<{ disco: number; ancho?: number }> = ({ disco, ancho = 560 }) => (
  <svg width={ancho} height={220} viewBox="0 0 560 220" style={{ overflow: "visible" }}>
    <rect x={0} y={100} width={560} height={20} rx={8} fill="#9aa6b8" stroke={TINTA} strokeWidth={5} />
    {disco > 0
      ? [40, 520].map((x) => (
          <g key={x}>
            {Array.from({ length: 3 }, (_, k) => (
              <rect key={k} x={x - 22 + (x < 280 ? k * 26 : -k * 26)} y={110 - disco / 2} width={22} height={disco} rx={8} fill={["#e0453b", "#2b3346", "#2f62b5"][k]} stroke={TINTA} strokeWidth={5} />
            ))}
          </g>
        ))
      : null}
    {[30, 530].map((x) => (
      <rect key={x} x={x - 6} y={92} width={12} height={36} rx={4} fill="#5c6470" />
    ))}
  </svg>
);

/** Pulmones que se hinchan y deshinchan (aprende a respirar). */
const Pulmones: React.FC<{ f: number; tam?: number }> = ({ f, tam = 200 }) => {
  const r = 1 + 0.12 * Math.sin(f / 9);
  return (
    <svg width={tam} height={tam} viewBox="0 0 100 100" style={{ transform: `scale(${r})` }}>
      <path d="M50 14 V44 M50 44 Q40 50 34 46 M50 44 Q60 50 66 46" stroke={TINTA} strokeWidth={5} fill="none" strokeLinecap="round" />
      <path d="M32 34 Q12 40 12 70 Q12 90 30 88 Q44 86 44 66 V44 Q40 32 32 34 Z" fill="#ff9bb0" stroke={TINTA} strokeWidth={5} />
      <path d="M68 34 Q88 40 88 70 Q88 90 70 88 Q56 86 56 66 V44 Q60 32 68 34 Z" fill="#ff9bb0" stroke={TINTA} strokeWidth={5} />
    </svg>
  );
};

const PlatoDieta: React.FC<{ tam?: number }> = ({ tam = 210 }) => (
  <svg width={tam} height={tam} viewBox="0 0 100 100">
    <circle cx={50} cy={54} r={40} fill="#fff" stroke={TINTA} strokeWidth={6} />
    <circle cx={50} cy={54} r={28} fill="#f1f5ee" />
    <path d="M36 50 Q40 38 52 42 Q48 54 36 50 Z" fill="#6ab04c" stroke={TINTA} strokeWidth={3} />
    <circle cx={60} cy={60} r={9} fill="#e0453b" stroke={TINTA} strokeWidth={3} />
    <path d="M42 64 h14" stroke="#f2a33a" strokeWidth={8} strokeLinecap="round" />
  </svg>
);

const Bocadillo: React.FC<{ f: number; x: number; y: number; giro?: number; children: React.ReactNode }> = ({ f, x, y, giro = 3, children }) =>
  f < 0 ? null : (
    <div style={{ position: "absolute", left: x, top: y, transform: `translateX(-50%) scale(${interpolate(f, [0, 6, 10], [0, 1.15, 1], CL)}) rotate(${giro}deg)` }}>
      <div style={{ background: "#fff", border: `9px solid ${TINTA}`, borderRadius: 40, padding: "14px 34px 4px", whiteSpace: "nowrap", textAlign: "center", boxShadow: `0 10px 0 ${TINTA}` }}>{children}</div>
    </div>
  );
const Txt: React.FC<{ tam?: number; color?: string; children: React.ReactNode }> = ({ tam = 84, color = TINTA, children }) => <div style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: tam, color, lineHeight: 1.05 }}>{children}</div>;

/** Cámara: sigue lo importante con ease-in-out entre planos [fotograma, x, y, escala]; deriva un poco siempre. */
const Cam: React.FC<{ f: number; planos: [number, number, number, number][]; temblor?: number; children: React.ReactNode }> = ({ f, planos, temblor = 0, children }) => {
  let [, x, y, sc] = planos[0];
  for (let i = 1; i < planos.length; i++) {
    const [en, px, py, ps] = planos[i];
    const p = ent(f, en, en + 40);
    x += (px - x) * p;
    y += (py - y) * p;
    sc += (ps - sc) * p;
  }
  const tx = Math.sin(f * 2.3) * 14 * temblor + Math.sin(f / 70) * 5,
    ty = Math.cos(f * 2.9) * 10 * temblor + Math.cos(f / 90) * 4;
  return <AbsoluteFill style={{ transformOrigin: "0 0", transform: `translate(${540 + tx}px, ${960 + ty}px) scale(${sc}) translate(${-x}px, ${-y}px)` }}>{children}</AbsoluteFill>;
};

/** Transformación entre escenas: en los últimos fotogramas la cámara se mete en el objeto que abre la siguiente. */
const Atraviesa: React.FC<{ f: number; dur: number; foco: [number, number]; sinEntrada?: boolean; children: React.ReactNode }> = ({ f, dur, foco, sinEntrada, children }) => {
  const p = ent(f, dur - 14, dur, Easing.in(Easing.cubic));
  const entra = sinEntrada ? 1 : interpolate(f, [0, 10], [1.25, 1], { ...CL, easing: Easing.out(Easing.cubic) });
  return (
    <AbsoluteFill style={{ transform: `scale(${entra * (1 + p * 2.2)})`, transformOrigin: `${foco[0]}px ${foco[1]}px`, filter: p > 0.1 ? `blur(${p * 10}px)` : undefined }}>
      {children}
    </AbsoluteFill>
  );
};

/* =================== ESCENAS =================== */

const Gancho: React.FC<{ f: number; m: M; dur: number }> = ({ f, m, dur }) => {
  const cuatro = marca(m, "4", 80);
  const seg = interpolate(f, [0, cuatro], [0, 59], CL);
  const para = f >= cuatro;
  return (
    <Atraviesa f={f} dur={dur} foco={[780, 760]} sinEntrada>
      <Cam f={f} planos={[[0, 540, 980, 1], [cuatro - 10, 700, 900, 1.25]]} temblor={para ? 0.15 : 0}>
        <Gimnasio f={f} />
        <MarcoEn cx={360} cy={900} ancho={560} expresion={para ? "susto" : "ilusion"} f={f} deporte brazoD={para ? 0 : 140} />
        <div style={{ position: "absolute", left: 640, top: 600, transform: `rotate(${para ? Math.sin(f) * 4 : 6}deg)` }}>
          <Crono seg={seg} para={para} tam={280} />
        </div>
      </Cam>
      <div style={{ position: "absolute", left: 50, top: 210, background: "#2a9a5a", border: `7px solid ${TINTA}`, borderRadius: 20, padding: "4px 24px 0", transform: "rotate(-4deg)", boxShadow: `0 8px 0 ${TINTA}` }}>
        <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 52, color: "#fff" }}>
          GANÓ GIMNASIO <span style={{ color: AMARILLO }}>83%</span>
        </span>
      </div>
      <TituloEntra s={f / FPS} desde={-0.35} y={330} tam={108}>
        DURÓ <span style={{ color: AMARILLO }}>4</span> MINUTOS
      </TituloEntra>
    </Atraviesa>
  );
};

const Ropa: React.FC<{ f: number; m: M; dur: number }> = ({ f, m, dur }) => {
  const ropa = marca(m, "ropa", 120);
  const diez = marca(m, "10", 200);
  const puesto = f >= ropa;
  const barras = ent(f, 4, 34, Easing.out(Easing.cubic));
  return (
    <Atraviesa f={f} dur={dur} foco={[540, 1150]}>
      {f < ropa - 6 ? (
        <AbsoluteFill>
          <Fondo a="#9be0b0" b="#1f6e45" />
          {[
            ["GIMNASIO", 83, "#2a9a5a", 620],
            ["TRABAJO", 17, "#2f62b5", 840],
          ].map(([t, p, c, y]) => (
            <div key={t as string} style={{ position: "absolute", left: 110, top: y as number, width: 860, height: 170, background: "#ffffff33", border: `9px solid ${TINTA}`, borderRadius: 40, overflow: "hidden" }}>
              <div style={{ width: `${(p as number) * barras}%`, height: "100%", background: c as string }} />
              <div style={{ position: "absolute", inset: "0 40px", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
                <Gordo tam={84}>{t}</Gordo>
                <Gordo tam={84} color={AMARILLO}>
                  {Math.round((p as number) * barras)}%
                </Gordo>
              </div>
            </div>
          ))}
          <TituloEntra s={f / FPS} desde={0} y={380} tam={100}>
            VOTASTEIS
          </TituloEntra>
        </AbsoluteFill>
      ) : (
        <AbsoluteFill>
          <Cam f={f} planos={[[ropa, 540, 960, 1], [diez - 20, 540, 1100, 1.2]]}>
            <Pasillo />
            {/* la ropa vuela hacia Marco (y se la pone) */}
            <MarcoEn cx={540} cy={820} ancho={720} expresion="ilusion" f={f} deporte={puesto} brazoD={130} />
            {f < ropa + 14
              ? [
                  [-300, 600, "#e0453b"],
                  [1300, 1300, "#2f62b5"],
                ].map(([x0, y0, c], k) => (
                  <div key={k} style={{ position: "absolute", left: interpolate(f, [ropa - 6, ropa + 10], [x0 as number, 520], CL), top: interpolate(f, [ropa - 6, ropa + 10], [y0 as number, k ? 1160 : 690], CL), width: 120, height: 50, borderRadius: 20, background: c as string, border: `6px solid ${TINTA}`, transform: `rotate(${f * 20}deg)` }} />
                ))
              : null}
            <Ono texto="¡ZAS!" f={f - ropa - 8} x={830} y={600} giro={10} tam={150} dura={40} />
            {/* las flechas de la vergüenza */}
            {f > diez - 10 ? (
              <>
                <svg width={1080} height={1920} style={{ position: "absolute" }}>
                  <path d={`M860 1300 Q760 1290 ${interpolate(f, [diez - 10, diez + 4], [860, 690], CL)} 1240`} fill="none" stroke={TINTA} strokeWidth={14} strokeLinecap="round" />
                  <path d={`M860 1300 Q760 1290 ${interpolate(f, [diez - 10, diez + 4], [860, 690], CL)} 1240`} fill="none" stroke={AMARILLO} strokeWidth={6} strokeLinecap="round" />
                </svg>
                <div style={{ position: "absolute", left: 740, top: 1290, transform: `scale(${muelle(f, diez - 6)}) rotate(6deg)`, background: AMARILLO, border: `7px solid ${TINTA}`, borderRadius: 18, padding: "4px 20px 0" }}>
                  <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 50, color: TINTA }}>TALLA S</span>
                </div>
              </>
            ) : null}
          </Cam>
          <Revela s={f / FPS} desde={(diez - 4) / FPS} y={300} tam={96}>
            MODA <span style={{ color: "#e0453b" }}>2016</span>
          </Revela>
        </AbsoluteFill>
      )}
    </Atraviesa>
  );
};

const CintaEsc: React.FC<{ f: number; m: M; dur: number }> = ({ f, m, dur }) => {
  const treinta = marca(m, "30", 100);
  const vuela = marca(m, "volando", 170);
  const choca = vuela + 22;
  const v = ent(f, vuela, choca, Easing.in(Easing.quad));
  const seg = Math.min(30, Math.round(interpolate(f, [10, treinta], [0, 30], CL)));
  return (
    <Atraviesa f={f} dur={dur} foco={[880, 760]}>
      <Cam f={f} planos={[[0, 540, 1000, 1], [vuela - 6, 760, 900, 1.15], [choca, 880, 800, 1.45]]} temblor={f > choca && f < choca + 14 ? 1 : 0.08}>
        <Gimnasio f={f} />
        <div style={{ position: "absolute", left: 120, top: 860 }}>
          <Cinta f={f < vuela ? f : vuela} />
          <div style={{ position: "absolute", left: 528, top: 30, width: 170, textAlign: "center", fontFamily: "'JetBrains Mono', monospace", fontWeight: 700, fontSize: 40, color: f >= treinta ? "#ff5b5b" : "#7dff9a" }}>0:{String(seg).padStart(2, "0")}</div>
        </div>
        {/* Marco corre… y sale volando contra el póster */}
        {f < choca ? (
          <div style={{ position: "absolute", left: interpolate(v, [0, 1], [420, 760]), top: interpolate(v, [0, 0.5, 1], [790, 420, 560]) - Math.abs(Math.sin(f / 5)) * 18 * (1 - v), transform: `rotate(${v * 720}deg) scale(${1 - v * 0.3})` }}>
            <MarcoEn cx={0} cy={0} ancho={420} expresion={f > treinta ? "susto" : "confuso"} f={f} deporte zancada={f < vuela ? Math.sin(f / 4) * 22 : 30} />
          </div>
        ) : (
          <div style={{ position: "absolute", left: 845 - 210, top: 760 - 300, transform: `scale(${interpolate(f, [choca, choca + 4], [1.25, 1], CL)}, ${interpolate(f, [choca, choca + 4], [0.6, 1], CL)})` }}>
            <MarcoEn cx={210} cy={300} ancho={420} expresion="dormido" f={f} deporte brazoD={150} />
          </div>
        )}
        <Ono texto="¡PLAF!" f={f - choca} x={820} y={480} giro={-12} tam={180} dura={60} />
      </Cam>
      <TituloEntra s={f / FPS} desde={0.05} hasta={(vuela - 4) / FPS} y={300} tam={100}>
        VELOCIDAD <span style={{ color: AMARILLO }}>1</span>
      </TituloEntra>
    </Atraviesa>
  );
};

const Pesas: React.FC<{ f: number; m: M; dur: number }> = ({ f, m, dur }) => {
  const vacia = marca(m, "vacia", 100);
  const doscientos = marca(m, "200", 200);
  const sube = ent(f, vacia - 20, vacia, Easing.out(Easing.cubic));
  const tiembla = Math.sin(f * 2.5) * 10 * sube;
  const grafica = ent(f, doscientos, doscientos + 30, Easing.out(Easing.cubic));
  return (
    <Atraviesa f={f} dur={dur} foco={[540, 900]}>
      <Cam f={f} planos={[[0, 400, 960, 1.1], [doscientos - 10, 540, 960, 1]]}>
        <Gimnasio f={f} poster="TÚ PUEDES MARCO" />
        {/* el de al lado, con 200 kg */}
        <div style={{ position: "absolute", left: 640, top: 520, opacity: ent(f, doscientos - 14, doscientos), transform: "scaleX(1.35)" }}>
          <Silueta ancho={300} color="#2c2c3a" ojos="feliz" brazoArriba />
        </div>
        <div style={{ position: "absolute", left: 520, top: 380, opacity: ent(f, doscientos - 14, doscientos), transform: `scale(${muelle(f, doscientos - 10)})` }}>
          <Barra disco={200} ancho={500} />
        </div>
        {/* Marco con la barra vacía, temblando */}
        <MarcoEn cx={300 + tiembla * 0.4} cy={1000} ancho={520} expresion={sube > 0.5 ? "susto" : "confuso"} f={f} deporte brazoD={150 * sube} />
        <div style={{ position: "absolute", left: 40 + tiembla, top: interpolate(sube, [0, 1], [1130, 640]) }}>
          <Barra disco={0} ancho={520} />
        </div>
      </Cam>
      {/* la escala: 20 kg contra 200 kg, a la misma regla */}
      {grafica > 0 ? (
        <div style={{ position: "absolute", left: 90, right: 90, top: 430, background: "#ffffffee", border: `8px solid ${TINTA}`, borderRadius: 30, padding: "18px 24px", transform: `scale(${0.8 + 0.2 * grafica})`, opacity: grafica }}>
          {[
            ["MARCO", 20, "#e0453b"],
            ["EL DE AL LADO", 200, "#2f62b5"],
          ].map(([q, kg, c]) => (
            <div key={q as string} style={{ display: "flex", alignItems: "center", gap: 16, marginBottom: 10 }}>
              <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 34, color: TINTA, width: 250 }}>{q}</span>
              <div style={{ flex: 1, height: 40 }}>
                <div style={{ width: `${((kg as number) / 200) * 100 * grafica}%`, height: "100%", background: c as string, borderRadius: 12, border: `5px solid ${TINTA}` }} />
              </div>
              <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 40, color: c as string, width: 140, textAlign: "right" }}>{kg} kg</span>
            </div>
          ))}
        </div>
      ) : null}
      <TituloEntra s={f / FPS} desde={0.05} y={290} tam={96}>
        BARRA <span style={{ color: AMARILLO }}>VACÍA</span>
      </TituloEntra>
    </Atraviesa>
  );
};

const Entrenador: React.FC<{ f: number; m: M; dur: number }> = ({ f, m, dur }) => {
  const dijo = marca(m, "dijo", 60);
  const respirar = marca(m, "respirar", 150);
  return (
    <Atraviesa f={f} dur={dur} foco={[300, 1100]}>
      <Cam f={f} planos={[[0, 540, 900, 1], [respirar - 10, 360, 1050, 1.25]]}>
        <Gimnasio f={f} />
        {/* el entrenador: enorme al lado de Marco (escala) */}
        <div style={{ position: "absolute", left: 470, top: 320, transform: "scaleX(1.45)" }}>
          <Silueta ancho={460} color="#26324a" ojos="enfado" />
        </div>
        <div style={{ position: "absolute", left: 720, top: 520, width: 36, height: 46, borderRadius: 10, background: "#ffd400", border: `5px solid ${TINTA}` }} />
        <MarcoEn cx={260} cy={1080} ancho={420} expresion="pena" f={f} deporte />
        <div style={{ position: "absolute", left: 160, top: 760, opacity: ent(f, respirar - 6, respirar + 6) }}>
          <Pulmones f={f} tam={200} />
        </div>
      </Cam>
      <Ono texto="¡PRIIII!" f={f - dijo + 10} x={800} y={420} giro={8} tam={130} dura={50} color="#ffffff" />
      <Revela s={f / FPS} desde={(respirar - 18) / FPS} y={280} tam={84}>
        APRENDE A <span style={{ color: "#e0453b" }}>RESPIRAR</span>
      </Revela>
    </Atraviesa>
  );
};

const CasaEsc: React.FC<{ f: number; m: M; dur: number }> = ({ f, m, dur }) => {
  const y = marca(m, "y", 120);
  const trabajo = marca(m, "trabajo", 200);
  return (
    <Atraviesa f={f} dur={dur} foco={[560, 640]}>
      {f < y - 4 ? (
        <AbsoluteFill>
          <Calle avance={f * 1.2} f={f} tarde />
          {/* Marco a gatas por la acera, con un rastro de sudor */}
          <div style={{ position: "absolute", left: 120, top: 1250, width: 520, height: 16, borderRadius: 8, background: "#8fd0ff", opacity: 0.6 }} />
          <div style={{ position: "absolute", left: 640, top: 1140, transform: `rotate(-78deg) translateY(${Math.sin(f / 6) * 8}px)`, transformOrigin: "0 0" }}>
            <MarcoEn cx={0} cy={0} ancho={420} expresion="dormido" f={f} deporte zancada={Math.sin(f / 6) * 12} />
          </div>
          <TituloEntra s={f / FPS} desde={0.05} y={300} tam={96}>
            A <span style={{ color: AMARILLO }}>GATAS</span>
          </TituloEntra>
        </AbsoluteFill>
      ) : (
        <AbsoluteFill>
          <Casa abierta f={f} />
          <div style={{ position: "absolute", left: 415, top: 740 }}>
            <Papa ancho={250} expresion="serio" />
          </div>
          <div style={{ position: "absolute", left: 120, top: 1130, transform: "rotate(-80deg)", transformOrigin: "0 0" }}>
            <MarcoEn cx={0} cy={0} ancho={380} expresion="dormido" f={f} deporte />
          </div>
          <Bocadillo f={f - trabajo + 8} x={560} y={430}>
            <Txt tam={92}>
              ¿Y EL <span style={{ color: "#e0453b" }}>TRABAJO</span>?
            </Txt>
          </Bocadillo>
        </AbsoluteFill>
      )}
    </Atraviesa>
  );
};

const Dolor: React.FC<{ f: number; m: M; dur: number }> = ({ f, m, dur }) => {
  const pelo = marca(m, "pelo", 100);
  return (
    <Atraviesa f={f} dur={dur} foco={[540, 1000]}>
      <Cam f={f} planos={[[0, 540, 1000, 1], [pelo - 12, 560, 640, 1.7]]}>
        <Pasillo />
        <MarcoEn cx={540} cy={820} ancho={760} expresion="pena" f={f} deporte dolor={ent(f, 10, 40)} tirita={f >= pelo} />
        <Ono texto="¡AY!" f={f - pelo} x={760} y={540} giro={14} tam={120} dura={60} />
      </Cam>
      <Revela s={f / FPS} desde={0.15} y={300} tam={96}>
        LE DUELE <span style={{ color: "#e0453b" }}>TODO</span>
      </Revela>
    </Atraviesa>
  );
};

const Voto: React.FC<{ f: number }> = ({ f }) => (
  <AbsoluteFill style={{ transform: `scale(${interpolate(f, [0, 10], [1.2, 1], { ...CL, easing: Easing.out(Easing.cubic) })})` }}>
    <Fondo a="#ffe066" b="#f08a24" />
    <TituloEntra s={f / FPS} desde={0} y={330} tam={92}>
      ¿QUÉ TOCA <span style={{ color: AMARILLO }}>MAÑANA</span>?
    </TituloEntra>
    <CartaVoto n={1} titulo="DIETA" color="#2a9a5a" icono={<PlatoDieta tam={210} />} f={f - 4} giro={-5} x={290} />
    <CartaVoto n={2} titulo="TRABAJO" color="#2f62b5" icono={<IcoEdificio tamano={210} color="#ffcf5a" />} f={f - 10} giro={5} x={790} />
    <div style={{ position: "absolute", top: 1470, left: 0, right: 0, display: "flex", justifyContent: "center", transform: `scale(${interpolate(f, [30, 38, 42], [0, 1.15, 1], CL) * (1 + Math.sin(f / 8) * 0.03)})` }}>
      <div style={{ background: TINTA, borderRadius: 30, padding: "10px 40px 0" }}>
        <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 70, color: "#fff" }}>
          COMENTA <span style={{ color: AMARILLO }}>1</span> O <span style={{ color: AMARILLO }}>2</span>
        </span>
      </div>
    </div>
  </AbsoluteFill>
);

/* ---------- sonido ---------- */
type Sfx = [string, Id, string | number, number?];
const SFX: Sfx[] = [
  ["golpe", "gancho", 0, 0.8],
  ["tic", "gancho", 20, 0.4],
  ["tic", "gancho", 40, 0.4],
  ["error", "gancho", "4", 0.6],
  ["whoosh", "ropa", 0, 0.5],
  ["subida", "ropa", 4, 0.4],
  ["whoosh", "ropa", "ropa", 0.6],
  ["pop", "ropa", "10", 0.6],
  ["whoosh", "cinta", 0, 0.5],
  ["error", "cinta", "30", 0.5],
  ["whoosh", "cinta", "volando", 0.8],
  ["golpe", "cinta", "volando", 1],
  ["whoosh", "pesas", 0, 0.5],
  ["latido", "pesas", "vacia", 0.6],
  ["golpe", "pesas", "200", 0.6],
  ["whoosh", "entrenador", 0, 0.5],
  ["cascabel", "entrenador", "dijo", 0.6],
  ["pop", "entrenador", "respirar", 0.6],
  ["whoosh", "casa", 0, 0.5],
  ["error", "casa", "trabajo", 0.6],
  ["whoosh", "dolor", 0, 0.5],
  ["pop", "dolor", "pelo", 0.7],
  ["whoosh", "voto", 0, 0.6],
  ["exito", "voto", 34, 0.6],
];

const ESCENAS: Record<Id, React.FC<{ f: number; m: M; dur: number }>> = {
  gancho: Gancho,
  ropa: Ropa,
  cinta: CintaEsc,
  pesas: Pesas,
  entrenador: Entrenador,
  casa: CasaEsc,
  dolor: Dolor,
  voto: ({ f }) => <Voto f={f} />,
};

export const Episodio3: React.FC = () => {
  const frame = useCurrentFrame();
  const { i, id, local } = L.escenaEn(frame);
  const m = L.marcas(id);
  const dur = L.duraciones[i];
  const sinMusica = Boolean((getInputProps() as { sinMusica?: boolean }).sinMusica);
  const t = (local - L.preDe(id)) / FPS;
  const Esc = ESCENAS[id];
  const inicioDolor = L.inicios[IDS.indexOf("dolor")];

  return (
    <AbsoluteFill style={{ background: "#000", overflow: "hidden" }}>
      <Esc f={local} m={m} dur={dur} />
      {frame >= inicioDolor ? <ContadorDia dia={2} f={frame - inicioDolor} /> : null}
      <Subtitulo palabras={tiempos.voz[id].palabras} t={t} fps={FPS} claves={CLAVES} y={id === "voto" ? 1290 : 1260} />
      {IDS.map((k, n) => (
        <Sequence key={k} from={L.inicios[n] + L.preDe(k)} durationInFrames={Math.ceil((tiempos.voz[k].duracion + 0.2) * FPS)}>
          <Audio src={src(`voz-${k}.mp3`)} />
        </Sequence>
      ))}
      {SFX.map(([e, esc, cuando, vol = 0.6], n) => {
        const k = IDS.indexOf(esc);
        let loc = 0;
        if (typeof cuando === "number") loc = cuando;
        else {
          try {
            loc = L.marcas(esc)(cuando);
          } catch {
            return null;
          }
        }
        return (
          <Sequence key={n} from={L.inicios[k] + loc} durationInFrames={s2f(3)}>
            <Audio src={src(`sfx-${e}.mp3`)} volume={vol} />
          </Sequence>
        );
      })}
      {sinMusica ? null : <Audio src={src("musica.mp3")} volume={0.22} loop />}
    </AbsoluteFill>
  );
};

