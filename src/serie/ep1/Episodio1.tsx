/**
 * Serie de Marco (cuenta alternativa, no AEZ) · Episodio 1: "10 años congelado".
 * ~30 s a 60 fps, cortes secos cada 1–2 s en las marcas de la voz, subtítulos gigantes palabra a palabra
 * y votación final: ¿familia o Laura?
 */
import React from "react";
import { AbsoluteFill, Audio, Sequence, getInputProps, interpolate, random, staticFile, useCurrentFrame } from "remotion";
import { IcoCasa, IcoCorazon } from "../../marca/iconos";
import { crearLinea, type Tiempos } from "../../marca/linea";
import { Marco } from "../Marco";
import { MarcoFeo, type ExpresionMarco } from "../MarcoFeo";
import { AMARILLO, CartaVoto, ContadorDia, FUENTE, Gordo, Ono, Rec, Subtitulo, TINTA, punch } from "../piezas";
import tiemposJson from "./tiempos.json";

const FPS = 60;
const tiempos = tiemposJson as unknown as Tiempos;
const IDS = ["gancho", "como", "despierta", "mensajes", "flashback", "reto", "voto"] as const;
type Id = (typeof IDS)[number];
const L = crearLinea({ tiempos, ids: IDS, fps: FPS, pre: { gancho: 0.08, como: 0.12, despierta: 0.12, mensajes: 0.12, flashback: 0.15, reto: 0.12, voto: 0.12 }, extra: { voto: 1.8, flashback: 0.15 }, transicion: 0 });
export const DURACION_EP1 = L.total;
const CL = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;
const CLAVES = ["marco", "10", "congelado", "2016", "encerrado", "frigorifica", "despierta", "hongos", "helada", "movil", "114", "laura", "llamame", "nunca", "30", "uno", "familia", "comentarios"];
const s = (n: number) => Math.round(n * FPS);
const src = (f: string) => staticFile(`serie-ep1/${f}`);

/* ---------- ayudas de dibujo ---------- */

/** Marco feo colocado por la posición de su cara (cx, cy) en pantalla. */
const MarcoEn: React.FC<{ cx: number; cy: number; ancho: number; expresion: ExpresionMarco; f: number; movil?: boolean; brazoD?: number; tirita?: number }> = ({ cx, cy, ancho, f, ...p }) => (
  <div style={{ position: "absolute", left: cx - ancho / 2, top: cy - ancho * 0.45 }}>
    <MarcoFeo ancho={ancho} frame={f / 2} {...p} />
  </div>
);

const Fondo: React.FC<{ a: string; b: string }> = ({ a, b }) => <AbsoluteFill style={{ background: `radial-gradient(circle at 50% 38%, ${a} 0%, ${b} 85%)` }} />;

/** Copos de nieve que caen (deterministas). */
const Nieve: React.FC<{ f: number; n?: number; op?: number }> = ({ f, n = 40, op = 0.9 }) => (
  <AbsoluteFill>
    {Array.from({ length: n }, (_, i) => {
      const x = random(`nx${i}`) * 1080 + Math.sin(f / 30 + i) * 30;
      const y = ((random(`ny${i}`) * 2100 + f * (2 + random(`nv${i}`) * 3)) % 2100) - 100;
      const r = 5 + random(`nr${i}`) * 10;
      return <div key={i} style={{ position: "absolute", left: x, top: y, width: r, height: r, borderRadius: r, background: "#fff", opacity: op }} />;
    })}
  </AbsoluteFill>
);

