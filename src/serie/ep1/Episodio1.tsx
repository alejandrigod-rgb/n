/**
 * Serie de Marco (cuenta alternativa, no AEZ) · Episodio 1 (historia nueva del 13 de noviembre de 2026):
 * en 2016 sus padres lo echan de casa por no trabajar; en 2026 vive en un hostal gratis, gordo y con granos.
 * Laura lo llama para quedar en un mes con los amigos de siempre, y su madre le pide que vuelva a casa.
 * Tiene 30 días de "glow up" (físico, actitud y trabajo). Votación: ¿familia o Laura?
 * 60 fps, cortes secos cada 1–2 s en las marcas de la voz, subtítulos gigantes palabra a palabra.
 */
import React from "react";
import { AbsoluteFill, Audio, Sequence, getInputProps, interpolate, random, staticFile, useCurrentFrame } from "remotion";
import { IcoCasa, IcoCorazon } from "../../marca/iconos";
import { crearLinea, type Tiempos } from "../../marca/linea";
import { Marco } from "../Marco";
import { MarcoGordo, type ExpresionGordo } from "../MarcoGordo";
import { AMARILLO, CartaVoto, ContadorDia, FUENTE, Gordo, Ono, Rec, Subtitulo, TINTA, punch } from "../piezas";
import tiemposJson from "./tiempos.json";

const FPS = 60;
const tiempos = tiemposJson as unknown as Tiempos;
const IDS = ["gancho", "echado", "ahora", "llamada", "laura", "familia", "reto", "voto"] as const;
type Id = (typeof IDS)[number];
const L = crearLinea({ tiempos, ids: IDS, fps: FPS, pre: { gancho: 0.08, echado: 0.15, ahora: 0.12, llamada: 0.12, laura: 0.12, familia: 0.12, reto: 0.12, voto: 0.12 }, extra: { voto: 1.8, echado: 0.1 }, transicion: 0 });
export const DURACION_EP1 = L.total;
const CL = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;
const CLAVES = ["marco", "10", "echaron", "casa", "trabajas", "hostal", "gratis", "granos", "papada", "cero", "trabajo", "laura", "mes", "amigos", "madre", "vuelve", "30", "fisico", "actitud", "familia", "comenta"];
const s = (n: number) => Math.round(n * FPS);
const src = (f: string) => staticFile(`serie-ep1/${f}`);
type M = (p: string) => number;
/** Marca de una palabra, o un valor de reserva si Whisper no la encontró. */
const marca = (m: M, p: string, def: number) => {
  try {
    return m(p);
  } catch {
    return def;
  }
};

/* ---------- ayudas de dibujo ---------- */

/** Marco (2026) colocado por la posición de su cara (cx, cy) en pantalla. */
const MarcoEn: React.FC<{ cx: number; cy: number; ancho: number; expresion: ExpresionGordo; f: number; movil?: boolean; brazoD?: number; olor?: boolean }> = ({ cx, cy, ancho, f, ...p }) => (
  <div style={{ position: "absolute", left: cx - ancho / 2, top: cy - ancho * 0.45 }}>
    <MarcoGordo ancho={ancho} frame={f / 2} {...p} />
  </div>
);

const Fondo: React.FC<{ a: string; b: string }> = ({ a, b }) => <AbsoluteFill style={{ background: `radial-gradient(circle at 50% 38%, ${a} 0%, ${b} 85%)` }} />;

/** Etiqueta con flecha (para señalar los granos y la papada). */
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

/** Silueta de persona (Laura lleva coleta; su cara no se ve: es parte del misterio). */
const Silueta: React.FC<{ ancho: number; color?: string; coleta?: boolean }> = ({ ancho, color = "#3a2550", coleta = false }) => (
  <svg width={ancho} height={ancho * 2} viewBox="0 0 200 400">
    <g fill={color} stroke={TINTA} strokeWidth={5} strokeLinejoin="round">
      {coleta ? <path d="M120 40 Q170 60 160 130 Q150 110 132 96 Z" /> : null}
      <circle cx={100} cy={70} r={42} />
      <path d="M86 108 L114 108 L116 128 L84 128 Z" />
      <path d={coleta ? "M60 130 Q100 118 140 130 L150 230 L172 330 L28 330 L50 230 Z" : "M54 130 Q100 116 146 130 L150 330 L50 330 Z"} />
      <path d="M62 136 Q36 190 44 250 L60 250 Q58 200 76 160 Z" />
      <path d="M138 136 Q164 190 156 250 L140 250 Q142 200 124 160 Z" />
      <path d="M76 330 L72 392 L92 392 L94 330 Z M106 330 L108 392 L128 392 L124 330 Z" />
    </g>
  </svg>
);

