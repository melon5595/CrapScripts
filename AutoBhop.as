CScheduledFunction@ g_pBhopThinkFunc = null;
dictionary g_PlayerBhop;

void PluginInit() 
{
	g_Module.ScriptInfo.SetAuthor("null");
	g_Module.ScriptInfo.SetContactInfo("ahhh");
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
	
	if(g_pBhopThinkFunc !is null)
		g_Scheduler.RemoveTimer(g_pBhopThinkFunc);

	@g_pBhopThinkFunc = g_Scheduler.SetInterval("think", 0.007f);
}

HookReturnCode ClientSay(SayParameters@ pParams) 
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();
	string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	if (pArguments.ArgC() == 1 ) 
	{
		if(pArguments.Arg(0).ToLowercase() == "!bhop") 
		{
			pParams.ShouldHide = false;
			if(g_PlayerBhop.exists(szSteamId))
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[AutoBHOP] Disabled.\n");
				g_PlayerBhop.delete(szSteamId);
			}
			else
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[AutoBHOP] Enabled.\n");
				g_PlayerBhop[szSteamId] = 1;
			}
			return HOOK_HANDLED;
		}
	}
	return HOOK_CONTINUE;
}

void AutoBhop(CBasePlayer@ pPlayer, const string szSteamId)
{
	if(!pPlayer.IsAlive())
		return;
	
	int iOldButtons = pPlayer.pev.oldbuttons;
	if(pPlayer.pev.oldbuttons & IN_JUMP != 0 && pPlayer.pev.flags & FL_ONGROUND != 0)
	{
		iOldButtons &= ~IN_JUMP;
		pPlayer.pev.oldbuttons = iOldButtons;
		pPlayer.pev.sequence = PLAYER_JUMP;
	}
}

void think() 
{
	for (int i = 1; i <= g_Engine.maxClients; ++i) 
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
		if (pPlayer !is null && pPlayer.IsConnected()) 
		{
			string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
			if(g_PlayerBhop.exists(szSteamId))
			AutoBhop(pPlayer, szSteamId);
		}
	}
}
