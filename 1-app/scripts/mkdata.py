"""يبني assets/www/data.js من بيانات Quran.com (كلمة بكلمة) ويطابقها مع quran-meta."""
import json, re, sys
words_json, hafs_json, out_js = sys.argv[1:4]
d = json.load(open(words_json, encoding='utf-8'))
H = json.load(open(hafs_json, encoding='utf-8'))
ay = []; idx = {}; pages = []; cur_s = 0
for pg in d:
    p = pg['page']; lines = []; pend = []; last = 0
    for a in pg['ayahs']:
        lt = a['metaData'].get('lineType')
        if lt == 'start_sura':
            cur_s += 1; pend.append(['s', cur_s]); continue
        if lt == 'besmellah':
            pend.append(['b']); continue
        for w in a['words']:
            ln = w['line_number']
            if ln != last:
                assert ln - last - 1 == len(pend), ('line gap', p, ln)
                for x in pend:
                    last += 1; lines.append(x)
                pend = []
                lines.append([]); last = ln
            else:
                assert not pend, (p, ln)
            k = w['parentAyahVerseKey']
            if k not in idx:
                s, v = map(int, k.split(':')); assert s == cur_s
                idx[k] = len(ay); ay.append([s, v, p])
            i = idx[k]; segs = lines[-1]
            if segs and segs[-1][0] == i: segs[-1][1] += ' ' + w['code_v1']
            else: segs.append([i, w['code_v1']])
    for x in pend:
        last += 1; lines.append(x)
    assert last <= 15, ('too many lines', p)
    pages.append(lines)
SL = H['SurahList']; PL = H['PageList']; JL = H['JuzList']; HQ = H['HizbQuarterList']
assert (len(ay), len(pages), cur_s) == (6236, 604, 114)
for s in range(1, 115):
    mine = [i for i, a in enumerate(ay) if a[0] == s]
    assert mine[0] + 1 == SL[s][0] and len(mine) == SL[s][1], ('surah mismatch', s)
    assert re.fullmatch(r'[؀-ۿ ]+', SL[s][4])
for p in range(1, 605):
    assert next(i for i, a in enumerate(ay) if a[2] == p) + 1 == PL[p], ('page mismatch', p)
surahs = [[SL[s][4], SL[s][1], SL[s][0] - 1, ay[SL[s][0] - 1][2]] for s in range(1, 115)]
out = {'ay': [a[2] for a in ay], 'pages': pages, 'surahs': surahs, 'juz': [j - 1 for j in JL[1:31]], 'hq': [h - 1 for h in HQ[1:241]]}
open(out_js, 'w', encoding='utf-8').write('window.Q=' + json.dumps(out, ensure_ascii=False, separators=(',', ':')) + ';')
print('data.js ok: 114 surahs, 6236 ayahs, 604 pages verified')
