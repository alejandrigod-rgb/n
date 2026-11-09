import { interpolate, random, useCurrentFrame, useVideoConfig } from "remotion";
import { Brillo, Pop, Rafaga, Respira, useSeg } from "../marca/kit";
import { IcoBien, IcoCapucha, IcoEdificio, IcoEstrella, IcoHuella, IcoLuna, IcoMal, IcoSol, IcoTerminal, IcoTrofeo } from "../marca/iconos";
import { C, CLAMP, F } from "../marca/tema";
import { Escena, S } from "./comun";
import { LINEA } from "./linea";

const ROJO = "#ff5470";

const Chip: React.FC<{ texto: string; color?: string; tamano?: number; oscuro?: boolean; icono?: React.ReactNode }> = ({ texto, color = C.menta, tamano = 40, oscuro, icono }) => (
  <div
    style={{
      display: "inline-flex",
      alignItems: "center",
      gap: 14,
      fontFamily: F.cifra,
      fontWeight: 700,
      fontSize: tamano,
      color: oscuro ? color : C.abismo,
      background: oscuro ? "rgba(2,8,20,0.88)" : color,
      border: oscuro ? `3px solid ${color}` : undefined,
      padding: "6px 22px",
      borderRadius: 999,
      whiteSpace: "nowrap",
    }}
  >
    {icono}
    {texto}
  </div>
);

/** Ventana de terminal con líneas que se escriben solas. */
const Terminal: React.FC<{ lineas: { t: string; desde: number; color?: string; grande?: boolean }[]; ancho?: number; titulo?: string }> = ({ lineas, ancho = 860, titulo = "nyxar@aez: ~" }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const s = frame / fps;
  return (
    <div style={{ width: ancho, background: "rgba(4,10,24,0.94)", border: `3px solid ${C.menta}66`, borderRadius: 26, overflow: "hidden", boxShadow: `0 0 40px ${C.menta}22` }}>
      <div style={{ display: "flex", alignItems: "center", gap: 12, padding: "14px 22px", background: "#0c1730" }}>
        {[C.panuelo, C.cascabel, C.menta].map((c) => (
          <span key={c} style={{ width: 18, height: 18, borderRadius: 9, background: c, display: "inline-block" }} />
        ))}
        <span style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 24, color: C.niebla, marginLeft: 12 }}>{titulo}</span>
      </div>
      <div style={{ padding: "22px 30px", display: "flex", flexDirection: "column", gap: 14, minHeight: 120 }}>
        {lineas.map((l, k) => {
          if (frame < l.desde) return null;
          const n = Math.min(l.t.length, Math.floor(((frame - l.desde) / fps) * 38));
          const escribiendo = n < l.t.length;
          const ultima = k === lineas.length - 1 || frame < lineas[k + 1].desde;
          return (
            <div key={k} style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: l.grande ? 64 : 32, color: l.color ?? C.hueso, whiteSpace: "pre", lineHeight: 1.15 }}>
              {l.t.slice(0, n)}
              {(escribiendo || ultima) && Math.floor(s * 2.5) % 2 === 0 ? <span style={{ display: "inline-block", width: "0.55em", height: "0.9em", marginLeft: 4, verticalAlign: "-0.1em", background: C.menta }} /> : null}
            </div>
          );
        })}
      </div>
    </div>
  );
};

/* 1 · GANCHO: el veredicto ya está en pantalla en el fotograma 0 */
export const Gancho: React.FC = () => {
  const m = LINEA.marcas("gancho");
  return (
    <Escena id="gancho" etiqueta="SERIES PARA PROGRAMADORES" titulo="La serie de hackers más realista" claves={["hackers", "aprueban"]} golpes={[0, m("aprueban")]} sinEntrada>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 30, transform: "translateX(80px)" }}>
        <Terminal
          ancho={800}
          lineas={[
            { t: "$ revisar_hackeos --serie mr_robot", desde: -999, color: C.niebla },
            { t: "RESULTADO:", desde: -999, color: C.hueso },
          ]}
        />
        <Brillo color={C.menta}>
          <div style={{ display: "flex", alignItems: "center", gap: 24, background: "rgba(2,8,20,0.9)", border: `4px solid ${C.menta}`, borderRadius: 30, padding: "8px 40px" }}>
            <IcoBien tamano={110} />
            <span style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 120, color: C.menta, lineHeight: 1.1 }}>REALES</span>
          </div>
        </Brillo>
      </div>
      <S id="cascabel" en={0} volumen={0.45} />
      <S id="golpe" en={0} volumen={0.3} />
      <S id="exito" en={m("aprueban")} volumen={0.25} />
    </Escena>
  );
};

