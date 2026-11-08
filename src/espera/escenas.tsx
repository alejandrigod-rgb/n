import { interpolate, random, useCurrentFrame, useVideoConfig } from "remotion";
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

/* 1 · GANCHO: "13 AÑOS" desde el fotograma 0 y el calendario que corre */
export const Gancho: React.FC = () => {
  const m = LINEA.marcas("gancho");
  const frame = useCurrentFrame();
  const anio = Math.round(interpolate(frame, [m("gta"), m("ahora")], [2013, 2026], CLAMP));
  const linea = interpolate(frame, [m("gta"), m("ahora")], [0, 1], CLAMP);
  return (
    <Escena
      id="gancho"
      etiqueta="¿POR QUÉ…?"
      titulo="¿Por qué GTA VI tardó tanto?"
      claves={["trece", "tanto"]}
      golpes={[0, m("tanto")]}
      sinEntrada
    >
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 34 }}>
        <Brillo color={C.panuelo}>
          <div
            style={{
              fontFamily: F.cifra,
              fontWeight: 700,
              fontSize: 150,
              color: "#ff8da1",
              background: "rgba(2,8,20,0.85)",
              border: `3px solid ${C.panuelo}`,
              borderRadius: 30,
              padding: "0 40px",
              lineHeight: 1.15,
            }}
          >
            13 AÑOS
          </div>
        </Brillo>
        <Pop desde={m("gta")}>
          <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 18 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 24 }}>
              <Chip texto="GTA V · 2013" color={C.niebla} />
              <div style={{ width: 220, height: 10, borderRadius: 5, background: "#ffffff22", overflow: "hidden" }}>
                <div style={{ width: `${linea * 100}%`, height: "100%", background: C.menta }} />
              </div>
              <Chip texto="GTA VI · 2026" color={linea >= 1 ? C.menta : "#2b3350"} />
            </div>
            <div style={{ fontFamily: F.cifra, fontWeight: 700, fontSize: 90, color: C.hueso, fontVariantNumeric: "tabular-nums" }}>
              {anio}
            </div>
          </div>
        </Pop>
      </div>
      <S id="cascabel" en={0} volumen={0.45} />
      <S id="golpe" en={0} volumen={0.3} />
      <S id="calendario" en={m("gta")} volumen={0.35} />
      <S id="golpe" en={m("tanto")} volumen={0.25} />
    </Escena>
  );
};

/* 2 · ÉXITO: 230 millones de copias */
export const Exito: React.FC = () => {
  const m = LINEA.marcas("exito");
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const cajas = Math.min(14, Math.max(0, Math.floor((frame - m("nunca")) / (fps * 0.12))));
  return (
    <Escena id="exito" etiqueta="RAZÓN 1" titulo="GTA V nunca dejó de venderse" claves={["millones"]} golpes={[m("millones")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 30 }}>
        <div style={{ position: "relative", width: 700, height: 300 }}>
          {new Array(cajas).fill(0).map((_, k) => {
            const fila = Math.floor(k / 5);
            const col = k % 5;
            return (
              <svg
                key={k}
                width={120}
                height={150}
                viewBox="0 0 120 150"
                style={{ position: "absolute", left: 50 + col * 125 + (fila % 2) * 60, bottom: fila * 100 }}
              >
                <rect x={8} y={8} width={104} height={134} rx={10} fill="#0c2f3a" stroke={C.menta} strokeWidth={5} />
                <rect x={8} y={8} width={104} height={30} rx={8} fill={C.menta} opacity={0.85} />
                <text x={60} y={98} textAnchor="middle" fontFamily="Baloo 2" fontWeight={800} fontSize={44} fill={C.hueso}>
                  V
                </text>
              </svg>
            );
          })}
        </div>
        <Pop desde={m("doscientos")}>
          <Brillo>
            <Contador hasta={230000000} inicio={m("doscientos")} dur={1.4} sufijo="+" tamano={92} />
          </Brillo>
        </Pop>
        <Pop desde={m("sigue")}>
          <Chip texto="y sigue vendiendo cada año" color={C.cascabel} tamano={36} />
        </Pop>
      </div>
      <S id="pop" en={m("nunca")} volumen={0.3} />
      <S id="exito" en={m("millones")} volumen={0.3} />
      <S id="monedas" en={m("sigue")} volumen={0.3} />
    </Escena>
  );
};

