import xml.etree.ElementTree as et
import re
import os
import sys

DURATIONS = {
    'whole': 1,
    'half': 2,
    'quarter': 4,
    'eighth': 8,
    'sixteenth': 16,
    '16th': 16,
    '32nd': 32,
    '64th': 64
}
    
def tree2voices(tree):
    measures = tree.findall('.//measure')
    for measure in measures:
        notes = measure.findall('.//note')
        m = {}
        for note in notes:
            try:
                pitch = note.find('.//pitch/step').text
                octave = int(note.find('.//pitch/octave').text)
            except AttributeError:
                pitch = 'rest'
                octave = 0
            alter = note.find('.//pitch/alter')
            if alter is not None:
                alter = int(alter.text)
                pitch += ('es' if alter < 0 else 'is')*abs(alter)
            try:
                duration = note.find('.//type').text
            except AttributeError:
                duration = None
            voice = note.find('.//voice').text
            chord = 'chord' if note.find('.//chord') is not None else None
            m.setdefault(voice, [])
            m[voice].append((pitch, octave, duration, chord))
        yield m

def note2tn(note):
    pitch, octave, duration, chord = note
    if pitch == 'rest':
        return 'r%d' %(DURATIONS[duration],)
    oct_num = octave - 3
    if oct_num < 0:
        oct = ','*(-oct_num)
    elif oct_num > 0:
        oct = "'"*oct_num
    else:
        oct = ''
    return '%s%s%s' %(pitch.lower(), oct, DURATIONS[duration])
    
def _voice2tn(notes):
    for note in notes:
        if note[-1] is not None:
            yield '+'
        else:
            yield '*'
        yield note2tn(note)

def __voice2tn(notes):
    for note in re.split('\*', ''.join(_voice2tn(notes)))[1:]:
        chord = note.split('+')
        if len(chord) == 1:
            yield chord[0]
        else:
            yield '<< ' + ' '.join(chord) + ' >>'

def voice2tn(notes):
    return ' '.join(__voice2tn(notes))

def _xml2tn(tree):
    voices = tree2voices(tree)
    for measure in voices:
        for voice in measure:
            yield voice2tn(measure[voice])
        yield '\n'

def xml2tn(tree):
    return '\n'.join(_xml2tn(tree))

def convert(filename):
    name, _ = os.path.splitext(filename)
    xml = open(filename).read()
    with open(name + '.txt', 'w') as f:
        tree = et.fromstring(xml)
        f.write(xml2tn(tree))

if __name__ == '__main__':
    convert(sys.argv[1])