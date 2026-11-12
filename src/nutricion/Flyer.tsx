/**
 * Imagen de contacto para el cliente "Alimentación y Equilibrio de Giovana Olivas" (Perú).
 * Pieza de cliente: sin Nyxar ni estilo AEZ. Logo redibujado en vector a partir de la foto que pasó el usuario.
 * Formato 1080×1350 (publicación de Instagram/Facebook y WhatsApp).
 */
import "@fontsource/lexend/300.css";
import "@fontsource/lexend/400.css";
import "@fontsource/lexend/600.css";
import "@fontsource/baloo-2/800.css";
import { AbsoluteFill, continueRender, delayRender, Img, staticFile } from "remotion";

if (typeof document !== "undefined") {
  const h = delayRender("Fuentes del flyer");
  Promise.all([
    document.fonts.load(`300 60px 'Lexend'`),
    document.fonts.load(`400 60px 'Lexend'`),
    document.fonts.load(`600 60px 'Lexend'`),
    document.fonts.load(`800 60px 'Baloo 2'`),
  ])
    .then(() => continueRender(h))
    .catch(() => continueRender(h));
}

/** Colores del logo (tonos sacados de la foto, aclarados porque la foto los oscurece). */
const L = {
  azul: "#2fb0cf",
  azulTexto: "#2a9db8",
  verde: "#8cc63e",
  verdeOsc: "#2f8a3c",
  banda: "#1d5d6e",
  texto: "#21414a",
  suave: "#5d7a80",
};
const LEX = "'Lexend', sans-serif";

/** Datos de contacto, copiados tal cual los pasó el usuario (solo se corrige "Whataspp" y se quita el espacio del usuario de Instagram). */
const DATOS = [
  { red: "TikTok", valor: "ayedegiovanaolivas" },
  { red: "Facebook", valor: "Alimentacion y Equilibrio" },
  { red: "Instagram", valor: "alimentacionyequilibrio" },
  { red: "Página web", valor: "alimentacionyequilibrio.com" },
  { red: "Teléfono", valor: "265-8680" },
  { red: "WhatsApp", valor: "990-103447" },
  { red: "Dirección", valor: "Brigadier Mateo Pumacahua N°2429, dpto. 302 Lince" },
];

/* ---------- Logo ---------- */

/**
 * Logo: el "19 años" y la figura se sacaron de la foto del logo separando sus colores (más fieles que redibujarlos);
 * el texto fino se escribe con Lexend Light porque en la foto sale roto.
 */
export const LogoAyE: React.FC<{ escala?: number }> = ({ escala = 1 }) => (
  <div style={{ display: "flex", flexDirection: "column", alignItems: "center" }}>
    <Img src={staticFile("nutricion/logo-19-anos.png")} style={{ height: 330 * escala }} />
    <div style={{ display: "flex", alignItems: "center", gap: 14 * escala, marginTop: 20 * escala }}>
      <div style={{ textAlign: "right", lineHeight: 0.95 }}>
        <div style={{ fontFamily: LEX, fontWeight: 300, fontSize: 70 * escala, color: L.azulTexto, letterSpacing: -1 }}>alimentación</div>
        <div style={{ fontFamily: LEX, fontWeight: 300, fontSize: 70 * escala, color: L.verde, letterSpacing: -1 }}>y equilibrio</div>
        <div style={{ fontFamily: LEX, fontWeight: 400, fontSize: 30 * escala, color: L.azulTexto, marginTop: 8 * escala }}>De Giovana Olivas</div>
      </div>
      <Img src={staticFile("nutricion/logo-figura.png")} style={{ height: 250 * escala, marginTop: -40 * escala }} />
    </div>
  </div>
);

/* ---------- Comida dibujada ---------- */

const Manzana: React.FC<{ t: number }> = ({ t }) => (
  <svg width={t} height={t} viewBox="0 0 100 100">
    <path d="M50 28 C30 14 8 26 10 52 C12 78 30 96 50 88 C70 96 88 78 90 52 C92 26 70 14 50 28 Z" fill="#e94b4b" />
    <path d="M50 28 C48 18 50 10 56 4" stroke="#6b4a2b" strokeWidth={5} fill="none" strokeLinecap="round" />
    <path d="M56 16 C66 6 80 8 84 14 C74 22 64 22 56 16 Z" fill={L.verde} />
    <path d="M24 44 C26 36 32 32 38 30" stroke="#ffffff" strokeOpacity={0.6} strokeWidth={5} fill="none" strokeLinecap="round" />
  </svg>
);

