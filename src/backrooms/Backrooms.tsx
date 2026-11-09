import { AbsoluteFill, Html5Audio, interpolate, random, Sequence, spring, staticFile, useCurrentFrame } from "remotion";
import { Brillo, Pop, Subtitulos } from "../marca/kit";
import { IcoBombilla, IcoInfinito, IcoMoqueta } from "../marca/iconos";
import { C, CLAMP, F, FPS } from "../marca/tema";
import { Expresion, Nyxar, POSE_BASE, PoseNyxar } from "../personajes/Nyxar";
import { TipoObjeto } from "../personajes/objetos";
import { CAIDA, CARPETA, CORTE, CRIATURA, IdEscena, IDS, LEVANTA, LINEA, NEGRO, SUSTO, TIEMPOS } from "./linea";
import { Backrooms, Criatura, Cuarto } from "./mundos";

const seg = (n: number) => Math.round(n * FPS);
const sen = (t: number, periodo: number) => Math.sin((t * Math.PI * 2) / periodo);

const Sfx: React.FC<{ id: string; en: number; volumen?: number; dur?: number; loop?: boolean }> = ({
  id,
  en,
  volumen = 0.35,
  dur,
  loop,
}) => (
  <Sequence from={Math.max(0, Math.round(en))} durationInFrames={dur} layout="none">
    <Html5Audio src={staticFile(`${CARPETA}/sfx-${id}.mp3`)} volume={volumen} loop={loop} />
  </Sequence>
);

const Chip: React.FC<{ texto: string; color?: string; tamano?: number }> = ({ texto, color = C.menta, tamano = 40 }) => (
  <div
    style={{
      display: "inline-block",
      fontFamily: F.cifra,
      fontWeight: 700,
      fontSize: tamano,
      color: C.abismo,
      background: color,
      padding: "6px 22px",
      borderRadius: 999,
      whiteSpace: "nowrap",
      boxShadow: "0 8px 24px rgba(0,0,0,0.35)",
    }}
  >
    {texto}
  </div>
);

const marca = (id: IdEscena, palabra: string, n = 0) => LINEA.inicios[IDS.indexOf(id)] + LINEA.marcas(id)(palabra, n);