/* 3 · ONLINE: jugadores conectados y monedas */
export const Online: React.FC = () => {
  const m = LINEA.marcas("online");
  const frame = useCurrentFrame();
  const s = useSeg();
  const red = interpolate(frame, [m("online"), m("gente") + 20], [0, 1], CLAMP);
  const monedas = frame >= m("gastando");
  const nodos = new Array(12).fill(0).map((_, i) => {
    const a = (i / 12) * Math.PI * 2;
    return { x: 500 + Math.cos(a) * 360, y: 300 + Math.sin(a) * 210 };
  });
  return (
    <Escena id="online" etiqueta="RAZÓN 2" titulo="GTA Online no paró" claves={["gastando"]} golpes={[m("gastando")]}>
      <div style={{ position: "relative", width: 1000, height: 600 }}>
        <svg width={1000} height={600} viewBox="0 0 1000 600" style={{ position: "absolute" }}>
          {nodos.map((n, i) => (
            <g key={i} opacity={i / 12 < red ? 1 : 0}>
              <line x1={500} y1={300} x2={n.x} y2={n.y} stroke={C.azul} strokeWidth={3} opacity={0.5} />
              <circle cx={n.x} cy={n.y} r={30} fill="#0c2f3a" stroke={C.menta} strokeWidth={4} />
              <circle cx={n.x} cy={n.y - 8} r={9} fill={C.menta} />
              <path
                d={`M${n.x - 15} ${n.y + 18} C${n.x - 15} ${n.y + 2} ${n.x + 15} ${n.y + 2} ${n.x + 15} ${n.y + 18} Z`}
                fill={C.menta}
              />
            </g>
          ))}
          <circle cx={500} cy={300} r={80} fill="#2a2060" stroke={C.menta} strokeWidth={6} />
          <text x={500} y={316} textAnchor="middle" fontFamily="JetBrains Mono" fontWeight={700} fontSize={40} fill={C.hueso}>
            ONLINE
          </text>
          {monedas
            ? new Array(10).fill(0).map((_, k) => {
                const n = nodos[(k * 5) % 12];
                const p = (s * 0.9 + random(`m${k}`)) % 1;
                return (
                  <g key={k} opacity={Math.sin(p * Math.PI)}>
                    <circle
                      cx={n.x + (500 - n.x) * p}
                      cy={n.y + (300 - n.y) * p}
                      r={16}
                      fill={C.cascabel}
                      stroke="#1d1530"
                      strokeWidth={3}
                    />
                    <text
                      x={n.x + (500 - n.x) * p}
                      y={n.y + (300 - n.y) * p + 7}
                      textAnchor="middle"
                      fontFamily="JetBrains Mono"
                      fontWeight={700}
                      fontSize={18}
                      fill="#1d1530"
                    >
                      $
                    </text>
                  </g>
                );
              })
            : null}
        </svg>
        <div style={{ position: "absolute", bottom: -10, left: 0, right: 0, display: "flex", justifyContent: "center" }}>
          <Pop desde={m("tiempo")}>
            <Chip texto="⏳ tiempo de sobra" />
          </Pop>
        </div>
      </div>
      <S id="pop" en={m("online")} volumen={0.3} />
      <S id="monedas" en={m("gastando")} volumen={0.35} />
      <S id="tic" en={m("tiempo")} volumen={0.35} />
    </Escena>
  );
};

