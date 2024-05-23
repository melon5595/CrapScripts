class CPlayerScoreData
{
	float scores;
	int kills;
	int deaths;
    int damages;
	int takedamages;
	int CountdownTimer;
	int AddPoint;
	int KillStreak;
	float Multiplier;
	string szScoreInfo;
	string szScoreHUD;
}
dictionary g_pPlayerScoreData;

void SendKillInfo(CBasePlayer@ pPlayer, string szName, int iAddPoint, float flMultiplier)
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	CPlayerScoreData@ data = cast<CPlayerScoreData@>(g_pPlayerScoreData[szSteamId]);
	if(data !is null)
	{
		data.kills += 1;
		data.CountdownTimer = ScoreTime;
		data.AddPoint += iAddPoint;
		data.Multiplier += flMultiplier;
		data.KillStreak += 1;
		data.szScoreInfo.opAddAssign(szName + "| " + iAddPoint + "\n");
		g_pPlayerScoreData[szSteamId] = data;
		Refresh(pPlayer, 2);

		g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, szScoreSound, 1.0f, 1.0f, 0, 90 + 10 * data.KillStreak, target_ent_unreliable:pPlayer.entindex());
	}
}

void SendDamageInfo(CBasePlayer@ pPlayer, int iDamage)
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	CPlayerScoreData@ data = cast<CPlayerScoreData@>(g_pPlayerScoreData[szSteamId]);
	if(data !is null)
	{
		data.damages += iDamage;
		g_pPlayerScoreData[szSteamId] = data;
	}
}

void SendTakeDamageInfo(CBasePlayer@ pPlayer, int iDamage)
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	CPlayerScoreData@ data = cast<CPlayerScoreData@>(g_pPlayerScoreData[szSteamId]);
	if(data !is null)
	{
		data.takedamages += iDamage;
		g_pPlayerScoreData[szSteamId] = data;
	}
}

void SendTimer(CBasePlayer@ pPlayer, int iTime)
{
	int remainingtime = iTime;
	int maxtime = ScoreTime;
	
	int currentDashes = remainingtime;	
	int remainingDashes = maxtime - currentDashes;

	string timerDisplay;
	string remainingDisplay;
	for(int i = 0; i < currentDashes; i++)
	{
		timerDisplay.opAddAssign('|');
	}
	for(int j = 0; j < remainingDashes; j++)
	{
		remainingDisplay.opAddAssign('_');
	}
	
	string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	CPlayerScoreData@ data = cast<CPlayerScoreData@>(g_pPlayerScoreData[szSteamId]);
	if(data !is null)
	{
		data.szScoreHUD = "[" + timerDisplay + remainingDisplay + "]";
		g_pPlayerScoreData[szSteamId] = data;
	}
}

void CleanScoreInfo(CBasePlayer@ pPlayer)
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	CPlayerScoreData@ data = cast<CPlayerScoreData@>(g_pPlayerScoreData[szSteamId]);
	if(data !is null)
	{
		data.CountdownTimer = 0;
		data.AddPoint = 0;
		data.Multiplier = 0.0;
		data.KillStreak = 0;
		data.szScoreInfo = "";
		data.szScoreHUD = "";
		g_pPlayerScoreData[szSteamId] = data;
	}
}

void Refresh(CBasePlayer@ pPlayer, int iEffect)
{
	HUDTextParams paramSCNotify;
	paramSCNotify.channel = 2;
	paramSCNotify.x = 0.05;
	paramSCNotify.y = 0.1;
	paramSCNotify.a1 = 0;
	paramSCNotify.effect = iEffect;
	paramSCNotify.fadeinTime = 0;
	paramSCNotify.fadeoutTime = 0.5;
	paramSCNotify.holdTime = 2;
	paramSCNotify.fxTime = 0.5;
	paramSCNotify.r1 = 140;
	paramSCNotify.g1 = 220;
	paramSCNotify.b1 = 250;	
	
	string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	CPlayerScoreData@ data = cast<CPlayerScoreData@>(g_pPlayerScoreData[szSteamId]);
	if(data is null)
		return;
	
	string szScoreInfo = "PTS: " + string(int(data.scores));
	string szKDInfo = "K/D: " + data.kills + " / " + data.deaths;
	string szDMGInfo = "DMG/TDMG:" + data.damages + " / " + data.takedamages;	
	string szUnderscore = "-------";

	g_PlayerFuncs.HudMessage( pPlayer, paramSCNotify, (data.CountdownTimer <= 0) ? szScoreInfo + "\n" + szKDInfo + "\n" + szDMGInfo:
													szScoreInfo + "\n" +
													szUnderscore + "\n" +
													"Streak: " + data.KillStreak + "\n" + 
													data.szScoreInfo + 
													"+" +  data.AddPoint + " " + "[ x" + data.Multiplier + " ]\n" +
													szUnderscore + "\n" +
													data.szScoreHUD + "\n");
													
	if(data.CountdownTimer > 0)
	{
		data.CountdownTimer -= 1;
		g_pPlayerScoreData[szSteamId] = data;
		SendTimer(pPlayer, data.CountdownTimer);
	}
	if(data.CountdownTimer <= 0)
	{
		AddBonusPoint(pPlayer, data.AddPoint, data.Multiplier);
		CleanScoreInfo(pPlayer);
	}
	if(data.KillStreak >= 8)
	{
		string szRandom;
		switch ( Math.RandomLong( 1, 3 ) ) 
		{
			case 1: szRandom = szStreak1Sound; break;
			case 2: szRandom = szStreak2Sound; break;
			case 3: szRandom = szStreak3Sound; break;
		}
		g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, szRandom, 1.0f, 1.0f, 0, PITCH_NORM);
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, string(pPlayer.pev.netname) + " 达成8次连续击杀 [累计加成" + int(data.AddPoint * data.Multiplier * 2) + "分]" );
		AddBonusPoint(pPlayer, data.AddPoint, data.Multiplier * 2);
		CleanScoreInfo(pPlayer);
	}
}

