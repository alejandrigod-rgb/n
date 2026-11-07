/** Línea de tiempo de un video a partir de las duraciones reales de la narración. */
export type Palabra = { p: string; ini: number; fin: number };
export type Voz = { texto: string; duracion: number; palabras: Palabra[]; letras: string; ini: number[]; fin: number[] };
export type Tiempos = { voz: Record<string, Voz>; sfx: Record<string, number> };

const normalizar = (s: string) =>
  s.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/[^a-z0-9]/g, "");

const valorLetra = (c: string) => {
  const l = c.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "");
  if (l === "a") return 1;
  if (l === "e" || l === "o") return 0.75;
  if (l === "i" || l === "u") return 0.45;
  if ("mbpfv".includes(l)) return 0.05;
  if (/[a-z]/.test(l)) return 0.3;
  return 0;
};

export const crearLinea = <Id extends string>(opts: {
  tiempos: Tiempos;
  ids: readonly Id[];
  fps: number;
  /** Segundos de silencio antes de la voz en cada escena (por escena o general). */
  pre: number | Partial<Record<Id, number>>;
  /** Segundos extra al final de cada escena. */
  extra?: Partial<Record<Id, number>>;
  transicion: number;
}) => {
  const { tiempos, ids, fps, transicion } = opts;
  const preDe = (id: Id) => Math.round((typeof opts.pre === "number" ? opts.pre : opts.pre[id] ?? 0.2) * fps);
  const duraciones = ids.map((id) => preDe(id) + Math.ceil((tiempos.voz[id].duracion + 0.55 + (opts.extra?.[id] ?? 0)) * fps));
  const inicios = duraciones.map((_, i) => duraciones.slice(0, i).reduce((a, d) => a + d - transicion, 0));
  const total = inicios[ids.length - 1] + duraciones[ids.length - 1];

  const escenaEn = (frame: number) => {
    let i = 0;
    for (let k = 0; k < ids.length; k++) if (frame >= inicios[k]) i = k;
    return { i, id: ids[i], local: frame - inicios[i] };
  };

  /** Fotograma local en que se dice `palabra` (n-ésima aparición). */
  const marcas = (id: Id) => (palabra: string, n = 0) => {
    let c = 0;
    for (const w of tiempos.voz[id].palabras) {
      if (normalizar(w.p) === normalizar(palabra)) {
        if (c === n) return preDe(id) + Math.round(w.ini * fps);
        c++;
      }
    }
    throw new Error(`"${palabra}" no aparece en "${id}"`);
  };

  const aperturaEn = (v: Voz, t: number) => {
    for (let k = 0; k < v.letras.length; k++) if (t >= v.ini[k] && t < v.fin[k]) return valorLetra(v.letras[k]);
    return 0;
  };

  /** Apertura de la boca (0-1) en un fotograma global, suavizada. */
  const aperturaBoca = (frame: number) => {
    for (let i = 0; i < ids.length; i++) {
      const v = tiempos.voz[ids[i]];
      const t = (frame - inicios[i] - preDe(ids[i])) / fps;
      if (t >= -0.05 && t <= v.duracion + 0.05) {
        const m = [-0.035, 0, 0.035].map((d) => aperturaEn(v, t + d));
        return m[0] * 0.25 + m[1] * 0.5 + m[2] * 0.25;
      }
    }
    return 0;
  };

  return { duraciones, inicios, total, escenaEn, marcas, aperturaBoca, preDe, normalizar };
};
