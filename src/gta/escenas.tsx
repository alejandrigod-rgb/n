import { interpolate, useCurrentFrame, useVideoConfig } from "remotion";
import { Brillo, Contador, Pop, Rafaga, Respira, useSeg } from "../marca/kit";
import { C, CLAMP, F } from "../marca/tema";
import { Escena, S } from "./comun";
import { LINEA } from "./linea";

const Chip: React.FC<{ texto: string; color?: string; tamano?: number }> = ({ texto, color = C.menta, tamano = 40 }) => (
  <div style={{ display: "inline-block", fontFamily: F.cifra, fontWeight: 700, fontSize: tamano, color: C.abismo, background: color, padding: "6px 22px", borderRadius: 999, whiteSpace: "nowrap" }}>{texto}</div>
);

/* 1 · GANCHO: el contador de 212 GB y las 40 películas */
export const Gancho: React.FC = () => {
  const m = LINEA.marcas("gancho");
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const relleno = interpolate(frame, [0, m("gigas")], [0.08, 1], CLAMP);
  const subir = interpolate(frame, [m("mas") - 8, m("mas") + 10], [0, 1], CLAMP);
  return (
    <Escena id="gancho" etiqueta="¿POR QUÉ…?" titulo="¿Por qué GTA VI pesa tanto?" claves={["gigas", "tanto"]} golpes={[m("doce"), m("tanto")]} sinEntrada>
      <div style={{ position: "relative", width: 1000, height: 620, display: "flex", flexDirection: "column", alignItems: "center" }}>
        <div style={{ transform: `translateY(${-subir * 30}px) scale(${1 - subir * 0.25})`, display: "flex", flexDirection: "column", alignItems: "center", gap: 26 }}>
          <Brillo>
            <Contador hasta={212} inicio={m("doscientos")} dur={1.2} sufijo=" GB" tamano={130} />
          </Brillo>
          <div style={{ width: 760, height: 46, borderRadius: 23, border: `3px solid ${C.menta}88`, background: "rgba(2,8,20,0.7)", overflow: "hidden" }}>
            <div style={{ width: `${relleno * 100}%`, height: "100%", background: relleno > 0.95 ? C.panuelo : C.menta, boxShadow: `0 0 24px ${C.menta}` }} />
          </div>
          <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 30, color: relleno > 0.95 ? "#ff8da1" : C.niebla }}>{relleno > 0.95 ? "ALMACENAMIENTO LLENO" : "descargando…"}</div>
        </div>
        <div style={{ position: "absolute", top: 262, display: "grid", gridTemplateColumns: "repeat(10, 64px)", gap: 12 }}>
          {new Array(40).fill(0).map((_, k) => (
            <Pop key={k} desde={m("cuarenta") + k * Math.round(fps * 0.018)}>
              <svg width={64} height={50} viewBox="0 0 64 50" style={{ display: "block" }}>
                <rect x={3} y={3} width={58} height={44} rx={7} fill="#0c2f3a" stroke={C.menta} strokeWidth={3} />
                <polygon points="26,15 42,25 26,35" fill={C.cascabel} />
              </svg>
            </Pop>
          ))}
        </div>
        <div style={{ position: "absolute", top: 548 }}>
          <Pop desde={m("pelis")}>
            <Chip texto="= 40 películas en HD" color={C.cascabel} />
          </Pop>
        </div>
      </div>
      <S id="cascabel" en={0} volumen={0.45} />
      <S id="descarga" en={m("doscientos")} volumen={0.3} />
      <S id="golpe" en={m("gigas")} volumen={0.35} />
      <S id="pop" en={m("cuarenta")} volumen={0.3} />
      <S id="golpe" en={m("tanto")} volumen={0.25} />
    </Escena>
  );
};

/* 2 · TEXTURAS: un coche neón que pasa de pixelado a nítido */
const enCoche = (x: number, y: number): string | null => {
  // Lienzo 0-1. Ruedas, cristales, carrocería y luces.
  const rueda = (cx: number) => (x - cx) ** 2 + ((y - 0.72) / 1) ** 2 < 0.0085;
  if (rueda(0.27) || rueda(0.73)) return "#1d1530";
  if (y > 0.36 && y < 0.5 && x > 0.32 && x < 0.68 && !(x > 0.49 && x < 0.51)) return "#8fd8ff";
  if (y > 0.3 && y < 0.52 && x > 0.28 && x < 0.72) return "#c2334d";
  if (y > 0.5 && y < 0.72 && x > 0.1 && x < 0.9) {
    if (x > 0.84 && y < 0.6) return C.cascabel;
    if (y > 0.6 && y < 0.63) return "#ff8da1";
    return "#e04563";
  }
  return null;
};

