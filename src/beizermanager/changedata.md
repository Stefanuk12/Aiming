# BeizerManger.ChangeData
Creates a new Beizer Manager.

!!!note
    This also sets `Active` to `true` and `t` to `0`

## Parameters
| Name   | Description | Type            | Default |
| ------ | ----------- | --------------- | ------- |
| `self` | N/A         | `BeizerManager` | N/A     |
| `Data` | N/A         | `table`         | N/A     |

### Data Structure
| Name          | Description | Type                | Default |
| ------------- | ----------- | ------------------- | ------- |
| `StartPoint`  | N/A         | `Vector3 | Vector2` | N/A     |
| `EndPoint`    | N/A         | `Vector3 | Vector2` | N/A     |
| `Smoothness`  | N/A         | `number`            |
| `CurvePoints` | N/A         | `Vector2[2]`        | N/A     |
| `DrawPath`    | N/A         | `boolean`           | N/A     |

## Return
`nil`