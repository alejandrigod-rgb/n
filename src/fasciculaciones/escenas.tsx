import { interpolate, useCurrentFrame, useVideoConfig } from "remotion";
import { Brillo, Contador, Pop, Rafaga, Respira, useSeg } from "../marca/kit";
import { C, CLAMP, F } from "../marca/tema";
import { Escena, S } from "./comun";
import { LINEA } from "./linea";

const Chip: React.FC<{ texto: string; color?: string; tamano?: number }> = ({ texto, color = C.menta, tamano = 40 }) => (
  <div
    style={{
      display: "inline-block",
      fontFamily: F.cifra,
      fontWeight: 700,
      fontSize: tamano,
      color: C.abismo,
      background: color,
      padding: "6px 22px",
      borderRadius: 999,
      whiteSpace: "nowrap",
    }}
  >
    {texto}
  </div>
);

/** Temblor a ráfagas, como un párpado que tiembla: vibra rápido unos instantes y se calma. */
const temblor = (s: number) => {
  const rafaga = s % 1.1 < 0.6 ? 1 : 0;
  return rafaga * Math.sin(s * 70) * (0.6 + 0.4 * Math.sin(s * 13));
};

/* 1 · GANCHO: un ojo con el párpado temblando desde el fotograma 0 */
export const Gancho: React.FC = () => {
  const m = LINEA.marcas("gancho");
  const s = useSeg();
  const t = temblor(s);
  return (
    <Escena
      id="gancho"
      etiqueta="¿POR QUÉ…?"
      titulo="¿Te tiembla el párpado solo?"
      claves={["fasciculacion", "normal"]}
      golpes={[0, m("fasciculacion")]}
      sinEntrada
    >
      <div style={{ position: "relative", display: "flex", flexDirection: "column", alignItems: "center", gap: 30 }}>
        <Brillo color={C.menta} fuerza={0.7}>
          <svg width={720} height={380} viewBox="-360 -190 720 380">
            {/* líneas de vibración */}
            {[-1, 1].map((lado) =>
              [0, 1, 2].map((k) => (
                <path
                  key={`${lado}-${k}`}
                  d={`M${lado * (300 + k * 18)} ${40 - k * 6} q${lado * 12} 16 0 32`}
                  stroke={C.menta}
                  strokeWidth={6}
                  fill="none"
                  strokeLinecap="round"
                  opacity={Math.abs(t) > 0.2 ? 0.9 : 0.15}
                />
              )),
            )}
            <defs>
              <clipPath id="zona-ojo">
                <ellipse rx={335} ry={165} />
              </clipPath>
            </defs>
            <ellipse rx={335} ry={165} fill="#54418e" stroke="#1d1530" strokeWidth={8} />
            <g clipPath="url(#zona-ojo)">
              <path d="M-290 0 Q0 -200 290 0 Q0 200 -290 0 Z" fill="#f1f5ff" stroke="#1d1530" strokeWidth={10} />
              <circle r={92} fill="#1b2f7a" />
              <circle r={44} fill="#0b1440" />
              <circle cx={-28} cy={-30} r={18} fill="#fff" opacity={0.9} />
              {/* párpado superior */}
              <path d="M-300 0 Q0 -210 300 0 L300 -200 L-300 -200 Z" fill="#54418e" transform="translate(0 -46)" />
              <path d="M-300 -46 Q0 -256 300 -46" stroke="#1d1530" strokeWidth={10} fill="none" />
              {/* párpado inferior que tiembla */}
              <g transform={`translate(0 ${-10 * Math.abs(t)})`}>
                <path d="M-300 0 Q0 210 300 0 L300 200 L-300 200 Z" fill="#54418e" transform="translate(0 52)" />
                <path d="M-290 52 Q0 254 290 52" stroke="#1d1530" strokeWidth={10} fill="none" />
              </g>
            </g>
            <ellipse rx={335} ry={165} fill="none" stroke="#1d1530" strokeWidth={8} />
          </svg>
        </Brillo>
        <Pop desde={m("fasciculacion") - 6}>
          <Chip texto="FASCICULACIÓN" color={C.cascabel} tamano={50} />
        </Pop>
        <div style={{ position: "absolute", bottom: -70 }}>
          <Pop desde={m("normal")}>
            <Chip texto="✓ casi siempre normal" />
          </Pop>
        </div>
      </div>
      <S id="cascabel" en={0} volumen={0.45} />
      <S id="golpe" en={0} volumen={0.3} />
      <S id="tic" en={2} volumen={0.4} />
      <S id="pop" en={m("fasciculacion") - 6} volumen={0.3} />
      <S id="exito" en={m("normal")} volumen={0.25} />
    </Escena>
  );
};