/* 2 · CONTEXTO: título propio y fechas */
export const Contexto: React.FC = () => {
  const m = LINEA.marcas("contexto");
  const frame = useCurrentFrame();
  const s = useSeg();
  const glitch = (frame - m("mr")) % 50 < 4 && frame > m("mr");
  return (
    <Escena id="contexto" etiqueta="LA SERIE" titulo="Mr. Robot (2015-2019)" claves={["robot", "cuatro"]} golpes={[m("mr"), m("cuatro")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 40 }}>
        <Pop desde={m("mr")}>
          <div style={{ position: "relative", fontFamily: F.titulo, fontWeight: 800, fontSize: 170, color: C.hueso, lineHeight: 1, letterSpacing: 4 }}>
            {glitch ? (
              <>
                <span style={{ position: "absolute", left: 8, top: 0, color: ROJO, opacity: 0.8 }}>MR. ROBOT</span>
                <span style={{ position: "absolute", left: -8, top: 0, color: C.menta, opacity: 0.8 }}>MR. ROBOT</span>
              </>
            ) : null}
            <span style={{ position: "relative" }}>MR. ROBOT</span>
            <div style={{ height: 14, marginTop: 8, borderRadius: 7, background: ROJO, width: `${interpolate(frame, [m("mr"), m("mr") + 20], [0, 100], CLAMP)}%`, boxShadow: `0 0 ${20 + 8 * Math.sin(s * 4)}px ${ROJO}` }} />
          </div>
        </Pop>
        <div style={{ display: "flex", gap: 26 }}>
          <Pop desde={m("cuatro")}>
            <Chip texto="4 TEMPORADAS" color={C.menta} tamano={44} />
          </Pop>
          <Pop desde={m("quince")}>
            <Chip texto="2015 – 2019" color={C.cascabel} tamano={44} />
          </Pop>
        </div>
      </div>
      <S id="glitch" en={m("mr")} volumen={0.3} />
      <S id="pop" en={m("cuatro")} volumen={0.3} />
      <S id="tic" en={m("quince")} volumen={0.3} />
    </Escena>
  );
};

/* 3 · ELLIOT: de día ciberseguridad, de noche hacker */
export const Elliot: React.FC = () => {
  const m = LINEA.marcas("elliot");
  const frame = useCurrentFrame();
  const noche = interpolate(frame, [m("hacker") - 10, m("hacker") + 10], [0, 1], CLAMP);
  return (
    <Escena id="elliot" etiqueta="EL PROTAGONISTA" titulo="Elliot: dos vidas" claves={["dia", "noche"]} golpes={[m("ingeniero"), m("noche")]}>
      <div style={{ display: "flex", gap: 30, transform: "translateX(-60px)" }}>
        <Pop desde={m("ingeniero")}>
          <div style={{ width: 360, height: 420, borderRadius: 34, background: "#14304f", border: `4px solid ${C.cascabel}`, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 20, opacity: 1 - noche * 0.45 }}>
            <IcoSol tamano={150} />
            <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 30, color: C.cascabel }}>DE DÍA</div>
            <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 44, color: C.hueso, textAlign: "center", lineHeight: 1.05 }}>ingeniero de{"\n"}ciberseguridad</div>
          </div>
        </Pop>
        <Pop desde={m("hacker")}>
          <Brillo color={C.azul}>
            <div style={{ width: 360, height: 420, borderRadius: 34, background: "#0a0f22", border: `4px solid ${C.azul}`, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 14 }}>
              <div style={{ display: "flex", alignItems: "flex-end" }}>
                <IcoCapucha tamano={150} />
                <IcoLuna tamano={70} style={{ marginLeft: -20, marginBottom: 90 }} />
              </div>
              <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 30, color: C.azul }}>DE NOCHE</div>
              <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 44, color: C.hueso, textAlign: "center", lineHeight: 1.05 }}>hacker{"\n"}justiciero</div>
            </div>
          </Brillo>
        </Pop>
      </div>
      <S id="pop" en={m("ingeniero")} volumen={0.3} />
      <S id="whoosh" en={m("hacker") - 6} volumen={0.3} />
      <S id="golpe" en={m("noche")} volumen={0.25} />
    </Escena>
  );
};