export const Texturas: React.FC = () => {
  const m = LINEA.marcas("texturas");
  const frame = useCurrentFrame();
  const niveles = [m("texturas"), m("pared"), m("coche"), m("cara"), m("detalle")];
  const nivel = niveles.filter((f) => frame >= f).length;
  const n = [6, 10, 18, 34, 64, 64][nivel];
  const lado = 560;
  const celda = lado / n;
  const rects = [];
  for (let i = 0; i < n; i++) {
    for (let j = 0; j < n; j++) {
      const col = enCoche((i + 0.5) / n, (j + 0.5) / n);
      if (col) rects.push(<rect key={`${i}-${j}`} x={i * celda} y={j * celda} width={celda + 0.6} height={celda + 0.6} fill={col} />);
    }
  }
  return (
    <Escena id="texturas" etiqueta="RAZÓN 1" titulo="Texturas con muchísimo detalle" claves={["detalle"]} golpes={[m("detalle")]}>
      <div style={{ position: "relative", display: "flex", flexDirection: "column", alignItems: "center", gap: 16 }}>
        <Respira amp={0.015}>
          <Brillo color={C.panuelo} fuerza={0.8}>
            <div style={{ width: lado, height: lado * 0.86, borderRadius: 30, border: `3px solid ${C.menta}66`, background: "rgba(2,8,20,0.6)", overflow: "hidden" }}>
              <svg width={lado} height={lado} viewBox={`0 0 ${lado} ${lado}`} style={{ marginTop: -lado * 0.1 }} shapeRendering={nivel >= 5 ? "auto" : "crispEdges"}>
                {rects}
              </svg>
            </div>
          </Brillo>
        </Respira>
        <div style={{ display: "flex", gap: 16 }}>
          {["pared", "coche", "cara"].map((w, k) => (
            <Pop key={w} desde={m(w)}>
              <Chip texto={["240p", "1080p", "4K"][k]} color={k === 2 ? C.menta : C.niebla} />
            </Pop>
          ))}
        </div>
      </div>
      {["pared", "coche", "cara"].map((w) => <S key={w} id="tic" en={m(w)} volumen={0.4} />)}
      <S id="lupa" en={m("detalle") - 6} volumen={0.35} />
    </Escena>
  );
};

/* 3 · SONIDO: onda, idiomas, radio y miles de efectos */
const IDIOMAS = ["ES", "EN", "FR", "DE", "IT", "PT", "JA", "KO"];