/* 2 · QUÉ ES: chispa que viaja por el nervio y fibras que se contraen */
export const Que: React.FC = () => {
  const m = LINEA.marcas("que");
  const frame = useCurrentFrame();
  const s = useSeg();
  const viaje = interpolate(frame, [m("senal"), m("suelta") + 8], [0, 1], CLAMP);
  const contrae = frame >= m("contraen") && frame < m("permiso") + 30;
  const FIBRAS = 7;
  const activas = [1, 3, 4];
  return (
    <Escena id="que" etiqueta="QUÉ ES" titulo="Una señal suelta" claves={["senal", "contraen"]} golpes={[m("contraen")]}>
      <div style={{ position: "relative", width: 980, height: 600 }}>
        <svg width={980} height={600} viewBox="0 0 980 600" style={{ position: "absolute" }}>
          {/* nervio */}
          <path id="nervio" d="M60 80 C260 80 300 230 470 260" stroke={C.azul} strokeWidth={14} fill="none" strokeLinecap="round" />
          <path
            d="M60 80 C260 80 300 230 470 260"
            stroke="#ffffff"
            strokeOpacity={0.35}
            strokeWidth={4}
            fill="none"
            strokeLinecap="round"
          />
          {viaje > 0 && viaje < 1
            ? (() => {
                // punto sobre la curva cúbica
                const u = viaje;
                const bx = (1 - u) ** 3 * 60 + 3 * (1 - u) ** 2 * u * 260 + 3 * (1 - u) * u * u * 300 + u ** 3 * 470;
                const by = (1 - u) ** 3 * 80 + 3 * (1 - u) ** 2 * u * 80 + 3 * (1 - u) * u * u * 230 + u ** 3 * 260;
                return (
                  <g>
                    <circle cx={bx} cy={by} r={34} fill={C.menta} opacity={0.25} />
                    <circle cx={bx} cy={by} r={16} fill={C.menta} />
                  </g>
                );
              })()
            : null}
          {/* músculo: haz de fibras */}
          <g transform="translate(470 180)">
            <rect x={-10} y={-10} width={460} height={FIBRAS * 46 + 10} rx={60} fill="#3a1830" stroke="#1d1530" strokeWidth={8} />
            {new Array(FIBRAS).fill(0).map((_, k) => {
              const activa = contrae && activas.includes(k);
              const sacudida = activa ? Math.sin(s * 60 + k) * 6 : 0;
              return (
                <g key={k} transform={`translate(${220 + sacudida} ${20 + k * 46}) scale(${activa ? 0.9 : 1} 1)`}>
                  <rect x={-205} y={0} width={410} height={34} rx={17} fill={activa ? C.menta : "#c2334d"} />
                  <rect x={-190} y={6} width={380} height={6} rx={3} fill="#ffffff" opacity={activa ? 0.5 : 0.18} />
                </g>
              );
            })}
          </g>
        </svg>
        <div style={{ position: "absolute", left: 40, top: 120 }}>
          <Pop desde={m("nervio")}>
            <Chip texto="nervio" color={C.azul} tamano={34} />
          </Pop>
        </div>
        <div style={{ position: "absolute", right: 60, top: 540 }}>
          <Pop desde={m("musculo")}>
            <Chip texto="músculo" color="#ff8da1" tamano={34} />
          </Pop>
        </div>
      </div>
      <S id="chispa" en={m("senal")} volumen={0.35} />
      <S id="tic" en={m("contraen")} volumen={0.45} />
      <S id="tic" en={m("contraen") + 9} volumen={0.35} />
    </Escena>
  );
};

