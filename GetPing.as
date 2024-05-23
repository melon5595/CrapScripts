CConCommand getping("getping", "getping", @GetPlayerPingLoss);

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("null");
	g_Module.ScriptInfo.SetContactInfo("ahhh");
}

void GetPlayerPingLoss(const CCommand@ pArgs) 
{
	array<string> NetName(g_Engine.maxClients);
	array<int> NetNamePing(g_Engine.maxClients);
	array<int> NetNameLoss(g_Engine.maxClients);
	
	for(int i = 1; i <= g_Engine.maxClients; i++) 
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
		if(pPlayer !is null && pPlayer.IsConnected()) 
		{
			NetName[i - 1] = pPlayer.pev.netname;
			g_EngineFuncs.GetPlayerStats(pPlayer.edict(), NetNamePing[i - 1], NetNameLoss[i - 1]);
		}
	}
	
	for(int i = 1; i <= (int(NetName.length())-1); i++) // Due to the array index is optimized
	{
		string thisName = NetName[i - 1];
		int thisPing = NetNamePing[i - 1];
		int thisLoss = NetNameLoss[i - 1];
		
		if(thisName != "" && thisName != " ")
		{
			g_EngineFuncs.ServerPrint("#" + i + " " + thisName + " | Ping: " + string(thisPing) +  " | Loss: " +  string(thisLoss) + " |\n");
		}
	}
}


