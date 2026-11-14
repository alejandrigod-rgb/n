import React from "react";
import { Img, interpolate, staticFile, useCurrentFrame, useVideoConfig } from "remotion";
import { IcoBien, IcoHuella, IcoMal } from "../marca/iconos";
import { Pop, Rafaga, Respira, useSeg } from "../marca/kit";
import { C, CLAMP, F } from "../marca/tema";
import { Escena, S } from "./comun";
import { Bote, Corte, Sarten, Vaso } from "./dibujos";
import { CARPETA, IdEscena, LINEA } from "./linea";

/** Marca de una palabra con valor de reserva (por si Whisper la partió distinto). */
const mk = (id: IdEscena) => (w: string, def = 0) => {
  try {
    return LINEA.marcas(id)(w);
  } catch {
    return def;
  }
};

const Chip: React.FC<{ texto: string; color?: string; tamano?: number; icono?: React.ReactNode }> = ({ texto, color = C.menta, tamano = 44, icono }) => (
  <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: tamano, color: C.abismo, background: color, padding: "8px 26px 2px", borderRadius: 999, whiteSpace: "nowrap", display: "inline-flex", alignItems: "center", gap: 14, boxShadow: `0 0 30px ${color}88` }}>
    {icono}
    {texto}
  </div>
);

/** Foto real de Openverse en grande, con marco y zoom lento (Nyxar va delante, en su escenario). */
const FotoReal: React.FC<{ src: string; desde: number; etiqueta?: string }> = ({ src, desde, etiqueta = "FOTO REAL" }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const t = (frame - desde) / fps;
  return (
    <Pop desde={desde} giro={-3}>
      <div style={{ position: "relative", width: 940, height: 620, borderRadius: 28, overflow: "hidden", border: `8px solid ${C.hueso}`, boxShadow: `0 0 60px ${C.cascabel}66` }}>
        <Img src={staticFile(`${CARPETA}/${src}`)} style={{ width: "100%", height: "100%", objectFit: "cover", transform: `scale(${1.05 + t * 0.04})` }} />
        <div style={{ position: "absolute", left: 22, top: 20 }}>
          <Chip texto={etiqueta} color={C.cascabel} tamano={34} />
        </div>
      </div>
    </Pop>
  );
};

/* 1 · GANCHO: la sartén ardiendo y "NUNCA AGUA" desde el fotograma 0 */
export const Gancho: React.FC = () => {
  const m = mk("gancho");
  const s = useSeg();
  return (
    <Escena id="gancho" etiqueta="QUÉ HACER SI…" titulo="Tu sartén arde" claves={["fuego"]} golpes={[0, m("fuego", 40)]} sinEntrada>
      <div style={{ position: "relative", transform: "translate(110px, 40px)" }}>
        <Sarten s={s} llamas={1} ancho={720} />
        <div style={{ position: "absolute", left: 230, top: -110, transform: `rotate(-6deg) scale(${1 + 0.04 * Math.sin(s * 6)})` }}>
          <Chip texto="NUNCA AGUA" color={C.panuelo} tamano={64} icono={<IcoMal tamano={60} color={C.abismo} />} />
        </div>
      </div>
      <S id="golpe" en={0} volumen={0.5} />
      <S id="cascabel" en={2} volumen={0.4} />
      <S id="fuego" en={0} volumen={0.35} dur={4} />
    </Escena>
  );
};

/* 2 · EL INSTINTO: el vaso de agua se acerca… y la X roja */
export const Instinto: React.FC = () => {
  const m = mk("instinto");
  const s = useSeg();
  const frame = useCurrentFrame();
  const no = m("no", 120);
  const giro = interpolate(frame, [m("agua", 40), m("agua", 40) + 20], [0, -38], CLAMP);
  return (
    <Escena id="instinto" etiqueta="EL ERROR" titulo="Tu instinto: agua" claves={["agua", "no"]} golpes={[m("agua", 40), no]}>
      <div style={{ position: "relative", width: 900, height: 600, transform: "translateX(-60px)" }}>
        <div style={{ position: "absolute", left: 60, top: 160 }}>
          <Sarten s={s} llamas={1} ancho={620} />
        </div>
        <Pop desde={m("agua", 40) - 6} style={{ position: "absolute", left: 600, top: 0 }}>
          <Vaso giro={giro} tamano={200} />
        </Pop>
        {frame >= no ? (
          <Pop desde={no} style={{ position: "absolute", left: 280, top: 60 }}>
            <IcoMal tamano={360} />
          </Pop>
        ) : null}
      </div>
      <S id="pop" en={m("agua", 40) - 6} volumen={0.3} />
      <S id="error" en={no} volumen={0.4} />
    </Escena>
  );
};

