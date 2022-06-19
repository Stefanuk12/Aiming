# NPCs
You may want to make Aiming work with NPCs and non-players. You can do this easily.

## Utilities.GetPlayers
This function returns all of the players as an array. To make this work with Aiming, replace this function and make it return all of the NPCs instead. Depending on how the game works, you may have NPCs as players or not, in which case, return those. Otherwise, returning the character of the NPCs is good enough.

## Utilities.Character
This function returns the character of a player. You need to replace this so it returns the model character of the "player". It may be the case that you just return what was given, depending on how you replaced GetPlayers.

## Ignored.IsIgnored
This function handles ignoring players. You may have to replace this and make it return true or implement your own logic for it. This also applies for all of the Ignored.* functions.

## Done
Now that you've done all that, you should be good to go. You might have to do some additional work with Checks.* though, so be careful of that. This was a *very* brief guide on how to do it, essentially treat the "players" as NPCs. If you are still stuck, there may be some example scripts out there.