/* 3 · CAUSAS: estrés, café, dormir poco y ejercicio */
const IconoCausa: React.FC<{ tipo: string }> = ({ tipo }) => {
  const s = useSeg();
  if (tipo === "estres")
    return (
      <svg width={150} height={150} viewBox="0 0 100 100">
        <path
          d="M25 58 C10 58 10 38 25 38 C25 20 50 16 56 30 C64 22 82 28 80 42 C92 44 92 58 80 58 Z"
          fill="#8a96a8"
          stroke="#1d1530"
          strokeWidth={4}
        />
        <polygon points="52,58 42,78 50,78 44,96 62,72 54,72 60,58" fill={C.cascabel} opacity={0.6 + 0.4 * Math.abs(Math.sin(s * 8))} />
      </svg>
    );
  if (tipo === "cafe")
    return (
      <svg width={150} height={150} viewBox="0 0 100 100">
        {[0, 1, 2].map((k) => (
          <path
            key={k}
            d={`M${36 + k * 12} 30 q-6 -8 0 -16`}
            stroke="#ffffff88"
            strokeWidth={4}
            fill="none"
            strokeLinecap="round"
            transform={`translate(0 ${-((s * 20 + k * 5) % 8)})`}
          />
        ))}
        <path d="M24 38 H76 L70 86 C69 92 64 94 58 94 H42 C36 94 31 92 30 86 Z" fill="#f1f5ff" stroke="#1d1530" strokeWidth={4} />
        <rect x={27} y={42} width={46} height={8} fill="#6b3e1d" />
        <path d="M76 48 C92 48 92 72 72 72" stroke="#1d1530" strokeWidth={6} fill="none" />
      </svg>
    );
  if (tipo === "dormir")
    return (
      <svg width={150} height={150} viewBox="0 0 100 100">
        <path d="M62 14 A36 36 0 1 0 86 70 A28 28 0 1 1 62 14 Z" fill={C.cascabel} stroke="#1d1530" strokeWidth={4} />
        <rect x={10} y={70} width={44} height={20} rx={5} fill="none" stroke={C.panuelo} strokeWidth={4} />
        <rect x={14} y={74} width={10} height={12} fill={C.panuelo} />
        <rect x={54} y={76} width={5} height={8} fill={C.panuelo} />
      </svg>
    );
  return (
    <svg width={150} height={150} viewBox="0 0 100 100">
      <g transform={`rotate(${Math.sin(s * 4) * 10} 50 50)`}>
        <rect x={24} y={46} width={52} height={8} rx={4} fill="#9aabc9" stroke="#1d1530" strokeWidth={3} />
        <rect x={12} y={30} width={14} height={40} rx={5} fill={C.pelaje} stroke="#1d1530" strokeWidth={4} />
        <rect x={74} y={30} width={14} height={40} rx={5} fill={C.pelaje} stroke="#1d1530" strokeWidth={4} />
      </g>
    </svg>
  );
};

const CAUSAS = [
  { tipo: "estres", texto: "Estrés", palabra: "estres", sfx: "golpe" },
  { tipo: "cafe", texto: "Mucho café", palabra: "cafe", sfx: "cafe" },
  { tipo: "dormir", texto: "Dormir poco", palabra: "dormir", sfx: "ronquido" },
  { tipo: "ejercicio", texto: "Mucho ejercicio", palabra: "pasarte", sfx: "pop" },
];

export const Causas: React.FC = () => {
  const m = LINEA.marcas("causas");
  return (
    <Escena id="causas" etiqueta="LAS CAUSAS" titulo="Los culpables típicos" claves={["estres", "cafe"]} golpes={[m("estres")]}>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(2, 440px)", gap: 30 }}>
        {CAUSAS.map((c, k) => (
          <Pop key={c.tipo} desde={m(c.palabra)} giro={k % 2 ? 8 : -8}>
            <Respira fase={k} amp={0.02}>
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 18,
                  background: "rgba(2,8,20,0.75)",
                  border: `3px solid ${C.menta}55`,
                  borderRadius: 28,
                  padding: "16px 22px",
                }}
              >
                <IconoCausa tipo={c.tipo} />
                <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 46, color: C.hueso, lineHeight: 1 }}>{c.texto}</div>
              </div>
            </Respira>
          </Pop>
        ))}
      </div>
      {CAUSAS.map((c) => (
        <S key={c.tipo} id={c.sfx} en={m(c.palabra)} volumen={c.sfx === "golpe" ? 0.25 : 0.35} />
      ))}
    </Escena>
  );
};

