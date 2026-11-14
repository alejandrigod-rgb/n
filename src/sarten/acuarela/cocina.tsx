/**
 * La cocina del video de la sartén, pintada en acuarela (piel de la skill «animaciones», MIT) y en capas de profundidad:
 * PARED (se mueve menos con la cámara), MUEBLES (encimera, horno, cajones y lo que hay encima) y DELANTE (la lámpara y la planta,
 * que se mueven más). Así, al mover la cámara, parece 3D. Coordenadas del mundo: 1080×1920 (la sartén en x 155-675, y 870-1260;
 * el fogón en y 1228; la encimera en y 1240; Nyxar detrás, en x 590-1020).
 */
import React from "react";
import { Cosa, circD, elipD, lienzo, rectD, redD, ruta, type P, type Pintada } from "./piel";

const MADERA = "#C8955D";
const SALVIA = "#9CB7A6";

/* ================= LA PARED ================= */
const pintarPared = (): Pintada => {
  const L = lienzo(4242);
  // la gran aguada de la pared y los azulejos de metro detrás del fogón
  L.mancha(rectD(-40, -40, 1160, 1290), "#F1DDB6", 0.9, 0);
  L.mancha(rectD(-40, 690, 1160, 560), "#E3E8E2", 0.85, 4);
  for (let fila = 0; fila < 12; fila++) {
    for (let col = -1; col < 13; col++) {
      const x = col * 92 + (fila % 2 ? 46 : 0),
        y = 700 + fila * 46;
      if (L.r() < 0.12) continue;
      L.mancha(redD(x + 3, y + 3, 86, 40, 8), L.r() < 0.5 ? "#F4F6F1" : "#EAF0EC", 0.95, 3);
    }
  }
  // la campana extractora con su chimenea
  L.mancha(rectD(330, -40, 140, 610), "#C7CDD3", 0.95, 5);
  L.mancha(rectD(345, -40, 18, 600), "#E6EAEE", 0.7, 0);
  L.mancha(ruta([[150, 700], [650, 700], [560, 556], [240, 556]], true), "#B9C2CB", 0.97, 6);
  L.mancha(rectD(150, 690, 500, 22), "#8E98A3", 1, 4);
  L.mancha(ruta([[250, 570], [300, 570], [205, 690], [170, 690]], true), "#DDE3E8", 0.7, 0);
  L.caja(330, -40, 140, 610);
  L.linea([[150, 700], [650, 700], [560, 556], [240, 556]]);
  // armarios de arriba (salvia) con puertas de cristal y platos dentro
  L.mancha(rectD(18, 168, 290, 360), SALVIA, 0.96, 6);
  [28, 168].forEach((x) => {
    L.mancha(rectD(x, 182, 130, 330), "#B3CABC", 0.9, 4);
    L.mancha(rectD(x + 14, 200, 102, 200), "#E9F0EA", 0.85, 3);
    [[x + 40, 270], [x + 78, 270]].forEach((c) => {
      L.mancha(circD(c as P, 26), "#F7F3EA", 0.95, 3);
      L.aro(c as P, 26);
      L.raya(circD(c as P, 16), "#6E93C2", 2.4, 0.7);
    });
    L.mancha(rectD(x + 14, 330, 102, 8), "#C9B48A", 1, 2);
    [x + 26, x + 50, x + 74, x + 98].forEach((cx, k) => L.mancha(rectD(cx - 8, 346, 16, 46), ["#D98C8C", "#EDCB45", "#6F93BC", "#7FA66A"][k], 0.9, 2));
    L.mancha(rectD(x + 104, 430, 8, 46), "#8B6A4C", 1, 2);
    L.caja(x, 182, 130, 330);
    L.caja(x + 14, 200, 102, 200);
  });
  L.caja(18, 168, 290, 360);
  // el reloj encima de los armarios
  L.mancha(circD([164, 96], 56), "#F7F1E3", 1, 3);
  L.raya(circD([164, 96], 56), "#4F8E8C", 10, 0.9);
  L.aro([164, 96], 60);
  // la ventana al atardecer, con cortinas y macetas en el alféizar
  L.mancha(rectD(580, 200, 440, 380), "#F4ECDC", 1, 5);
  L.mancha(rectD(600, 220, 400, 340), "#F3B98A", 0.95, 4);
  L.mancha(rectD(600, 220, 400, 120), "#E9A27E", 0.8, 0);
  L.mancha(rectD(600, 220, 400, 60), "#C9A3C4", 0.7, 0);
  L.mancha(circD([900, 300], 36), "#FBE7B5", 0.95, 3);
  ([[600, 430, 70, 130], [670, 400, 60, 160], [730, 450, 90, 110], [820, 380, 50, 180], [870, 420, 80, 140], [950, 460, 50, 100]] as number[][]).forEach(([x, y, w, h]) => {
    L.mancha(rectD(x, y, w, h), "#8C86AE", 0.9, 3);
    for (let k = 0; k < 4; k++) if (L.r() < 0.6) L.mancha(rectD(x + 10 + (k % 2) * 26, y + 20 + Math.floor(k / 2) * 40, 12, 16), "#FBD889", 0.95, 0);
  });
  L.mancha(rectD(796, 220, 8, 340), "#F4ECDC", 1, 2);
  L.mancha(rectD(600, 386, 400, 8), "#F4ECDC", 1, 2);
  L.mancha(ruta([[580, 196], [690, 196], [650, 380], [600, 590], [570, 590]], true), "#D98C8C", 0.9, 5);
  L.mancha(ruta([[1020, 196], [910, 196], [950, 380], [1000, 590], [1030, 590]], true), "#D98C8C", 0.9, 5);
  L.raya("M 600 230 Q 620 400 590 580 M 1000 230 Q 980 400 1010 580", "#B96F70", 3, 0.6);
  L.mancha(rectD(560, 576, 480, 22), "#E8D9BF", 1, 5);
  L.caja(600, 220, 400, 340);
  L.caja(560, 576, 480, 22);
  // macetas: un cactus y unas hierbas
  L.mancha(ruta([[640, 540], [690, 540], [684, 578], [646, 578]], true), "#C47852", 0.97, 4);
  L.mancha(redD(650, 470, 30, 74, 14), "#7FA66A", 0.95, 4);
  L.mancha(redD(626, 498, 22, 40, 10), "#7FA66A", 0.95, 3);
  L.mancha(ruta([[930, 540], [990, 540], [982, 578], [938, 578]], true), "#C47852", 0.97, 4);
  for (let k = 0; k < 7; k++) L.mancha(elipD([936 + k * 8, 520 - (k % 3) * 8], 8, 18, (k - 3) * 0.25), "#6E9E5E", 0.95, 2);
  // la estantería de especias
  L.mancha(rectD(20, 600, 200, 14), MADERA, 1, 4);
  [40, 80, 120, 160, 196].forEach((x, k) => {
    L.mancha(redD(x - 14, 548, 28, 52, 6), "#F4F1EA", 0.8, 3);
    L.mancha(rectD(x - 14, 572, 28, 26), ["#C9433A", "#E0A53A", "#7FA66A", "#9C6A3E", "#D98C8C"][k], 0.9, 0);
    L.mancha(rectD(x - 15, 540, 30, 10), "#6A5E54", 1, 2);
  });
  L.caja(20, 600, 200, 14);
  // la barra con utensilios colgados (cucharón, espátula, batidor)
  L.raya("M 20 770 H 150", "#6A5E54", 7);
  L.mancha(rectD(36, 776, 10, 140), "#9AA4A9", 1, 3);
  L.mancha(elipD([41, 930], 22, 18), "#AEB8BC", 0.97, 4);
  L.mancha(rectD(82, 776, 10, 120), "#8B6A4C", 1, 3);
  L.mancha(redD(70, 892, 34, 50, 6), "#9C7451", 0.97, 4);
  L.mancha(rectD(126, 776, 8, 100), "#9AA4A9", 1, 3);
  L.raya("M 130 876 Q 108 930 130 960 Q 152 930 130 876 M 130 876 Q 118 930 130 958 Q 142 930 130 876", "#8E98A3", 3, 0.9);
  // un calendario con el día marcado
  L.mancha(rectD(30, 1000, 120, 150), "#FBF7EE", 1, 4);
  L.mancha(rectD(30, 1000, 120, 34), "#C9433A", 0.9, 3);
  for (let k = 0; k < 12; k++) L.mancha(rectD(40 + (k % 4) * 26, 1046 + Math.floor(k / 4) * 30, 18, 18), "#E3DCCB", 0.9, 0);
  L.raya(circD([75, 1085], 14), "#C9433A", 3, 0.9);
  L.caja(30, 1000, 120, 150);
  return L.fin();
};