/** Móvil grande dibujado (genérico, sin marca). */
const Movil: React.FC<{ children: React.ReactNode; top?: number; fondo?: string }> = ({ children, top = 170, fondo = "linear-gradient(180deg,#3b5ca8,#7a4fa8)" }) => (
  <div style={{ position: "absolute", left: 160, top, width: 760, height: 1000, background: "#1c1f2b", border: `10px solid ${TINTA}`, borderRadius: 70, padding: 26, boxSizing: "border-box", boxShadow: `0 18px 0 ${TINTA}` }}>
    <div style={{ width: "100%", height: "100%", borderRadius: 48, overflow: "hidden", background: fondo, position: "relative" }}>{children}</div>
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

/** Sello rojo que cae de golpe. */
const Sello: React.FC<{ texto: string; f: number; x?: number; y?: number; giro?: number; tam?: number }> = ({ texto, f, x = 540, y = 820, giro = -14, tam = 130 }) =>
  f < 0 ? null : (
    <div style={{ position: "absolute", left: x, top: y, transform: `translate(-50%,-50%) rotate(${giro}deg) scale(${interpolate(f, [0, 5, 9], [3, 0.92, 1], CL)})`, border: "14px solid #ff2a2a", borderRadius: 24, padding: "14px 36px 0", background: "rgba(255,255,255,0.88)" }}>
      <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: tam, color: "#ff2a2a", whiteSpace: "nowrap" }}>{texto}</span>
    </div>
  );

