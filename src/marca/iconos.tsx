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
};
