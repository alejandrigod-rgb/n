import { interpolate, random, useCurrentFrame } from "remotion";
import { Chip, Escena, Pop, Rafaga, Sello, Sfx, usePop } from "../comunes";
import { marcas } from "../linea";
import { C, CLAMP, TITULO } from "../tema";

const NODOS = new Array(14).fill(0).map((_, i) => {
  const a = (i / 14) * Math.PI * 2 + random(`na${i}`) * 0.3;
  const r = 200 + random(`nr${i}`) * 90;
  return { x: Math.cos(a) * r, y: Math.sin(a) * r * 0.75 };
});

export const Internet: React.FC = () => {
  const m = marcas("internet");
  const frame = useCurrentFrame();
  const globo = usePop(m("internet"), 12);
  const enlaces = interpolate(frame, [m("napster"), m("millones") + 10], [0, 1], CLAMP);
  return (
    <Escena id="internet" etiqueta="AÑO 1999" titulo="Llega internet... y Napster" color={C.verde}>
      <div style={{ position: "relative", width: 1000, height: 600 }}>
        <svg width={1000} height={600} viewBox="-500 -300 1000 600" style={{ position: "absolute" }}>
          {NODOS.map((n, i) => {
            const visible = i / NODOS.length < enlaces;
            return (
              <g key={i} opacity={visible ? 1 : 0}>
                <line x1={0} y1={0} x2={n.x} y2={n.y} stroke={C.verde} strokeWidth={3} opacity={0.5} />
                {frame >= m("musica") ? (() => {
                  const p = ((frame + i * 7) % 40) / 40;
                  return <text x={n.x * p} y={n.y * p} fontSize={34} textAnchor="middle">🎵</text>;
                })() : null}
                <circle cx={n.x} cy={n.y} r={22} fill="#0f1d33" stroke={C.verde} strokeWidth={5} />
                <text x={n.x} y={n.y + 11} textAnchor="middle" fontSize={28}>🧑</text>
              </g>
            );
          })}
          <g transform={`scale(${globo}) rotate(${frame * 0.5})`}>
            <circle r={130} fill="#16547a" stroke={C.cian} strokeWidth={8} />
            <ellipse rx={60} ry={130} fill="none" stroke={C.cian} strokeWidth={5} />
            <line x1={-130} y1={0} x2={130} y2={0} stroke={C.cian} strokeWidth={5} />
            <path d="M-115 -60 Q0 -40 115 -60 M-115 60 Q0 40 115 60" stroke={C.cian} strokeWidth={5} fill="none" />
          </g>
        </svg>
        <div style={{ position: "absolute", top: 10, left: 0, right: 0, display: "flex", justifyContent: "center" }}>
          <Chip texto="NAPSTER · 1999" color={C.verde} desde={m("napster")} />
        </div>
        <div style={{ position: "absolute", bottom: 0, left: 0, right: 0, textAlign: "center" }}>
          <Pop desde={m("millones")}>
            <div style={{ fontFamily: TITULO, fontWeight: 800, fontSize: 64, color: C.amarillo }}>¡millones de personas!</div>
          </Pop>
        </div>
        <Rafaga en={m("internet")} color={C.cian} tamano={700} />
      </div>
      <Sfx id="modem" en={m("internet")} volumen={0.3} />
      <Sfx id="boing" en={m("salto")} volumen={0.25} />
      <Sfx id="exito" en={m("napster")} volumen={0.3} />
      <Sfx id="notas" en={m("musica")} volumen={0.3} />
    </Escena>
  );
};

