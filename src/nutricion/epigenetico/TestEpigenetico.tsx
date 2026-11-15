/**
 * Cliente "Alimentación y Equilibrio de Giovana Olivas": el Test Epigenético (15 de noviembre de 2026).
 * El usuario pasó el reel de la clienta (una nutricionista hablando) y pidió uno NUEVO: voz nueva (VoxCPM, mujer, acento latino neutro),
 * detallado, profesional, para TikTok, sin personas. Reglas que pidió y se cumplen aquí:
 *  - Una acción visual por bloque, sincronizada con la palabra que la nombra (marcas de `tiempos.json`).
 *  - Títulos que entran desde la izquierda con ease-in-out y estela de movimiento (`TituloEntra`), y textos revelados con máscara (`Revela`).
 *  - Como mucho 4 palabras en pantalla por escena, aparte de los subtítulos.
 *  - Analogías dibujadas literalmente ("conexión" = un puente de luz; "enfoque" = desenfocado → nítido), magnitudes con escala
 *    (5 hebras diminutas frente a un informe enorme), la cámara sigue lo importante y cada escena termina en una imagen clara.
 *  - Los objetos se conservan y se transforman para abrir la escena siguiente: ADN → pelo → tubo → informe → portátil → burbujas → plato → móvil.
 * Se quitó del guion original "carga electromagnética" (afirmación sin base).
 */
import "@fontsource/baloo-2/800.css";
import "@fontsource/lexend/400.css";
import "@fontsource/lexend/600.css";
import React from "react";
import { AbsoluteFill, Easing, Html5Audio, interpolate, random, Sequence, spring, staticFile, useCurrentFrame } from "remotion";
import { crearLinea, type Tiempos } from "../../marca/linea";
import { Brocoli, Fresa, L, Limon, LogoAyE, Manzana, Palta, Zanahoria } from "../Flyer";
import tiemposJson from "./tiempos.json";

const FPS = 60;
const tiempos = tiemposJson as unknown as Tiempos;
const IDS = ["conexion", "ciencia", "hebras", "informe", "conoceras", "presentacion", "dudas", "agenda"] as const;
type Id = (typeof IDS)[number];
const LINEA = crearLinea({ tiempos, ids: IDS, fps: FPS, pre: { conexion: 0.25, ciencia: 0.1, hebras: 0.1, informe: 0.1, conoceras: 0.1, presentacion: 0.1, dudas: 0.1, agenda: 0.1 }, extra: { agenda: 2.4, conoceras: 0.3 }, transicion: 0 });
export const DURACION_EPIGENETICO = LINEA.total;
const CL = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;
const TIT = "'Baloo 2', sans-serif";
const LEX = "'Lexend', sans-serif";
const OSC = "#16404a";
const ROJO = "#e8546a";
const src = (f: string) => staticFile(`nutricion-epigenetico/${f}`);

/** Inicio (s, global) de la escena y segundo (global) en que se dice una palabra. */
const ini = (id: Id) => LINEA.inicios[IDS.indexOf(id)] / FPS;
const fin = (id: Id) => (LINEA.inicios[IDS.indexOf(id)] + LINEA.duraciones[IDS.indexOf(id)]) / FPS;
const M = (id: Id, w: string, def = 0.5) => {
  try {
    return (LINEA.inicios[IDS.indexOf(id)] + LINEA.marcas(id)(w)) / FPS;
  } catch {
    return ini(id) + def;
  }
};
const io = Easing.inOut(Easing.cubic);
const sale = Easing.out(Easing.cubic);
const muelle = (t: number, desde: number, d = 12) => (t < desde ? 0 : spring({ frame: (t - desde) * FPS, fps: FPS, config: { damping: d, mass: 0.6 } }));
const entre = (t: number, a: number, b: number, e = io) => interpolate(t, [a, b], [0, 1], { ...CL, easing: e });

/* ================= TIPOGRAFÍA ANIMADA ================= */
/** Título que entra desde la izquierda con ease-in-out y estela de movimiento (copias que se quedan atrás según la velocidad). */
const TituloEntra: React.FC<{ t: number; desde: number; hasta?: number; y: number; children: React.ReactNode; color?: string; tam?: number }> = ({ t, desde, hasta, y, children, color = OSC, tam = 96 }) => {
  const dur = 0.7;
  const pos = (tt: number) => {
    const entra = -1300 * (1 - interpolate(tt, [desde, desde + dur], [0, 1], { ...CL, easing: io }));
    const va = hasta === undefined ? 0 : 1400 * interpolate(tt, [hasta - dur * 0.8, hasta], [0, 1], { ...CL, easing: Easing.in(Easing.cubic) });
    return entra + va;
  };
  const x = pos(t);
  const v = (x - pos(t - 1 / FPS)) * FPS; // px/s
  if (t < desde && desde >= 0) return null;
  const estela = Math.min(1, Math.abs(v) / 3000);
  const texto = (op: number, dx: number, k: number) => (
    <div key={k} style={{ position: "absolute", left: 0, right: 0, top: y, display: "flex", justifyContent: "center", transform: `translateX(${x - dx}px) skewX(${-v / 600}deg)`, opacity: op, filter: estela > 0.05 ? `blur(${estela * 6}px)` : undefined }}>
      <span style={{ fontFamily: TIT, fontWeight: 800, fontSize: tam, color, letterSpacing: 1, whiteSpace: "nowrap", textShadow: "0 8px 24px #16404a22" }}>{children}</span>
    </div>
  );
  return (
    <>
      {estela > 0.05 ? [4, 3, 2, 1].map((k) => texto(0.12 * estela, (v / FPS) * k * 1.6, k)) : null}
      {texto(1, 0, 0)}
    </>
  );
};

/** Texto que se revela desde una máscara (sube desde detrás de una línea invisible). */
const Revela: React.FC<{ t: number; desde: number; y: number; children: React.ReactNode; tam?: number; color?: string; fondo?: string }> = ({ t, desde, y, children, tam = 110, color = "#fff", fondo }) => {
  const p = entre(t, desde, desde + 0.55, sale);
  return (
    <div style={{ position: "absolute", left: 0, right: 0, top: y, display: "flex", justifyContent: "center" }}>
      <div style={{ overflow: "hidden", padding: "6px 30px 0", borderRadius: 28, background: fondo, clipPath: `inset(0 ${(1 - entre(t, desde, desde + 0.35, sale)) * 50}% 0 ${(1 - entre(t, desde, desde + 0.35, sale)) * 50}% round 28px)` }}>
        <div style={{ transform: `translateY(${(1 - p) * 110}%)`, fontFamily: TIT, fontWeight: 800, fontSize: tam, color, whiteSpace: "nowrap", lineHeight: 1.1 }}>{children}</div>
      </div>
    </div>
  );
};

