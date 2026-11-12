import { interpolate, useCurrentFrame, useVideoConfig } from "remotion";
import { Brillo, Pop, Rafaga, Respira, useSeg } from "../marca/kit";
import { IcoBalon, IcoCamiseta, IcoEstrella, IcoHuella, IcoPersona, IcoTrofeo } from "../marca/iconos";
import { C, CLAMP, F } from "../marca/tema";
import { Escena, S } from "./comun";
import { LINEA } from "./linea";

const ROJO_PT = "#d6283e";
const VERDE_PT = "#1f9d55";
const ROJO_ES = "#f2c230";

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

/** Marcador de un año: año + ronda alcanzada. */
const Marcador: React.FC<{ anio: string; ronda: string; color: string; bien: boolean }> = ({ anio, ronda, color, bien }) => (
  <div style={{ width: 380, background: "rgba(2,8,20,0.9)", border: `4px solid ${color}`, borderRadius: 28, padding: "18px 24px", display: "flex", flexDirection: "column", alignItems: "center", gap: 6 }}>
    <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
      <IcoCamiseta tamano={64} color={ROJO_PT} segundo={VERDE_PT} />
      <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 64, color: C.hueso }}>{anio}</div>
    </div>
    <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 54, color, lineHeight: 1 }}>{ronda}</div>
    <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 24, color: C.niebla }}>{bien ? "funcionó" : "no funcionó"}</div>
  </div>
);

/** Pizarra táctica: campo visto desde arriba con fichas. */
const Pizarra: React.FC<{ ancho?: number; alto?: number; children: React.ReactNode }> = ({ ancho = 760, alto = 470, children }) => (
  <div style={{ position: "relative", width: ancho, height: alto, borderRadius: 24, background: "#1d6b3f", border: "6px solid #0e3d22", overflow: "hidden" }}>
    <svg width={ancho} height={alto} style={{ position: "absolute", inset: 0 }}>
      {new Array(6).fill(0).map((_, k) => (
        <rect key={k} x={(k * ancho) / 6} y={0} width={ancho / 12} height={alto} fill="#ffffff08" />
      ))}
      <rect x={14} y={14} width={ancho - 28} height={alto - 28} fill="none" stroke="#ffffffaa" strokeWidth={4} />
      <line x1={ancho / 2} y1={14} x2={ancho / 2} y2={alto - 14} stroke="#ffffffaa" strokeWidth={4} />
      <circle cx={ancho / 2} cy={alto / 2} r={60} fill="none" stroke="#ffffffaa" strokeWidth={4} />
      <rect x={14} y={alto / 2 - 90} width={90} height={180} fill="none" stroke="#ffffffaa" strokeWidth={4} />
      <rect x={ancho - 104} y={alto / 2 - 90} width={90} height={180} fill="none" stroke="#ffffffaa" strokeWidth={4} />
    </svg>
    {children}
  </div>
);

const Ficha: React.FC<{ x: number; y: number; color: string; r?: number }> = ({ x, y, color, r = 18 }) => (
  <div style={{ position: "absolute", left: x - r, top: y - r, width: r * 2, height: r * 2, borderRadius: r, background: color, border: "4px solid #1d1530", boxShadow: "0 4px 0 #00000055" }} />
);

/* 1 · GANCHO: 2006 semifinal vs 2026 octavos, desde el fotograma 0 */
export const Gancho: React.FC = () => {
  const m = LINEA.marcas("gancho");
  return (
    <Escena id="gancho" etiqueta="FÚTBOL" titulo="¿Por qué Portugal 2006 sí funcionó?" claves={["mejores", "peor"]} golpes={[0, m("peor")]} sinEntrada>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 22, transform: "translateX(80px)" }}>
        <Marcador anio="2006" ronda="SEMIFINAL" color={C.menta} bien />
        <Brillo color={ROJO_PT}>
          <Marcador anio="2026" ronda="OCTAVOS" color="#ff8da1" bien={false} />
        </Brillo>
      </div>
      <S id="silbato" en={0} volumen={0.35} />
      <S id="golpe" en={0} volumen={0.3} />
      <S id="error" en={m("peor")} volumen={0.2} />
    </Escena>
  );
};

