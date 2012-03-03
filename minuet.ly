\version "2.14.0"

\header {
  title = "Minuet"
  composer = "(from \"Mastering the Piano\")"
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

notes = {
      \time 3/4
      \autoBeamOff

      <<
        { \tn bes''-4 a'' g'' }
      \\
        { \tn g2.-2 }
      >> \nl
      <<
        { \tn a''4-3 d''-1 d'' }
      \\
        { \tn f2. }
      >> \nl
      <<
        { \tn g''4-5  g'8-1[ a' bes'-3 c''-1] }
      \\
        { \tn ees2. }
      >>  
      <<
        { \tn d''2.-2 }
      \\
        { \tn d4-5 d'8-1 c' bes a-4 }
      >>  
      <<
        { \tn ees''4-3 f''8 ees'' d'' c'' }
      \\
        { \tn << g2-5 bes-3 >> a4-4 }
      >>  
      <<
        { \tn d''4-2 ees''8 d'' c''-1 bes'-2 }
      \\
        { \tn bes2-3 g4-5 }
      >>  

      <<
        { \tn c''4-3 d''8-4 c'' bes' c'' }
      \\
        { \tn a4-1 fis-3 g-2 }
      >> \nl 
      <<
        { \tn a'2.-1 }
      \\
        { \tn d4-5 d'8-1 c' bes-3 a-1 }
      >>  \nl
      <<
        { \tn bes''4-4 a'' g'' }
      \\
        { \tn g2.-2 }
      >> \nl
      <<
        { \tn a''4-3 d''-1 d'' }
      \\
        { \tn f2. }
      >> \nl
      <<
        { \tn g''4-5 g'8-1 a' bes'-3 c''-1 }
      \\
        { \tn ees2. }
      >> \nl
      <<
        { \tn d''2.-2 }
      \\
        { \tn d4-5 d'8-1 c' b a-4 }
      >> \nl
      <<
        { \tn f''4-4 g''8 f'' ees'' d'' }
      \\
        { \tn << b2-3 d'-1 >> g4-5 }
      >> \nl
      <<
        { \tn ees''4-3 f''8 ees'' d'' c' }
      \\
        { \tn c'4-1 a-3 f-5 }
      >> \nl
      <<
        { \tn d''4-2 g''-5 c'-1 }
      \\
        { \tn bes4-2 ees-5 << f-3 a-1 >> }
      >> \nl
      <<
        { \tn << d'2.-1 f'-2 bes'-4 >> }
      \\
        { \tn bes4-1 bes,2-5 }
      >> \nl

      \bar "|."
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