/** Dónde está Nyxar (dentro del mundo) y cómo está, en cada momento. */
const nyxarEn = (frame: number) => {
  const t = frame / FPS;
  const { id, local } = LINEA.escenaEn(frame);
  const l = local / FPS;
  const base: PoseNyxar = { ...POSE_BASE };
  let x = 280;
  let y = 1100;
  let ancho = 520;
  let giro = 0;
  let expresion: Expresion = "normal";
  let objeto: TipoObjeto | undefined;
  let pose = base;
  if (frame < CAIDA) {
    // Al principio está pegado a la cámara ajustándola; luego se aparta.
    const aparta = spring({ frame: frame - seg(1.0), fps: FPS, config: { damping: 16 } });
    x = interpolate(aparta, [0, 1], [520, 280]);
    y = interpolate(aparta, [0, 1], [700, 1100]);
    ancho = interpolate(aparta, [0, 1], [1050, 520]);
    pose = {
      ...base,
      brazoD: interpolate(aparta, [0, 1], [150, 150 + 22 * sen(t, 0.65)]),
      brazoI: interpolate(aparta, [0, 1], [130, 18]),
      mirarY: aparta < 0.5 ? -0.3 : 0,
    };
    expresion = "feliz";
  } else if (frame < NEGRO + 4) {
    // Se cae con el trípode.
    const p = interpolate(frame, [CAIDA, NEGRO], [0, 1], CLAMP);
    pose = { ...base, brazoI: 160, brazoD: 160 };
    giro = 80 * p;
    y = 1100 + 500 * p * p;
    expresion = "sorprendido";
  } else if (frame >= LEVANTA) {
    const tras = (frame - LEVANTA) / FPS;
    // Nada más levantar la cámara, está muy cerca; luego retrocede.
    const atras = spring({ frame: frame - LEVANTA - seg(0.9), fps: FPS, config: { damping: 16 } });
    const lados: Partial<Record<IdEscena, number>> = { revelacion: 280, origen: 40, leyenda: 520, liminal: 40, real: 520, final: 40 };
    const destino = lados[id] ?? 280;
    x = tras < 3 ? interpolate(atras, [0, 1], [400, 280]) : destino;
    y = tras < 3 ? interpolate(atras, [0, 1], [760, 1100]) : 1100;
    ancho = tras < 3 ? interpolate(atras, [0, 1], [900, 520]) : 520;
    if (id === "revelacion") {
      expresion = l >= LINEA.marcas("revelacion")("cuarto") / FPS ? "triste" : "sorprendido";
      pose = {
        ...base,
        brazoI: 20 + 10 * sen(t, 0.3),
        brazoD: 20 - 10 * sen(t, 0.3),
        mirarX: -0.4 * Math.sin(t * 2),
        cabeza: 6 * Math.sin(t * 3),
      };
    } else if (id === "origen") {
      expresion = "pensativo";
      pose = { ...base, brazoD: 128, brazoI: 18, mirarX: 0.6, mirarY: -0.6 };
    } else if (id === "leyenda") {
      expresion = "normal";
      objeto = "Lupa";
      pose = { ...base, objeto: spring({ frame: local - LINEA.marcas("leyenda")("realidad"), fps: FPS, config: { damping: 13 } }) };
    } else if (id === "liminal") {
      expresion = "triste";
      pose = { ...base, brazoI: 30, brazoD: 30, mirarX: 0.5, cabeza: -5 };
    } else if (id === "real") {
      expresion = l >= LINEA.marcas("real")("tienda") / FPS ? "sorprendido" : "normal";
      objeto = "Movil";
      pose = { ...base, objeto: spring({ frame: local - LINEA.marcas("real")("encontraron"), fps: FPS, config: { damping: 13 } }) };
    } else {
      const asustado = frame >= CRIATURA;
      expresion = asustado ? "sorprendido" : "triste";
      pose = {
        ...base,
        brazoI: asustado ? 150 : 25,
        brazoD: asustado ? 150 : 25,
        mirarX: asustado ? 0.7 : -0.5 * Math.sin(t * 1.5),
        mirarY: asustado ? -0.3 : 0,
        salto: frame >= SUSTO ? 40 : 0,
      };
    }
  }
  return { x, y, ancho, giro, pose, expresion, objeto };
};

/** Cámara: se ajusta al principio, cae, se levanta y luego tiembla un poco "en mano". */
const camara = (frame: number) => {
  const t = frame / FPS;
  let rot = 0;
  let tx = 0;
  let ty = 0;
  let escala = 1;
  if (frame < CAIDA) {
    const ajuste = spring({ frame: frame - seg(0.5), fps: FPS, config: { damping: 9, mass: 0.7 } });
    rot = interpolate(ajuste, [0, 1], [-9, 0]) + (frame < seg(0.5) ? Math.sin(t * 30) * 1.2 : 0);
    tx = interpolate(ajuste, [0, 1], [120, 0]);
    escala = interpolate(ajuste, [0, 1], [1.12, 1]);
  } else if (frame < NEGRO) {
    const p = interpolate(frame, [CAIDA, NEGRO], [0, 1], { ...CLAMP, easing: (x) => x * x });
    rot = -84 * p;
    ty = 900 * p;
    escala = 1 + 0.3 * p;
  } else if (frame >= LEVANTA) {
    const sube = spring({ frame: frame - LEVANTA, fps: FPS, config: { damping: 10, mass: 1 } });
    rot = interpolate(sube, [0, 1], [78, 0]);
    ty = interpolate(sube, [0, 1], [700, 0]);
    escala = interpolate(sube, [0, 1], [1.35, 1]);
    // cámara en mano: deriva suave
    rot += Math.sin(t * 0.9) * 0.6;
    tx += Math.sin(t * 0.7) * 10;
    ty += Math.cos(t * 0.8) * 8;
    escala += 0.03 * Math.sin(t * 0.3);
  }
  return { rot, tx, ty, escala };
};

