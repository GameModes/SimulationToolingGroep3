turtles-own[partyleader choicelist radius finding
  new_choicelist ];for approval voting to get new choices


globals[ counting colorlist chosencolor chosencolorlist convertedcolor found_color tempchoicelist ;General color registration variables
  winningpoints_index winning_party_colorcode winning_party electionslist ;General counting best party variables
  loserslist worstparty_index worseparty_candidates strategyvotingcandidaten;only for Plurality strategyvoting
  ap_partyleader-points ;only Approval voting
  tempelectionslist tempchosencolorlist temp_amount_partyleader  ;temporary variables
  rivalspoints_list rivals_list] ;for get_rivals function

to setup
  clear-all
  create-turtles kandidaten + amount_partyleaders[
    set shape "circle"
    set size 0.5
    set color white
    ;; visualize the turtles from left to right in ascending order of wealth
    setxy random-xcor random-ycor
    set chosencolorlist []
    set partyleader -1

  ]
  createpartyleaders
  giveturtles_choices ;;misschien in setup? of in Plurality_run?
  reset-ticks
end

to createpartyleaders
  set temp_amount_partyleader amount_partyleaders
  set colorlist [red orange brown yellow green turquoise cyan sky blue violet magenta pink]

  loop[
    set chosencolor one-of colorlist
    set colorlist remove chosencolor colorlist
    set chosencolorlist add_to_list chosencolorlist chosencolor

    ask one-of turtles with [partyleader = -1] [set color chosencolor set partyleader temp_amount_partyleader set size 2]

    set temp_amount_partyleader temp_amount_partyleader - 1
    if temp_amount_partyleader = 0 [show chosencolorlist stop ]
  ]
end

to giveturtles_choices
  ask turtles with [ partyleader = -1 ] [ getchoices ]
end

to getchoices ;;zet voor elke kandidaat een keuze list voor de dichtbijzijnste partijleaders
  set choicelist []
  set radius 0
  set finding 1
    loop [
    set radius radius + 1
    set tempchoicelist choicelist
    ask turtles in-radius radius with [partyleader > -1] [if member? color tempchoicelist = false [set found_color color]] ;;slaat de gevonden partyleader's kleur op in een variabele genaamd found_color
    if any? turtles in-radius radius with [partyleader > -1] [if member? found_color choicelist = false [set choicelist add_to_list choicelist found_color]] ;;geeft zichzelf de kleur van de gevonden partyleader als hij zelf niet de kleur al is en verhoogt finding met +1
    if radius > 200 [stop] ;;gaat door tot het elke partyleader gevonden heeft
       ]
end


to Plurality_run
  clearboard
  set loserslist [white]
  if Plurality_Choice = "bestvoting" [
    ask turtles with [ partyleader = -1 ] [ pl-findfirstparty ]]
  if Plurality_Choice = "secondbestvoting" [
    ask turtles with [ partyleader = -1 ] [ pl-findsecondparty ]]
  if Plurality_Choice = "strategicvoting" [
    ask turtles with [ partyleader = -1 ] [ pl-findfirstparty ]
    set electionslist countcolorelections
    pl-getworstparty]

  set electionslist countcolorelections
  showelections
end

to Approval_run
  clearboard
  if Approval_Choice = "one rival voting"[

    ask turtles with [ partyleader = -1 ] [set new_choicelist first choicelist set new_choicelist (list new_choicelist)]
    set rivals_list get-rivals
    ask turtles with [ partyleader = -1 ] [ ap-removenotrivals-and-first ]
    set electionslist countpointelections
    showelections
  ]
  if Approval_Choice = "only not the worst"[
    ask turtles with [ partyleader = -1 ] [ ap-removefarthestparty ]
    ;give1point
    set electionslist countpointelections
    showelections
  ]

end

to-report get-rivals
  set rivalspoints_list []
  set rivals_list []
  set electionslist countpointelections
  set rivalspoints_list add_to_list rivalspoints_list max electionslist
  set electionslist remove-item (position max electionslist electionslist) electionslist
  set rivalspoints_list add_to_list rivalspoints_list max electionslist
  set electionslist countpointelections

  foreach rivalspoints_list [x -> set rivals_list add_to_list rivals_list item (position x electionslist) chosencolorlist ]
  report rivals_list
end

