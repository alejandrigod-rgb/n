/**
 * Iconos propios de AEZ: sustituyen a los emojis en los videos (petición del usuario).
 * Mismo estilo que Nyxar: relleno de color de la marca, contorno oscuro grueso y redondeado,
 * y un brillo blanco suave arriba a la izquierda.
 */
import { C } from "./tema";

const LINEA = "#1d1530";
const T = 7; // grosor del contorno (en un lienzo de 100×100)

type P = { tamano?: number; color?: string; style?: React.CSSProperties };

const Lienzo: React.FC<P & { children: React.ReactNode }> = ({ tamano = 80, style, children }) => (
  <svg width={tamano} height={tamano} viewBox="0 0 100 100" style={{ display: "inline-block", verticalAlign: "middle", overflow: "visible", ...style }}>
    <g strokeLinejoin="round" strokeLinecap="round">{children}</g>
  </svg>
);

const brillo = (d: string) => <path d={d} fill="none" stroke="#ffffff" strokeWidth={5} opacity={0.55} />;

/** Flecha de descarga sobre una bandeja. */
export const IcoDescarga: React.FC<P> = ({ color = C.menta, ...p }) => (
  <Lienzo {...p}>
    <path d="M38 10 H62 V44 H78 L50 74 L22 44 H38 Z" fill={color} stroke={LINEA} strokeWidth={T} />
    <path d="M12 70 V86 H88 V70" fill="none" stroke={LINEA} strokeWidth={T + 6} />
    <path d="M12 70 V86 H88 V70" fill="none" stroke={color} strokeWidth={T - 1} />
    {brillo("M44 18 V40")}
  </Lienzo>
);

/** Mando de consola. */
export const IcoMando: React.FC<P> = ({ color = C.cascabel, ...p }) => (
  <Lienzo {...p}>
    <path d="M24 30 H76 C90 30 96 52 94 68 C92 82 80 84 72 72 L64 62 H36 L28 72 C20 84 8 82 6 68 C4 52 10 30 24 30 Z" fill={color} stroke={LINEA} strokeWidth={T} />
    <path d="M24 44 V56 M18 50 H30" stroke={LINEA} strokeWidth={6} />
    <circle cx={70} cy={45} r={5} fill={LINEA} />
    <circle cx={80} cy={55} r={5} fill={LINEA} />
    {brillo("M22 36 H40")}
  </Lienzo>
);

/** Candado cerrado. */
export const IcoCandado: React.FC<P> = ({ color = C.cascabel, ...p }) => (
  <Lienzo {...p}>
    <path d="M30 46 V32 a20 20 0 0 1 40 0 V46" fill="none" stroke={LINEA} strokeWidth={T + 8} />
    <path d="M30 46 V32 a20 20 0 0 1 40 0 V46" fill="none" stroke={color} strokeWidth={T} />
    <rect x={16} y={44} width={68} height={48} rx={12} fill={color} stroke={LINEA} strokeWidth={T} />
    <circle cx={50} cy={64} r={7} fill={LINEA} />
    <path d="M50 66 V78" stroke={LINEA} strokeWidth={7} />
    {brillo("M24 54 V64")}
  </Lienzo>
);

/** Estrella redondeada (reseñas, favorito). */
export const IcoEstrella: React.FC<P> = ({ color = C.cascabel, ...p }) => (
  <Lienzo {...p}>
    <path d="M50 8 L62 36 L92 38 L69 58 L77 88 L50 72 L23 88 L31 58 L8 38 L38 36 Z" fill={color} stroke={LINEA} strokeWidth={T} />
    {brillo("M44 30 L48 22")}
  </Lienzo>
);

/** Huella de gato (la de Nyxar). */
export const IcoHuella: React.FC<P> = ({ color = C.pelaje, ...p }) => (
  <Lienzo {...p}>
    <path d="M50 52 C66 52 80 66 78 78 C76 90 62 86 50 86 C38 86 24 90 22 78 C20 66 34 52 50 52 Z" fill={color} stroke={LINEA} strokeWidth={T} />
    {[
      [22, 40],
      [40, 22],
      [60, 22],
      [78, 40],
    ].map(([x, y], k) => (
      <ellipse key={k} cx={x} cy={y} rx={10} ry={13} fill={color} stroke={LINEA} strokeWidth={T - 1} transform={`rotate(${[-25, -8, 8, 25][k]} ${x} ${y})`} />
    ))}
    {brillo("M38 62 C42 58 46 57 50 57")}
  </Lienzo>
);

