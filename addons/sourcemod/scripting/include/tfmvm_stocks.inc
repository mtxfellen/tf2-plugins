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
