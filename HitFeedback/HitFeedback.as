/***
CrossHairFeedBack	--Dr.Abc
Edited by null
****/

CScheduledFunction@ hitfeedback_check;
dictionary pHitFeedbackDic;

const array<string> monsterIgnorelist =
{
	"monster_generic",
	"monster_rat",
	"monster_satchel",
	"monster_tripmine",
	"monster_scientist_dead",
	"monster_otis_dead",
	"monster_leech",
	"monster_human_grunt_ally_dead",
	"monster_hgrunt_dead",
	"monster_hevsuit_dead",
	"monster_handgrenade",
	"monster_gman",
	"monster_furniture",
	"monster_barney_dead"
};

class CPlayerHitFeedbackData
{
	float PlayerFrags;
	bool IsGrenade;
	bool IsHitmarker;
	bool IsHPBar;
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("Dr.Abc");
	g_Module.ScriptInfo.SetContactInfo( "I LOVE OWL2" );
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
	
	g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
	g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
	
	g_Hooks.RegisterHook(Hooks::Monster::MonsterTraceAttack, @MonsterTraceAttack);
	g_Hooks.RegisterHook(Hooks::Monster::MonsterTakeDamage, @MonsterTakeDamage);
	
	g_Hooks.RegisterHook(Hooks::Entity::BreakableTraceAttack, @BreakableTraceAttack);
	g_Hooks.RegisterHook(Hooks::Entity::BreakableTakeDamage, @BreakableTakeDamage);
	
	g_Hooks.RegisterHook(Hooks::Player::PlayerKilled, @PlayerKilled);
	
	g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);
}

void MapInit()
{
	g_Game.PrecacheModel( "sprites/misc/hitmarker.spr" );
	g_Game.PrecacheModel( "sprites/misc/grenade.spr" );
	g_SoundSystem.PrecacheSound( "misc/hitmarker.wav" );	
	g_SoundSystem.PrecacheSound( "misc/head.wav" );	

	g_Game.PrecacheGeneric( "sprites/misc/hitmarker.spr" );
	g_Game.PrecacheGeneric( "sprites/misc/grenade.spr" );
	g_Game.PrecacheGeneric( "sound/misc/hitmarker.wav" );
	g_Game.PrecacheGeneric( "sound/misc/head.wav" );
	
	@hitfeedback_check = g_Scheduler.SetInterval("CheckGrenade", 0.2f, g_Scheduler.REPEAT_INFINITE_TIMES);
}

HookReturnCode MapChange()
{
	g_Scheduler.RemoveTimer(hitfeedback_check);

	@hitfeedback_check = null;
	return HOOK_HANDLED;
}


HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer)
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	if(pHitFeedbackDic.exists(szSteamId))
		pHitFeedbackDic.delete(szSteamId);
 
	return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer)
{
	string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	if(!pHitFeedbackDic.exists(szSteamId))
	{
		CPlayerHitFeedbackData data;
		data.PlayerFrags = pPlayer.pev.frags;
		data.IsGrenade = true;
		data.IsHitmarker = true;
		data.IsHPBar = true;
		pHitFeedbackDic[szSteamId] = data;
	}
	return HOOK_CONTINUE;
}

HookReturnCode ClientSay(SayParameters@ pParams)
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();
	if (pArguments.ArgC() == 1) 
	{
		if (pArguments.Arg(0).ToLowercase() == "!grenademeter") 
		{
			pParams.ShouldHide = true;
			string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
			CPlayerHitFeedbackData@ data = cast<CPlayerHitFeedbackData@>(pHitFeedbackDic[steamId]);
			if (data.IsGrenade)
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[CrosshairFeedback] GrenadeMeter Disabled.\n");
				data.IsGrenade = false;
			}
			else 
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[CrosshairFeedback] GrenadeMeter Enabled.\n");
				data.IsGrenade = true;
			}
			pHitFeedbackDic[steamId] = data;
			return HOOK_HANDLED;
		}
		if (pArguments.Arg(0).ToLowercase() == "!hitmarker") 
		{
			pParams.ShouldHide = true;
			string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
			CPlayerHitFeedbackData@ data = cast<CPlayerHitFeedbackData@>(pHitFeedbackDic[steamId]);
			if (data.IsHitmarker)
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[CrosshairFeedback] HitMarker Disabled.\n");
				data.IsHitmarker = false;
			}
			else 
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[CrosshairFeedback] HitMarker Enabled.\n");
				data.IsHitmarker = true;
			}
			pHitFeedbackDic[steamId] = data;
			return HOOK_HANDLED;
		}
		if (pArguments.Arg(0).ToLowercase() == "!hpbar") 
		{
			pParams.ShouldHide = true;
			string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
			CPlayerHitFeedbackData@ data = cast<CPlayerHitFeedbackData@>(pHitFeedbackDic[steamId]);
			if (data.IsHPBar)
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[CrosshairFeedback] HealthBar Disabled.\n");
				data.IsHPBar = false;
			}
			else 
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[CrosshairFeedback] HealthBar Enabled.\n");
				data.IsHPBar = true;
			}
			pHitFeedbackDic[steamId] = data;
			return HOOK_HANDLED;
		}
	}
	return HOOK_CONTINUE;
}

