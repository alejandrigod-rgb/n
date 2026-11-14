/**
 * AEZ · "Tu sartén arde: nunca le eches agua". Formato "Qué hacer si…" en versión inmersiva (14 de noviembre de 2026):
 * una cocina con cámara viva, Nyxar en los planos generales y su pata en los primeros planos, rebobinado y
 * una foto real a pantalla completa en el "¡bum!" (dominio público). Las tomas están en `tomas.tsx`.
 * Datos: bomberos de Cambridge y de Mamaroneck, y extensión de la Universidad de Illinois.
 */
import { linearTiming, TransitionSeries } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { AbsoluteFill, Html5Audio, interpolate, staticFile, useCurrentFrame } from "remotion";
import { Borde, Filtros, Grano } from "./acuarela/piel";
import { C, CLAMP } from "../marca/tema";
import { CARPETA, IDS, LINEA, TRANSICION } from "./linea";
import { TOMAS } from "./tomas";

const INICIO_TAPA = LINEA.inicios[IDS.indexOf("tapa")];
const F_TAPADA = (() => {
  try {
    return INICIO_TAPA + LINEA.marcas("tapa")("tapa") + 30;
  } catch {
    return INICIO_TAPA + 120;
  }
})();
const INICIO_BOLA = LINEA.inicios[IDS.indexOf("bola")];

export const DURACION_SARTEN = LINEA.total;

/** Los filtros de la acuarela «hierven» 10 veces por segundo (cada 6 fotogramas, en un ciclo de 10). */
const FiltrosVivos: React.FC = () => {
  const f = useCurrentFrame();
  return <Filtros paso={Math.floor(f / 6) % 10} />;
};

export const SartenArde: React.FC = () => (
  <AbsoluteFill style={{ background: C.abismo }}>
    <FiltrosVivos />
    <TransitionSeries>
      {IDS.flatMap((id, i) => {
        const Comp = TOMAS[i];
        const items = [
          <TransitionSeries.Sequence key={id} durationInFrames={LINEA.duraciones[i]}>
            <Comp />
          </TransitionSeries.Sequence>,
        ];
        if (i < IDS.length - 1) items.push(<TransitionSeries.Transition key={`${id}-t`} presentation={fade()} timing={linearTiming({ durationInFrames: TRANSICION })} />);
        return items;
      })}
    </TransitionSeries>
    {/* el grano del papel y el borde rasgado de la hoja, encima de todo */}
    <Grano />
    <Borde />
    <Html5Audio loop loopVolumeCurveBehavior="extend" src={staticFile(`${CARPETA}/sfx-musica.mp3`)} volume={(f) => interpolate(f, [0, 30, LINEA.total - 60, LINEA.total], [0.05, 0.06, 0.07, 0], CLAMP)} />
    {/* el fuego crepita hasta que se tapa la sartén (más fuerte en el "¡bum!") */}
    <Html5Audio loop src={staticFile(`${CARPETA}/sfx-fuego.mp3`)} volume={(f) => interpolate(f, [F_TAPADA, F_TAPADA + 30], [1, 0], CLAMP) * (f >= INICIO_BOLA && f < INICIO_TAPA ? 0.22 : 0.13)} />
  </AbsoluteFill>
);
