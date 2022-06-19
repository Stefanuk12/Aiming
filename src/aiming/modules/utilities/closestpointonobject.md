# Utilities.ClosestPointOnObject
Gets the closest point on an object. This is really useful for making legit aimbot and silent aim.

!!! note
    `OriginPoint` **must** be lined up on the same "plane" as the object, if `OriginPoint` is **NOT** a ray.

## Parameters
| Name          | Description | Type                 | Default |
| ------------- | ----------- | -------------------- | ------- |
| `OriginPoint` | N/A         | `Vector3 | Ray`      | N/A     |
| `Object`      | N/A         | `Instance<BasePart>` | N/A     |

## Return
`<Vector3>` Closest Point