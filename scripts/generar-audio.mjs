// Genera narración (con marcas de tiempo por palabra) y efectos con ElevenLabs.
// Uso: NODE_USE_ENV_PROXY=1 node scripts/generar-audio.mjs <carpeta-en-src> [--forzar]
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";

const API = "https://api.elevenlabs.io/v1";
const KEY = process.env.ELEVENLABS_API_KEY ?? "proxy-injected";
const proyecto = process.argv[2];
const forzar = process.argv.includes("--forzar");
if (!proyecto) throw new Error("Indica la carpeta, p. ej. programacion");

const guion = JSON.parse(readFileSync(`src/${proyecto}/guion.json`, "utf8"));
const SALIDA = `public/${guion.carpeta}`;
const TIEMPOS = `src/${proyecto}/tiempos.json`;
mkdirSync(SALIDA, { recursive: true });
const previos = existsSync(TIEMPOS) ? JSON.parse(readFileSync(TIEMPOS, "utf8")) : { voz: {}, sfx: {} };

const post = async (ruta, cuerpo) => {
  const res = await fetch(`${API}${ruta}`, {
    method: "POST",
    headers: { "xi-api-key": KEY, "Content-Type": "application/json" },
    body: JSON.stringify(cuerpo),
  });
  if (!res.ok) throw new Error(`${ruta} → ${res.status}: ${await res.text()}`);
  return res;
};

const duracion = (archivo) =>
  Number(execFileSync("ffprobe", ["-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", archivo]).toString());

/** Agrupa los caracteres alineados en palabras con inicio y fin. */
const palabras = (al) => {
  const out = [];
  let actual = null;
  al.characters.forEach((c, i) => {
    if (/\s/.test(c)) {
      if (actual) out.push(actual);
      actual = null;
      return;
    }
    if (!actual) actual = { p: "", ini: al.character_start_times_seconds[i], fin: 0 };
    actual.p += c;
    actual.fin = al.character_end_times_seconds[i];
  });
  if (actual) out.push(actual);
  return out;
};

const tiempos = { voz: {}, sfx: {} };

for (const e of guion.escenas) {
  const archivo = `${SALIDA}/voz-${e.id}.mp3`;
  const previo = previos.voz[e.id];
  if (forzar || !existsSync(archivo) || !previo || previo.texto !== e.texto) {
    const prefijo = guion.prefijo ? `${guion.prefijo} ` : "";
    const res = await post(`/text-to-speech/${guion.voz}/with-timestamps?output_format=mp3_44100_128`, {
      text: prefijo + e.texto,
      model_id: guion.modelo,
      language_code: "es",
      ...(guion.modelo === "eleven_v3"
        ? {}
        : { voice_settings: { stability: 0.5, similarity_boost: 0.8, style: 0.3, use_speaker_boost: true } }),
    });
    const d = await res.json();
    writeFileSync(archivo, Buffer.from(d.audio_base64, "base64"));
    // Quita la etiqueta de estilo (no se pronuncia) de la alineación.
    const n = prefijo.length;
    // Quita también las etiquetas de interpretación dentro del texto ("[susurrando]"...), que no se pronuncian.
    const chars = d.alignment.characters.slice(n);
    const ini = d.alignment.character_start_times_seconds.slice(n);
    const fin = d.alignment.character_end_times_seconds.slice(n);
    const al = { characters: [], character_start_times_seconds: [], character_end_times_seconds: [] };
    let dentro = false;
    chars.forEach((c, k) => {
      if (c === "[") dentro = true;
      const fuera = !dentro;
      if (c === "]") {
        dentro = false;
        return;
      }
      if (fuera && !(al.characters.length === 0 && /\s/.test(c))) {
        al.characters.push(c);
        al.character_start_times_seconds.push(ini[k]);
        al.character_end_times_seconds.push(fin[k]);
      }
    });
    tiempos.voz[e.id] = {
      texto: e.texto,
      duracion: duracion(archivo),
      palabras: palabras(al),
      // Letra a letra, para animar la boca.
      letras: al.characters.join(""),
      ini: al.character_start_times_seconds.map((x) => Math.round(x * 1000) / 1000),
      fin: al.character_end_times_seconds.map((x) => Math.round(x * 1000) / 1000),
    };
    console.log("✓", archivo);
    // Guardar ya, por si la siguiente petición falla (por ejemplo, sin créditos).
    writeFileSync(TIEMPOS, JSON.stringify({ voz: { ...previos.voz, ...tiempos.voz }, sfx: previos.sfx }, null, 1) + "\n");
  } else {
    tiempos.voz[e.id] = previo;
  }
}

for (const s of guion.sfx) {
  const archivo = `${SALIDA}/sfx-${s.id}.mp3`;
  if (forzar || !existsSync(archivo)) {
    const res = await post("/sound-generation", {
      text: s.texto,
      duration_seconds: s.duracion,
      prompt_influence: 0.6,
      model_id: "eleven_text_to_sound_v2",
      ...(s.loop ? { loop: true } : {}),
    });
    writeFileSync(archivo, Buffer.from(await res.arrayBuffer()));
    console.log("✓", archivo);
  }
  tiempos.sfx[s.id] = duracion(archivo);
}

writeFileSync(TIEMPOS, JSON.stringify(tiempos, null, 1) + "\n");
console.log("Duraciones de voz:", Object.fromEntries(Object.entries(tiempos.voz).map(([k, v]) => [k, v.duracion.toFixed(2)])));