/* 4 · SUEÑO: la cama cae al vacío y da una sacudida; 7 de cada 10 personas */
export const Sueno: React.FC = () => {
  const m = LINEA.marcas("sueno");
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const s = useSeg();
  const cae = interpolate(frame, [m("cayeras"), m("vacio") + 10], [0, 1], { ...CLAMP, easing: (x) => x * x });
  const sacude = frame >= m("sacudida") && frame < m("sacudida") + fps * 0.4 ? Math.sin(s * 80) * 18 : 0;
  const vuelve = interpolate(frame, [m("sacudida"), m("sacudida") + 8], [1, 0], CLAMP);
  const caida = frame < m("sacudida") ? cae : cae * vuelve;
  const personas = frame >= m("hasta");
  return (
    <Escena
      id="sueno"
      etiqueta="AL DORMIR"
      titulo="El salto al dormirte"
      claves={["vacio", "hipnica"]}
      golpes={[m("sacudida"), m("siete")]}
    >
      <div style={{ position: "relative", width: 1000, height: 600, display: "flex", flexDirection: "column", alignItems: "center" }}>
        {!personas ? (
          <div style={{ position: "relative", width: 1000, height: 520 }}>
            {/* líneas de velocidad */}
            {caida > 0.05
              ? new Array(8)
                  .fill(0)
                  .map((_, k) => (
                    <div
                      key={k}
                      style={{
                        position: "absolute",
                        left: 140 + k * 100,
                        top: 40 + ((s * 900 + k * 70) % 420),
                        width: 6,
                        height: 80,
                        borderRadius: 3,
                        background: C.menta,
                        opacity: 0.4 * caida,
                      }}
                    />
                  ))
              : null}
            <div
              style={{
                position: "absolute",
                left: 250,
                top: 160 + caida * 140,
                transform: `translateX(${sacude}px) rotate(${caida * -6 + sacude * 0.3}deg)`,
              }}
            >
              <svg width={500} height={240} viewBox="0 0 500 240">
                <rect x={10} y={120} width={480} height={50} rx={12} fill="#2a2060" stroke="#1d1530" strokeWidth={6} />
                <rect x={20} y={60} width={110} height={60} rx={24} fill="#f1f5ff" stroke="#1d1530" strokeWidth={5} />
                <path d="M120 80 H470 Q490 80 490 100 V120 H120 Z" fill={C.pelaje} stroke="#1d1530" strokeWidth={5} />
                <rect x={20} y={170} width={16} height={60} fill="#1d1530" />
                <rect x={464} y={170} width={16} height={60} fill="#1d1530" />
              </svg>
            </div>
            <div
              style={{
                position: "absolute",
                left: 620,
                top: 90,
                fontFamily: F.titulo,
                fontWeight: 800,
                fontSize: 60,
                color: C.niebla,
                opacity: frame < m("cayeras") ? 0.8 : 0,
              }}
            >
              z z z
            </div>
            {frame >= m("sacudida") ? (
              <div style={{ position: "absolute", left: 640, top: 40 }}>
                <Pop desde={m("sacudida")} giro={-20}>
                  <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 110, color: C.cascabel, transform: "rotate(-8deg)" }}>
                    ¡ZAS!
                  </div>
                </Pop>
              </div>
            ) : null}
            <Rafaga en={m("sacudida")} color={C.cascabel} tamano={700} />
            <div style={{ position: "absolute", left: 0, right: 0, bottom: 0, display: "flex", justifyContent: "center" }}>
              <Pop desde={m("sacudida")}>
                <Chip texto="SACUDIDA HÍPNICA" color={C.menta} tamano={46} />
              </Pop>
            </div>
          </div>
        ) : (
          <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 30, marginTop: 30 }}>
            <div style={{ display: "flex", gap: 18 }}>
              {new Array(10).fill(0).map((_, k) => {
                const on = k < 7 && frame >= m("siete") + k * Math.round(fps * 0.05);
                return (
                  <Pop key={k} desde={m("hasta") + k * 2}>
                    <svg width={78} height={130} viewBox="0 0 78 130">
                      <circle cx={39} cy={26} r={22} fill={on ? C.menta : "#2b3350"} />
                      <path d="M4 128 C4 64 74 64 74 128 Z" fill={on ? C.menta : "#2b3350"} />
                    </svg>
                  </Pop>
                );
              })}
            </div>
            <Brillo>
              <div
                style={{
                  fontFamily: F.cifra,
                  fontWeight: 700,
                  fontSize: 96,
                  color: C.menta,
                  background: "rgba(2,8,20,0.8)",
                  border: `2px solid ${C.menta}55`,
                  borderRadius: 24,
                  padding: "0 30px",
                }}
              >
                <Contador hasta={7} inicio={m("siete")} dur={0.5} tamano={96} />
                <span> de 10</span>
              </div>
            </Brillo>
          </div>
        )}
      </div>
      <S id="ronquido" en={0} volumen={0.3} />
      <S id="caida" en={m("cayeras")} volumen={0.4} />
      <S id="sacudida" en={m("sacudida")} volumen={0.5} />
      <S id="pop" en={m("siete")} volumen={0.3} />
    </Escena>
  );
};

