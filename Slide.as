const string SLIDE_DID = "$i_didslide";
const string SLIDE_DIDDOUBLE = "$i_diddouble";

const string SLIDE_WALLGLIDE = "$i_wallglide";
const string SLIDE_DOUBLEJUMP = "$i_doublejump";
const string SLIDE_FORBIDDEN = "$i_forbidden";
const string SLIDE_JUMPTIME = "$f_jumptime";

const string SLIDE_SPR = "sprites/fun/laserbeam.spr";
const string SLIDE_SLIDESND = "misc/slide.mp3";
const string SLIDE_BOOSTSND = "tfc/weapons/airgun_1.wav";
const int SLIDE_IFORWARD = 100;
const int SLIDE_ISIDE = 75;

dictionary g_PlayerSlide;

class PlayerVelocityData
{
	int iForwardSpeed;
	int iSideSpeed;
}

void PluginInit() 
{
	g_Module.ScriptInfo.SetAuthor("Dr.Abc null");
	g_Module.ScriptInfo.SetContactInfo("ahhh");

	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
	g_Hooks.RegisterHook(Hooks::Player::PlayerPreThink, @PlayerPreThink);
	g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerSpawn);
	g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);
}

void Precache()
{
    g_Game.PrecacheModel( SLIDE_SPR );
	g_Game.PrecacheGeneric( SLIDE_SPR );
	
	g_Game.PrecacheGeneric( "sound/" + SLIDE_SLIDESND );
	g_Game.PrecacheGeneric( "sound/" + SLIDE_BOOSTSND );

	g_SoundSystem.PrecacheSound( SLIDE_SLIDESND );
	g_SoundSystem.PrecacheSound( SLIDE_BOOSTSND );
}


void MapInit() 
{
	Precache();
}

HookReturnCode ClientSay(SayParameters@ pParams) 
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();
	string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	if (pArguments.ArgC() == 1 ) 
	{
		if(pArguments.Arg(0).ToLowercase() == "!slide") 
		{
			pParams.ShouldHide = false;
			if(g_PlayerSlide.exists(szSteamId))
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Slide] Disabled.\n");
				g_PlayerSlide.delete(szSteamId);
			}
			else
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Slide] Enabled.\n");
				g_PlayerSlide[szSteamId] = 1;			
			}
			return HOOK_HANDLED;
		}
	}
	return HOOK_CONTINUE;
}

HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
{
	g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_WALLGLIDE, 0);
	g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_DID, 0);
	g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_DOUBLEJUMP, 0);
	
	Clean(@pPlayer);
	
    return HOOK_HANDLED;
}

HookReturnCode MapChange()
{
	g_Scheduler.ClearTimerList();
	
    return HOOK_HANDLED;
}

