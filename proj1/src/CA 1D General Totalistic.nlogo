globals [
  current-row              ;; current row of display
  gone?                    ;; indicates a run has already been completed
  state-colors             ;; colors corresponding to state values
  max-total                ;; max total of states of cell and its neighbors
  num-rules                ;; number of rule entries = max=total + 1
  width                    ;; neighborhood size = 2 * radius + 1
  rule                     ;; transition rule table
  non-quiescent-indices    ;; list of indices of non-quiescent transitions
  config-table             ;; table of num of configs for each width and total
  pascal-triangle          ;; Pascal's triangle for computing binomial coefficients
  multiplicity             ;; num of configs for a given total
  num-virt-rules           ;; number of virtual rules (for equiv non-totalistic CA)
  lambda                   ;; Langton lambda of equiv non-totalistic CA
  entropy                  ;; entropy of equiv non-totalistic CA
  lambda-T                 ;; Langton lambda of totalistic CA
  entropy-T                ;; entropy of totalistic CA
  kappa                    ;; extended index of complexity
  kappa-R                  ;; relative extended index of complexity
  record-file-open?        ;; set if record file being created
]

patches-own [value]

to startup
  set gone? false
  set record-file-open? false
end

;; setup single cell of color-one in the top center row
to setup-single
  setup
  ask patches with [pycor = current-row]
    [ set pcolor item 0 state-colors
      set value 0 ]
;  set ([value] of patch 0 current-row) 1
  ask patch 0 current-row [set value 1]
;  set ([pcolor] of patch 0 current-row) item 1 state-colors
  ask patch 0 current-row [set pcolor item 1 state-colors]
end

;; setup cells of random distribution across the top row
to setup-random
  setup
  ask patches with [pycor = current-row]
  [ set value random states
    set pcolor item value state-colors
  ]
end

;; setup cells to spcified state colors near center of top row
to setup-specified
  setup
  ask patches with [pycor = current-row]
    [ set pcolor item 0 state-colors
      set value 0 ]
  let initials read-from-string user-input (word "Enter list of numbers in range 0 to " (states - 1))
  if not empty? filter [ [?1] -> ?1 >= states or ?1 < 0 ] initials
   [ output-show (word "Bad states not in range 0 to "
      (states - 1) ": " (filter [ [?1] -> ?1 >= states or ?1 < 0 ] initials))
     stop
   ]
  let offset length initials / 2
  foreach n-values (length initials) [ [?1] -> ?1 ]
   [ [?1] -> ;set ([value] of patch (? - offset) current-row) item ? initials
     ;set ([pcolor] of patch (? - offset) current-row) item (item ? initials) state-colors
     ask patch (?1 - offset) current-row
       [ set value item ?1 initials
         set pcolor item (item ?1 initials) state-colors ]
   ]
end

to setup
  set state-colors [ black violet blue green yellow orange red turquoise brown magenta ]
  cp ct
  set current-row max-pycor  ;; set current row to top position
  set gone? false
end

to random-full-table ;; compute random transition rule table
  set width 2 * radius + 1
  set max-total width * (states - 1)
  set num-rules max-total + 1
  set rule n-values num-rules [ random states ]
  set non-quiescent-indices n-values num-rules [ [?1] -> ?1 ]
  if quiescence
   [ set rule replace-item 0 rule 0 ;; if quiesence is set, quiescent state remains so
     set non-quiescent-indices but-first non-quiescent-indices ]
  compute-rule-parameters
end

to specify-rule
  set width 2 * radius + 1
  set max-total width * (states - 1)
  set num-rules max-total + 1
  let input-rule read-from-string
    user-input (word "Enter list of " num-rules " numbers in range 0 to " (states - 1))
  if length input-rule != num-rules or not empty? filter [ [?1] -> ?1 >= states or ?1 < 0 ] input-rule
   [ output-show "Incorrect rule table."
     stop
   ]
  set rule input-rule
  set non-quiescent-indices filter [ [?1] -> item ?1 rule > 0 ] (n-values num-rules [ [?1] -> ?1 ])
  compute-rule-parameters
end

to decimate ;; zero (make quiescent) one non-quiescent transition
  if empty? non-quiescent-indices [ stop ]
  let victim random length non-quiescent-indices
  set rule replace-item (item victim non-quiescent-indices) rule 0
  set non-quiescent-indices remove-item victim non-quiescent-indices
  compute-rule-parameters
end