/** Visto bueno: círculo con check. */
export const IcoBien: React.FC<P> = ({ color = C.menta, ...p }) => (
  <Lienzo {...p}>
    <circle cx={50} cy={50} r={40} fill={color} stroke={LINEA} strokeWidth={T} />
    <path d="M30 52 L44 66 L72 36" fill="none" stroke={LINEA} strokeWidth={11} />
    {brillo("M24 40 C27 30 34 22 44 18")}
  </Lienzo>
);

/** Error: círculo con aspa. */
export const IcoMal: React.FC<P> = ({ color = C.panuelo, ...p }) => (
  <Lienzo {...p}>
    <circle cx={50} cy={50} r={40} fill={color} stroke={LINEA} strokeWidth={T} />
    <path d="M34 34 L66 66 M66 34 L34 66" stroke={C.hueso} strokeWidth={11} />
    {brillo("M24 40 C27 30 34 22 44 18")}
  </Lienzo>
);

/** Bombilla (luz, idea). */
export const IcoBombilla: React.FC<P> = ({ color = C.cascabel, ...p }) => (
  <Lienzo {...p}>
    <path d="M50 8 C72 8 84 26 80 44 C78 54 68 60 66 70 H34 C32 60 22 54 20 44 C16 26 28 8 50 8 Z" fill={color} stroke={LINEA} strokeWidth={T} />
    <rect x={34} y={70} width={32} height={18} rx={6} fill={C.niebla} stroke={LINEA} strokeWidth={T} />
    <path d="M40 92 H60" stroke={LINEA} strokeWidth={T} />
    <path d="M42 50 L50 40 L58 50" fill="none" stroke={LINEA} strokeWidth={5} />
    {brillo("M30 30 C32 22 38 17 46 16")}
  </Lienzo>
);

/** Moqueta / esponja húmeda (gotas sobre un bloque). */
export const IcoMoqueta: React.FC<P> = ({ color = C.cascabel, ...p }) => (
  <Lienzo {...p}>
    <rect x={10} y={50} width={80} height={36} rx={10} fill={color} stroke={LINEA} strokeWidth={T} />
    {[24, 42, 60, 76].map((x) => (
      <circle key={x} cx={x} cy={68} r={4} fill={LINEA} opacity={0.5} />
    ))}
    <path d="M34 14 C40 24 44 30 44 36 a10 10 0 0 1 -20 0 C24 30 28 24 34 14 Z" fill={C.azul} stroke={LINEA} strokeWidth={T - 1} />
    <path d="M66 22 C70 30 72 34 72 38 a7 7 0 0 1 -14 0 C58 34 62 30 66 22 Z" fill={C.azul} stroke={LINEA} strokeWidth={T - 1} />
  </Lienzo>
);

/** Infinito (salas que no acaban). */
export const IcoInfinito: React.FC<P> = ({ color = C.menta, ...p }) => (
  <Lienzo {...p}>
    <path d="M50 50 C40 34 14 30 12 50 C14 70 40 66 50 50 C60 34 86 30 88 50 C86 70 60 66 50 50 Z" fill="none" stroke={LINEA} strokeWidth={T + 10} />
    <path d="M50 50 C40 34 14 30 12 50 C14 70 40 66 50 50 C60 34 86 30 88 50 C86 70 60 66 50 50 Z" fill="none" stroke={color} strokeWidth={T + 1} />
  </Lienzo>
);