/* 2 · ANTES: el camino de 2006 hasta semifinales */
export const Antes: React.FC = () => {
  const m = LINEA.marcas("antes");
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const pasos = ["GRUPOS", "OCTAVOS", "CUARTOS", "SEMIS"];
  const avance = interpolate(frame, [m("portugal"), m("semifinales")], [0, 3], CLAMP);
  return (
    <Escena id="antes" etiqueta="ALEMANIA 2006" titulo="Hasta semifinales" claves={["semifinales", "cuarenta"]} golpes={[m("semifinales"), m("cuarenta")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 34, transform: "translateX(-60px)" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          {pasos.map((p, k) => {
            const on = avance >= k - 0.01;
            return (
              <div key={p} style={{ display: "flex", alignItems: "center", gap: 10 }}>
                <div style={{ padding: "12px 16px", borderRadius: 16, background: on ? (k === 3 ? C.menta : "#1f3d56") : "#151a2e", border: `3px solid ${on ? C.menta : "#2b3350"}`, fontFamily: F.cifra, fontWeight: 700, fontSize: 26, color: on ? (k === 3 ? C.abismo : C.hueso) : C.niebla, transform: `scale(${on && k === Math.floor(avance) ? 1.08 : 1})` }}>
                  {p}
                </div>
                {k < 3 ? <div style={{ width: 26, height: 6, borderRadius: 3, background: avance > k ? C.menta : "#2b3350" }} /> : null}
              </div>
            );
          })}
        </div>
        <Pop desde={m("cuarenta")}>
          <Brillo>
            <div style={{ display: "flex", alignItems: "center", gap: 20, background: "rgba(2,8,20,0.9)", border: `4px solid ${C.cascabel}`, borderRadius: 26, padding: "10px 30px" }}>
              <IcoTrofeo tamano={90} />
              <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 48, color: C.cascabel, lineHeight: 1 }}>
                mejor en
                <br />
                40 años
              </div>
            </div>
          </Brillo>
        </Pop>
        {frame < m("semifinales") + fps ? null : null}
      </div>
      <S id="tic" en={m("portugal")} volumen={0.25} />
      <S id="subida" en={m("portugal") + 6} volumen={0.2} />
      <S id="aficion" en={m("semifinales")} volumen={0.3} />
      <S id="exito" en={m("cuarenta")} volumen={0.25} />
    </Escena>
  );
};

/* 3 · AHORA: más talento en 2026... y fuera en octavos */
export const Ahora: React.FC = () => {
  const m = LINEA.marcas("ahora");
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const barra = (desde: number, v: number) => v * interpolate(frame, [desde, desde + fps * 0.8], [0, 1], { ...CLAMP, easing: (x) => 1 - Math.pow(1 - x, 3) });
  const sello = interpolate(frame, [m("octavos"), m("octavos") + 8], [0, 1], CLAMP);
  return (
    <Escena id="ahora" etiqueta="2026" titulo="Más talento que nunca" claves={["talento", "octavos"]} golpes={[m("talento"), m("octavos")]}>
      <div style={{ position: "relative", display: "flex", flexDirection: "column", alignItems: "center", gap: 26, transform: "translateX(70px)" }}>
        <Pop desde={m("talento")}>
          <div style={{ width: 640, background: "rgba(2,8,20,0.9)", borderRadius: 26, padding: "22px 28px", display: "flex", flexDirection: "column", gap: 14 }}>
            <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 24, color: C.niebla }}>talento en la plantilla</div>
            {[
              { t: "2006", v: 0.7, c: C.niebla },
              { t: "2026", v: 1, c: C.cascabel },
            ].map((b) => (
              <div key={b.t} style={{ display: "flex", alignItems: "center", gap: 16 }}>
                <div style={{ width: 90, fontFamily: F.cifra, fontWeight: 700, fontSize: 30, color: C.hueso }}>{b.t}</div>
                <div style={{ height: 32, width: 440 * barra(m("talento"), b.v), background: b.c, borderRadius: 16 }} />
              </div>
            ))}
          </div>
        </Pop>
        <div style={{ display: "flex", gap: 18 }}>
          <Pop desde={m("campeones")}>
            <Chip texto="campeones de Europa con el PSG" color={C.cascabel} tamano={28} icono={<IcoEstrella tamano={40} color={C.hueso} />} />
          </Pop>
        </div>
        <Pop desde={m("titulares")}>
          <div style={{ display: "flex", gap: 14 }}>
            {["8", "10", "17", "5", "7"].map((n, k) => (
              <IcoCamiseta key={n} tamano={84} color={ROJO_PT} segundo={VERDE_PT} numero={n} style={{ transform: `translateY(${k % 2 ? 8 : 0}px)` }} />
            ))}
          </div>
        </Pop>
        {frame >= m("octavos") ? (
          <div style={{ position: "absolute", right: 20, bottom: -110, transform: `rotate(-6deg) scale(${2 - sello})`, opacity: sello, fontFamily: F.titulo, fontWeight: 800, fontSize: 58, color: "#ff5470", border: "6px solid #ff5470", borderRadius: 14, padding: "0 20px", background: "#0b0d16dd" }}>
            FUERA EN OCTAVOS
          </div>
        ) : null}
      </div>
      <S id="subida" en={m("talento")} volumen={0.25} />
      <S id="brillo" en={m("campeones")} volumen={0.25} />
      <S id="pop" en={m("titulares")} volumen={0.25} />
      <S id="golpe" en={m("octavos")} volumen={0.35} />
    </Escena>
  );
};

