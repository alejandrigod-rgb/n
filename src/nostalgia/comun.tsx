import { AbsoluteFill, Html5Audio, Sequence, staticFile } from "remotion";
import { Plano, Sfx, Subtitulos, Titulo } from "../marca/kit";
import { CARPETA, IdEscena, IDS, LINEA, TIEMPOS } from "./linea";

/** Escena de la marca: título, gráfico con zoom lento y golpes, subtítulos y voz. */
export const Escena: React.FC<{
  id: IdEscena;
  etiqueta: string;
  titulo: string;
  claves: string[];
  golpes?: number[];
  sinEntrada?: boolean;
  children: React.ReactNode;
}> = ({ id, etiqueta, titulo, claves, golpes = [], sinEntrada, children }) => {
  const dur = LINEA.duraciones[IDS.indexOf(id)];
  const pre = LINEA.preDe(id);
  return (
    <AbsoluteFill>
      <Plano dur={dur} golpes={golpes}>
        <div
          style={{
            position: "absolute",
            top: 500,
            left: 0,
            right: 0,
            height: 620,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          {children}
        </div>
      </Plano>
      <Titulo etiqueta={etiqueta} titulo={titulo} sinEntrada={sinEntrada} />
      <Subtitulos palabras={TIEMPOS.voz[id].palabras} pre={pre} claves={claves} />
      <Sequence from={pre} layout="none">
        <Html5Audio src={staticFile(`${CARPETA}/voz-${id}.mp3`)} volume={1} />
      </Sequence>
      {!sinEntrada ? <Sfx carpeta={CARPETA} id="whoosh" en={0} volumen={0.2} /> : null}
    </AbsoluteFill>
  );
};

export const S: React.FC<{ id: string; en: number; volumen?: number; dur?: number }> = (p) => <Sfx carpeta={CARPETA} {...p} />;