/** Sol (de día). */
export const IcoSol: React.FC<P> = ({ color = C.cascabel, ...p }) => (
  <Lienzo {...p}>
    {new Array(8).fill(0).map((_, k) => {
      const a = (k * Math.PI) / 4;
      return <path key={k} d={`M${50 + Math.cos(a) * 34} ${50 + Math.sin(a) * 34} L${50 + Math.cos(a) * 46} ${50 + Math.sin(a) * 46}`} stroke={LINEA} strokeWidth={T + 6} />;
    })}
    {new Array(8).fill(0).map((_, k) => {
      const a = (k * Math.PI) / 4;
      return <path key={`c${k}`} d={`M${50 + Math.cos(a) * 34} ${50 + Math.sin(a) * 34} L${50 + Math.cos(a) * 46} ${50 + Math.sin(a) * 46}`} stroke={color} strokeWidth={T - 1} />;
    })}
    <circle cx={50} cy={50} r={24} fill={color} stroke={LINEA} strokeWidth={T} />
    {brillo("M38 42 C40 36 44 33 49 32")}
  </Lienzo>
);

/** Luna (de noche). */
export const IcoLuna: React.FC<P> = ({ color = C.azul, ...p }) => (
  <Lienzo {...p}>
    <path d="M62 10 C40 14 26 32 28 54 C30 76 50 92 72 88 C82 86 88 80 92 74 C70 78 50 64 48 42 C46 28 52 16 62 10 Z" fill={color} stroke={LINEA} strokeWidth={T} />
    <circle cx={74} cy={26} r={4} fill={C.hueso} />
    <circle cx={86} cy={46} r={3} fill={C.hueso} />
  </Lienzo>
);

/** Hacker con capucha (genérico, sin cara). */
export const IcoCapucha: React.FC<P> = ({ color = "#2b2f45", ...p }) => (
  <Lienzo {...p}>
    <path d="M50 6 C74 6 86 26 84 50 L92 94 H8 L16 50 C14 26 26 6 50 6 Z" fill={color} stroke={LINEA} strokeWidth={T} />
    <path d="M50 22 C64 22 70 34 70 48 C70 62 62 70 50 70 C38 70 30 62 30 48 C30 34 36 22 50 22 Z" fill="#0b0d16" stroke={LINEA} strokeWidth={T - 2} />
    <ellipse cx={41} cy={48} rx={4} ry={3} fill={C.menta} />
    <ellipse cx={59} cy={48} rx={4} ry={3} fill={C.menta} />
    {brillo("M26 34 C30 22 38 15 48 13")}
  </Lienzo>
);

/** Trofeo (premios). */
export const IcoTrofeo: React.FC<P> = ({ color = C.cascabel, ...p }) => (
  <Lienzo {...p}>
    <path d="M28 18 H12 V28 C12 40 20 46 30 46 M72 18 H88 V28 C88 40 80 46 70 46" fill="none" stroke={LINEA} strokeWidth={T + 6} />
    <path d="M28 18 H12 V28 C12 40 20 46 30 46 M72 18 H88 V28 C88 40 80 46 70 46" fill="none" stroke={color} strokeWidth={T - 2} />
    <path d="M26 10 H74 V36 C74 52 64 62 50 62 C36 62 26 52 26 36 Z" fill={color} stroke={LINEA} strokeWidth={T} />
    <path d="M44 62 H56 V74 H44 Z" fill={color} stroke={LINEA} strokeWidth={T - 1} />
    <rect x={28} y={74} width={44} height={16} rx={5} fill={C.niebla} stroke={LINEA} strokeWidth={T} />
    {brillo("M34 18 V36")}
  </Lienzo>
);

/** Rascacielos (gran empresa). */
export const IcoEdificio: React.FC<P> = ({ color = C.niebla, ...p }) => (
  <Lienzo {...p}>
    <path d="M28 94 V18 L50 6 L72 18 V94 Z" fill={color} stroke={LINEA} strokeWidth={T} />
    {[24, 38, 52, 66].map((y) => (
      <g key={y}>
        <rect x={36} y={y} width={10} height={8} rx={2} fill={LINEA} opacity={0.6} />
        <rect x={54} y={y} width={10} height={8} rx={2} fill={LINEA} opacity={0.6} />
      </g>
    ))}
    <rect x={43} y={80} width={14} height={14} rx={2} fill={LINEA} />
    {brillo("M33 26 V60")}
  </Lienzo>
);

