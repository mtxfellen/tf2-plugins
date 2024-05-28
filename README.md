# fellen's TF2 Plugins

Collection of various SourceMod plugins for TF2 servers (mostly for Mann vs. Machine).

## Plugin List

### tfmvm_nomapchange.smx

Reloads the current mission once it is completed, preventing the map from changing.

Syncs the "Loading next mission in # seconds..." dialog to correctly reflect the mission reload timer.

Compatiable with methods that modify `m_iszMvMPopfileName` like in the VScript example provided, as the mission name is fetched directly with `ServerCommandEx()`.

```Squirrel
// Works fine!
NetProps.SetPropString(tf_objective_resource, "m_iszMvMPopfileName", "Trespasser (Expert)")
```