/** Bloque de hielo translúcido con grietas (0–1). */
const Hielo: React.FC<{ x: number; y: number; w: number; h: number; grietas?: number }> = ({ x, y, w, h, grietas = 0 }) => (
  <svg style={{ position: "absolute", left: x, top: y, overflow: "visible" }} width={w} height={h} viewBox={`0 0 ${w} ${h}`}>
    <rect x={0} y={0} width={w} height={h} rx={40} fill="#bfeaff" opacity={0.42} stroke="#ffffff" strokeWidth={10} />
    <path d={`M40 ${h * 0.12} L${w * 0.3} 30 M60 ${h * 0.25} L${w * 0.45} 40 M${w - 60} ${h * 0.7} L${w - 30} ${h * 0.5}`} stroke="#fff" strokeWidth={16} strokeLinecap="round" opacity={0.7} />
    {grietas > 0 ? (
      <path
        d={`M${w * 0.5} ${h * 0.45} L${w * 0.38} ${h * 0.3} L${w * 0.42} ${h * 0.15} M${w * 0.5} ${h * 0.45} L${w * 0.66} ${h * 0.36} L${w * 0.8} ${h * 0.4} M${w * 0.5} ${h * 0.45} L${w * 0.46} ${h * 0.62} L${w * 0.58} ${h * 0.8} M${w * 0.5} ${h * 0.45} L${w * 0.3} ${h * 0.55} L${w * 0.15} ${h * 0.5}`}
        stroke="#ffffff"
        strokeWidth={9}
        fill="none"
        strokeLinejoin="round"
        pathLength={1}
        strokeDasharray={1}
        strokeDashoffset={1 - grietas}
      />
    ) : null}
  </svg>
);

/** Etiqueta con flecha (para señalar los hongos y la nariz). */
const Etiqueta: React.FC<{ texto: string; x: number; y: number; ax: number; ay: number; f: number; giro?: number }> = ({ texto, x, y, ax, ay, f, giro = -4 }) => {
  if (f < 0) return null;
  const e = interpolate(f, [0, 5, 9], [0, 1.15, 1], CL);
  const p = interpolate(f, [0, 10], [0, 1], CL);
  return (
    <>
      <svg style={{ position: "absolute", left: 0, top: 0 }} width={1080} height={1920}>
        <line x1={x} y1={y} x2={x + (ax - x) * p} y2={y + (ay - y) * p} stroke={TINTA} strokeWidth={16} strokeLinecap="round" />
        <line x1={x} y1={y} x2={x + (ax - x) * p} y2={y + (ay - y) * p} stroke={AMARILLO} strokeWidth={7} strokeLinecap="round" />
        {p >= 1 ? <circle cx={ax} cy={ay} r={16} fill={AMARILLO} stroke={TINTA} strokeWidth={6} /> : null}
      </svg>
      <div style={{ position: "absolute", left: x, top: y, transform: `translate(-50%,-50%) rotate(${giro}deg) scale(${e})`, background: AMARILLO, border: `7px solid ${TINTA}`, borderRadius: 20, padding: "6px 24px 0", boxShadow: `0 8px 0 ${TINTA}` }}>
        <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 62, color: TINTA, whiteSpace: "nowrap" }}>{texto}</span>
      </div>
    </>
  );
};

/** Silueta de Laura (su cara no se ve: es parte del misterio). */
const Laura: React.FC<{ ancho: number }> = ({ ancho }) => (
  <svg width={ancho} height={ancho * 2} viewBox="0 0 200 400">
    <g fill="#3a2550" stroke={TINTA} strokeWidth={5} strokeLinejoin="round">
      <path d="M120 40 Q170 60 160 130 Q150 110 132 96 Z" />
      <circle cx={100} cy={70} r={42} />
      <path d="M86 108 L114 108 L116 128 L84 128 Z" />
      <path d="M60 130 Q100 118 140 130 L150 230 L172 330 L28 330 L50 230 Z" />
      <path d="M62 136 Q36 190 44 250 L60 250 Q58 200 76 160 Z" />
      <path d="M138 136 Q164 190 156 250 L140 250 Q142 200 124 160 Z" />
      <path d="M76 330 L72 392 L92 392 L94 330 Z M106 330 L108 392 L128 392 L124 330 Z" />
    </g>
  </svg>
);

/** Móvil grande dibujado (genérico, sin marca). */
const Movil: React.FC<{ children: React.ReactNode; top?: number }> = ({ children, top = 170 }) => (
  <div style={{ position: "absolute", left: 160, top, width: 760, height: 1000, background: "#1c1f2b", border: `10px solid ${TINTA}`, borderRadius: 70, padding: 26, boxSizing: "border-box", boxShadow: `0 18px 0 ${TINTA}` }}>
    <div style={{ width: "100%", height: "100%", borderRadius: 48, overflow: "hidden", background: "linear-gradient(180deg,#3b5ca8,#7a4fa8)", position: "relative" }}>{children}</div>
  </div>
);

