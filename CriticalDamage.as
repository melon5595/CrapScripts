void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "null" );
	g_Module.ScriptInfo.SetContactInfo( "yee" );
	
	g_Hooks.RegisterHook(Hooks::Monster::MonsterTakeDamage, @CritChance);
}

void MapInit()
{
	g_Game.PrecacheModel( "sprites/misc/minicrit.spr" );
	g_SoundSystem.PrecacheSound( "misc/crit.wav" );
	
	g_Game.PrecacheGeneric( "sprites/misc/minicrit.spr" );
	g_Game.PrecacheGeneric( "sound/misc/crit.wav" );

}

HookReturnCode CritChance(DamageInfo@ info)
{
	if(info.pVictim is null || info.pAttacker is null)
		return HOOK_CONTINUE;

	CBaseEntity@ pVictim = cast<CBaseEntity@>(g_EntityFuncs.Instance(info.pVictim.pev));
	CBaseEntity@ pAttacker = cast<CBaseEntity@>(g_EntityFuncs.Instance(info.pAttacker.pev));
	
	if(pVictim is null || pVictim.IsPlayer() || pAttacker is null || !pAttacker.IsPlayer())
		return HOOK_CONTINUE;
	
	float flChance = Math.RandomFloat( 0.0f, 1.0f );
	if(flChance <= 0.1f)
	{
		info.flDamage*= Math.RandomLong( 2, 4 );
		
		NetworkMessage beffect( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
			beffect.WriteByte( TE_EXPLOSION );
			beffect.WriteCoord( pVictim.GetOrigin().x );
			beffect.WriteCoord( pVictim.GetOrigin().y );
			beffect.WriteCoord( pVictim.GetOrigin().z + 72 );
			beffect.WriteShort( g_EngineFuncs.ModelIndex("sprites/misc/minicrit.spr") );
			beffect.WriteByte( 4 ); //scale
			beffect.WriteByte( 2 ); //framerate
			beffect.WriteByte( TE_EXPLFLAG_NODLIGHTS | TE_EXPLFLAG_NOSOUND | TE_EXPLFLAG_NOPARTICLES );
		beffect.End();
		
		g_SoundSystem.EmitSoundDyn( pVictim.edict(), CHAN_ITEM, "misc/crit.wav", 1, ATTN_NORM, 0, PITCH_NORM);
	}
	
	return HOOK_CONTINUE;
}