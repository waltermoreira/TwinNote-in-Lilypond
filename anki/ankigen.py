import subprocess

def note(name, octave):
    inp = open('n.ly')
    s = inp.read()
    full_note = name + octave
    out = open(full_note + '.ly', 'w')
    out.write(s %(full_note,))
    out.close()
    subprocess.call(('lilypond %s.ly' %(full_note,)).split())


if __name__ == '__main__':
    notes = ['c', 'cis', 'd', 'dis', 'e', 'f', 'fis', 'g', 'gis', 'a', 'ais', 'b']
    octaves = [",,", ",", "", "'", "''", "'''"]
    for n in notes:
        for octave in octaves:
            note(n, octave)