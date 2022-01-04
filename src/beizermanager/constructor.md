# BeizerManger.new
Creates a new Beizer Manager.

## Parameters
| Name | Description | Type | Default |
| ---- | ----------- | ---- | ------- |
| N/A  | N/A         | N/A  | N/A     |

## Structure
| Name          | Description | Type          | Default          |
| ------------- | ----------- | ------------- | ---------------- |
| `t`           | N/A         | `number`      | `0`              |
| `tThreshold`  | N/A         | `number`      | `0.99995`        |
| `StartPoint`  | N/A         | `Vector2`     | `0, 0`           |
| `EndPoint`    | N/A         | `Vector2`     | `0, 0`           |
| `CurvePoints` | N/A         | `Vector2[2]`  | `(1, 1), (1, 1)` |
| `Active`      | N/A         | `boolean`     | `false`          |
| `Smoothness`  | N/A         | `number`      | `0.0025`         |
| `DrawPath`    | N/A         | `boolean`     | `false`          |
| `Function`    | N/A         | `function`    | `mousemoveabs`   |
| `Started`     | N/A         | `boolean`     | `false`          |

## Return
`<BeizerManager>`