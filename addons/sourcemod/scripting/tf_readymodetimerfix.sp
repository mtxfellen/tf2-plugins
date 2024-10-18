// tf_readymodetimerfix.sp
//  Fixes the readymode timer not aborting when the only player readied disconnects from the
//  server.
#include <sdktools_functions>
#include <sdktools_gamerules>
#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
	name        = "[TF2] Ready-up Timer Disconnect Fix",
	author      = "fellen",
	url         = "https://steamcommunity.com/profiles/76561198055313095",
	description = "Fixes the ready-up timer not aborting if the readied player disconnects.",
	version     = SOURCEMOD_VERSION
}

ConVar mp_tournament = null;
ConVar mp_tournament_readymode = null;
ConVar mp_tournament_readymode_min = null;

bool hooked_player_disconnect = false;
bool late_loaded = false;
bool playing_mvm = false;

// == GLOBAL CALLBACKS ==

public void OnPluginStart() {
	mp_tournament = FindConVar("mp_tournament");
	mp_tournament_readymode = FindConVar("mp_tournament_readymode");
	mp_tournament_readymode_min = FindConVar("mp_tournament_readymode_min");

	mp_tournament.AddChangeHook(Updated_mp_tournament);
	mp_tournament_readymode.AddChangeHook(Updated_mp_tournament);

	if (late_loaded) {
		// If we late load, we need to test our hook as the map may already be loaded.
		TestAndHook();
	}
}

// Check if we should hook on map start.
public void OnMapStart() {
	playing_mvm = view_as<bool>(GameRules_GetProp("m_bPlayingMannVsMachine"));
	TestAndHook();
}

public void OnMapEnd() {
	// Unhook event on map end.
	if (hooked_player_disconnect) {
		UnhookEvent("player_disconnect", OnGameEvent_player_disconnect);
		hooked_player_disconnect = false;
	}
}

// Track if we late loaded to use in OnPluginStart().
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	if (late)
		late_loaded = true;

	return APLRes_Success;
}

// == END GLOBAL CALLBACKS ==

// == PLUGIN CALLBACKS ==

// Check if we should hook when our mp_tournament(_readymode) status updates.
void Updated_mp_tournament(ConVar convar, char[] oldValue, char[] newValue) {
	TestAndHook();
}

// player_disconnect event hook.
Action OnGameEvent_player_disconnect(Event event, const char[] name, bool dontBroadcast) {
	int leaver = GetClientOfUserId(event.GetInt("userid"));

	// Do nothing if the player was not readied.
	if (!view_as<bool>(GameRules_GetProp("m_bPlayerReady", _, leaver)))
		return Plugin_Continue;
	// Fix a bug where player ready state is preserved between sessions.
	GameRules_SetProp("m_bPlayerReady", view_as<int>(false), _, leaver);

	// If the countdown timer is not active or uninterruptable, do nothing.
	if (playing_mvm) {
		if (GameRules_GetPropFloat("m_flRestartRoundTime") <= 10.0 + GetGameTime())
			return Plugin_Continue;
	} else if (GameRules_GetPropFloat("m_flRestartRoundTime") <=
		GetGameTime() + mp_tournament_readymode_min.IntValue) {
		// IntValue is correct here; that's what the game uses.
		return Plugin_Continue;
	}

	for (int i = 1; i <= MaxClients; ++i) {
		if (!IsClientInGame(i))
			continue;

		// Skip over the disconnecting player.
		if (i == leaver)
			continue;

		// If another player is ready, do nothing.
		if (view_as<bool>(GameRules_GetProp("m_bPlayerReady", _, i)))
			return Plugin_Continue;
	}

	// Stop the countdown timer.
	GameRules_SetPropFloat("m_flRestartRoundTime", -1.0);

	return Plugin_Continue;
}

// == END PLUGIN CALLBACKS ==


/**
 * Hooks player_disconnect if we're playing MvM or if mp_tournament_readymode 1 is set.
 * Otherwise, unhook player_disconnect if we're not.
 */
void TestAndHook() {
	if (playing_mvm ||
	 (mp_tournament.BoolValue && mp_tournament_readymode.BoolValue)
	 && !hooked_player_disconnect)
	{
		HookEvent("player_disconnect", OnGameEvent_player_disconnect);
		hooked_player_disconnect = true;
	} else if (hooked_player_disconnect) {
		UnhookEvent("player_disconnect", OnGameEvent_player_disconnect);
		hooked_player_disconnect = false;
	}
}
