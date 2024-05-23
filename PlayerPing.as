CTextMenu@ PingMenu = CTextMenu(PingMenuCallback);
dictionary g_PingTimes;
const uint g_PingDelay = 2000;
const int g_PingMax = 20;
const int g_PingMin = 3;
const int g_PingDefault = 10;

int g_spriteGohere;
int g_spriteTake;
int g_spriteUse;
int g_spriteObjective;
int g_spriteDanger;
int g_spriteDestory;
int g_spriteHeal;
int g_spriteAmmo;
int g_spriteWave;

const uint MARKER_GOHERE    = 1;
const uint MARKER_TAKE      = 2;
const uint MARKER_USE       = 3;
const uint MARKER_OBJECTIVE = 4;
const uint MARKER_DANGER    = 5;
const uint MARKER_DESTORY   = 6;
const uint MARKER_HEAL      = 7;
const uint MARKER_AMMO      = 8;

void PluginInit() 
{
	g_Module.ScriptInfo.SetAuthor("null");
	g_Module.ScriptInfo.SetContactInfo("ahhh");
	
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
	PingMenu.SetTitle("[Ping]\nCommunicate or alert your teammate:\n");
	PingMenu.AddItem("Go Here", null);
	PingMenu.AddItem("Take", null);
	PingMenu.AddItem("Use", null);
	PingMenu.AddItem("Object", null);
	PingMenu.AddItem("Danger", null);
	PingMenu.AddItem("Destory", null);
	PingMenu.AddItem("Request Heal", null);
	PingMenu.AddItem("Request Ammo", null);
	PingMenu.Register();
	
	g_PingTimes.deleteAll();
}

void MapInit() 
{
    g_spriteGohere    = g_Game.PrecacheModel("sprites/misc/gohere.spr");
    g_spriteTake      = g_Game.PrecacheModel("sprites/misc/take.spr");
    g_spriteUse       = g_Game.PrecacheModel("sprites/misc/use.spr");
    g_spriteObjective = g_Game.PrecacheModel("sprites/misc/objective.spr");
    g_spriteDanger    = g_Game.PrecacheModel("sprites/misc/danger.spr");
    g_spriteDestory   = g_Game.PrecacheModel("sprites/misc/destory.spr");
    g_spriteHeal      = g_Game.PrecacheModel("sprites/misc/heal.spr");
    g_spriteAmmo      = g_Game.PrecacheModel("sprites/misc/ammo.spr");
    g_spriteWave      = g_Game.PrecacheModel("sprites/laserbeam.spr");
}

void PingMenuCallback(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem)
{
	if(mItem !is null && pPlayer !is null)
	{
		string markermsg;
		uint markerType;
		int markerlife = g_PingDefault;
		if(mItem.m_szName == "Go Here")
		{
			markerType = MARKER_GOHERE;
			markermsg = '来这里';
		}
		if(mItem.m_szName == "Take")
		{
			markerType = MARKER_TAKE;
			markermsg = '拿上这个';
		}
		if(mItem.m_szName == "Use")
		{
			markerType = MARKER_USE;
			markermsg = '使用按钮/触发物件';
		}
		if(mItem.m_szName == "Object")
		{
			markerType = MARKER_OBJECTIVE;
			markermsg = '目标指示';
		}
		if(mItem.m_szName == "Danger")
		{
			markerType = MARKER_DANGER;
			markermsg = '前方危险, 注意掩护';
		}
		if(mItem.m_szName == "Destory")
		{
			markerType = MARKER_DESTORY;
			markermsg = '摧毁此物';
		}
		if(mItem.m_szName == "Request Heal")
		{
			markerType = MARKER_HEAL;
			markermsg = '需要治疗/救治';
		}
		if(mItem.m_szName == "Request Ammo")
		{
			markerType = MARKER_AMMO;
			markermsg = '需要弹药';
		}
		pingmsg(pPlayer, markerType, markerlife, markermsg);
	}
}