/** Grano y viñeta de grabación antigua. */
const GranoFilm: React.FC<{ f: number }> = ({ f }) => (
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

/** Fachada de la casa de sus padres (puerta abierta o cerrada). */
const Casa: React.FC<{ abierta: boolean }> = ({ abierta }) => (
  <>
    <AbsoluteFill style={{ background: "linear-gradient(180deg,#9fc7e8 0%,#d9ecf7 60%,#7c9b5a 60%,#5d7a40 100%)" }} />
    <div style={{ position: "absolute", left: 90, top: 470, width: 900, height: 700, background: "#f0d9b5", border: `10px solid ${TINTA}` }} />
    <div style={{ position: "absolute", left: 40, top: 220, width: 1000, height: 260, background: "#b8483a", border: `10px solid ${TINTA}`, clipPath: "polygon(50% 0,100% 100%,0 100%)" }} />
    <div style={{ position: "absolute", left: 150, top: 560, width: 200, height: 180, background: "#bfe3ff", border: `9px solid ${TINTA}` }} />
    <div style={{ position: "absolute", left: 730, top: 560, width: 200, height: 180, background: "#bfe3ff", border: `9px solid ${TINTA}` }} />
    <div style={{ position: "absolute", left: 420, top: 760, width: 240, height: 410, background: abierta ? "#2a1e18" : "#7a4a2a", border: `10px solid ${TINTA}` }}>
      {abierta ? null : <div style={{ position: "absolute", right: 26, top: 200, width: 30, height: 30, borderRadius: 15, background: AMARILLO, border: `5px solid ${TINTA}` }} />}
    </div>
  </>
);

/* ---------- las escenas (cada una con sus planos de corte seco) ---------- */

const Gancho: React.FC<{ f: number; m: M }> = ({ f, m }) => {
  const b = marca(m, "echaron", 80);
  return f < b ? (
    <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
      <Fondo a="#c7b38f" b="#5a4a3a" />
      <MarcoEn cx={540} cy={860} ancho={900} expresion="confuso" f={f} />
      <div style={{ position: "absolute", top: 200, left: 0, right: 0, display: "flex", flexDirection: "column", alignItems: "center" }}>
        <Gordo tam={150} color={AMARILLO} style={{ transform: "rotate(-3deg)" }}>
          10 AÑOS
        </Gordo>
        <Gordo tam={130}>SIN CASA</Gordo>
      </div>
    </AbsoluteFill>
  ) : (
    <AbsoluteFill style={{ transform: `scale(${punch(f - b)})` }}>
      <Fondo a="#e0cfae" b="#6a5844" />
      <MarcoEn cx={540} cy={700} ancho={1400} expresion="pena" f={f} />
    </AbsoluteFill>
  );
};

const Echado: React.FC<{ f: number; m: M; dur: number }> = ({ f, m, dur }) => {
  const b = marca(m, "fue", dur - 60);
  const escena =
    f < b ? (
      <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
        <Casa abierta />
        <div style={{ position: "absolute", left: 450, top: 770 }}>
          <Silueta ancho={180} color="#2c2c3a" />
        </div>
        <div style={{ position: "absolute", left: 40, top: 760 }}>
          <Marco variante="congelado" joven ancho={330} ojos="confusos" />
        </div>
        <div style={{ position: "absolute", left: 540, top: 300, transform: `translateX(-50%) scale(${interpolate(f, [4, 10, 14], [0, 1.15, 1], CL)}) rotate(-3deg)` }}>
          <div style={{ background: "#fff", border: `9px solid ${TINTA}`, borderRadius: 40, padding: "14px 34px 4px", textAlign: "center", whiteSpace: "nowrap" }}>
            <div style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 80, color: TINTA, lineHeight: 1 }}>¡O TRABAJAS</div>
            <div style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 80, color: "#e0453b", lineHeight: 1.1 }}>O TE VAS!</div>
          </div>
        </div>
      </AbsoluteFill>
    ) : (
      <AbsoluteFill style={{ transform: `scale(${punch(f - b)})` }}>
        <Casa abierta={false} />
        <div style={{ position: "absolute", left: 120 - (f - b) * 3, top: 900 }}>
          <Marco variante="congelado" joven ancho={300} ojos="cerrados" />
        </div>
        <Ono texto="¡PUM!" f={f - b} x={760} y={640} giro={10} dura={50} />
      </AbsoluteFill>
    );
  return (
    <AbsoluteFill>
      <AbsoluteFill style={{ filter: "sepia(0.7) saturate(1.3) contrast(1.05)" }}>{escena}</AbsoluteFill>
      <GranoFilm f={f} />
      <Rec f={f} fecha="13·11·2016" />
    </AbsoluteFill>
  );
};

/** Habitación del hostal: literas, papel despegado y el letrero. */
const Hostal: React.FC = () => (
  <>
    <AbsoluteFill style={{ background: "linear-gradient(180deg,#8d9a7a 0%,#a7b18f 70%,#6e5a46 70%,#5a4838 100%)" }} />
    {[0, 1].map((k) => (
      <div key={k} style={{ position: "absolute", left: k ? 760 : 30, top: 560, width: 290, height: 820 }}>
        <div style={{ position: "absolute", left: 0, top: 0, width: 24, height: 820, background: "#5c6470", border: `5px solid ${TINTA}` }} />
        <div style={{ position: "absolute", right: 0, top: 0, width: 24, height: 820, background: "#5c6470", border: `5px solid ${TINTA}` }} />
        {[150, 560].map((y) => (
          <div key={y} style={{ position: "absolute", left: 10, right: 10, top: y, height: 70, background: "#d9d2c0", border: `6px solid ${TINTA}`, borderRadius: 10 }} />
        ))}
      </div>
    ))}
    <div style={{ position: "absolute", left: 230, top: 320, width: 620, height: 130, background: "#2b2440", border: `8px solid ${TINTA}`, borderRadius: 20, display: "flex", alignItems: "center", justifyContent: "center", boxShadow: "0 0 40px rgba(255,90,170,0.6)" }}>
      <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 74, color: "#ff7ac0", textShadow: "0 0 16px #ff4fa8", marginTop: 10, whiteSpace: "nowrap" }}>HOSTAL GRATIS</span>
    </div>
  </>
);