HookReturnCode PlayerPreThink( CBasePlayer@ pPlayer, uint& out uiFlags )
{
	CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
	string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
	Vector velocity = pPlayer.pev.velocity;
	float speed = sqrt( pow( velocity.x, 2.0 ) + pow( velocity.y, 2.0 ) );

	if(pPlayer is null || !pPlayer.IsAlive() || !g_PlayerSlide.exists(szSteamId))
		return HOOK_CONTINUE;


	if(pPlayer.pev.button & IN_DUCK != 0 && pPlayer.pev.flags & FL_ONGROUND != 0 && pPlayer.pev.flags & FL_DUCKING != 1)
	{	
		if(pCustom.GetKeyvalue(SLIDE_DID).GetInteger() == 1 || int(speed) <= 240 || int(speed) > 550)
			return HOOK_CONTINUE;
		
		PlayerVelocityData data;
		if(pPlayer.pev.button & IN_FORWARD != 0)
		{
			if(pPlayer.pev.button & IN_MOVELEFT != 0)
			{
				data.iForwardSpeed = SLIDE_IFORWARD;
				data.iSideSpeed = -SLIDE_ISIDE;
				g_PlayerSlide[szSteamId] = data;
			}
			else if(pPlayer.pev.button & IN_MOVERIGHT != 0)
			{
				data.iForwardSpeed = SLIDE_IFORWARD;
				data.iSideSpeed = SLIDE_ISIDE;
				g_PlayerSlide[szSteamId] = data;
			}
			else 	
			{
				data.iForwardSpeed = SLIDE_IFORWARD;
				data.iSideSpeed = 0;
				g_PlayerSlide[szSteamId] = data;
			}
		}
		else if(pPlayer.pev.button & IN_MOVELEFT != 0)
		{
			data.iForwardSpeed = 0;
			data.iSideSpeed = -SLIDE_ISIDE;
			g_PlayerSlide[szSteamId] = data;
		}
		else if(pPlayer.pev.button & IN_MOVERIGHT != 0)
		{
			data.iForwardSpeed = 0;
			data.iSideSpeed = SLIDE_ISIDE;
			g_PlayerSlide[szSteamId] = data;
		}
		else
		{
			return HOOK_CONTINUE;
		}
		g_Scheduler.SetInterval("SlideBoost", 0.05, 20, @pPlayer, szSteamId);
		g_Scheduler.SetTimeout("DidBoost", 1.5, @pPlayer);
		g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_DID, 1);
		SlideEffect(pPlayer);
	}
	
    if(pPlayer.pev.flags & FL_ONGROUND == 0 && (pPlayer.m_afPhysicsFlags == 0 || pPlayer.m_afPhysicsFlags == PFLAG_USING) )
	{
		if(pPlayer.pev.oldbuttons & IN_JUMP == 0 && pPlayer.pev.button & IN_JUMP != 0 && pCustom.GetKeyvalue(SLIDE_DOUBLEJUMP).GetInteger() != 1)
		{
			g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_DOUBLEJUMP, 1);
			Math.MakeVectors(pPlayer.pev.angles);
			Vector vecAgles = Math.VecToAngles(pPlayer.pev.velocity);
			pPlayer.pev.velocity = pPlayer.pev.velocity + g_Engine.v_up * 255;
			g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, SLIDE_BOOSTSND, 1.0, ATTN_NORM, 0, 100 + Math.RandomLong( -10, 10 ));
			NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
			m.WriteByte(TE_BEAMFOLLOW);
				m.WriteShort(pPlayer.entindex());
				m.WriteShort(g_EngineFuncs.ModelIndex(SLIDE_SPR));
				m.WriteByte(1);
				m.WriteByte(8);
				m.WriteByte(125);
				m.WriteByte(125);
				m.WriteByte(255);
				m.WriteByte(255);
			m.End();
		}

		if(pCustom.GetKeyvalue(SLIDE_DOUBLEJUMP).GetInteger() == 1)
		{
			TraceResult tr;
			//不知道有什么作用但是不这样做g_Engine.v_xxx会乱
			Vector vecSrc = pPlayer.pev.origin;
			Math.MakeVectors(pPlayer.pev.angles);
			Math.VecToAngles(pPlayer.pev.velocity);
			//玩家左右16距离寻找墙壁
			float flCheckDist = (pPlayer.pev.size.x + pPlayer.pev.size.y) / 2 + 16;
			//先寻找右边墙壁
			g_Utility.TraceLine(vecSrc, vecSrc + g_Engine.v_right * flCheckDist, dont_ignore_monsters, dont_ignore_glass, pPlayer.edict(), tr);
			bool bIsRight = IsInWall(tr);
			bool bFlag;
			//未找到则寻找左边
			if(!bIsRight)
			{
				g_Utility.TraceLine(vecSrc, vecSrc + g_Engine.v_right * -flCheckDist, dont_ignore_monsters, dont_ignore_glass, pPlayer.edict(), tr);
				bFlag = IsInWall(tr);
			}
			else //找到了
				bFlag = true;

			//找到了墙壁
			if(bFlag && pCustom.GetKeyvalue(SLIDE_FORBIDDEN).GetInteger() != 1)
			{
				//移动玩家视角营造滑行效果
				//pPlayer.pev.punchangle.y += bIsRight ? -2 : 2; 
				//pPlayer.pev.punchangle.y = Math.clamp(-20.0f, 20.0f, pPlayer.pev.punchangle.y);
				//第一次贴墙
				if(pCustom.GetKeyvalue(SLIDE_WALLGLIDE).GetInteger() != 1)
					StartGlide(pPlayer, bIsRight);
				else
				{
					//帅气的第三人称
					pPlayer.pev.sequence = 11;
					pPlayer.pev.gaitsequence = 6;
					//不准朝天上飞
					if(pPlayer.pev.velocity.z > 0)
						pPlayer.pev.velocity.z = 0;       
					//再次拍空格则从墙上弹开
					//Logger::Log(CrossProduct(tr.vecPlaneNormal, pPlayer.pev.angles).z);
					if(pPlayer.pev.oldbuttons & IN_JUMP == 0 && pPlayer.pev.button & IN_JUMP != 0)
					{
						//0.5s允许弹开一次
						if(g_Engine.time - pCustom.GetKeyvalue(SLIDE_JUMPTIME).GetFloat() >= 0.5f)
						{
							float flSpeed = Math.max(256, pPlayer.pev.velocity.Length());
							pPlayer.pev.velocity = pPlayer.pev.velocity + tr.vecPlaneNormal * flSpeed + g_Engine.v_up * flSpeed;
							g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_JUMPTIME, g_Engine.time);
							g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, SLIDE_BOOSTSND, 1.0, ATTN_NORM, 0, 100 + Math.RandomLong( -10, 10 ));
							g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_DOUBLEJUMP, 0);
							StopGlide(pPlayer);
						}
					}
					//速度太慢，直接掉落
					Vector vecTemp = pPlayer.pev.velocity;
					vecTemp.z = 0;
					if(vecTemp.Length() < 96)
					{
						//禁止再次贴墙
						StopGlide(pPlayer);
						g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_FORBIDDEN, 1);
					}
				}
			}
			else if(pCustom.GetKeyvalue(SLIDE_WALLGLIDE).GetInteger() == 1)
				StopGlide(pPlayer);
		}
	}
	else
	{
		Clean(@pPlayer);
	}
	return HOOK_CONTINUE;
}