/* 4 · TRAMA: un grupo misterioso contra la empresa más poderosa del mundo */
export const Trama: React.FC = () => {
  const m = LINEA.marcas("trama");
  const frame = useCurrentFrame();
  const s = useSeg();
  const tumbar = frame >= m("tumbar");
  const tiembla = tumbar ? Math.sin(s * 50) * Math.max(0, 1 - (frame - m("tumbar")) / 40) * 12 : 0;
  return (
    <Escena id="trama" etiqueta="LA TRAMA (SIN SPOILERS)" titulo="Un grupo contra un gigante" claves={["grupo", "poderosa"]} golpes={[m("enorme"), m("tumbar")]}>
      <div style={{ position: "relative", width: 1000, height: 620 }}>
        {[0, 1, 2, 3].map((k) => (
          <Pop key={k} desde={m("grupo") + k * 5} style={{ position: "absolute", left: 30 + (k % 2) * 140, top: 120 + Math.floor(k / 2) * 190 }}>
            <Respira fase={k} amp={0.03}>
              <IcoCapucha tamano={170} />
            </Respira>
          </Pop>
        ))}
        <Pop desde={m("misterioso")} style={{ position: "absolute", left: 40, top: 40 }}>
          <Chip texto="grupo misterioso" color={C.niebla} oscuro tamano={34} />
        </Pop>
        {/* Flecha punteada hacia la empresa */}
        <svg width={260} height={60} viewBox="0 0 260 60" style={{ position: "absolute", left: 360, top: 300, opacity: interpolate(frame, [m("enorme"), m("enorme") + 10], [0, 1], CLAMP) }}>
          <path d="M10 30 H220" stroke={ROJO} strokeWidth={10} strokeDasharray="22 16" strokeDashoffset={-s * 80} strokeLinecap="round" />
          <path d="M210 10 L246 30 L210 50 Z" fill={ROJO} />
        </svg>
        <Pop desde={m("empresa")} style={{ position: "absolute", left: 560, top: 40 }}>
          <div style={{ transform: `translateX(${tiembla}px) rotate(${tumbar ? interpolate(frame, [m("tumbar"), m("tumbar") + 20], [0, 6], CLAMP) : 0}deg)`, transformOrigin: "50% 100%" }}>
            <Brillo color={tumbar ? ROJO : C.niebla}>
              <IcoEdificio tamano={330} color={tumbar ? "#c9a3ad" : C.niebla} />
            </Brillo>
          </div>
        </Pop>
        <Pop desde={m("mundo")} style={{ position: "absolute", left: 400, top: 430 }} giro={-4}>
          <Chip texto="LA EMPRESA MÁS PODEROSA" color={ROJO} tamano={34} />
        </Pop>
        {tumbar ? <Rafaga en={m("tumbar")} color={ROJO} tamano={420} x={220} y={-90} /> : null}
      </div>
      <S id="latido" en={m("grupo")} volumen={0.3} />
      <S id="whoosh" en={m("enorme")} volumen={0.25} />
      <S id="golpe" en={m("tumbar")} volumen={0.35} />
      <S id="glitch" en={m("mundo")} volumen={0.2} />
    </Escena>
  );
};