const Ahora: React.FC<{ f: number; m: M }> = ({ f, m }) => {
  const b = marca(m, "Granos", 100);
  const c = marca(m, "cero", b + 80);
  const pap = marca(m, "papada", b + 40);
  if (f < b) {
    return (
      <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
        <Hostal />
        <MarcoEn cx={540} cy={870} ancho={700} expresion="triste" f={f} />
        <div style={{ position: "absolute", left: 50, top: 210, background: AMARILLO, border: `7px solid ${TINTA}`, borderRadius: 20, padding: "4px 24px 0", transform: "rotate(-4deg)" }}>
          <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 64, color: TINTA }}>2026</span>
        </div>
      </AbsoluteFill>
    );
  }
  if (f < c) {
    return (
      <AbsoluteFill style={{ transform: `scale(${punch(f - b)})` }}>
        <Fondo a="#f3d3b5" b="#a2674a" />
        <MarcoEn cx={540} cy={560} ancho={1300} expresion="asco" f={f} olor={false} />
        <Etiqueta texto="GRANOS" x={860} y={330} ax={761} ay={651} f={f - b - 2} giro={5} />
        <Etiqueta texto="PAPADA" x={230} y={1060} ax={430} ay={960} f={f - pap} />
      </AbsoluteFill>
    );
  }
  return (
    <AbsoluteFill style={{ transform: `scale(${punch(f - c)})` }}>
      <Hostal />
      <MarcoEn cx={540} cy={870} ancho={700} expresion="pena" f={f} />
      <Sello texto="CERO TRABAJO" f={f - c - 4} y={700} tam={110} />
    </AbsoluteFill>
  );
};

const Llamada: React.FC<{ f: number; m: M }> = ({ f, m }) => {
  const b = marca(m, "Laura", 50);
  if (f < b) {
    const vib = Math.sin(f * 2.4) * 8;
    return (
      <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
        <Fondo a="#3a3f5c" b="#0f1220" />
        <div style={{ position: "absolute", inset: 0, transform: `translateX(${vib}px) rotate(${vib * 0.15}deg)` }}>
          <Movil fondo="linear-gradient(180deg,#e0457b,#7a2f8f)">
            <div style={{ textAlign: "center", marginTop: 110 }}>
              <div style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 48, color: "#ffffffcc" }}>LLAMADA ENTRANTE</div>
              <div style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 150, color: "#fff", lineHeight: 1.1 }}>???</div>
            </div>
          </Movil>
        </div>
        <Ono texto="RING" f={f % 24} x={170} y={330} giro={-14} tam={120} color="#ffffff" dura={16} />
      </AbsoluteFill>
    );
  }
  return (
    <AbsoluteFill style={{ transform: `scale(${punch(f - b)})` }}>
      <Fondo a="#ffe1ec" b="#d0457b" />
      <MarcoEn cx={540} cy={700} ancho={880} expresion="susto" movil brazoD={115} f={f} />
      <div style={{ position: "absolute", left: 0, right: 0, top: 230, display: "flex", justifyContent: "center" }}>
        <Gordo tam={110} color="#ffffff" style={{ transform: "rotate(-3deg)" }}>
          ES <span style={{ color: AMARILLO }}>LAURA</span>
        </Gordo>
      </div>
    </AbsoluteFill>
  );
};