to compute-rule-parameters ;; compute lambda and entropy parameters for a rule
  let quiescent-states length filter [ [?1] -> ?1 = 0 ] rule
  set lambda-T 1 - (quiescent-states / num-rules)
  let freqs n-values states [ [?1] -> count-total ?1 ]
;; Either of the following is correct, but the 2nd is more efficient
;  set entropy-T 0 - sum map [ plgp (? / num-rules) ] freqs
  set entropy-T (log num-rules 2) - (sum map [ [?1] -> plgp ?1 ] freqs) / num-rules

;; The following computes lambda and entropy for corrsponding
;; "ordinary" (non-totalistic) rule table (the "virtual" rule).
  compute-multiplicity-table
  set num-virt-rules states ^ width
  set quiescent-states sum
    map [ [?1] -> ifelse-value ((item ?1 rule) = 0) [item ?1 multiplicity] [0] ]
      n-values num-rules [ [?1] -> ?1 ]
  set lambda 1 - (quiescent-states / num-virt-rules)
  set freqs n-values states [ [?1] -> count-configs-total ?1 ]
  set entropy (log num-virt-rules 2) - (sum map [ [?1] -> plgp ?1 ] freqs) / num-virt-rules

;; The following computes the index of complexity as the number of state changes
;; between contiguous rule table entries.
  set kappa sum (map [ [?1 ?2] -> ifelse-value (?1 != ?2) [1] [0] ] (but-first rule) (but-last rule))
  set kappa-R kappa / states
end

to-report count-total [n] ;; count number of rules leading to state n
  report length filter [ [?1] -> ?1 = n ] rule
end

to-report count-configs-total [n] ;; count number of virtual rules leading to state n
  report sum
    map [ [?1] -> ifelse-value ((item ?1 rule) = n) [item ?1 multiplicity] [0] ]
      n-values num-rules [ [?1] -> ?1 ]
end

to-report plgp [p] ;; compute p lg p correctly if p=0
  ifelse p = 0
    [ report 0 ]
    [ report p * log p 2 ]
end

to compute-multiplicity-table  ;; compute table of number of nbd configs for a given total
  ;; item n (item i config-table) is the number for total n and width i+1
  compute-Pascal-triangle (max-total + width - 1)
  set config-table (list n-values num-rules [ [?1] -> ifelse-value (?1 < states) [1] [0] ])
  foreach n-values (width - 1) [ [?1] -> 1 + ?1 ]
    [ [?1] -> set config-table lput (config-row ?1) config-table ]
  set multiplicity item (width - 1) config-table
;  set multiplicity n-values num-rules [ configs-for-total ? ]
end

to-report configs-for-total [n]
  report (C (width + n - 1) n) -
    reduce [ [?1 ?2] -> ?1 + ?2 ] n-values width
      [ [?1] -> (C width (?1 + 1)) * (C (width + n - (?1 + 1) * states - 1) (width - 1)) ]
end

to-report config-row [i] ;; compute row i (1..width-1) of config-table
  report fput 1 n-values max-total [ [?1] -> configs-for i (?1 + 1) ]
end

to-report configs-for [i n] ;; compute number of configs of width i+1 for total n
  let prev-row item (i - 1) config-table
  report ifelse-value (n <= i)
   [ C (i + n) n ]
   [ sum (ifelse-value (n - states + 1 >= 0)
       [ sublist prev-row (n - states + 1) (n + 1) ]
       [ sublist prev-row 0 (n + 1) ])
   ]
end

to-report C [n r] ;; binomial coefficient C (n, r) from Pascal's triangle
  ifelse n >= r
   [ report item r (item n pascal-triangle) ]
   [ report 0 ]
end

to compute-Pascal-triangle [max-n] ;; compute binomial coefficients by Pascal's triangle
  ; C (n, r) = item r (item n pascal-triangle), for n, r = 0..max-n
  set pascal-triangle (list fput 1 n-values max-n [0])
  foreach n-values max-n [ [?1] -> 1 + ?1 ]
    [ [?1] -> set pascal-triangle lput (pascal-row ?1) pascal-triangle ]
end

to-report pascal-row [n] ;; compute new row of Pascal's triangle from preceding row
  let prev-row item (n - 1) pascal-triangle
  report fput 1 (map [ [?1 ?2] -> ?1 + ?2 ] (but-last prev-row) (but-first prev-row))
end