export const Sonido: React.FC = () => {
  const m = LINEA.marcas("sonido");
  const s = useSeg();
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const radio = frame >= m("radio");
  return (
    <Escena id="sonido" etiqueta="RAZÓN 2" titulo="Sonido para dar y regalar" claves={["idiomas"]} golpes={[m("idiomas")]}>
      <div style={{ position: "relative", width: 1000, height: 600 }}>
        <svg width={1000} height={600} viewBox="-500 -300 1000 600" style={{ position: "absolute" }}>
          {new Array(28).fill(0).map((_, k) => {
            const h = 30 + 120 * Math.abs(Math.sin(s * 5 + k * 0.7) * Math.sin(s * 2.3 + k * 0.3));
            return <rect key={k} x={-280 + k * 20} y={-h / 2} width={12} height={h} rx={6} fill={k % 2 ? C.menta : C.azul} opacity={0.9} />;
          })}
        </svg>
        {IDIOMAS.map((l, k) => {
          const a = (k / IDIOMAS.length) * Math.PI * 2 - Math.PI / 2;
          return (
            <div key={l} style={{ position: "absolute", left: 500 + Math.cos(a) * 400 - 50, top: 300 + Math.sin(a) * 230 - 30 }}>
              <Pop desde={m("idiomas") + k * Math.round(fps * 0.07)}>
                <Chip texto={l} color={k % 2 ? C.menta : C.cascabel} tamano={36} />
              </Pop>
            </div>
          );
        })}
        <div style={{ position: "absolute", left: 360, top: 420 }}>
          <Pop desde={m("radio")}>
            <div style={{ display: "flex", alignItems: "center", gap: 14, fontFamily: F.cifra, fontWeight: 700, fontSize: 36, color: C.hueso, background: "rgba(2,8,20,0.8)", border: `2px solid ${C.cascabel}88`, borderRadius: 16, padding: "8px 20px" }}>
              <span style={{ color: C.cascabel }}>FM</span> {radio ? (101.3 + ((Math.floor(s * 3) % 5) * 1.7)).toFixed(1) : "—"}
            </div>
          </Pop>
        </div>
        <div style={{ position: "absolute", left: 0, right: 0, top: -20, display: "flex", justifyContent: "center" }}>
          <Pop desde={m("miles")}>
            <Contador hasta={1000} inicio={m("miles")} dur={0.7} sufijo="+ efectos" tamano={56} color={C.cascabel} />
          </Pop>
        </div>
      </div>
      <S id="pop" en={m("idiomas")} volumen={0.3} />
      <S id="radio" en={m("radio")} volumen={0.3} />
      <S id="tic" en={m("miles")} volumen={0.4} />
    </Escena>
  );
};

/* 4 · MAPA: una ciudad neón que se vuelve enorme */
const CALLES_H = [-240, -150, -60, 30, 120, 210];
const CALLES_V = [-420, -300, -180, -60, 60, 180, 300, 420];

export const Mapa: React.FC = () => {
  const m = LINEA.marcas("mapa");
  const frame = useCurrentFrame();
  const s = useSeg();
  const zoom = interpolate(frame, [m("ciudad"), m("enorme") + 40], [1.8, 0.9], { ...CLAMP, easing: (x) => 1 - Math.pow(1 - x, 3) });
  const dibujo = interpolate(frame, [0, m("ciudad")], [0, 1], CLAMP);
  // Coche recorriendo un circuito
  const ruta = (u: number) => {
    const per = 4 * (840 + 450);
    let d = (u % 1) * per;
    const lados = [[840, 1, 0], [450, 0, 1], [840, -1, 0], [450, 0, -1]];
    let x = -420, y = -240;
    for (const [len, dx, dy] of lados) {
      const paso = Math.min(d, len);
      x += dx * paso;
      y += dy * paso;
      d -= paso;
      if (d <= 0) break;
    }
    return { x, y };
  };
  const coche = ruta(s * 0.18);
  return (
    <Escena id="mapa" etiqueta="RAZÓN 3" titulo="Un mapa gigante" claves={["carga"]} golpes={[m("enorme"), m("carga")]}>
      <div style={{ position: "relative", width: 1000, height: 600, overflow: "hidden", borderRadius: 36, border: `3px solid ${C.menta}55`, background: "rgba(2,8,20,0.6)" }}>
        <svg width={1000} height={600} viewBox="-500 -300 1000 600" style={{ position: "absolute" }}>
          <g transform={`scale(${zoom})`}>
            {CALLES_V.slice(0, -1).map((x, i) =>
              CALLES_H.slice(0, -1).map((y, j) => (
                <rect key={`${i}-${j}`} x={x + 14} y={y + 14} width={92} height={62} rx={8} fill={(i + j) % 3 ? "#123a52" : "#2a2060"} opacity={0.9} />
              )),
            )}
            {CALLES_H.map((y) => <line key={`h${y}`} x1={-440} y1={y} x2={440} y2={y} stroke={C.menta} strokeWidth={4} opacity={0.55} strokeDasharray={900} strokeDashoffset={900 * (1 - dibujo)} />)}
            {CALLES_V.map((x) => <line key={`v${x}`} x1={x} y1={-260} x2={x} y2={230} stroke={C.azul} strokeWidth={4} opacity={0.45} strokeDasharray={520} strokeDashoffset={520 * (1 - dibujo)} />)}
            <circle cx={coche.x} cy={coche.y} r={16} fill={C.cascabel} />
            <circle cx={coche.x} cy={coche.y} r={30} fill={C.cascabel} opacity={0.25} />
          </g>
        </svg>
        <div style={{ position: "absolute", bottom: 24, left: 0, right: 0, display: "flex", justifyContent: "center" }}>
          <Pop desde={m("sin")}>
            <Chip texto="SIN PANTALLAS DE CARGA" />
          </Pop>
        </div>
      </div>
      <S id="motor" en={m("ciudad")} volumen={0.3} />
      <S id="golpe" en={m("enorme")} volumen={0.25} />
      <S id="exito" en={m("carga")} volumen={0.25} />
    </Escena>
  );
};