/* 4 · BLOQUE: 2006 defendía como un equipo */
export const Bloque: React.FC = () => {
  const m = LINEA.marcas("bloque");
  const frame = useCurrentFrame();
  const s = useSeg();
  const junta = interpolate(frame, [m("bloque"), m("bloque") + 30], [0, 1], CLAMP);
  const vaiven = Math.sin(s * 1.6) * 40 * junta;
  // 4-2-3-1 que se compacta en bloque
  const base = [
    [80, 235], [190, 90], [190, 185], [190, 285], [190, 380], [300, 170], [300, 300], [400, 110], [400, 235], [400, 360], [500, 235],
  ];
  return (
    <Escena id="bloque" etiqueta="LA CLAVE DE 2006" titulo="No eran estrellas: era un equipo" claves={["equipo", "bloque"]} golpes={[m("equipo"), m("bloque")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 20, transform: "translateX(-60px)" }}>
        <Pop desde={m("clave")}>
          <Pizarra>
            {base.map(([x, y], k) => {
              const cx = k === 0 ? x : x + (300 - x) * 0.35 * junta + vaiven;
              const cy = k === 0 ? y : y + (235 - y) * 0.35 * junta;
              return <Ficha key={k} x={cx} y={cy} color={ROJO_PT} />;
            })}
            {junta > 0 ? (
              <div style={{ position: "absolute", left: 190 + vaiven - 20, top: 120, width: 260, height: 240, borderRadius: 40, border: `5px dashed ${C.cascabel}`, opacity: junta }} />
            ) : null}
          </Pizarra>
        </Pop>
        <div style={{ display: "flex", gap: 20 }}>
          <Pop desde={m("scolari")}>
            <Chip texto="Scolari" color={C.hueso} oscuro tamano={34} />
          </Pop>
          <Pop desde={m("junto")}>
            <Chip texto="defienden los 11" color={C.cascabel} tamano={34} />
          </Pop>
        </div>
      </div>
      <S id="tic" en={m("estrellas")} volumen={0.25} />
      <S id="whoosh" en={m("bloque")} volumen={0.25} />
      <S id="exito" en={m("junto")} volumen={0.25} />
    </Escena>
  );
};

/* 5 · PLAN: 2026 se encerró ante España y cayó en el último minuto */
export const Plan: React.FC = () => {
  const m = LINEA.marcas("plan");
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const atras = interpolate(frame, [m("encerraron"), m("encerraron") + 30], [0, 1], CLAMP);
  const tiro = interpolate(frame, [m("gol"), m("gol") + fps * 0.4], [0, 1], { ...CLAMP, easing: (x) => x * x });
  const pt = [
    [60, 235], [150, 100], [150, 190], [150, 280], [150, 370], [250, 150], [250, 320], [330, 110], [330, 235], [330, 360], [420, 235],
  ];
  const es = [
    [700, 235], [600, 120], [600, 350], [520, 80], [520, 180], [520, 290], [520, 390], [440, 140], [440, 330], [380, 200], [380, 280],
  ];
  return (
    <Escena id="plan" etiqueta="LO QUE PASÓ EN 2026" titulo="Se encerraron contra España" claves={["plan", "encerraron", "casa"]} golpes={[m("encerraron"), m("gol")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 20, transform: "translateX(60px)" }}>
        <Pop desde={m("prensa")}>
          <Pizarra>
            {pt.map(([x, y], k) => (
              <Ficha key={`p${k}`} x={k === 0 ? x : x - (x - 110) * 0.55 * atras} y={y} color={ROJO_PT} />
            ))}
            {es.map(([x, y], k) => (
              <Ficha key={`e${k}`} x={k === 0 ? x : x - 120 * atras} y={y} color={ROJO_ES} />
            ))}
            {frame >= m("gol") ? (
              <div style={{ position: "absolute", left: interpolate(tiro, [0, 1], [300, 30]) - 22, top: interpolate(tiro, [0, 1], [230, 215]) - 22 }}>
                <IcoBalon tamano={44} />
              </div>
            ) : null}
            {tiro >= 1 ? <Rafaga en={m("gol") + Math.round(fps * 0.4)} color={ROJO_ES} tamano={300} x={-330} /> : null}
          </Pizarra>
        </Pop>
        <div style={{ display: "flex", gap: 20 }}>
          <Pop desde={m("gol")}>
            <Chip texto="ESPAÑA 1-0 · min. 90" color={ROJO_ES} tamano={34} />
          </Pop>
          <Pop desde={m("casa")}>
            <Chip texto="adiós al Mundial" color="#ff8da1" oscuro tamano={34} />
          </Pop>
        </div>
      </div>
      <S id="clic" en={m("prensa")} volumen={0.25} />
      <S id="latido" en={m("encerraron")} volumen={0.3} />
      <S id="patada" en={m("gol")} volumen={0.4} />
      <S id="aficion" en={m("gol") + Math.round(fps * 0.4)} volumen={0.3} />
      <S id="silbato" en={m("casa")} volumen={0.3} />
    </Escena>
  );
};