to setup-continue
  if not gone? [stop]

  let value-list []
  set value-list map [ [?1] -> [value] of ?1 ] sort patches with [pycor = current-row]  ;; copy cell states from the current row to a list
  cp ct
  set current-row max-pycor  ;; reset current row to top
  ask patches with [ pycor = current-row ]
  [
    set value item (pxcor + max-pxcor) value-list  ;; copy states from list to top row
    set pcolor value-to-color value
  ]
  set gone? false
end

to go
  if current-row = min-pycor  ;; if we hit the bottom row
  [
    ifelse auto-continue?  ;; continue
    [
      set gone? true
      display    ;; ensure full view gets drawn before we clear it
      setup-continue
    ]
    [
      ifelse gone?
        [ setup-continue ]       ;; a run has already been completed, so continue with another
        [ set gone? true stop ]  ;; otherwise stop
    ]
  ]
  ask patches with [pycor = current-row]
    [ do-rule ]
  set current-row (current-row - 1)
end

to do-rule  ;; patch procedure
  let next-patch patch-at 0 -1
  let total 0
  let mypxcor pxcor
  ;; set the next state of the cell based on total of neighboring state
;  set (value-of next-patch)
;    item
;    (sum values-from patches with [ pycor = current-row and (abs (pxcor - mypxcor) <= radius) ] [value])
;    rule
  foreach n-values width [ [?1] -> ?1 ]
   [ [?1] -> set total total + [value] of patch-at (?1 - radius) 0
   ]
  ;set ([value] of next-patch) item total rule
  ;; paint the next cell based on the new value
  ;set [pcolor] of next-patch (value-to-color [value] of next-patch)
  ask next-patch
   [ set value item total rule
     set pcolor value-to-color value ]
end

to-report value-to-color [v]  ;; convert cell value to color
  report item v state-colors
end

to open-record-file
  if record-file-open? [ file-close set record-file-open? false ]
  file-open user-input "Enter file name or path"
  set record-file-open? true
  setup-random
end

to close-record-file
  if record-file-open? [ file-close ]
  set record-file-open? false
end

to classify
  let class user-input "Enter class"
  if record-file-open?
   [ file-write class
     file-print (list lambda lambda-T entropy entropy-T kappa kappa-R rule)
   ]
  output-write class
  output-print (list lambda lambda-T entropy entropy-T kappa kappa-R rule)
  decimate
  setup-random
end

; Modified 2007-07-30 by Bruce MacLennan from CA 1D Totalistic by Uri Wilensky,
; which bears the following copyright:
;
; *** NetLogo 3.1.4 Model Copyright Notice ***
;
; This model was created as part of the projects:
; PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN
; CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT.
; The project gratefully acknowledges the support of the
; National Science Foundation (REPP & ROLE programs) --
; grant numbers REC #9814682 and REC-0126227.
;
; Copyright 2002 by Uri Wilensky.  All rights reserved.
;
; Permission to use, modify or redistribute this model is hereby granted,
; provided that both of the following requirements are followed:
; a) this copyright notice is included.
; b) this model will not be redistributed for profit without permission
;    from Uri Wilensky.
; Contact Uri Wilensky for appropriate licenses for redistribution for
; profit.
;
; To refer to this model in academic publications, please use:
; Wilensky, U. (2002).  NetLogo CA 1D Totalistic model.
; http://ccl.northwestern.edu/netlogo/models/CA1DTotalistic.
; Center for Connected Learning and Computer-Based Modeling,
; Northwestern University, Evanston, IL.
;
; In other publications, please use:
; Copyright 2002 Uri Wilensky.  All rights reserved.
; See http://ccl.northwestern.edu/netlogo/models/CA1DTotalistic
; for terms of use.
;
; *** End of NetLogo 3.1.4 Model Copyright Notice ***
@#$#@#$#@
GRAPHICS-WINDOW
240
10
762
277
-1
-1
2.0
1
10
1
1
1
0
1
0
1
-128
128
-64
64
0
0
1
ticks
30.0

BUTTON
120
389
225
422
Setup Single
setup-single
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
12
425
81
458
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
12
389
116
422
Setup Random
setup-random
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
85
426
225
459
auto-continue?
auto-continue?
1
1
-1000

SLIDER
12
31
120
64
states
states
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
125
32
217
65
radius
radius
0
5
1.0
1
1
NIL
HORIZONTAL

SWITCH
12
68
121
101
quiescence
quiescence
0
1
-1000

BUTTON
12
105
121
138
random rule
random-full-table
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
12
204
85
249
lambda
lambda
3
1
11

