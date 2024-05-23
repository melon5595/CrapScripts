const string SC_ConfirmDead = "$i_IsDead";

array<string> smallType =
{
	"monster_alien_babyvoltigore",
	"monster_babycrab",
	"monster_barnacle",
	"monster_chumtoad",
	"monster_headcrab",
	"monster_houndeye",
	"monster_miniturret",
	"monster_sentry",
	"monster_shockroach",
	"monster_snark",
	"monster_stukabat",
	"monster_turret"
};

array<string> mediumType =
{
	"monster_alien_controller",
	"monster_alien_slave",
	"monster_alien_grunt",
	"monster_assassin_repel",
	"monster_barney",
	"monster_bodyguard",
	"monster_bullchicken",
	"monster_cleansuit_scientist",
	"monster_gonome",
	"monster_grunt_repel",
	"monster_human_assassin",
	"monster_human_grunt",
	"monster_hwgrunt",
	"monster_hwgrunt_repel",
	"monster_male_assassin",
	"monster_zombie",
	"monster_zombie_barney",
	"monster_zombie_soldier",
	"monster_shocktrooper",	
	"monster_otis",
	"monster_pitdrone",
	"monster_robogrunt",
	"monster_robogrunt_repel",
	"monster_scientist"
};

array<string> largeType =
{
	"monster_alien_tor",
	"monster_alien_voltigore",
	"monster_babygarg",
	"monster_bigmomma",
	"monster_gargantua",
	"monster_kingpin"
};


bool IsFirstDead(CBaseEntity@ pEntity)
{
	CustomKeyvalues@ pVicCustom = pEntity.GetCustomKeyvalues();
	if(pVicCustom.GetKeyvalue(SC_ConfirmDead).GetInteger() == 1)
		return false; 
	else 
		return true;
}

bool IsPlayerDucking(CBasePlayer@ pPlayer)
{
	return pPlayer.pev.flags & FL_DUCKING != 0;
}

bool IsPlayerInWater(CBasePlayer@ pPlayer)
{
	return pPlayer.pev.flags & FL_INWATER != 0;
}

bool IsPlayerMidAir(CBasePlayer@ pPlayer)
{
	return pPlayer.pev.flags & FL_ONGROUND == 0;
}



bool IsOneShot(float flDamage, CBaseEntity@ pEntity)
{
	return flDamage >= pEntity.pev.max_health;
}

bool IsLongShot(CBaseEntity@ pVictim, CBaseEntity@ pAttacker)
{
	Vector vecCenter1 = pVictim.pev.origin + pVictim.pev.size * 0.5;
    Vector vecCenter2 = pAttacker.pev.origin + pAttacker.pev.size * 0.5;

    Vector delta = vecCenter2 - vecCenter1;
    float distance = delta.Length();
	
	return distance > 1024.0f;
}

bool IsHead(CBasePlayer@ pPlayer)
{
	TraceResult tr;
	Math.MakeVectors( pPlayer.pev.v_angle );
	Vector vecSrc = pPlayer.GetGunPosition();
	Vector vecEnd = vecSrc + g_Engine.v_forward * 4096;
	
	g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );
	if(tr.flFraction >= 1.0)
	{
		g_Utility.TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, pPlayer.edict(), tr );
	}
	
	return tr.iHitgroup == HITGROUP_HEAD;
}

bool IsLastBullet(CBasePlayer@ pPlayer)
{
	CBasePlayerWeapon@ activeItem = cast<CBasePlayerWeapon@>(pPlayer.m_hActiveItem.GetEntity());
	if(activeItem !is null && activeItem.m_iClip != -1)
		return activeItem.m_iClip == 0;
	else
		return false;
}


void AddBonusPoint(CBasePlayer@ pPlayer, int iPoint, float flMultiplier)
{
	pPlayer.pev.frags += iPoint * flMultiplier;
}

//g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, pVictim.GetClassname() );
