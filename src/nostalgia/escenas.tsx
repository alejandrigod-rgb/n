import { interpolate, useCurrentFrame, useVideoConfig } from "remotion";
import { Brillo, Pop, Rafaga, Respira, useSeg } from "../marca/kit";
import { IcoCasete, IcoCerebro, IcoCorazon, IcoHuella, IcoPersona, IcoEstrella } from "../marca/iconos";
import { C, CLAMP, F } from "../marca/tema";
import { Nyxar, POSE_BASE } from "../personajes/Nyxar";
import { Escena, S } from "./comun";
import { LINEA } from "./linea";

const NARANJA = "#ff9a3c";
const PAPEL = "#efe3c8";

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

/** Foto Polaroid con fecha de cámara antigua. */
export const Polaroid: React.FC<{ ancho?: number; giro?: number; fecha?: string; pie?: string; children: React.ReactNode; filtro?: string }> = ({ ancho = 360, giro = 0, fecha, pie, children, filtro }) => {
  const alto = ancho * 0.92;
  return (
    <div style={{ width: ancho, padding: `${ancho * 0.05}px ${ancho * 0.05}px ${ancho * 0.2}px`, background: "#f6f1e6", borderRadius: 6, transform: `rotate(${giro}deg)`, boxShadow: "0 18px 40px #00000066", position: "relative" }}>
      <div style={{ width: "100%", height: alto, overflow: "hidden", position: "relative", background: "#2a2047", filter: filtro ?? "sepia(0.35) saturate(1.2) contrast(0.95)" }}>
        {children}
        {fecha ? (
          <div style={{ position: "absolute", right: 10, bottom: 8, fontFamily: F.cifra, fontWeight: 700, fontSize: ancho * 0.06, color: NARANJA, textShadow: `0 0 8px ${NARANJA}` }}>{fecha}</div>
        ) : null}
      </div>
      {pie ? (
        <div style={{ position: "absolute", left: 0, right: 0, bottom: ancho * 0.05, textAlign: "center", fontFamily: F.titulo, fontWeight: 800, fontSize: ancho * 0.09, color: "#3a2a5e" }}>{pie}</div>
      ) : null}
    </div>
  );
};

/** Nyxar de pequeño, para las fotos. */
const NyxarFoto: React.FC<{ ancho: number }> = ({ ancho }) => (
  <div style={{ position: "absolute", left: "50%", bottom: -ancho * 0.25, transform: "translateX(-50%)" }}>
    <Nyxar ancho={ancho} pose={{ ...POSE_BASE, brazoD: 150, brazoI: 18 }} boca={0.4} frame={0} fps={30} id={`foto${ancho}`} expresion="feliz" parpadeo={0} />
  </div>
);

/* 1 · GANCHO: foto antigua y "ADICTIVO" desde el fotograma 0 */
export const Gancho: React.FC = () => {
  const m = LINEA.marcas("gancho");
  return (
    <Escena id="gancho" etiqueta="LA NOSTALGIA" titulo="¿Por qué nos engancha el pasado?" claves={["adictivo", "pasado"]} golpes={[0, m("pasado")]} sinEntrada>
      <div style={{ position: "relative", width: 900, height: 620, transform: "translateX(70px)" }}>
        <div style={{ position: "absolute", left: 300, top: 20 }}>
          <Polaroid ancho={400} giro={6} fecha="07 09 2015" pie="el verano">
            <div style={{ position: "absolute", inset: 0, background: "linear-gradient(#7fb8ff, #ffd59a)" }} />
            <div style={{ position: "absolute", left: 40, top: 30, width: 70, height: 70, borderRadius: 35, background: "#fff3c4" }} />
            <NyxarFoto ancho={260} />
          </Polaroid>
        </div>
        <div style={{ position: "absolute", left: 40, top: 360 }}>
          <Brillo color={C.panuelo}>
            <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 104, color: "#ff8da1", background: "rgba(2,8,20,0.9)", border: `4px solid ${C.panuelo}`, borderRadius: 28, padding: "0 36px", transform: "rotate(-5deg)" }}>ADICTIVO</div>
          </Brillo>
        </div>
      </div>
      <S id="cascabel" en={0} volumen={0.45} />
      <S id="golpe" en={0} volumen={0.3} />
      <S id="pop" en={m("por")} volumen={0.3} />
    </Escena>
  );
};