/* ================= LOS MUEBLES (encimera, horno, cajones, lo de encima y el suelo) ================= */
const pintarMuebles = (): Pintada => {
  const L = lienzo(919);
  // suelo de baldosas
  L.mancha(rectD(-40, 1750, 1160, 220), "#CDD6D5", 0.9, 0);
  for (let i = 0; i < 12; i++) if (i % 2) L.mancha(rectD(i * 92, 1770, 92, 70), "#AEBDC2", 0.55, 3);
  for (let i = 0; i < 12; i++) if (!(i % 2)) L.mancha(rectD(i * 92, 1840, 92, 80), "#AEBDC2", 0.55, 3);
  // la encimera de madera
  L.mancha(rectD(-30, 1240, 1140, 46), MADERA, 0.97, 6);
  L.mancha(rectD(-30, 1244, 1140, 8), "#E4C08B", 0.9, 0);
  L.raya("M 0 1262 Q 300 1258 540 1264 T 1080 1260", "#A9763F", 2.4, 0.45);
  L.caja(-30, 1240, 1140, 46);
  // horno
  L.mancha(rectD(150, 1290, 450, 440), "#E1DCD3", 0.97, 6);
  L.mancha(rectD(150, 1290, 450, 54), "#CBC5BA", 0.95, 4);
  [220, 300, 520].forEach((x) => {
    L.mancha(circD([x, 1316], 18), "#5E5650", 1, 3);
    L.aro([x, 1316], 18);
  });
  L.mancha(redD(184, 1420, 382, 250, 22), "#5C4A44", 0.95, 5);
  L.mancha(ruta([[210, 1440], [300, 1440], [230, 1650], [200, 1650]], true), "#8C7A72", 0.5, 0);
  L.mancha(rectD(200, 1370, 350, 22), "#9AA4A9", 1, 4);
  // el trapo de cocina colgado del asa
  L.mancha(ruta([[330, 1370], [430, 1370], [436, 1520], [326, 1520]], true), "#F2E6E1", 0.97, 5);
  [1400, 1440, 1480].forEach((y) => L.mancha(rectD(328, y, 106, 10), "#D98C8C", 0.9, 0));
  L.caja(150, 1290, 450, 440);
  L.caja(184, 1420, 382, 250);
  // armario de la izquierda y cajones de la derecha
  L.mancha(rectD(-30, 1290, 172, 440), SALVIA, 0.96, 6);
  L.mancha(rectD(110, 1360, 10, 70), "#8B6A4C", 1, 3);
  L.caja(-30, 1290, 172, 440);
  [1290, 1440, 1590].forEach((y) => {
    L.mancha(rectD(610, y + 4, 480, 142), SALVIA, 0.96, 6);
    L.mancha(redD(800, y + 60, 100, 16, 8), "#8B6A4C", 1, 3);
    L.caja(610, y + 4, 480, 142);
  });
  L.mancha(rectD(-30, 1730, 1140, 26), "#6A5E54", 0.9, 3);
  // sombras de contacto en la encimera
  L.mancha(elipD([70, 1240], 70, 10), "#7E5A38", 0.35, 0);
  L.mancha(elipD([1000, 1240], 80, 10), "#7E5A38", 0.35, 0);
  // el taco de cuchillos y una maceta de albahaca a la izquierda
  L.mancha(ruta([[20, 1240], [100, 1240], [110, 1130], [40, 1110]], true), "#8B6A4C", 0.97, 5);
  [[48, 1100], [66, 1094], [84, 1100]].forEach(([x, y]) => L.mancha(redD(x - 7, y - 50, 14, 52, 5), "#3F3833", 1, 2));
  L.linea([[20, 1240], [100, 1240], [110, 1130], [40, 1110]]);
  L.mancha(ruta([[112, 1240], [150, 1240], [146, 1200], [116, 1200]], true), "#C47852", 0.97, 3);
  for (let k = 0; k < 6; k++) L.mancha(elipD([118 + k * 6, 1188 - (k % 2) * 10], 9, 14, (k - 2.5) * 0.3), "#6E9E5E", 0.95, 2);
  // el hervidor y el frutero a la derecha
  L.mancha(redD(940, 1140, 90, 100, 30), "#4F8E8C", 0.97, 5);
  L.mancha(ruta([[1030, 1160], [1066, 1150], [1060, 1170], [1030, 1186]], true), "#4F8E8C", 0.97, 4);
  L.mancha(rectD(966, 1124, 40, 18), "#3F6F6D", 1, 3);
  L.mancha(ruta([[950, 1160], [960, 1150], [972, 1220], [958, 1226]], true), "#A8D0CE", 0.7, 0);
  L.aro([985, 1190], 46);
  return L.fin();
};

