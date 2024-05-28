# Plugin Documentation

Many of the recommended server.cfg variables listed below can be viewed [here](server_example.cfg).

## tfmvm_nomapchange.smx

This plugin will modify the values of `tf_mvm_victory_reset_time` and `tf_mvm_disconnect_on_victory` while active; you can remove these variables from your server.cfg.

The plugin sets `tf_mvm_disconnect_on_victory 0` (default) in order to display the "Loading next mission in # seconds..." dialog text instead of "Exiting to main menu in # seconds...". If you need `tf_mvm_disconnect_on_victory 1` set, then this plugin probably isn't for you anyway.

It also modifies `tf_mvm_victory_reset_time` to afford itself enough time to reload the mission before the game attempts to change map. Use the plugin's provided `sm_mvm_reloadtimer #` to manually override the time before the mission is reloaded.