export const Cierre: React.FC = () => {
  const m = marcas("cierre");
  const frame = useCurrentFrame();
  const enjambre = usePop(m("tarde"), 14);
  const caja = interpolate(frame, [m("tarde") - 6, m("tarde") + 6], [1, 0], CLAMP);
  return (
    <Escena id="cierre" etiqueta="AÑO 2001" titulo="Cierre... y lo que vino" color={C.rojo}>
      <div style={{ position: "relative", width: 1000, height: 600, display: "flex", alignItems: "center", justifyContent: "center" }}>
        <div style={{ position: "relative", opacity: caja, transform: `scale(${0.6 + 0.4 * caja})` }}>
          <Pop desde={m("discograficas")}>
            <div style={{ width: 460, height: 260, borderRadius: 30, background: "#16547a", border: `6px solid ${C.cian}`, display: "flex", alignItems: "center", justifyContent: "center", fontFamily: TITULO, fontWeight: 800, fontSize: 80, color: C.texto }}>Napster</div>
          </Pop>
          <div style={{ position: "absolute", top: -120, right: -140 }}>
            <Pop desde={m("juicio") - 4}>
              <div style={{ fontSize: 130, transform: `rotate(${frame >= m("juicio") ? 20 : -40}deg)` }}>🔨</div>
            </Pop>
          </div>
          <Sello en={m("cerro")} texto="CERRADO" tamano={96} />
        </div>
        <svg width={1000} height={600} viewBox="-500 -300 1000 600" style={{ position: "absolute", opacity: enjambre }}>
          {new Array(18).fill(0).map((_, i) => {
            const a = (i / 18) * Math.PI * 2;
            const r = 140 + (i % 3) * 70;
            const x = Math.cos(a + frame / 90) * r * enjambre;
            const y = Math.sin(a + frame / 90) * r * 0.7 * enjambre;
            const j = (i + 5) % 18;
            const a2 = (j / 18) * Math.PI * 2;
            const r2 = 140 + (j % 3) * 70;
            return (
              <g key={i}>
                <line x1={x} y1={y} x2={Math.cos(a2 + frame / 90) * r2 * enjambre} y2={Math.sin(a2 + frame / 90) * r2 * 0.7 * enjambre} stroke={C.naranja} strokeWidth={3} opacity={0.45} />
                <circle cx={x} cy={y} r={16} fill={C.naranja} />
              </g>
            );
          })}
        </svg>
        <div style={{ position: "absolute", bottom: 10 }}>
          <Chip texto="BitTorrent · 2001" color={C.naranja} desde={m("bittorrent")} />
        </div>
      </div>
      <Sfx id="mazo" en={m("juicio")} volumen={0.45} />
      <Sfx id="sello" en={m("cerro")} volumen={0.5} />
      <Sfx id="whoosh" en={m("tarde")} volumen={0.35} />
      <Sfx id="pop" en={m("bittorrent")} />
    </Escena>
  );
};

export const Streaming: React.FC = () => {
  const m = marcas("streaming");
  const frame = useCurrentFrame();
  const play = usePop(m("streaming"), 9);
  const curva = interpolate(frame, [m("legal"), m("piratear") + 10], [0, 1], CLAMP);
  const pulso = 1 + 0.05 * Math.sin(frame / 5);
  const puntos = new Array(20).fill(0).map((_, k) => {
    const x = k * 22;
    const y = k < 8 ? 40 + Math.sin(k) * 10 : 40 + (k - 8) * 16;
    return `${x},${y}`;
  });
  return (
    <Escena id="streaming" etiqueta="AÑOS 2010" titulo="¿Qué la frenó?" color={C.verde}>
      <div style={{ position: "relative", width: 1000, height: 600, display: "flex", alignItems: "center", justifyContent: "space-around" }}>
        <div style={{ transform: `scale(${play * pulso})` }}>
          <svg width={300} height={300} viewBox="0 0 300 300">
            <circle cx={150} cy={150} r={140} fill={C.rojo} />
            <polygon points="120,90 220,150 120,210" fill="#fff" />
          </svg>
          <div style={{ fontFamily: TITULO, fontWeight: 800, fontSize: 50, color: C.texto, textAlign: "center" }}>streaming</div>
        </div>
        <Pop desde={m("legal")}>
          <div style={{ background: "#0b1424aa", borderRadius: 24, padding: 24, border: `3px solid ${C.verde}55` }}>
            <div style={{ fontFamily: TITULO, fontWeight: 600, fontSize: 34, color: C.tenue }}>piratería</div>
            <svg width={440} height={300} viewBox="0 0 440 300">
              <polyline points={puntos.join(" ")} fill="none" stroke={C.rojo} strokeWidth={10} strokeLinecap="round" strokeLinejoin="round" strokeDasharray={800} strokeDashoffset={800 * (1 - curva)} />
              <polygon points="410,250 440,230 425,275" fill={C.rojo} opacity={curva > 0.95 ? 1 : 0} />
            </svg>
          </div>
        </Pop>
        <div style={{ position: "absolute", bottom: -10, display: "flex", gap: 20 }}>
          <Chip texto="legal" color={C.verde} desde={m("legal")} />
          <Chip texto="fácil" color={C.cian} desde={m("facil")} />
          <Chip texto="barato" color={C.amarillo} desde={m("barato")} />
        </div>
        <Rafaga en={m("streaming")} color={C.rojo} x={-250} tamano={600} />
      </div>
      <Sfx id="exito" en={m("streaming")} volumen={0.35} />
      <Sfx id="boing" en={m("streaming")} volumen={0.25} />
      {["legal", "facil", "barato"].map((w) => <Sfx key={w} id="pop" en={m(w)} volumen={0.3} />)}
    </Escena>
  );
};