/* ================= PIEZAS DIBUJADAS ================= */
/** Doble hélice. `estira` 0-1 la endereza hasta ser un pelo. */
const ADN: React.FC<{ t: number; alto?: number; estira?: number; brillo?: number }> = ({ t, alto = 760, estira = 0, brillo = 0 }) => {
  const n = 22;
  return (
    <svg width={360} height={alto} viewBox={`-180 0 360 ${alto}`} style={{ overflow: "visible", filter: brillo ? `drop-shadow(0 0 ${20 * brillo}px ${L.azul})` : undefined }}>
      {Array.from({ length: n }, (_, i) => {
        const y = 20 + (i / (n - 1)) * (alto - 40);
        const fase = i * 0.55 + t * 2.6;
        const amp = 120 * (1 - estira);
        const x1 = Math.sin(fase) * amp,
          x2 = -Math.sin(fase) * amp;
        const delante = Math.cos(fase) > 0;
        return (
          <g key={i} opacity={(0.45 + 0.55 * Math.abs(Math.cos(fase))) * (1 - estira * 0.6)}>
            <line x1={x1} y1={y} x2={x2} y2={y} stroke={i % 2 ? L.verde : L.azul} strokeWidth={8} strokeLinecap="round" opacity={1 - estira} />
            <circle cx={x1} cy={y} r={(delante ? 15 : 10) * (1 - estira * 0.7)} fill={L.azul} />
            <circle cx={x2} cy={y} r={(delante ? 10 : 15) * (1 - estira * 0.7)} fill={L.verdeOsc} />
          </g>
        );
      })}
      {estira > 0 ? <path d={`M0 0 C${30 * Math.sin(t)} ${alto * 0.3} ${-30 * Math.sin(t)} ${alto * 0.6} 0 ${alto}`} fill="none" stroke="#4a2d1e" strokeWidth={14} strokeLinecap="round" opacity={estira} /> : null}
    </svg>
  );
};

/** Plato con comida (los alimentos aparecen con `lleno` 0-1). */
const Plato: React.FC<{ t: number; tam?: number; lleno?: number }> = ({ t, tam = 380, lleno = 1 }) => {
  const comidas = [Manzana, Brocoli, Palta, Limon, Fresa, Zanahoria];
  return (
    <div style={{ position: "relative", width: tam, height: tam }}>
      <div style={{ position: "absolute", inset: 0, borderRadius: "50%", background: "radial-gradient(circle at 40% 35%, #ffffff 0%, #eef6f7 60%, #d6e6ea 100%)", boxShadow: "0 30px 60px #16404a26, inset 0 -10px 30px #00000010" }} />
      <div style={{ position: "absolute", inset: tam * 0.12, borderRadius: "50%", border: `4px solid #dbe9ec` }} />
      {comidas.map((C, k) => {
        const a = (k / comidas.length) * Math.PI * 2 + 0.3;
        const e = interpolate(lleno, [k / comidas.length, (k + 1) / comidas.length], [0, 1], CL);
        return (
          <div key={k} style={{ position: "absolute", left: tam / 2 + Math.cos(a) * tam * 0.22 - tam * 0.14, top: tam / 2 + Math.sin(a) * tam * 0.22 - tam * 0.14, transform: `scale(${e}) rotate(${Math.sin(t + k) * 5}deg)` }}>
            <C t={tam * 0.28} />
          </div>
        );
      })}
    </div>
  );
};

/** Iconos de ciencia: matraz y microscopio. */
const Matraz: React.FC<{ t: number; tam?: number }> = ({ t, tam = 150 }) => (
  <svg width={tam} height={tam} viewBox="0 0 100 100">
    <path d="M38 8 H62 M42 8 V38 L18 82 Q14 92 26 92 H74 Q86 92 82 82 L58 38 V8" fill="#ffffffcc" stroke={OSC} strokeWidth={5} strokeLinejoin="round" />
    <path d="M28 66 H72 L80 84 Q82 88 76 88 H24 Q18 88 20 84 Z" fill={L.verde} />
    {[0, 1, 2].map((k) => (
      <circle key={k} cx={40 + k * 10} cy={78 - ((t * 30 + k * 10) % 30)} r={3} fill="#fff" />
    ))}
  </svg>
);
const Microscopio: React.FC<{ tam?: number }> = ({ tam = 150 }) => (
  <svg width={tam} height={tam} viewBox="0 0 100 100">
    <rect x={20} y={84} width={60} height={10} rx={4} fill={OSC} />
    <path d="M60 84 Q78 70 70 50" fill="none" stroke={OSC} strokeWidth={7} strokeLinecap="round" />
    <rect x={40} y={14} width={16} height={46} rx={5} fill={L.azul} transform="rotate(-25 48 37)" />
    <rect x={30} y={60} width={34} height={7} rx={3} fill={OSC} />
    <circle cx={39} cy={12} r={6} fill={OSC} />
  </svg>
);

/** Tubo de muestra con las hebras dentro (`hebras` 0-5). */
const Tubo: React.FC<{ hebras: number; tam?: number }> = ({ hebras, tam = 1 }) => (
  <svg width={160 * tam} height={420 * tam} viewBox="0 0 160 420">
    <rect x={20} y={0} width={120} height={40} rx={12} fill={L.verde} />
    <path d="M32 36 V360 A48 48 0 0 0 128 360 V36" fill="#ffffffdd" stroke="#9fc4d2" strokeWidth={8} />
    {Array.from({ length: 5 }, (_, k) => (
      <path key={k} d={`M${58 + k * 11} 90 C${48 + k * 12} 190 ${72 + k * 9} 280 ${62 + k * 10} 370`} fill="none" stroke="#4a2d1e" strokeWidth={5} strokeLinecap="round" opacity={hebras > k ? 1 : 0} />
    ))}
    <path d="M46 60 V350" stroke="#fff" strokeWidth={10} strokeLinecap="round" opacity={0.7} />
  </svg>
);