const LauraEsc: React.FC<{ f: number; m: M }> = ({ f, m }) => {
  const b = marca(m, "amigos", 90);
  if (f < b) {
    return (
      <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
        <Fondo a="#ffb3cf" b="#8a2f5f" />
        {Array.from({ length: 10 }, (_, i) => (
          <div key={i} style={{ position: "absolute", left: random(`c${i}`) * 960, top: 260 + random(`d${i}`) * 900 - ((f * (1 + random(`v${i}`))) % 200) }}>
            <IcoCorazon tamano={50 + random(`t${i}`) * 50} color="#ffd1e0" />
          </div>
        ))}
        <div style={{ position: "absolute", left: 360, top: 470 }}>
          <Silueta ancho={360} coleta />
        </div>
        <div style={{ position: "absolute", left: 540, top: 280, transform: `translateX(-50%) scale(${interpolate(f, [4, 10, 14], [0, 1.15, 1], CL)}) rotate(3deg)` }}>
          <div style={{ background: "#fff", border: `9px solid ${TINTA}`, borderRadius: 40, padding: "14px 34px 4px", whiteSpace: "nowrap" }}>
            <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 78, color: "#e0457b" }}>¿QUEDAMOS?</span>
          </div>
        </div>
      </AbsoluteFill>
    );
  }
  const g = f - b;
  return (
    <AbsoluteFill style={{ transform: `scale(${punch(g)})` }}>
      <Fondo a="#ffd6a0" b="#c4572f" />
      {[
        [60, "#2f4a6b", false],
        [300, "#3a2550", true],
        [560, "#28503a", false],
        [800, "#5a2f2f", false],
      ].map(([x, c, col], k) => (
        <div key={k} style={{ position: "absolute", left: x as number, top: 700 + (k % 2) * 30, transform: `scale(${interpolate(g, [k * 4, k * 4 + 6], [0, 1], CL)})`, transformOrigin: "50% 100%" }}>
          <Silueta ancho={240} color={c as string} coleta={col as boolean} />
        </div>
      ))}
      <div style={{ position: "absolute", left: 140, top: 260, width: 800, height: 280, background: "#fff", border: `9px solid ${TINTA}`, borderRadius: 34, boxShadow: `0 12px 0 ${TINTA}`, transform: `rotate(-2deg) scale(${interpolate(g, [16, 22, 26], [0, 1.08, 1], CL)})`, padding: "26px 36px", boxSizing: "border-box" }}>
        <div style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 52, color: "#6b6170" }}>LOS DE SIEMPRE</div>
        <div style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 92, color: TINTA, lineHeight: 1.1 }}>
          QUEDADA: <span style={{ color: "#e0453b" }}>DÍA 30</span>
        </div>
      </div>
    </AbsoluteFill>
  );
};

const Familia: React.FC<{ f: number; m: M }> = ({ f, m }) => {
  const b = marca(m, "vuelve", 70);
  if (f < b) {
    return (
      <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
        <Fondo a="#9cc2f0" b="#24467f" />
        <Movil top={190}>
          <div style={{ textAlign: "center", marginTop: 40 }}>
            <div style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 130, color: "#fff", lineHeight: 1 }}>23:47</div>
          </div>
          <Noti quien="MAMÁ" texto="Hijo, ¿cómo estás?" color="#2f62b5" f={f - 4} y={260} />
          <Noti quien="MAMÁ" texto="Tu padre se arrepiente..." color="#2f62b5" f={f - 14} y={406} />
          <Noti quien="MAMÁ" texto="Vuelve a casa, por favor" color="#2f62b5" f={b - 6 <= f ? f - (b - 6) : -1} y={552} numero={3} />
        </Movil>
      </AbsoluteFill>
    );
  }
  return (
    <AbsoluteFill style={{ transform: `scale(${punch(f - b)})` }}>
      <Fondo a="#c9dcf2" b="#3a5a8f" />
      <div style={{ position: "absolute", left: 540, top: 330, transform: `translate(-50%,-50%) scale(${interpolate(f - b, [0, 6, 10], [0, 1.15, 1], CL)})` }}>
        <IcoCasa tamano={260} color="#ffcf5a" />
      </div>
      <MarcoEn cx={540} cy={860} ancho={900} expresion="pena" f={f} olor={false} />
    </AbsoluteFill>
  );
};

