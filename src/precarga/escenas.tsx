import { AbsoluteFill, Html5Audio, interpolate, random, Sequence, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { Brillo, Contador, Pop, Rafaga, Respira, Subtitulos, useSeg } from "../marca/kit";
import { C, CLAMP, F } from "../marca/tema";
import { Escena, S } from "./comun";
import { CARPETA, LINEA, TIEMPOS } from "./linea";

const Chip: React.FC<{ texto: string; color?: string; tamano?: number; oscuro?: boolean }> = ({ texto, color = C.menta, tamano = 40, oscuro }) => (
  <div
    style={{
      display: "inline-block",
      fontFamily: F.cifra,
      fontWeight: 700,
      fontSize: tamano,
      color: oscuro ? color : C.abismo,
      background: oscuro ? "rgba(2,8,20,0.85)" : color,
      border: oscuro ? `3px solid ${color}` : undefined,
      padding: "6px 22px",
      borderRadius: 999,
      whiteSpace: "nowrap",
    }}
  >
    {texto}
  </div>
);

/** Candado vectorial: `abierto` 0-1 levanta el arco. */
const Candado: React.FC<{ tamano?: number; color?: string; abierto?: number }> = ({ tamano = 200, color = C.cascabel, abierto = 0 }) => (
  <svg width={tamano} height={tamano * 1.15} viewBox="0 0 200 230">
    <path d="M55 105 V70 a45 45 0 0 1 90 0 V105" transform={`translate(${abierto * 30} ${-abierto * 34})`} fill="none" stroke={color} strokeWidth={22} strokeLinecap="round" />
    <rect x={25} y={100} width={150} height={120} rx={22} fill={color} />
    <circle cx={100} cy={150} r={16} fill={C.abismo} />
    <rect x={93} y={155} width={14} height={34} rx={6} fill={C.abismo} />
  </svg>
);

const Llave: React.FC<{ tamano?: number; color?: string }> = ({ tamano = 180, color = C.cascabel }) => (
  <svg width={tamano} height={tamano * 0.5} viewBox="0 0 200 100">
    <circle cx={45} cy={50} r={34} fill="none" stroke={color} strokeWidth={16} />
    <rect x={76} y={42} width={116} height={16} rx={6} fill={color} />
    <rect x={150} y={56} width={14} height={26} rx={4} fill={color} />
    <rect x={174} y={56} width={14} height={20} rx={4} fill={color} />
  </svg>
);

/* 1 · GANCHO: descargado al 100 % y el botón de jugar bloqueado, desde el fotograma 0 */
export const Gancho: React.FC = () => {
  const m = LINEA.marcas("gancho");
  const frame = useCurrentFrame();
  const s = useSeg();
  const sacude = frame >= m("jugarlo") ? Math.sin(s * 60) * Math.max(0, 1 - (frame - m("jugarlo")) / 25) * 14 : 0;
  return (
    <Escena id="gancho" etiqueta="¿POR QUÉ…?" titulo="¿Por qué lo bajas y no lo juegas?" claves={["bajar", "jugarlo"]} golpes={[0, m("jugarlo")]} sinEntrada>
      <div
        style={{
          width: 820,
          background: "rgba(2,8,20,0.88)",
          border: `3px solid ${C.menta}55`,
          borderRadius: 36,
          padding: "34px 44px",
          display: "flex",
          flexDirection: "column",
          gap: 26,
          transform: "translateX(90px)",
        }}
      >
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
          <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 84, color: C.hueso, lineHeight: 1 }}>GTA VI</div>
          <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 40, color: C.menta }}>212 GB ✓</div>
        </div>
        <div style={{ height: 26, borderRadius: 13, background: "#ffffff1a", overflow: "hidden" }}>
          <div style={{ width: "100%", height: "100%", background: C.menta, boxShadow: `0 0 24px ${C.menta}` }} />
        </div>
        <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 30, color: C.niebla, letterSpacing: 2 }}>DESCARGA COMPLETADA · 100 %</div>
        <Brillo color={C.panuelo}>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: 24,
              height: 140,
              borderRadius: 28,
              background: "#3a1420",
              border: `4px solid ${C.panuelo}`,
              transform: `translateX(${sacude}px)`,
            }}
          >
            <Candado tamano={80} color="#ff8da1" />
            <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 72, color: "#ff8da1" }}>JUGAR</div>
          </div>
        </Brillo>
      </div>
      <S id="cascabel" en={0} volumen={0.45} />
      <S id="golpe" en={0} volumen={0.3} />
      <S id="error" en={m("jugarlo")} volumen={0.3} />
    </Escena>
  );
};