/* ================= DELANTE (lámpara colgante y planta en primer plano) ================= */
const pintarDelante = (): Pintada => {
  const L = lienzo(5151);
  L.raya("M 860 -60 V 110", "#433B35", 4, 0.9);
  L.mancha(ruta([[780, 200], [940, 200], [900, 110], [820, 110]], true), "#E3B44B", 0.97, 6);
  L.mancha(elipD([860, 204], 80, 14), "#F7E3A8", 0.95, 3);
  L.linea([[780, 200], [940, 200], [900, 110], [820, 110]]);
  // hojas grandes de una planta en primer plano (abajo a la izquierda)
  ([[-20, 1700, 90, 200, -0.6], [60, 1760, 80, 180, -0.2], [140, 1820, 70, 160, 0.3], [20, 1860, 90, 170, -1.0]] as number[][]).forEach(([x, y, rx, ry, a], k) => {
    L.mancha(elipD([x, y], rx, ry, a), k % 2 ? "#5F9154" : "#6E9E5E", 0.95, 6);
    L.raya(`M ${x - Math.sin(a) * ry * 0.9} ${y + Math.cos(a) * ry * 0.9} L ${x + Math.sin(a) * ry * 0.9} ${y - Math.cos(a) * ry * 0.9}`, "#3F6B38", 3, 0.6);
  });
  return L.fin();
};

const PARED = pintarPared();
const MUEBLES = pintarMuebles();
const DELANTE = pintarDelante();

const Svg: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <svg width={1080} height={1920} viewBox="0 0 1080 1920" style={{ position: "absolute", left: 0, top: 0, overflow: "visible" }}>
    {children}
  </svg>
);

export const ParedAcuarela: React.FC = React.memo(() => (
  <Svg>
    <Cosa pt={PARED} filtro="acu-cosa" op={0.6} />
  </Svg>
));
export const MueblesAcuarela: React.FC = React.memo(() => (
  <Svg>
    <Cosa pt={MUEBLES} filtro="acu-cosa" op={0.65} />
  </Svg>
));
/** La planta y la lámpara de delante, un poco desenfocadas (están cerca de la cámara). */
export const DelanteAcuarela: React.FC = React.memo(() => (
  <Svg>
    <g filter="url(#acu-b3)">
      <Cosa pt={DELANTE} filtro="acu-cosa" op={0.6} />
    </g>
  </Svg>
));
