import { interpolate, random, useCurrentFrame } from "remotion";
import { Chip, Escena, Pop, Rafaga, Sfx, usePop } from "../comunes";
import { marcas } from "../linea";
import { C, CLAMP, MONO, TITULO } from "../tema";

const Mazo: React.FC<{ en: number }> = ({ en }) => {
  const frame = useCurrentFrame();
  const golpe = interpolate(frame, [en - 8, en], [-50, 15], CLAMP);
  const vuelta = interpolate(frame, [en, en + 8], [0, -15], CLAMP);
  return (
    <svg width={260} height={240} viewBox="0 0 260 240">
      <rect x={30} y={200} width={200} height={30} rx={8} fill="#6b4423" />
      <g transform={`rotate(${golpe + vuelta} 200 180)`}>
        <rect x={60} y={150} width={150} height={18} rx={9} fill="#a0693a" />
        <rect x={20} y={110} width={70} height={100} rx={14} fill="#8b5a2b" stroke="#3b2410" strokeWidth={5} />
      </g>
    </svg>
  );
};

export const Ley: React.FC = () => {
  const m = marcas("ley");
  const frame = useCurrentFrame();
  const abrir = interpolate(frame, [m("setecientos") - 6, m("setecientos") + 18], [0, 1], CLAMP);
  return (
    <Escena id="ley" etiqueta="AÑO 1710" titulo="La primera ley" color={C.amarillo}>
      <div style={{ position: "relative", display: "flex", alignItems: "center", gap: 30 }}>
        <div style={{ width: 600, position: "relative" }}>
          <div style={{ height: 36, background: "#d9b77e", borderRadius: 18, border: "5px solid #6b4423" }} />
          <div style={{ height: 380 * abrir, overflow: "hidden", background: "#f3e2b8", margin: "0 20px", borderLeft: "5px solid #6b4423", borderRight: "5px solid #6b4423", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", textAlign: "center" }}>
            <div style={{ fontFamily: TITULO, fontWeight: 800, fontSize: 96, color: "#5b3a12", lineHeight: 1 }}>1710</div>
            <div style={{ fontFamily: TITULO, fontWeight: 800, fontSize: 46, color: "#5b3a12", lineHeight: 1.1, padding: "0 20px" }}>Estatuto de la Reina Ana</div>
            <div style={{ fontFamily: TITULO, fontWeight: 600, fontSize: 36, color: "#8a6a3a", marginTop: 14, opacity: frame >= m("autor") ? 1 : 0 }}>Primera ley de derechos de autor</div>
          </div>
          <div style={{ height: 36, background: "#d9b77e", borderRadius: 18, border: "5px solid #6b4423" }} />
        </div>
        <Pop desde={m("ley") - 12}>
          <Mazo en={m("ley")} />
        </Pop>
        <Rafaga en={m("ley")} color={C.amarillo} x={330} y={60} tamano={500} />
      </div>
      <Sfx id="pergamino" en={m("setecientos") - 6} volumen={0.4} />
      <Sfx id="mazo" en={m("ley")} volumen={0.45} />
      <Sfx id="brillo" en={m("estatuto")} volumen={0.25} />
    </Escena>
  );
};

const Casete: React.FC<{ ancho: number; girando: boolean; color: string }> = ({ ancho, girando, color }) => {
  const frame = useCurrentFrame();
  const giro = girando ? frame * 8 : 0;
  const rueda = (cx: number) => (
    <g transform={`translate(${cx} 120) rotate(${giro})`}>
      <circle r={34} fill="#f4f1ea" stroke="#222" strokeWidth={4} />
      {[0, 60, 120, 180, 240, 300].map((a) => <rect key={a} x={-4} y={-30} width={8} height={14} fill="#222" transform={`rotate(${a})`} />)}
      <circle r={10} fill="#222" />
    </g>
  );
  return (
    <svg width={ancho} height={ancho * 0.64} viewBox="0 0 400 256">
      <rect x={6} y={6} width={388} height={244} rx={22} fill={color} stroke="#0b1424" strokeWidth={8} />
      <rect x={40} y={30} width={320} height={60} rx={10} fill="#f4f1ea" />
      <line x1={60} y1={52} x2={280} y2={52} stroke="#bbb" strokeWidth={5} />
      <line x1={60} y1={70} x2={220} y2={70} stroke="#bbb" strokeWidth={5} />
      <rect x={90} y={86} width={220} height={70} rx={30} fill="#2b2b3b" />
      {rueda(140)}
      {rueda(260)}
      <path d="M90 250 L120 196 L280 196 L310 250" fill="#0b1424" opacity={0.4} />
    </svg>
  );
};

export const Cintas: React.FC = () => {
  const m = marcas("cintas");
  const frame = useCurrentFrame();
  const copia = usePop(m("copias"), 12);
  return (
    <Escena id="cintas" etiqueta="AÑOS 70 Y 80" titulo="La era del casete" color={C.rosa}>
      <div style={{ position: "relative", width: 1000, height: 600, display: "flex", alignItems: "center", justifyContent: "center" }}>
        <div style={{ position: "absolute", left: 30, top: 60 }}>
          <Pop desde={m("radio")}>
            <div style={{ fontSize: 150 }}>📻</div>
          </Pop>
          {frame >= m("radio")
            ? [0, 1, 2].map((k) => {
                const p = ((frame - m("radio") + k * 10) % 30) / 30;
                return <div key={k} style={{ position: "absolute", left: 150 + p * 120, top: 40, width: 60, height: 120, borderRadius: "50%", border: `6px solid ${C.rosa}`, borderLeft: "none", borderTop: "none", borderBottom: "none", opacity: 1 - p }} />;
              })
            : null}
        </div>
        <div style={{ transform: `translateX(${-180 * copia}px) rotate(${-4 * copia}deg)` }}>
          <Pop desde={m("casete")}>
            <Casete ancho={420} girando={frame >= m("casete")} color={C.rosa} />
          </Pop>
        </div>
        <div style={{ position: "absolute", transform: `translateX(${260 * copia}px) translateY(${90 * copia}px) rotate(${6 * copia}deg) scale(${copia * 0.85})`, opacity: copia }}>
          <Casete ancho={420} girando color={C.cian} />
        </div>
        <div style={{ position: "absolute", top: 40, fontFamily: TITULO, fontWeight: 800, fontSize: 90, color: C.amarillo, opacity: copia, transform: `translateX(60px) scale(${copia})` }}>→</div>
        {frame >= m("casete")
          ? new Array(6).fill(0).map((_, k) => {
              const p = ((frame + k * 17) % 60) / 60;
              return <div key={k} style={{ position: "absolute", left: 300 + random(`n${k}`) * 400, top: 480 - p * 420, fontSize: 50, opacity: Math.sin(p * Math.PI) }}>{k % 2 ? "🎵" : "🎶"}</div>;
            })
          : null}
      </div>
      <Sfx id="casete" en={m("casete")} volumen={0.45} />
      <Sfx id="notas" en={m("radio")} volumen={0.3} />
      <Sfx id="pop" en={m("copias")} />
    </Escena>
  );
};

export const Software: React.FC = () => {
  const m = marcas("software");
  const frame = useCurrentFrame();
  const escrito = interpolate(frame, [m("carta"), m("carta") + 50], [0, 1], CLAMP);
  const disquetes = Math.floor(interpolate(frame, [m("copiar"), m("copiar") + 30], [0, 8], CLAMP));
  return (
    <Escena id="software" etiqueta="AÑO 1976" titulo="Llega el software" color={C.cian}>
      <div style={{ position: "relative", width: 1000, height: 600, display: "flex", alignItems: "center", justifyContent: "center" }}>
        <Pop desde={m("gates")} giro={-8}>
          <div style={{ width: 520, background: "#fdf6e3", borderRadius: 12, padding: "34px 40px", boxShadow: "0 20px 50px rgba(0,0,0,0.35)", transform: "rotate(-3deg)" }}>
            <div style={{ fontFamily: TITULO, fontWeight: 800, fontSize: 40, color: "#2b2b3b" }}>Carta abierta a los aficionados</div>
            {[0, 1, 2, 3, 4, 5].map((k) => (
              <div key={k} style={{ height: 12, borderRadius: 6, background: "#b9ae96", marginTop: 20, width: `${(k % 3 === 2 ? 70 : 100) * Math.min(1, Math.max(0, escrito * 6 - k))}%` }} />
            ))}
            <div style={{ fontFamily: MONO, fontWeight: 700, fontSize: 30, color: "#5b4a2a", marginTop: 26, textAlign: "right", opacity: escrito > 0.9 ? 1 : 0 }}>— Bill Gates, 1976</div>
          </div>
        </Pop>
        {new Array(disquetes).fill(0).map((_, k) => {
          const a = (k / 8) * Math.PI * 2;
          return (
            <div key={k} style={{ position: "absolute", left: 500 + Math.cos(a) * 420 - 45, top: 300 + Math.sin(a) * 250 - 45, fontSize: 80, transform: `rotate(${k * 25}deg)` }}>💾</div>
          );
        })}
        <div style={{ position: "absolute", bottom: 0 }}>
          <Chip texto="¡sin pagar! 💸" color={C.amarillo} desde={m("pagar")} />
        </div>
      </div>
      <Sfx id="escribir" en={m("carta")} volumen={0.4} />
      {[0, 2, 4, 6].map((k) => <Sfx key={k} id="pop" en={m("copiar") + k * 4} volumen={0.25} />)}
      <Sfx id="monedas" en={m("pagar")} volumen={0.35} />
    </Escena>
  );
};
