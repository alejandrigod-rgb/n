import { interpolate, useCurrentFrame, useVideoConfig } from "remotion";
import { Brillo, Pop, Respira, useSeg } from "../marca/kit";
import { IcoCalculadora, IcoCasa, IcoCorazon, IcoHuella, IcoMal, IcoMovil, IcoPersona, IcoTrofeo } from "../marca/iconos";
import { C, CLAMP, F } from "../marca/tema";
import { Escena, S } from "./comun";
import { LINEA } from "./linea";

const HIELO = "#9fc3ff";

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

/** Burbuja de comentario de red social (texto inventado que representa el discurso). */
const Comentario: React.FC<{ texto: string; likes: string }> = ({ texto, likes }) => (
  <div style={{ display: "flex", gap: 14, alignItems: "flex-start", background: "#101a33", borderRadius: 20, padding: "14px 18px", width: 560 }}>
    <span style={{ width: 44, height: 44, borderRadius: 22, background: "#3a4466", flexShrink: 0 }} />
    <div style={{ flex: 1 }}>
      <div style={{ fontFamily: F.texto, fontWeight: 600, fontSize: 28, color: C.hueso, lineHeight: 1.2 }}>{texto}</div>
      <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 20, color: C.niebla, marginTop: 6 }}>{likes} me gusta</div>
    </div>
  </div>
);

/* 1 · GANCHO: la palabra, enorme, desde el fotograma 0, y comentarios que deprimen */
export const Gancho: React.FC = () => {
  const m = LINEA.marcas("gancho");
  const s = useSeg();
  return (
    <Escena id="gancho" etiqueta="¿QUÉ ES…?" titulo="La palabra que deprime a internet" claves={["deprime", "internet"]} golpes={[0, m("deprime")]} sinEntrada>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 26, transform: "translateX(80px)" }}>
        <Brillo color={C.panuelo}>
          <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 124, color: "#ff8da1", background: "rgba(2,8,20,0.9)", border: `4px solid ${C.panuelo}`, borderRadius: 28, padding: "0 36px", letterSpacing: 2, transform: `translateX(${Math.sin(s * 40) * (s < 0.4 ? 6 : 0)}px)` }}>HIPERGAMIA</div>
        </Brillo>
        <Pop desde={m("deprime")}>
          <Comentario texto="si no tienes dinero, olvídate" likes="12,4 mil" />
        </Pop>
        <Pop desde={m("internet")}>
          <Comentario texto="nadie elige al chico normal" likes="8,1 mil" />
        </Pop>
      </div>
      <S id="cascabel" en={0} volumen={0.35} />
      <S id="golpe" en={0} volumen={0.3} />
      <S id="pop" en={m("deprime")} volumen={0.25} />
      <S id="pop" en={m("internet")} volumen={0.25} />
    </Escena>
  );
};

/* 2 · QUÉ ES: emparejarse "hacia arriba" */
export const Que: React.FC = () => {
  const m = LINEA.marcas("que");
  const frame = useCurrentFrame();
  const sube = interpolate(frame, [m("buscar"), m("dinero")], [0, 1], CLAMP);
  return (
    <Escena id="que" etiqueta="LA DEFINICIÓN" titulo="Emparejarse hacia arriba" claves={["hipergamia", "sociologia"]} golpes={[m("hipergamia"), m("sociologia")]}>
      <div style={{ position: "relative", width: 900, height: 600, transform: "translateX(-60px)" }}>
        {/* Escalera */}
        {[0, 1, 2, 3].map((k) => (
          <Pop key={k} desde={m("hipergamia") + k * 4} style={{ position: "absolute", left: 120 + k * 150, top: 440 - k * 100 }}>
            <div style={{ width: 150, height: 30 + k * 100, background: `linear-gradient(${HIELO}55, ${HIELO}22)`, border: `4px solid ${HIELO}`, borderRadius: 10 }} />
          </Pop>
        ))}
        <div style={{ position: "absolute", left: 140 + sube * 0, top: 340 }}>
          <IcoPersona tamano={110} color={C.niebla} />
        </div>
        <Pop desde={m("dinero")} style={{ position: "absolute", left: 590, top: 30 }}>
          <IcoPersona tamano={120} color={C.cascabel} />
        </Pop>
        <svg width={900} height={600} style={{ position: "absolute", inset: 0 }}>
          <path d={`M200 330 Q400 ${200 - sube * 40} 600 140`} fill="none" stroke={C.cascabel} strokeWidth={8} strokeDasharray="20 14" opacity={sube} />
        </svg>
        <Pop desde={m("dinero")} style={{ position: "absolute", left: 600, top: 180 }}>
          <Chip texto="+ dinero" color={C.cascabel} tamano={36} />
        </Pop>
        <Pop desde={m("estudios")} style={{ position: "absolute", left: 600, top: 250 }}>
          <Chip texto="+ estudios" color={HIELO} tamano={36} />
        </Pop>
        <Pop desde={m("sociologia")} style={{ position: "absolute", left: 40, top: 40 }}>
          <Chip texto="término de sociología" color={C.hueso} oscuro tamano={32} />
        </Pop>
      </div>
      <S id="subida" en={m("buscar")} volumen={0.25} />
      <S id="pop" en={m("dinero")} volumen={0.25} />
      <S id="tic" en={m("sociologia")} volumen={0.25} />
    </Escena>
  );
};