const Noti: React.FC<{ quien: string; texto: string; color: string; f: number; y: number; numero?: number }> = ({ quien, texto, color, f, y, numero }) => {
  if (f < 0) return null;
  const e = interpolate(f, [0, 5, 9], [0.6, 1.06, 1], CL);
  const dx = interpolate(f, [0, 6], [-80, 0], CL);
  return (
    <div style={{ position: "absolute", left: 24, right: 24, top: y, height: 132, borderRadius: 30, background: "rgba(255,255,255,0.93)", display: "flex", alignItems: "center", gap: 20, padding: "0 22px", transform: `translateX(${dx}px) scale(${e})`, boxShadow: "0 6px 0 rgba(0,0,0,0.25)" }}>
      <div style={{ width: 84, height: 84, borderRadius: 42, background: color, border: `5px solid ${TINTA}`, flexShrink: 0, display: "flex", alignItems: "center", justifyContent: "center" }}>
        <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 50, color: "#fff", marginTop: 8 }}>{quien[0]}</span>
      </div>
      <div style={{ flex: 1, overflow: "hidden" }}>
        <div style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 40, color: TINTA, lineHeight: 1.1 }}>{quien}</div>
        <div style={{ fontFamily: "'Lexend', sans-serif", fontWeight: 600, fontSize: 30, color: "#4b4b5a", whiteSpace: "nowrap" }}>{texto}</div>
      </div>
      {numero ? (
        <div style={{ minWidth: 70, height: 70, borderRadius: 35, background: "#ff3b3b", display: "flex", alignItems: "center", justifyContent: "center", padding: "0 12px" }}>
          <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 40, color: "#fff", marginTop: 6 }}>{numero}</span>
        </div>
      ) : null}
    </div>
  );
};

/** Grano y viñeta de grabación antigua. */
const Grano: React.FC<{ f: number }> = ({ f }) => (
  <AbsoluteFill style={{ pointerEvents: "none" }}>
    <svg width={1080} height={1920} style={{ position: "absolute", opacity: 0.22, mixBlendMode: "overlay" }}>
      <filter id="grano">
        <feTurbulence type="fractalNoise" baseFrequency={0.85} numOctaves={2} seed={Math.floor(f / 3) % 20} />
      </filter>
      <rect width={1080} height={1920} filter="url(#grano)" />
    </svg>
    <AbsoluteFill style={{ background: "radial-gradient(circle at 50% 45%, transparent 45%, rgba(0,0,0,0.65) 100%)" }} />
    <div style={{ position: "absolute", left: 0, right: 0, top: (f * 9) % 1920, height: 6, background: "rgba(255,255,255,0.12)" }} />
  </AbsoluteFill>
);

/* ---------- las escenas (cada una con sus planos de corte seco) ---------- */

const Gancho: React.FC<{ f: number; m: (p: string) => number }> = ({ f, m }) => {
  const b = m("congelado");
  const tituloY = interpolate(f, [0, 8], [0, 1], CL);
  return f < b ? (
    <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
      <Fondo a="#bfe9ff" b="#1f5aa0" />
      <Nieve f={f} />
      <MarcoEn cx={540} cy={820} ancho={860} expresion="dormido" f={f} />
      <Hielo x={70} y={440} w={940} h={1500} />
      <div style={{ position: "absolute", top: 210, left: 0, right: 0, display: "flex", flexDirection: "column", alignItems: "center", gap: 0, transform: `scale(${0.96 + tituloY * 0.04})` }}>
        <Gordo tam={190} color={AMARILLO} style={{ transform: "rotate(-3deg)" }}>
          10 AÑOS
        </Gordo>
        <Gordo tam={140}>CONGELADO</Gordo>
      </div>
    </AbsoluteFill>
  ) : (
    <AbsoluteFill style={{ transform: `scale(${punch(f - b)})` }}>
      <Fondo a="#d6f3ff" b="#2a6db8" />
      <MarcoEn cx={540} cy={760} ancho={1450} expresion="dormido" f={f} />
      <Hielo x={-40} y={140} w={1160} h={1700} grietas={0} />
      <Nieve f={f} n={25} />
      <AbsoluteFill style={{ background: "radial-gradient(circle at 50% 45%, transparent 50%, rgba(220,245,255,0.9) 100%)" }} />
    </AbsoluteFill>
  );
};

