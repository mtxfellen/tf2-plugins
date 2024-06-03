#if defined _tfmvm_stocks_included
  #endinput
#endif
#define _tfmvm_stocks_included

#include <sourcemod>
#include <sdktools_gamerules>

#pragma newdecls required
#pragma semicolon 1

/**
 * Retrieves the current Popfile name.
 *
 * Note: This method is preferred over retrieving m_iszMvMPopfileName as that string may be modified to update the mission name on the scoreboard.
 *
 * @param buffer		Destination string buffer.
 * @param maxlen		Destination buffer length.
 * @return				Number of chars written to the buffer, not including the null terminator.
 */
stock int TF2_GetMissionName(char[] buffer, int maxlen) {
	char Popfile[20+PLATFORM_MAX_PATH];
	ServerCommandEx(Popfile, sizeof(Popfile), "tf_mvm_popfile");

	Popfile[strlen(Popfile) - 5] = '\0';
	return strcopy(buffer, maxlen, Popfile[39]);
}

/**
 * Returns true if the current gamemode is Mann vs Machine.
 *
 * @return              True if playing MvM, false otherwise.
 */
stock bool TF2_IsPlayingMvM() {
	return view_as<bool>(GameRules_GetProp("m_bPlayingMannVsMachine"));
}

/**
 * Reloads the current mission.
 */
stock void TF2_ReloadMission() {
	char Popfile[PLATFORM_MAX_PATH];
	TF2_GetMissionName(Popfile, sizeof(Popfile));
	ServerCommand("tf_mvm_popfile %s", Popfile);
}

/**
 * Returns the current wave number.
 *
 * @param               Entity index of tf_objective_resource.
 * @return              Current wave number.
 */
stock int TF2_GetCurrentWave(int tf_objective_resource) {
    return GetEntProp(tf_objective_resource, Prop_Send, "m_nMannVsMachineWaveCount");
}

/**
 * Returns the number of waves in the current mission.
 *
 * @param               Entity index of tf_objective_resource.
 * @return              Total waves in the mission.
 */
stock int TF2_GetWaveCount(int tf_objective_resource) {
    return GetEntProp(tf_objective_resource, Prop_Send, "m_nMannVsMachineMaxWaveCount");
}

/**
 * Returns the current wave index
 *
 * @param               Entity index of tf_mann_vs_machine_stats.
 * @return              Current wave number.
 */
stock int TF2_GetCurrentWaveIndex(int tf_mann_vs_machine_stats) {
    return GetEntProp(tf_mann_vs_machine_stats, Prop_Send, "m_iCurrentWaveIdx");
}
