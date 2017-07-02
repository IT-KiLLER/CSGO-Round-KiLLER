#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <multicolors>

#pragma semicolon 1
#pragma newdecls required
#define TAG_COLOR 	"{green}[SM]{default}"
#define PLUGIN_VERSION "1.0"

public Plugin myinfo = 
{
	name = "[CS:GO] Round KiLLER",
	author = "IT-KiLLER",
	description = "Command to end round. !endround !endwarmup",
	version = PLUGIN_VERSION,
	url = "https://github.com/it-killer"
}

public void OnPluginStart()
{
	RegAdminCmd("sm_foreendround", ForceRoundEnd, ADMFLAG_GENERIC, "The command ends the round.");
	RegAdminCmd("sm_forceendwarmup", ForceWarmupEnd, ADMFLAG_GENERIC, "The command ends the warmup");
	RegAdminCmd("sm_endround", ForceRoundEnd, ADMFLAG_GENERIC, "The command ends the round.");
	RegAdminCmd("sm_endwarmup", ForceWarmupEnd, ADMFLAG_GENERIC, "The command ends the warmup.");
}

public Action ForceWarmupEnd(int client, int args)
{
	CPrintToChatAll("%s %N has canceled the warm-up period.", TAG_COLOR, client);
	PrintToServer("[SM] %N has canceled the warm-up period.", client);
	SetConVarInt(FindConVar("mp_do_warmup_period"), 0, false, false);
	SetConVarInt(FindConVar("mp_warmuptime"), 0, false, false);
	CS_TerminateRound(2.0, CSRoundEnd_GameStart, true);
}

public Action ForceRoundEnd(int client, int args)
{
	char inputArgs[4];
	if (args == 1) {
		GetCmdArg(1, inputArgs, sizeof(inputArgs));
	}
	if(StrEqual("CT", inputArgs, false)) {
		CS_TerminateRound(2.0, CSRoundEnd_CTWin, true);
	} else if(StrEqual("T", inputArgs, false)) {
		CS_TerminateRound(2.0, CSRoundEnd_TerroristWin, true);
	} else if (args==1 && client) {
		CPrintToChat(client, "%s Invaild arguments. Available arguments: CT or T.", TAG_COLOR);
		return Plugin_Handled;
	} else if (client && (GetClientTeam(client) == CS_TEAM_CT || GetClientTeam(client) == CS_TEAM_T )) {
		CS_TerminateRound(2.0, GetClientTeam(client) == CS_TEAM_CT ? CSRoundEnd_CTWin : CSRoundEnd_TerroristWin, true);
	} else {
		ReplyToCommand(client, "[SM] An error has occurred, you need to enter the command again with arguments. CT / T");
		return Plugin_Handled;
	}
	CPrintToChatAll("%s %N has finished the round.", TAG_COLOR, client);
	PrintToServer("[SM] %N has finished the round.", client);
	return Plugin_Handled;
}
