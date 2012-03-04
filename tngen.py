import os

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
        d = os.path.dirname(os.path.abspath(__file__))
        self.template = open(os.path.join(d, self.TEMPLATE_FILE)).read()
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
        