/* 5 · TEORÍA: el cerebro cree que te caes y tensa todo */
export const Teoria: React.FC = () => {
  const m = LINEA.marcas("teoria");
  const frame = useCurrentFrame();
  const s = useSeg();
  const relaja = interpolate(frame, [m("relajarte"), m("golpe") + 12], [1, 0.15], CLAMP);
  const alarma = frame >= m("caes");
  const tensa = frame >= m("tensa");
  return (
    <Escena id="teoria" etiqueta="UNA TEORÍA" titulo="El cerebro se confunde" claves={["caes", "tensa"]} golpes={[m("caes"), m("tensa")]}>
      <div
        style={{ position: "relative", width: 1000, height: 600, display: "flex", alignItems: "center", justifyContent: "center", gap: 70 }}
      >
        <Pop desde={m("relajarte") - 6}>
          <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 12 }}>
            <div
              style={{
                width: 70,
                height: 360,
                borderRadius: 35,
                background: "#ffffff14",
                border: `3px solid ${C.menta}55`,
                display: "flex",
                alignItems: "flex-end",
                overflow: "hidden",
              }}
            >
              <div style={{ width: "100%", height: `${(tensa ? 1 : relaja) * 100}%`, background: tensa ? C.panuelo : C.menta }} />
            </div>
            <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 28, color: C.niebla, textAlign: "center" }}>
              tensión
              <br />
              muscular
            </div>
          </div>
        </Pop>
        <div style={{ position: "relative" }}>
          <Respira amp={tensa ? 0.05 : 0.02}>
            <Brillo color={alarma ? C.panuelo : "#d58ab8"}>
              <svg
                width={420}
                height={340}
                viewBox="0 0 120 100"
                style={{ transform: `translateX(${tensa ? Math.sin(s * 60) * 4 : 0}px)` }}
              >
                <path
                  d="M30 20 C15 22 10 40 18 50 C8 60 16 80 34 78 C40 92 62 92 68 82 C84 92 104 80 100 64 C112 54 106 34 92 32 C90 16 72 10 60 18 C52 8 36 10 30 20 Z"
                  fill={alarma ? "#e04563" : "#d58ab8"}
                  stroke="#1d1530"
                  strokeWidth={3}
                />
                <path
                  d="M60 20 C56 40 64 60 60 82 M34 40 C42 44 48 40 54 46 M72 38 C80 44 88 40 94 48 M30 62 C40 58 46 66 54 62 M70 64 C78 58 86 66 96 62"
                  stroke="#1d1530"
                  strokeWidth={2.5}
                  fill="none"
                  strokeLinecap="round"
                  opacity={0.6}
                />
              </svg>
            </Brillo>
          </Respira>
          {alarma ? (
            <div style={{ position: "absolute", top: -60, left: 60 }}>
              <Pop desde={m("caes")} giro={-12}>
                <div
                  style={{
                    fontFamily: F.titulo,
                    fontWeight: 800,
                    fontSize: 64,
                    color: C.hueso,
                    background: C.panuelo,
                    borderRadius: 26,
                    padding: "4px 28px",
                    transform: "rotate(-5deg)",
                  }}
                >
                  ¡Me caigo!
                </div>
              </Pop>
            </div>
          ) : null}
          {tensa
            ? new Array(8).fill(0).map((_, k) => {
                const a = (k / 8) * Math.PI * 2;
                const r = 230 + 20 * Math.sin(s * 12 + k);
                return (
                  <svg
                    key={k}
                    width={60}
                    height={60}
                    viewBox="0 0 100 100"
                    style={{ position: "absolute", left: 210 + Math.cos(a) * r - 30, top: 170 + Math.sin(a) * r * 0.8 - 30 }}
                  >
                    <polygon points="58,6 22,56 46,56 38,94 78,40 54,40 66,6" fill={C.cascabel} />
                  </svg>
                );
              })
            : null}
        </div>
      </div>
      <S id="alerta" en={m("caes")} volumen={0.35} />
      <S id="golpe" en={m("tensa")} volumen={0.3} />
    </Escena>
  );
};

