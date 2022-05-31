# Aiming.Settings
This is a table that holds all of the settings, along with one function that allows you to get a setting.

## Aiming.Settings.Get
This function allows you to get a setting.

### Parameters
This is a vararg, just input the path to the settings. For example: `"HitChance"` or `"FOVSettings", "Enabled"`

### Return
`<any>` Setting

## Structure
| Name             | Description | Type                                 |
| ---------------- | ----------- | ------------------------------------ |
| `Enabled`        | N/A         | `boolean`                            |
| `VisibleCheck`   | N/A         | `boolean`                            |
| `HitChance`      | N/A         | `number`                             |
| `TargetPart`     | N/A         | `string | string[]`                  |
| `RaycastIgnore`  | N/A         | `<Instance[]> function | Instance[]` |
| `FOVSettings`    | N/A         | `see below`                          |
| `TracerSettings` | N/A         | `see below`                          |
| `Ignored`        | N/A         | `see below`                          |

### FOVSettings
| Name      | Description | Type               |
| --------- | ----------- | ------------------ |
| `Circle`  | N/A         | `<Drawing> Circle` |
| `Enabled` | N/A         | `boolean`          |
| `Scale`   | `FOV`       | `number`           |
| `Sides`   | N/A         | `number`           |
| `Colour`  | N/A         | `Color3`           |

### TracerSettings
| Name      | Description | Type             |
| --------- | ----------- | ---------------- |
| `Circle`  | N/A         | `<Drawing> Line` |
| `Enabled` | N/A         | `boolean`        |
| `Colour`  | N/A         | `Color3`         |


### Ignored
| Name              | Description | Type                                 |
| ----------------- | ----------- | ------------------------------------ |
| `WhitelistMode`   | N/A         | `<Players: boolean, Teams: boolean>` |
| `Teams`           | N/A         | `<Team: Team, TeamColor: Color3>[]`  |
| `IgnoreLocalTeam` | N/A         | `boolean`                            |
| `Players`         | N/A         | `Instance<Player> | number`          |