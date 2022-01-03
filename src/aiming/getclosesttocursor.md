# Aiming.GetClosestToCursor
Gets the closest player (or NPC) along with part, position, and whether they are on screen. It then sets those variables to `Aiming.Selected`

!!! note
    Do not call this function, use `Aiming.Selected` instead. This holds the data resulting in better performance in general as you are not calling the function many, many times.

## Parameters
| Name | Description | Type | Default |
| ---- | ----------- | ---- | ------- |
| N/A  | N/A         | N/A  | N/A     |

## Return
nil