/* 2 · FECHAS: 10 de noviembre (precarga) → 19 de noviembre (jugar) y 212 GB */
export const Fechas: React.FC = () => {
  const m = LINEA.marcas("fechas");
  const frame = useCurrentFrame();
  const linea = interpolate(frame, [m("diez") + 10, m("diecinueve")], [0, 1], CLAMP);
  return (
    <Escena id="fechas" etiqueta="LA PRECARGA" titulo="Lo bajas 9 días antes" claves={["precargarlo", "diecinueve"]} golpes={[m("doscientos"), m("diecinueve")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 44, transform: "translateX(-20px)" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 22 }}>
          <Pop desde={m("diez")}>
            <Chip texto="10 NOV ⬇" color={C.menta} tamano={46} />
          </Pop>
          <div style={{ width: 200, height: 10, borderRadius: 5, background: "#ffffff22", overflow: "hidden" }}>
            <div style={{ width: `${linea * 100}%`, height: "100%", background: C.cascabel }} />
          </div>
          <Pop desde={m("diecinueve")}>
            <Chip texto="19 NOV 🎮" color={C.cascabel} tamano={46} />
          </Pop>
        </div>
        <Pop desde={m("playstation")}>
          <div style={{ display: "flex", gap: 24 }}>
            <Chip texto="PS5" color={C.azul} oscuro tamano={38} />
            <Chip texto="XBOX SERIES" color={C.menta} oscuro tamano={38} />
          </div>
        </Pop>
        <Pop desde={m("doscientos")}>
          <Brillo>
            <Contador hasta={212} inicio={m("doscientos")} dur={0.8} sufijo=" GB" tamano={130} />
          </Brillo>
        </Pop>
      </div>
      <S id="tic" en={m("diez")} volumen={0.3} />
      <S id="pop" en={m("playstation")} volumen={0.25} />
      <S id="subida" en={m("doscientos")} volumen={0.25} />
      <S id="golpe" en={m("diecinueve")} volumen={0.25} />
    </Escena>
  );
};

/* 3 · SERVIDORES: diez millones de descargas a la vez y el servidor revienta */
export const Servidores: React.FC = () => {
  const m = LINEA.marcas("servidores");
  const frame = useCurrentFrame();
  const s = useSeg();
  const { fps } = useVideoConfig();
  const gente = Math.min(60, Math.max(0, Math.floor((frame - m("imagina")) / (fps * 0.03))));
  const peligro = interpolate(frame, [m("mismo"), m("revientan")], [0, 1], CLAMP);
  const roto = frame >= m("revientan");
  const tiembla = (roto ? 12 : peligro * 5) * Math.sin(s * 70);
  const colorServ = roto ? C.panuelo : peligro > 0.5 ? C.cascabel : C.menta;
  return (
    <Escena id="servidores" etiqueta="RAZÓN 1" titulo="Los servidores no aguantarían" claves={["millones", "revientan"]} golpes={[m("millones"), m("revientan")]}>
      <div style={{ position: "relative", width: 1000, height: 620 }}>
        {/* Multitud de jugadores */}
        <div style={{ position: "absolute", left: 340, top: 20, width: 640, display: "flex", flexWrap: "wrap", gap: 10 }}>
          {new Array(gente).fill(0).map((_, k) => (
            <svg key={k} width={52} height={52} viewBox="0 0 52 52" style={{ transform: `translateY(${Math.sin(s * 6 + k) * 3}px)` }}>
              <circle cx={26} cy={16} r={11} fill={k % 3 ? C.pelaje : C.azul} />
              <rect x={10} y={30} width={32} height={20} rx={10} fill={k % 3 ? C.pelaje : C.azul} />
            </svg>
          ))}
        </div>
        <Pop desde={m("diez")} style={{ position: "absolute", left: 420, top: 340 }}>
          <Contador hasta={10000000} inicio={m("diez")} dur={0.9} color={C.hueso} tamano={70} />
        </Pop>
        <Pop desde={m("doscientos")} style={{ position: "absolute", left: 560, top: 450 }}>
          <Chip texto="× 212 GB cada uno" color={C.cascabel} tamano={38} />
        </Pop>
        {/* Servidor */}
        <Pop desde={m("por")} style={{ position: "absolute", left: 60, top: 60 }}>
          <div style={{ transform: `translateX(${tiembla}px)` }}>
            <Brillo color={colorServ}>
              <svg width={230} height={360} viewBox="0 0 230 360">
                <rect x={10} y={10} width={210} height={340} rx={22} fill="#0c1730" stroke={colorServ} strokeWidth={6} />
                {[0, 1, 2, 3].map((k) => (
                  <g key={k}>
                    <rect x={32} y={34 + k * 78} width={166} height={56} rx={10} fill="#16244a" />
                    <circle cx={60} cy={62 + k * 78} r={9} fill={colorServ} opacity={0.5 + 0.5 * Math.abs(Math.sin(s * (8 + k * 3)))} />
                    <rect x={84} y={56 + k * 78} width={90} height={10} rx={5} fill="#ffffff22" />
                  </g>
                ))}
              </svg>
            </Brillo>
          </div>
        </Pop>
        {roto ? (
          <>
            <Rafaga en={m("revientan")} color={C.panuelo} tamano={500} x={-325} y={-70} />
            <Pop desde={m("revientan")} style={{ position: "absolute", left: 40, top: 440 }} giro={-8}>
              <Chip texto="ERROR 503" color={C.panuelo} tamano={44} />
            </Pop>
          </>
        ) : null}
      </div>
      <S id="pop" en={m("imagina")} volumen={0.25} />
      <S id="subida" en={m("millones")} volumen={0.25} />
      <S id="latido" en={m("mismo")} volumen={0.3} />
      <S id="golpe" en={m("revientan")} volumen={0.35} />
      <S id="glitch" en={m("revientan")} volumen={0.25} />
    </Escena>
  );
};