to ap-removefarthestparty
  set new_choicelist choicelist
  set new_choicelist remove 0 new_choicelist ;; if choicelist got a zero somehow
  set new_choicelist remove last new_choicelist new_choicelist ;remove last choice
end

to ap-removenotrivals-and-first
  set new_choicelist []
  set new_choicelist add_to_list new_choicelist item 0 choicelist
  ifelse member? item 0 rivals_list new_choicelist = false and member? item 1 rivals_list new_choicelist = false[ ;;check if rival color not already first choice
  foreach choicelist [x ->
    if x = item 0 rivals_list [set new_choicelist add_to_list new_choicelist item 0 rivals_list set color item 0 rivals_list stop]
    if x = item 1 rivals_list [set new_choicelist add_to_list new_choicelist item 1 rivals_list set color item 1 rivals_list stop]]]
  ;; append the closest rival to the new choice list of the turtle
  [set color item 0 new_choicelist] ;;else change color to first choice
  ;set new_choicelist add_to_list new_choicelist item 1 rivals_list



end


to pl-findfirstparty
  set color item 0 choicelist ;;get first choice
end

to pl-findsecondparty
  set color item 1 choicelist ;;get second choice
end

to-report countcolorelections
  set electionslist []
  set counting 0
  foreach chosencolorlist [x -> ;;loopt de registreerde kleuren van partyleaders
    ask turtles with [color = x] [set counting counting + 1] ;;telt de turtles met de loopende kleur in de variabele temp_counting
    set electionslist add_to_list electionslist counting ;;en voegt het toe aan de list met de functie add_to_list
    set counting 0 ] ;;reset de variabele om fouten te voorkomen
  report electionslist
end

to-report countpointelections
  set electionslist []
  foreach chosencolorlist [set electionslist add_to_list electionslist 0]
  ask turtles with [partyleader = -1]
  ;                                                   replace item with "indexnumber" in electionlist to the item from the "indexnumber" in electionlist and add 1
    [foreach new_choicelist [x -> set electionslist replace-item (position x chosencolorlist) electionslist (item (position x chosencolorlist) electionslist + 1) ]] ; ;change 1 to this
 report electionslist
end

to showelections
  output-show "-------------------"
  output-show "Pluratity Election result:"
  (foreach chosencolorlist electionslist ;;loopt door de geregisteerde partyleaders' kleurenlist en de getelde kandidatenlist van functie countcolorelections
    [ [a b] -> set convertedcolor "white" ;;zet default kleur op white
      set convertedcolor convertnetlogocode a ;;zet de netlogokleurcode om in een tekst uit de functie convertnetlogocode
      output-show word "Party: " list convertedcolor b ]) ;;print de party kleur en de hoeveelheid stemmen in een list om ze als 1 output te laten zien
 ; set winning_party getwinningparty ap_total_partyleader-points chosencolorlist
  set convertedcolor getwinningparty electionslist chosencolorlist ;;krijg de winnende partij met de functie getwinningparty
  output-show "Winning party:"
  output-show convertedcolor ;; en print de gewonnen kleur
end



to pl-getworstparty
  set worseparty_candidates 0
  ;;getworstparty method 1: not enough votes
  foreach electionslist [x -> if kandidaten * 0.1 > x [set worstparty_index position x electionslist ;;als de partij minder dan 10% van de stemmen heeft, dan is het een slechte partij
  set loserslist add_to_list loserslist item worstparty_index chosencolorlist]] ;;loserslist houdt bij welke partijen slecht zijn

  ;;getworstparty method 2: general pick the worst party
  if loserslist = [white] [
    ifelse length electionslist > 4 ;;als meer dan 4 partijen dan kies dan 2 slechte partijen
    [set worstparty_index position min electionslist electionslist
      set loserslist add_to_list loserslist item worstparty_index chosencolorlist
      set tempelectionslist remove-item worstparty_index electionslist
      set tempchosencolorlist remove-item worstparty_index chosencolorlist
      set worstparty_index position min tempelectionslist tempelectionslist
      set loserslist add_to_list loserslist item worstparty_index tempchosencolorlist]
    [set worstparty_index position min electionslist electionslist ;;anders kies er maar 1
      set loserslist add_to_list loserslist item worstparty_index chosencolorlist]]

  ask turtles with [member? color loserslist = true and partyleader = -1] [set worseparty_candidates worseparty_candidates + 1] ;;alle kandidaten die een slechte partij gekozen hebben worden geteld
  ;(add above if only percentage wants to change vote)
  pl-worstparty_change?