const Reto: React.FC<{ f: number; m: M }> = ({ f, m }) => {
  const b = marca(m, "físico", 60);
  const ac = marca(m, "actitud", b + 40);
  const tr = marca(m, "trabajo", ac + 50);
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
              const e = interpolate(f - i * 0.8, [0, 6], [0, 1], CL);
              return (
                <div key={i} style={{ height: 96, borderRadius: 16, border: `5px solid ${TINTA}`, background: i === 29 ? "#ff7ac0" : "#f1ece3", display: "flex", alignItems: "center", justifyContent: "center", transform: `scale(${e})` }}>
                  <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 50, color: TINTA, marginTop: 6 }}>{i + 1}</span>
                </div>
              );
            })}
          </div>
        </div>
      </AbsoluteFill>
    );
  }
  // Lista del glow up: cada casilla entra cuando se nombra
  const items: [string, number][] = [
    ["FÍSICO", b],
    ["ACTITUD", ac],
    ["TRABAJO", tr],
  ];
  return (
    <AbsoluteFill style={{ transform: `scale(${punch(f - b)})` }}>
      <Fondo a="#ffe066" b="#e0782a" />
      <div style={{ position: "absolute", left: 0, right: 0, top: 330, display: "flex", justifyContent: "center" }}>
        <Gordo tam={120}>GLOW UP</Gordo>
      </div>
      {items.map(([t, at], k) => {
        const e = interpolate(f - at, [0, 5, 9], [0, 1.12, 1], CL);
        return (
          <div key={t} style={{ position: "absolute", left: 140, top: 520 + k * 190, width: 800, height: 160, background: "#fff", border: `9px solid ${TINTA}`, borderRadius: 30, boxShadow: `0 10px 0 ${TINTA}`, display: "flex", alignItems: "center", gap: 36, padding: "0 40px", boxSizing: "border-box", transform: `scale(${e}) rotate(${(k - 1) * 1.5}deg)` }}>
            <div style={{ width: 90, height: 90, borderRadius: 18, border: `8px solid ${TINTA}`, background: "#f1ece3" }} />
            <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 96, color: TINTA, marginTop: 12 }}>{t}</span>
          </div>
        );
      })}
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
  ["whoosh", "gancho", "echaron", 0.5],
  ["estatica", "echado", 0, 0.35],
  ["pop", "echado", 6, 0.6],
  ["golpe", "echado", "fue", 1],
  ["whoosh", "ahora", 0, 0.5],
  ["pop", "ahora", "Granos", 0.7],
  ["pop", "ahora", "papada", 0.7],
  ["error", "ahora", "cero", 0.7],
  ["cascabel", "llamada", 0, 0.5],
  ["cascabel", "llamada", 24, 0.5],
  ["latido", "llamada", "Laura", 0.8],
  ["brillo", "laura", 0, 0.5],
  ["pop", "laura", "amigos", 0.6],
  ["clic", "familia", 4, 0.6],
  ["clic", "familia", 14, 0.6],
  ["latido", "familia", "vuelve", 0.6],
  ["subida", "reto", 0, 0.5],
  ["tic", "reto", "físico", 0.8],
  ["tic", "reto", "actitud", 0.8],
  ["tic", "reto", "trabajo", 0.8],
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
    id === "gancho" ? (
      <Gancho f={local} m={m} />
    ) : id === "echado" ? (
      <Echado f={local} m={m} dur={dur} />
    ) : id === "ahora" ? (
      <Ahora f={local} m={m} />
    ) : id === "llamada" ? (
      <Llamada f={local} m={m} />
    ) : id === "laura" ? (
      <LauraEsc f={local} m={m} />
    ) : id === "familia" ? (
      <Familia f={local} m={m} />
    ) : id === "reto" ? (
      <Reto f={local} m={m} />
    ) : (
      <Voto f={local} />
    );

  // Sacudida de cámara en el portazo
  const golpes = [L.inicios[1] + marca(L.marcas("echado"), "fue", 0)];
  let sx = 0;
  for (const g of golpes) if (frame >= g && frame < g + 10) sx = Math.sin((frame - g) * 2.5) * (10 - (frame - g)) * 2;

  return (
    <AbsoluteFill style={{ background: "#000", overflow: "hidden" }}>
      <AbsoluteFill style={{ transform: `translate(${sx}px, ${sx * 0.6}px)` }}>{escena}</AbsoluteFill>
      {frame >= inicioReto ? <ContadorDia dia={0} f={frame - inicioReto} /> : null}
      <Subtitulo palabras={tiempos.voz[id].palabras} t={t} fps={FPS} claves={CLAVES} y={id === "voto" ? 1290 : 1260} />

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