/* 5 · REAL: hackeos reales, asesores y herramientas de verdad */
export const Real: React.FC = () => {
  const m = LINEA.marcas("real");
  return (
    <Escena id="real" etiqueta="LO MEJOR" titulo="Los hackeos son reales" claves={["reales", "kali"]} golpes={[m("reales"), m("kali")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 30, transform: "translateX(70px)" }}>
        <Terminal
          ancho={760}
          titulo="kali@linux: ~"
          lineas={[
            { t: "$ nmap -sV 10.0.0.0/24", desde: m("reales"), color: C.menta },
            { t: "$ john hashes.txt", desde: m("asesores"), color: C.menta },
            { t: "> contraseña encontrada", desde: m("exinvestigador"), color: C.cascabel },
          ]}
        />
        <div style={{ display: "flex", flexWrap: "wrap", justifyContent: "center", gap: 18, width: 760 }}>
          <Pop desde={m("asesores")}>
            <Chip texto="asesores de ciberseguridad" color={C.menta} tamano={32} />
          </Pop>
          <Pop desde={m("exinvestigador")}>
            <Chip texto="ex-FBI" color={C.azul} tamano={32} />
          </Pop>
          <Pop desde={m("kali")}>
            <Brillo>
              <Chip texto="Kali Linux" color={C.hueso} tamano={40} icono={<IcoTerminal tamano={50} />} />
            </Brillo>
          </Pop>
        </div>
      </div>
      <S id="clic" en={m("reales")} volumen={0.35} />
      <S id="tic" en={m("asesores")} volumen={0.3} />
      <S id="pop" en={m("exinvestigador")} volumen={0.3} />
      <S id="exito" en={m("kali")} volumen={0.3} />
    </Escena>
  );
};

/* 6 · MENTE: ansiedad, soledad y un narrador que no es de fiar */
export const Mente: React.FC = () => {
  const m = LINEA.marcas("mente");
  const frame = useCurrentFrame();
  const s = useSeg();
  const dudoso = frame >= m("narrador");
  const sep = dudoso ? 10 + 8 * Math.sin(s * 9) : 0;
  const salto = dudoso && random(`m${Math.floor(frame / 4)}`) > 0.8;
  return (
    <Escena id="mente" etiqueta="LO QUE ENGANCHA" titulo="La mente de Elliot" claves={["ansiedad", "soledad", "confiar"]} golpes={[m("narrador")]}>
      <div style={{ position: "relative", width: 1000, height: 620 }}>
        <div style={{ position: "absolute", left: 360, top: 120, transform: `translateX(${salto ? 18 : 0}px)` }}>
          {dudoso ? (
            <>
              <IcoCapucha tamano={300} color="#5a1a2a" style={{ position: "absolute", left: sep, top: 0, opacity: 0.6 }} />
              <IcoCapucha tamano={300} color="#0f3d3a" style={{ position: "absolute", left: -sep, top: 0, opacity: 0.6 }} />
            </>
          ) : null}
          <Pop desde={m("elliot")}>
            <IcoCapucha tamano={300} />
          </Pop>
        </div>
        <Pop desde={m("ansiedad")} style={{ position: "absolute", left: 60, top: 80 }} giro={-6}>
          <Chip texto="ansiedad" color={C.cascabel} tamano={40} />
        </Pop>
        <Pop desde={m("soledad")} style={{ position: "absolute", left: 700, top: 120 }} giro={6}>
          <Chip texto="soledad" color={C.azul} tamano={40} />
        </Pop>
        <Pop desde={m("confiar")} style={{ position: "absolute", left: 230, top: 470 }}>
          <div style={{ position: "relative" }}>
            <Chip texto='"confía en mí"' color={C.hueso} oscuro tamano={44} />
            <div style={{ position: "absolute", left: -10, right: -10, top: "50%", height: 8, background: ROJO, transform: `rotate(-5deg) scaleX(${interpolate(frame, [m("confiar") + 8, m("confiar") + 20], [0, 1], CLAMP)})`, borderRadius: 4 }} />
          </div>
        </Pop>
      </div>
      <S id="latido" en={m("ansiedad")} volumen={0.3} />
      <S id="glitch" en={m("narrador")} volumen={0.3} />
      <S id="error" en={m("confiar")} volumen={0.25} />
    </Escena>
  );
};