/* 2 · ORIGEN: 1688, nostos + algos, "enfermedad" */
export const Origen: React.FC = () => {
  const m = LINEA.marcas("origen");
  const frame = useCurrentFrame();
  const sello = interpolate(frame, [m("enfermedad"), m("enfermedad") + 8], [0, 1], CLAMP);
  return (
    <Escena id="origen" etiqueta="UN POCO DE HISTORIA" titulo="Una palabra de 1688" claves={["nostalgia", "dolor", "enfermedad"]} golpes={[m("mil"), m("enfermedad")]}>
      <div style={{ position: "relative", width: 820, height: 600, transform: "translateX(-40px)" }}>
        <Pop desde={m("nostalgia")} giro={-3}>
          <div style={{ width: 820, background: PAPEL, borderRadius: 18, padding: "30px 40px", boxShadow: "0 18px 40px #00000066", display: "flex", flexDirection: "column", alignItems: "center", gap: 18 }}>
            <div style={{ display: "flex", justifyContent: "space-between", width: "100%", fontFamily: F.cifra, fontWeight: 700, fontSize: 30, color: "#6b4a33" }}>
              <span>Dr. J. Hofer</span>
              <span>Suiza</span>
            </div>
            <Pop desde={m("mil")}>
              <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 120, color: "#3a2a5e", lineHeight: 1 }}>1688</div>
            </Pop>
            <Pop desde={m("significa")}>
              <div style={{ display: "flex", alignItems: "center", gap: 18, fontFamily: F.titulo, fontWeight: 800, fontSize: 52, color: "#3a2a5e" }}>
                <div style={{ textAlign: "center" }}>
                  NOSTOS
                  <div style={{ fontFamily: F.texto, fontWeight: 600, fontSize: 26, color: "#6b4a33" }}>volver a casa</div>
                </div>
                <span style={{ color: C.panuelo }}>+</span>
                <div style={{ textAlign: "center" }}>
                  ALGOS
                  <div style={{ fontFamily: F.texto, fontWeight: 600, fontSize: 26, color: "#6b4a33" }}>dolor</div>
                </div>
              </div>
            </Pop>
          </div>
        </Pop>
        {frame >= m("enfermedad") ? (
          <div style={{ position: "absolute", right: -10, bottom: 60, transform: `rotate(-14deg) scale(${2 - sello})`, opacity: sello, fontFamily: F.titulo, fontWeight: 800, fontSize: 64, color: C.panuelo, border: `6px solid ${C.panuelo}`, borderRadius: 14, padding: "0 20px", background: "#efe3c8cc" }}>
            ENFERMEDAD
          </div>
        ) : null}
      </div>
      <S id="tic" en={m("mil")} volumen={0.3} />
      <S id="pop" en={m("significa")} volumen={0.3} />
      <S id="golpe" en={m("enfermedad")} volumen={0.35} />
    </Escena>
  );
};

/* 3 · CEREBRO: el sistema de recompensa se enciende */
export const Cerebro: React.FC = () => {
  const m = LINEA.marcas("cerebro");
  const frame = useCurrentFrame();
  const s = useSeg();
  const luz = interpolate(frame, [m("recompensa"), m("recompensa") + 20], [0, 1], CLAMP);
  const chips = [
    { t: "recuerdos", w: "recuerdo", x: 40, y: 60, i: <IcoCorazon tamano={46} /> },
    { t: "comida", w: "comida", x: 620, y: 70, i: null },
    { t: "música", w: "musica", x: 620, y: 360, i: <IcoCasete tamano={50} /> },
  ];
  return (
    <Escena id="cerebro" etiqueta="LA CIENCIA" titulo="Tu cerebro lo premia" claves={["recompensa"]} golpes={[m("recompensa")]}>
      <div style={{ position: "relative", width: 1000, height: 620 }}>
        <svg width={1000} height={620} style={{ position: "absolute", inset: 0 }}>
          {chips.map((c) => (
            <line key={c.w} x1={500} y1={300} x2={c.x + 120} y2={c.y + 30} stroke={C.cascabel} strokeWidth={6} strokeDasharray="14 12" strokeDashoffset={-s * 60} opacity={frame >= m(c.w) ? 0.8 : 0} />
          ))}
        </svg>
        <div style={{ position: "absolute", left: 500 - 170, top: 300 - 170, width: 340, height: 340, borderRadius: 170, background: `radial-gradient(circle, ${C.cascabel}${Math.round(luz * 140 + 20).toString(16).padStart(2, "0")} 0%, transparent 70%)` }} />
        <Pop desde={m("recuerdo")} style={{ position: "absolute", left: 500 - 140, top: 300 - 140 }}>
          <Respira amp={0.04}>
            <IcoCerebro tamano={280} />
          </Respira>
        </Pop>
        <Pop desde={m("recompensa")} style={{ position: "absolute", left: 290, top: 500 }}>
          <Brillo color={C.cascabel}>
            <Chip texto="RECOMPENSA" color={C.cascabel} tamano={46} icono={<IcoEstrella tamano={50} color={C.hueso} />} />
          </Brillo>
        </Pop>
        {chips.map((c) => (
          <Pop key={c.w} desde={m(c.w)} style={{ position: "absolute", left: c.x, top: c.y }}>
            <Chip texto={c.t} color={C.hueso} tamano={38} icono={c.i} />
          </Pop>
        ))}
      </div>
      <S id="pop" en={m("recuerdo")} volumen={0.3} />
      <S id="brillo" en={m("recompensa")} volumen={0.35} />
      <S id="tic" en={m("comida")} volumen={0.25} />
      <S id="tic" en={m("musica")} volumen={0.25} />
    </Escena>
  );
};