/* 4 · CANDADO: los archivos llegan cifrados y la llave espera al día 19 */
export const Candados: React.FC = () => {
  const m = LINEA.marcas("candado");
  const s = useSeg();
  const frame = useCurrentFrame();
  const cifrado = frame >= m("cifrados");
  return (
    <Escena id="candado" etiqueta="RAZÓN 2" titulo="Te llega con candado" claves={["candado", "llave"]} golpes={[m("candado"), m("llave")]}>
      <div style={{ display: "flex", alignItems: "center", gap: 40, transform: "translateX(-30px)" }}>
        <div style={{ position: "relative", width: 420, height: 420 }}>
          {/* Archivos */}
          {new Array(6).fill(0).map((_, k) => {
            const col = k % 3;
            const fila = Math.floor(k / 3);
            return (
              <Pop key={k} desde={m("antes") + k * 4} style={{ position: "absolute", left: col * 135, top: fila * 165 }}>
                <svg width={120} height={150} viewBox="0 0 120 150">
                  <path d="M10 10 H80 L110 40 V140 H10 Z" fill="#0c2f3a" stroke={C.menta} strokeWidth={5} />
                  <path d="M80 10 V40 H110" fill="none" stroke={C.menta} strokeWidth={5} />
                  {[0, 1, 2].map((r) => (
                    <text key={r} x={22} y={74 + r * 24} fontFamily="JetBrains Mono" fontWeight={700} fontSize={18} fill={cifrado ? C.cascabel : C.menta}>
                      {cifrado ? "#%&@$!".slice(r, r + 4 + ((Math.floor(s * 12) + k) % 2)) : "data"}
                    </text>
                  ))}
                </svg>
              </Pop>
            );
          })}
          <Pop desde={m("candado")} style={{ position: "absolute", left: 120, top: 90 }}>
            <Respira amp={0.04}>
              <Brillo color={C.cascabel}>
                <Candado tamano={190} />
              </Brillo>
            </Respira>
          </Pop>
        </div>
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 26 }}>
          <Pop desde={m("cifrados")}>
            <Chip texto="CIFRADOS 🔒" color={C.cascabel} tamano={38} />
          </Pop>
          <Pop desde={m("llave")}>
            <Respira amp={0.05} fase={1}>
              <Llave tamano={170} color={C.niebla} />
            </Respira>
          </Pop>
          <Pop desde={m("lanzamiento")}>
            <Chip texto="llega el 19" color={C.niebla} oscuro tamano={34} />
          </Pop>
        </div>
      </div>
      <S id="clic" en={m("candado")} volumen={0.35} />
      <S id="golpe" en={m("candado")} volumen={0.2} />
      <S id="glitch" en={m("cifrados")} volumen={0.2} />
      <S id="brillo" en={m("llave")} volumen={0.25} />
    </Escena>
  );
};