/* 5 · GIRO: comprimido contra sin comprimir */
const Carril: React.FC<{ titulo: string; color: string; progreso: number; estado: string; icono: React.ReactNode }> = ({ titulo, color, progreso, estado, icono }) => (
  <div style={{ display: "flex", alignItems: "center", gap: 26, width: 920, background: "rgba(2,8,20,0.75)", border: `3px solid ${color}88`, borderRadius: 26, padding: "22px 28px" }}>
    {icono}
    <div style={{ flex: 1, minWidth: 0 }}>
      <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 46, color: C.hueso, lineHeight: 1 }}>{titulo}</div>
      <div style={{ height: 26, borderRadius: 13, background: "#ffffff14", marginTop: 14, overflow: "hidden" }}>
        <div style={{ width: `${progreso * 100}%`, height: "100%", background: color, boxShadow: `0 0 18px ${color}` }} />
      </div>
      <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 28, color, marginTop: 10 }}>{estado}</div>
    </div>
  </div>
);

export const Giro: React.FC = () => {
  const m = LINEA.marcas("giro");
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const salida = m("descomprimiendo");
  const lento = interpolate(frame, [salida, m("rapido") + fps * 1.2], [0, 0.55], CLAMP);
  const rapido = interpolate(frame, [salida, salida + fps * 0.5], [0, 1], { ...CLAMP, easing: (x) => 1 - Math.pow(1 - x, 3) });
  const caja = (
    <svg width={110} height={110} viewBox="0 0 110 110">
      <rect x={14} y={24} width={82} height={72} rx={10} fill="#3a2a70" stroke={C.cascabel} strokeWidth={5} />
      <rect x={48} y={24} width={14} height={72} fill={C.cascabel} opacity={0.8} />
      <path d="M20 24 L55 8 L90 24" fill="none" stroke={C.cascabel} strokeWidth={5} strokeLinejoin="round" />
    </svg>
  );
  const archivos = (
    <svg width={110} height={110} viewBox="0 0 110 110">
      {[0, 1, 2].map((k) => (
        <g key={k} transform={`translate(${12 + k * 18} ${10 + k * 12})`}>
          <path d="M0 0 H40 L56 16 V70 H0 Z" fill="#0c2f3a" stroke={C.menta} strokeWidth={4} strokeLinejoin="round" />
        </g>
      ))}
    </svg>
  );
  return (
    <Escena id="giro" etiqueta="EL GIRO" titulo="Lo curioso: a propósito" claves={["comprimir", "rapido"]} golpes={[m("curioso"), m("comprimir"), m("rapido")]}>
      <div style={{ position: "absolute", display: "flex", justifyContent: "center" }}>
        <Pop desde={m("curioso") - 4} hasta={m("algunos") - 10} giro={-15}>
          <Respira amp={0.06}>
            <Brillo color={C.cascabel}>
              <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 260, color: C.cascabel, lineHeight: 1 }}>¿?</div>
            </Brillo>
          </Respira>
        </Pop>
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 30, alignItems: "center" }}>
        <Pop desde={m("algunos")} giro={-6}>
          <Carril titulo="Comprimido" color={C.cascabel} progreso={lento} estado={frame >= salida ? "descomprimiendo…" : "ocupa menos"} icono={caja} />
        </Pop>
        <Pop desde={m("comprimir")} giro={6}>
          <Carril titulo="Sin comprimir" color={C.menta} progreso={rapido} estado={rapido >= 1 ? "¡listo!" : "ocupa más"} icono={archivos} />
        </Pop>
      </div>
      <S id="golpe" en={m("curioso")} volumen={0.3} />
      <S id="comprimir" en={m("comprimir")} volumen={0.35} />
      <S id="rapido" en={salida} volumen={0.35} />
      <S id="exito" en={salida + Math.round(fps * 0.5)} volumen={0.3} />
    </Escena>
  );
};