const Como: React.FC<{ f: number; m: (p: string) => number; dur: number }> = ({ f, m, dur }) => {
  const b = m("encerrado");
  if (f < b) {
    const hoja = (k: number) => interpolate(f, [k * 4, k * 4 + 10], [0, -900], CL);
    return (
      <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
        <Fondo a="#ffb35c" b="#d2452f" />
        <div style={{ position: "absolute", left: 190, top: 330, width: 700, height: 760, background: "#fff", border: `10px solid ${TINTA}`, borderRadius: 40, overflow: "hidden", boxShadow: `0 18px 0 ${TINTA}` }} />
        <div style={{ position: "absolute", left: 190, top: 330, width: 700, height: 760, display: "flex", flexDirection: "column", alignItems: "center" }}>
          <div style={{ width: "100%", height: 170, background: "#e2553f", borderBottom: `10px solid ${TINTA}`, borderRadius: "30px 30px 0 0", display: "flex", alignItems: "center", justifyContent: "center" }}>
            <Gordo tam={96}>NOVIEMBRE</Gordo>
          </div>
          <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 300, color: TINTA, marginTop: 60 }}>2016</span>
        </div>
        {/* hojas de calendario que vuelan hacia atrás en el tiempo */}
        {[2026, 2025, 2024].map((a, k) => (
          <div key={a} style={{ position: "absolute", left: 190, top: 330 + hoja(k), width: 700, height: 760, background: "#fff", border: `10px solid ${TINTA}`, borderRadius: 40, transform: `rotate(${(k - 1) * 6}deg)`, opacity: hoja(k) < -880 ? 0 : 1, display: "flex", alignItems: "center", justifyContent: "center" }}>
            <Gordo tam={220} color="#ddd">{a}</Gordo>
          </div>
        ))}
      </AbsoluteFill>
    );
  }
  // La cámara frigorífica: Marco dentro, tiritando, y la puerta que se cierra al final
  const cierre = interpolate(f, [dur - 34, dur - 22], [1200, 0], { ...CL, easing: (x) => x * x });
  return (
    <AbsoluteFill style={{ transform: `scale(${punch(f - b)})` }}>
      <AbsoluteFill style={{ background: "linear-gradient(180deg,#9fb6c8,#5d7488)" }} />
      {[420, 760, 1100].map((y) => (
        <div key={y} style={{ position: "absolute", left: 0, right: 0, top: y, height: 26, background: "#c7d3dc", borderTop: `6px solid ${TINTA}`, borderBottom: `6px solid ${TINTA}` }}>
          {[60, 300, 760, 900].map((x, k) => (
            <div key={x} style={{ position: "absolute", left: x, top: -130 + (k % 2) * 20, width: 150 - (k % 2) * 30, height: 124 - (k % 2) * 20, background: k % 2 ? "#e9d3a6" : "#d9bd86", border: `6px solid ${TINTA}`, borderRadius: 8 }} />
          ))}
        </div>
      ))}
      <Nieve f={f} n={30} op={0.6} />
      <MarcoEn cx={540} cy={800} ancho={640} expresion="susto" tirita={1} f={f} />
      <div style={{ position: "absolute", right: 60, top: 230, background: AMARILLO, border: `8px solid ${TINTA}`, borderRadius: 18, padding: "6px 26px 0", transform: "rotate(5deg)" }}>
        <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 92, color: TINTA }}>−25 °C</span>
      </div>
      {/* puerta de acero */}
      <div style={{ position: "absolute", top: 0, bottom: 0, left: cierre, width: 1080, background: "linear-gradient(90deg,#8a98a6,#b7c2cc 40%,#7d8a97)", borderLeft: `14px solid ${TINTA}` }}>
        <div style={{ position: "absolute", left: 80, top: 860, width: 60, height: 240, borderRadius: 20, background: "#3b4450", border: `8px solid ${TINTA}` }} />
      </div>
      <Ono texto="¡CLANC!" f={f - (dur - 22)} x={560} y={700} giro={-8} color="#ffffff" />
    </AbsoluteFill>
  );
};

