
/*	Copyright (C) 2017 IT-KiLLER

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdktools_gamerules>
#include <multicolors>
#pragma semicolon 1
#pragma newdecls required
#define TAG_COLOR 	"{green}[SM]{default}"
#define PLUGIN_VERSION "1.1"
ConVar sm_round_killer_terminate_time;

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
	sm_round_killer_terminate_time  = CreateConVar("sm_round_killer_terminate_time", "2.0", "Time to end the round. (0-30)", _, true, 0.0, true,30.0);
	RegAdminCmd("sm_endround", ForceRoundEnd, ADMFLAG_GENERIC, "The command ends the round.");
	RegAdminCmd("sm_endwarmup", ForceRoundEnd, ADMFLAG_GENERIC, "The command ends the warmup.");
}

public Action ForceRoundEnd(int client, int args)
{
	if(GameRules_GetProp("m_bWarmupPeriod") == 1) {
		CPrintToChatAll("%s %N has canceled the warmup period.", TAG_COLOR, client);
		PrintToServer("[SM] %N has canceled the warmup period.", client);
		SetConVarInt(FindConVar("mp_do_warmup_period"), 0, false, false);
		SetConVarInt(FindConVar("mp_warmuptime"), 0, false, false);
		CS_TerminateRound(5.0, CSRoundEnd_GameStart, true);
		return Plugin_Handled;
	}
	char inputArgs[4];
	if (args == 1) {
		GetCmdArg(1, inputArgs, sizeof(inputArgs));
	}
	if(StrEqual("CT", inputArgs, false)) {
		CS_TerminateRound(2.0, CSRoundEnd_CTWin, true);
	} else if(StrEqual("T", inputArgs, false)) {
		CS_TerminateRound(2.0, CSRoundEnd_TerroristWin, true);
	} else if (args==1 && client) {
		CReplyToCommand(client, "%s Invaild arguments. Available arguments: CT or T.", TAG_COLOR);
		return Plugin_Handled;
	} else if (client && (GetClientTeam(client) == CS_TEAM_CT || GetClientTeam(client) == CS_TEAM_T )) {
		CS_TerminateRound(sm_round_killer_terminate_time.FloatValue, GetClientTeam(client) == CS_TEAM_CT ? CSRoundEnd_CTWin : CSRoundEnd_TerroristWin, true);
	} else {
		CReplyToCommand(client, "%s An error has occurred, you need to enter the command again with arguments. CT / T", TAG_COLOR);
		return Plugin_Handled;
	}
	CPrintToChatAll("%s %N has finished the round.", TAG_COLOR, client);
	PrintToServer("[SM] %N has finished the round.", client);
	return Plugin_Handled;
}