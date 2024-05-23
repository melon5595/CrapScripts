const float m_MaxSize = 1.0;
const float m_MinSize = 0.3;
float m_Value;
dictionary g_SizeList;

const array<string> g_IgnoreMaps = 
{
'zombie_nights_v7',
'ctf_warforts'
};

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("null");
	g_Module.ScriptInfo.SetContactInfo("ahhh");
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
	g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerSpawn);
}

void g_ChangeSize( CBasePlayer@ pPlayer , float Key )
{
	g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), "scale", Key );
}

HookReturnCode ClientSay( SayParameters@ pParams ) 
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();
	const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

	
	if(pPlayer !is null && ( pArguments[0].ToLowercase() == "!size" || pArguments[0].ToLowercase() =="/size" ))
	{
		if (g_IgnoreMaps.find(g_Engine.mapname) >= 0) 
		{
			g_PlayerFuncs.SayText(pPlayer, "[ChangeSize] 该地图不允许设置模型大小\n");
			return HOOK_CONTINUE;
		}
		else
		{
			m_Value = ( atof(pArguments[1]) == 0 ) ? 1.0f : Math.clamp( m_MinSize , m_MaxSize , atof(pArguments[1]) );
			string str_Value = ( m_Value == 1 ) ? "默认值" : m_Value;
			string str_Verb = ( m_Value == 1 ) ? "重置" : "修改";
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[ChangeSize] 你模型缩放比例已" + str_Verb + "为 " + str_Value + "\n");
			g_ChangeSize( pPlayer, m_Value );
			g_SizeList[steamId] = m_Value;
			return HOOK_HANDLED;
		}
	}
	else
	return HOOK_CONTINUE;
}

HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
{
	const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	if(pPlayer !is null && g_SizeList.exists(steamId))
		g_ChangeSize( pPlayer , float(g_SizeList[steamId]) );
	return HOOK_HANDLED;
}