/* 4 · RED DEAD: un atardecer del oeste */
export const Rdr: React.FC = () => {
  const m = LINEA.marcas("rdr");
  const s = useSeg();
  return (
    <Escena id="rdr" etiqueta="MIENTRAS TANTO" titulo="Otro juego enorme" claves={["enorme"]} golpes={[m("enorme"), m("dieciocho")]}>
      <div
        style={{
          position: "relative",
          width: 1000,
          height: 600,
          borderRadius: 40,
          overflow: "hidden",
          border: `3px solid ${C.cascabel}55`,
        }}
      >
        <svg width={1000} height={600} viewBox="0 0 1000 600" style={{ position: "absolute" }}>
          <defs>
            <linearGradient id="atardecer" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0" stopColor="#2a2060" />
              <stop offset="0.6" stopColor="#c2334d" />
              <stop offset="1" stopColor="#ffb547" />
            </linearGradient>
          </defs>
          <rect width={1000} height={600} fill="url(#atardecer)" />
          <circle cx={500} cy={420 - 10 * Math.sin(s)} r={110} fill="#ffd27a" opacity={0.9} />
          <path d="M0 470 C200 430 350 480 520 450 C700 420 820 470 1000 440 L1000 600 L0 600 Z" fill="#3a1830" />
          {[
            [180, 470, 1.1],
            [820, 455, 0.8],
          ].map(([x, y, e], k) => (
            <g key={k} transform={`translate(${x} ${y}) scale(${e})`} fill="#1d1530">
              <rect x={-14} y={-150} width={28} height={150} rx={14} />
              <rect x={-60} y={-110} width={22} height={60} rx={11} />
              <rect x={-60} y={-60} width={50} height={20} rx={10} />
              <rect x={38} y={-130} width={22} height={60} rx={11} />
              <rect x={10} y={-80} width={50} height={20} rx={10} />
            </g>
          ))}
          <g transform={`translate(500 250) rotate(${Math.sin(s * 2) * 4})`}>
            <path d="M-150 30 C-90 10 90 10 150 30 C120 50 -120 50 -150 30 Z" fill="#6b3e1d" stroke="#1d1530" strokeWidth={5} />
            <path d="M-80 26 C-80 -40 -50 -60 0 -50 C50 -60 80 -40 80 26 Z" fill="#8b5a2b" stroke="#1d1530" strokeWidth={5} />
            <rect x={-80} y={4} width={160} height={16} fill="#3b2410" />
          </g>
        </svg>
        <div style={{ position: "absolute", top: 30, left: 0, right: 0, display: "flex", justifyContent: "center" }}>
          <Pop desde={m("red")}>
            <Chip texto="RED DEAD REDEMPTION 2" color={C.cascabel} tamano={40} />
          </Pop>
        </div>
        <div style={{ position: "absolute", bottom: 30, left: 0, right: 0, display: "flex", justifyContent: "center" }}>
          <Pop desde={m("dieciocho")}>
            <Chip texto="2018" color={C.hueso} tamano={56} />
          </Pop>
        </div>
      </div>
      <S id="whoosh" en={m("enorme")} volumen={0.3} />
      <S id="caballo" en={m("red")} volumen={0.35} />
      <S id="tic" en={m("dieciocho")} volumen={0.35} />
    </Escena>
  );
};

/* 5 · RETRASOS: dos fechas tachadas y la definitiva */
const Fecha: React.FC<{ texto: string; tachada: boolean; desde: number; selloEn?: number; buena?: boolean }> = ({
  texto,
  tachada,
  desde,
  selloEn,
  buena,
}) => {
  const frame = useCurrentFrame();
  const p = selloEn === undefined ? 0 : interpolate(frame, [selloEn, selloEn + 6], [0, 1], CLAMP);
  return (
    <Pop desde={desde}>
      <div
        style={{
          position: "relative",
          width: 270,
          height: 210,
          borderRadius: 26,
          background: "rgba(2,8,20,0.8)",
          border: `4px solid ${buena ? C.menta : "#ffffff33"}`,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          textAlign: "center",
          fontFamily: F.titulo,
          fontWeight: 800,
          fontSize: 52,
          color: buena ? C.menta : C.hueso,
          lineHeight: 1.05,
          opacity: tachada && p > 0.5 ? 0.6 : 1,
          whiteSpace: "pre-line",
        }}
      >
        {texto}
        {tachada && frame >= (selloEn ?? 0) ? (
          <div
            style={{
              position: "absolute",
              fontFamily: F.titulo,
              fontWeight: 800,
              fontSize: 170,
              color: C.panuelo,
              transform: `scale(${2 - p}) rotate(-12deg)`,
              opacity: p,
            }}
          >
            ✗
          </div>
        ) : null}
        {buena ? (
          <div
            style={{
              position: "absolute",
              top: -26,
              right: -20,
              width: 64,
              height: 64,
              borderRadius: 32,
              background: C.menta,
              color: C.abismo,
              fontSize: 44,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
            }}
          >
            ✓
          </div>
        ) : null}
      </div>
    </Pop>
  );
};

export const Retrasos: React.FC = () => {
  const m = LINEA.marcas("retrasos");
  return (
    <Escena
      id="retrasos"
      etiqueta="EL GIRO"
      titulo="Dos retrasos"
      claves={["retrasaron", "noviembre"]}
      golpes={[m("mayo"), m("noviembre")]}
    >
      <div style={{ display: "flex", gap: 22, alignItems: "center" }}>
        <Fecha texto={"Otoño\n2025"} tachada desde={m("veinticinco") - 10} selloEn={m("mayo")} />
        <Fecha texto={"Mayo\n2026"} tachada desde={m("mayo")} selloEn={m("noviembre")} />
        <Fecha texto={"19 NOV\n2026"} tachada={false} desde={m("noviembre")} buena />
      </div>
      <S id="pop" en={m("veinticinco") - 10} volumen={0.3} />
      <S id="sello" en={m("mayo")} volumen={0.45} />
      <S id="sello" en={m("noviembre")} volumen={0.45} />
      <S id="exito" en={m("noviembre") + 12} volumen={0.25} />
    </Escena>
  );
};