MONITOR
90
204
167
249
entropy
entropy
3
1
11

MONITOR
12
259
85
304
lambda_T
lambda-T
3
1
11

MONITOR
89
259
166
304
entropy_T
entropy-T
3
1
11

BUTTON
12
142
122
175
decimate
decimate
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
12
314
363
359
rule table
Rule
0
1
11

BUTTON
126
69
218
102
set rand seed
random-seed read-from-string user-input \"Random seed?\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
12
186
162
204
Rule Parameters:
11
0.0
0

TEXTBOX
12
10
162
28
Rule Definition:
11
0.0
0

TEXTBOX
13
371
100
389
Simulation:
11
0.0
0

BUTTON
229
389
363
422
Input Initial State
setup-specified
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
371
361
757
528
12

BUTTON
433
304
566
337
open record-file
open-record-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
570
304
704
337
close record-file
close-record-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
214
493
363
527
classify & decimate
classify
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
13
493
87
526
start test
clear-output\nrandom-full-table\nsetup-random
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
95
493
208
526
run test
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
13
473
163
491
Decimation run:
11
0.0
0

TEXTBOX
372
343
522
361
Output:
11
0.0
0

BUTTON
126
106
218
139
enter rule
specify-rule
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
173
204
237
249
NIL
kappa
0
1
11

MONITOR
172
259
237
304
kappa_R
kappa-R
3
1
11

@#$#@#$#@
## WHAT IS IT?

This program is a one-dimensional totalistic cellular automata. In a totalistic CA, the value of the next cell state is determined by the sum of the current cell and its neighbors, not by the values of each individual neighbor. The model allows you to explore the behavior of random totalistic CAs.

This model is intended for the more sophisticated users who are already familiar with basic 1D CA's. If you are exploring CA for the first time, we suggest you first look at one of the simpler CA models such as CA 1D Rule 30.

## HOW IT WORKS

Each cell may have one of several colors with the values 0 to STATES - 1.  The next state of a cell is determined by taking the sum value of the center and the neighbors on each side (as determined by RADIUS). This sum is used as an index into a state-transition table, the "rule," which defines the new state of that cell.

## HOW TO USE IT

STATES: Defines the number of states of each cell.  
RADIUS: Defines the radius on both sides of a cell used to define its new state.

SET RANDOM SEED: By setting the random seed you can repeat experiments.  
RANDOM RULE: Generates a random transition rule, with all states being equally likely.  The rule is displayed below (RULE CODE, which shows the new state for each neighborhood total), and its ENTROPY and LAMBDA parameters are computed.  
ENTER RULE: This allows you to enter a rule as a list of state values.  
QUIESCENCE: If this is turned on (the usual case), then the quiescent (0) state will be forced to map into the quiescent state. If it is not set, then the quiescent state is permitted to map into any state.  
DECIMATE: Zeros one of the non-zero entries in the rule, thus causing that neighborhood sum to map into the quiescent state.

SETUP SINGLE: Sets up a single color-two cell centered in the top row.  
SETUP RANDOM: Sets up cells of uniformly random colors across the top row.  
INPUT INITIAL STATE: Sets up cells of specified state values/colors near center of top row.  
AUTO-CONTINUE?: Automatically continue the CA from the top once it reaches the bottom row.  
GO: Run the CA.  If GO is clicked again after a run, the run continues from the top.

START TEST: Clears the output area, creates a random rule, and generates a random initial state for a decimation run.  
RUN TEST: Equivalent to GO, i.e., runs the CA as above.  It is possible to reset the initial state (e.g., randomly or to specified values) and RUN TEST again.  
CLASSIFY & DECIMATE: Based on the test run, the user types in a string descibing the behavior (e.g., "IV" or "II (long transient)").  The classification, parameters (lambda etc.), and the rule are written in the output area.  The rule is automatically decimated and the initial state randomized in preparation for another RUN TEST.  At the end of a decimation run (when the rule is all zeros), the output area can be copied and pasted into a text file when running under NetLogo (but not as an applet).  Note that you will be alternating between RUN TEST and CLASSIFY & DECIMATE.

OPEN RECORD-FILE: Open a file to receive the record of a decimation run (exactly the same information displayed in the output area, described above). You are requested to enter a filename or path. Note that you will have to have write access to directory from which this program is running or to the path.  The alternative is to copy and past from the Output area, as described above.  
CLOSE RECORD-FILE: Close the record-file and write it to disk. If you open a record-file then a previously opened record-file will be closed automatically. Note, however, that if you quit the program without closing the record file, you will lose the file's contents!

