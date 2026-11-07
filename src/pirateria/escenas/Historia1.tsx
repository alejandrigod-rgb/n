import { interpolate, useCurrentFrame } from "remotion";
import { Chip, Escena, Pop, Rafaga, Sello, Sfx, usePop } from "../comunes";
import { marcas } from "../linea";
import { C, CLAMP, TITULO } from "../tema";

/** Bandera pirata ondeando (dibujo genérico). */
const Bandera: React.FC<{ ancho: number }> = ({ ancho }) => {
  const frame = useCurrentFrame();
  const puntos = (y: number) =>
    new Array(11).fill(0).map((_, k) => {
      const x = k * 32;
      return `${x},${y + Math.sin(frame / 5 - k * 0.6) * (k * 1.6)}`;
    });
  const arriba = puntos(0);
  const abajo = puntos(200).reverse();
  return (
    <svg width={ancho} height={ancho * 0.8} viewBox="-30 -30 380 300">
      <rect x={-22} y={-20} width={12} height={300} rx={6} fill="#c08a4a" />
      <polygon points={[...arriba, ...abajo].join(" ")} fill="#151320" stroke="#000" strokeWidth={4} />
      <g transform={`translate(160 ${100 + Math.sin(frame / 5 - 3) * 8})`}>
        <circle r={42} cy={-10} fill="#f4f1ea" />
        <rect x={-22} y={20} width={44} height={20} rx={6} fill="#f4f1ea" />
        <circle cx={-15} cy={-12} r={11} fill="#151320" />
        <circle cx={15} cy={-12} r={11} fill="#151320" />
        <path d="M-70 50 L70 90 M-70 90 L70 50" stroke="#f4f1ea" strokeWidth={14} strokeLinecap="round" />
      </g>
    </svg>
  );
};

export const Intro: React.FC = () => {
  const m = marcas("intro");
  const frame = useCurrentFrame();
  const bandera = usePop(m("pirateria"), 10);
  const tachar = interpolate(frame, [m("internet") + 6, m("internet") + 16], [0, 1], CLAMP);
  return (
    <Escena id="intro" etiqueta="HISTORIA EXPRESS" titulo="¿Qué es la piratería?" color={C.amarillo}>
      <div style={{ position: "relative", display: "flex", flexDirection: "column", alignItems: "center" }}>
        <div style={{ transform: `scale(${bandera}) rotate(${(1 - bandera) * -20}deg)` }}>
          <Bandera ancho={460} />
        </div>
        <div style={{ position: "relative", marginTop: 10 }}>
          <Pop desde={m("antigua")}>
            <div style={{ fontFamily: TITULO, fontWeight: 800, fontSize: 60, color: C.texto }}>
              más antigua que <span style={{ position: "relative", color: C.cian }}>
                internet
                <span style={{ position: "absolute", left: -6, right: -6, top: "52%", height: 10, background: C.rojo, borderRadius: 5, transformOrigin: "left", transform: `scaleX(${tachar}) rotate(-6deg)` }} />
              </span>
            </div>
          </Pop>
        </div>
        <div style={{ position: "absolute", top: 20, right: -40 }}>
          <Chip texto="SPOILER" color={C.rojo} desde={m("spoiler")} />
        </div>
        <Rafaga en={m("pirateria")} color={C.amarillo} y={-60} tamano={700} />
      </div>
      <Sfx id="olas" en={m("pirateria")} volumen={0.2} dur={45} />
      <Sfx id="pop" en={m("spoiler")} />
      <Sfx id="sello" en={m("internet") + 6} volumen={0.3} />
    </Escena>
  );
};

const ITEMS = [
  { emoji: "🎬", palabra: "peli", color: C.rosa },
  { emoji: "🎵", palabra: "cancion", color: C.cian },
  { emoji: "🎮", palabra: "videojuego", color: C.verde },
];