/* 3 · SE HUNDE: corte de la sartén, las gotas bajan hasta el fondo */
export const Hunde: React.FC = () => {
  const m = mk("hunde");
  const s = useSeg();
  const frame = useCurrentFrame();
  const g = interpolate(frame, [m("pesa", 30), m("fondo", 120) + 10], [0, 1], CLAMP);
  return (
    <Escena id="hunde" etiqueta="1 · EL PORQUÉ" titulo="El agua se hunde" claves={["pesa", "fondo"]} golpes={[m("fondo", 120)]}>
      <div style={{ position: "relative", transform: "translate(60px, 30px) scale(0.92)" }}>
        <Corte s={s} gotas={g} vapor={0} llamas={0.55} />
        <Pop desde={m("aceite", 50)} style={{ position: "absolute", left: 300, top: 300 }}>
          <Chip texto="ACEITE" color={C.cascabel} tamano={40} />
        </Pop>
        <Pop desde={m("agua", 10)} style={{ position: "absolute", left: 620, top: 40 }}>
          <Chip texto="AGUA" color="#7fc8ff" tamano={40} />
        </Pop>
      </div>
      <S id="tic" en={m("pesa", 30)} volumen={0.3} />
      <S id="pop" en={m("fondo", 120)} volumen={0.3} />
    </Escena>
  );
};

/* 4 · HIERVE DE GOLPE: el vapor crece en el fondo */
export const Hierve: React.FC = () => {
  const m = mk("hierve");
  const s = useSeg();
  const frame = useCurrentFrame();
  const v = interpolate(frame, [m("golpe", 90) - 6, m("golpe", 90) + 30], [0, 1], CLAMP);
  return (
    <Escena id="hierve" etiqueta="2 · EL PORQUÉ" titulo="Hierve de golpe" claves={["grados", "golpe"]} golpes={[m("grados", 40), m("golpe", 90)]}>
      <div style={{ position: "relative", transform: "translate(-60px, 30px) scale(0.92)" }}>
        <Corte s={s} gotas={1} vapor={v} llamas={0.7 + v * 0.3} />
        <Pop desde={m("grados", 40)} style={{ position: "absolute", left: 560, top: -40 }}>
          <Chip texto="CIENTOS DE °C" color={C.panuelo} tamano={46} />
        </Pop>
      </div>
      <S id="tic" en={m("grados", 40)} volumen={0.3} />
      <S id="subida" en={m("golpe", 90) - 6} volumen={0.35} />
    </Escena>
  );
};

/* 5 · LA BOLA DE FUEGO: fotos reales de demostraciones (dominio público), Nyxar delante */
export const Bola: React.FC = () => {
  const m = mk("bola");
  const frame = useCurrentFrame();
  const fuego = m("fuego", 200);
  return (
    <Escena id="bola" etiqueta="ASÍ DE REAL" titulo="Una bola de fuego" claves={["vapor", "fuego"]} golpes={[m("disparada", 60), fuego]}>
      <div style={{ transform: "translateY(-40px)" }}>{frame < fuego ? <FotoReal src="img-99ec5f66.jpg" desde={0} etiqueta="DEMOSTRACIÓN REAL" /> : <FotoReal src="img-958efea7.jpg" desde={fuego} etiqueta="AGUA + ACEITE" />}</div>
      <Rafaga en={fuego} color={C.cascabel} tamano={900} />
      <S id="fogonazo" en={m("disparada", 60)} volumen={0.5} />
      <S id="golpe" en={fuego} volumen={0.5} />
      <S id="fogonazo" en={fuego} volumen={0.4} />
    </Escena>
  );
};

/* 6 · LO QUE SÍ FUNCIONA: apagar el fuego y tapar con metal */
export const Tapa: React.FC = () => {
  const m = mk("tapa");
  const s = useSeg();
  const frame = useCurrentFrame();
  const tapa = interpolate(frame, [m("tapa", 80) - 4, m("tapa", 80) + 18], [0, 1], { ...CLAMP, easing: (x) => 1 - (1 - x) ** 3 });
  const llamas = interpolate(frame, [m("tapa", 80) + 14, m("tapa", 80) + 40], [1, 0], CLAMP);
  return (
    <Escena id="tapa" etiqueta="LO QUE SÍ FUNCIONA" titulo="Apaga y tapa" claves={["apaga", "metal"]} golpes={[m("apaga", 40), m("tapa", 80)]}>
      <div style={{ position: "relative", transform: "translate(0px, 40px)" }}>
        <Sarten s={s} llamas={llamas} tapa={tapa} humo={1 - llamas} ancho={700} />
        <Pop desde={m("apaga", 40)} style={{ position: "absolute", left: -10, top: -120 }}>
          <Chip texto="1 · APAGA EL FUEGO" tamano={44} />
        </Pop>
        <Pop desde={m("metal", 120)} style={{ position: "absolute", left: 260, top: -40 }}>
          <Chip texto="2 · TAPA DE METAL" tamano={44} icono={<IcoBien tamano={46} color={C.hueso} />} />
        </Pop>
      </div>
      <S id="clic" en={m("apaga", 40)} volumen={0.4} />
      <S id="golpe" en={m("tapa", 80) + 16} volumen={0.4} />
      <S id="brillo" en={m("metal", 120)} volumen={0.3} />
    </Escena>
  );
};

