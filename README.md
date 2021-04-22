# boids
Goal-seeking swarms modeled in Agent Based Model tools such as NetLogo

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

Copyright (c) 2021 R. Wade Schuette, see license
wade.schuette@gmail.com 

YouTube video is scheduled to be added in February, 2021

 
