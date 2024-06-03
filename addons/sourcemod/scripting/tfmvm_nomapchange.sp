// tfmvm_nomapchange.sp
//  Reloads the current mission once it is completed, preventing the map from changing.
//   Compatiable with `SetEntPropString(tf_objective_resource, Prop_Send, "m_iszMvMPopfileName", "Trespasser (Expert)");`.
//   Syncs the next mission loading dialog properly.

#include <sourcemod>
#include <sdktools_functions>
#include <tfmvm_stocks>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = {
    name = "[TF2-MvM] No Automated Map Change",
    author = "fellen",
    description = "Don't change the map after MvM mission completion.",
    version = "1.4",
    url = "https://steamcommunity.com/id/mtxfellen/"
};

#define VICTORY_METHOD_OVERRIDE false
#define RELOAD_TIME_OVERRIDE 9999.0

Handle g_hReloadMissionTimer = INVALID_HANDLE;
Handle g_hHideWaveSummaryTimer = INVALID_HANDLE;
bool g_bAllowKickMessage = false;
bool g_bHookedReloadEvents = false;

ConVar sm_mvm_reloadtimer = null;
ConVar tf_mvm_disconnect_on_victory = null;
ConVar tf_mvm_victory_reset_time = null;

// Plugin forwards
public void OnPluginStart() {
    sm_mvm_reloadtimer = CreateConVar("sm_mvm_reloadtimer", "11.0",
        "How long to wait after mission completion before reloading.", _, true, 0.0, true, 254.0);
    tf_mvm_disconnect_on_victory = FindConVar("tf_mvm_disconnect_on_victory");
    tf_mvm_victory_reset_time = FindConVar("tf_mvm_victory_reset_time");

    tf_mvm_disconnect_on_victory.AddChangeHook(Changed_tf_mvm_disconnect_on_victory);
    tf_mvm_victory_reset_time.AddChangeHook(Changed_tf_mvm_victory_reset_time);
    tf_mvm_disconnect_on_victory.SetBool(VICTORY_METHOD_OVERRIDE);
    tf_mvm_victory_reset_time.SetFloat(RELOAD_TIME_OVERRIDE);
}

public void OnMapStart() {
    if (!g_bHookedReloadEvents && TF2_IsPlayingMvM()) {
        HookEvent("teamplay_round_start", teamplay_round_start, EventHookMode_PostNoCopy);
        HookUserMessage(GetUserMessageId("MVMVictory"), MVMVictory, false, FireFakeKickMsg);
        HookUserMessage(GetUserMessageId("MVMServerKickTimeUpdate"), MVMServerKickTimeUpdate, true);
        g_bHookedReloadEvents = true;
    }
    else if (g_bHookedReloadEvents && !TF2_IsPlayingMvM()) {
        UnhookEvent("teamplay_round_start", teamplay_round_start, EventHookMode_PostNoCopy);
        UnhookUserMessage(GetUserMessageId("MVMVictory"), MVMVictory, false);
        UnhookUserMessage(GetUserMessageId("MVMServerKickTimeUpdate"), MVMServerKickTimeUpdate, true);
        g_bHookedReloadEvents = false;
    }
}

public void OnMapEnd() {
    if (g_hHideWaveSummaryTimer != null) delete g_hHideWaveSummaryTimer;
    if (g_hReloadMissionTimer != null) delete g_hReloadMissionTimer;
}

// Console variable hooks
void Changed_tf_mvm_disconnect_on_victory(ConVar convar, const char[] oldValue, const char[] newValue) {
    if (view_as<bool>(StringToInt(newValue, 2)) != VICTORY_METHOD_OVERRIDE) convar.SetBool(VICTORY_METHOD_OVERRIDE);
}

void Changed_tf_mvm_victory_reset_time(ConVar convar, const char[] oldValue, const char[] newValue) {
    if (StringToFloat(newValue) != RELOAD_TIME_OVERRIDE) convar.SetFloat(RELOAD_TIME_OVERRIDE);
}

// UserMessage hooks
Action MVMVictory(UserMsg msg_id, Handle msg, const int[] players, int playersNum, bool reliable, bool init) {
    g_hHideWaveSummaryTimer = CreateTimer(max(sm_mvm_reloadtimer.FloatValue, 0.0), Action_HideWaveSummary);
    g_hReloadMissionTimer = CreateTimer(sm_mvm_reloadtimer.FloatValue, Action_ReloadMission);
    return Plugin_Continue;
}

Action MVMServerKickTimeUpdate(UserMsg msg_id, Handle msg, const int[] players, int playersNum, bool reliable, bool init) {
    if (g_bAllowKickMessage == true) {
        g_bAllowKickMessage = false;
        return Plugin_Continue;
    }
    return Plugin_Handled;
}

// Event hooks
void teamplay_round_start(Event event, const char[] name, bool dontBroadcast) {
    if (g_hHideWaveSummaryTimer != null) delete g_hHideWaveSummaryTimer;
    if (g_hReloadMissionTimer != null) delete g_hReloadMissionTimer;
}

// Plugin functions
Action Action_HideWaveSummary(Handle timer) {
    SetEntProp(FindEntityByClassname(-1, "tf_objective_resource"), Prop_Send, "m_nMannVsMachineWaveCount", 0);
    delete g_hHideWaveSummaryTimer;
    return Plugin_Handled;
}

Action Action_ReloadMission(Handle timer) {
    TF2_ReloadMission();
    delete g_hReloadMissionTimer;
    return Plugin_Handled;
}

void FireFakeKickMsg(UserMsg msg_id, bool sent) {
    g_bAllowKickMessage = true;
    Handle kickmsg = StartMessageAll("MVMServerKickTimeUpdate", USERMSG_RELIABLE);
    BfWrite bf = UserMessageToBfWrite(kickmsg);
    bf.WriteByte(RoundToNearest(sm_mvm_reloadtimer.FloatValue + 1.0));
    EndMessage();
}

float max(float a, float b) {
    return a > b ? a : b;
}
