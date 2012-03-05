#!/usr/bin/env python

import sys
import os
import subprocess

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
        self.job_name = None
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
        
    def render(self):
        with open(self.job_name+'.ly', 'w') as out:
            out.write(self.template %{'title': self.title,
                                      'composer': self.composer,
                                      'tempo': self.tempo,
                                      'notes': self.notes})
        
    def read(self):
        f = open(self.job_name + '.txt')
        self._get_metadata(f)
        self.notes = self._get_notes(f)

    def _get_metadata(self, stream):
        for line in stream:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            if line.startswith('---'):
                break
            data = line.split(':')
            key = data[0].strip()
            value = ''.join(data[1:]).strip()
            setattr(self, key, value)

    def _get_notes(self, stream):
        for line in stream:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            next_line = next(stream, '').strip()
            if next_line:
                yield (line, next_line)
            else:
                yield (line,)

    def lily(self):
        subprocess.call(['lilypond', self.job_name + '.ly'])

    def do_it(self):
        if self.job_name is not None:
            self.read()
            self.render()
            self.lily()

if __name__ == '__main__':
    renderer = Renderer()
    renderer.job_name = sys.argv[1]
    renderer.do_it()
    