/* 5 · LLAVE: sin filtraciones; a medianoche llega la llave y se abre */
export const LlaveLlega: React.FC = () => {
  const m = LINEA.marcas("llave");
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const segundo = Math.floor(interpolate(frame, [m("medianoche"), m("llave")], [55, 60], CLAMP));
  const reloj = segundo >= 60 ? "00:00:00" : `23:59:${segundo}`;
  const vuelo = interpolate(frame, [m("llave"), m("llave") + fps * 0.5], [0, 1], { ...CLAMP, easing: (x) => 1 - Math.pow(1 - x, 3) });
  const abierto = interpolate(frame, [m("llave") + fps * 0.5, m("llave") + fps * 0.75], [0, 1], CLAMP);
  return (
    <Escena id="llave" etiqueta="ASÍ FUNCIONA" titulo="Nadie lo abre antes" claves={["filtra", "medianoche", "jugando"]} golpes={[m("medianoche"), m("jugando")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 30 }}>
        <Pop desde={m("filtra")}>
          <div style={{ position: "relative" }}>
            <Chip texto="SPOILERS DEL FINAL" color={C.niebla} oscuro tamano={38} />
            <div style={{ position: "absolute", left: -10, right: -10, top: "50%", height: 8, background: C.panuelo, transform: "rotate(-6deg)", borderRadius: 4 }} />
          </div>
        </Pop>
        <Pop desde={m("medianoche")}>
          <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 100, color: frame >= m("llave") ? C.menta : C.hueso, background: "rgba(2,8,20,0.85)", borderRadius: 24, padding: "0 30px", fontVariantNumeric: "tabular-nums" }}>
            {reloj}
          </div>
        </Pop>
        <div style={{ position: "relative", width: 520, height: 250 }}>
          <div style={{ position: "absolute", left: 160, top: 0 }}>
            <Brillo color={abierto >= 1 ? C.menta : C.cascabel}>
              <Candado tamano={190} color={abierto >= 1 ? C.menta : C.cascabel} abierto={abierto} />
            </Brillo>
          </div>
          {frame >= m("llave") ? (
            <div style={{ position: "absolute", left: interpolate(vuelo, [0, 1], [520, 210]), top: 140 - Math.sin(vuelo * Math.PI) * 120, transform: `rotate(${(1 - vuelo) * -40}deg)` }}>
              <Llave tamano={130} />
            </div>
          ) : null}
          {abierto >= 1 ? <Rafaga en={m("llave") + Math.round(fps * 0.75)} color={C.menta} tamano={520} x={0} y={-10} /> : null}
        </div>
        <Pop desde={m("jugando")}>
          <Brillo>
            <Chip texto="¡A JUGAR!" color={C.menta} tamano={60} />
          </Brillo>
        </Pop>
      </div>
      <S id="tic" en={m("medianoche")} volumen={0.3} />
      <S id="whoosh" en={m("llave")} volumen={0.25} />
      <S id="clic" en={m("llave") + Math.round(fps * 0.5)} volumen={0.4} />
      <S id="exito" en={m("jugando")} volumen={0.3} />
    </Escena>
  );
};

/* 6 · REMATE: todas las pantallas arrancan a la vez */
export const Remate: React.FC = () => {
  const m = LINEA.marcas("remate");
  const frame = useCurrentFrame();
  const s = useSeg();
  const encendidas = frame >= m("vez");
  return (
    <Escena id="remate" etiqueta="EN RESUMEN" titulo="Todos empiezan a la vez" claves={["todos", "vez"]} golpes={[m("vez")]}>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 170px)", gap: 22, transform: "translateX(120px)" }}>
        {new Array(12).fill(0).map((_, k) => (
          <Pop key={k} desde={m("todos") - 20 + k * 2}>
            <div
              style={{
                width: 170,
                height: 110,
                borderRadius: 16,
                background: encendidas ? "#0c2f3a" : "#0b0f1f",
                border: `4px solid ${encendidas ? C.menta : "#2b3350"}`,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontFamily: F.cifra,
                fontWeight: 700,
                fontSize: 30,
                color: C.menta,
                boxShadow: encendidas ? `0 0 ${18 + 8 * Math.sin(s * 6 + k)}px ${C.menta}88` : undefined,
              }}
            >
              {encendidas ? "START" : "· · ·"}
            </div>
          </Pop>
        ))}
      </div>
      {encendidas ? <Rafaga en={m("vez")} color={C.menta} tamano={800} x={120} /> : null}
      <S id="tic" en={m("todos")} volumen={0.25} />
      <S id="exito" en={m("vez")} volumen={0.3} />
    </Escena>
  );
};

