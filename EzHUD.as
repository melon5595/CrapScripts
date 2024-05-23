HUDTextParams h_Parameters;
string szCurrentTime;
string szSteamId;

dictionary g_PlayerHUD;

void PluginInit()
{
  g_Module.ScriptInfo.SetAuthor("aaa");
  g_Module.ScriptInfo.SetContactInfo("eee");
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);

   h_Parameters.x = 0.65; // X
   h_Parameters.y = 0.02; // Y
   h_Parameters.a1 = 0;
   h_Parameters.fadeinTime = 0.0;
   h_Parameters.fadeoutTime = 0.0;
   h_Parameters.holdTime = 2.5;
   h_Parameters.fxTime = 0.0;
   h_Parameters.channel = 8;
   g_Scheduler.SetInterval( "RefreshHUD", 1, g_Scheduler.REPEAT_INFINITE_TIMES );
   
   g_PlayerHUD.deleteAll();
}

void HideHUD(CBasePlayer@ pPlayer){
      g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "HIDDEN!");
}

// Health handler
void RefreshHUD(){
  for (int i = 1; i <= g_Engine.maxClients; i++){
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
    if(pPlayer !is null && pPlayer.IsConnected()){
      h_Parameters.r1 = 140;
      h_Parameters.g1 = 220;
      h_Parameters.b1 = 250;
      h_Parameters.effect = 0;
	  DateTime time;
	  time.Format(szCurrentTime, "%Y.%m.%d - %H:%M:%S" );
	  szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	  
	  if(!g_PlayerHUD.exists(szSteamId))
		g_PlayerHUD[szSteamId] = true;
	  if(bool (g_PlayerHUD[szSteamId]))
	  {
			g_PlayerFuncs.HudMessage( pPlayer, h_Parameters,  "Time: " + szCurrentTime + "\n" +
														"Name: " + pPlayer.pev.netname + "\n" +
														"Score: " + int(pPlayer.pev.frags) + "\n" +
														"Health: " + pPlayer.pev.health + "\n" +
														"SteamID: " + szSteamId + "\n" +
														"https://nullplay.com \n"
														);
		}
    }
  }
}

HookReturnCode ClientSay(SayParameters@ pParams) {
  CBasePlayer@ pPlayer = pParams.GetPlayer();
  const CCommand@ pArguments = pParams.GetArguments();
 
  if (pArguments.ArgC() == 1) {
    if (pArguments.Arg(0) == "!hud") {
      pParams.ShouldHide = true;
      szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	
	  if (bool (g_PlayerHUD[szSteamId])) {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[HUD] Disabled.\n");
		g_PlayerHUD[szSteamId] = false;
		//HideHUD(pPlayer);
      }
      else {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[HUD] Enabled.\n");
		g_PlayerHUD[szSteamId] = true;
		RefreshHUD();
	  }
      return HOOK_HANDLED;
    }
  }
  return HOOK_CONTINUE;
}