/** El informe: portada con logo, barras y gráficas. `abre` 0-1 despliega las páginas en abanico. */
const Informe: React.FC<{ t: number; abre: number; ancho?: number }> = ({ t, abre, ancho = 560 }) => {
  const alto = ancho * 1.35;
  return (
    <div style={{ position: "relative", width: ancho, height: alto }}>
      {[3, 2, 1].map((k) => (
        <div key={k} style={{ position: "absolute", inset: 0, background: "#fff", borderRadius: 24, boxShadow: "0 20px 40px #16404a22", transform: `translate(${abre * k * 70}px, ${-abre * k * 10}px) rotate(${abre * k * 7}deg)`, transformOrigin: "50% 100%", padding: 34, boxSizing: "border-box" }}>
          {Array.from({ length: 6 }, (_, j) => (
            <div key={j} style={{ height: 14, width: `${50 + ((j * 37 + k * 13) % 45)}%`, background: "#e3eef1", borderRadius: 7, marginBottom: 20 }} />
          ))}
          <svg width="100%" height={ancho * 0.4} viewBox="0 0 100 40">
            {Array.from({ length: 8 }, (_, j) => (
              <rect key={j} x={4 + j * 12} y={40 - (10 + ((j * 7 + k * 5) % 25))} width={8} height={10 + ((j * 7 + k * 5) % 25)} rx={2} fill={j % 2 ? L.verde : L.azul} />
            ))}
          </svg>
        </div>
      ))}
      <div style={{ position: "absolute", inset: 0, background: "#fff", borderRadius: 24, boxShadow: "0 30px 60px #16404a30", overflow: "hidden" }}>
        <div style={{ height: alto * 0.3, background: `linear-gradient(135deg, ${L.azul}, ${L.verde})`, padding: 30, boxSizing: "border-box", display: "flex", flexDirection: "column", justifyContent: "flex-end" }}>
          <div style={{ fontFamily: LEX, fontWeight: 600, fontSize: ancho * 0.045, color: "#ffffffcc" }}>Informe epigenético</div>
          <div style={{ fontFamily: TIT, fontWeight: 800, fontSize: ancho * 0.085, color: "#fff", lineHeight: 1 }}>TU RESULTADO</div>
        </div>
        <div style={{ padding: 30 }}>
          {[0.82, 0.64, 0.9, 0.48].map((v, j) => (
            <div key={j} style={{ display: "flex", alignItems: "center", gap: 14, marginBottom: 22 }}>
              <div style={{ width: 28, height: 28, borderRadius: 14, background: [L.azul, L.verde, "#f2a33a", ROJO][j] }} />
              <div style={{ flex: 1, height: 18, background: "#edf3f4", borderRadius: 9, overflow: "hidden" }}>
                <div style={{ width: `${v * 100 * Math.min(1, abre * 1.4)}%`, height: "100%", background: [L.azul, L.verde, "#f2a33a", ROJO][j], borderRadius: 9 }} />
              </div>
            </div>
          ))}
          <svg width="100%" height={ancho * 0.22} viewBox="0 0 100 22">
            <path d={`M0 18 ${Array.from({ length: 11 }, (_, i) => `L${i * 10} ${18 - (Math.sin(i * 1.1 + t) + 1.2) * 6 * Math.min(1, abre * 1.4)}`).join(" ")}`} fill="none" stroke={L.azul} strokeWidth={1.6} />
          </svg>
        </div>
      </div>
    </div>
  );
};

/** Intestino (microbioma) con bacterias buenas moviéndose. */
const Intestino: React.FC<{ t: number; tam?: number }> = ({ t, tam = 200 }) => (
  <svg width={tam} height={tam} viewBox="0 0 100 100">
    <path d="M30 20 H70 Q84 20 84 34 Q84 46 70 46 H32 Q18 46 18 60 Q18 74 32 74 H70 Q84 74 84 86" fill="none" stroke="#f0a3a8" strokeWidth={14} strokeLinecap="round" />
    <path d="M30 20 H70 Q84 20 84 34 Q84 46 70 46 H32 Q18 46 18 60 Q18 74 32 74 H70 Q84 74 84 86" fill="none" stroke="#f7c6c9" strokeWidth={6} strokeLinecap="round" />
    {Array.from({ length: 6 }, (_, k) => {
      const u = ((t * 0.15 + k / 6) % 1) * 4;
      const tramo = Math.floor(u),
        f = u - tramo;
      const pts: [number, number][] = tramo === 0 ? [[30 + f * 40, 20]] : tramo === 1 ? [[70 - f * 38, 46]] : tramo === 2 ? [[32 + f * 38, 74]] : [[70 + f * 14, 74 + f * 12]];
      return <ellipse key={k} cx={pts[0][0]} cy={pts[0][1]} rx={5} ry={3} fill={k % 2 ? L.verde : L.azul} />;
    })}
  </svg>
);

/** Portátil con una "diapositiva". */
const Portatil: React.FC<{ t: number; children?: React.ReactNode }> = ({ t, children }) => (
  <div style={{ position: "relative", width: 820, height: 560 }}>
    <div style={{ position: "absolute", left: 60, top: 0, width: 700, height: 460, background: "#1c2a30", borderRadius: 28, padding: 18, boxSizing: "border-box", boxShadow: "0 30px 60px #16404a33" }}>
      <div style={{ width: "100%", height: "100%", background: "#f6fbfc", borderRadius: 14, overflow: "hidden", position: "relative" }}>{children}</div>
    </div>
    <div style={{ position: "absolute", left: 0, top: 460, width: 820, height: 44, background: "linear-gradient(180deg,#cfdde2,#a9bcc3)", borderRadius: "6px 6px 30px 30px" }} />
    <div style={{ position: "absolute", left: 340, top: 462, width: 140, height: 10, background: "#8ea4ab", borderRadius: 5, opacity: 0.6 + 0.4 * Math.sin(t * 3) }} />
  </div>
);

const Burbuja: React.FC<{ lado: "izq" | "der"; texto: React.ReactNode; color: string }> = ({ lado, texto, color }) => (
  <div style={{ background: color, color: lado === "izq" ? OSC : "#fff", fontFamily: LEX, fontWeight: 600, fontSize: 34, padding: "18px 28px", borderRadius: lado === "izq" ? "30px 30px 30px 6px" : "30px 30px 6px 30px", boxShadow: "0 12px 30px #16404a22", whiteSpace: "nowrap" }}>{texto}</div>
);

