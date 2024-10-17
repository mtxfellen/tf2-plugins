# fellen's TF2 Plugins

Collection of various SourceMod plugins for TF2 servers (mostly for Mann vs. Machine).

## Plugin List

### tf_readymodetimerfix

Fixes the readymode timer not aborting when the only player readied disconnects from the server.

Automatically activates when playing MvM, or when `mp_tournament_readymode 1` is set.

### tfmvm_nomapchange

Reloads the current mission once it is completed, preventing the map from changing.

Syncs the "Loading next mission in # seconds..." dialog to correctly reflect the mission reload timer.

Compatiable with methods that modify `m_iszMvMPopfileName` like in the VScript example provided, as the mission name is read from `ServerCommandEx()`.

```Squirrel
// Mission reloads fine!
NetProps.SetPropString(tf_objective_resource, "m_iszMvMPopfileName", "Trespasser (Expert)")
```
