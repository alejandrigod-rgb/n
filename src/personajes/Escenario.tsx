/**
 * Escenario de Nyxar: en cada tramo del video aparece en un sitio distinto de la pantalla
 * vertical (1080×1920). Entra deslizándose desde fuera, y antes del siguiente tramo sale
 * por su lado para reaparecer en otro. A la derecha se gira para mirar al centro.
 */
import { interpolate, spring, useCurrentFrame } from "remotion";

export type Lado = "izquierda" | "derecha" | "centro" | "asomadoIzquierda" | "asomadoDerecha";

type Sitio = { x: number; y: number; ancho: number; giro: number; espejo: boolean; desdeX: number; desdeY: number };

/** Sitios pensados para dejar libres las zonas que tapa TikTok (abajo y botones de la derecha). */
export const SITIOS: Record<Lado, Sitio> = {
  izquierda: { x: 30, y: 1130, ancho: 470, giro: 0, espejo: false, desdeX: -600, desdeY: 0 },
  derecha: { x: 440, y: 1130, ancho: 470, giro: 0, espejo: true, desdeX: 700, desdeY: 0 },
  centro: { x: 300, y: 1150, ancho: 480, giro: 0, espejo: false, desdeX: 0, desdeY: 800 },
  asomadoIzquierda: { x: -230, y: 1020, ancho: 680, giro: 14, espejo: false, desdeX: -500, desdeY: 0 },
  asomadoDerecha: { x: 640, y: 250, ancho: 600, giro: -16, espejo: true, desdeX: 600, desdeY: 0 },
};

export type Tramo = { inicio: number; fin: number; lado: Lado };

const SALIDA = 10;

export const Escenario: React.FC<{ tramos: Tramo[]; fps: number; children: (ancho: number) => React.ReactNode }> = ({
  tramos,
  fps,
  children,
}) => {
  const frame = useCurrentFrame();
  let i = 0;
  for (let k = 0; k < tramos.length; k++) if (frame >= tramos[k].inicio) i = k;
  const t = tramos[i];
  const s = SITIOS[t.lado];
  const entra = spring({ frame: frame - t.inicio, fps, config: { damping: 14, mass: 0.8 } });
  const esUltimo = i === tramos.length - 1;
  const sale = esUltimo ? 0 : interpolate(frame, [t.fin - SALIDA, t.fin], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const fuera = Math.max(1 - entra, sale);
  const x = s.x + s.desdeX * fuera;
  const y = s.y + s.desdeY * fuera;
  return (
    <div
      style={{
        position: "absolute",
        left: x,
        top: y,
        width: s.ancho,
        transform: `rotate(${s.giro}deg) scaleX(${s.espejo ? -1 : 1})`,
        transformOrigin: "50% 100%",
      }}
    >
      {children(s.ancho)}
    </div>
  );
};
