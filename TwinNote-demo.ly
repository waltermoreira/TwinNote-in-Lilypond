\version "2.13.54"

%Customizing note head stencils based on pitch
%Defining stencils

upTriangle =
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

downTriangle =
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
      fill
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
	(case semitone
		((11) upTriLgr)
		((12) downTriLgr)
		(else (if (= (remainder semitone 2) 0) downTriangle upTriangle))
	)
)

%Get the pitch from the grob, convert to semitone, and send it on
#(define (stencil-notehead grob)
   (semitone-to-stencil 
	 (ly:pitch-semitones (ly:event-property (event-cause grob) 'pitch))))


%Begin stem attachment adjustment code
%Assign stem attachment values to variables

upTriUpStem 		= #'(1 . -1)
upTridownStem 		= #'(1 . .9)
downTriUpStem		= #'(1 . .9)
downTriDownStem 	= #'(1 . -1)

%Based on the pitch, is the stem up or down, 
%Then based on pitch is the note head an up or down triangle

#(define (pitch-to-stem pitch stemdir)
	(if (= (remainder (ly:pitch-semitones pitch) 2) 1) 
		(if (= UP stemdir) upTriUpStem upTridownStem)		(if (= DOWN stemdir) downTriDownStem downTriUpStem)
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



scales = \relative c' {
  c cis d dis e f fis g gis a ais b
  c cis d dis e f fis g gis a ais b c1 
  e,,2 e4 e4 
  e2. e8 e8 
  f2 f4 f8 f8
  f'2 e2 
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
  clefPosition = #(+ -6 3.5)
}
{
  \override Staff.StaffSymbol #'line-positions = #'( 4 2 -2 -4 )
  \override Staff.StaffSymbol #'ledger-positions = #'(4 -2 0 2 4)

  \override NoteHead #'stencil = #stencil-notehead
  \override NoteHead #'stem-attachment = #stem-adjuster
  \override Stem #'stencil = #doubleStemmer
  <<
    \scales
    \context NoteNames {
      \set printOctaveNames= ##f
      \scales
    }
  >>
}