const Palta: React.FC<{ t: number }> = ({ t }) => (
  <svg width={t} height={t} viewBox="0 0 100 100">
    <path d="M50 4 C66 4 72 26 80 46 C90 72 74 96 50 96 C26 96 10 72 20 46 C28 26 34 4 50 4 Z" fill="#3f7d2e" />
    <path d="M50 12 C62 12 66 30 72 48 C80 70 68 88 50 88 C32 88 20 70 28 48 C34 30 38 12 50 12 Z" fill="#d6ea8a" />
    <circle cx={50} cy={62} r={16} fill="#8a5a2b" />
    <circle cx={45} cy={57} r={4} fill="#ffffff" opacity={0.4} />
  </svg>
);

const Zanahoria: React.FC<{ t: number }> = ({ t }) => (
  <svg width={t} height={t} viewBox="0 0 100 100">
    <path d="M30 30 C44 22 62 26 70 38 L34 94 C30 98 26 96 26 90 Z" fill="#ff8c2b" transform="rotate(-20 50 50)" />
    <path d="M40 40 L48 44 M36 56 L44 60 M33 72 L40 75" stroke="#d9661a" strokeWidth={4} strokeLinecap="round" transform="rotate(-20 50 50)" />
    <path d="M58 26 C56 12 62 4 66 2 C66 12 64 20 60 28 M62 30 C70 18 80 16 86 16 C80 24 72 30 64 32 M60 28 C64 16 72 8 78 6" stroke={L.verde} strokeWidth={6} fill="none" strokeLinecap="round" />
  </svg>
);

const Brocoli: React.FC<{ t: number }> = ({ t }) => (
  <svg width={t} height={t} viewBox="0 0 100 100">
    <path d="M42 56 L38 94 H62 L58 56 Z" fill="#9fd36b" />
    {[
      [30, 40, 18],
      [50, 30, 20],
      [70, 40, 18],
      [40, 52, 16],
      [60, 52, 16],
    ].map(([x, y, r], k) => (
      <circle key={k} cx={x} cy={y} r={r} fill={k % 2 ? "#3d9a3f" : L.verdeOsc} />
    ))}
    <circle cx={46} cy={24} r={5} fill="#ffffff" opacity={0.3} />
  </svg>
);

const Limon: React.FC<{ t: number }> = ({ t }) => (
  <svg width={t} height={t} viewBox="0 0 100 100">
    <circle cx={50} cy={50} r={42} fill="#f6d84a" />
    <circle cx={50} cy={50} r={34} fill="#fff6c2" />
    {new Array(8).fill(0).map((_, k) => {
      const a = (k * Math.PI) / 4;
      return <path key={k} d={`M50 50 L${50 + Math.cos(a) * 30} ${50 + Math.sin(a) * 30} A30 30 0 0 1 ${50 + Math.cos(a + Math.PI / 4) * 30} ${50 + Math.sin(a + Math.PI / 4) * 30} Z`} fill="#fbe36b" stroke="#fff6c2" strokeWidth={3} />;
    })}
  </svg>
);

const Fresa: React.FC<{ t: number }> = ({ t }) => (
  <svg width={t} height={t} viewBox="0 0 100 100">
    <path d="M50 92 C24 72 14 46 24 32 C34 20 66 20 76 32 C86 46 76 72 50 92 Z" fill="#e8344a" />
    {[
      [38, 42], [52, 40], [64, 46], [44, 56], [58, 58], [50, 72], [34, 54],
    ].map(([x, y], k) => (
      <ellipse key={k} cx={x} cy={y} rx={2} ry={3} fill="#ffe08a" />
    ))}
    <path d="M30 28 L42 22 L50 10 L58 22 L70 28 L58 32 L50 28 L42 32 Z" fill={L.verde} />
  </svg>
);

/** Hoja decorativa suave. */
const Hoja: React.FC<{ x: number; y: number; t: number; rot: number; color: string; op?: number }> = ({ x, y, t, rot, color, op = 0.18 }) => (
  <svg width={t} height={t} viewBox="0 0 100 100" style={{ position: "absolute", left: x, top: y, transform: `rotate(${rot}deg)`, opacity: op }}>
    <path d="M10 90 C10 40 40 10 90 10 C90 60 60 90 10 90 Z" fill={color} />
    <path d="M14 86 C40 60 60 40 86 14" stroke="#ffffff" strokeWidth={3} fill="none" />
  </svg>
);

/* ---------- Iconos de contacto (genéricos, con su etiqueta al lado) ---------- */

