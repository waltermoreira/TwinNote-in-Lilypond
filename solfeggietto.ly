\version "2.14.0"

\header {
  title = "Solfeggietto"
  composer = "C.P.E. Bach"
}
 
\paper {
  #(set-paper-size "a4")
}

%Customizing note head stencils based on pitch
%Defining stencils

upTriangleEmpty =
#(ly:make-stencil 
	(list 'embedded-ps
    "gsave
      currentpoint translate
      newpath
      -.1875 -.5 moveto
      .65625 .5 lineto
      1.5 -.5 lineto
      closepath
      0.19 setlinewidth
      stroke
      grestore" )
    (cons -.1875 1.5)
    (cons -.5 .5)
)

upTriangleFull =
#(ly:make-stencil 
	(list 'embedded-ps
    "gsave
      currentpoint translate
      newpath
      -.1875 -.5 moveto
      .65625 .5 lineto
      1.5 -.5 lineto
      closepath
      fill
      grestore" )
    (cons -.1875 1.5)
    (cons -.5 .5)
)

downTriangleEmpty =
#(ly:make-stencil 
	(list 'embedded-ps
    "gsave
      currentpoint translate

      newpath
      .08 .34 moveto
      .65625 -.4 lineto
      1.2325 .34 lineto
      closepath
      0.12 setlinewidth
      stroke      

      newpath
      -.0775 .43 moveto
      .65625 -.43 lineto
      1.39 .43 lineto
      closepath
      0.1 setlinewidth
      stroke      
	  
	  newpath
      -.1675 .48 moveto
      .65625 -.48 lineto
      1.48 .48 lineto
      closepath
      0.04 setlinewidth
      stroke

      grestore" )
    (cons -.1875 1.5)
    (cons -.5 .5)
)

downTriangleFull =
#(ly:make-stencil 
	(list 'embedded-ps
    "gsave
      currentpoint translate

      newpath
      .08 .34 moveto
      .65625 -.4 lineto
      1.2325 .34 lineto
      closepath
      0.12 setlinewidth
      stroke      

      newpath
      -.0775 .43 moveto
      .65625 -.43 lineto
      1.39 .43 lineto
      closepath
      0.1 setlinewidth
      stroke      
	  
	  newpath
      -.1675 .48 moveto
      .65625 -.48 lineto
      1.48 .48 lineto
      closepath
      fill

      grestore" )
    (cons -.1875 1.5)
    (cons -.5 .5)
)

upTriLgr = 
#(ly:make-stencil 
	(list 'embedded-ps
    "gsave
      currentpoint translate
      newpath
      -.1875 -.5 moveto
      .65625 .5 lineto
      1.5 -.5 lineto
      closepath
      0.19 setlinewidth
      stroke
	  newpath
	  -.5 0 moveto
	  1.8 0 lineto
      closepath
      .19 setlinewidth
      stroke  
      grestore" )
    (cons -.1875 1.5)
    (cons -.5 .5)
)

downTriLgr =
#(ly:make-stencil 
	(list 'embedded-ps
    "gsave
      currentpoint translate
      newpath
      .08 .34 moveto
      .65625 -.4 lineto
      1.2325 .34 lineto
      closepath
      0.12 setlinewidth
      stroke      
      newpath
      -.0775 .43 moveto
      .65625 -.43 lineto
      1.39 .43 lineto
      closepath
      0.1 setlinewidth
      stroke      
	  newpath
      -.1675 .48 moveto
      .65625 -.48 lineto
      1.48 .48 lineto
      closepath
      0.04 setlinewidth
      stroke
	  newpath
	  -.5 0 moveto
	  1.8 0 lineto
      closepath
      .19 setlinewidth
      stroke  
      grestore" )
    (cons -.1875 1.5)
    (cons -.5 .5)
)

%Based on the pitch's semitone, which note head
#(define (semitone-to-stencil semitone)
         (let ((s (modulo semitone 12)))
         	(case s
		((11) upTriLgr)
		((0) downTriLgr)
                ((2 4) downTriangleEmpty)
                ((5 7 9) upTriangleEmpty)
                ((1 3) upTriangleFull)
                ((6 8 10) downTriangleFull)
	))
)