const Rec: React.FC<{ frame: number }> = ({ frame }) => {
  const t = frame / FPS;
  const hh = Math.floor(t / 3600);
  const mm = Math.floor(t / 60) % 60;
  const ss = Math.floor(t) % 60;
  const ff = Math.floor((t % 1) * 30);
  const p2 = (n: number) => String(n).padStart(2, "0");
  const esquina = (style: React.CSSProperties) => (
    <div style={{ position: "absolute", width: 70, height: 70, borderColor: "#ffffffcc", borderStyle: "solid", ...style }} />
  );
  return (
    <AbsoluteFill style={{ pointerEvents: "none" }}>
      {esquina({ left: 50, top: 70, borderWidth: "5px 0 0 5px" })}
      {esquina({ right: 50, top: 70, borderWidth: "5px 5px 0 0" })}
      {esquina({ left: 50, bottom: 360, borderWidth: "0 0 5px 5px" })}
      {esquina({ right: 50, bottom: 360, borderWidth: "0 5px 5px 0" })}
      <div
        style={{
          position: "absolute",
          left: 90,
          top: 100,
          display: "flex",
          alignItems: "center",
          gap: 12,
          fontFamily: F.cifra,
          fontWeight: 700,
          fontSize: 40,
          color: "#fff",
          textShadow: "0 2px 6px #000",
        }}
      >
        <span style={{ width: 26, height: 26, borderRadius: 13, background: "#ff2a3d", opacity: Math.floor(t * 2) % 2 ? 1 : 0.15 }} />
        REC
      </div>
      <div style={{ position: "absolute", right: 90, top: 104, display: "flex", alignItems: "center", gap: 4 }}>
        <div style={{ width: 62, height: 30, border: "4px solid #fff", borderRadius: 6, padding: 3 }}>
          <div style={{ width: "45%", height: "100%", background: "#fff" }} />
        </div>
        <div style={{ width: 6, height: 14, background: "#fff", borderRadius: 2 }} />
      </div>
      <div
        style={{
          position: "absolute",
          left: 90,
          bottom: 380,
          fontFamily: F.cifra,
          fontWeight: 700,
          fontSize: 34,
          color: "#fff",
          textShadow: "0 2px 6px #000",
        }}
      >
        {`${p2(hh)}:${p2(mm)}:${p2(ss)}:${p2(ff)}`}
      </div>
    </AbsoluteFill>
  );
};

/** Gráficos de la explicación, superpuestos como en la marca. */
const Graficos: React.FC<{ frame: number }> = ({ frame }) => {
  const { id } = LINEA.escenaEn(frame);
  const zona: React.CSSProperties = {
    position: "absolute",
    top: 470,
    left: 0,
    right: 0,
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    gap: 26,
  };
  if (id === "origen")
    return (
      <div style={zona}>
        <Pop desde={marca("origen", "diecinueve") - 6}>
          <Chip texto="Foro de internet · 2019" color={C.azul} />
        </Pop>
        <Pop desde={marca("origen", "foto")} giro={-8}>
          <div
            style={{
              background: "#f1f5ff",
              padding: "16px 16px 50px",
              borderRadius: 6,
              transform: "rotate(-4deg)",
              boxShadow: "0 18px 40px rgba(0,0,0,0.45)",
            }}
          >
            <div style={{ position: "relative", width: 380, height: 300, overflow: "hidden" }}>
              <div
                style={{
                  position: "absolute",
                  left: -350,
                  top: -620,
                  transform: "scale(0.35)",
                  transformOrigin: "350px 620px",
                  width: 1080,
                  height: 1920,
                }}
              >
                <Backrooms s={0} parpadeo={0} />
              </div>
            </div>
          </div>
        </Pop>
      </div>
    );
  if (id === "leyenda")
    return (
      <div style={zona}>
        {[
          { t: "moqueta húmeda", i: IcoMoqueta, w: "moqueta", c: C.cascabel },
          { t: "zumbido de fluorescentes", i: IcoBombilla, w: "zumbido", c: C.hueso },
          { t: "salas vacías para siempre", i: IcoInfinito, w: "salas", c: C.menta },
        ].map((x) => (
          <Pop key={x.w} desde={marca("leyenda", x.w)} giro={-6}>
            <div style={{ display: "flex", alignItems: "center", gap: 16 }}>
              <x.i tamano={70} />
              <Chip texto={x.t} color={x.c} tamano={42} />
            </div>
          </Pop>
        ))}
      </div>
    );
  if (id === "liminal")
    return (
      <div style={zona}>
        <Pop desde={marca("liminal", "liminal")}>
          <Brillo>
            <Chip texto="ESPACIO LIMINAL" tamano={56} />
          </Brillo>
        </Pop>
        <div style={{ display: "flex", flexDirection: "column", gap: 16, alignItems: "center" }}>
          {["pasillo de hotel", "parking vacío", "colegio de noche"].map((x, k) => (
            <Pop key={x} desde={marca("liminal", "sitio") + k * seg(0.25)}>
              <Chip texto={x} color="#f1f5ffdd" tamano={36} />
            </Pop>
          ))}
        </div>
      </div>
    );
  if (id === "real")
    return (
      <div style={zona}>
        <Pop desde={marca("real", "veinticuatro")}>
          <Chip texto="2024 · ¡encontrado!" color={C.cascabel} tamano={48} />
        </Pop>
        <Pop desde={marca("real", "tienda")} giro={-6}>
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 20,
              background: "rgba(2,8,20,0.85)",
              border: `3px solid ${C.menta}`,
              borderRadius: 26,
              padding: "18px 30px",
            }}
          >
            <svg width={90} height={110} viewBox="0 0 90 110">
              <path
                d="M45 105 C45 105 8 62 8 40 A37 37 0 0 1 82 40 C82 62 45 105 45 105 Z"
                fill={C.panuelo}
                stroke="#1d1530"
                strokeWidth={4}
              />
              <circle cx={45} cy={40} r={14} fill="#fff" />
            </svg>
            <div style={{ fontFamily: F.titulo, fontWeight: 800, fontSize: 46, color: C.hueso, lineHeight: 1.1 }}>
              Tienda de maquetas
              <br />
              <span style={{ color: C.menta, fontSize: 38 }}>Oshkosh, EE. UU.</span>
            </div>
          </div>
        </Pop>
      </div>
    );
  return null;
};

