;; MODEL NAME:   goal-boid-public-v1
;; DATE:  written 14-Nov-2019
;;        uploaded to modeling commons:  1-Feb-2021
;;        latest version updated 1-Feb-2021 at 6:28 AM CST (Chicago time zone )
;;
;; IF YOU DOWNLOAD THIS,  you should uncomment two sections that were
;;       commented out for running this on the web.
;;       search for word "UNCOMMENT" below to find them.

;; known bugs:
;;  *  prints stopped when all turtles succeeded twice in output
;;  *  on stop for everyone,  neither of the plots are accurate, and the last 45 or so never are caught

globals [

  stop-now?        ;; stop flag for subroutines to back up to the go command
  patch-count      ;; for this size display
  on-peak-count    ;; number of turtles on the peak
  peak-height      ;; height of highest patch
  my-center        ;; weighted centroid of all the agents, to track where it moves
  timestamp        ;; updated date-and-time to show on interface, only updated when taking snapshot
  stop-at-tick     ;; stop run when ticks >= stop-at-tick
  filechoice       ;; imported landscape jpg file name, if any

  ;; global variables defined by the interface controls
  ;; ===============================================
  ;; number-of-hits
  ;; turtle-count
  ;; rule-to-use
  ;; leave-a-trail?
  ;; run-title
  ;; turtle-color
  ;; turtle-shape
  ;; landscape-source
  ;; noise?
  ;; noise-size
  ;; noise-density
  ;; group-weight
  ;; timestamp
  ;; braking-pct   ( insert a wait X seconds into the end of the go loop for fine tuning)

;;; ============== automater's globals begin ====================
;  working-directory   ;; the operating system working directory
;  command-file        ;; where the commands will be read from
;  output-file         ;; optional, where output from the go step can be written
;  log-file            ;; a log of what commands were executed
;  run-title           ;; whatever you want to name this run
;  show-commands-as-run?        ;; controls whether you want to see commands as they are run
;  use-sample-input-file?       ;; if true, generates a file called test-01-input.txt to use
;                               ;; as input for this model.
;                               ;; This will destroy an existing file of that name!
;;; ================ automater's globals end =====================


]

turtles-own[
  wealth    ;; just equal to the pcolor of the patch the turtle is on
  on-peak?
  old-heading  ;; actually exponentially smoothed history of prior headings
  inertia      ;;  [0,1], turtle specific, weight of old-heading in updated heading, defaults to zero
  empathy      ;;  [0,1] actually misnamed to be shorter, susceptibility to group peer pressure

]

patches-own [
  height
]

