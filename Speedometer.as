CScheduledFunction@ g_pSpeedThinkFunc = null;
dictionary g_PlayerSpeed, g_PlayerLastSpeed;
HUDNumDisplayParams speed, lastspeed;

Vector velocity;
float speedh;

void PluginInit() 
{
	g_Module.ScriptInfo.SetAuthor("null");
	g_Module.ScriptInfo.SetContactInfo("ahhh");
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
	
	speed.channel = 9;
	speed.flags = HUD_ELEM_DEFAULT_ALPHA | HUD_ELEM_SCR_CENTER_X;
	speed.x = 0;
	speed.y = 0.90;
	speed.defdigits = 1;
	speed.maxdigits = 4;
	speed.color1 = RGBA_SVENCOOP;
	speed.holdTime = 1.0f;
	
	lastspeed.channel = 10;
	lastspeed.flags = HUD_ELEM_DEFAULT_ALPHA | HUD_ELEM_SCR_CENTER_X;
	lastspeed.x = 0;
	lastspeed.y = 0.95;
	lastspeed.defdigits = 1;
	lastspeed.maxdigits = 4;
	lastspeed.color1 = RGBA_SVENCOOP;
	lastspeed.holdTime = 1.0f;

	if(g_pSpeedThinkFunc !is null)
		g_Scheduler.RemoveTimer(g_pSpeedThinkFunc);

	@g_pSpeedThinkFunc = g_Scheduler.SetInterval("speedThink", 0.1f);
}

void MapInit() 
{
	g_Game.PrecacheGeneric( "sprites/misc/run.spr" );
	g_Game.PrecacheGeneric( "sprites/misc/stand.spr" );
	g_Game.PrecacheGeneric( "sprites/misc/duck.spr" );
	g_Game.PrecacheGeneric( "sprites/misc/jump.spr" );
	g_Game.PrecacheModel( "sprites/misc/run.spr" );
	g_Game.PrecacheModel( "sprites/misc/stand.spr" );
	g_Game.PrecacheModel( "sprites/misc/duck.spr" );
	g_Game.PrecacheModel( "sprites/misc/jump.spr" );
}


HookReturnCode ClientSay(SayParameters@ pParams) 
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();
	if (pArguments.ArgC() == 1) 
	{
		if (pArguments.Arg(0).ToLowercase() == "!speedometer") 
		{
			pParams.ShouldHide = true;
			string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
		  
			if (g_PlayerSpeed.exists(szSteamId)) 
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SpeedoMeter] Disabled.\n");
				removeSpeedometer(pPlayer);
			}
			else 
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[SpeedoMeter] Enabled.\n");
				g_PlayerSpeed[szSteamId] = speedh;
			}
		return HOOK_HANDLED;
		}
	}
	return HOOK_CONTINUE;
}

void speedMsg(CBasePlayer@ pPlayer, const string szSteamId) 
{
	velocity = pPlayer.pev.velocity;
	speedh = sqrt( pow( velocity.x, 2.0 ) + pow( velocity.y, 2.0 ) );
	
	speed.value = int(speedh);
	speed.spritename = "misc/stand.spr";
	lastspeed.spritename = "misc/jump.spr";
	
	if(pPlayer.pev.button & IN_JUMP != 0 && pPlayer.pev.flags & FL_ONGROUND != 1)
	{
		lastspeed.value = int(speedh);
	}
	
	if(pPlayer.IsMoving())
	{
		if(pPlayer.pev.flags & FL_DUCKING != 0)
		{
			speed.spritename = "misc/duck.spr";
		}
		else
		{
			speed.spritename = "misc/run.spr";
		}
	}
	
	if(pPlayer.pev.flags & FL_DUCKING != 0)
	{
		speed.spritename = "misc/duck.spr";
	}

	if (g_PlayerSpeed.exists(szSteamId))
	g_PlayerFuncs.HudNumDisplay( pPlayer, speed );
	g_PlayerFuncs.HudNumDisplay( pPlayer, lastspeed );
}

void removeSpeedometer(CBasePlayer@ pPlayer) 
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	if(g_PlayerSpeed.exists(szSteamId))
		g_PlayerSpeed.delete(szSteamId);
}

void speedThink() 
{
	for (int i = 1; i <= g_Engine.maxClients; ++i) 
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
		if (pPlayer !is null && pPlayer.IsConnected()) 
		{
			string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
			if (g_PlayerSpeed.exists(szSteamId))
			speedMsg(pPlayer, szSteamId);
		}
	}
}