/** Signo que gira de "?" a "✓" (dibujado, sin emojis). */
const DudaCheck: React.FC<{ resuelta: number; tam?: number }> = ({ resuelta, tam = 130 }) => {
  const giro = resuelta * 180;
  const verde = resuelta > 0.5;
  return (
    <div style={{ width: tam, height: tam, transform: `rotateY(${giro}deg)`, borderRadius: "50%", background: verde ? L.verde : "#f2a33a", boxShadow: `0 14px 30px ${verde ? L.verde : "#f2a33a"}66`, display: "flex", alignItems: "center", justifyContent: "center" }}>
      <svg width={tam * 0.6} height={tam * 0.6} viewBox="0 0 100 100" style={{ transform: verde ? "scaleX(-1)" : undefined }}>
        {verde ? <path d="M18 54 L42 76 L84 26" fill="none" stroke="#fff" strokeWidth={14} strokeLinecap="round" strokeLinejoin="round" /> : <path d="M32 34 Q32 14 52 14 Q72 14 72 32 Q72 46 54 52 V64 M54 82 V86" fill="none" stroke="#fff" strokeWidth={13} strokeLinecap="round" />}
      </svg>
    </div>
  );
};

/** Móvil con calendario: el día `marcado` 0-1 se rodea y se confirma. */
const MovilAgenda: React.FC<{ t: number; marcado: number }> = ({ t, marcado }) => (
  <div style={{ width: 520, height: 900, borderRadius: 70, background: "#1c2a30", padding: 20, boxSizing: "border-box", boxShadow: "0 40px 80px #16404a44" }}>
    <div style={{ width: "100%", height: "100%", borderRadius: 52, background: "#f6fbfc", overflow: "hidden", padding: "40px 30px", boxSizing: "border-box" }}>
      <div style={{ fontFamily: LEX, fontWeight: 600, fontSize: 30, color: L.azulTexto, textAlign: "center" }}>Agenda tu cita</div>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(7, 1fr)", gap: 10, marginTop: 26 }}>
        {Array.from({ length: 28 }, (_, i) => {
          const es = i === 17;
          return (
            <div key={i} style={{ height: 52, borderRadius: 14, display: "flex", alignItems: "center", justifyContent: "center", fontFamily: LEX, fontWeight: 600, fontSize: 24, color: es && marcado > 0.5 ? "#fff" : OSC, background: es ? `rgba(140,198,62,${marcado})` : "#e8f1f3", transform: es ? `scale(${1 + 0.25 * Math.sin(marcado * Math.PI)})` : undefined }}>
              {i + 1}
            </div>
          );
        })}
      </div>
      <div style={{ marginTop: 34, background: `linear-gradient(90deg, ${L.azul}, ${L.verde})`, borderRadius: 999, padding: "18px 0 12px", textAlign: "center", fontFamily: TIT, fontWeight: 800, fontSize: 42, color: "#fff", opacity: 0.4 + 0.6 * marcado, transform: `scale(${1 + 0.03 * Math.sin(t * 6) * marcado})` }}>
        {marcado > 0.5 ? "CITA CONFIRMADA" : "RESERVAR"}
      </div>
    </div>
  </div>
);

/* ================= CÁMARA Y FONDO ================= */
type Cam = { x: number; y: number; s: number };
/** La cámara va de plano en plano con ease-in-out: [segundo, plano]. Siempre deriva un poco (nunca está quieta). */
const camara = (t: number, planos: [number, Cam][]): Cam => {
  let c = planos[0][1];
  for (let i = 1; i < planos.length; i++) {
    const [en, d] = planos[i];
    const p = entre(t, en, en + 0.8);
    c = { x: c.x + (d.x - c.x) * p, y: c.y + (d.y - c.y) * p, s: c.s + (d.s - c.s) * p };
  }
  return { x: c.x + Math.sin(t * 0.6) * 6, y: c.y + Math.cos(t * 0.5) * 6, s: c.s * (1 + 0.006 * Math.sin(t * 0.8)) };
};
const Camara: React.FC<{ cam: Cam; children: React.ReactNode }> = ({ cam, children }) => (
  <AbsoluteFill style={{ transformOrigin: "0 0", transform: `translate(540px, 960px) scale(${cam.s}) translate(${-cam.x}px, ${-cam.y}px)` }}>{children}</AbsoluteFill>
);

const Fondo: React.FC<{ t: number }> = ({ t }) => (
  <AbsoluteFill style={{ background: "linear-gradient(170deg, #f3fbfd 0%, #eaf6f2 55%, #f4f9ea 100%)", overflow: "hidden" }}>
    {[
      [160, 260, 420, L.azul],
      [920, 640, 380, L.verde],
      [260, 1560, 480, L.verde],
      [900, 1680, 360, L.azul],
    ].map(([x, y, r, c], k) => (
      <div key={k} style={{ position: "absolute", left: (x as number) - (r as number) + Math.sin(t * 0.4 + k) * 40, top: (y as number) - (r as number) + Math.cos(t * 0.3 + k) * 40, width: (r as number) * 2, height: (r as number) * 2, borderRadius: "50%", background: c as string, opacity: 0.12, filter: "blur(60px)" }} />
    ))}
    {/* rejilla de puntos de laboratorio, muy suave */}
    <svg width={1080} height={1920} style={{ position: "absolute", opacity: 0.25 }}>
      {Array.from({ length: 13 * 23 }, (_, i) => {
        const x = (i % 13) * 90 + 30,
          y = Math.floor(i / 13) * 90 + 20 + ((t * 12) % 90);
        return <circle key={i} cx={x} cy={y} r={2.2} fill={L.azul} />;
      })}
    </svg>
    {Array.from({ length: 14 }, (_, i) => {
      const y = ((random(`py${i}`) * 2100 - t * (20 + random(`pv${i}`) * 30)) % 2100 + 2100) % 2100 - 100;
      return <div key={i} style={{ position: "absolute", left: random(`px${i}`) * 1080, top: y, width: 10 + (i % 4) * 6, height: 10 + (i % 4) * 6, borderRadius: "50%", background: i % 2 ? L.verde : L.azul, opacity: 0.18 }} />;
    })}
  </AbsoluteFill>
);