## THINGS TO NOTICE

How does the complexity of the multicolor totalistic CA differ from the two-color CA?  (see the CA 1D Elementary model)

Do most rules lead to constantly repeating patterns, nesting, randomness, or more complex behavior (Wolfram Class IV)? What does this tell you about the nature of complexity?

## THINGS TO TRY

Observe the behavior of a rule under different initial conditions (single point or random initial state).  Do different random initial states affect its qualitative behavior.

Start with a random rule and observe its behavior. Then decimate the rule, pick a new random initial state, and observe again. Continue progressively decimating the rule and look for changes in behavior (e.g., different Wolfram classes). Note if qualitative changes of behavior happen at particular values of the LAMBDA or ENTROPY parameters.

Do this decimation experiment with a number of random rules to see if you can determine which parameter best predicts the CAs qualitative behavior.

Explore the effects of different numbers of states and different neighborhood sizes on the CA's qualitative behavior.  What conditions seem to be necessary for complex (Class IV) behavior to emerge?

## EXTENDING THE MODEL

Try making a two-dimensional cellular automaton.  The neighborhood could be the eight cells around it, or just the cardinal cells (the cells to the right, left, above, and below).

## RELATED MODELS

Life - an example of a two-dimensional cellular automaton  
CA 1D Rule 30 - the basic rule 30 model  
CA 1D Rule 30 Turtle - the basic rule 30 model implemented using turtles  
CA 1D Rule 90 - the basic rule 90 model  
CA 1D Rule 250 - the basic rule 250 model  
CA 1D Elementary - a simple one-dimensional 2-state cellular automata model  
CA 1D Totalistic - a simple one-dimensional 3-state, unit-radius CA model  
CA Continuous - a totalistic continuous-valued cellular automata with thousands of states

## CREDITS AND REFERENCES

Thanks to Ethan Bakshy for his help with this model.

The first cellular automaton was conceived by John Von Neumann in the late 1940's for his analysis of machine reproduction under the suggestion of Stanislaw M. Ulam. It was later completed and documented by Arthur W. Burks in the 1960's. Other two-dimensional cellular automata, and particularly the game of "Life," were explored by John Conway in the 1970's. Many others have since researched CA's. In the late 1970's and 1980's Chris Langton, Tom Toffoli and Stephen Wolfram did some notable research. Wolfram classified all 256 one-dimensional two-state single-neighbor cellular automata. In his recent book, "A New Kind of Science," Wolfram presents many examples of cellular automata and argues for their fundamental importance in doing science.

See also:

Von Neumann, J. and Burks, A. W., Eds, 1966. Theory of Self-Reproducing Automata. University of Illinois Press, Champaign, IL.

Toffoli, T. 1977. Computation and construction universality of reversible cellular automata. J. Comput. Syst. Sci. 15, 213-231.

Langton, C. 1984. Self-reproduction in cellular automata. Physica D 10, 134-144

Langton, C. 1990. Computation at the Edge of Chaos: Phase Transitions and Emergent Computation. In Emergent Computation, ed. Stephanie Forrest. North-Holland. 

Langton, C. 1992. Life at the Edge of Chaos. In Artificial Life II, ed. Langton et al. Addison-Wesley.

Wolfram, S. 1986. Theory and Applications of Cellular Automata: Including Selected Papers 1983-1986. World Scientific Publishing Co., Inc., River Edge, NJ.

Bar-Yam, Y. 1997. Dynamics of Complex Systems. Perseus Press. Reading, Ma.

Wolfram, S. 2002. A New Kind of Science. Wolfram Media Inc.  Champaign, IL.

This model was modified 2007-08-24 by Bruce MacLennan from Uri Wilensky's CA 1D Totalistic model to compute entropy, kappa, and lambda values, and to allow entering rules and decimation, setting the random seed, specification of initial state, and control and recording of decimation runs.  This version: 2011-12-30 for NetLogo 5.0beta2.

To refer to the original model in academic publications, please use:  Wilensky, U. (2002).  NetLogo CA 1D Totalistic model.  http://ccl.northwestern.edu/netlogo/models/CA1DTotalistic.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

In other publications, please use:  Copyright 2002 Uri Wilensky.  All rights reserved.  See http://ccl.northwestern.edu/netlogo/models/CA1DTotalistic for terms of use.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0
@#$#@#$#@
setup-random
repeat world-height - 1 [ go ]
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