const IcoRed: React.FC<{ red: string }> = ({ red }) => {
  const color: Record<string, string> = {
    TikTok: "#111111",
    Facebook: "#1877f2",
    Instagram: "#d6249f",
    "Página web": L.azul,
    Teléfono: L.verdeOsc,
    WhatsApp: "#25d366",
    Dirección: "#e94b4b",
  };
  const glifo: Record<string, React.ReactNode> = {
    TikTok: <path d="M54 22 C56 32 62 38 72 40 V50 C64 50 58 47 54 44 V64 C54 74 46 82 36 82 C26 82 18 74 18 64 C18 54 26 46 36 46 V56 C31 56 28 60 28 64 C28 69 32 72 36 72 C41 72 44 68 44 64 V22 Z" fill="#fff" />,
    Facebook: <path d="M54 84 V54 H64 L66 42 H54 V35 C54 31 56 29 60 29 H66 V18 C64 18 60 17 56 17 C47 17 42 23 42 32 V42 H33 V54 H42 V84 Z" fill="#fff" />,
    Instagram: (
      <>
        <rect x={22} y={22} width={56} height={56} rx={16} fill="none" stroke="#fff" strokeWidth={7} />
        <circle cx={50} cy={50} r={13} fill="none" stroke="#fff" strokeWidth={7} />
        <circle cx={66} cy={34} r={4} fill="#fff" />
      </>
    ),
    "Página web": (
      <>
        <circle cx={50} cy={50} r={28} fill="none" stroke="#fff" strokeWidth={6} />
        <ellipse cx={50} cy={50} rx={12} ry={28} fill="none" stroke="#fff" strokeWidth={5} />
        <path d="M22 50 H78 M26 36 H74 M26 64 H74" stroke="#fff" strokeWidth={5} />
      </>
    ),
    Teléfono: <path d="M30 22 L40 20 L46 36 L39 42 C43 52 48 57 58 61 L64 54 L80 60 L78 70 C76 76 70 80 62 78 C42 72 28 58 22 38 C20 30 24 24 30 22 Z" fill="#fff" />,
    WhatsApp: (
      <>
        <path d="M50 18 C32 18 18 32 18 50 C18 56 20 62 23 67 L19 82 L35 78 C39 80 44 82 50 82 C68 82 82 68 82 50 C82 32 68 18 50 18 Z" fill="none" stroke="#fff" strokeWidth={6} />
        <path d="M40 36 L46 35 L49 43 L45 47 C47 52 50 55 55 57 L59 53 L66 56 L65 62 C63 65 59 66 55 65 C46 62 40 56 37 47 C36 42 37 38 40 36 Z" fill="#fff" />
      </>
    ),
    Dirección: (
      <>
        <path d="M50 86 C38 70 26 56 26 42 C26 28 37 18 50 18 C63 18 74 28 74 42 C74 56 62 70 50 86 Z" fill="#fff" />
        <circle cx={50} cy={42} r={10} fill={"#e94b4b"} />
      </>
    ),
  };
  const fondo = red === "Instagram" ? "linear-gradient(45deg, #f9a03f, #d6249f 55%, #6b3fd4)" : color[red];
  return (
    <div style={{ width: 66, height: 66, borderRadius: 20, background: fondo, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
      <svg width={52} height={52} viewBox="0 0 100 100">
        {glifo[red]}
      </svg>
    </div>
  );
};

/* ---------- Composición ---------- */

export const FlyerAyE: React.FC = () => (
  <AbsoluteFill style={{ background: "linear-gradient(180deg, #fbfdf6 0%, #eef8e6 60%, #e2f3ee 100%)", fontFamily: LEX, overflow: "hidden" }}>
    <Hoja x={-60} y={-40} t={260} rot={10} color={L.verde} />
    <Hoja x={870} y={-30} t={240} rot={100} color={L.azul} />
    <Hoja x={-70} y={560} t={200} rot={-30} color={L.azul} op={0.12} />
    <Hoja x={900} y={520} t={220} rot={150} color={L.verde} op={0.14} />
    <div style={{ position: "absolute", left: 0, right: 0, top: 22, display: "flex", justifyContent: "center" }}>
      <LogoAyE escala={0.86} />
    </div>
    {/* Fila de comida */}
    <div style={{ position: "absolute", left: 0, right: 0, top: 560, display: "flex", justifyContent: "center", alignItems: "flex-end", gap: 22 }}>
      <Brocoli t={112} />
      <Zanahoria t={116} />
      <Manzana t={130} />
      <Palta t={136} />
      <Fresa t={112} />
      <Limon t={106} />
    </div>
    {/* Tarjeta de contacto */}
    <div style={{ position: "absolute", left: 60, right: 60, top: 726, bottom: 46, background: "#ffffff", borderRadius: 40, boxShadow: "0 18px 40px rgba(33,65,74,0.12)", padding: "26px 40px", display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
      {DATOS.map((d) => (
        <div key={d.red} style={{ display: "flex", alignItems: "center", gap: 22 }}>
          <IcoRed red={d.red} />
          <div style={{ display: "flex", flexDirection: "column", minWidth: 0 }}>
            <div style={{ fontWeight: 400, fontSize: 22, color: L.suave, letterSpacing: 1, textTransform: "uppercase" }}>{d.red}</div>
            <div style={{ fontWeight: 600, fontSize: d.red === "Dirección" ? 27 : 32, color: L.texto, lineHeight: 1.15 }}>{d.valor}</div>
          </div>
        </div>
      ))}
    </div>
  </AbsoluteFill>
);
