/**
 * Serie de Marco (cuenta Marcoglowup, no AEZ) · Episodio 2: ganó FAMILIA (87 %).
 * Vuelve a casa: su padre no le reconoce ("no compramos nada"), su madre sí (por la sudadera de 2016).
 * Condición del padre: trabajo en 30 días o fuera. Día 1: la báscula pide ayuda. Votación: ¿gimnasio o trabajo?
 */
import React from "react";
import { AbsoluteFill, Audio, Sequence, getInputProps, interpolate, random, staticFile, useCurrentFrame } from "remotion";
import { IcoCorazon, IcoEdificio } from "../../marca/iconos";
import { crearLinea, type Tiempos } from "../../marca/linea";
import { Casa, Fondo, MarcoEn, Sello, Silueta, marca, type M } from "../kit";
import { AMARILLO, CartaVoto, ContadorDia, FUENTE, Gordo, Ono, Subtitulo, TINTA, punch } from "../piezas";
import tiemposJson from "./tiempos.json";

const FPS = 60;
const tiempos = tiemposJson as unknown as Tiempos;
const IDS = ["gancho", "votasteis", "puerta", "madre", "condicion", "bascula", "voto"] as const;
type Id = (typeof IDS)[number];
const L = crearLinea({ tiempos, ids: IDS, fps: FPS, pre: { gancho: 0.08, votasteis: 0.12, puerta: 0.12, madre: 0.12, condicion: 0.12, bascula: 0.12, voto: 0.12 }, extra: { voto: 1.8 }, transicion: 0 });
export const DURACION_EP2 = L.total;
const CL = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;
const CLAVES = ["padre", "reconocio", "familia", "casa", "10", "compramos", "nada", "madre", "sudadera", "2016", "condicion", "30", "trabajo", "fuera", "1", "glow", "bascula", "ayuda", "gimnasio", "comenta"];
const s = (n: number) => Math.round(n * FPS);
const src = (f: string) => staticFile(`serie-ep2/${f}`);

/** Bocadillo blanco con borde (lo que dicen los personajes). */
const Bocadillo: React.FC<{ f: number; x: number; y: number; giro?: number; children: React.ReactNode }> = ({ f, x, y, giro = 3, children }) =>
  f < 0 ? null : (
    <div style={{ position: "absolute", left: x, top: y, transform: `translateX(-50%) scale(${interpolate(f, [0, 6, 10], [0, 1.15, 1], CL)}) rotate(${giro}deg)` }}>
      <div style={{ background: "#fff", border: `9px solid ${TINTA}`, borderRadius: 40, padding: "14px 34px 4px", whiteSpace: "nowrap", textAlign: "center", boxShadow: `0 10px 0 ${TINTA}` }}>{children}</div>
    </div>
  );
const Txt: React.FC<{ tam?: number; color?: string; children: React.ReactNode }> = ({ tam = 84, color = TINTA, children }) => <div style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: tam, color, lineHeight: 1.05 }}>{children}</div>;

/** Mancuerna (icono propio, mismo estilo que los de la marca). */
const Mancuerna: React.FC<{ tamano?: number }> = ({ tamano = 210 }) => (
  <svg width={tamano} height={tamano} viewBox="0 0 100 100">
    <g stroke={TINTA} strokeWidth={6} strokeLinejoin="round">
      <rect x={30} y={44} width={40} height={12} rx={4} fill="#c9ced6" />
      <rect x={14} y={26} width={18} height={48} rx={6} fill="#ffcf5a" />
      <rect x={68} y={26} width={18} height={48} rx={6} fill="#ffcf5a" />
      <rect x={4} y={36} width={12} height={28} rx={4} fill="#ffcf5a" />
      <rect x={84} y={36} width={12} height={28} rx={4} fill="#ffcf5a" />
    </g>
    <path d="M18 34 V50" stroke="#fff" strokeWidth={4} opacity={0.6} strokeLinecap="round" />
  </svg>
);

/* ---------- escenas ---------- */