/* 7 · PREGUNTA: precargar el primer día o esperar reseñas */
export const Pregunta: React.FC = () => {
  const m = LINEA.marcas("pregunta");
  const { fps } = useVideoConfig();
  const firma = m("leo") + Math.round(fps * 0.5);
  return (
    <Escena id="pregunta" etiqueta="¿Y TÚ?" titulo="¿Precargas o esperas?" claves={["precargas", "resenas"]} golpes={[m("precargas"), m("resenas")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 44, transform: "translateX(-50px)" }}>
        <div style={{ display: "flex", gap: 34 }}>
          {[
            { t: "PRECARGO YA", i: "⬇️", c: C.menta, w: "precargas" },
            { t: "ESPERO RESEÑAS", i: "⭐", c: C.cascabel, w: "resenas" },
          ].map((b, k) => (
            <Pop key={b.t} desde={m(b.w)} giro={k ? 8 : -8}>
              <Respira fase={k * 1.5} amp={0.05}>
                <div
                  style={{
                    width: 300,
                    height: 220,
                    borderRadius: 40,
                    background: b.c,
                    display: "flex",
                    flexDirection: "column",
                    alignItems: "center",
                    justifyContent: "center",
                    gap: 8,
                    fontFamily: F.titulo,
                    fontWeight: 800,
                    fontSize: 48,
                    lineHeight: 1,
                    textAlign: "center",
                    color: C.abismo,
                  }}
                >
                  <span style={{ fontSize: 70 }}>{b.i}</span>
                  {b.t}
                </div>
              </Respira>
            </Pop>
          ))}
        </div>
        <Pop desde={firma}>
          <div style={{ display: "flex", alignItems: "center", gap: 16, fontFamily: F.cifra, fontWeight: 700, fontSize: 40, color: C.hueso }}>
            <span style={{ width: 36, height: 36, borderRadius: 18, background: C.pelaje, border: `3px solid ${C.hueso}`, display: "inline-block" }} />
            @ithnoir · comenta 🐾
          </div>
        </Pop>
      </div>
      <S id="pop" en={m("precargas")} volumen={0.3} />
      <S id="pop" en={m("resenas")} volumen={0.3} />
      <S id="cascabel" en={firma} volumen={0.45} />
    </Escena>
  );
};

/* 8 · FINAL: solo el cuarto, la voz y los subtítulos. Lo raro pasa detrás (ver Precarga.tsx). */
export const Final: React.FC = () => {
  const pre = LINEA.preDe("final");
  const m = LINEA.marcas("final");
  return (
    <AbsoluteFill>
      <Subtitulos palabras={TIEMPOS.voz.final.palabras} pre={pre} claves={["backrooms"]} />
      <Sequence from={pre} layout="none">
        <Html5Audio src={staticFile(`${CARPETA}/voz-final.mp3`)} volume={1} />
      </Sequence>
      <S id="parpadeo" en={m("backrooms")} volumen={0.35} />
      <S id="zumbido" en={m("backrooms")} volumen={0.25} dur={4} />
      <S id="latido" en={m("verdad")} volumen={0.4} />
    </AbsoluteFill>
  );
};

/** Ruido de cinta para el corte final. */
export const Estatica: React.FC<{ fuerza: number }> = ({ fuerza }) => {
  const frame = useCurrentFrame();
  if (fuerza <= 0) return null;
  return (
    <AbsoluteFill style={{ opacity: fuerza }}>
      {new Array(40).fill(0).map((_, k) => (
        <div
          key={k}
          style={{
            position: "absolute",
            left: 0,
            right: 0,
            top: random(`e${frame}-${k}`) * 1920,
            height: 4 + random(`h${frame}-${k}`) * 40,
            background: random(`c${frame}-${k}`) > 0.5 ? "#f1f5ff" : "#1b1b1b",
            opacity: 0.5 + random(`o${frame}-${k}`) * 0.5,
          }}
        />
      ))}
    </AbsoluteFill>
  );
};
