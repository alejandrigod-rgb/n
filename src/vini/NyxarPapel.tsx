import React from "react";
import { Nyxar, type Expresion, type PoseNyxar } from "../personajes/Nyxar";

/**
 * Nyxar de cartulina: el mismo Nyxar vectorial (gris, para temas tristes) con fibra de papel, borde cortado a tijera
 * y la sombra suave del estilo papel recortado. El filtro va por id único.
 */
export const FiltroPapelNyxar: React.FC = () => (
  <svg width={0} height={0} style={{ position: "absolute" }}>
    <defs>
      <filter id="nyx-papel" x="-10%" y="-10%" width="125%" height="125%" colorInterpolationFilters="sRGB">
        {/* borde de tijera: un desplazamiento pequeño y fijo */}
        <feTurbulence type="fractalNoise" baseFrequency="0.035" numOctaves={2} seed={7} result="ruidoBorde" />
        <feDisplacementMap in="SourceGraphic" in2="ruidoBorde" scale={4} xChannelSelector="R" yChannelSelector="G" result="cortado" />
        {/* fibra: grano fino oscuro y claro solo dentro de la figura */}
        <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves={2} seed={3} result="grano" />
        <feColorMatrix in="grano" type="matrix" values="0 0 0 0 1  0 0 0 0 1  0 0 0 0 1  0 0 0 -0.6 0.32" result="granoOsc" />
        <feComposite in="granoOsc" in2="cortado" operator="in" result="fibra" />
        <feMerge result="conFibra">
          <feMergeNode in="cortado" />
          <feMergeNode in="fibra" />
        </feMerge>
        <feDropShadow in="conFibra" dx={14} dy={18} stdDeviation={12} floodColor="#3A200C" floodOpacity={0.3} />
      </filter>
    </defs>
  </svg>
);

export const NyxarPapel: React.FC<{ ancho: number; pose: PoseNyxar; boca: number; frame: number; fps: number; expresion: Expresion; parpadeo?: number }> = (p) => (
  <div style={{ filter: "url(#nyx-papel)" }}>
    <Nyxar {...p} paleta="grisPapel" />
  </div>
);
