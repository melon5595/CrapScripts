namespace Directive
{
	namespace DecreasedStats
	{
		string Name = "半吊子特工";
		string Desc = "所有玩家最大血量/护甲减少";
		bool DirectiveActive = false;
		
		void Precache()
		{
		
		}
		
		void Announcer()
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[" + Name + "] 已设置为 " + string(DirectiveActive) + "\n");
		}
		
		void Init()
		{
			for (int i = 1; i <= g_Engine.maxClients; ++i) 
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
				if (pPlayer !is null && pPlayer.IsConnected()) 
				{
					pPlayer.pev.max_health *= DecreaseVal;
					pPlayer.pev.health *= DecreaseVal;
					pPlayer.pev.armortype *= DecreaseVal;
					pPlayer.pev.armorvalue *= DecreaseVal;
				}
			}
		}
		
		void Modifier(CBasePlayer@ pPlayer)
		{
			pPlayer.pev.max_health *= DecreaseVal;
			pPlayer.pev.health *= DecreaseVal;
			pPlayer.pev.armortype *= DecreaseVal;
			pPlayer.pev.armorvalue *= DecreaseVal;
		}
		
		void Disable()
		{
			DirectiveActive = false;
			for (int i = 1; i <= g_Engine.maxClients; ++i) 
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
				if (pPlayer !is null && pPlayer.IsConnected()) 
				{
					pPlayer.pev.max_health += pPlayer.pev.max_health;
					pPlayer.pev.health += pPlayer.pev.health;
					pPlayer.pev.armortype += pPlayer.pev.armortype;
					pPlayer.pev.armorvalue += pPlayer.pev.armorvalue;
				}
			}
		}
	}
	
	namespace IncreasedStats
	{
		string Name = "特训特工";
		string Desc = "所有玩家最大血量/护甲提升";
		bool DirectiveActive = false;
		
		void Precache()
		{
		
		}
		
		void Announcer()
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[" + Name + "] 已设置为 " + string(DirectiveActive) + "\n");
		}
		
		void Init()
		{
			for (int i = 1; i <= g_Engine.maxClients; ++i) 
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
				if (pPlayer !is null && pPlayer.IsConnected()) 
				{
					pPlayer.pev.max_health *= IncreasedVal;
					pPlayer.pev.health *= IncreasedVal;
					pPlayer.pev.armortype *= IncreasedVal;
					pPlayer.pev.armorvalue *= IncreasedVal;
				}
			}
		}
		
		void Modifier(CBasePlayer@ pPlayer)
		{
			pPlayer.pev.max_health *= IncreasedVal;
			pPlayer.pev.health *= IncreasedVal;
			pPlayer.pev.armortype *= IncreasedVal;
			pPlayer.pev.armorvalue *= IncreasedVal;
		}
		
		void Disable()
		{
			DirectiveActive = false;
			for (int i = 1; i <= g_Engine.maxClients; ++i) 
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
				if (pPlayer !is null && pPlayer.IsConnected()) 
				{
					pPlayer.pev.max_health /= IncreasedVal;
					pPlayer.pev.health /= IncreasedVal;
					pPlayer.pev.armortype /= IncreasedVal;
					pPlayer.pev.armorvalue /= IncreasedVal;
				}
			}
		}
	}
	
	namespace WeArePilot
	{
		string Name = "化身铁驭";
		string Desc = "获得双重跳/滑铲/贴墙滑行能力";
		bool DirectiveActive = false;
		
		dictionary g_PlayerSlide;
		CScheduledFunction@ g_SchSlideBoost = null;
		CScheduledFunction@ g_SchDidBoost = null;
		
		class PlayerVelocityData
		{
			int iForwardSpeed;
			int iSideSpeed;
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
		
		void Announcer()
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[" + Name + "] 已设置为 " + string(DirectiveActive) + "\n");
		}
		
		void Init()
		{
			g_EngineFuncs.CVarSetFloat("mp_falldamage", -1);
			for(int i = 1; i <= g_Engine.maxClients; ++i) 
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
				if (pPlayer !is null && pPlayer.IsConnected()) 
				{
					g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_WALLGLIDE, 0);
					g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_DID, 0);
					g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_DOUBLEJUMP, 0);
					Clean(pPlayer);
				}
			}
		}
		
		bool IsInWall(TraceResult&in tr)
		{
			return tr.flFraction <= 0.5;
		}
		
		void MotionCheck(CBasePlayer@ pPlayer)
		{
			CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
			string szSteamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
			float speed = sqrt( pow( pPlayer.pev.velocity.x, 2.0 ) + pow( pPlayer.pev.velocity.y, 2.0 ) );
			if(pPlayer.pev.button & IN_DUCK != 0 && pPlayer.pev.flags & FL_ONGROUND != 0 && pPlayer.pev.flags & FL_DUCKING != 1)
			{	
				if(pCustom.GetKeyvalue(SLIDE_DID).GetInteger() == 1 || int(speed) <= 240 || int(speed) > 550)
					return;
				
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
					return;
				}
				@g_SchSlideBoost = g_Scheduler.SetInterval("SlideBoost", 0.05, 20, @pPlayer, szSteamId);
				@g_SchDidBoost = g_Scheduler.SetTimeout("DidBoost", 1.5, @pPlayer);
				SlideEffect(pPlayer);
				g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_DID, 1);
			}
			if(pPlayer.pev.flags & FL_ONGROUND == 0 && (pPlayer.m_afPhysicsFlags == 0 || pPlayer.m_afPhysicsFlags == PFLAG_USING) )
			{
				if(pPlayer.pev.oldbuttons & IN_JUMP == 0 && pPlayer.pev.button & IN_JUMP != 0 && pCustom.GetKeyvalue(SLIDE_DOUBLEJUMP).GetInteger() != 1)
				{
					g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_DOUBLEJUMP, 1);
					Math.MakeVectors(pPlayer.pev.angles);
					Vector vecAgles = Math.VecToAngles(pPlayer.pev.velocity);
					pPlayer.pev.velocity.z = 0;
					pPlayer.pev.velocity = pPlayer.pev.velocity + g_Engine.v_up * 400;
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
				Clean(pPlayer);
			}
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
			pPlayer.pev.velocity.z = 0;
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
			
			if(pPlayer.pev.button & IN_DUCK == 0)
			{
				g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), SLIDE_DID, 0);
				//g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTNOTIFY, "standingClean\n");
			}
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
		
		void ResetCheck(CBasePlayer@ pPlayer)
		{
			if(pPlayer !is null && pPlayer.pev.flags & FL_ONGROUND != 0 ) 
			{
				Clean(pPlayer);
			}
		}
		
		void Disable()
		{
			g_EngineFuncs.CVarSetFloat("mp_falldamage", 1);
			DirectiveActive = false;
			g_PlayerSlide.deleteAll();
			g_Scheduler.RemoveTimer(@g_SchSlideBoost);
			g_Scheduler.RemoveTimer(@g_SchDidBoost);
		}
	}
	
	namespace Ragers
	{
		string Name = "愤怒者";
		string Desc = "击杀敌人将增加其周围敌人的血量";
		bool DirectiveActive = false;
		
		array<EHandle> monsterHandle;
		CScheduledFunction@ g_SchRager = null;
		
		void Precache()
		{
		
		}
		
		void Announcer()
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[" + Name + "] 已设置为 " + string(DirectiveActive) + "\n");
		}
		
		void Init()
		{
		
		}
		
		void Check(CBaseEntity@ pVictim)
		{
			Vector vecSource = pVictim.GetOrigin();
			array<CBaseEntity@> nearbyEntity(32);		
			//Get monsters to track and get how many
			uint iTargetCount = g_EntityFuncs.MonstersInSphere(nearbyEntity, vecSource, RagerRadius);
			//g_Game.AlertMessage( at_console, "Number of radar targets: %1\n", iTargetCount );
			for(uint i = 0; i < nearbyEntity.length(); i++) //Loop through targets array
			{
				CBaseEntity@ foundEntity = nearbyEntity[i];

				if(foundEntity is null || string(foundEntity.pev.classname).StartsWith("monster_") == false || !foundEntity.IsAlive() || foundEntity.Classify() == CLASS_PLAYER || foundEntity.Classify() == CLASS_PLAYER_ALLY || ignoremosterlist.find(foundEntity.GetClassname()) >= 0)
					continue;
				
				foundEntity.pev.health += RagerHealVal;
				foundEntity.pev.max_health += RagerHealVal;
				
				NetworkMessage healfx(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
					healfx.WriteByte(TE_DLIGHT);
					healfx.WriteCoord(foundEntity.Center().x);
					healfx.WriteCoord(foundEntity.Center().y);
					healfx.WriteCoord(foundEntity.Center().z);
					healfx.WriteByte(8);
					healfx.WriteByte(255);
					healfx.WriteByte(0);
					healfx.WriteByte(0);
					healfx.WriteByte(5);
					healfx.WriteByte(2);
				healfx.End();
				//Vector vecTargetOrig = foundEntity.pev.origin; //Normalize with world origin
				//g_Game.AlertMessage( at_console, "Target vector: (%1, %2, %3) | " + foundEntity.pev.classname + "\n", vecTargetOrig.x, vecTargetOrig.y, vecTargetOrig.z);
			}
		}
		
		void Disable()
		{
			DirectiveActive = false;
		}
	}
	
	namespace MoveOrDie
	{
		string Name = "动或死";
		string Desc = "保持移动，血量根据移动动态变化";
		bool DirectiveActive = false;
		
		CScheduledFunction@ g_SchMoveOrDie = null;
		
		void Precache()
		{
		
		}
		
		void Announcer()
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[" + Name + "] 已设置为 " + string(DirectiveActive) + "\n");
		}
		
		void Init()
		{
			@g_SchMoveOrDie = g_Scheduler.SetInterval("MoveChecker", 0.5f, g_Scheduler.REPEAT_INFINITE_TIMES);
		}
		
		void MoveChecker()
		{
			for (int i = 1; i <= g_Engine.maxClients; i++)
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
				if( pPlayer !is null && pPlayer.IsConnected())
				{
					if(pPlayer.IsAlive())
					{
						if(!pPlayer.IsMoving())
						{
							if(pPlayer.pev.health <= 30)
								return;

							pPlayer.pev.health -= MODMinus;
						}
						if(pPlayer.IsMoving())
						{
							if(pPlayer.pev.health >= pPlayer.pev.max_health * 2)
								return;

							float speedh = sqrt( pow( pPlayer.pev.velocity.x, 2.0 ) + pow( pPlayer.pev.velocity.y, 2.0 ) );
							int plushealth = int(speedh / 50);
							
							pPlayer.pev.health += plushealth;
						}
					}
				}
			}
		}
		
		void Disable()
		{
			DirectiveActive = false;
			g_Scheduler.RemoveTimer(@g_SchMoveOrDie);
		}
	}
	
	namespace Bleeding
	{
		string Name = "失血状态";
		string Desc = "每三秒掉1HP，移动状态下掉2HP(30HP以下停止)";
		bool DirectiveActive = false;
		
		CScheduledFunction@ g_SchBleeding = null;
		
		void Precache()
		{
		
		}
		
		void Announcer()
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[" + Name + "] 已设置为 " + string(DirectiveActive) + "\n");
		}
		
		void Init()
		{
			@g_SchBleeding = g_Scheduler.SetInterval("BleedChecker", 3, g_Scheduler.REPEAT_INFINITE_TIMES);
		}
		
		void BleedChecker()
		{
			for (int i = 1; i <= g_Engine.maxClients; i++)
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
				if(pPlayer !is null && pPlayer.IsConnected())
				{
					if(pPlayer.IsAlive() && pPlayer.pev.health > 30 && pPlayer.pev.flags & FL_FROZEN != 1)
					{
						if(pPlayer.IsMoving()) {
							pPlayer.pev.health -= BleedMoving;
						}
						else {
							pPlayer.pev.health -= BleedStatic;
						}
					}
				}
			}
		}
		
		void Disable()
		{
			DirectiveActive = false;
			g_Scheduler.RemoveTimer(@g_SchBleeding);
		}
	}

	namespace AmmoHoarders
	{
		string Name = "子弹囤积者";
		string Desc = "弹药量减半，更换弹夹将丢失原有弹夹";
		bool DirectiveActive = false;
		
		void Precache()
		{
		
		}
		
		void Announcer()
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[" + Name + "] 已设置为 " + string(DirectiveActive) + "\n");
		}
		
		void Init()
		{
			for(int i = 1; i <= g_Engine.maxClients; i++) 
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
				if (pPlayer !is null && pPlayer.IsConnected()) 
				{
					AmmoCut(pPlayer);
				}
			}
		}
		
		void ReloadDrop(CBasePlayer@ pPlayer)
		{
			CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>(pPlayer.m_hActiveItem.GetEntity());
			if(pWeapon !is null && ignoreweplist.find(pWeapon.GetClassname()) < 0 && pPlayer.m_rgAmmo(pWeapon.m_iPrimaryAmmoType) >= pWeapon.iMaxClip() && pWeapon.m_iClip < pWeapon.iMaxClip() )
				pWeapon.m_iClip = 0;
		}
		
		void RespawnCut(CBasePlayer@ pPlayer)
		{
			AmmoCut(pPlayer);
		}
		
		void AmmoCut(CBasePlayer@ pPlayer)
		{
			for(uint j = 0; j < MAX_ITEM_TYPES; j++)
			{
				CBasePlayerItem@ pItem = pPlayer.m_rgpPlayerItems(j);
				if( pItem !is null )
				{
					CBasePlayerWeapon@ pWeapon = pItem.GetWeaponPtr();
					if( ignoreweplist.find(pWeapon.GetClassname()) < 0 && pWeapon !is null )
					{
						pPlayer.SetMaxAmmo(pWeapon.m_iPrimaryAmmoType, int(pPlayer.GetMaxAmmo(pWeapon.m_iPrimaryAmmoType) * AHCutdown));
						if(pPlayer.GetMaxAmmo(pWeapon.m_iSecondaryAmmoType) != -1)
							pPlayer.SetMaxAmmo(pWeapon.m_iSecondaryAmmoType, int(pPlayer.GetMaxAmmo(pWeapon.m_iSecondaryAmmoType) * AHCutdown));
						
						pPlayer.m_rgAmmo(pWeapon.m_iPrimaryAmmoType, int(pPlayer.m_rgAmmo(pWeapon.m_iPrimaryAmmoType) * AHCutdown));
						if(pPlayer.GetMaxAmmo(pWeapon.m_iSecondaryAmmoType) != -1)
							pPlayer.m_rgAmmo(pWeapon.m_iSecondaryAmmoType, int(pPlayer.m_rgAmmo(pWeapon.m_iSecondaryAmmoType) * AHCutdown));
						
						//g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, string(pWeapon.GetClassname()) + "\n");
					}
				}
			}
		}
		
		void Disable()
		{
			DirectiveActive = false;
		}
	}
	
	namespace Darken
	{
		string Name = "夜幕降临";
		string Desc = "玩家视野减小，注意使用手电";
		bool DirectiveActive = false;
		
		void Precache()
		{
		
		}
		
		void Announcer()
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[" + Name + "] 已设置为 " + string(DirectiveActive) + "\n");
		}
		
		void Init()
		{
			g_EngineFuncs.LightStyle(0, DarkLight);
		}
		
		void Modifier(CBasePlayer@ pPlayer)
		{
		
		}
		
		void Disable()
		{
			DirectiveActive = false;
			g_EngineFuncs.LightStyle(0, "m");
		}
	}
	
	namespace BulletKing
	{
		string Name = "枪弹师";
		string Desc = "弹夹小于30％时有20％的概率自动补充弹药并恢复20％的护甲";
		bool DirectiveActive = false;
		
		void Precache()
		{
			
		}
		
		void Init()
		{
		
		}
		
		void Announcer()
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[" + Name + "] 已设置为 " + string(DirectiveActive) + "\n");
		}
		
		void BulletCheck(CBasePlayer@ pPlayer)
		{
			CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>(pPlayer.m_hActiveItem.GetEntity());
			if(ignoreweplist.find(pWeapon.GetClassname()) < 0 && pWeapon !is null)
			{
				if(pPlayer.m_rgAmmo(pWeapon.m_iPrimaryAmmoType) >= pWeapon.iMaxClip())
				{
					if(pWeapon.m_iClip < pWeapon.iMaxClip() * 0.3f)
					{
						int iTemp = g_PlayerFuncs.SharedRandomLong( pPlayer.random_seed, 0, 100 );
						if(iTemp > 20)
							return;
						pPlayer.pev.armorvalue += BKAmmoRegen * pPlayer.pev.armortype;
						pPlayer.m_rgAmmo(pWeapon.m_iPrimaryAmmoType, pPlayer.m_rgAmmo(pWeapon.m_iPrimaryAmmoType) - (pWeapon.iMaxClip() - pWeapon.m_iClip));
						pWeapon.m_iClip = pWeapon.iMaxClip();
						g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_ITEM, "weapons/scock1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
					}
				}
			}
		}
		
		void Disable()
		{
			DirectiveActive = false;
		}
	}
	
	namespace GroupHeal
	{
		string Name = "团队医生";
		string Desc = "持有医疗包时将为附近队友恢复HP";
		bool DirectiveActive = false;
		
		CScheduledFunction@ g_SchGroupHeal = null;
		
		void Precache()
		{
		
		}
		
		void Announcer()
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[" + Name + "] 已设置为 " + string(DirectiveActive) + "\n");
		}
		
		void Init()
		{
			@g_SchGroupHeal = g_Scheduler.SetInterval("GroupHealCheck", 1, g_Scheduler.REPEAT_INFINITE_TIMES);
		}
		
		void Check(CBasePlayer@ pPlayer)
		{
			Vector vecSource = pPlayer.GetOrigin();
			array<CBaseEntity@> nearbyEntity(32);		
			//Get monsters to track and get how many
			uint iTargetCount = g_EntityFuncs.MonstersInSphere(nearbyEntity, vecSource, GroupHealRadius);
			//g_Game.AlertMessage( at_console, "Number of radar targets: %1\n", iTargetCount );
			for(uint i = 0; i < nearbyEntity.length(); i++) //Loop through targets array
			{
				CBaseEntity@ foundEntity = nearbyEntity[i];
				if(foundEntity is null || !foundEntity.IsPlayer() || !foundEntity.IsAlive())
					continue;

				if(foundEntity.pev.health < foundEntity.pev.max_health)
				{
					foundEntity.pev.health += GroupHealVal;
					NetworkMessage healfx(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
						healfx.WriteByte(TE_DLIGHT);
						healfx.WriteCoord(foundEntity.Center().x);
						healfx.WriteCoord(foundEntity.Center().y);
						healfx.WriteCoord(foundEntity.Center().z);
						healfx.WriteByte(8);
						healfx.WriteByte(0);
						healfx.WriteByte(255);
						healfx.WriteByte(0);
						healfx.WriteByte(5);
						healfx.WriteByte(2);
					healfx.End();
					
					NetworkMessage healcylfx(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
						healcylfx.WriteByte(TE_BEAMCYLINDER);
						healcylfx.WriteCoord(pPlayer.Center().x);
						healcylfx.WriteCoord(pPlayer.Center().y);
						healcylfx.WriteCoord(pPlayer.Center().z);
						healcylfx.WriteCoord(pPlayer.Center().x);
						healcylfx.WriteCoord(pPlayer.Center().y);
						healcylfx.WriteCoord(pPlayer.Center().z + float(GroupHealRadius));
						healcylfx.WriteShort(g_EngineFuncs.ModelIndex("sprites/laserbeam.spr"));
						healcylfx.WriteByte(0);
						healcylfx.WriteByte(16);
						healcylfx.WriteByte(8);
						healcylfx.WriteByte(8);
						healcylfx.WriteByte(0);
						healcylfx.WriteByte(0);
						healcylfx.WriteByte(255);
						healcylfx.WriteByte(0);
						healcylfx.WriteByte(100);
						healcylfx.WriteByte(0);
					healcylfx.End();
				}
				//Vector vecTargetOrig = foundEntity.pev.origin; //Normalize with world origin
				//g_Game.AlertMessage( at_console, "Target vector: (%1, %2, %3) | " + foundEntity.pev.classname + "\n", vecTargetOrig.x, vecTargetOrig.y, vecTargetOrig.z);
			}
		}
		
		void GroupHealCheck()
		{
			for(int i = 1; i <= g_Engine.maxClients; i++) 
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
				if(pPlayer !is null && pPlayer.IsConnected()) 
				{
					CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>(pPlayer.m_hActiveItem.GetEntity());
					if(pPlayer.IsAlive() && pWeapon !is null)
					{
						if(pWeapon.GetClassname() == "weapon_medkit")
							Check(pPlayer);
					}
				}
			}
		}
		
		void Disable()
		{
			DirectiveActive = false;
			g_Scheduler.RemoveTimer(@g_SchGroupHeal);
		}
	}
	
	namespace ExplosiveRounds
	{
		string Name = "爆炸子弹";
		string Desc = "射击的子弹有10％几率产生随机爆炸伤害";
		bool DirectiveActive = false;
		
		void Precache()
		{
			g_Game.PrecacheModel( "sprites/eexplo.spr" );
		}
		
		void Announcer()
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[" + Name + "] 已设置为 " + string(DirectiveActive) + "\n");
		}
		
		void Init()
		{
		
		}	
		
		void HitCheck(CBasePlayer@ pPlayer)
		{
			CBaseEntity@ pHit;
			CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>(pPlayer.m_hActiveItem.GetEntity());
			
			float flChance = Math.RandomFloat(0.0f,1.0f);
			if(flChance > ERChance)
				return;
			
			if(ignoreweplist.find(pWeapon.GetClassname()) < 0 && pWeapon !is null)
			{
				Vector vecSrc	 = pPlayer.GetGunPosition();
				Vector vecAiming = pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
				
				TraceResult tr;
				float x, y;
				g_Utility.GetCircularGaussianSpread( x, y );
				
				Vector vecDir = vecAiming + x * VECTOR_CONE_1DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_1DEGREES.y * g_Engine.v_up;
				Vector vecEnd = vecSrc + vecDir * 4096;

				g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );
				
				if(tr.flFraction < 1.0)
				{
					@pHit = g_EntityFuncs.Instance( tr.pHit );
					if ( pHit is null || pHit.IsBSPModel() )
						g_Utility.FindHullIntersection( vecSrc, tr, tr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, pPlayer.edict() );
					vecEnd = tr.vecEndPos;
				}
				if(tr.flFraction >= 1.0)
				{
					g_Utility.TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, pPlayer.edict(), tr );
				}
				
				int expdmg = Math.RandomLong(ERBaseDMG, 200);
				int expradius = Math.RandomLong(ERBaseRadius, 96);
				g_WeaponFuncs.RadiusDamage( vecEnd , pPlayer.pev, pPlayer.pev, expdmg, expradius, CLASS_PLAYER, DMG_BLAST | DMG_ALWAYSGIB );
				NullServerExplosion( vecEnd, "sprites/eexplo.spr", expradius, 30, TE_EXPLFLAG_NONE );
				g_Utility.DecalTrace( tr, DECAL_SCORCH1 + Math.RandomLong(0,1) );
			}
		}
		
		void Disable()
		{
			DirectiveActive = false;
		}
	}
	
	namespace CyberArmor
	{
		string Name = "赛博护甲";
		string Desc = "当护甲为0时牺牲10点血量回复护甲";
		bool DirectiveActive = false;
		
		void Precache()
		{
		
		}
		
		void Announcer()
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[" + Name + "] 已设置为 " + string(DirectiveActive) + "\n");
		}
		
		void Init()
		{
			for (int i = 1; i <= g_Engine.maxClients; ++i) 
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
				if (pPlayer !is null && pPlayer.IsConnected()) 
				{
					pPlayer.pev.armortype /= CRTransfer;
					pPlayer.pev.armorvalue /= CRTransfer;
				}
			}
		}
		
		void Modifier(CBasePlayer@ pPlayer)
		{
			pPlayer.pev.armortype /= CRTransfer;
			pPlayer.pev.armorvalue /= CRTransfer;
		}
		
		void ArmorChecker(CBasePlayer@ pPlayer)
		{
			if(pPlayer.pev.armorvalue == 0 && pPlayer.pev.health > 10)
			{
				pPlayer.pev.armorvalue += pPlayer.pev.armortype;
				pPlayer.pev.health -= CRHealUsed;
				
				g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_ITEM, "items/suitchargeok1.wav", 1.0, ATTN_NORM, 0, 120 );
			}
		}
		
		void Disable()
		{
			DirectiveActive = false;
			for (int i = 1; i <= g_Engine.maxClients; ++i) 
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
				if (pPlayer !is null && pPlayer.IsConnected()) 
				{
					pPlayer.pev.armortype *= CRTransfer;
					pPlayer.pev.armorvalue *= CRTransfer;
				}
			}
		}
	}
	
	namespace Bloodlust
	{
		string Name = "吸血鬼";
		string Desc = "击中敌人可回复生命值";
		bool DirectiveActive = false;
		
		void Precache()
		{
			
		}
		
		void Announcer()
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[" + Name + "] 已设置为 " + string(DirectiveActive) + "\n");
		}
		
		void Init()
		{
		
		}
		
		void Check(CBaseEntity@ pVictim, CBaseEntity@ pAttacker, float flAmount)
		{
			CBasePlayer@ pPlayer = cast<CBasePlayer@>(@pAttacker);	
			if(pVictim.Classify() != CLASS_PLAYER || pVictim.Classify() != CLASS_PLAYER_ALLY  && ignoremosterlist.find(pVictim.GetClassname()) < 0)
			{
				if(pPlayer.pev.health <= pPlayer.pev.max_health * 2)
				{
					pPlayer.pev.health += Math.clamp(0, pPlayer.pev.max_health * 2, flAmount);
				}
				NetworkMessage mElight(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
				mElight.WriteByte(TE_ELIGHT);
				mElight.WriteShort(pPlayer.entindex());
				mElight.WriteCoord(pPlayer.pev.origin.x);
				mElight.WriteCoord(pPlayer.pev.origin.y);
				mElight.WriteCoord(pPlayer.pev.origin.z);
				mElight.WriteCoord(256);
				mElight.WriteByte(255);
				mElight.WriteByte(0);
				mElight.WriteByte(0);
				mElight.WriteByte(5);
				mElight.WriteCoord(2000.0f);
				mElight.End();
			}
		}
		
		void Disable()
		{
			DirectiveActive = false;
		}
	}
	
	namespace StableShoot
	{
		string Name = "沉着冷静";
		string Desc = "无视武器射击视角抖动";
		bool DirectiveActive = false;
		
		void Precache()
		{
			
		}
		
		void Announcer()
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[" + Name + "] 已设置为 " + string(DirectiveActive) + "\n");
		}
		
		void Init()
		{
		
		}	
		
		void StableCheck(CBasePlayer@ pPlayer)
		{
			if(pPlayer !is null && pPlayer.IsConnected())
			{
				pPlayer.pev.punchangle = Vector(0, 0, 0);
			}
		}
		
		void Disable()
		{
			DirectiveActive = false;
		}
	}
	
	namespace SpeedyTackle
	{
		string Name = "迫不及待";
		string Desc = "移速增加，射速增加";
		bool DirectiveActive = false;
		
		CScheduledFunction@ g_SchSpeedShoot = null;
		
		void Precache()
		{
		
		}
		
		void Announcer()
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[" + Name + "] 已设置为 " + string(DirectiveActive) + "\n");
		}
	
		void Init()
		{
			g_EngineFuncs.CVarSetFloat("sv_maxspeed", SpeedyMaxSpeed);
			SetPlayerSpeed(SpeedyMaxSpeed);
			@g_SchSpeedShoot = g_Scheduler.SetInterval("SpeedyShoot", 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES);
		}
		
		void SetPlayerSpeed(int iSpeed)
		{
			for(int i = 1; i <= g_Engine.maxClients; ++i) 
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
				if (pPlayer !is null && pPlayer.IsConnected()) 
				{
					pPlayer.SetMaxSpeed(iSpeed);
					pPlayer.SetMaxSpeedOverride(iSpeed);
				}
			}
		}
		
		void SpeedyShoot()
		{
			for(int i = 1; i <= g_Engine.maxClients; ++i) 
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
				if (pPlayer !is null && pPlayer.IsConnected()) 
				{
					CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>( pPlayer.m_hActiveItem.GetEntity() );
					
					if(pWeapon !is null)
						pWeapon.m_flNextPrimaryAttack = pWeapon.m_flNextPrimaryAttack * .5;
				}
			}
			
		}
		
		void Disable()
		{
			g_EngineFuncs.CVarSetFloat("sv_maxspeed", 270);
			SetPlayerSpeed(270);
			
			DirectiveActive = false;
			g_Scheduler.RemoveTimer(@g_SchSpeedShoot);
		}
	}
	
	namespace GrenadeManiac
	{
		string Name = "炸弹狂热";
		string Desc = "免疫(部分(笑))爆炸伤害，并转化为你的血量";
		bool DirectiveActive = false;
		
		void Precache()
		{
		
		}
		
		void Announcer()
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[" + Name + "] 已设置为 " + string(DirectiveActive) + "\n");
		}
		
		void Init()
		{
			
		}
		
		void Check(CBaseEntity@ pVictim, float flDamage)
		{
			CBasePlayer@ pPlayer = cast<CBasePlayer@>(@pVictim);
			if(pPlayer.pev.health <= pPlayer.pev.max_health * 2)
				pPlayer.pev.health += Math.clamp(0, pPlayer.pev.max_health * 2, flDamage);
		}
		
		void Disable()
		{
			DirectiveActive = false;
		}
	}
	
	namespace RicochetArmor
	{
		string Name = "反弹护甲";
		string Desc = "护甲高于50%时，消耗部分护甲反弹伤害";
		bool DirectiveActive = false;
		
		bool IsCapableRicochet(CBasePlayer@ pPlayer)
		{
			if(pPlayer.pev.armorvalue < pPlayer.pev.armortype * 0.5f)
				return false;
			else return true;
		}
		
		void Precache()
		{
			g_SoundSystem.PrecacheSound( RICOSHET_SND );
		}
		
		void Announcer()
		{
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[" + Name + "] 已设置为 " + string(DirectiveActive) + "\n");
		}
		
		void Init()
		{
			
		}
		
		void Check(CBaseEntity@ pVictim, CBaseEntity@ pAttacker, float flDamage, int bitsDamageType)
		{
			CBasePlayer@ pPlayer = cast<CBasePlayer@>(@pVictim);
				
			pPlayer.pev.armorvalue -= RC_ARMORCOST;
			pAttacker.TakeDamage(pPlayer.pev, pPlayer.pev, flDamage, bitsDamageType);
			
			NetworkMessage message( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
			message.WriteString("spk " +  RICOSHET_SND);
			message.End();
			//g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, RICOSHET_SND, 1.0f, 1.0f, 0, 90 + Math.RandomLong( 0, 10 ), target_ent_unreliable:pPlayer.entindex());
		}
		
		void Disable()
		{
			DirectiveActive = false;
		}
	}
}