const RIESGOS = [
  { emoji: "⚖️", texto: "Es ilegal", palabra: "ilegal", color: C.amarillo, sfx: "sello" },
  { emoji: "🦠", texto: "Virus", palabra: "virus", color: C.verde, sfx: "glitch" },
  { emoji: "💸", texto: "Sin ingresos para quien crea", palabra: "ingresos", color: C.rosa, sfx: "monedas" },
];

export const Riesgos: React.FC = () => {
  const m = marcas("riesgos");
  const frame = useCurrentFrame();
  return (
    <Escena id="riesgos" etiqueta="¡OJO!" titulo="Los riesgos" color={C.rojo}>
      <div style={{ display: "flex", flexDirection: "column", gap: 34 }}>
        {RIESGOS.map((r) => {
          const en = m(r.palabra);
          const glitch = r.palabra === "virus" && frame >= en && frame < en + 18 ? (random(`g${frame}`) - 0.5) * 30 : 0;
          return (
            <Pop key={r.texto} desde={en} giro={-12}>
              <div style={{ width: 860, display: "flex", alignItems: "center", gap: 30, background: "#0b1424cc", border: `5px solid ${r.color}`, borderRadius: 30, padding: "18px 34px", transform: `translateX(${glitch}px)` }}>
                <div style={{ fontSize: 100 }}>{r.emoji}</div>
                <div style={{ fontFamily: TITULO, fontWeight: 800, fontSize: 58, color: r.color, lineHeight: 1.05 }}>{r.texto}</div>
              </div>
            </Pop>
          );
        })}
      </div>
      {RIESGOS.map((r) => <Sfx key={r.texto} id={r.sfx} en={m(r.palabra)} volumen={0.4} />)}
    </Escena>
  );
};

export const Final: React.FC = () => {
  const m = marcas("final");
  const frame = useCurrentFrame();
  const corazon = usePop(m("apoya"), 8);
  const latido = 1 + 0.08 * Math.max(0, Math.sin(frame / 4));
  return (
    <Escena id="final" etiqueta="EN RESUMEN" titulo="Apoya a quien crea" color={C.rosa}>
      <div style={{ position: "relative", display: "flex", flexDirection: "column", alignItems: "center" }}>
        <div style={{ transform: `scale(${corazon * latido})` }}>
          <svg width={340} height={300} viewBox="0 0 100 90">
            <path d="M50 86 C20 64 4 46 6 28 C8 12 28 4 40 14 L50 23 L60 14 C72 4 92 12 94 28 C96 46 80 64 50 86 Z" fill={C.rojo} stroke="#0b1424" strokeWidth={3} />
            <path d="M24 26 C26 20 32 17 37 18" stroke="#ffffff99" strokeWidth={4} fill="none" strokeLinecap="round" />
          </svg>
        </div>
        <Pop desde={m("vemos")} style={{ marginTop: 30 }}>
          <div style={{ fontFamily: TITULO, fontWeight: 800, fontSize: 70, color: C.amarillo, textAlign: "center" }}>¡Nos vemos!</div>
        </Pop>
        <Rafaga en={m("apoya")} color={C.rosa} y={-60} tamano={700} />
        <Rafaga en={m("vemos")} color={C.amarillo} y={-60} tamano={800} />
      </div>
      <Sfx id="corazon" en={m("apoya")} volumen={0.4} />
      <Sfx id="brillo" en={m("vemos")} volumen={0.35} />
      <Sfx id="boing" en={m("vemos")} volumen={0.25} />
    </Escena>
  );
};