/* 6 · REMATE: normalmente inofensivas, pero ojo con las señales */
export const Remate: React.FC = () => {
  const m = LINEA.marcas("remate");
  return (
    <Escena
      id="remate"
      etiqueta="EN RESUMEN"
      titulo="¿Hay que preocuparse?"
      claves={["inofensivas", "medico"]}
      golpes={[m("inofensivas"), m("medico")]}
    >
      <div style={{ display: "flex", flexDirection: "column", gap: 34, alignItems: "center" }}>
        <Pop desde={m("inofensivas")} giro={-6}>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 26,
              width: 900,
              background: "rgba(2,8,20,0.75)",
              border: `4px solid ${C.menta}`,
              borderRadius: 30,
              padding: "22px 30px",
            }}
          >
            <div
              style={{
                width: 100,
                height: 100,
                borderRadius: 50,
                background: C.menta,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontFamily: F.titulo,
                fontWeight: 800,
                fontSize: 70,
                color: C.abismo,
              }}
            >
              ✓
            </div>
            <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 54, color: C.hueso, lineHeight: 1.05 }}>
              Suelen ser inofensivas
            </div>
          </div>
        </Pop>
        <Pop desde={m("debilidad")} giro={6}>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 26,
              width: 900,
              background: "rgba(2,8,20,0.75)",
              border: `4px solid ${C.panuelo}`,
              borderRadius: 30,
              padding: "22px 30px",
            }}
          >
            <svg width={100} height={100} viewBox="0 0 100 100">
              <circle cx={50} cy={50} r={48} fill={C.panuelo} />
              <rect x={40} y={20} width={20} height={60} rx={4} fill="#fff" />
              <rect x={20} y={40} width={60} height={20} rx={4} fill="#fff" />
            </svg>
            <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 46, color: C.hueso, lineHeight: 1.1 }}>
              ¿Con debilidad o no se van?
              <br />
              <span style={{ color: "#ff8da1" }}>Consulta a un médico</span>
            </div>
          </div>
        </Pop>
      </div>
      <S id="exito" en={m("inofensivas")} volumen={0.3} />
      <S id="alerta" en={m("debilidad")} volumen={0.25} />
    </Escena>
  );
};

/* 7 · PREGUNTA + FIRMA */
export const Pregunta: React.FC = () => {
  const m = LINEA.marcas("pregunta");
  const { fps } = useVideoConfig();
  const firma = m("leo") + Math.round(fps * 0.9);
  return (
    <Escena id="pregunta" etiqueta="¿Y TÚ?" titulo="¿Te ha pasado el salto al dormir?" claves={["si", "no"]} golpes={[m("si")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 50 }}>
        <div style={{ display: "flex", gap: 60 }}>
          {[
            { t: "SÍ", c: C.menta, w: "si" },
            { t: "NO", c: C.panuelo, w: "no" },
          ].map((b, k) => (
            <Pop key={b.t} desde={m(b.w)} giro={k ? 10 : -10}>
              <Respira fase={k * 1.5} amp={0.05}>
                <Brillo color={b.c}>
                  <div
                    style={{
                      width: 280,
                      height: 200,
                      borderRadius: 40,
                      background: b.c,
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      fontFamily: F.titulo,
                      fontWeight: 800,
                      fontSize: 120,
                      color: k ? C.hueso : C.abismo,
                    }}
                  >
                    {b.t}
                  </div>
                </Brillo>
              </Respira>
            </Pop>
          ))}
        </div>
        <Pop desde={firma}>
          <div
            style={{ display: "flex", alignItems: "center", gap: 16, fontFamily: F.cifra, fontWeight: 700, fontSize: 40, color: C.hueso }}
          >
            <span
              style={{
                width: 36,
                height: 36,
                borderRadius: 18,
                background: C.pelaje,
                border: `3px solid ${C.hueso}`,
                display: "inline-block",
              }}
            />
            @ithnoir · comenta 🐾
          </div>
        </Pop>
      </div>
      <S id="pop" en={m("si")} volumen={0.3} />
      <S id="pop" en={m("no")} volumen={0.3} />
      <S id="cascabel" en={firma} volumen={0.5} />
    </Escena>
  );
};
