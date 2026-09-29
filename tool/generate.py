#!/usr/bin/env python3
"""Generates lib/src/icons.g.dart from the Figma-exported path JSON.
Usage: python3 tool/generate.py path/to/icon_paths.json"""
import json, re, sys, keyword
src = sys.argv[1] if len(sys.argv) > 1 else 'tool/icon_paths.json'
data = json.load(open(src))
FIX = {'sytinge':'syringe','tarhet':'target','dashborad':'dashboard','currnecy':'currency',
       'currecy':'currency','arow':'arrow','tounge':'tongue'}
QUIRK = ['line', 'r', 'Variant3', 'number binary', 'chart axis bar']
RESERVED = set(keyword.kwlist) | {'assert','break','case','catch','class','const','continue','default','do','else',
  'enum','extends','false','final','finally','for','if','in','is','new','null','rethrow','return','super',
  'switch','this','throw','true','try','var','void','while','with'}
def camel(n):
    for k, v in FIX.items(): n = n.replace(k, v)
    p = n.split('_'); c = p[0] + ''.join(x.capitalize() for x in p[1:])
    if c[0].isdigit() or c in RESERVED: c += 'Icon'
    return c
def esc(s): return s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')
def compact(d): return re.sub(r'\s+', ' ', d.replace(' ,', ',')).strip()
def layer(v):
    if v is None: return 'null'
    ps = v['paths']
    explicit = [i for i, p in enumerate(ps) if p['opacity'] or p['stroke'] == '#2563EB']
    accent = set(explicit) if explicit else ({len(ps) - 1} if len(ps) > 1 else set())
    out = []
    for i, p in enumerate(ps):
        flags = []
        if p['stroke']: flags.append('stroke: true')
        if p['fill_rule'] == 'evenodd': flags.append('evenOdd: true')
        if i in accent: flags.append('accent: true')
        out.append("StrangePath('%s'%s)" % (esc(compact(p['d'])), (', ' + ', '.join(flags)) if flags else ''))
    return 'StrangeIconLayer([' + ', '.join(out) + '])'
seen = {}; lines = []; names = []
for ic in data:
    nm = camel(ic['dart_name'])
    assert nm not in seen, nm
    seen[nm] = 1
    st = ic['styles']
    line = next((st[k] for k in QUIRK if k in st), None)
    lines.append("  /// `%s` (%s)\n  static const %s = StrangeIconData._(\n    '%s',\n    line: %s,\n    fill: %s,\n    duoline: %s,\n  );\n" %
        (nm, ic['section'], nm, nm, layer(line), layer(st.get('fill')), layer(st.get('duoline'))))
    names.append(nm)
head = ("// GENERATED CODE - DO NOT EDIT. Run `python3 tool/generate.py <json>`.\n"
        "// Icon artwork derived from strangeicons (MIT) - https://github.com/indigoscipio/strangeicons-v3\n"
        "// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars\n\n"
        "part of 'icon_data.dart';\n\n"
        "/// All icons in the set. Use with [StrangeIcon].\nabstract final class StrangeIcons {\n  StrangeIcons._();\n\n")
tail = "  /// Every icon, in Figma order.\n  static const List<StrangeIconData> values = [\n" + ''.join('    %s,\n' % n for n in names) + "  ];\n}\n"
open('lib/src/icons.g.dart', 'w').write(head + '\n'.join(lines) + '\n' + tail)
print(len(names), 'icons')