HookReturnCode ClientSay(SayParameters@ pParams)
{
    const CCommand@ pArguments = pParams.GetArguments();

    if(pArguments.ArgC() >= 1 && (pArguments.Arg(0).ToLowercase() == "!p") || (pArguments.Arg(0).ToLowercase() == ".p")) 
	{
		pParams.ShouldHide = true;
        CBasePlayer@ pPlayer = pParams.GetPlayer();
		string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

		uint markerType = MARKER_GOHERE;
		int markerlife = g_PingDefault;
		string markermsg;

		if(!g_PingTimes.exists(steamId))
			g_PingTimes[steamId] = 0;

		uint t = uint(g_EngineFuncs.Time()*1000);
		uint d = t - uint(g_PingTimes[steamId]);

		if(d < g_PingDelay) 
		{
			float w = float(g_PingDelay - d) / 1000.0f;
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, "Wait " + formatFloat(w) + " s\n");

			if ( pArguments.ArgC() == 1 )
				pParams.ShouldHide = true;

			return HOOK_HANDLED;
		}
		else
		{
			if(pPlayer !is null)
			{
				g_PingTimes[steamId] = t;
				if(pArguments.ArgC() == 1)
				{
					PingMenu.Open(0, 0, pPlayer);
					return HOOK_HANDLED;
				}
				if(pArguments.ArgC() >= 2)
				{
					string arg2 = pArguments.Arg(1).ToLowercase();
					if((arg2 == "m") || (arg2 == "menu"))
					{
						PingMenu.Open(0, 0, pPlayer);
					} else if((arg2 == "g") || (arg2 == "go"))
					{
						markerType = MARKER_GOHERE;
						markermsg = '来这里';
					} else if((arg2 == "t") || (arg2 == "take"))
					{
						markerType = MARKER_TAKE;
						markermsg = '拿上这个';
					} else if ((arg2 == "u") || (arg2 == "use")) 
					{
						markerType = MARKER_USE;
						markermsg = '使用按钮/触发物件';
					} else if ((arg2 == "o") || (arg2 == "obj"))
					{
						markerType = MARKER_OBJECTIVE;
						markermsg = '目标指示';
					} else if ((arg2 == "d") || (arg2 == "danger"))
					{
						markerType = MARKER_DANGER;
						markermsg = '前方危险, 注意掩护';
					} else if ((arg2 == "de") || (arg2 == "destory"))
					{
						markerType = MARKER_DESTORY;
						markermsg = '摧毁此物';
					} else if ((arg2 == "h") || (arg2 == "heal"))
					{
						markerType = MARKER_HEAL;
						markermsg = '需要治疗/救治';
					} else if ((arg2 == "a") || (arg2 == "ammo"))
					{
						markerType = MARKER_AMMO;
						markermsg = '需要弹药';
					}
				}
				if(pArguments.ArgC() >= 3)
				{
					markerlife = atoi(pArguments.Arg(2));
					markerlife = Math.clamp(g_PingMin,g_PingMax, markerlife);
				}
				pingmsg(pPlayer, markerType, markerlife, markermsg);
				return HOOK_HANDLED;
			}

        }
        
    }
    return HOOK_CONTINUE;
}


void pingmsg(CBasePlayer@ pPlayer, uint markerType, uint markerlife, string markermsg) 
{
	TraceResult tr;
	Math.MakeVectors( pPlayer.pev.v_angle );
	Vector vecSrc = pPlayer.GetGunPosition();
	Vector vecEnd = vecSrc + g_Engine.v_forward * 4096;
	
	g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );
	/*TraceResult tr;
	float x, y;
	g_Utility.GetCircularGaussianSpread( x, y );
	
	Vector vecSrc = pPlayer.GetGunPosition();
	Vector vecAiming = g_Engine.v_forward;
	Math.MakeVectors(pPlayer.pev.angles);
	g_Utility.TraceLine(vecSrc, vecSrc + vecAiming * 8192, dont_ignore_monsters, pPlayer.edict(), tr);
	*/
	string PlayerName = pPlayer.pev.netname;
	int sprite;
	if(markerType == MARKER_GOHERE)
	{
		sprite = g_spriteGohere;
	}
	if(markerType == MARKER_TAKE)
	{
		sprite = g_spriteTake;
	}
	if(markerType == MARKER_USE)
	{
		sprite = g_spriteUse;
	}
	if(markerType == MARKER_OBJECTIVE)
	{
		sprite = g_spriteObjective;
	}
	if(markerType == MARKER_DANGER)
	{
		sprite = g_spriteDanger;
	}
	if(markerType == MARKER_DESTORY)
	{
		sprite = g_spriteDestory;
	}
	if(markerType == MARKER_HEAL)
	{
		sprite = g_spriteHeal;
	}
    if(markerType == MARKER_AMMO)
	{
		sprite = g_spriteAmmo;
	}

	g_PlayerFuncs.ClientPrintAll(HUD_PRINTNOTIFY, PlayerName + ' 发出了 ' + markermsg + ' 的指令\n' );
	
	NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
        m.WriteByte(TE_GLOWSPRITE);
        m.WriteCoord(tr.vecEndPos.x);
        m.WriteCoord(tr.vecEndPos.y);
        m.WriteCoord(tr.vecEndPos.z + 10);
        m.WriteShort(sprite);
        m.WriteByte(markerlife);
        m.WriteByte(10);
        m.WriteByte(245);
    m.End();

    NetworkMessage m2(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
		m2.WriteByte(TE_BEAMCYLINDER);
		m2.WriteCoord(tr.vecEndPos.x);
		m2.WriteCoord(tr.vecEndPos.y);
		m2.WriteCoord(tr.vecEndPos.z - 30);
		m2.WriteCoord(tr.vecEndPos.x);
		m2.WriteCoord(tr.vecEndPos.y);
		m2.WriteCoord(tr.vecEndPos.z + 30);
		m2.WriteShort(g_spriteWave);
		m2.WriteByte(0);
		m2.WriteByte(16);
		m2.WriteByte(markerlife);
		m2.WriteByte(10);
		m2.WriteByte(0);
		m2.WriteByte(245);
		m2.WriteByte(245);
		m2.WriteByte(245);
		m2.WriteByte(245);
		m2.WriteByte(0);
	m2.End();
	

}