/* 3 · LA REGLA: internet la convierte en ley */
export const Regla: React.FC = () => {
  const m = LINEA.marcas("regla");
  return (
    <Escena id="regla" etiqueta="¿POR QUÉ DUELE?" titulo="Internet la volvió una regla" claves={["tristeza", "nadie"]} golpes={[m("regla"), m("nadie")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 34, transform: "translateX(-60px)" }}>
        <Pop desde={m("regla")} giro={-2}>
          <div style={{ width: 720, background: "#0c1426", border: `4px solid ${C.panuelo}`, borderRadius: 26, padding: "26px 34px" }}>
            <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 28, color: C.panuelo, letterSpacing: 4 }}>"REGLA" DE INTERNET</div>
            <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 62, color: C.hueso, lineHeight: 1.05, marginTop: 10 }}>
              sin dinero
              <br />= nadie te elige
            </div>
          </div>
        </Pop>
        <Pop desde={m("tienes")}>
          <div style={{ display: "flex", alignItems: "center", gap: 30 }}>
            <IcoPersona tamano={130} color={C.niebla} />
            <Respira amp={0.05}>
              <IcoCorazon tamano={110} roto />
            </Respira>
          </div>
        </Pop>
      </div>
      <S id="latido" en={m("tristeza")} volumen={0.3} />
      <S id="golpe" en={m("regla")} volumen={0.25} />
      <S id="error" en={m("nadie")} volumen={0.2} />
    </Escena>
  );
};

/* 4 · COMPARAR: el feed solo enseña al 1 % */
export const Comparar: React.FC = () => {
  const m = LINEA.marcas("comparar");
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const scroll = interpolate(frame, [m("redes"), m("comparas")], [0, -260], CLAMP);
  const yo = interpolate(frame, [m("suficiente"), m("suficiente") + fps * 0.8], [1, 0.55], CLAMP);
  return (
    <Escena id="comparar" etiqueta="LA COMPARACIÓN" titulo="Solo ves al 1 %" claves={["redes", "suficiente"]} golpes={[m("redes"), m("suficiente")]}>
      <div style={{ display: "flex", alignItems: "center", gap: 50, transform: "translateX(-40px)" }}>
        <Pop desde={m("redes")}>
          <div style={{ width: 330, height: 560, borderRadius: 46, background: "#0b1124", border: `8px solid #2b3350`, overflow: "hidden", position: "relative" }}>
            <div style={{ position: "absolute", left: 20, right: 20, top: 30 + scroll, display: "flex", flexDirection: "column", gap: 18 }}>
              {new Array(7).fill(0).map((_, k) => (
                <div key={k} style={{ height: 120, borderRadius: 18, background: "linear-gradient(135deg, #3a3060, #6b4fb3)", display: "flex", alignItems: "center", gap: 14, padding: "0 16px" }}>
                  <IcoTrofeo tamano={64} />
                  <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 22, color: C.cascabel }}>coche, viaje,{"\n"}reloj…</div>
                </div>
              ))}
            </div>
          </div>
        </Pop>
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 24 }}>
          <Pop desde={m("redes")}>
            <Brillo color={C.cascabel}>
              <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 120, color: C.cascabel }}>1 %</div>
            </Brillo>
          </Pop>
          <Pop desde={m("comparas")}>
            <div style={{ opacity: yo, transform: `scale(${0.8 + yo * 0.2})`, display: "flex", flexDirection: "column", alignItems: "center", gap: 8 }}>
              <IcoPersona tamano={160} color={C.niebla} />
              <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 40, color: C.hueso }}>tú</div>
            </div>
          </Pop>
        </div>
      </div>
      <S id="whoosh" en={m("redes")} volumen={0.25} />
      <S id="tic" en={m("comparas")} volumen={0.25} />
      <S id="latido" en={m("suficiente")} volumen={0.3} />
    </Escena>
  );
};