%Get the pitch from the grob, convert to semitone, and send it on
#(define (stencil-notehead grob)
   (semitone-to-stencil 
	 (ly:pitch-semitones (ly:event-property (event-cause grob) 'pitch))))


%Begin stem attachment adjustment code
%Assign stem attachment values to variables

upTriUpStem 	= #'(1 . -1)
upTridownStem 	= #'(1 . .9)
downTriUpStem	= #'(1 . .9)
downTriDownStem	= #'(1 . -1)

%Based on the pitch, is the stem up or down, 
%Then based on pitch is the note head an up or down triangle

#(define (pitch-to-stem pitch stemdir)
	(if (= (modulo (ly:pitch-semitones pitch) 2) 1) 
		(if (= UP stemdir) upTriUpStem upTridownStem)		
		(if (= DOWN stemdir) downTriDownStem downTriUpStem)
	)
)

%Get the stem from notehead grob
#(define (notehead-get-notecolumn nhgrob)
   (ly:grob-parent nhgrob X))

#(define (notehead-get-stem nhgrob)
   (let ((notecolumn (notehead-get-notecolumn nhgrob)))
     (ly:grob-object notecolumn 'stem)))

%Get the pitch and stem direction from the grob and send it on
#(define (stem-adjuster nhgrob)
	(pitch-to-stem
	    (ly:event-property (event-cause nhgrob) 'pitch) 
		(ly:grob-property (notehead-get-stem nhgrob) 'direction) ))

%Begin double-stem for half note code
#(define (doubleStemmer grob)
   (if (= 1 (ly:grob-property grob 'duration-log))

		(ly:stencil-combine-at-edge
              (ly:stem::print grob)
              X
              (- (ly:grob-property grob 'direction))
              (ly:stem::print grob)
              -.42 0) ;; note: use .15 for other side

		(ly:stem::print grob)
	)
)

%End customization scripts

down = {
      \override Stem #'direction = #DOWN     
}

up = {
      \override Stem #'direction = #UP
}

nl = {
      \once \override Score.RehearsalMark #'transparent = ##t
      \mark "C"
}

tn = {
  \override Staff.StaffSymbol #'line-positions = #'(10 8 4 2 -2 -4 -8 -10 -14 -16 -20 -22)
  \override NoteHead #'stem-attachment = #stem-adjuster
  \override NoteHead #'stencil = #stencil-notehead
  \override Stem #'stencil = #doubleStemmer
}

notes = \relative c {
      \autoBeamOff

      \up
      ees16-2
      \down
      c-5[ ees-3 g]
      \up
      c-2[ ees-4 d c] b
      \down
      g[ b d]
      \up
      g[ f ees d]      

      \up
      ees
      \down
      c[ ees g]
      \up
      c[ ees d c]
      d[ c b a]
      g[ f ees d]

      \up
      ees  \nl
      \down
      c[ ees g]
      \up
      c[ ees d c] b
      \down
      g[ b d]
      \up
      g[ f ees d]      

      \up
      ees
      \down
      c[ ees g]
      \up
      c[ ees d c]
      d[ c b a]
      g[ f ees d]

      \up
      ees \nl
      \down
      c[ g ees c]
      \up
      c''[ g ees] aes
      \down
      f,,[ aes c f]
      \up
      aes[ c ees]

      \up
      d \nl
      \down
      bes[ f d bes]
      \up
      bes''[ f d g]
      \down
      ees,,[ g bes ees]
      \up
      g[ bes d]

      \up
      c[ \nl a]
      \down
      gis[ a]
      \up
      c[ a]
      \down
      gis[ a]
      \up
      ees'[ c]
      \down
      g[ a]
      \up
      ees'[ c]
      \down
      g[ a]

      \up
      d[ c]
      \down
      fis,[ a]
      \up
      a'[ c,]
      \down
      fis,[ a]
      \up
      fis'[ c]
      \down
      d,[ a']
      \up
      c[ a fis d]

      \up
      bes' \nl
      \down
      g,,[ bes d]
      \up
      g[ bes a g] fis
      \down
      d[ fis a]
      \up
      d[ c bes a]

      \up
      bes \nl
      \down
      g[ bes d]
      \up
      g[ bes a g]
      a[ g fis e]
      d[ c bes a]

      \up
      bes \nl
      \down
      g[ bes d]
      \up
      g[ bes a g] fis
      \down
      d[ fis a]
      \up
      d[ c bes a]

      \up
      bes \nl
      \down
      g[ bes d]
      \up
      g[ bes a g]
      a[ g fis e]
      d[ c bes a]

      \up
      << 
         { \tn bes[ g bes d] } 
      \\ 
         { \tn << g,,4 g, >> } 
      >> \nl
      \down
      g'''16[ d bes g]
      <<
         { \tn r16 g'[ d b] }
      \\
         { \tn << f,4 f, >> }
      >>
      g''16[ b d g]

      <<
         { \tn r16 g,[ g' g,] }
      \\
         { \tn << c4 ees, >> }
      >>
      <<
         { \tn r16 g16[ g' g,] }
      \\
         { \tn << c4 ees, >> }
      >>
      <<
         { \tn r16 g[ f' g,] }
      \\
         { \tn << b4 d, >> }
      >>
      <<
         { \tn r16 g[ f' g,] }
      \\
         { \tn << b4 d, >> }
      >>

      <<
         { ees'16[ c ees g] }
      \\
         { << c,,4 c, >> }
      >> \nl
      c'''16[ g ees c]
      <<
         { \tn r16 c'[ g e] c[ e g c] }
      \\
         { \tn << bes,,4 bes, >> }
      >>

      <<
         { r16 c''[ c' c,] r c[ c' c,] r c[ bes' c,] r c[ bes' c,] }
      \\
         { \tn << aes4 f' >> << aes, f' >> << g, e' >> << g, e' >> }
      >>

      \down
      aes16 \nl f,,,[ aes c]
      \up
      f[ aes g f] e
      \down
      c[ e g]
      \up
      c[ bes aes g]

      \up
      aes
      \down
      f[ aes c]
      \up 
      f[ aes g f] g[ f e d] c[ bes aes g]

      c cis d dis e f fis g gis a ais b c
      c cis d dis e f fis g gis a ais b c
}

%{ TwinNote style staff, wholetone spacing between staff positions
Note the special scheme function used for staffLineLayoutFunction  
%}

\new Staff \with {
  \remove "Accidental_engraver"
  \remove "Key_engraver" 
  staffLineLayoutFunction = #(lambda (p) (floor (/ (+ (ly:pitch-semitones p) 1) 2)))
  middleCPosition = #-6
  clefGlyph = #"clefs.G"
  clefPosition = #(+ -6 4)
}
{
  \tn
  \notes 
}