HookReturnCode MonsterTraceAttack(CBaseMonster@ pMonster, entvars_t@ pevAttacker, float flDamage, Vector vecDir, const TraceResult& in ptr, int bitDamageType)
{
    CBasePlayer@ pPlayer = cast<CBasePlayer@>(g_EntityFuncs.Instance(pevAttacker));
    if(pMonster is null || pMonster.IsPlayer() || !pMonster.IsAlive() || pPlayer is null || !pPlayer.IsPlayer())
        return HOOK_CONTINUE;
    pMonster.pev.vuser3 = ptr.vecEndPos;
    return HOOK_CONTINUE;
}

HookReturnCode MonsterTakeDamage(DamageInfo@ info)
{
	if(info.pVictim is null || info.pAttacker is null)
		return HOOK_CONTINUE;

	CBaseEntity@ pVictim = cast<CBaseEntity@>(g_EntityFuncs.Instance(info.pVictim.pev));
	CBaseEntity@ pAttacker = cast<CBaseEntity@>(g_EntityFuncs.Instance(info.pAttacker.pev));
	
	if(pVictim is null || pAttacker is null || pVictim is pAttacker || !pAttacker.IsPlayer() || monsterIgnorelist.find(pVictim.GetClassname()) >= 0)
		return HOOK_CONTINUE;

	CBasePlayer@ pPlayer = cast<CBasePlayer@>(@pAttacker);

	string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	if(pHitFeedbackDic.exists(steamId))
	{
		CPlayerHitFeedbackData@ data = cast<CPlayerHitFeedbackData@>(pHitFeedbackDic[steamId]);
		if( data.IsHPBar )
		{
			if(pVictim.pev.max_health > 0)
			{	
				SendHPHud(pPlayer, pVictim, info.flDamage);
			}
		}
		if( data.IsHitmarker )
		{
			SendHitFeedback( pPlayer, (pVictim.IsPlayerAlly()) ? RGBA(0, 255, 0, 255) : RGBA_SVENCOOP );	
		}
	}
	return HOOK_CONTINUE;
}

HookReturnCode BreakableTraceAttack(CBaseEntity@ pBreakable, entvars_t@ pevAttacker, float flDamage, Vector vecDir, const TraceResult& in ptr, int bitDamageType)
{
    CBasePlayer@ pPlayer = cast<CBasePlayer@>(g_EntityFuncs.Instance(pevAttacker));
    if(pBreakable is null || !pBreakable.IsAlive() || pBreakable.IsPlayer() || pPlayer is null || !pPlayer.IsPlayer())
        return HOOK_CONTINUE;
	
    pBreakable.pev.vuser3 = ptr.vecEndPos;
    return HOOK_CONTINUE;
}

HookReturnCode BreakableTakeDamage(DamageInfo@ info)
{
	if(info.pVictim is null || info.pAttacker is null)
		return HOOK_CONTINUE;

	CBaseEntity@ pBreakable = cast<CBaseEntity@>(g_EntityFuncs.Instance(info.pVictim.pev));
	CBaseEntity@ pAttacker = cast<CBaseEntity@>(g_EntityFuncs.Instance(info.pAttacker.pev));
	
	if(pBreakable is null || pAttacker is null || !pAttacker.IsPlayer())
		return HOOK_CONTINUE;
		
	CBasePlayer@ pPlayer = cast<CBasePlayer@>(@pAttacker);

	string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	if(pHitFeedbackDic.exists(steamId))
	{
		CPlayerHitFeedbackData@ data = cast<CPlayerHitFeedbackData@>(pHitFeedbackDic[steamId]);
		if( data.IsHPBar )
		{
			if(pBreakable.pev.max_health > 0)
			{	
				SendHPHud(pPlayer, pBreakable, info.flDamage, true);
			}
		}
		if( data.IsHitmarker )
		{
			SendHitFeedback( pPlayer, (pBreakable.pev.impulse > 0) ? RGBA(240, 134, 80, 255) : RGBA(255, 255, 0, 255) );
		}
	}
	return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
	if( pPlayer is null || !pPlayer.IsPlayer() || pAttacker is null || pPlayer is pAttacker || pAttacker.GetClassname() == "worldspawn")
		return HOOK_CONTINUE;
	
	string targetname;
	CBaseEntity@ pVictim = cast<CBaseEntity@>(@pPlayer);
	if(pAttacker.IsPlayer())
	{
		CBasePlayer@ pTargetPlayer = cast<CBasePlayer@>(@pAttacker);
		targetname = pTargetPlayer.pev.netname;
	}
	else
	{
		targetname = pAttacker.pev.classname;
	}

	float distance = GetDistance(pVictim, pAttacker);
	
	g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[HitFeedback] 你被 " + targetname + " 击杀 (距离 " + int(distance) + " 单位)");
	return HOOK_CONTINUE;
}

