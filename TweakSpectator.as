array<string> AlivePlayer(g_Engine.maxClients);
array<string> SpecPlayer(g_Engine.maxClients);
array<string> szOutput(g_Engine.maxClients);

HUDTextParams SpecHUDText;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("null");
	g_Module.ScriptInfo.SetContactInfo("nada");
	
	SpecHUDText.channel = 4;
	SpecHUDText.x = 0.45;
	SpecHUDText.y = 0.75;
	SpecHUDText.a1 = 0;
	SpecHUDText.fadeinTime = 0;
	SpecHUDText.fadeoutTime = 0;
	SpecHUDText.holdTime = 1;
	SpecHUDText.r1 = 140;
    SpecHUDText.g1 = 220;
    SpecHUDText.b1 = 250;
	
	//g_Hooks.RegisterHook(Hooks::Player::PlayerEnteredObserver, @PlayerEnteredObserver);
	//g_Hooks.RegisterHook(Hooks::Player::PlayerLeftObserver, @PlayerLeftObserver);
	
	g_Scheduler.SetInterval( "ListThink", 1.0, g_Scheduler.REPEAT_INFINITE_TIMES );
	g_Scheduler.SetInterval( "KeyThink", 0.2, g_Scheduler.REPEAT_INFINITE_TIMES );
}




void ListThink() 
{
	for(int i = 1; i <= g_Engine.maxClients; ++i) 
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
		if(pPlayer !is null && pPlayer.IsConnected()) 
		{
			Observer@ pObserver = pPlayer.GetObserver();
			if(!pObserver.IsObserver())
			{
				AlivePlayer[i - 1] = pPlayer.pev.netname;
				//g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[AdvancedSpectator] " + AlivePlayer[i - 1] + " Is Player.\n");
			}
			else
			{
				SpecPlayer[i - 1] = pPlayer.pev.netname;
				//g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[AdvancedSpectator] " + SpecPlayer[i - 1] + " Is Spectator.\n");
			}
		}
	}
}


void KeyThink()
{
	for(int i = 1; i <= g_Engine.maxClients; ++i) 
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
		if(pPlayer !is null && pPlayer.IsConnected())
		{
			Observer@ pObserver = pPlayer.GetObserver();
			if(!pObserver.IsObserver())
			{
				string szforward = (pPlayer.pev.button & IN_FORWARD != 0) ? "W" : "_";
				string szbackward = (pPlayer.pev.button & IN_BACK != 0) ? "S" : "_";
				string szmoveleft = (pPlayer.pev.button & IN_MOVELEFT != 0) ? "A" : "_";
				string szmoveright = (pPlayer.pev.button & IN_MOVERIGHT != 0) ? "D" : "_";
				string szduck = (pPlayer.pev.button & IN_DUCK != 0) ? "DUCK" : "_";
				string szjump = (pPlayer.pev.button & IN_JUMP != 0) ? "JUMP" : "_";
				
				
				string szBuffer = "\t\t%1\t\t\t%2\n\t%3 %4 %5\t\t%6";
				snprintf(szOutput[i - 1], szBuffer, szforward,szjump,szmoveleft,szbackward,szmoveright,szduck);
			}
			
			for(int j = 1; j <= g_Engine.maxClients; ++j)
			{
				@pPlayer = g_PlayerFuncs.FindPlayerByIndex(j);
				if(pPlayer !is null && pPlayer.IsConnected()) 
				{
					@pObserver = pPlayer.GetObserver();
					if(pPlayer.pev.netname == SpecPlayer[j - 1])
					{
						// Receive pTarget's button
						CBaseEntity@ pTarget = pObserver.GetObserverTarget();
						if(pObserver.GetObserverTarget() !is null)
						{
							for(int k = 1;k <= int(AlivePlayer.length());++k)
							{
								if(pTarget.pev.netname == AlivePlayer[k - 1])
									g_PlayerFuncs.HudMessage( pPlayer, SpecHUDText, szOutput[k - 1]);
							}
						}
					}
				}
			}
		}
	}
}