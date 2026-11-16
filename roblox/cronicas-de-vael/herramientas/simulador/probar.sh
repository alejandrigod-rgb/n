#!/usr/bin/env bash
# Prueba los scripts del juego en un "Roblox de mentira" (sin Studio): valida propiedades, eventos y enums contra
# la API oficial y ejecuta el cliente y el servidor simulando una partida. Uso: herramientas/simulador/probar.sh
# Necesita: python3, curl y el ejecutable `luau` (https://github.com/luau-lang/luau/releases), en el PATH o en LUAU=.
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"
LUAU="${LUAU:-luau}"
if [ ! -f "$D/api.luau" ]; then
  curl -sSL -o "$D/api.json" https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/Full-API-Dump.json
  python3 - "$D" <<'PY'
import json, sys
d = sys.argv[1]
api = json.load(open(d + '/api.json'))
esc = lambda s: s.replace('\\', '\\\\').replace('"', '\\"')
out = ['return {classes={']
for c in api['Classes']:
    ms = []
    for m in c['Members']:
        t = m['MemberType']
        if t == 'Property':
            vt = m['ValueType']['Name']
            if m['ValueType'].get('Category') == 'Enum':
                vt = 'Enum:' + vt
            ms.append('["%s"]="%s"' % (esc(m['Name']), esc(vt)))
        elif t == 'Event':
            ms.append('["%s"]="@event"' % esc(m['Name']))
        elif t == 'Function':
            ms.append('["%s"]="@fn"' % esc(m['Name']))
    sup = c.get('Superclass')
    out.append('["%s"]={s=%s,m={%s}},' % (c['Name'], ('"%s"' % sup) if sup and sup != '<<<ROOT>>>' else 'nil', ','.join(ms)))
out.append('},enums={')
for e in api['Enums']:
    out.append('["%s"]={%s},' % (e['Name'], ','.join('["%s"]=%d' % (esc(i['Name']), i['Value']) for i in e['Items'])))
out.append('}}')
open(d + '/api.luau', 'w').write('\n'.join(out))
PY
  rm -f "$D/api.json"
fi
for prueba in prueba_cliente prueba_servidor; do
  python3 - "$D" "$prueba" <<'PY'
import glob, os, sys
D, prueba = sys.argv[1], sys.argv[2]
R = os.path.join(D, '..', '..', 'src')
def largo(t):
    n = 0
    while ']' + '=' * n + ']' in t or '[' + '=' * n + '[' in t:
        n += 1
    return '[' + '=' * n + '[', ']' + '=' * n + ']'
partes = ['local API_DATA = (function()\n' + open(D + '/api.luau').read() + '\nend)()\n',
          'local RT_MODULO = (function()\n' + open(D + '/rt.luau').read() + '\nend)()\n',
          'local BASE = (function()\n' + open(D + '/base.luau').read() + '\nend)()\n',
          'local FUENTES = {\n']
for f in sorted(glob.glob(R + '/**/*.luau', recursive=True)):
    t = open(f).read()
    a, b = largo(t)
    partes.append('["%s"] = %s\n%s%s,\n' % (os.path.relpath(f, R), a, t, b))
partes.append('}\n' + open(D + '/' + prueba + '.luau').read())
open(D + '/salida.luau', 'w').write(''.join(partes))
PY
  echo "######## $prueba"
  "$LUAU" "$D/salida.luau"
done
rm -f "$D/salida.luau"