export const Que: React.FC = () => {
  const m = marcas("que");
  const frame = useCurrentFrame();
  return (
    <Escena id="que" etiqueta="DEFINICIÓN" titulo="¿Qué es piratear?" color={C.cian}>
      <div style={{ position: "relative", width: 1000, height: 560 }}>
        <div style={{ display: "flex", justifyContent: "space-around", alignItems: "center", height: "100%" }}>
          {ITEMS.map((it) => {
            const en = m(it.palabra);
            const copias = interpolate(frame, [en + 8, en + 24], [0, 1], CLAMP);
            return (
              <Pop key={it.emoji} desde={en} giro={-30}>
                <div style={{ position: "relative", width: 250, height: 250 }}>
                  {[3, 2, 1].map((k) => (
                    <div key={k} style={{ position: "absolute", inset: 0, borderRadius: 40, background: `${it.color}22`, border: `4px dashed ${it.color}88`, transform: `translate(${k * 22 * copias}px, ${-k * 22 * copias}px)`, opacity: copias }} />
                  ))}
                  <div style={{ position: "absolute", inset: 0, borderRadius: 40, background: "#ffffff12", border: `5px solid ${it.color}`, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 140 }}>{it.emoji}</div>
                </div>
              </Pop>
            );
          })}
        </div>
        <Sello en={m("permiso")} texto="SIN PERMISO" tamano={92} />
      </div>
      {ITEMS.map((it) => <Sfx key={it.emoji} id="pop" en={m(it.palabra)} />)}
      <Sfx id="sello" en={m("permiso")} volumen={0.5} />
    </Escena>
  );
};

/** Barco pirata navegando sobre olas animadas. */
export const Nombre: React.FC = () => {
  const m = marcas("nombre");
  const frame = useCurrentFrame();
  const barcoX = interpolate(frame, [m("piratas") - 10, m("piratas", 1)], [-380, 120], CLAMP);
  const ola = (y: number, fase: number, color: string) => {
    let d = `M-20 ${y}`;
    for (let x = -20; x <= 1100; x += 40) d += ` Q${x + 20} ${y + Math.sin(frame / 8 + x / 60 + fase) * 18 - 14} ${x + 40} ${y}`;
    return <path d={`${d} L1100 640 L-20 640 Z`} fill={color} />;
  };
  return (
    <Escena id="nombre" etiqueta="EL NOMBRE" titulo="¿Por qué «piratas»?" color={C.naranja}>
      <div style={{ position: "relative", width: 1080, height: 620, overflow: "hidden" }}>
        <svg width={1080} height={620} viewBox="0 0 1080 620" style={{ position: "absolute" }}>
          {ola(430, 0, "#2a6f97")}
          <g transform={`translate(${440 + barcoX} ${330 + Math.sin(frame / 9) * 8}) rotate(${Math.sin(frame / 11) * 4})`} opacity={frame >= m("piratas") - 10 ? 1 : 0}>
            <line x1={0} y1={-220} x2={0} y2={60} stroke="#6b4423" strokeWidth={12} />
            <path d="M6 -200 C90 -170 90 -60 6 -40 Z" fill="#f4f1ea" stroke="#333" strokeWidth={4} />
            <path d="M-6 -190 C-80 -160 -80 -70 -6 -50 Z" fill="#e8e2d4" stroke="#333" strokeWidth={4} />
            <rect x={-4} y={-250} width={60} height={34} fill="#151320" />
            <circle cx={26} cy={-235} r={9} fill="#f4f1ea" />
            <path d="M-170 40 L170 40 L120 120 L-120 120 Z" fill="#8b5a2b" stroke="#4a2c10" strokeWidth={6} />
            <circle cx={-60} cy={78} r={10} fill="#3b2410" />
            <circle cx={0} cy={78} r={10} fill="#3b2410" />
            <circle cx={60} cy={78} r={10} fill="#3b2410" />
          </g>
          {ola(470, 2, "#1f5677")}
          {ola(520, 4, "#173f5a")}
        </svg>
        <div style={{ position: "absolute", top: 40, left: 0, right: 0, display: "flex", justifyContent: "center" }}>
          <Pop desde={m("ajeno")}>
            <div style={{ fontFamily: TITULO, fontWeight: 800, fontSize: 52, color: C.texto, background: "#00000055", padding: "8px 28px", borderRadius: 20 }}>
              se quedaban con lo <span style={{ color: C.naranja }}>ajeno</span>
            </div>
          </Pop>
        </div>
        <div style={{ position: "absolute", top: 150, left: 0, right: 0, display: "flex", justifyContent: "center" }}>
          <Pop desde={m("piratas", 1)} giro={10}>
            <div style={{ fontFamily: TITULO, fontWeight: 800, fontSize: 60, color: "#0f1d33", background: C.amarillo, padding: "6px 30px", borderRadius: 20, transform: "rotate(-3deg)" }}>
              PIRATA = copiar sin permiso
            </div>
          </Pop>
        </div>
      </div>
      <Sfx id="olas" en={m("piratas") - 10} volumen={0.35} />
      <Sfx id="boing" en={m("piratas")} volumen={0.3} />
      <Sfx id="pop" en={m("ajeno")} />
      <Sfx id="exito" en={m("piratas", 1)} volumen={0.3} />
    </Escena>
  );
};

