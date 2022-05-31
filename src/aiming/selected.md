# Aiming.Selected
This is a table that holds the data from `Aiming.GetClosestToCursor`. Use this to get that data, as it results in better performance because you are not calling that function.

## Structure
| Name            | Description | Type                 |
| --------------- | ----------- | -------------------- |
| `Instance`      | N/A         | `Instance<Model>`    |
| `Part`          | N/A         | `Instance<BasePart>` |
| `Position`      | N/A         | `Vector2`            |
| `Velocity`      | N/A         | `Vector3`            |
| `OnScreen`      | N/A         | `boolean`            |