const Gancho: React.FC<{ f: number; m: M }> = ({ f, m }) => {
  const b = marca(m, "reconoció.", 70);
  return f < b ? (
    <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
      <Casa abierta />
      <div style={{ position: "absolute", left: 430, top: 740 }}>
        <Silueta ancho={220} color="#2c2c3a" ojos="susto" />
      </div>
      <MarcoEn cx={270} cy={1000} ancho={560} expresion="ilusion" f={f} />
      <Bocadillo f={f + 10} x={560} y={430}>
        <Txt tam={96}>¿QUIÉN ERES?</Txt>
      </Bocadillo>
      <div style={{ position: "absolute", left: 50, top: 210, background: "#2f62b5", border: `7px solid ${TINTA}`, borderRadius: 20, padding: "4px 24px 0", transform: "rotate(-4deg)", boxShadow: `0 8px 0 ${TINTA}` }}>
        <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 56, color: "#fff" }}>
          GANÓ FAMILIA <span style={{ color: AMARILLO }}>87%</span>
        </span>
      </div>
    </AbsoluteFill>
  ) : (
    <AbsoluteFill style={{ transform: `scale(${punch(f - b)})` }}>
      <Fondo a="#6b6f86" b="#1c1e2b" />
      <div style={{ position: "absolute", left: 540 - 450, top: 160 }}>
        <Silueta ancho={900} color="#2c2c3a" ojos="susto" />
      </div>
      <Ono texto="?" f={f - b} x={880} y={330} giro={14} tam={260} dura={80} />
      <Ono texto="?" f={f - b - 6} x={190} y={420} giro={-12} tam={180} dura={80} />
    </AbsoluteFill>
  );
};