/* 6 · REMATE: el talento gana partidos, el equipo gana Mundiales */
export const Remate: React.FC = () => {
  const m = LINEA.marcas("remate");
  return (
    <Escena id="remate" etiqueta="LA LECCIÓN" titulo="Talento vs. equipo" claves={["talento", "equipo"]} golpes={[m("talento"), m("equipo")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 30, transform: "translateX(-50px)" }}>
        <Pop desde={m("talento")} giro={-3}>
          <div style={{ display: "flex", alignItems: "center", gap: 20, background: "rgba(2,8,20,0.9)", border: `4px solid ${C.niebla}`, borderRadius: 26, padding: "14px 28px" }}>
            <IcoPersona tamano={80} color={C.cascabel} />
            <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 48, color: C.hueso }}>talento → partidos</div>
          </div>
        </Pop>
        <Pop desde={m("equipo")} giro={3}>
          <Brillo color={C.menta}>
            <div style={{ display: "flex", alignItems: "center", gap: 20, background: "rgba(2,8,20,0.9)", border: `4px solid ${C.menta}`, borderRadius: 26, padding: "14px 28px" }}>
              <div style={{ display: "flex" }}>
                {[0, 1, 2].map((k) => (
                  <IcoPersona key={k} tamano={70} color={C.menta} style={{ marginLeft: k ? -24 : 0 }} />
                ))}
              </div>
              <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 48, color: C.menta }}>equipo → Mundiales</div>
              <IcoTrofeo tamano={70} />
            </div>
          </Brillo>
        </Pop>
      </div>
      <S id="pop" en={m("talento")} volumen={0.3} />
      <S id="exito" en={m("mundiales")} volumen={0.3} />
    </Escena>
  );
};

/* 7 · PREGUNTA: ¿culpa del entrenador o de los jugadores? */
export const Pregunta: React.FC = () => {
  const m = LINEA.marcas("pregunta");
  const { fps } = useVideoConfig();
  const firma = m("leo") + Math.round(fps * 0.4);
  return (
    <Escena id="pregunta" etiqueta="¿Y TÚ?" titulo="¿De quién fue la culpa?" claves={["entrenador", "jugadores"]} golpes={[m("entrenador"), m("jugadores")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 40, transform: "translateX(-50px)" }}>
        <div style={{ display: "flex", gap: 34 }}>
          {[
            { t: "ENTRENADOR", i: <IcoPersona tamano={92} color={C.hueso} />, c: C.cascabel, w: "entrenador" },
            { t: "JUGADORES", i: <IcoCamiseta tamano={92} color={ROJO_PT} segundo={VERDE_PT} />, c: C.menta, w: "jugadores" },
          ].map((b, k) => (
            <Pop key={b.w} desde={m(b.w)} giro={k ? 8 : -8}>
              <Respira fase={k * 1.5} amp={0.05}>
                <div style={{ width: 310, height: 230, borderRadius: 40, background: b.c, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 10, fontFamily: F.titulo, fontWeight: 800, fontSize: 46, color: C.abismo }}>
                  {b.i}
                  {b.t}
                </div>
              </Respira>
            </Pop>
          ))}
        </div>
        <Pop desde={firma}>
          <div style={{ display: "flex", alignItems: "center", gap: 16, fontFamily: F.cifra, fontWeight: 700, fontSize: 40, color: C.hueso }}>
            <span style={{ width: 36, height: 36, borderRadius: 18, background: C.pelaje, border: `3px solid ${C.hueso}`, display: "inline-block" }} />
            @ithnoir · comenta <IcoHuella tamano={56} />
          </div>
        </Pop>
      </div>
      <S id="pop" en={m("entrenador")} volumen={0.3} />
      <S id="pop" en={m("jugadores")} volumen={0.3} />
      <S id="cascabel" en={firma} volumen={0.45} />
    </Escena>
  );
};