/* 4 · FILTRO: lo malo se borra antes que lo bueno */
export const Filtro: React.FC = () => {
  const m = LINEA.marcas("filtro");
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const recuerdos = [
    { b: true, x: 60, y: 60 },
    { b: false, x: 300, y: 20 },
    { b: true, x: 540, y: 80 },
    { b: false, x: 760, y: 40 },
    { b: false, x: 140, y: 250 },
    { b: true, x: 420, y: 240 },
    { b: false, x: 680, y: 260 },
  ];
  return (
    <Escena id="filtro" etiqueta="LA TRAMPA" titulo="Tu memoria edita el pasado" claves={["trampa", "mejor"]} golpes={[m("trampa"), m("mejor")]}>
      <div style={{ position: "relative", width: 1000, height: 620 }}>
        {recuerdos.map((r, k) => {
          const borra = r.b ? 0 : interpolate(frame, [m("malo") + k * 5, m("malo") + k * 5 + fps * 0.8], [0, 1], CLAMP);
          return (
            <Pop key={k} desde={m("memoria") + k * 3} style={{ position: "absolute", left: r.x, top: r.y }}>
              <div style={{ opacity: 1 - borra * 0.9, filter: `blur(${borra * 10}px)`, transform: `scale(${1 - borra * 0.3})` }}>
                <div style={{ width: 170, height: 170, borderRadius: 85, background: r.b ? `${C.menta}33` : `${C.panuelo}33`, border: `5px solid ${r.b ? C.menta : C.panuelo}`, display: "flex", alignItems: "center", justifyContent: "center" }}>
                  {r.b ? <IcoCorazon tamano={90} color={C.menta} /> : <IcoCorazon tamano={90} roto />}
                </div>
              </div>
            </Pop>
          );
        })}
        <Pop desde={m("malo")} style={{ position: "absolute", left: 110, top: 470 }}>
          <Chip texto="lo malo se borra antes" color={C.panuelo} oscuro tamano={36} />
        </Pop>
        <Pop desde={m("mejor")} style={{ position: "absolute", left: 300, top: 530 }} giro={-3}>
          <Brillo>
            <Chip texto="PASADO = MEJOR" color={C.menta} tamano={48} />
          </Brillo>
        </Pop>
      </div>
      <S id="glitch" en={m("trampa")} volumen={0.2} />
      <S id="whoosh" en={m("malo")} volumen={0.25} />
      <S id="exito" en={m("mejor")} volumen={0.25} />
    </Escena>
  );
};

/* 5 · TRISTEZA: algo bonito que no vuelve: agridulce */
export const Tristeza: React.FC = () => {
  const m = LINEA.marcas("tristeza");
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const desvanece = interpolate(frame, [m("volver"), m("volver") + fps * 1.2], [0, 1], CLAMP);
  return (
    <Escena id="tristeza" etiqueta="¿POR QUÉ DUELE?" titulo="Alegría y pérdida a la vez" claves={["duele", "volver"]} golpes={[m("duele"), m("perdida")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 34, transform: "translateX(-50px)" }}>
        <Pop desde={m("bonito")}>
          <div style={{ opacity: 1 - desvanece * 0.75, filter: `blur(${desvanece * 4}px)` }}>
            <Polaroid ancho={300} giro={-5} fecha="12 03 2012" pie="aquel día">
              <div style={{ position: "absolute", inset: 0, background: "linear-gradient(#ffb36b, #8a5fd1)" }} />
              <NyxarFoto ancho={200} />
            </Polaroid>
          </div>
        </Pop>
        <div style={{ display: "flex", alignItems: "center", gap: 22 }}>
          <Pop desde={m("alegria")}>
            <Chip texto="alegría" color={C.menta} tamano={44} />
          </Pop>
          <Pop desde={m("perdida")}>
            <IcoCorazon tamano={110} roto />
          </Pop>
          <Pop desde={m("perdida")}>
            <Chip texto="pérdida" color={C.panuelo} tamano={44} />
          </Pop>
        </div>
      </div>
      <S id="latido" en={m("duele")} volumen={0.35} />
      <S id="whoosh" en={m("volver")} volumen={0.2} />
      <S id="pop" en={m("alegria")} volumen={0.3} />
      <S id="error" en={m("perdida")} volumen={0.2} />
    </Escena>
  );
};

