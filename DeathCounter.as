// DeathCounter for RealDMG server
// Todolist: Count players' death to calculate final score bonus
/*CClientCommand test("list", "list", @list);

void list(const CCommand@ pArgs) 
{
	Listname();
}*/

CScheduledFunction@ deathcounter_check;
CScheduledFunction@ deathcounter_regen;
HUDTextParams iDeathText;

bool g_pFirstblood;
dictionary g_pTriplekill, g_pMegakill, g_pMonsterkill, g_pHolyshit, g_pUnstoppable;
string sz1kill 	= "csnd/1kill.wav";
string sz3kill 	= "csnd/3kill.wav";
string sz5kill 	= "csnd/5kill.wav";
string sz8kill 	= "csnd/mmmmm.wav";
string sz10kill = "csnd/holyshit.wav";
string sz12kill = "csnd/unstoppable.wav";

void PluginInit() 
{
	g_Module.ScriptInfo.SetAuthor("null");
	g_Module.ScriptInfo.SetContactInfo("ahhh");
	
	g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerSpawn);
	g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);
	
	iDeathText.channel = 3;
	iDeathText.x = 0.05;
	iDeathText.y = 0.45;
	iDeathText.a1 = 0;
	iDeathText.fadeinTime = 0.5;
	iDeathText.fadeoutTime = 0.5;
	iDeathText.holdTime = 3;
	//iDeathText.fxTime = 1.5;
	iDeathText.r1 = 140;
    iDeathText.g1 = 220;
    iDeathText.b1 = 250;
}

void MapInit()
{
	Precache();
	
	g_pFirstblood = true;
	g_pTriplekill.deleteAll();
	g_pMegakill.deleteAll();
	g_pMonsterkill.deleteAll(); 
	g_pHolyshit.deleteAll();
	g_pUnstoppable.deleteAll();

	@deathcounter_check = g_Scheduler.SetInterval("Think", 0.2f);
	@deathcounter_regen = g_Scheduler.SetInterval("Regeneration", 0.5f);
}

void Precache()
{	
	g_Game.PrecacheGeneric( "sound/" + sz1kill );
	g_Game.PrecacheGeneric( "sound/" + sz3kill );
	g_Game.PrecacheGeneric( "sound/" + sz5kill );
	g_Game.PrecacheGeneric( "sound/" + sz8kill );
	g_Game.PrecacheGeneric( "sound/" + sz10kill );
	g_Game.PrecacheGeneric( "sound/" + sz12kill );
	
	g_SoundSystem.PrecacheSound( sz1kill );
	g_SoundSystem.PrecacheSound( sz3kill );
	g_SoundSystem.PrecacheSound( sz5kill );
	g_SoundSystem.PrecacheSound( sz8kill );
	g_SoundSystem.PrecacheSound( sz10kill );
	g_SoundSystem.PrecacheSound( sz12kill );
}

HookReturnCode MapChange()
{
	g_Scheduler.RemoveTimer(deathcounter_check);
	g_Scheduler.RemoveTimer(deathcounter_regen);

	return HOOK_HANDLED;
}

HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
{
	if(pPlayer is null || !pPlayer.IsConnected()) 
		return HOOK_HANDLED;
		
	string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	if(g_pTriplekill.exists(szSteamId))
	{
		pPlayer.pev.armortype += 50;
		pPlayer.pev.armorvalue += 50;
	}
	if(g_pMegakill.exists(szSteamId))
	{
		pPlayer.pev.max_health += 50;
		pPlayer.pev.health += 50;
	}
	if(g_pHolyshit.exists(szSteamId))
	{
		pPlayer.pev.max_health += 50;
		pPlayer.pev.health += 50;
		pPlayer.pev.armortype += 50;
		pPlayer.pev.armorvalue += 50;
	}

	return HOOK_HANDLED;
}

void Regeneration()
{
	for(int i = 1; i <= g_Engine.maxClients; ++i) 
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
		if(pPlayer !is null && pPlayer.IsConnected()) 
		{
			string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
			if(pPlayer.IsAlive() && g_pUnstoppable.exists(szSteamId))
			{
				if(pPlayer.pev.health < pPlayer.pev.max_health)
					pPlayer.pev.health += 5;
			
				if(pPlayer.pev.armorvalue < pPlayer.pev.armortype)
					pPlayer.pev.armorvalue += 2;
			}
		}
	}		
}