/* 5 · DATOS: las parejas se parecen, y hoy ella suele tener más estudios */
export const Datos: React.FC = () => {
  const m = LINEA.marcas("datos");
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const crece = (desde: number) => interpolate(frame, [desde, desde + fps * 0.8], [0, 1], { ...CLAMP, easing: (x) => 1 - Math.pow(1 - x, 3) });
  const juntos = crece(m("parecen"));
  return (
    <Escena id="datos" etiqueta="LOS DATOS" titulo="La realidad es otra" claves={["datos", "mayoria", "ella"]} golpes={[m("datos"), m("ella")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 30, transform: "translateX(60px)" }}>
        <Pop desde={m("mayoria")}>
          <div style={{ display: "flex", alignItems: "center", gap: 24, background: "rgba(2,8,20,0.85)", borderRadius: 26, padding: "18px 30px" }}>
            <div style={{ position: "relative", width: 220, height: 130 }}>
              <div style={{ position: "absolute", left: 40 - juntos * 25, top: 0, width: 130, height: 130, borderRadius: 65, background: `${C.menta}55`, border: `5px solid ${C.menta}` }} />
              <div style={{ position: "absolute", left: 90 + juntos * 25 - 50 * juntos, top: 0, width: 130, height: 130, borderRadius: 65, background: `${HIELO}55`, border: `5px solid ${HIELO}` }} />
            </div>
            <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 46, color: C.hueso, lineHeight: 1.05 }}>
              la mayoría
              <br />
              <span style={{ color: C.menta }}>se parece</span>
            </div>
          </div>
        </Pop>
        <Pop desde={m("ella")}>
          <div style={{ width: 640, background: "rgba(2,8,20,0.85)", borderRadius: 26, padding: "22px 30px", display: "flex", flexDirection: "column", gap: 16 }}>
            <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 24, color: C.niebla }}>parejas con distintos estudios</div>
            <div style={{ display: "flex", alignItems: "center", gap: 16, opacity: 1 - crece(m("ella")) * 0.55 }}>
              <div style={{ width: 120, fontFamily: F.cifra, fontWeight: 700, fontSize: 26, color: C.niebla }}>antes</div>
              <div style={{ fontFamily: F.texto, fontWeight: 600, fontSize: 32, color: C.hueso }}>él tenía más estudios</div>
            </div>
            <div style={{ display: "flex", alignItems: "center", gap: 16, transform: `scale(${0.9 + crece(m("ella")) * 0.1})`, transformOrigin: "left center" }}>
              <div style={{ width: 120, fontFamily: F.cifra, fontWeight: 700, fontSize: 26, color: C.menta }}>hoy</div>
              <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 40, color: C.menta }}>ella tiene más estudios</div>
            </div>
            <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 20, color: C.niebla }}>tendencia en España y Latinoamérica</div>
          </div>
        </Pop>
      </div>
      <S id="clic" en={m("datos")} volumen={0.3} />
      <S id="pop" en={m("mayoria")} volumen={0.25} />
      <S id="subida" en={m("ella")} volumen={0.25} />
    </Escena>
  );
};

/* 6 · REMATE: no elegimos con calculadora */
export const Remate: React.FC = () => {
  const m = LINEA.marcas("remate");
  const frame = useCurrentFrame();
  const tacha = interpolate(frame, [m("calculadora") + 10, m("calculadora") + 22], [0, 1], CLAMP);
  return (
    <Escena id="remate" etiqueta="EN RESUMEN" titulo="El amor no es una cuenta" claves={["calculadora", "casa"]} golpes={[m("calculadora"), m("casa")]}>
      <div style={{ display: "flex", alignItems: "center", gap: 70, transform: "translateX(-50px)" }}>
        <Pop desde={m("calculadora")}>
          <div style={{ position: "relative", opacity: 1 - tacha * 0.4 }}>
            <IcoCalculadora tamano={220} />
            <div style={{ position: "absolute", left: 30, top: 30, transform: `scale(${tacha})` }}>
              <IcoMal tamano={160} />
            </div>
          </div>
        </Pop>
        <Pop desde={m("elegimos")}>
          <Brillo color={C.cascabel}>
            <div style={{ position: "relative" }}>
              <IcoCasa tamano={240} />
              <div style={{ position: "absolute", left: 160, top: -10 }}>
                <IcoCorazon tamano={90} />
              </div>
            </div>
          </Brillo>
        </Pop>
      </div>
      <S id="error" en={m("calculadora") + 10} volumen={0.2} />
      <S id="brillo" en={m("casa")} volumen={0.3} />
    </Escena>
  );
};

/* 7 · PREGUNTA: ¿importa más el dinero que antes? */
export const Pregunta: React.FC = () => {
  const m = LINEA.marcas("pregunta");
  const { fps } = useVideoConfig();
  const firma = m("leo") + Math.round(fps * 0.4);
  return (
    <Escena id="pregunta" etiqueta="¿Y TÚ?" titulo="¿El dinero importa más que antes?" claves={["dinero", "antes"]} golpes={[m("dinero"), m("antes")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 40, transform: "translateX(-50px)" }}>
        <div style={{ display: "flex", gap: 34 }}>
          {[
            { t: "SÍ, MÁS", i: <IcoMovil tamano={92} />, c: C.cascabel, w: "dinero" },
            { t: "NO, IGUAL", i: <IcoCasa tamano={92} color={C.hueso} />, c: HIELO, w: "antes" },
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
            <span style={{ width: 36, height: 36, borderRadius: 18, background: "#8c90ab", border: `3px solid ${C.hueso}`, display: "inline-block" }} />
            @ithnoir · comenta <IcoHuella tamano={56} color="#8c90ab" />
          </div>
        </Pop>
      </div>
      <S id="pop" en={m("dinero")} volumen={0.3} />
      <S id="pop" en={m("antes")} volumen={0.3} />
      <S id="cascabel" en={firma} volumen={0.35} />
    </Escena>
  );
};
