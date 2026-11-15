import io, re, os

HERE = os.path.dirname(os.path.abspath(__file__))
FILES = [os.path.join(HERE, 'examples', f) for f in
         ['assert-app.mjs', 'measure-overflow.mjs', 'capture-shots.mjs', 'measure-overlap.mjs']]
# 在 JS 模板字符串里，\d \s \w 这类会被模板转义处理吃掉变成字面字母。
# 正确写法是 \\d。这里找「单反斜杠 + 正则元字符字母」的行。
BAD = re.compile(r'''(?<![\\\\])\\([dswbnDWSB]|\d|.|$)''')
SAFE = re.compile(r'''\\\\''')

total = 0
for fn in FILES:
    src = io.open(fn, encoding='utf-8').read()
    out = []
    for i, line in enumerate(src.split('\n'), 1):
        if '`' not in line:
            continue
        # 先把合法的双反斜杠占位掉，避免误报
        tmp = line.replace('\\\\', '\x00')
        for m in re.finditer(r'\\([A-Za-z0-9])', tmp):
            out.append((i, '\\' + m.group(1), line.strip()[:100]))
    print(f'--- {fn}: {len(out)} 处「模板里的单反斜杠+字母」')
    for i, tok, txt in out:
        print(f'    L{i:<5} {tok:<4} {txt}')
    total += len(out)
print(f'\n合计 {total} 处待人工判定（\\n \\t 之类在模板里是正常转义，\\d \\w 才是 bug）')
