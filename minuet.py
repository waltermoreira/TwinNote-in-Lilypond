
notes = [
    [" bes''-4 a'' g'' ",
     " g2.-2 "],
    [" a''4-3 d''-1 d'' ",
     " f2. "],
    [" g''4-5  g'8-1[ a' bes'-3 c''-1] ",
     " ees2. "],
    [" d''2.-2 ",
     " d4-5 d'8-1 c' bes a-4 "],
    [" ees''4-3 f''8 ees'' d'' c'' ",
     " << g2-5 bes-3 >> a4-4 "],
    [" d''4-2 ees''8 d'' c''-1 bes'-2 ",
     " bes2-3 g4-5 "],
    [" c''4-3 d''8-4 c'' bes' c'' ",
     " a4-1 fis-3 g-2 "],
    [" a'2.-1 ",
     " d4-5 d'8-1 c' bes-3 a-1 "],
    [" bes''4-4 a'' g'' ",
     " g2.-2 "],
    [" a''4-3 d''-1 d'' ",
     " f2. "],
    [" g''4-5 g'8-1 a' bes'-3 c''-1 ",
     " ees2. "],
    [" d''2.-2 ",
     " d4-5 d'8-1 c' b a-4 "],
    [" f''4-4 g''8 f'' ees'' d'' ",
     " << b2-3 d'-1 >> g4-5 "],
    [" ees''4-3 f''8 ees'' d'' c'' ",
     " c'4-1 a-3 f-5 "],
    [" d''4-2 g''-5 c''-1 ",
     " bes4-2 ees-5 << f-3 a-1 >> "],
    [" << d'2.-1 f'-2 bes'-4 >> ",
     " bes4-1 bes,2-5 "],
    [r' \bar "|."']
]

def _render(notes):
    for bar in notes:
        if len(bar) == 1:
            yield bar[0]
        else:
            top, bottom = bar
            yield '<< { \\tn '
            yield top
            yield ' }\n\\\\ { \\tn '
            yield bottom
            yield '} >> \\nl\n'

def render(notes):
    return ''.join(_render(notes))

class Renderer(object):

    TEMPLATE_FILE = 'tnpiano.ly.template'
    
    def __init__(self):
        self.template = open(self.TEMPLATE_FILE).read()
        self.title = '(self.title)'
        self.composer = '(self.composer)'
        self.tempo = '4/4'
        self.notes = []

    @property
    def notes(self):
        return self._rendered_notes

    @notes.setter
    def notes(self, value):
        self._notes = value
        self._rendered_notes = render(value)
        
    def render(self, to):
        with open(to, 'w') as out:
            out.write(self.template %{'title': self.title,
                                      'composer': self.composer,
                                      'tempo': self.tempo,
                                      'notes': self.notes})
        