bool IsInWall(TraceResult&in tr)
{
	return tr.flFraction <= 0.5;
}

void StartGlide(CBasePlayer@ pPlayer, bool bIsRight)
{
	if(pPlayer is null || !pPlayer.IsAlive())
		return;
	
	g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_WALLGLIDE, 1);
	Vector vecForward = g_Engine.v_forward;
	vecForward.z = 0;
	pPlayer.pev.velocity = pPlayer.pev.velocity + g_Engine.v_right * (bIsRight ? 1 : -1 ) * 200;
	pPlayer.pev.velocity = pPlayer.pev.velocity + vecForward * 128;
	pPlayer.pev.gravity = 0.05;

	NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
		m.WriteByte(TE_BEAMFOLLOW);
		m.WriteShort(pPlayer.entindex());
		m.WriteShort(g_EngineFuncs.ModelIndex(SLIDE_SPR));
		m.WriteByte(2);
		m.WriteByte(8);
		m.WriteByte(125);
		m.WriteByte(125);
		m.WriteByte(255);
		m.WriteByte(125);
	m.End();
}

void StopGlide(CBasePlayer@ pPlayer)
{
	if(pPlayer is null || !pPlayer.IsAlive())
		return;

	g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_WALLGLIDE, 0);
	pPlayer.pev.gravity = 1;
}

void Clean(CBasePlayer@ pPlayer)
{
	if(pPlayer is null || !pPlayer.IsAlive())
		return;

	CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
	if(pCustom.GetKeyvalue(SLIDE_DOUBLEJUMP).GetInteger() == 1)
			g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_DOUBLEJUMP, 0);
	if(pCustom.GetKeyvalue(SLIDE_WALLGLIDE).GetInteger() == 1)
	{
		NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
			m.WriteByte(TE_KILLBEAM);
			m.WriteShort(pPlayer.entindex());
		m.End();
		StopGlide(pPlayer);
	}
	if(pCustom.GetKeyvalue(SLIDE_FORBIDDEN).GetInteger() == 1)
		g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_FORBIDDEN, 0);
	if(pCustom.GetKeyvalue(SLIDE_JUMPTIME).GetFloat() != 0)
		g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_JUMPTIME, 0);
}

void SlideBoost(CBasePlayer@ pPlayer, const string szSteamId)
{
	if(pPlayer is null || !pPlayer.IsAlive())
		return;

	PlayerVelocityData@ data = cast<PlayerVelocityData@>( g_PlayerSlide[szSteamId] );
	if(pPlayer.pev.flags & FL_ONGROUND != 0)
	{
		if(pPlayer.pev.button & IN_DUCK != 0)
		{
			Math.MakeVectors(pPlayer.pev.angles);
			Vector vecAngles = Math.VecToAngles(pPlayer.pev.velocity);
			pPlayer.pev.velocity = pPlayer.pev.velocity + g_Engine.v_forward * data.iForwardSpeed + g_Engine.v_right * data.iSideSpeed;
			//g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTNOTIFY, "ground ducking forward "+ data.iForwardSpeed + " side " + data.iSideSpeed + "\n");
		}
		else
		{
			Math.MakeVectors(pPlayer.pev.angles);
			Vector vecAngles = Math.VecToAngles(pPlayer.pev.velocity);
			pPlayer.pev.velocity = pPlayer.pev.velocity + g_Engine.v_forward * int(data.iForwardSpeed / 4) + g_Engine.v_right * int(data.iSideSpeed / 4);
			//g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTNOTIFY, "ground standing forward "+ int(data.iForwardSpeed / 5) + " side " + int(data.iSideSpeed / 5) + "\n");
		}
	}
}

void DidBoost(CBasePlayer@ pPlayer)
{	
	if(pPlayer is null || !pPlayer.IsAlive())
		return;

	g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_DID, 0);
	NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
		m.WriteByte(TE_KILLBEAM);
		m.WriteShort(pPlayer.entindex());
	m.End();
}

void SlideEffect(CBaseEntity@ pEntity)
{
	NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
		m.WriteByte(TE_BEAMFOLLOW);
		m.WriteShort(pEntity.entindex());
		m.WriteShort(g_EngineFuncs.ModelIndex(SLIDE_SPR));
		m.WriteByte(2); // Life
		m.WriteByte(6); // Width
		m.WriteByte(160); // R
		m.WriteByte(160); // G
		m.WriteByte(160); // B
		m.WriteByte(150); // Alpha
    m.End();
	
	g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_ITEM, SLIDE_SLIDESND, 0.85, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) );
}