float GetDistance(CBaseEntity@ pVictim, CBaseEntity@ pAttacker)
{
	Vector vecCenter1 = pVictim.pev.origin + pVictim.pev.size * 0.5;
    Vector vecCenter2 = pAttacker.pev.origin + pAttacker.pev.size * 0.5;

    Vector delta = vecCenter2 - vecCenter1;
    float distance = delta.Length();
	
	return distance;
}

void CheckGrenade() 
{
	for(int i = 1; i <= g_Engine.maxClients; ++i) 
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
		if (pPlayer !is null && pPlayer.IsConnected()) 
		{
			string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
			if(!pHitFeedbackDic.exists(steamId))
				return;

			CPlayerHitFeedbackData@ data = cast<CPlayerHitFeedbackData@>(pHitFeedbackDic[steamId]);
			if( data.IsGrenade )
				SendGrenadeHUD( pPlayer );
		}
	}
}

void SendHPHud(CBasePlayer@ pPlayer, CBaseEntity@ pVictim, float flDamage, bool IsBreakable = false)
{
	HUDTextParams hpbarparams;
	hpbarparams.channel = 4;
	hpbarparams.x = -1.0;
	hpbarparams.y = -0.35;
	hpbarparams.a1 = 0;
	hpbarparams.effect = 2;
	hpbarparams.fadeinTime = 0;
	hpbarparams.fadeoutTime = 0.5;
	hpbarparams.holdTime = 1;
	hpbarparams.fxTime = 0.5;
	
	string deductDisplay = (int(flDamage) == 0) ? " MISS!" : " -" + int(flDamage);
	string healthDisplay, remainingDisplay;

	float health 		= Math.clamp(0.0, Math.INT32_MAX, pVictim.pev.health - flDamage);
	float maxHealth 	= Math.clamp(0.0, Math.INT32_MAX, pVictim.pev.max_health);

	if(maxHealth < health)
		maxHealth = health;
	
	int healthDashes 	= 20;
	int dashConvert 	= Math.clamp(1, Math.INT32_MAX, int(maxHealth/healthDashes));

	int currentDashes 	= int( health / dashConvert );	
	int remainingHealth = healthDashes - currentDashes;
	for(int i = 0; i < currentDashes; i++)
	{
		healthDisplay.opAddAssign('|');
	}
	for(int j = 0; j < remainingHealth; j++)
	{
		remainingDisplay.opAddAssign('_');
	}
	
	string szName, szRelation, szHPBar, szNum, szPercent, szOuputUI;
	szHPBar 	= "[" + healthDisplay + remainingDisplay + "]";
	szNum 		= string(int(health)) + " / " + string(int(maxHealth));
	szPercent 	= " (" + string(int((health/maxHealth)*100)) + "%) ";

	if(IsBreakable)
	{
		hpbarparams.r1 = 255;
		hpbarparams.g1 = 255;
		hpbarparams.b1 = 0;
		if(health <= 0)
		{
			hpbarparams.r1 = 255;
			hpbarparams.g1 = 0;
			hpbarparams.b1 = 0;
			deductDisplay = " [BROKEN]";
			if(pVictim.pev.impulse > 0)
				g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[HitFeedback] " + pPlayer.pev.netname + " 引爆了一个爆炸破坏物");
		}
		szName = "Breakable";
		szRelation = (pVictim.pev.impulse > 0) ? "[Explosive] " : "";
		if(pVictim.pev.spawnflags & 512 != 0)
			szRelation.opAddAssign("ExplosiveOnly/Immue ");
		if(pVictim.pev.spawnflags & 64 != 0)
			szRelation.opAddAssign("Immue ");
	} 
	else
	{
		hpbarparams.r1 = 140;
		hpbarparams.g1 = 220;
		hpbarparams.b1 = 250;
		if(pVictim.IsPlayerAlly())
		{
			hpbarparams.r1 = 117;
			hpbarparams.g1 = 249;
			hpbarparams.b1 = 77;
			deductDisplay = " [FRIENDLY]";
		}
		if(health <= 0)
		{
			hpbarparams.r1 = 255;
			hpbarparams.g1 = 0;
			hpbarparams.b1 = 0;
			deductDisplay = " [DEAD]";
		}
		if(pVictim.IsPlayer())
		{
			CBasePlayer@ pTargetPlayer = cast<CBasePlayer@>(@pVictim);
			szName = string(pTargetPlayer.pev.netname);
		}
		else
		{
			CBaseMonster@ pMonster = cast<CBaseMonster@>(@pVictim);
			szName = string(pMonster.m_FormattedName);
		}
		szRelation = (pVictim.IsPlayerAlly()) ? "Friendly: " : "Enemy: ";
	}
	if(pVictim.pev.max_health < Math.INT32_MAX)
	{
		szOuputUI = szRelation + szName + "\n" +  szHPBar + deductDisplay + "\n" + szNum + szPercent;
	}
	else {
		szOuputUI = szRelation + szName + "\n" + "[|||INVINCIBLE|||]" + deductDisplay;
	}
	g_PlayerFuncs.HudMessage( pPlayer, hpbarparams, szOuputUI);
}