/* 6 · REMATE: espacio a cambio de velocidad */
export const Remate: React.FC = () => {
  const m = LINEA.marcas("remate");
  const s = useSeg();
  return (
    <Escena id="remate" etiqueta="EN RESUMEN" titulo="El trato" claves={["velocidad"]} golpes={[m("velocidad")]}>
      <div style={{ position: "relative", display: "flex", alignItems: "center", gap: 40 }}>
        <Pop desde={m("espacio")} giro={-10}>
          <Respira fase={0}>
            <div style={{ textAlign: "center", fontFamily: F.titulo, fontWeight: 800, fontSize: 72, color: C.cascabel, background: "rgba(2,8,20,0.75)", border: `3px solid ${C.cascabel}`, borderRadius: 30, padding: "18px 34px", lineHeight: 1 }}>
              + espacio
            </div>
          </Respira>
        </Pop>
        <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 90, color: C.hueso, transform: `rotate(${s * 90}deg)` }}>⇄</div>
        <Pop desde={m("velocidad")} giro={10}>
          <Respira fase={1.5}>
            <Brillo>
              <div style={{ textAlign: "center", fontFamily: F.titulo, fontWeight: 800, fontSize: 72, color: C.menta, background: "rgba(2,8,20,0.75)", border: `3px solid ${C.menta}`, borderRadius: 30, padding: "18px 34px", lineHeight: 1 }}>
                + velocidad
              </div>
            </Brillo>
          </Respira>
        </Pop>
        <Rafaga en={m("velocidad")} tamano={900} x={230} />
      </div>
      <S id="pop" en={m("espacio")} volumen={0.3} />
      <S id="exito" en={m("velocidad")} volumen={0.35} />
    </Escena>
  );
};

/* 7 · PREGUNTA + FIRMA */
export const Pregunta: React.FC = () => {
  const m = LINEA.marcas("pregunta");
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const libre = interpolate(frame, [m("cabe"), m("cabe") + fps * 0.8], [0.62, 0.12], CLAMP);
  const firma = m("comentarios") + Math.round(fps * 0.9);
  return (
    <Escena id="pregunta" etiqueta="¿Y TÚ?" titulo="¿Te cabe en la consola?" claves={["comentarios"]} golpes={[m("diecinueve")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 34 }}>
        <Pop desde={m("diecinueve")}>
          <Brillo color={C.cascabel}>
            <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 110, color: C.cascabel, background: "rgba(2,8,20,0.8)", border: `3px solid ${C.cascabel}88`, borderRadius: 26, padding: "0 36px" }}>19 · NOV</div>
          </Brillo>
        </Pop>
        <Pop desde={m("cabe")}>
          <div style={{ width: 760, display: "flex", flexDirection: "column", gap: 10 }}>
            <div style={{ display: "flex", justifyContent: "space-between", fontFamily: F.cifra, fontWeight: 700, fontSize: 30, color: C.niebla }}>
              <span>Espacio libre</span>
              <span style={{ color: libre < 0.2 ? "#ff8da1" : C.menta }}>{Math.round(libre * 825)} GB</span>
            </div>
            <div style={{ height: 40, borderRadius: 20, background: "#ffffff14", overflow: "hidden" }}>
              <div style={{ width: `${(1 - libre) * 100}%`, height: "100%", background: libre < 0.2 ? C.panuelo : C.pelaje }} />
            </div>
          </div>
        </Pop>
        <Pop desde={firma}>
          <div style={{ display: "flex", alignItems: "center", gap: 16, fontFamily: F.cifra, fontWeight: 700, fontSize: 40, color: C.hueso }}>
            <span style={{ width: 36, height: 36, borderRadius: 18, background: C.pelaje, border: `3px solid ${C.hueso}`, display: "inline-block" }} />
            @ithnoir · comenta 🐾
          </div>
        </Pop>
      </div>
      <S id="tic" en={m("diecinueve")} volumen={0.35} />
      <S id="descarga" en={m("cabe")} volumen={0.25} />
      <S id="cascabel" en={firma} volumen={0.5} />
    </Escena>
  );
};