/** Imprenta que estampa libros sin parar. */
export const Imprenta: React.FC = () => {
  const m = marcas("imprenta");
  const frame = useCurrentFrame();
  const inicio = m("imprenta");
  const ciclo = Math.max(0, frame - inicio);
  const baja = frame >= inicio ? Math.max(0, Math.sin((ciclo / 14) * Math.PI)) : 0;
  const rapido = frame >= m("facilisimo");
  const libros = Math.min(12, Math.floor(ciclo / (rapido ? 5 : 14)));
  return (
    <Escena id="imprenta" etiqueta="SIGLO XV" titulo="Llega la imprenta" color={C.verde}>
      <div style={{ position: "relative", width: 1000, height: 600, display: "flex", alignItems: "flex-end", justifyContent: "center", gap: 60 }}>
        <Pop desde={inicio}>
          <svg width={360} height={480} viewBox="0 0 360 480">
            <rect x={30} y={20} width={30} height={440} rx={8} fill="#8b5a2b" stroke="#3b2410" strokeWidth={5} />
            <rect x={300} y={20} width={30} height={440} rx={8} fill="#8b5a2b" stroke="#3b2410" strokeWidth={5} />
            <rect x={20} y={10} width={320} height={40} rx={10} fill="#a0693a" stroke="#3b2410" strokeWidth={5} />
            <rect x={170} y={50} width={20} height={90 + 110 * baja} fill="#777" />
            <rect x={90} y={130 + 110 * baja} width={180} height={50} rx={8} fill="#555" stroke="#222" strokeWidth={5} />
            <rect x={60} y={330} width={240} height={30} rx={6} fill="#a0693a" stroke="#3b2410" strokeWidth={5} />
            <rect x={110} y={300} width={140} height={30} fill="#f4f1ea" stroke="#999" strokeWidth={3} />
            <rect x={20} y={440} width={320} height={30} rx={8} fill="#6b4423" />
          </svg>
        </Pop>
        <div style={{ position: "relative", width: 300, height: 480 }}>
          {new Array(libros).fill(0).map((_, k) => (
            <div key={k} style={{ position: "absolute", bottom: k * 36, left: 40 + (k % 2) * 16, width: 200, height: 34, borderRadius: 6, background: [C.rojo, C.cian, C.amarillo, C.verde, C.rosa][k % 5], border: "4px solid #0b1424" }} />
          ))}
          <div style={{ position: "absolute", top: -20, left: 0, right: 0, textAlign: "center" }}>
            <Pop desde={m("facilisimo")}>
              <div style={{ fontFamily: TITULO, fontWeight: 800, fontSize: 64, color: C.amarillo }}>¡x100!</div>
            </Pop>
          </div>
        </div>
        <Sello en={m("permiso")} texto="SIN PERMISO" tamano={70} giro={8} />
      </div>
      <Sfx id="imprenta" en={inicio} volumen={0.4} />
      <Sfx id="imprenta" en={m("facilisimo")} volumen={0.35} />
      <Sfx id="boing" en={m("facilisimo")} volumen={0.3} />
      <Sfx id="sello" en={m("permiso")} volumen={0.45} />
    </Escena>
  );
};