end

to pl-worstparty_change?
  show worseparty_candidates
  set strategyvotingcandidaten round(0.1 * worseparty_candidates)
  show strategyvotingcandidaten
  loop [
    ask one-of turtles with [member? color loserslist = true and partyleader = -1] [pl-chooseotherparty set strategyvotingcandidaten strategyvotingcandidaten - 1]
    ; only let x% (30) choose other party
    if strategyvotingcandidaten < 1 [stop]
  ]
  ;foreach loserslist [worstcolor -> ask one-of turtles with [color = worstcolor and partyleader = -1] [pl-findfirstparty]] ;the remainder chooses the same party
end

to pl-chooseotherparty
  foreach choicelist [otherparty ->
      if member? otherparty loserslist = false [set color otherparty stop]] ;;loops through the choices from best to worst and if not a bad party in general (aka in loserslist) it chooses that party
end

to-report convertnetlogocode [a]
    if a = red [set convertedcolor "red"]
      if a = orange [set convertedcolor "orange"]
      if a = brown [set convertedcolor "brown"]
      if a = yellow [set convertedcolor "yellow"]
      if a = green [set convertedcolor "green"]
      if a = turquoise [set convertedcolor "turquoise"]
      if a = cyan [set convertedcolor "cyan"]
      if a = sky [set convertedcolor "sky"]
      if a = blue [set convertedcolor "blue"]
      if a = violet [set convertedcolor "violet"]
      if a = pink [set convertedcolor "pink"]
      if a = magenta [set convertedcolor "magenta"]
  report convertedcolor
end

to-report add_to_list [a_list addons]
  ifelse a_list = []
  [set a_list insert-item 0 a_list addons ]
  [set a_list insert-item length a_list a_list addons ]
  report a_list
end

to-report getwinningparty[pointslist partylist]
  set winningpoints_index position max pointslist pointslist
  set winning_party_colorcode item winningpoints_index partylist
  set winning_party convertnetlogocode winning_party_colorcode
  report winning_party
end

to clearboard
  ask turtles with [partyleader = -1] [set color white]
end
@#$#@#$#@
GRAPHICS-WINDOW
488
10
925
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
373
33
436
66
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

PLOT
936
54
1136
204
Histrogram Elections
color code
counted amount
0.0
100.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 1 -5298144 true "" "histogram [color] of turtles"

TEXTBOX
948
235
1098
291
NIL
11
0.0
1

OUTPUT
1038
243
1382
398
11

SLIDER
19
33
191
66
kandidaten
kandidaten
10
200
23.0
1
1
NIL
HORIZONTAL

BUTTON
401
448
491
481
NIL
clearboard
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
192
33
364
66
amount_partyleaders
amount_partyleaders
1
10
3.0
1
1
NIL
HORIZONTAL

TEXTBOX
112
200
262
256
Per kandidaat stellen welke partij beter is om op te stemmen en zo hun vote te veranderen ap-firstandsecond
11
0.0
1

BUTTON
261
448
399
481
NIL
giveturtles_choices
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
18
71
165
116
Plurality_Choice
Plurality_Choice
"bestvoting" "secondbestvoting" "strategicvoting"
2

BUTTON
171
82
272
115
NIL
Plurality_run
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
169
129
275
162
NIL
Approval_run
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
17
123
167
168
Approval_Choice
Approval_Choice
"one rival voting" "only not the worst"
0

@#$#@#$#@
## WHAT IS IT?

This model shows what the candidates will vote on the certain voting system and which party's get his victory impacted by it

## HOW IT WORKS

The agents are checking in their radius, which party's and candidaten are close. The agents will choose their party depending on these. The buttons show which way they choose

## HOW TO USE IT

To begin the model use, choose the amount of candidates which should be at least 4 so 3 of them can be a partyleader. After that click setup to place them on the world. It will show on the world that there are (white) candidates and a couple partyleaders.
Then you can choose the buttons for votingsystem (row) and the way of voting (column), where 
- pl means Plurity
- ir means Instant Runoff 
- ap means Approval. 

The three ways of voting are firstparty, secondparty and strategicparty. 
- Firstparty is just voting to the nearest party, 
- secondparty is voting for the second closest
- strategicparty is voting instead for the losing party to vote for the nearest winning party.

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 6.1.1
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
0
@#$#@#$#@