export const DURACION_BACKROOMS = CORTE + seg(0.9);

export const BackroomsVideo: React.FC = () => {
  const frame = useCurrentFrame();
  const t = frame / FPS;
  const enBackrooms = frame >= LEVANTA;
  const negro = (frame >= NEGRO && frame < LEVANTA) || frame >= CORTE;
  const cam = camara(frame);
  const ny = nyxarEn(frame);
  // Parpadeo de las luces: de vez en cuando y, al final, sin parar.
  const parpadeo =
    frame >= CRIATURA && frame < CORTE ? (Math.floor(t * 12) % 3 === 0 ? 1 : 0.2) : random(`pp${Math.floor(t * 4)}`) > 0.93 ? 0.8 : 0;
  // Criatura: aparece al fondo y luego, de golpe, delante.
  const cerca = frame >= SUSTO;
  const criaturaVisible = frame >= CRIATURA && frame < CORTE && (cerca || parpadeo < 0.9);
  // Glitch al caer y al cortar
  const glitch = (frame >= NEGRO - 4 && frame < NEGRO + 10) || (frame >= SUSTO && frame < CORTE);

  return (
    <AbsoluteFill style={{ background: "#000", overflow: "hidden" }}>
      {!negro ? (
        <AbsoluteFill
          style={{
            transform: `translate(${cam.tx + (glitch ? (random(`g${frame}`) - 0.5) * 40 : 0)}px, ${cam.ty}px) rotate(${cam.rot}deg) scale(${cam.escala})`,
            transformOrigin: "50% 60%",
            filter: glitch ? "drop-shadow(8px 0 0 rgba(255,0,60,0.6)) drop-shadow(-8px 0 0 rgba(0,200,255,0.6))" : undefined,
          }}
        >
          {enBackrooms ? <Backrooms s={t} parpadeo={parpadeo} /> : <Cuarto s={t} />}
          {criaturaVisible ? (
            <div
              style={{
                position: "absolute",
                left: cerca ? 40 : 495,
                top: cerca ? -120 : 852,
                transform: cerca ? `scale(${1 + (frame - SUSTO) * 0.012})` : undefined,
                transformOrigin: "50% 30%",
              }}
            >
              <Criatura s={t} ancho={cerca ? 1000 : 90} />
            </div>
          ) : null}
          {!cerca ? (
            <div
              style={{
                position: "absolute",
                left: ny.x,
                top: ny.y,
                width: ny.ancho,
                transform: `rotate(${ny.giro}deg)`,
                transformOrigin: "50% 100%",
              }}
            >
              <Nyxar
                ancho={ny.ancho}
                pose={ny.pose}
                boca={LINEA.aperturaBoca(frame)}
                frame={frame}
                fps={FPS}
                expresion={ny.expresion}
                objeto={ny.objeto}
              />
            </div>
          ) : null}
          {/* Rayas de vídeo antiguo en los Backrooms */}
          {enBackrooms ? (
            <AbsoluteFill style={{ backgroundImage: "repeating-linear-gradient(0deg, rgba(0,0,0,0.06) 0 2px, transparent 2px 5px)" }} />
          ) : null}
        </AbsoluteFill>
      ) : null}
      {/* Interfaz de la cámara (desaparece con el corte final) */}
      {frame < CORTE ? <Rec frame={frame} /> : null}
      {/* Gráficos y subtítulos de la marca */}
      {enBackrooms && frame < CRIATURA ? <Graficos frame={frame} /> : null}
      {IDS.map((id, i) => (
        <Sequence key={id} from={LINEA.inicios[i]} durationInFrames={LINEA.duraciones[i]} layout="none">
          {frame < CORTE ? (
            <Subtitulos
              palabras={TIEMPOS.voz[id].palabras}
              pre={LINEA.preDe(id)}
              claves={id === "revelacion" ? ["backrooms"] : id === "liminal" ? ["liminal"] : id === "origen" ? ["foto"] : []}
            />
          ) : null}
          <Sequence from={LINEA.preDe(id)} layout="none">
            <Html5Audio src={staticFile(`${CARPETA}/voz-${id}.mp3`)} volume={1} />
          </Sequence>
        </Sequence>
      ))}
      {/* Sonido */}
      <Sequence from={0} durationInFrames={CAIDA} layout="none">
        <Html5Audio src={staticFile(`${CARPETA}/sfx-musica.mp3`)} volume={0.05} />
      </Sequence>
      <Sfx id="cascabel" en={0} volumen={0.4} />
      <Sfx id="camara" en={seg(0.1)} volumen={0.5} />
      <Sfx id="tripode" en={CAIDA} volumen={0.6} />
      <Sfx id="estatica" en={NEGRO - 2} volumen={0.4} dur={seg(0.4)} />
      <Sfx id="levantar" en={LEVANTA - seg(0.3)} volumen={0.5} />
      <Sequence from={LEVANTA} durationInFrames={CORTE - LEVANTA} layout="none">
        <Html5Audio src={staticFile(`${CARPETA}/sfx-zumbido.mp3`)} volume={0.14} loop />
      </Sequence>
      <Sequence from={LEVANTA + seg(0.5)} durationInFrames={CORTE - LEVANTA - seg(0.5)} layout="none">
        <Html5Audio src={staticFile(`${CARPETA}/sfx-drone.mp3`)} volume={0.1} loop />
      </Sequence>
      <Sfx id="golpe" en={marca("revelacion", "backrooms")} volumen={0.35} />
      <Sfx id="foto" en={marca("origen", "foto")} volumen={0.45} />
      {["moqueta", "zumbido", "salas"].map((w) => (
        <Sfx key={w} id="pop" en={marca("leyenda", w)} volumen={0.25} />
      ))}
      <Sfx id="tic" en={marca("liminal", "liminal")} volumen={0.35} />
      <Sfx id="pop" en={marca("real", "tienda")} volumen={0.3} />
      <Sfx id="latido" en={LINEA.inicios[IDS.indexOf("final")]} volumen={0.4} />
      <Sfx id="parpadeo" en={CRIATURA} volumen={0.45} />
      <Sfx id="criatura" en={CRIATURA + seg(0.4)} volumen={0.6} />
      <Sfx id="golpe" en={SUSTO} volumen={0.6} />
      <Sfx id="estatica" en={SUSTO} volumen={0.6} dur={CORTE - SUSTO + seg(0.15)} />
    </AbsoluteFill>
  );
};