/** Terminal (código). */
export const IcoTerminal: React.FC<P> = ({ color = "#16244a", ...p }) => (
  <Lienzo {...p}>
    <rect x={6} y={14} width={88} height={72} rx={12} fill={color} stroke={LINEA} strokeWidth={T} />
    <path d="M6 30 H94" stroke={LINEA} strokeWidth={T - 2} />
    <path d="M22 46 L34 56 L22 66" fill="none" stroke={C.menta} strokeWidth={7} />
    <path d="M42 68 H64" stroke={C.menta} strokeWidth={7} />
  </Lienzo>
);


/** Cerebro. */
export const IcoCerebro: React.FC<P> = ({ color = "#ff8da1", ...p }) => (
  <Lienzo {...p}>
    <path d="M50 16 C42 8 26 10 22 22 C10 24 6 38 12 46 C4 54 8 70 20 72 C22 84 36 90 46 84 L50 82 L54 84 C64 90 78 84 80 72 C92 70 96 54 88 46 C94 38 90 24 78 22 C74 10 58 8 50 16 Z" fill={color} stroke={LINEA} strokeWidth={T} />
    <path d="M50 18 V82" stroke={LINEA} strokeWidth={5} />
    <path d="M30 34 C36 38 36 46 30 50 M70 34 C64 38 64 46 70 50 M28 62 C34 60 40 64 40 70 M72 62 C66 60 60 64 60 70" fill="none" stroke={LINEA} strokeWidth={4.5} />
    {brillo("M26 26 C30 20 36 17 42 17")}
  </Lienzo>
);

/** Persona (silueta redondeada). */
export const IcoPersona: React.FC<P> = ({ color = C.azul, ...p }) => (
  <Lienzo {...p}>
    <circle cx={50} cy={30} r={18} fill={color} stroke={LINEA} strokeWidth={T} />
    <path d="M16 92 C16 64 30 54 50 54 C70 54 84 64 84 92 Z" fill={color} stroke={LINEA} strokeWidth={T} />
    {brillo("M40 22 C42 18 46 16 50 16")}
  </Lienzo>
);

/** Corazón (agridulce: con una grieta opcional). */
export const IcoCorazon: React.FC<P & { roto?: boolean }> = ({ color = C.panuelo, roto, ...p }) => (
  <Lienzo {...p}>
    <path d="M50 88 C20 66 8 50 10 32 C12 16 32 8 50 26 C68 8 88 16 90 32 C92 50 80 66 50 88 Z" fill={color} stroke={LINEA} strokeWidth={T} />
    {roto ? <path d="M50 26 L42 44 L56 54 L46 70 L50 88" fill="none" stroke={LINEA} strokeWidth={6} /> : null}
    {brillo("M22 30 C24 22 30 18 36 18")}
  </Lienzo>
);

/** Casete. */
export const IcoCasete: React.FC<P> = ({ color = C.cascabel, ...p }) => (
  <Lienzo {...p}>
    <rect x={6} y={20} width={88} height={60} rx={8} fill={color} stroke={LINEA} strokeWidth={T} />
    <rect x={20} y={32} width={60} height={24} rx={6} fill={C.hueso} stroke={LINEA} strokeWidth={4} />
    <circle cx={36} cy={44} r={7} fill={LINEA} />
    <circle cx={64} cy={44} r={7} fill={LINEA} />
    <path d="M24 80 L30 66 H70 L76 80" fill="none" stroke={LINEA} strokeWidth={5} />
  </Lienzo>
);

/** Todos los iconos, para la hoja de marca. */
export const ICONOS = {
  descarga: IcoDescarga,
  mando: IcoMando,
  candado: IcoCandado,
  estrella: IcoEstrella,
  huella: IcoHuella,
  bien: IcoBien,
  mal: IcoMal,
  bombilla: IcoBombilla,
  moqueta: IcoMoqueta,
  infinito: IcoInfinito,
  sol: IcoSol,
  luna: IcoLuna,
  capucha: IcoCapucha,
  trofeo: IcoTrofeo,
  edificio: IcoEdificio,
  terminal: IcoTerminal,
  cerebro: IcoCerebro,
  persona: IcoPersona,
  corazon: IcoCorazon,
  casete: IcoCasete,
};