const Despierta: React.FC<{ f: number; m: (p: string) => number }> = ({ f, m }) => {
  const b = m("hongos");
  const c = m("móvil");
  let nariz = -1;
  try {
    nariz = m("nariz");
  } catch {
    nariz = b + 30;
  }
  if (f < b) {
    const g = interpolate(f, [4, 18], [0, 1], CL);
    const rompe = f > 24;
    return (
      <AbsoluteFill style={{ transform: `scale(${punch(f)}) translate(${f < 30 ? Math.sin(f * 3) * 10 : 0}px,0)` }}>
        <Fondo a="#e4f7ff" b="#4c8fcf" />
        <MarcoEn cx={540} cy={760} ancho={760} expresion="susto" tirita={1} f={f} />
        {!rompe ? (
          <Hielo x={110} y={380} w={860} h={1450} grietas={g} />
        ) : (
          Array.from({ length: 10 }, (_, i) => {
            const t = f - 24;
            const ang = random(`h${i}`) * Math.PI * 2;
            return <div key={i} style={{ position: "absolute", left: 540 + Math.cos(ang) * (200 + t * 26), top: 900 + Math.sin(ang) * (300 + t * 20) + t * t * 0.6, width: 90 + random(`hw${i}`) * 80, height: 70 + random(`hh${i}`) * 60, background: "#d2f1ff", opacity: 0.85, border: "6px solid #fff", borderRadius: 14, transform: `rotate(${t * 9 + i * 40}deg)` }} />;
          })
        )}
        <Ono texto="¡CRAC!" f={f - 22} x={540} y={360} giro={-10} />
      </AbsoluteFill>
    );
  }
  if (f < c) {
    return (
      <AbsoluteFill style={{ transform: `scale(${punch(f - b)})` }}>
        <Fondo a="#d9e8a0" b="#5f7d35" />
        <MarcoEn cx={540} cy={640} ancho={1400} expresion="asco" f={f} />
        <Etiqueta texto="HONGOS" x={850} y={330} ax={640} ay={230} f={f - b - 4} giro={5} />
        <Etiqueta texto="NARIZ HELADA" x={260} y={960} ax={520} ay={720} f={f - nariz} />
      </AbsoluteFill>
    );
  }
  return (
    <AbsoluteFill style={{ transform: `scale(${punch(f - c)})` }}>
      <Fondo a="#fff0c9" b="#e39a4a" />
      <MarcoEn cx={540} cy={620} ancho={820} expresion="confuso" movil brazoD={115} f={f} />
      <Ono texto="BZZ" f={(f - c) % 26} x={880} y={520} giro={12} tam={130} color="#ffffff" dura={18} />
      <div style={{ position: "absolute", left: 0, right: 0, top: 240, display: "flex", justifyContent: "center" }}>
        <Gordo tam={90} color="#ffffff" style={{ transform: "rotate(-3deg)" }}>
          MÓVIL DE <span style={{ color: AMARILLO }}>2016</span>
        </Gordo>
      </div>
    </AbsoluteFill>
  );
};