/* ================= SUBTÍTULOS ================= */
const CLAVES = new Set(["conexion", "genetica", "nutricion", "ciencia", "epigenetico", "cinco", "hebras", "informe", "detallado", "vitaminas", "minerales", "microbioma", "sensibilidad", "presentacion", "resultados", "dudas", "optimizar", "agenda"]);
const norm = (w: string) => w.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/[^a-z0-9]/g, "");
const Subtitulos: React.FC<{ t: number }> = ({ t }) => {
  const { id, local } = LINEA.escenaEn(Math.round(t * FPS));
  const ts = (local - LINEA.preDe(id)) / FPS;
  const pal = tiempos.voz[id].palabras;
  const grupos: (typeof pal)[] = [];
  let g: typeof pal = [];
  pal.forEach((w) => {
    g.push(w);
    if (/[,.:;?!]$/.test(w.p) || g.length >= 3) {
      grupos.push(g);
      g = [];
    }
  });
  if (g.length) grupos.push(g);
  const i = grupos.findIndex((gr, k) => ts >= gr[0].ini - 0.05 && ts < (grupos[k + 1] ? grupos[k + 1][0].ini - 0.05 : gr[gr.length - 1].fin + 0.4));
  if (i < 0) return null;
  const gr = grupos[i];
  const e = interpolate(ts, [gr[0].ini - 0.05, gr[0].ini + 0.1], [0.85, 1], CL);
  return (
    <div style={{ position: "absolute", left: 60, right: 60, top: 1400, display: "flex", justifyContent: "center", flexWrap: "wrap", gap: "0 16px", transform: `scale(${e})` }}>
      {gr.map((w, k) => {
        const limpio = w.p.replace(/[¿?,.:;!]/g, "");
        const clave = CLAVES.has(norm(limpio));
        return (
          <span key={k} style={{ fontFamily: TIT, fontWeight: 800, fontSize: 84, lineHeight: 1.05, textTransform: "uppercase", color: clave ? (k % 2 ? L.verdeOsc : L.azulTexto) : OSC, opacity: ts >= w.ini - 0.03 ? 1 : 0.32, WebkitTextStroke: "9px #ffffff", paintOrder: "stroke fill", filter: "drop-shadow(0 6px 10px #16404a30)" }}>
            {limpio}
          </span>
        );
      })}
    </div>
  );
};