/* 6 · GIRO: la nostalgia nos hace sentir menos solos */
export const Giro: React.FC = () => {
  const m = LINEA.marcas("giro");
  const frame = useCurrentFrame();
  const s = useSeg();
  const calor = interpolate(frame, [m("solos"), m("solos") + 25], [0, 1], CLAMP);
  return (
    <Escena id="giro" etiqueta="EL GIRO" titulo="No es mala: es un refugio" claves={["solos", "refugio"]} golpes={[m("solos"), m("refugio")]}>
      <div style={{ position: "relative", width: 1000, height: 620, transform: "translateX(60px)" }}>
        <div style={{ position: "absolute", left: 500 - 260, top: 290 - 260, width: 520, height: 520, borderRadius: 260, background: `radial-gradient(circle, ${C.cascabel}${Math.round(calor * 110).toString(16).padStart(2, "0")} 0%, transparent 70%)` }} />
        {[0, 1, 2, 3, 4].map((k) => {
          const a = (k / 5) * Math.PI * 2 - Math.PI / 2;
          const r = 210 - calor * 50;
          return (
            <Pop key={k} desde={m("estudios") + k * 4} style={{ position: "absolute", left: 500 + Math.cos(a) * r - 55, top: 290 + Math.sin(a) * r - 55 + Math.sin(s * 2 + k) * 6 }}>
              <IcoPersona tamano={110} color={[C.azul, C.menta, C.cascabel, "#ff8da1", "#9b7fe0"][k]} />
            </Pop>
          );
        })}
        <Pop desde={m("solos")} style={{ position: "absolute", left: 500 - 70, top: 290 - 70 }}>
          <Respira amp={0.06}>
            <IcoCorazon tamano={140} />
          </Respira>
        </Pop>
        <Pop desde={m("solos")} style={{ position: "absolute", left: 300, top: 530 }}>
          <Chip texto="menos solos" color={C.cascabel} tamano={44} />
        </Pop>
        {frame >= m("refugio") ? <Rafaga en={m("refugio")} color={C.cascabel} tamano={600} /> : null}
      </div>
      <S id="pop" en={m("estudios")} volumen={0.25} />
      <S id="brillo" en={m("solos")} volumen={0.3} />
      <S id="exito" en={m("refugio")} volumen={0.25} />
    </Escena>
  );
};

/* 7 · PREGUNTA: volver o quedarse */
export const Pregunta: React.FC = () => {
  const m = LINEA.marcas("pregunta");
  const { fps } = useVideoConfig();
  const firma = m("leo") + Math.round(fps * 0.4);
  return (
    <Escena id="pregunta" etiqueta="¿Y TÚ?" titulo="¿Volverías al pasado?" claves={["volverias", "quedas"]} golpes={[m("volverias"), m("quedas")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 40, transform: "translateX(-50px)" }}>
        <div style={{ display: "flex", gap: 34 }}>
          {[
            { t: "VOLVER", i: <IcoCasete tamano={96} color={C.hueso} />, c: C.cascabel, w: "volverias" },
            { t: "QUEDARME", i: <IcoEstrella tamano={92} color={C.hueso} />, c: C.menta, w: "quedas" },
          ].map((b, k) => (
            <Pop key={b.w} desde={m(b.w)} giro={k ? 8 : -8}>
              <Respira fase={k * 1.5} amp={0.05}>
                <div style={{ width: 300, height: 230, borderRadius: 40, background: b.c, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 10, fontFamily: F.titulo, fontWeight: 800, fontSize: 50, color: C.abismo }}>
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
      <S id="pop" en={m("volverias")} volumen={0.3} />
      <S id="pop" en={m("quedas")} volumen={0.3} />
      <S id="cascabel" en={firma} volumen={0.45} />
    </Escena>
  );
};