const Mensajes: React.FC<{ f: number; m: (p: string) => number }> = ({ f, m }) => {
  const b = m("Laura");
  const cuenta = Math.round(interpolate(f, [0, Math.min(b, 70)], [0, 114], CL));
  const zoom = f >= b ? interpolate(f - b, [0, 8], [1, 1.45], { ...CL, easing: (x) => 1 - (1 - x) ** 3 }) : 1;
  return (
    <AbsoluteFill style={{ transform: `scale(${f < b ? punch(f) : 1})` }}>
      <Fondo a="#3a3f5c" b="#0f1220" />
      <div style={{ position: "absolute", inset: 0, transform: `scale(${zoom})`, transformOrigin: "540px 990px" }}>
        <Movil>
          <div style={{ textAlign: "center", marginTop: 40 }}>
            <div style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 130, color: "#fff", lineHeight: 1 }}>13:11</div>
            <div style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 44, color: "#ffffffcc" }}>{cuenta} MENSAJES SIN LEER</div>
          </div>
          <Noti quien="FAMILIA" texto="Mamá: Hijo, ¿dónde estás?" color="#2f62b5" f={f - 4} y={290} numero={98} />
          <Noti quien="FAMILIA" texto="Papá: Llámanos, por favor" color="#2f62b5" f={f - 12} y={436} />
          <Noti quien="FAMILIA" texto="Lucía: Te echamos de menos" color="#2f62b5" f={f - 20} y={582} />
          <Noti quien="LAURA" texto="¿Por qué no me llamaste?" color="#e0457b" f={f - 28} y={728} numero={16} />
        </Movil>
      </div>
      {f >= b ? (
        <div style={{ position: "absolute", left: 830, top: 1080, transform: `scale(${interpolate(f - b, [0, 6, 10], [0, 1.3, 1], CL) * (1 + Math.sin((f - b) / 5) * 0.06)})` }}>
          <IcoCorazon tamano={170} color="#ff4f8a" />
        </div>
      ) : null}
      <Ono texto="BZZ" f={f % 20} x={150} y={330} giro={-14} tam={110} color="#ffffff" dura={12} />
    </AbsoluteFill>
  );
};

const Flashback: React.FC<{ f: number; m: (p: string) => number }> = ({ f, m }) => {
  const b = m("nunca");
  const escena =
    f < b ? (
      <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
        <AbsoluteFill style={{ background: "linear-gradient(180deg,#f7a14f 0%,#e5674b 55%,#6b4b3a 55%,#4a3326 100%)" }} />
        <div style={{ position: "absolute", left: 470, top: 300, width: 24, height: 760, background: "#2a2220" }} />
        <div style={{ position: "absolute", left: 430, top: 280, width: 104, height: 50, borderRadius: 20, background: "#ffe7a0", boxShadow: "0 0 90px 40px rgba(255,220,140,0.6)" }} />
        <div style={{ position: "absolute", left: 60, top: 560 }}>
          <Marco variante="congelado" joven ancho={430} ojos="abiertos" />
        </div>
        <div style={{ position: "absolute", left: 640, top: 600 }}>
          <Laura ancho={340} />
        </div>
        <div style={{ position: "absolute", left: 600, top: 330, transform: `scale(${interpolate(f, [6, 12, 16], [0, 1.15, 1], CL)}) rotate(4deg)`, transformOrigin: "50% 100%" }}>
          <div style={{ background: "#fff", border: `9px solid ${TINTA}`, borderRadius: 40, padding: "14px 34px 4px" }}>
            <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 92, color: "#e0457b" }}>¡LLÁMAME!</span>
          </div>
        </div>
      </AbsoluteFill>
    ) : (
      <AbsoluteFill style={{ transform: `scale(${punch(f - b)})` }}>
        <Fondo a="#56607a" b="#1a1d29" />
        <Movil top={190}>
          <div style={{ textAlign: "center", marginTop: 120 }}>
            <div style={{ width: 240, height: 240, borderRadius: 120, background: "#e0457b", border: `8px solid ${TINTA}`, margin: "0 auto", display: "flex", alignItems: "center", justifyContent: "center" }}>
              <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 150, color: "#fff", marginTop: 20 }}>L</span>
            </div>
            <div style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 96, color: "#fff", marginTop: 20 }}>Laura</div>
          </div>
          <div style={{ position: "absolute", left: "50%", bottom: 130, marginLeft: -90, width: 180, height: 180, borderRadius: 90, background: "#36c06b", border: `8px solid ${TINTA}`, display: "flex", alignItems: "center", justifyContent: "center" }}>
            <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 44, color: "#fff", marginTop: 8 }}>LLAMAR</span>
          </div>
        </Movil>
        <div style={{ position: "absolute", left: 540, top: 820, transform: `translate(-50%,-50%) rotate(-14deg) scale(${interpolate(f - b, [10, 15, 19], [3, 0.92, 1], CL)})`, opacity: f - b >= 10 ? 1 : 0, border: "14px solid #ff2a2a", borderRadius: 24, padding: "14px 36px 0", background: "rgba(255,255,255,0.85)" }}>
          <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 130, color: "#ff2a2a", whiteSpace: "nowrap" }}>NUNCA LLAMÓ</span>
        </div>
      </AbsoluteFill>
    );
  return (
    <AbsoluteFill>
      <AbsoluteFill style={{ filter: "sepia(0.7) saturate(1.3) contrast(1.05)" }}>{escena}</AbsoluteFill>
      <Grano f={f} />
      <Rec f={f} fecha="13·11·2016" />
    </AbsoluteFill>
  );
};