to setup
  clear-all
  set timestamp date-and-time
  set stop-now? false

 ;; no-display  ( won't work over the web ! )
  if landscape-source = "generated" [make-landscape  ]
  if landscape-source = "imported"  [import-landscape]
  make-turtles
;;  display( won't work over the web ! )
  set my-center (patch 0 0)   ;; weighted centroid of the agents, dynamically updated
  ;;======================================= automaters commands begin
  ;; setup-automater
  ;;======================================= automaters commands end
  prepare-outputs
  set stop-at-tick max-ticks ;; stop normally if time is reached
  reset-ticks
end

to prepare-outputs  ;; called once during setup
  ;; select external log and output files here, if any

  ;; write experiment title and date to output area

  output-print run-title
  output-print timestamp  ;; set at start of run, not output date-and-time !
  output-print " "
  output-print (word "turtle-count: " turtle-count)
  output-print (word "rule-to-use: " rule-to-use)
  output-print (word "landscape: " landscape-source)

  if (landscape-source = "imported")
    [output-print (word "file: " filechoice)]

  ;; other experimental settings could be output here
  output-print "  "

  ;; write column headers to the output area

     (if-else
       rule-to-use = "single: wander"              [ output-print (word "turtle "   " ticks "   )  ]
       rule-to-use = "single: go-uphill"           [ output-print (word "turtle "   " ticks "    )  ]
       rule-to-use = "single: find-everyone"       [ output-print (word "turtle "   " ticks "   " group-weight: "   )  ]
       rule-to-use = "pair: uphill with inertia"   [ output-print (word "turtle "   " ticks "   " inertia "  )  ]
       rule-to-use = "pair: uphill with everyone"  [ output-print (word "turtle "   " ticks "   " group-weight "  )  ]
       rule-to-use = "triple: use all three"       [ output-print (word "turtle "   " ticks "   " group-weight "   " inertia "   )  ]
        ; else commands
    [ error (word " unexpected rule-to-use choice: " rule-to-use) ]
   )



end

;; IMPORT LANDSCAPE only works in downloaded version
;;  commented out for web-based version

to import-landscape
  print "landscape importing only works on downloaded versions."
end

;; UNCOMMENT THIS SECTION to enable importing of land-profile images!!
;to import-landscape
;  set filechoice user-file
;  if-else filechoice = false [
;    print " no file selected!"
;    print (word  "Importing file " user-file " failed, geneating file locally")
;    set landscape-source "generated"
;    make-landscape
;  ]
;
;  [
;    print (word "You asked to import this landscape file: " filechoice)
;
;    ;; UNFINISHED -- verify this is a jpg file!
;
;    import-pcolors filechoice
;      ask  max-one-of patches [pcolor] [set peak-height pcolor]
;      ask patches [ set height pcolor]
;     ;; ask patches [ set pcolor scale-color red height 0 peak-height ]
;  ]
;end

to go

  ;; WARNING -- this will not print final output if stopped by interface
  if stop-now? [ print "Stop was requested by a subroutine" stop ]

  if ticks > stop-at-tick [wrap-up-run stop]  ;; prevent runaway models from consuming computer time

  if all? turtles [on-peak?]
  [    wrap-up-run stop ]

  move-turtles
    if stop-now? [ print "Stop was requested by a subroutine." stop ]
    if stop-now? [ error "stop was requested but failed" ]
  update-status

  if braking-pct > 0 [ wait ( braking-pct / 100) ]  ;; slowdown despite top master speed switch

  tick
end

to wrap-up-run ;; wrap up the entire run
  ;; this is a place-holder
  ;; print "any wrapping up will go here", such as writing output to a file

  if (ticks >= stop-at-tick) [
    print (word "stopped at time limit, ticks = " ticks)
    output-print (word "stopped at time limit, ticks = " ticks)
  ]

  if (stop-now?)   [
    print (word "stopped unexpectedly, ticks = " ticks)
    output-print (word "stopped unexpectedly, ticks = " ticks)
  ]

   if-else (all? turtles [on-peak?])  [
    print (word "stopped when all turtles succeeded, ticks = " ticks)
    output-print (word "stopped when all turtles succeeded, ticks = " ticks)
   ]
   [
    print ( word "count of turtles not yet on the peak: " count turtles with [on-peak? = false] )
    output-print ( word "count of turtles not yet on the peak: " count turtles with [on-peak? = false] )
   ]

   ;; for inertia plot, set the time to 100 and plot the straglers
      if   rule-to-use = "pair: uphill with inertia"   [

            set-current-plot "inertia-influence"
            ;;plotxy inertia ticks

             ask turtles with [on-peak? = false ]
            [
                 let cluster-show 98 + random-float 2
                 plotxy inertia cluster-show  ;
                 output-print   (word   " ? " "        " cluster-show )
            ]
    ]

  ;; for group plot, set the time to 100 and plot the straglers
     if   rule-to-use = "pair: uphill with everyone"   [

            set-current-plot "social-influence"

            ask turtles with [on-peak? = false ]
               [
                  let cluster-show2 98 + random-float 2
                  plotxy empathy cluster-show2 ;
                  output-print   (word   " ? " "        " cluster-show2  "       " 1.0 " (forced) "       )
               ]

       ]
end

to update-status

 set on-peak-count count turtles with [on-peak?]

;; ======================================================= automater code begins
;;   file-open output-file
;;   file-print (word "turtles on peak: " on-peak-count)
;;======================================================== automater code ends

end

to-report centroid      ;; compute center of the swarm, weighted by wealth

  ;; side-effect:  this sets the global variable my-center
  let sumx 0
  let sumy 0
  let sumx-wealth 0
  let sumy-wealth 0

  ask turtles [
    set sumx sumx +(pxcor * wealth)
    set sumx-wealth sumx-wealth + wealth

    set sumy sumy +(pycor * wealth)
    set sumy-wealth sumy-wealth + wealth
  ]

  ;; at set-up avoid division by zero
  if-else ( sumx-wealth > 0 )
  [ set sumx sumx / sumx-wealth
    set sumy sumy / sumy-wealth]
  [ set sumx 0  set sumy 0 ]       ;; put centroid in the center on first pass

  set my-center (patch sumx sumy)

  report (list sumx sumy)
end

; =========== turtle movement commands ===============
to wrap-up-step  ;;    Utility, called by every rule, in every step, in a turtle context
    set wealth height ;   transfer patch parameter to a turtle parameter

    ;; This output relies on the various move steps ONLY being called for
    ;; turtles that were not already at peak height.  Otherwise, this
    ;; will generate way too much output!!

    if  height = peak-height   ;; did we just reach the peak?
      [
        set on-peak? true
        set color green
        set label ""

       (if-else
          rule-to-use = "single: wander"              [ output-print (word   who "        " ticks                        )  ]
          rule-to-use = "single: go-uphill"           [ output-print (word   who "        " ticks                        )  ]
          rule-to-use = "single: find-everyone"       [ output-print (word   who "        " ticks  "       " group-weight    )  ]
          rule-to-use = "pair: uphill with inertia"   [ output-print (word   who "        " ticks  "       " inertia         )

            set-current-plot "inertia-influence"
            set-current-plot-pen "default"
            plotxy inertia ticks




        ]
          rule-to-use = "pair: uphill with everyone"  [ output-print (word   who "        " ticks  "       " group-weight    )



    set-current-plot "social-influence"
    set-current-plot-pen "default"
    plotxy empathy ticks




        ]
          rule-to-use = "triple: use all three"       [ output-print (word   who "        " ticks  "       " group-weight "       " inertia )

            set-current-plot "inertia-influence"
            set-current-plot-pen "default"
            plotxy inertia ticks


            set-current-plot "social-influence"
            set-current-plot-pen "default"
            plotxy empathy ticks




        ]
           ; else commands
          [ error (word " unexpected rule-to-use choice: " rule-to-use) ] )

      ]




end

to go-wander

    ask turtles with [not on-peak?] [

      set heading heading + random 45
      set heading heading - random 45

      step-or-reverse ( 1 )

      ;;set wealth height
      wrap-up-step
   ]
end

to step-or-reverse [ size-of-step ]
         if-else  can-move? size-of-step  [forward size-of-step][ set heading heading + 180 forward size-of-step]
         ;; WARNING -- fails in a corner
end

to-report uphill-heading
    ;; heading is in degrees , 0 to 360
    ;; hard-codes a search radius

    let search-radius 2.5

   ;; ask turtles with [not on-peak?] [
        let old-patch patch-here
        let neighborhood patches with [ distance myself < search-radius ]
        let target max-one-of neighborhood [height ]
        face target             ;; WARNING -- side-effect
        report heading
   ;; ]

end

to go-uphill
     ;; hard-codes a step size
     let step-size 1

     ask turtles with [not on-peak?] [
     set heading uphill-heading

     step-or-reverse ( 1 )

      wrap-up-step
      ]
end

to go-find-everyone  ;;  centroid and my-center needs to be refactored

   ;; first, comput the  weighted centroid of all the turtles
   let new-centroid (list 0 0)
   set new-centroid centroid  ;; sets global my-center as side-effect
                              ;; computes new-centroid but only uses the side effect
                              ;; WARNING -- twisted way of simply setting my-center

   ask turtles with [not on-peak?] [

       ;; let old-patch patch-here ;; obsolete??
       face my-center
       step-or-reverse ( 1 )
       wrap-up-step
   ]

end



to go-uphill-inertia   ;; draft

    ask turtles with [not on-peak?] [

         set label inertia

         let old-patch patch-here ;;  used????

         let heading-uphill uphill-heading

         set heading ( inertia * old-heading) + (1 - inertia) * heading-uphill
         step-or-reverse ( 1 )
         set old-heading heading ;;   this is a turtle-own variable
         wrap-up-step

    ]
end

to go-use-all-rules    ;; runs but not validated, not even one full walk-through

    ;; first, compute the  weighted centroid of all the turtles
   let new-centroid (list 0 0)
   if ticks > 1 [ set new-centroid centroid ]  ;; can't run on first tick because weath is zero and get division error
   ;;  type "centroid is " show new-centroid

  ask turtles with [not on-peak?] [

    let old-patch patch-here

    ;; let's find what heading goes uphill

    let target max-one-of neighbors [height]
    face target
    let heading-uphill heading

    ;; ok soften that with inertia

           set heading-uphill ( inertia * old-heading) + (1 - inertia) * heading-uphill

         set old-heading heading ;;   this is a turtle-own variable


    face my-center
    let heading-group heading

    set heading (empathy)*(heading-group) + (1 - empathy)*(heading-uphill)
   ;; set heading (group-weight)*(heading-group) + (1 - group-weight)*(heading-uphill)


    step-or-reverse ( 1 )
    set old-heading heading ;;   this is a turtle-own variable

    wrap-up-step
  ]
end

to go-uphill-everyone  ;;draft

   ;; first, comput the  weighted centroid of all the turtles
   let new-centroid (list 0 0)
   if ticks > 1 [ set new-centroid centroid ]  ;; can't run on first tick because weath is zero and get division error
   ;;  type "centroid is " show new-centroid

  ask turtles with [not on-peak?] [

    let old-patch patch-here

    ;; let's find what heading goes uphill

    let target max-one-of neighbors [height]
    face target
    let heading-uphill heading

    face my-center
    let heading-group heading

    set heading (empathy)*(heading-group) + (1 - empathy)*(heading-uphill)
   ;; set heading (group-weight)*(heading-group) + (1 - group-weight)*(heading-uphill)


    step-or-reverse ( 1 )
    wrap-up-step

   ]


end

;================end of turtle movement commands =======

to snapshot   ;;  save a picture of the whole interface to disk,   bare bones draft only
  ;; ask for a file-name
  ;; This should set a directory and base file name then increment a number add .jpg and save silently
  set timestamp date-and-time
  print " export snapshot only works locally "

  ;; UNCOMMENT the next line to save a snapshot of the image to disk
  ;;export-interface user-new-file
  ;; print OK
end

to apologize
  print " that function is not yet working!"
  set stop-now? true
end

to move-turtles

  if-else leave-a-trail? [ ask turtles [ pen-down ]]   [ ask turtles [ pen-up ]]

  (if-else
  rule-to-use = "single: wander"              [ go-wander          ]
  rule-to-use = "single: go-uphill"           [ go-uphill          ]
  rule-to-use = "single: find-everyone"       [ go-find-everyone   ]
  rule-to-use = "pair: uphill with inertia"   [ go-uphill-inertia  ]
  rule-to-use = "pair: uphill with everyone"  [ go-uphill-everyone ]
  rule-to-use = "triple: use all three"       [ go-use-all-rules   ]
   ; else commands
    [ error (word " unexpected rule-to-use choice: " rule-to-use) ]
   )

  ;;set stop-now? false

end

to make-landscape

  set patch-count count  patches;

  ask patch -7 -4  [set pcolor 125]  ;; always make at least one hill
  if number-of-hills >= 2 [  ask patch  3 6  [set pcolor 95] ]
  if number-of-hills >= 3 [  ask patch  7 -5  [set pcolor 75] ]

  repeat 15 [ diffuse pcolor 1]  ;; smooth that out somewhat

    if noise?
  [ ask N-of (  noise-density * patch-count) patches [set pcolor pcolor + noise-size]  ]

   repeat 2 [ diffuse pcolor 1]  ;; smooth the noise

  ask  max-one-of patches [pcolor] [set peak-height pcolor]
  ask patches [ set height pcolor]
  ask patches [ set pcolor scale-color red height 0 peak-height ]

end

to make-turtles

  ; set the turtle color from the user menu
  let use-color green  ;; default
  if turtle-color = "green" [ set use-color green ]
  if turtle-color = "white" [ set use-color white ]
  if turtle-color = "black" [ set use-color black ]
  if turtle-color = "red"   [ set use-color red ]


   create-turtles turtle-count [      ;;  turtle-count is set by a slider
     setxy random-xcor random-ycor
     set on-peak? FALSE
     set color use-color
     set size 2
     set shape turtle-shape
     set wealth 0

    if-else ( randomize-inertia? )  [
      set inertia precision (random-float 1) 2
    ]
    [ set inertia inertia-static ]

     if-else ( randomize-group-weight? )
      [set empathy precision (random-float 1) 2 ]                ;; set to random uniform on [0,1]
      [set empathy group-weight]                                 ;; set in slider
  ]
end

to help
  ;; UNCOMMENT this section if you have a help file on your local PC

;if-else file-exists? "help-for-goals.txt"
;  [
;    file-open "help-for-goals.txt"
;    while [not file-at-end? ]
;    [print file-read-line]
;    file-close
;  ]
;  [
    print "The help file 'help-for-goals.txt' was not found!"
;  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
20
200
75
233
NIL
setup
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
140
200
195
233
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
20
70
195
103
turtle-count
turtle-count
0
100
49.0
1
1
NIL
HORIZONTAL

MONITOR
10
315
67
360
turtles
count   turtles
17
1
11

MONITOR
77
316
201
361
turtles on best peak
on-peak-count
17
1
11

PLOT
6
365
206
515
% turtles on best peak
time
percent success
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot 100 * (on-peak-count / count turtles)"

CHOOSER
20
20
195
65
number-of-hills
number-of-hills
1 2 3
0

SWITCH
665
125
835
158
noise?
noise?
0
1
-1000

SLIDER
665
155
837
188
noise-size
noise-size
0
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
665
185
837
218
noise-density
noise-density
0
1
0.25
0.05
1
NIL
HORIZONTAL

SLIDER
665
235
855
268
group-weight
group-weight
0
1
0.2
0.05
1
NIL
HORIZONTAL

CHOOSER
20
110
195
155
rule-to-use
rule-to-use
"single: wander" "single: go-uphill" "single: find-everyone" "pair: uphill with inertia" "pair: uphill with everyone" "triple: use all three"
5

SWITCH
20
160
195
193
leave-a-trail?
leave-a-trail?
0
1
-1000

CHOOSER
660
20
752
65
turtle-color
turtle-color
"white" "black" "red" "green"
0

CHOOSER
750
20
845
65
turtle-shape
turtle-shape
"arrow" "turtle" "person" "default"
3

CHOOSER
660
65
845
110
landscape-source
landscape-source
"generated" "imported"
0

BUTTON
675
425
738
458
NIL
help
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
760
425
842
458
NIL
snapshot
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
670
465
845
510
NIL
timestamp
17
1
11

OUTPUT
875
375
1200
510
11

INPUTBOX
210
460
645
520
run-title
Exploring space
1
0
String

BUTTON
80
200
135
233
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

TEXTBOX
890
220
1100
250
Output shows turtles reaching the peak
11
0.0
1

PLOT
875
185
1190
365
inertia-influence
inertia
runtime
0.0
1.1
0.0
100.0
false
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" " "

PLOT
875
10
1185
175
social-influence
empathy
run-time
0.0
1.0
0.0
101.0
false
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" ""

SLIDER
20
270
195
303
braking-pct
braking-pct
0
100
0.0
5
1
NIL
HORIZONTAL

SWITCH
665
265
857
298
randomize-group-weight?
randomize-group-weight?
0
1
-1000

SLIDER
670
315
842
348
inertia-static
inertia-static
0
1
0.25
0.05
1
NIL
HORIZONTAL

SLIDER
20
235
192
268
max-ticks
max-ticks
0
200
100.0
25
1
NIL
HORIZONTAL

SWITCH
670
345
845
378
randomize-inertia?
randomize-inertia?
0
1
-1000

TEXTBOX
10
535
1180
591
<------------------------------------This interface is this wide --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This models the ability of a swarm to reach a goal based on communication, memory, and observations limited by distance and noise.      

The model also allows agents to learn over time what rules seem to work,
and co-evolve cultural wisdom which is passed on to new agents.

It can be used to study evolution of cultural shared opinions ( tribes )
as well as robustness of the overall planet to sudden changes in 
the landscape properties. ( once learned does behavior perseverate ? ) 

## TAGS
computational social-science, education, policy-making, polarization, peer-pressure,
cancel-culture, sharing, humility, cultural-evolution, culture-robustness

## WHAT IS THE PURPOSE OF THE MODEL AND INTENDED AUDIENCE?

People of all ages might enjoy seeing what kind of problems occur in such a 
"simple" situation.   Everyone can relate.

More serious students of decision-theory could find insight into the understudied
question of how to make an optimal decision in a noisy world.

Lessons can be setup at selected points in complexity for maximum 
Axelrod-impact on segmented audiences by being near to them and familiar

## HOW IT WORKS CONCEPTUALLY
 
  * there are mountains of "wealth" where higher on the hill represents
    more wealth.  the swarm of agents move across this landscape and
    seek to get all of them on the highest peak of wealth.

  * Agents are initally distributed randomly across the landscape.  There are
    no links between agents.  Agents cannot see what wealth other agents have.

  * Agents all have the same set of rules and rules don't change during the run.

  * Different rules can be selected for testing.

  * At each tick, one random agent makes a decision about which direction is
    best to move.  They base this decision by trade-offs between

	* a global observation: where is everyone else ?
        * a local observation : which way appears to be "uphill" ? 
        * memory:  which way have I been moving recently?

        Then they either move one step forward and their wealth changes too
        the wealth of the new patch, or they can elect to stay where they are.

   * The run stops when all agents have reached the highest peak of wealth,
     or after a maximum time-limit

   * The same situation can be tested using different rules to see what
     impact the rules have on the results.

   * The same rules can be tested against different landscapes to see if 
     they work as well.


## WHY IS THIS NON-TRIVIAL?

   If there were only one smooth hill of wealth,  a very simple hill-climbing
   rule would succeed:   Everyone just move whatever way is locally uphill.
   You can set that up and see it work.

   But, there are real-world complications to finding the best place, and
   these cause the simple hill-climbing rule to fail.

   There might be more than one large-scale hill, so agents will get stuck
   on the wrong large hill.  You can try that out and see. 

   There might be small-scale variations on the landscape 
   (it may be "noisy" and not smooth ) so agents
    might get trapped on a local bump.  You can see that in action.

   The landscape might have blind-alleys where the "go uphill" rule fails 
   on a location that is not even the top of any hill. An example that
   generates a blind-alley can be tried out.

   Finally, there might be actual obstacles to travel in the landscape, 
   such as walls.  How well do rules work if there are such obstacles?
   A few such worlds have been supplied as examples that can be imported
   into the model to explore.  Advanced users could make others to import.

   We've all been stuck in a blind-alley or behind an obstacle.  Are there
   rules that can get you unstuck?
   


## WHAT ARE THE INTERESTING QUESTIONS?

This illustrates the problems of trying locate the best point in a noisy fitness landsape.  How can agents avoid being trapped on a local maximum?

What are the trade-offs between observation and memory?

Agents can communicate, so strategies that involve jointly locating a best 
point are useful, such as moving towards each other,  but these have a downside
of too much coherence, in that everyone may end up into small clusters that are near each other, but still far from the best hill. 

Agents can also effectively smooth out the landscape by remembering which way they
have been moving,  and consider that as important as the local "uphill" measurement
in deciding which way is "up".  

Is there a "best" algorithm that works for all combinations of long-range and
short-range noise?


## IMPORTANT LIFE LESSONS THE MODEL HELPS CONVEY

*  Being "greedy" is not always the best rule.
   (A series of "best" short-run decisions does not always get you to the best
    possible long-term result.)

   possible application area:   public policy,  Congressional "progress".

* The best rule may still fail in some situations.  ( A bad outcome doesn't
  mean that a bad policy was used.)

   possible application:   evaluating doctors or policy-makers

* Sometimes it pays to be slow to change one's opinion. 

* What is "obvious" ( locally ) and what is real (globally) may differ.

    possible application:  intellectual humility

* Sometimes you have to just try and see what happens.

    pososible application:   more tolerance for "mistakes" by self and others

## HOW IS THE MODEL IMPLEMENTED IN NETLOGO?


  * the world wraps horizontally and vertically
  * N turtles are created in random locations.  N is a slider choice
  * all turtles follow the same rules ( There is no wisdom-distribution )
  * turtles don't communicate with each other or see each other

  *??? agents cannot see what wealth other agents have.

 ( variant of model, let them discover it and broadcast it
            as a population, gradually )

  * each turtle has two local rules at each tick
     (1) if it is possible to move uphill locally, do so and
     reset own wealth to the local pcolor value
      ELSE
     (2) if turtle is at a local maximum
    and realizes it is not the current best GLOBAL max,
      turn blue, and take a leap of size (3 + random 4) in a random direction
     OTHERWISE ... turn green and stay there
 
 
  The success of a migration critically depends on ability to get off a local maximum
 in this version ( hill-climbing-03) the leap step is simply
 forward (3 + random 4) in a random direction  ( varies with iteration )
 and is the same for every turtle
  These "magic numbers" are buried at the bottom of the move-turtles section
 and were picked for convenience because they worked out for the given hill locations
 and shapes used for developing the code


## HOW TO USE IT

 [ coming, Feb 2021 ]

## THINGS TO NOTICE

 [ coming, Feb 2021 ]

## THINGS TO TRY

 [ coming, Feb 2021 ]

## EXTENDING THE MODEL

 [ coming, Feb 2021 ]

## NETLOGO FEATURES

 [ coming, Feb 202
1 ]
## RELATED MODELS
 
 The hill creation code is inspired from the "Hill Climbing example" model

## CREDITS AND REFERENCES

Copyright (c) 2021 R. Wade Schuette, all rights reserved.
wade.schuette@gmail.com 

YouTube video is scheduled to be added in February, 2021

 
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
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
1
@#$#@#$#@