/* ================= EL MUNDO: todo vive en un mismo espacio y se transforma ================= */
export const TestEpigenetico: React.FC = () => {
  const f = useCurrentFrame();
  const t = f / FPS;

  // marcas clave
  const tConex = M("conexion", "conexión", 0.4),
    tGen = M("conexion", "genética", 1.2),
    tNut = M("conexion", "nutrición", 2);
  const tEnf = M("ciencia", "enfoque", 0.4),
    tCien = M("ciencia", "ciencia,", 1.4),
    tTest = M("ciencia", "Test", 2.4);
  const tCinco = M("hebras", "cinco", 0.6),
    tCab = M("hebras", "cabello.", 1.6);
  const tRec = M("informe", "recibirás", 0.6),
    tDet = M("informe", "detallado", 1.6),
    tToda = M("informe", "toda", 2.2);
  const tVit = M("conoceras", "vitaminas", 0.5),
    tMic = M("conoceras", "microbioma", 1.8),
    tSen = M("conoceras", "sensibilidad", 3);
  const tPres = M("presentacion", "presentación", 1),
    tConv = M("presentacion", "conversamos", 1.8);
  const tDud = M("dudas", "dudas,", 0.6),
    tDet2 = M("dudas", "detalle", 1.2),
    tOpt = M("dudas", "optimizar", 2.4);
  const tEsc = M("agenda", "escríbenos", 0.8),
    tAg = M("agenda", "agenda", 1.6);

  const I = (id: Id) => ini(id);
  const F = (id: Id) => fin(id);

  // la cámara sigue lo importante en cada momento
  const cam = camara(t, [
    [0, { x: 540, y: 820, s: 1 }],
    [tGen - 0.3, { x: 330, y: 820, s: 1.25 }],
    [tNut - 0.3, { x: 760, y: 820, s: 1.25 }],
    [I("ciencia") - 0.2, { x: 540, y: 820, s: 1 }],
    [I("hebras") - 0.2, { x: 540, y: 860, s: 1.05 }],
    [I("informe") + 0.2, { x: 540, y: 820, s: 1 }],
    [tToda, { x: 560, y: 900, s: 0.92 }],
    [I("conoceras") - 0.1, { x: 560, y: 760, s: 1.3 }],
    [I("presentacion"), { x: 540, y: 800, s: 1 }],
    [tConv - 0.2, { x: 540, y: 860, s: 1.05 }],
    [I("dudas"), { x: 540, y: 800, s: 1 }],
    [I("agenda"), { x: 540, y: 820, s: 1 }],
  ]);

  /* ---- 1 · CONEXIÓN: ADN a la izquierda, plato a la derecha y un puente de luz entre ellos ---- */
  const juntar = entre(t, I("ciencia") - 0.1, I("ciencia") + 0.7); // al pasar a "ciencia" se juntan en el centro
  const aPelo = entre(t, I("hebras") - 0.1, I("hebras") + 0.9); // el ADN se estira hasta ser un pelo
  const adnX = interpolate(juntar, [0, 1], [300, 540]),
    adnEsc = interpolate(aPelo, [0, 1], [1, 0.85]);
  const platoX = interpolate(juntar, [0, 1], [790, 540]);
  const puente = entre(t, tConex - 0.05, tConex + 0.7, sale) * (1 - juntar);
  const enfoque = interpolate(t, [tEnf - 0.1, tEnf + 0.6], [10, 0], { ...CL, easing: sale }) * (t >= I("ciencia") - 0.1 ? 1 : 0);
  const verAdn = t < I("informe") + 0.2;
  const verPlato = t < I("hebras") + 0.2;

  /* ---- 3 · HEBRAS: cinco pelos contados y el tubo ---- */
  const enTubo = entre(t, tCab, tCab + 0.7);
  const hebrasVis = t < tCinco ? 0 : Math.min(5, Math.floor((t - tCinco) / 0.12) + 1);

  /* ---- 4 · INFORME: el tubo se encoge y el informe crece a su lado (escala: 5 hebras → un informe enorme) ---- */
  const informeE = entre(t, tRec - 0.2, tRec + 0.6, sale);
  const abre = entre(t, tDet - 0.1, tDet + 0.8);
  const aPantalla = entre(t, I("presentacion") - 0.1, I("presentacion") + 0.8); // el informe vuela al portátil
  const verInforme = t > I("informe") - 0.1 && t < I("presentacion") + 0.9;

  /* ---- 6 → 7 → 8 ---- */
  const portatilE = entre(t, I("presentacion") + 0.2, I("presentacion") + 0.9, sale) * (1 - entre(t, I("dudas") - 0.1, I("dudas") + 0.5));
  const dudasE = entre(t, I("dudas") - 0.1, I("dudas") + 0.5, sale) * (1 - entre(t, tOpt - 0.2, tOpt + 0.4));
  const platoFinal = entre(t, tOpt - 0.1, tOpt + 0.5, sale) * (1 - entre(t, I("agenda") - 0.1, I("agenda") + 0.5));
  const movilE = entre(t, I("agenda") - 0.1, I("agenda") + 0.6, sale);
  const logoFinal = entre(t, F("agenda") - 2.2, F("agenda") - 1.6, sale);

  return (
    <AbsoluteFill style={{ background: "#f3fbfd" }}>
      <Fondo t={t} />
      <Camara cam={cam}>
        {/* ===== 1-3: ADN (que se vuelve pelo) y plato ===== */}
        {verAdn ? (
          <div style={{ position: "absolute", left: adnX - 180, top: 440, transform: `scale(${adnEsc * (t < I("hebras") ? 1 : interpolate(aPelo, [0, 1], [1, 0.7]))}) translateY(${aPelo * -40}px)`, filter: enfoque > 0.3 ? `blur(${enfoque}px)` : undefined, opacity: 1 - entre(t, tCab, tCab + 0.5) }}>
            <ADN t={t} estira={aPelo} brillo={t > tGen && t < I("ciencia") ? 1 : 0} />
          </div>
        ) : null}
        {verPlato ? (
          <div style={{ position: "absolute", left: platoX - 190, top: 640, transform: `scale(${(t > tNut && t < I("ciencia") ? 1.08 : 1) * (1 - juntar * 0.45)})`, opacity: 1 - entre(t, I("ciencia") + 0.3, I("ciencia") + 0.9), filter: enfoque > 0.3 ? `blur(${enfoque}px)` : undefined }}>
            <Plato t={t} />
          </div>
        ) : null}
        {/* el puente de luz (conexión literal) */}
        {puente > 0 ? (
          <svg width={1080} height={1920} style={{ position: "absolute", left: 0, top: 0 }}>
            <path d="M370 820 C480 700 600 700 700 820" fill="none" stroke={L.azul} strokeWidth={12} strokeLinecap="round" pathLength={1} strokeDasharray={1} strokeDashoffset={1 - puente} style={{ filter: `drop-shadow(0 0 12px ${L.azul})` }} />
            {Array.from({ length: 6 }, (_, k) => {
              const u = (t * 0.8 + k / 6) % 1;
              const x = 370 + u * 330,
                y = 820 - Math.sin(u * Math.PI) * 92;
              return <circle key={k} cx={x} cy={y} r={9} fill={k % 2 ? L.verde : "#fff"} opacity={puente} />;
            })}
          </svg>
        ) : null}
        {/* 2 · visor de cámara (enfoque) e iconos de ciencia */}
        {t > I("ciencia") - 0.1 && t < I("hebras") + 0.3 ? (
          <div style={{ position: "absolute", inset: 0, opacity: 1 - entre(t, I("hebras") - 0.1, I("hebras") + 0.3) }}>
            {[
              [250, 380, 0],
              [830, 380, 90],
              [830, 1260, 180],
              [250, 1260, 270],
            ].map(([x, y, g], k) => {
              const e = entre(t, tEnf - 0.2, tEnf + 0.4, sale);
              return <div key={k} style={{ position: "absolute", left: x - 50 + (k === 0 || k === 3 ? -1 : 1) * (1 - e) * 80, top: y - 50 + (k < 2 ? -1 : 1) * (1 - e) * 80, width: 100, height: 100, borderLeft: `10px solid ${L.verde}`, borderTop: `10px solid ${L.verde}`, transform: `rotate(${g}deg)`, borderRadius: "10px 0 0 0", opacity: e }} />;
            })}
            <div style={{ position: "absolute", left: 130, top: 1050, transform: `scale(${muelle(t, tCien - 0.1)}) rotate(-8deg)` }}>
              <Matraz t={t} />
            </div>
            <div style={{ position: "absolute", left: 800, top: 1040, transform: `scale(${muelle(t, tCien)}) rotate(6deg)` }}>
              <Microscopio />
            </div>
          </div>
        ) : null}
        {/* 3 · las cinco hebras, contadas, y el tubo */}
        {t > I("hebras") + 0.2 && t < I("informe") + 1.2 ? (
          <div style={{ position: "absolute", inset: 0 }}>
            {Array.from({ length: 5 }, (_, k) => {
              const vis = hebrasVis > k ? 1 : 0;
              const x0 = 260 + k * 140;
              const x = interpolate(enTubo, [0, 1], [x0, 540]);
              const y = interpolate(enTubo, [0, 1], [560, 760]);
              return (
                <div key={k} style={{ position: "absolute", left: x - 30, top: y, opacity: vis * (1 - enTubo), transform: `scale(${muelle(t, tCinco + k * 0.12) * (1 - enTubo * 0.5)})` }}>
                  <svg width={60} height={420} viewBox="0 0 60 420">
                    <path d={`M30 0 C${10 + Math.sin(t + k) * 8} 140 ${50 - Math.sin(t + k) * 8} 280 30 420`} fill="none" stroke="#4a2d1e" strokeWidth={9} strokeLinecap="round" />
                  </svg>
                  <div style={{ position: "absolute", left: 0, top: 440, width: 60, height: 60, borderRadius: 30, background: L.azul, display: "flex", alignItems: "center", justifyContent: "center", fontFamily: TIT, fontWeight: 800, fontSize: 34, color: "#fff", boxShadow: `0 8px 18px ${L.azul}55` }}>{k + 1}</div>
                </div>
              );
            })}
            {/* pinzas que bajan a recogerlas */}
            <div style={{ position: "absolute", left: 470, top: interpolate(enTubo, [0, 0.5, 1], [180, 520, 360], CL), opacity: entre(t, tCab - 0.4, tCab) * (1 - entre(t, tCab + 0.8, tCab + 1.1)) }}>
              <svg width={140} height={240} viewBox="0 0 70 120">
                <path d="M28 0 L22 110 M42 0 L48 110" stroke="#9aa6b8" strokeWidth={8} strokeLinecap="round" />
                <rect x={24} y={0} width={22} height={18} rx={4} fill="#7f8ba0" />
              </svg>
            </div>
            {/* el tubo: aparece al recogerlas y luego se encoge a un lado del informe */}
            {(() => {
              const e = entre(t, tCab, tCab + 0.6, sale);
              const lado = informeE;
              return (
                <div style={{ position: "absolute", left: interpolate(lado, [0, 1], [460, 100]), top: interpolate(lado, [0, 1], [640, 1060]), transform: `scale(${e * interpolate(lado, [0, 1], [1, 0.42])})`, transformOrigin: "0 0" }}>
                  <Tubo hebras={hebrasVis} />
                </div>
              );
            })()}
          </div>
        ) : null}
        {/* 4-5 · el informe: crece, se abre y luego la cámara entra en sus filas */}
        {verInforme ? (
          <div style={{ position: "absolute", left: interpolate(aPantalla, [0, 1], [260, 300]), top: interpolate(aPantalla, [0, 1], [420, 560]), transform: `scale(${informeE * interpolate(aPantalla, [0, 1], [1, 0.3])})`, transformOrigin: "50% 50%", opacity: 1 - entre(t, I("presentacion") + 0.5, I("presentacion") + 0.9) }}>
            <Informe t={t} abre={abre * (1 - entre(t, I("conoceras") - 0.1, I("conoceras") + 0.4))} />
            {/* 5 · las filas del informe se convierten en lo que conocerás */}
            {t > I("conoceras") - 0.2 ? (
              <div style={{ position: "absolute", left: -40, top: 230, width: 640, display: "flex", flexDirection: "column", gap: 20 }}>
                {[
                  { en: tVit, txt: "Vitaminas y minerales", icono: <div style={{ display: "flex", gap: 6 }}>{[L.azul, L.verde, "#f2a33a"].map((c, j) => <div key={j} style={{ width: 54, height: 26, borderRadius: 13, background: `linear-gradient(90deg, ${c} 50%, #fff 50%)`, border: `3px solid ${c}`, transform: `rotate(${-20 + j * 20}deg)` }} />)}</div> },
                  { en: tMic, txt: "Microbioma intestinal", icono: <Intestino t={t} tam={110} /> },
                  { en: tSen, txt: "Sensibilidad alimentaria", icono: <div style={{ display: "flex", gap: 6 }}><Manzana t={60} /><Palta t={60} /></div> },
                ].map((fila, j) => {
                  const e = muelle(t, fila.en - 0.1);
                  return (
                    <div key={j} style={{ display: "flex", alignItems: "center", gap: 20, background: "#fff", borderRadius: 28, padding: "16px 24px", boxShadow: "0 16px 34px #16404a26", transform: `translateX(${(1 - e) * -700}px) scale(${0.9 + 0.1 * e})`, opacity: e }}>
                      <div style={{ width: 150, display: "flex", justifyContent: "center" }}>{fila.icono}</div>
                      <span style={{ fontFamily: LEX, fontWeight: 600, fontSize: 36, color: OSC }}>{fila.txt}</span>
                      <svg width={46} height={46} viewBox="0 0 100 100" style={{ marginLeft: "auto" }}>
                        <circle cx={50} cy={50} r={44} fill={L.verde} />
                        <path d="M28 52 L44 68 L74 34" fill="none" stroke="#fff" strokeWidth={11} strokeLinecap="round" strokeLinejoin="round" />
                      </svg>
                    </div>
                  );
                })}
              </div>
            ) : null}
          </div>
        ) : null}
        {/* 6 · el portátil con la diapositiva y la conversación */}
        {portatilE > 0 ? (
          <div style={{ position: "absolute", left: 130, top: 470, transform: `scale(${0.6 + 0.4 * portatilE})`, opacity: portatilE, transformOrigin: "50% 50%" }}>
            <Portatil t={t}>
              <div style={{ position: "absolute", inset: 0, padding: 30, boxSizing: "border-box" }}>
                <div style={{ fontFamily: TIT, fontWeight: 800, fontSize: 40, color: L.azulTexto }}>Tus resultados</div>
                <svg width="100%" height={260} viewBox="0 0 100 50">
                  {Array.from({ length: 7 }, (_, j) => {
                    const h = (10 + ((j * 9) % 30)) * entre(t, tPres, tPres + 0.8);
                    return <rect key={j} x={4 + j * 14} y={46 - h} width={9} height={h} rx={2} fill={j % 2 ? L.verde : L.azul} />;
                  })}
                </svg>
              </div>
            </Portatil>
          </div>
        ) : null}
        {portatilE > 0 ? (
          <>
            <div style={{ position: "absolute", left: 90, top: 1080, transform: `scale(${muelle(t, tConv - 0.1)})`, transformOrigin: "0 100%", opacity: portatilE }}>
              <Burbuja lado="izq" texto="¿Qué significa esto?" color="#ffffff" />
            </div>
            <div style={{ position: "absolute", right: 90, top: 1190, transform: `scale(${muelle(t, tConv + 0.4)})`, transformOrigin: "100% 100%", opacity: portatilE }}>
              <Burbuja lado="der" texto="Te lo explicamos" color={L.azulTexto} />
            </div>
          </>
        ) : null}
        {/* 7 · las dudas giran a ✓ una a una y caen en el plato */}
        {dudasE > 0 ? (
          <div style={{ position: "absolute", inset: 0, opacity: dudasE }}>
            {Array.from({ length: 5 }, (_, k) => {
              const a = (k / 5) * Math.PI * 2 - Math.PI / 2;
              const res = entre(t, tDet2 + k * 0.22, tDet2 + k * 0.22 + 0.35);
              return (
                <div key={k} style={{ position: "absolute", left: 540 + Math.cos(a) * 300 - 65, top: 800 + Math.sin(a) * 300 - 65 + Math.sin(t * 2 + k) * 10, transform: `scale(${muelle(t, tDud - 0.1 + k * 0.08)})` }}>
                  <DudaCheck resuelta={res} />
                </div>
              );
            })}
          </div>
        ) : null}
        {platoFinal > 0 ? (
          <div style={{ position: "absolute", left: 540 - 230, top: 560, transform: `scale(${0.5 + 0.5 * platoFinal})`, opacity: platoFinal }}>
            <Plato t={t} tam={460} lleno={entre(t, tOpt, tOpt + 0.9)} />
          </div>
        ) : null}
        {platoFinal > 0 ? (
          <div style={{ position: "absolute", left: 160, right: 160, top: 1110, opacity: platoFinal }}>
            <div style={{ height: 40, borderRadius: 20, background: "#fff", boxShadow: "inset 0 4px 10px #00000018", overflow: "hidden" }}>
              <div style={{ width: `${entre(t, tOpt, tOpt + 1.2) * 100}%`, height: "100%", borderRadius: 20, background: `linear-gradient(90deg, ${L.azul}, ${L.verde})` }} />
            </div>
          </div>
        ) : null}
        {/* 8 · el móvil con la agenda y, al final, el logo */}
        {movilE > 0 ? (
          <div style={{ position: "absolute", left: 540 - 260, top: 360, transform: `scale(${(0.6 + 0.4 * movilE) * 0.84 * (1 - logoFinal * 0.35)}) translateY(${logoFinal * -260}px)`, opacity: movilE * (1 - logoFinal), transformOrigin: "50% 0" }}>
            <MovilAgenda t={t} marcado={entre(t, tAg, tAg + 0.5)} />
          </div>
        ) : null}
      </Camara>

      {/* ===== textos de cada escena (máx. 4 palabras) ===== */}
      <TituloEntra t={t} desde={-0.4} hasta={I("ciencia") + 0.1} y={250}>
        <span style={{ color: L.azulTexto }}>GENÉTICA</span> + <span style={{ color: L.verdeOsc }}>NUTRICIÓN</span>
      </TituloEntra>
      {t > I("ciencia") - 0.1 && t < I("hebras") + 0.4 ? (
        <div style={{ opacity: 1 - entre(t, I("hebras") - 0.1, I("hebras") + 0.3) }}>
          <Revela t={t} desde={tTest - 0.15} y={230} tam={104} fondo={`linear-gradient(90deg, ${L.azul}, ${L.verde})`}>
            TEST EPIGENÉTICO
          </Revela>
        </div>
      ) : null}
      <TituloEntra t={t} desde={I("hebras") + 0.1} hasta={I("informe") + 0.2} y={250} tam={120}>
        <span style={{ color: L.azulTexto }}>5</span> HEBRAS
      </TituloEntra>
      <TituloEntra t={t} desde={I("informe") + 0.1} hasta={I("conoceras") + 0.1} y={250}>
        INFORME <span style={{ color: L.verdeOsc }}>DETALLADO</span>
      </TituloEntra>
      <TituloEntra t={t} desde={I("conoceras") + 0.05} hasta={I("presentacion") + 0.1} y={250}>
        LO QUE <span style={{ color: L.azulTexto }}>CONOCERÁS</span>
      </TituloEntra>
      <TituloEntra t={t} desde={I("presentacion") + 0.1} hasta={I("dudas") + 0.1} y={250}>
        TUS <span style={{ color: L.verdeOsc }}>RESULTADOS</span>
      </TituloEntra>
      <TituloEntra t={t} desde={I("dudas") + 0.05} hasta={I("agenda") + 0.1} y={250}>
        DUDAS <span style={{ color: L.verdeOsc }}>RESUELTAS</span>
      </TituloEntra>
      <TituloEntra t={t} desde={I("agenda") + 0.1} hasta={F("agenda") - 2.2} y={230}>
        AGENDA <span style={{ color: L.azulTexto }}>HOY</span>
      </TituloEntra>
      {/* el número, revelado con máscara cuando dice "escríbenos" */}
      {t > tEsc - 0.2 && logoFinal < 1 ? (
        <div style={{ opacity: 1 - logoFinal }}>
          <Revela t={t} desde={tEsc} y={1190} tam={70} fondo={`linear-gradient(90deg, ${L.azul}, ${L.verde})`}>
            WhatsApp 990 103 447
          </Revela>
        </div>
      ) : null}
      {/* imagen final: el logo con el contacto */}
      {logoFinal > 0 ? (
        <AbsoluteFill style={{ opacity: logoFinal }}>
          <div style={{ position: "absolute", left: 540, top: 760, transform: `translate(-50%,-50%) scale(${0.85 + 0.12 * logoFinal})` }}>
            <LogoAyE escala={1} />
          </div>
          <div style={{ position: "absolute", left: 0, right: 0, top: 1170, display: "flex", flexDirection: "column", alignItems: "center", gap: 16 }}>
            <div style={{ fontFamily: TIT, fontWeight: 800, fontSize: 64, color: "#fff", background: `linear-gradient(90deg, ${L.azul}, ${L.verde})`, padding: "10px 40px 2px", borderRadius: 999 }}>990 103 447</div>
            <div style={{ fontFamily: LEX, fontWeight: 600, fontSize: 38, color: L.azulTexto }}>alimentacionyequilibrio.com</div>
          </div>
        </AbsoluteFill>
      ) : null}

      {t < F("agenda") - 2.3 ? <Subtitulos t={t} /> : null}

      {/* ===== audio ===== */}
      {IDS.map((k, n) => (
        <Sequence key={k} from={LINEA.inicios[n] + LINEA.preDe(k)} durationInFrames={Math.ceil((tiempos.voz[k].duracion + 0.3) * FPS)}>
          <Html5Audio src={src(`voz-${k}.mp3`)} />
        </Sequence>
      ))}
      <Html5Audio loop src={src("musica.mp3")} volume={0.07} />
      {(
        [
          ["whoosh", 0.05, 0.4],
          ["brillo", tConex, 0.35],
          ["pop", tGen, 0.3],
          ["pop", tNut, 0.3],
          ["whoosh", I("ciencia"), 0.35],
          ["clic", tEnf, 0.4],
          ["pop", tCien, 0.3],
          ["exito", tTest, 0.35],
          ["whoosh", I("hebras"), 0.35],
          ...[0, 1, 2, 3, 4].map((k) => ["tic", tCinco + k * 0.12, 0.35]),
          ["subida", tCab, 0.3],
          ["whoosh", I("informe"), 0.35],
          ["brillo", tDet, 0.3],
          ["whoosh", I("conoceras"), 0.3],
          ["pop", tVit, 0.3],
          ["pop", tMic, 0.3],
          ["pop", tSen, 0.3],
          ["whoosh", I("presentacion"), 0.35],
          ["clic", tConv, 0.35],
          ["whoosh", I("dudas"), 0.3],
          ...[0, 1, 2, 3, 4].map((k) => ["tic", tDet2 + k * 0.22, 0.3]),
          ["exito", tOpt, 0.35],
          ["whoosh", I("agenda"), 0.35],
          ["exito", tAg, 0.35],
          ["brillo", F("agenda") - 2.2, 0.4],
        ] as [string, number, number][]
      ).map(([id, en, vol], k) => (
        <Sequence key={k} from={Math.max(0, Math.round(en * FPS))} durationInFrames={FPS * 3}>
          <Html5Audio src={src(`sfx-${id}.mp3`)} volume={vol} />
        </Sequence>
      ))}
    </AbsoluteFill>
  );
};