const Reto: React.FC<{ f: number; m: (p: string) => number }> = ({ f, m }) => {
  const b = m("solo");
  if (f < b) {
    return (
      <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
        <Fondo a="#4f86e0" b="#1c3f8f" />
        <div style={{ position: "absolute", left: 110, top: 360, width: 860, height: 800, background: "#fff", border: `10px solid ${TINTA}`, borderRadius: 40, boxShadow: `0 18px 0 ${TINTA}`, overflow: "hidden" }}>
          <div style={{ height: 150, background: "#e2553f", borderBottom: `10px solid ${TINTA}`, display: "flex", alignItems: "center", justifyContent: "center" }}>
            <Gordo tam={110}>30 DÍAS</Gordo>
          </div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(6, 1fr)", gap: 14, padding: 26 }}>
            {Array.from({ length: 30 }, (_, i) => {
              const e = interpolate(f - i * 1.2, [0, 6], [0, 1], CL);
              return (
                <div key={i} style={{ height: 96, borderRadius: 16, border: `5px solid ${TINTA}`, background: i === 29 ? AMARILLO : "#f1ece3", display: "flex", alignItems: "center", justifyContent: "center", transform: `scale(${e})` }}>
                  <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 50, color: TINTA, marginTop: 6 }}>{i + 1}</span>
                </div>
              );
            })}
          </div>
        </div>
      </AbsoluteFill>
    );
  }
  // Cruce de caminos: familia o Laura
  const g = f - b;
  return (
    <AbsoluteFill style={{ transform: `scale(${punch(g)})` }}>
      <AbsoluteFill style={{ background: "linear-gradient(180deg,#8fd3ff 0%,#cdeeff 52%,#7cc46a 52%,#4f9a45 100%)" }} />
      <div style={{ position: "absolute", left: 525, top: 330, width: 30, height: 700, background: "#7a5233", border: `6px solid ${TINTA}` }} />
      <div style={{ position: "absolute", left: 90, top: 360, width: 470, height: 150, background: "#2f62b5", border: `8px solid ${TINTA}`, clipPath: "polygon(14% 0,100% 0,100% 100%,14% 100%,0 50%)", display: "flex", alignItems: "center", justifyContent: "center", transform: `rotate(-4deg) scale(${interpolate(g, [2, 8], [0, 1], CL)})` }}>
        <Gordo tam={84}>FAMILIA</Gordo>
      </div>
      <div style={{ position: "absolute", left: 520, top: 540, width: 470, height: 150, background: "#e0457b", border: `8px solid ${TINTA}`, clipPath: "polygon(0 0,86% 0,100% 50%,86% 100%,0 100%)", display: "flex", alignItems: "center", justifyContent: "center", transform: `rotate(4deg) scale(${interpolate(g, [8, 14], [0, 1], CL)})` }}>
        <Gordo tam={84}>LAURA</Gordo>
      </div>
      <MarcoEn cx={540} cy={1000} ancho={560} expresion="triste" f={f} />
      <Ono texto="?" f={g % 40} x={830} y={860} giro={14} tam={170} dura={36} />
    </AbsoluteFill>
  );
};