void DeathCounter(CBasePlayer@ pPlayer)
{
	if(pPlayer !is null && pPlayer.IsConnected()) 
	{
		string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
		int g_DeathCount = pPlayer.m_iDeaths;

		if(g_DeathCount == 1 && g_pFirstblood)
		{
			KillStreakFunc(pPlayer, sz1kill, " achieved the first death!");
			g_pFirstblood = false;
		}
		if(g_DeathCount == 3 && !g_pTriplekill.exists(szSteamId))
		{	
			KillStreakFunc(pPlayer, sz3kill, " has achieved 3 deaths in total! \n(+50 Extra Armor)");
			g_pTriplekill[szSteamId] = true;
		}
		if(g_DeathCount == 5 && !g_pMegakill.exists(szSteamId))
		{	
			KillStreakFunc(pPlayer, sz5kill, " has achieved 5 deaths in total! \nRampage! \n(+50 Extra Health)");
			g_pMegakill[szSteamId] = true;
		}
		if(g_DeathCount == 8 && !g_pMonsterkill.exists(szSteamId))
		{	
			KillStreakFunc(pPlayer, sz8kill, " has achieved 8 deaths in total! \nM0N5T3R KILL! \n(Skip Reloading while holding trigger)");
			g_pMonsterkill[szSteamId] = true;
		}
		if(g_DeathCount == 10 && !g_pHolyshit.exists(szSteamId))
		{	
			KillStreakFunc(pPlayer, sz10kill, " has achieved 10 deaths in total! \nHOLYSHIT! \n(+100 Extra Health & +100 Extra Armor)");
			g_pHolyshit[szSteamId] = true;
		}
		if(g_DeathCount == 12 && !g_pUnstoppable.exists(szSteamId))
		{	
			KillStreakFunc(pPlayer, sz12kill, " has achieved 12 deaths in total! \nUNSTOPPABLE! \n(Auto-Regen HP&AP)");
			g_pUnstoppable[szSteamId] = true;
		}
		if(g_pMonsterkill.exists(szSteamId)) // 8 death streak function
		{
			CBasePlayerWeapon@ activeItem = cast<CBasePlayerWeapon@>(pPlayer.m_hActiveItem.GetEntity());
			if(activeItem !is null && activeItem.m_bFireOnEmpty == true)
			{
				if(activeItem.m_iClip == -1 || activeItem.iMaxClip() <= 1 || pPlayer.m_rgAmmo(activeItem.m_iPrimaryAmmoType) < activeItem.iMaxClip())
					return;
				
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, "Hold to Auto-Reload!");
				pPlayer.m_rgAmmo(activeItem.m_iPrimaryAmmoType, pPlayer.m_rgAmmo(activeItem.m_iPrimaryAmmoType) - activeItem.iMaxClip());
				activeItem.m_iClip = activeItem.iMaxClip();
				activeItem.m_bFireOnEmpty = false;
			}
		}
	}
}

void KillStreakFunc(CBasePlayer@ pPlayer, string&in Sound, string&in Msg)
{
	g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_ITEM, Sound, 0.75, ATTN_NORM, 0, PITCH_NORM );
	g_PlayerFuncs.HudMessageAll( iDeathText, string(pPlayer.pev.netname) + Msg);
}

void Think() 
{
	for(int i = 1; i <= g_Engine.maxClients; ++i) 
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
		if(pPlayer !is null && pPlayer.IsConnected()) 
		{
			DeathCounter(pPlayer);
		}
	}
}

void Listname()
{
	array<string> NetName(g_Engine.maxClients);
	array<int> NetNameDeath(g_Engine.maxClients);
	string MostDeathName;
	string LeastDeathName;
	
	int MostDeath = 0;
	int LeastDeath = 0;
	
	for(int i = 1; i <= (int(g_Engine.maxClients)); i++) //Player index start from 1
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
		if(pPlayer !is null)
		{
			NetName[i - 1] = pPlayer.pev.netname;
			NetNameDeath[i - 1] = pPlayer.m_iDeaths;
			
			if(MostDeath <= NetNameDeath[i - 1])
			{
				MostDeath = NetNameDeath[i - 1];
				MostDeathName = NetName[i - 1];
			}
			if(LeastDeath >= NetNameDeath[i - 1])
			{
				LeastDeath = NetNameDeath[i - 1];
				LeastDeathName = NetName[i - 1];
			}
		}
	}
	for(int i = 1; i <= (int(NetName.length())-1); i++) // Due to the array index is optimized
	{
		string thisName = NetName[i - 1];
		int thisDeath = NetNameDeath[i - 1];

		if(thisName != "" && thisName != " ")
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "| Player: " + thisName + " | " + "Deaths: " + string(thisDeath) + " |\n");
		}
	}
	g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "Most Deaths: " +  MostDeathName + " (" + MostDeath + ")\n");
}