const Votasteis: React.FC<{ f: number; m: M }> = ({ f, m }) => {
  const b = marca(m, "vuelve", 70);
  if (f < b) {
    const p = interpolate(f, [4, 30], [0, 1], { ...CL, easing: (x) => 1 - (1 - x) ** 3 });
    const barra = (t: string, pct: number, col: string, y: number, gana: boolean) => (
      <div style={{ position: "absolute", left: 110, top: y, width: 860, height: 170, background: "#ffffff22", border: `9px solid ${TINTA}`, borderRadius: 40, overflow: "hidden", transform: gana && f > 32 ? `scale(${1 + Math.sin((f - 32) / 4) * 0.02})` : undefined }}>
        <div style={{ position: "absolute", inset: 0, width: `${pct * p}%`, background: col }} />
        <div style={{ position: "absolute", left: 40, right: 40, top: 0, bottom: 0, display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <Gordo tam={88}>{t}</Gordo>
          <Gordo tam={88} color={gana ? AMARILLO : "#fff"}>
            {Math.round(pct * p)}%
          </Gordo>
        </div>
      </div>
    );
    return (
      <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
        <Fondo a="#4f86e0" b="#16306e" />
        <div style={{ position: "absolute", top: 300, left: 0, right: 0, display: "flex", justifyContent: "center" }}>
          <Gordo tam={100}>VOTASTEIS</Gordo>
        </div>
        {barra("FAMILIA", 87, "#2f62b5", 520, true)}
        {barra("LAURA", 13, "#e0457b", 740, false)}
      </AbsoluteFill>
    );
  }
  return (
    <AbsoluteFill style={{ transform: `scale(${punch(f - b)})` }}>
      <AbsoluteFill style={{ background: "linear-gradient(180deg,#ffb36b 0%,#ffd9a0 55%,#9c8a6a 55%,#7a6a50 100%)" }} />
      {/* casa a lo lejos */}
      <div style={{ position: "absolute", left: 700, top: 820, width: 200, height: 150, background: "#f0d9b5", border: `7px solid ${TINTA}` }} />
      <div style={{ position: "absolute", left: 680, top: 740, width: 240, height: 90, background: "#b8483a", border: `7px solid ${TINTA}`, clipPath: "polygon(50% 0,100% 100%,0 100%)" }} />
      <MarcoEn cx={360 + (f - b) * 1.2} cy={880} ancho={620} expresion="confuso" f={f} />
      <div style={{ position: "absolute", left: 0, right: 0, top: 260, display: "flex", justifyContent: "center" }}>
        <Gordo tam={96} style={{ transform: "rotate(-3deg)" }}>
          <span style={{ color: AMARILLO }}>10 AÑOS</span> DESPUÉS
        </Gordo>
      </div>
    </AbsoluteFill>
  );
};

const Puerta: React.FC<{ f: number; m: M }> = ({ f, m }) => {
  const b = marca(m, "abre", 60);
  const c = marca(m, "compramos", b + 30);
  if (f < b) {
    return (
      <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
        <Casa abierta={false} />
        <MarcoEn cx={320} cy={1000} ancho={560} expresion="ilusion" brazoD={60} f={f} />
        <Ono texto="TOC TOC" f={f - 8} x={700} y={620} giro={8} tam={140} dura={60} />
      </AbsoluteFill>
    );
  }
  return (
    <AbsoluteFill style={{ transform: `scale(${punch(f - b)})` }}>
      <Fondo a="#f0d9b5" b="#8a6a46" />
      <div style={{ position: "absolute", left: 200, top: 250, width: 680, height: 1400, background: "#2a1e18", border: `14px solid ${TINTA}` }} />
      <div style={{ position: "absolute", left: 540 - 300, top: 420 }}>
        <Silueta ancho={600} color="#2c2c3a" ojos="normal" />
      </div>
      <Bocadillo f={f - c + 4} x={540} y={250} giro={-3}>
        <Txt tam={90}>NO COMPRAMOS</Txt>
        <Txt tam={110} color="#e0453b">
          NADA
        </Txt>
      </Bocadillo>
    </AbsoluteFill>
  );
};

const Madre: React.FC<{ f: number; m: M }> = ({ f, m }) => {
  const b = marca(m, "sudadera", 90);
  if (f < b) {
    return (
      <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
        <Fondo a="#ffc9dc" b="#b0406f" />
        <div style={{ position: "absolute", left: 540 - 380, top: 230 }}>
          <Silueta ancho={760} color="#4a2a44" mono ojos={f < 30 ? "susto" : "feliz"} />
        </div>
        <Ono texto="¡HIJO!" f={f - 30} x={540} y={300} giro={-6} tam={170} dura={200} color="#ffffff" />
      </AbsoluteFill>
    );
  }
  const g = f - b;
  return (
    <AbsoluteFill style={{ transform: `scale(${punch(g)})` }}>
      <Fondo a="#ffe0b5" b="#c46a3a" />
      <MarcoEn cx={540} cy={60} ancho={1300} expresion="ilusion" f={f} olor={false} />
      {Array.from({ length: 8 }, (_, i) => (
        <div key={i} style={{ position: "absolute", left: 80 + random(`m${i}`) * 860, top: 900 - ((g * (2 + random(`v${i}`) * 2) + i * 60) % 700), opacity: g > 10 ? 1 : 0 }}>
          <IcoCorazon tamano={70 + random(`t${i}`) * 40} color="#ff7aa8" />
        </div>
      ))}
      <div style={{ position: "absolute", left: 720, top: 420, transform: `rotate(10deg) scale(${interpolate(g, [6, 12, 16], [0, 1.2, 1], CL)})`, background: AMARILLO, border: `8px solid ${TINTA}`, borderRadius: 22, padding: "4px 26px 0", boxShadow: `0 8px 0 ${TINTA}` }}>
        <span style={{ fontFamily: FUENTE, fontWeight: 800, fontSize: 80, color: TINTA }}>2016</span>
      </div>
    </AbsoluteFill>
  );
};

const Condicion: React.FC<{ f: number; m: M; dur: number }> = ({ f, m }) => {
  const b = marca(m, "trabajo.", 100);
  const c = marca(m, "fuera.", b + 40);
  if (f < b) {
    return (
      <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
        <Fondo a="#9aa3b8" b="#2a2f40" />
        <div style={{ position: "absolute", left: 540 - 330, top: 400 }}>
          <Silueta ancho={660} color="#2c2c3a" ojos="enfado" brazoArriba />
        </div>
        <Bocadillo f={f - 6} x={540} y={240} giro={-3}>
          <Txt tam={100}>CON UNA</Txt>
          <Txt tam={100} color="#e0453b">
            CONDICIÓN
          </Txt>
        </Bocadillo>
      </AbsoluteFill>
    );
  }
  return (
    <AbsoluteFill style={{ transform: `scale(${punch(f - b)})` }}>
      <Fondo a="#f2ead8" b="#a8946a" />
      <div style={{ position: "absolute", left: 150, top: 300, width: 780, height: 820, background: "#fff", border: `10px solid ${TINTA}`, borderRadius: 24, boxShadow: `0 16px 0 ${TINTA}`, transform: "rotate(-2deg)", padding: "40px 50px", boxSizing: "border-box" }}>
        <Txt tam={70} color="#6b6170">
          NORMAS DE CASA
        </Txt>
        <div style={{ height: 30 }} />
        <Txt tam={110}>TRABAJO</Txt>
        <Txt tam={110}>
          EN <span style={{ color: "#e0453b" }}>30 DÍAS</span>
        </Txt>
        <div style={{ height: 40 }} />
        {[0, 1, 2].map((k) => (
          <div key={k} style={{ height: 14, width: `${80 - k * 15}%`, background: "#e6e1d6", borderRadius: 7, marginBottom: 26 }} />
        ))}
        <div style={{ position: "absolute", right: 60, bottom: 50, fontFamily: "'Lexend', sans-serif", fontWeight: 600, fontSize: 40, color: "#2f62b5", transform: "rotate(-6deg)" }}>Firmado: Papá</div>
      </div>
      <Sello texto="O FUERA" f={f - c} x={560} y={1020} tam={140} giro={-10} />
    </AbsoluteFill>
  );
};

const Bascula: React.FC<{ f: number; m: M }> = ({ f, m }) => {
  const b = marca(m, "báscula...", 90);
  const c = marca(m, "ayuda.", b + 50);
  if (f < b) {
    return (
      <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
        <Fondo a="#9be0b0" b="#2a7a4a" />
        <div style={{ position: "absolute", left: 0, right: 0, top: 300, display: "flex", flexDirection: "column", alignItems: "center", transform: `scale(${interpolate(f, [0, 6, 10], [0.4, 1.15, 1], CL)})` }}>
          <Gordo tam={240} color={AMARILLO}>
            DÍA 1
          </Gordo>
          <Gordo tam={110}>GLOW UP</Gordo>
        </div>
        <MarcoEn cx={540} cy={1000} ancho={520} expresion="ilusion" f={f} />
      </AbsoluteFill>
    );
  }
  const roto = f >= c;
  const kg = Math.min(999, Math.round(interpolate(f - b, [0, 40], [0, 160], CL) + random(`k${Math.floor(f / 3)}`) * 9));
  const temb = roto ? Math.sin(f * 3) * 10 : Math.sin(f * 1.8) * 3;
  return (
    <AbsoluteFill style={{ transform: `scale(${punch(f - b)})` }}>
      <AbsoluteFill style={{ background: "linear-gradient(180deg,#cfe8ef 0%,#e9f4f6 62%,#b9c9cf 62%,#9fb0b6 100%)" }} />
      {/* azulejos */}
      {Array.from({ length: 9 }, (_, i) => (
        <div key={i} style={{ position: "absolute", left: 0, right: 0, top: 120 * i, height: 4, background: "#b0cdd6" }} />
      ))}
      <MarcoEn cx={540} cy={480} ancho={760} expresion={roto ? "susto" : "confuso"} f={f} />
      {/* la báscula */}
      <div style={{ position: "absolute", left: 230, top: 1400, width: 620, height: 150, background: "#e8ecef", border: `10px solid ${TINTA}`, borderRadius: 40, transform: `translateX(${temb}px)` }}>
        <div style={{ position: "absolute", left: 180, top: 26, width: 260, height: 90, background: roto ? "#ff3b3b" : "#1d2a22", border: `7px solid ${TINTA}`, borderRadius: 14, display: "flex", alignItems: "center", justifyContent: "center" }}>
          <span style={{ fontFamily: "'JetBrains Mono', monospace", fontWeight: 700, fontSize: roto ? 48 : 62, color: roto ? "#fff" : "#7dff9a" }}>{roto ? "¡AYUDA!" : `${kg} kg`}</span>
        </div>
      </div>
      {roto ? (
        <svg width={1080} height={1920} style={{ position: "absolute", left: 0, top: 0 }}>
          <path d="M300 1410 L360 1470 L330 1510 L400 1550 M760 1410 L720 1460 L780 1510" stroke={TINTA} strokeWidth={8} fill="none" />
        </svg>
      ) : null}
      <Ono texto="¡CRAC!" f={f - c} x={620} y={370} giro={-8} tam={170} dura={70} />
    </AbsoluteFill>
  );
};

const Voto: React.FC<{ f: number }> = ({ f }) => (
  <AbsoluteFill style={{ transform: `scale(${punch(f)})` }}>
    <Fondo a="#ffe066" b="#f08a24" />
    <div style={{ position: "absolute", top: 330, left: 0, right: 0, display: "flex", flexDirection: "column", alignItems: "center" }}>
      <Gordo tam={96}>¿POR DÓNDE</Gordo>
      <Gordo tam={96} color={AMARILLO}>
        EMPIEZA?
      </Gordo>
    </div>
    <CartaVoto n={1} titulo="GIMNASIO" color="#2a9a5a" icono={<Mancuerna tamano={210} />} f={f - 4} giro={-5} x={290} />
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
  ["error", "gancho", "reconoció.", 0.5],
  ["whoosh", "votasteis", 0, 0.5],
  ["subida", "votasteis", 4, 0.5],
  ["exito", "votasteis", 32, 0.5],
  ["whoosh", "votasteis", "vuelve", 0.5],
  ["clic", "puerta", 8, 0.9],
  ["clic", "puerta", 16, 0.9],
  ["golpe", "puerta", "abre", 0.4],
  ["error", "puerta", "compramos", 0.6],
  ["brillo", "madre", 30, 0.6],
  ["latido", "madre", "sudadera", 0.7],
  ["golpe", "condicion", 0, 0.5],
  ["pop", "condicion", 6, 0.6],
  ["whoosh", "condicion", "trabajo.", 0.5],
  ["golpe", "condicion", "fuera.", 1],
  ["subida", "bascula", 0, 0.5],
  ["tic", "bascula", "báscula...", 0.6],
  ["golpe", "bascula", "ayuda.", 1],
  ["error", "bascula", "ayuda.", 0.6],
  ["whoosh", "voto", 0, 0.6],
  ["exito", "voto", 34, 0.6],
];

export const Episodio2: React.FC = () => {
  const frame = useCurrentFrame();
  const { i, id, local } = L.escenaEn(frame);
  const m = L.marcas(id);
  const dur = L.duraciones[i];
  const sinMusica = Boolean((getInputProps() as { sinMusica?: boolean }).sinMusica);
  const t = (local - L.preDe(id)) / FPS;
  const inicioDia = L.inicios[IDS.indexOf("bascula")];

  const escena =
    id === "gancho" ? (
      <Gancho f={local} m={m} />
    ) : id === "votasteis" ? (
      <Votasteis f={local} m={m} />
    ) : id === "puerta" ? (
      <Puerta f={local} m={m} />
    ) : id === "madre" ? (
      <Madre f={local} m={m} />
    ) : id === "condicion" ? (
      <Condicion f={local} m={m} dur={dur} />
    ) : id === "bascula" ? (
      <Bascula f={local} m={m} />
    ) : (
      <Voto f={local} />
    );

  // Sacudida en los golpes fuertes
  const golpes = [L.inicios[4] + marca(L.marcas("condicion"), "fuera.", 0), L.inicios[5] + marca(L.marcas("bascula"), "ayuda.", 0)];
  let sx = 0;
  for (const g of golpes) if (frame >= g && frame < g + 10) sx = Math.sin((frame - g) * 2.5) * (10 - (frame - g)) * 2;

  return (
    <AbsoluteFill style={{ background: "#000", overflow: "hidden" }}>
      <AbsoluteFill style={{ transform: `translate(${sx}px, ${sx * 0.6}px)` }}>{escena}</AbsoluteFill>
      {frame >= inicioDia ? <ContadorDia dia={1} f={frame - inicioDia} /> : null}
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
          <Sequence key={n} from={L.inicios[k] + loc} durationInFrames={s(3)}>
            <Audio src={src(`sfx-${e}.mp3`)} volume={vol} />
          </Sequence>
        );
      })}
      {sinMusica ? null : <Audio src={src("musica.mp3")} volume={0.22} loop />}
    </AbsoluteFill>
  );
};