/* 7 · SIN AIRE: la llama se ahoga; no moverla ni llevarla al fregadero */
export const Aire: React.FC = () => {
  const m = mk("aire");
  const s = useSeg();
  return (
    <Escena id="aire" etiqueta="OJO" titulo="Ni la muevas" claves={["ahoga", "muevas"]} golpes={[m("muevas", 80), m("fregadero", 130)]}>
      <div style={{ position: "relative", transform: "translate(80px, 50px)" }}>
        <Sarten s={s} llamas={0} tapa={1} humo={0.6} ancho={620} />
        <Pop desde={m("muevas", 80)} style={{ position: "absolute", left: -40, top: -150 }}>
          <Chip texto="NO LA MUEVAS" color={C.panuelo} tamano={46} icono={<IcoMal tamano={48} color={C.abismo} />} />
        </Pop>
        <Pop desde={m("fregadero", 130)} style={{ position: "absolute", left: 120, top: -50 }}>
          <Chip texto="NI AL FREGADERO" color={C.panuelo} tamano={46} icono={<IcoMal tamano={48} color={C.abismo} />} />
        </Pop>
      </div>
      <S id="error" en={m("muevas", 80)} volumen={0.3} />
      <S id="error" en={m("fregadero", 130)} volumen={0.3} />
    </Escena>
  );
};

/* 8 · BICARBONATO SÍ, HARINA NO */
export const Bicarbonato: React.FC = () => {
  const m = mk("bicarbonato");
  return (
    <Escena id="bicarbonato" etiqueta="SI ES PEQUEÑO" titulo="Bicarbonato sí" claves={["bicarbonato", "harina"]} golpes={[m("bicarbonato", 30), m("harina", 90)]}>
      <div style={{ display: "flex", gap: 90, transform: "translate(-70px, 20px)" }}>
        {[
          { t: "BICARBONATO", c: "#2f8a64", w: "bicarbonato", ok: true },
          { t: "HARINA", c: C.panuelo, w: "harina", ok: false },
        ].map((b, k) => (
          <Pop key={b.t} desde={m(b.w, 30 + k * 60)} giro={k ? 6 : -6}>
            <Respira fase={k * 1.3} amp={0.04}>
              <div style={{ position: "relative" }}>
                <Bote texto={b.t} color={b.c} tamano={250} />
                <div style={{ position: "absolute", right: -40, top: -30 }}>{b.ok ? <IcoBien tamano={130} /> : <IcoMal tamano={130} />}</div>
              </div>
            </Respira>
          </Pop>
        ))}
      </div>
      <S id="exito" en={m("bicarbonato", 30)} volumen={0.3} />
      <S id="error" en={m("harina", 90)} volumen={0.35} />
    </Escena>
  );
};

/* 9 · PREGUNTA que divide + firma */
export const Pregunta: React.FC = () => {
  const m = mk("pregunta");
  const { fps } = useVideoConfig();
  const firma = m("casa", 150) + Math.round(fps * 0.5);
  return (
    <Escena id="pregunta" etiqueta="¿Y TÚ?" titulo="¿Le habrías echado agua?" claves={["agua", "casa"]} golpes={[m("agua", 40)]}>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 44, transform: "translateX(-60px)" }}>
        <div style={{ display: "flex", gap: 34 }}>
          {[
            { t: "SÍ, AGUA", i: <IcoMal tamano={84} color={C.abismo} />, c: C.panuelo, txt: C.hueso },
            { t: "NI DE BROMA", i: <IcoBien tamano={84} color={C.hueso} />, c: C.menta, txt: C.abismo },
          ].map((b, k) => (
            <Pop key={b.t} desde={m("agua", 40) + k * 8} giro={k ? 8 : -8}>
              <Respira fase={k * 1.5} amp={0.05}>
                <div style={{ width: 300, height: 220, borderRadius: 40, background: b.c, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 8, fontFamily: F.titulo, fontWeight: 800, fontSize: 48, lineHeight: 1, textAlign: "center", color: b.txt }}>
                  {b.i}
                  {b.t}
                </div>
              </Respira>
            </Pop>
          ))}
        </div>
        <Pop desde={firma}>
          <div style={{ display: "flex", alignItems: "center", gap: 16, fontFamily: F.cifra, fontWeight: 700, fontSize: 40, color: C.hueso }}>
            <span style={{ width: 36, height: 36, borderRadius: 18, background: C.pelaje, border: `3px solid ${C.hueso}`, display: "inline-block" }} />
            @ithnoir · comenta <IcoHuella tamano={56} />
          </div>
        </Pop>
      </div>
      <S id="pop" en={m("agua", 40)} volumen={0.3} />
      <S id="cascabel" en={firma} volumen={0.45} />
    </Escena>
  );
};