const Voto: React.FC<{ f: number }> = ({ f }) => (
  <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
    <Fondo a="#ffe066" b="#f08a24" />
    <div style={{ position: "absolute", top: 330, left: 0, right: 0, display: "flex", flexDirection: "column", alignItems: "center" }}>
      <Gordo tam={96}>¿A QUIÉN VE</Gordo>
      <Gordo tam={96} color={AMARILLO}>
        PRIMERO?
      </Gordo>
    </div>
    <CartaVoto n={1} titulo="FAMILIA" color="#2f62b5" icono={<IcoCasa tamano={210} color="#ffcf5a" />} f={f - 4} giro={-5} x={290} />
    <CartaVoto n={2} titulo="LAURA" color="#e0457b" icono={<IcoCorazon tamano={210} color="#ffd1e0" />} f={f - 10} giro={5} x={790} />
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
// [efecto, escena, palabra o fotograma local, volumen]
const SFX: Sfx[] = [
  ["golpe", "gancho", 0, 0.8],
  ["brillo", "gancho", "congelado", 0.5],
  ["whoosh", "como", 0, 0.6],
  ["tic", "como", 4, 0.6],
  ["tic", "como", 8, 0.6],
  ["tic", "como", 12, 0.6],
  ["whoosh", "como", "encerrado", 0.5],
  ["golpe", "despierta", 22, 1],
  ["glitch", "despierta", 24, 0.35],
  ["pop", "despierta", "hongos", 0.7],
  ["pop", "despierta", "nariz", 0.7],
  ["clic", "despierta", "móvil", 0.7],
  ["pop", "mensajes", 4, 0.5],
  ["pop", "mensajes", 12, 0.5],
  ["pop", "mensajes", 20, 0.5],
  ["pop", "mensajes", 28, 0.6],
  ["latido", "mensajes", "Laura", 0.8],
  ["estatica", "flashback", 0, 0.35],
  ["error", "flashback", "nunca", 0.7],
  ["subida", "reto", 0, 0.5],
  ["whoosh", "reto", "solo", 0.5],
  ["whoosh", "voto", 0, 0.6],
  ["exito", "voto", 34, 0.6],
];

export const Episodio1: React.FC = () => {
  const frame = useCurrentFrame();
  const { i, id, local } = L.escenaEn(frame);
  const m = L.marcas(id);
  const dur = L.duraciones[i];
  const sinMusica = Boolean((getInputProps() as { sinMusica?: boolean }).sinMusica);
  const t = (local - L.preDe(id)) / FPS;
  const inicioReto = L.inicios[IDS.indexOf("reto")];

  const escena =
    id === "gancho" ? <Gancho f={local} m={m} /> : id === "como" ? <Como f={local} m={m} dur={dur} /> : id === "despierta" ? <Despierta f={local} m={m} /> : id === "mensajes" ? <Mensajes f={local} m={m} /> : id === "flashback" ? <Flashback f={local} m={m} /> : id === "reto" ? <Reto f={local} m={m} /> : <Voto f={local} />;

  // Sacudida de cámara global en los golpes
  const golpes = [L.inicios[2] + 22, L.inicios[1] + L.duraciones[1] - 22];
  let sx = 0;
  for (const g of golpes) if (frame >= g && frame < g + 10) sx = Math.sin((frame - g) * 2.5) * (10 - (frame - g)) * 2;

  return (
    <AbsoluteFill style={{ background: "#000", overflow: "hidden" }}>
      <AbsoluteFill style={{ transform: `translate(${sx}px, ${sx * 0.6}px)` }}>{escena}</AbsoluteFill>
      {frame >= inicioReto ? <ContadorDia dia={0} f={frame - inicioReto} /> : null}
      <Subtitulo palabras={tiempos.voz[id].palabras} t={t} fps={FPS} claves={CLAVES} cambiar={{ diez: "10" }} y={id === "voto" ? 1290 : 1260} />

      {/* Voz */}
      {IDS.map((k, n) => (
        <Sequence key={k} from={L.inicios[n] + L.preDe(k)} durationInFrames={Math.ceil((tiempos.voz[k].duracion + 0.2) * FPS)}>
          <Audio src={src(`voz-${k}.mp3`)} />
        </Sequence>
      ))}
      {/* Efectos */}
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
          <Sequence key={n} from={L.inicios[k] + loc} durationInFrames={s(3)}>
            <Audio src={src(`sfx-${e}.mp3`)} volume={vol} />
          </Sequence>
        );
      })}
      {sinMusica ? null : <Audio src={src("musica.mp3")} volume={0.22} loop />}
    </AbsoluteFill>
  );
};
