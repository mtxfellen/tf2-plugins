#include <sourcemod>
#include <sdktools_functions>

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

int tf_gamerules = -1;
bool hooked_player_disconnect = false;
bool late_loaded = false;

public void OnPluginStart() {
	mp_tournament = FindConVar("mp_tournament");
	mp_tournament_readymode = FindConVar("mp_tournament_readymode");

	mp_tournament.AddChangeHook(Updated_mp_tournament);
	mp_tournament_readymode.AddChangeHook(Updated_mp_tournament);

	if (late_loaded) {
		tf_gamerules = FindEntityByClassname(-1, "tf_gamerules");
		TestAndHook();
	}
}

void Updated_mp_tournament(ConVar convar, char[] oldValue, char[] newValue) {
	TestAndHook();
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	if (late)
		late_loaded = true;

	return APLRes_Success;
}

public void OnMapStart() {
	tf_gamerules = FindEntityByClassname(-1, "tf_gamerules");
	TestAndHook();
}

public void OnMapEnd() {
	tf_gamerules = -1;

	if (hooked_player_disconnect) {
		UnhookEvent("player_disconnect", OnGameEvent_player_disconnect);
		hooked_player_disconnect = false;
	}
}

Action OnGameEvent_player_disconnect(Event event, const char[] name, bool dontBroadcast) {
	if (GetEntPropFloat(tf_gamerules, Prop_Send, "m_flRestartRoundTime") == -1.0)
		return Plugin_Continue;

	for (int i = 1; i <= MaxClients; ++i) {

		if (!IsClientInGame(i))
			continue;

		if (IsFakeClient(i))
			continue;
		
		if (view_as<bool>(GetEntProp(tf_gamerules, Prop_Send, "m_bPlayerReady", _, i)))
			return Plugin_Continue;
	}

	SetEntPropFloat(tf_gamerules, Prop_Send, "m_flRestartRoundTime", -1.0);
	return Plugin_Continue;
}

void TestAndHook() {
	if (view_as<bool>(GetEntProp(tf_gamerules, Prop_Send, "m_bPlayingMannVsMachine"))
	 || (mp_tournament.BoolValue && mp_tournament_readymode.BoolValue)
	 && !hooked_player_disconnect)
	{
		HookEvent("player_disconnect", OnGameEvent_player_disconnect);
		hooked_player_disconnect = true;
	} else if (hooked_player_disconnect) {
		UnhookEvent("player_disconnect", OnGameEvent_player_disconnect);
		hooked_player_disconnect = false;
	}
}
