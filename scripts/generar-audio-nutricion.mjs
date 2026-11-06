// Genera la narración y los efectos de sonido con ElevenLabs.
// Uso: ELEVENLABS_API_KEY=... node scripts/generar-audio-nutricion.mjs [--forzar]
import { execFileSync } from "node:child_process";
import { existsSync, readFileSync, writeFileSync } from "node:fs";

const API = "https://api.elevenlabs.io/v1";
const KEY = process.env.ELEVENLABS_API_KEY ?? "proxy-injected";
const SALIDA = "public/nutricion";
const forzar = process.argv.includes("--forzar");
const guion = JSON.parse(readFileSync("src/nutricion/guion.json", "utf8"));

const pedir = async (ruta, cuerpo, archivo) => {
  if (!forzar && existsSync(archivo)) return;
  const res = await fetch(`${API}${ruta}`, {
    method: "POST",
    headers: { "xi-api-key": KEY, "Content-Type": "application/json" },
    body: JSON.stringify(cuerpo),
  });
  if (!res.ok) throw new Error(`${ruta} → ${res.status}: ${await res.text()}`);
  writeFileSync(archivo, Buffer.from(await res.arrayBuffer()));
  console.log("✓", archivo);
};

const duracion = (archivo) =>
  Number(
    execFileSync("ffprobe", [
      "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", archivo,
    ]).toString(),
  );

const duraciones = { voz: {}, sfx: {} };

for (const e of guion.escenas) {
  const archivo = `${SALIDA}/voz-${e.id}.mp3`;
  await pedir(
    `/text-to-speech/${guion.voz}?output_format=mp3_44100_128`,
    {
      text: e.texto,
      model_id: guion.modelo,
      language_code: "es",
      voice_settings: { stability: 0.45, similarity_boost: 0.8, style: 0.35, use_speaker_boost: true },
    },
    archivo,
  );
  duraciones.voz[e.id] = duracion(archivo);
}

for (const s of guion.sfx) {
  const archivo = `${SALIDA}/sfx-${s.id}.mp3`;
  await pedir(
    "/sound-generation",
    {
      text: s.texto,
      duration_seconds: s.duracion,
      prompt_influence: 0.6,
      model_id: "eleven_text_to_sound_v2",
      ...(s.loop ? { loop: true } : {}),
    },
    archivo,
  );
  duraciones.sfx[s.id] = duracion(archivo);
}

writeFileSync("src/nutricion/duraciones.json", JSON.stringify(duraciones, null, 2) + "\n");
console.log(duraciones);