void SendHitFeedback( CBasePlayer@ pPlayer, RGBA color )
{	
	HUDSpriteParams HitMarkerparams;
	HitMarkerparams.channel = 5;
	HitMarkerparams.flags =  HUD_ELEM_SCR_CENTER_Y | HUD_ELEM_SCR_CENTER_X | HUD_SPR_MASKED | HUD_ELEM_DEFAULT_ALPHA;
	HitMarkerparams.spritename = "misc/hitmarker.spr";
	HitMarkerparams.x = 0;
	HitMarkerparams.y = 0;
	HitMarkerparams.fxTime = 0.03;
	HitMarkerparams.effect = HUD_EFFECT_RAMP_UP;
	HitMarkerparams.fadeinTime = 0.03;
	HitMarkerparams.fadeoutTime = 0.03;
	HitMarkerparams.holdTime = 0.2;
	HitMarkerparams.color2 = RGBA_WHITE;
	
	TraceResult tr;
	Math.MakeVectors( pPlayer.pev.v_angle );
	Vector vecSrc = pPlayer.GetGunPosition();
	Vector vecEnd = vecSrc + g_Engine.v_forward * 4096;
	
	g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );
	if(tr.flFraction >= 1.0)
	{
		g_Utility.TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, pPlayer.edict(), tr );
	}
	
	CBasePlayerWeapon@ activeItem = cast<CBasePlayerWeapon@>(pPlayer.m_hActiveItem.GetEntity());
	if(activeItem !is null && activeItem.GetClassname() != "weapon_medkit")
	{
		if(tr.iHitgroup == HITGROUP_HEAD)
		{
			HitMarkerparams.color1 = RGBA_RED;
			
			NetworkMessage message( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
			message.WriteString("spk " +  "misc/head.wav");
			message.End();
			//g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, "misc/head.wav", 1.0f, 1.0f, 0, PITCH_NORM, target_ent_unreliable:pPlayer.entindex());
		}
		else
		{
			HitMarkerparams.color1 = color;
			
			NetworkMessage message( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
			message.WriteString("spk " +  "misc/hitmarker.wav");
			message.End();
			//g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, "misc/hitmarker.wav", 1.0f, 1.0f, 0, PITCH_NORM, target_ent_unreliable:pPlayer.entindex());
		}
		g_PlayerFuncs.HudCustomSprite( pPlayer, HitMarkerparams );
	}
}

void SendGrenadeHUD( CBasePlayer@ pPlayer, float hold = 0.2 )
{
	CBaseEntity@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "grenade");
	if( pEntity !is null )
	{
		Vector vecLengh = pPlayer.pev.origin - pEntity.pev.origin;
		if( vecLengh.Length() < 256.0f )
		{
			HUDSpriteParams params;

			Vector vecAngle = vecLengh/vecLengh.Length();
			vecAngle = Vector(vecAngle.x + 1, vecAngle.y + 1, vecAngle.z + 1).opDiv(2);
			
			Vector vecAim = pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES )/pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES ).Length();
			vecAim = Vector(vecAim.x + 1, vecAim.y + 1, vecAim.z + 1 ).opDiv(2);
			
			Vector2D vecHUD = ((vecAngle + vecAim)/2).Make2D();
			
			params.channel = 6;
			params.spritename = "misc/grenade.spr";
			params.x = vecHUD.x ;
			params.y = vecHUD.y ;
			params.holdTime = hold;
			params.color1 = ( pEntity.IRelationship( pPlayer ) >= R_DL ) ? RGBA_RED : RGBA_SVENCOOP;
			g_PlayerFuncs.HudCustomSprite( pPlayer, params );
		}	
	}
}