/* 6 · REMATE: pulirlo hasta que brille */
export const Remate: React.FC = () => {
  const m = LINEA.marcas("remate");
  const frame = useCurrentFrame();
  const s = useSeg();
  const brillo = interpolate(frame, [m("pulirlo"), m("fans")], [0.2, 1], CLAMP);
  return (
    <Escena
      id="remate"
      etiqueta="EL MOTIVO OFICIAL"
      titulo="Pulirlo al máximo"
      claves={["pulirlo", "fans"]}
      golpes={[m("pulirlo"), m("fans")]}
    >
      <div style={{ position: "relative", display: "flex", alignItems: "center", justifyContent: "center" }}>
        <Respira amp={0.02}>
          <div style={{ filter: `drop-shadow(0 0 ${10 + 40 * brillo}px ${C.menta})` }}>
            <svg width={440} height={440} viewBox="-110 -110 220 220" style={{ transform: `rotate(${s * 40}deg)` }}>
              <circle r={100} fill="#9aabc9" opacity={0.4 + 0.6 * brillo} stroke="#1d1530" strokeWidth={5} />
              <circle r={100} fill="url(#arcoiris)" opacity={brillo * 0.6} />
              <defs>
                <linearGradient id="arcoiris" x1="0" y1="0" x2="1" y2="1">
                  <stop offset="0" stopColor={C.menta} />
                  <stop offset="0.5" stopColor={C.pelaje} />
                  <stop offset="1" stopColor={C.cascabel} />
                </linearGradient>
              </defs>
              <circle r={26} fill={C.abismo} stroke="#1d1530" strokeWidth={5} />
              <path d="M-60 -50 A80 80 0 0 1 20 -78" stroke="#ffffff" strokeWidth={10} fill="none" strokeLinecap="round" opacity={brillo} />
            </svg>
          </div>
        </Respira>
        {new Array(6).fill(0).map((_, k) => {
          const a = (k / 6) * Math.PI * 2 + s;
          return (
            <svg
              key={k}
              width={50}
              height={50}
              viewBox="-25 -25 50 50"
              style={{
                position: "absolute",
                left: `calc(50% + ${Math.cos(a) * 280}px - 25px)`,
                top: `calc(50% + ${Math.sin(a) * 280}px - 25px)`,
                opacity: brillo,
              }}
            >
              <path d="M0 -22 L6 -6 L22 0 L6 6 L0 22 L-6 6 L-22 0 L-6 -6 Z" fill={C.cascabel} />
            </svg>
          );
        })}
        <Rafaga en={m("fans")} tamano={900} />
      </div>
      <S id="pulir" en={m("pulirlo")} volumen={0.4} />
      <S id="brillo" en={m("altura")} volumen={0.35} />
    </Escena>
  );
};

/* 7 · PREGUNTA + FIRMA */
export const Pregunta: React.FC = () => {
  const m = LINEA.marcas("pregunta");
  const { fps } = useVideoConfig();
  const firma = m("no") + Math.round(fps * 1.2);
  return (
    <Escena id="pregunta" etiqueta="¿Y TÚ?" titulo="¿Valió la pena esperar?" claves={["si", "no"]} golpes={[m("diecinueve"), m("si")]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 40 }}>
        <Pop desde={m("diecinueve")}>
          <Brillo color={C.cascabel}>
            <div
              style={{
                fontFamily: F.cifra,
                fontWeight: 700,
                fontSize: 90,
                color: C.cascabel,
                background: "rgba(2,8,20,0.8)",
                border: `3px solid ${C.cascabel}88`,
                borderRadius: 26,
                padding: "0 34px",
              }}
            >
              19 · NOV
            </div>
          </Brillo>
        </Pop>
        <div style={{ display: "flex", gap: 60 }}>
          {[
            { t: "SÍ", c: C.menta, w: "si" },
            { t: "NO", c: C.panuelo, w: "no" },
          ].map((b, k) => (
            <Pop key={b.t} desde={m(b.w)} giro={k ? 10 : -10}>
              <Respira fase={k * 1.5} amp={0.05}>
                <div
                  style={{
                    width: 260,
                    height: 180,
                    borderRadius: 40,
                    background: b.c,
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontFamily: F.titulo,
                    fontWeight: 800,
                    fontSize: 110,
                    color: k ? C.hueso : C.abismo,
                  }}
                >
                  {b.t}
                </div>
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
      <S id="tic" en={m("diecinueve")} volumen={0.35} />
      <S id="pop" en={m("si")} volumen={0.3} />
      <S id="pop" en={m("no")} volumen={0.3} />
      <S id="cascabel" en={firma} volumen={0.5} />
    </Escena>
  );
};
