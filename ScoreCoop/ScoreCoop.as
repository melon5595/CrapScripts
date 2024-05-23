#include "tracker"
#include "ui"

int ScoreTime = 5 / 0.5f;
string szScoreSound = "misc/score.wav";
string szStreak1Sound = "misc/streak1.mp3";
string szStreak2Sound = "misc/streak2.mp3";
string szStreak3Sound = "misc/streak3.mp3";
CScheduledFunction@ g_pScoreCoopTimer;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "null" );
	g_Module.ScriptInfo.SetContactInfo( "yee" );
	
	g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
	g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);

	g_Hooks.RegisterHook(Hooks::Monster::MonsterTakeDamage, @MonsterTakeDamage);
	g_Hooks.RegisterHook(Hooks::Player::PlayerTakeDamage, @PlayerTakeDamage);
	g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerSpawn);
}

void MapInit()
{
	g_SoundSystem.PrecacheSound( szScoreSound );
	g_SoundSystem.PrecacheSound( szStreak1Sound );
	g_SoundSystem.PrecacheSound( szStreak2Sound );
	g_SoundSystem.PrecacheSound( szStreak3Sound );
	
	g_Game.PrecacheGeneric( "sound/" + szScoreSound );
	g_Game.PrecacheGeneric( "sound/" + szStreak1Sound );
	g_Game.PrecacheGeneric( "sound/" + szStreak2Sound );
	g_Game.PrecacheGeneric( "sound/" + szStreak3Sound );
	
	g_Scheduler.RemoveTimer(@g_pScoreCoopTimer);
	@g_pScoreCoopTimer = g_Scheduler.SetInterval("Timer", 0.5f);
}

HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer)
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	if(g_pPlayerScoreData.exists(szSteamId))
		g_pPlayerScoreData.delete(szSteamId);
 
	return HOOK_CONTINUE;
}

HookReturnCode MapChange()
{
	g_pPlayerScoreData.deleteAll();
	return HOOK_CONTINUE;
}

HookReturnCode MonsterTakeDamage(DamageInfo@ info)
{
	if(info.pVictim is null || info.pAttacker is null)
		return HOOK_CONTINUE;
		
	CBaseEntity@ pVictim = cast<CBaseEntity@>(g_EntityFuncs.Instance(info.pVictim.pev));
	CBasePlayer@ pAttacker = cast<CBasePlayer@>(g_EntityFuncs.Instance(info.pAttacker.pev));
	if(pVictim is null || pAttacker is null || pVictim is pAttacker || !IsFirstDead(pVictim) || !pAttacker.IsPlayer())
		return HOOK_CONTINUE;
	
	CBaseMonster@ pMonster = cast<CBaseMonster@>(@pVictim);
	if(pMonster.pev.max_health > 0)
	{
		if(pMonster.pev.health > 0)
			SendDamageInfo(pAttacker, int(info.flDamage));

		if(pMonster.pev.health - info.flDamage <= 0)
		{
			g_EntityFuncs.DispatchKeyValue(pMonster.edict(), SC_ConfirmDead, int(1));

			string szScoreMessage = pMonster.m_FormattedName;
			int AddiPoint = 5;
			float AddflMultiplier = 0.25;

			// Player Motion
			if(IsPlayerMidAir(pAttacker))
			{
				AddiPoint += 15;
				AddflMultiplier += 0.15;
				szScoreMessage.opAddAssign("|MidAir");
			}
			if(IsPlayerDucking(pAttacker))
			{
				AddiPoint += 5;
				AddflMultiplier += 0.05;
				szScoreMessage.opAddAssign("|Sneak");
			}
			if(IsPlayerInWater(pAttacker))
			{
				AddiPoint += 25;
				AddflMultiplier += 0.25;
				szScoreMessage.opAddAssign("|InWater");
			}
			
			// Special
			if(IsOneShot(info.flDamage, pMonster))
			{
				AddiPoint += 10;
				AddflMultiplier += 0.15;
				szScoreMessage.opAddAssign("|OneShot");
			}
			if(IsLongShot(pAttacker, pMonster))
			{
				AddiPoint += 50;
				AddflMultiplier += 0.5;
				szScoreMessage.opAddAssign("|LongShot");
			}
			if(IsHead(pAttacker))
			{
				AddiPoint += 30;
				AddflMultiplier += 0.3;
				szScoreMessage.opAddAssign("|Head");
			}
			if(IsLastBullet(pAttacker))
			{
				AddiPoint += 30;
				AddflMultiplier += 0.30;
				szScoreMessage.opAddAssign("|LastBullet");
			}
			
			// DamageType
			if(info.bitsDamageType == DMG_CRUSH || info.bitsDamageType == DMG_FALL)
			{
				AddiPoint += 100;
				AddflMultiplier += 1.0;
				szScoreMessage.opAddAssign("|Crush");
			}
			if(info.bitsDamageType == DMG_BLAST)
			{
				AddiPoint += 5;
				AddflMultiplier += 0.10;
				szScoreMessage.opAddAssign("|Blast");
			}
			if(info.bitsDamageType == DMG_CLUB)
			{
				AddiPoint += 10;
				AddflMultiplier += 0.25;
				szScoreMessage.opAddAssign("|Club");
			}
			SendKillInfo(pAttacker, szScoreMessage, AddiPoint, AddflMultiplier);
		}
	}
	return HOOK_CONTINUE;
}

HookReturnCode PlayerTakeDamage( DamageInfo@ info )
{
	CBasePlayer@ pPlayer = cast<CBasePlayer@>(g_EntityFuncs.Instance(info.pVictim.pev));
	if(pPlayer is null)
		return HOOK_CONTINUE;
	
	SendTakeDamageInfo(pPlayer, int(info.flDamage));

	return HOOK_CONTINUE;
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{
	if(pPlayer is null)
		return HOOK_CONTINUE;
	
	g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SC_ConfirmDead, int(0));
	return HOOK_CONTINUE;
}

void Timer()
{
	for(int i = 1; i <= g_Engine.maxClients; ++i) 
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
		if(pPlayer !is null && pPlayer.IsConnected()) 
		{
			string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
			if(!g_pPlayerScoreData.exists(szSteamId))
			{
				CPlayerScoreData data;
				data.scores = 0;
				data.kills = 0;
				data.deaths = 0;
				data.damages = 0;
				data.takedamages = 0;
				data.CountdownTimer = 0;
				data.AddPoint = 0;
				data.Multiplier = 0.0;
				data.KillStreak = 0;
				data.szScoreInfo = "";
				data.szScoreHUD = "";
				g_pPlayerScoreData[szSteamId] = data;
			} 
			CPlayerScoreData@ data = cast<CPlayerScoreData@>(g_pPlayerScoreData[szSteamId]);
			if(data !is null)
			{
				data.scores = pPlayer.pev.frags;
				data.deaths = pPlayer.m_iDeaths;
			
				g_pPlayerScoreData[szSteamId] = data;
			}
			Refresh(pPlayer, 0);
		}
	}
}