/* 7 · PREMIOS: Globo de Oro y Emmy */
export const Premios: React.FC = () => {
  const m = LINEA.marcas("premios");
  return (
    <Escena id="premios" etiqueta="PREMIOS" titulo="Y la crítica la adoró" claves={["globo", "emmy"]} golpes={[m("globo"), m("emmy")]}>
      <div style={{ display: "flex", gap: 40, transform: "translateX(-60px)" }}>
        {[
          { w: "globo", a: "GLOBO DE ORO", b: "mejor serie dramática", c: C.cascabel },
          { w: "emmy", a: "EMMY", b: "Rami Malek, mejor actor", c: C.menta },
        ].map((p, k) => (
          <Pop key={p.w} desde={m(p.w)} giro={k ? 6 : -6}>
            <Respira fase={k * 1.3} amp={0.03}>
              <div style={{ width: 340, height: 430, borderRadius: 34, background: "rgba(2,8,20,0.9)", border: `4px solid ${p.c}`, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 18, padding: 20 }}>
                <Brillo color={p.c}>
                  <IcoTrofeo tamano={170} color={p.c} />
                </Brillo>
                <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 52, color: p.c, lineHeight: 1 }}>{p.a}</div>
                <div style={{ fontFamily: F.texto, fontWeight: 600, fontSize: 30, color: C.hueso, textAlign: "center" }}>{p.b}</div>
              </div>
            </Respira>
          </Pop>
        ))}
      </div>
      <S id="brillo" en={m("globo")} volumen={0.3} />
      <S id="exito" en={m("emmy")} volumen={0.3} />
    </Escena>
  );
};

/* 8 · PREGUNTA: obra maestra o sobrevalorada */
export const Pregunta: React.FC = () => {
  const m = LINEA.marcas("pregunta");
  const { fps } = useVideoConfig();
  const firma = m("comentarios") + Math.round(fps * 0.4);
  return (
    <Escena id="pregunta" etiqueta="¿Y TÚ?" titulo="¿Obra maestra o sobrevalorada?" claves={["obra", "sobrevalorada"]} golpes={[m("obra"), m("sobrevalorada")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 40, transform: "translateX(-50px)" }}>
        <div style={{ display: "flex", gap: 34 }}>
          {[
            { t: "OBRA\nMAESTRA", i: <IcoEstrella tamano={92} color={C.hueso} />, c: C.menta, w: "obra" },
            { t: "SOBRE-\nVALORADA", i: <IcoMal tamano={92} />, c: C.cascabel, w: "sobrevalorada" },
          ].map((b, k) => (
            <Pop key={b.w} desde={m(b.w)} giro={k ? 8 : -8}>
              <Respira fase={k * 1.5} amp={0.05}>
                <div style={{ width: 300, height: 240, borderRadius: 40, background: b.c, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 10, fontFamily: F.titulo, fontWeight: 800, fontSize: 48, lineHeight: 1, textAlign: "center", color: C.abismo, whiteSpace: "pre-line" }}>
                  {b.i}
                  {b.t}
                </div>
              </Respira>
            </Pop>
          ))}
        </div>
        <Pop desde={m("spoilers")}>
          <Chip texto="SIN SPOILERS" color={ROJO} tamano={38} icono={<IcoMal tamano={44} />} />
        </Pop>
        <Pop desde={firma}>
          <div style={{ display: "flex", alignItems: "center", gap: 16, fontFamily: F.cifra, fontWeight: 700, fontSize: 40, color: C.hueso }}>
            <span style={{ width: 36, height: 36, borderRadius: 18, background: C.pelaje, border: `3px solid ${C.hueso}`, display: "inline-block" }} />
            @ithnoir · comenta <IcoHuella tamano={56} />
          </div>
        </Pop>
      </div>
      <S id="pop" en={m("obra")} volumen={0.3} />
      <S id="pop" en={m("sobrevalorada")} volumen={0.3} />
      <S id="error" en={m("spoilers")} volumen={0.2} />
      <S id="cascabel" en={firma} volumen={0.45} />
    </Escena>
  );
};
