#include "../../custom_weapons/normal_weapon_effect"
#include "Directives"
#include "List"

// DecreasedStats
const float DecreaseVal = 0.5f;

// IncreasedStats
const float IncreasedVal = 2.0f;

// WeArePilot
const string SLIDE_DID = "$i_didslide";
const string SLIDE_DIDDOUBLE = "$i_diddouble";

const string SLIDE_WALLGLIDE = "$i_wallglide";
const string SLIDE_DOUBLEJUMP = "$i_doublejump";
const string SLIDE_FORBIDDEN = "$i_forbidden";
const string SLIDE_JUMPTIME = "$f_jumptime";

const string SLIDE_SPR = "sprites/fun/laserbeam.spr";
const string SLIDE_SLIDESND = "misc/slide.mp3";
const string SLIDE_BOOSTSND = "tfc/weapons/airgun_1.wav";
const int SLIDE_IFORWARD = 60;
const int SLIDE_ISIDE = 35;

// Ragers
const float RagerRadius = 384.0f;
const int RagerHealVal = 150;

// MoveOrDie
const int MODMinus = 3;

// Bleeding
const int BleedStatic = 1;
const int BleedMoving = 2;
const int SpeedBelowQuarter = 220;
const int SpeedBelowHalf = 170;
const int SpeedBelowCritical = 120;

// AmmoHoarders
const float AHCutdown = 0.5;

// Darken
const string DarkLight = "g";
// BulletKing
const float BKAmmoRegen = 0.2f;

// GroupHeal
const float GroupHealRadius = 256.0f;
const int GroupHealVal = 25;

// ExplosiveRounds
const float ERChance = 0.1f;
const int ERBaseDMG = 32;
const int ERBaseRadius = 48;

// CyberArmor
const float CRTransfer = 0.5f;
const int CRHealUsed = 10;

// Bloodlust
const int BLHeal = 25;

// SpeedyTackle
const float SpeedyMaxSpeed = 400;

// RicochetArmor
const int RC_ARMORCOST = 20;
const string RICOSHET_SND = "tfc/weapons/concgren_blast3.wav";

//Global 
const string g_CustomThisClip = "$i_thisclip";

CTextMenu@ DirectiveMenu = CTextMenu(DirectiveMenuCallback);

int iReturnVal = directives.length() - 1;

const array<string> directives = 
{
	"DecreasedStats",
	"IncreasedStats",
	"WeArePilot",
	"Ragers",
	"MoveOrDie",
	"Bleeding",
	"AmmoHoarders",
	"Darken",
	"BulletKing",
	"GroupHeal",
	"ExplosiveRounds",
	"CyberArmor",
	"Bloodlust",
	"StableShoot",
	"SpeedyTackle",
	"GrenadeManiac",
	"RicochetArmor"
};

string ReturnStrValue(int Num)
{
	string szReturnVal = directives[Num];
	return szReturnVal;
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("null");
	g_Module.ScriptInfo.SetContactInfo("nada");
	g_Module.ScriptInfo.SetMinimumAdminLevel( ADMIN_YES );
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
	g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerSpawn);
	g_Hooks.RegisterHook(Hooks::Player::PlayerPreThink, @PlayerPreThink);
	g_Hooks.RegisterHook(Hooks::Player::PlayerTakeDamage, @PlayerTakeDamage);
	//g_Hooks.RegisterHook(Hooks::Player::PlayerPostTakeDamage, @PlayerPostTakeDamage);
	g_Hooks.RegisterHook(Hooks::Monster::MonsterTakeDamage, @MonsterTakeDamage);
	g_Hooks.RegisterHook(Hooks::Monster::MonsterKilled, @MonsterKilled);

	g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);
	
	g_Hooks.RegisterHook(Hooks::Weapon::WeaponPrimaryAttack, @WeaponPrimaryAttack);
	//g_Hooks.RegisterHook(Hooks::Weapon::WeaponSecondaryAttack, @WeaponSecondaryAttack);
	
	DirectiveMenu.SetTitle("[Directive]\nConfigure directive status:\n");
	DirectiveMenu.Register();
	for(int i = 0; i <= iReturnVal; i++)
	{
		DirectiveMenu.AddItem(ReturnStrValue(i), null);
	}
}

void DirectiveMenuCallback(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem)
{
	if(mItem !is null && pPlayer !is null)
	{
		if(mItem.m_szName == "DecreasedStats")
		{
			if(Directive::DecreasedStats::DirectiveActive == true) 
			{
				Directive::DecreasedStats::Disable();
			}
			else 
			{
				Directive::DecreasedStats::DirectiveActive = true;
				Directive::DecreasedStats::Init();
			}
			Directive::DecreasedStats::Announcer();
		}
		
		if(mItem.m_szName == "IncreasedStats")
		{
			if(Directive::IncreasedStats::DirectiveActive == true) 
			{
				Directive::IncreasedStats::Disable();
			}
			else 
			{
				Directive::IncreasedStats::DirectiveActive = true;
				Directive::IncreasedStats::Init();
			}
			Directive::IncreasedStats::Announcer();
		}
		
		if(mItem.m_szName == "WeArePilot")
		{
			if(Directive::WeArePilot::DirectiveActive == true) 
			{
				Directive::WeArePilot::Disable();
			}
			else 
			{
				Directive::WeArePilot::DirectiveActive = true;
				Directive::WeArePilot::Init();
			}
			Directive::WeArePilot::Announcer();
		}
		
		if(mItem.m_szName == "Ragers")
		{
			if(Directive::Ragers::DirectiveActive == true) 
			{
				Directive::Ragers::Disable();
			}
			else 
			{
				Directive::Ragers::DirectiveActive = true;
				Directive::Ragers::Init();
			}
			Directive::Ragers::Announcer();
		}
		if(mItem.m_szName == "MoveOrDie")
		{
			if(Directive::MoveOrDie::DirectiveActive == true) 
			{
				Directive::MoveOrDie::Disable();
			}
			else 
			{
				Directive::MoveOrDie::DirectiveActive = true;
				Directive::MoveOrDie::Init();
			}
			Directive::MoveOrDie::Announcer();
		}
		if(mItem.m_szName == "Bleeding")
		{
			if(Directive::Bleeding::DirectiveActive == true) 
			{
				Directive::Bleeding::Disable();
			}
			else 
			{
				Directive::Bleeding::DirectiveActive = true;
				Directive::Bleeding::Init();
			}
			Directive::Bleeding::Announcer();
		}
		if(mItem.m_szName == "AmmoHoarders")
		{
			if(Directive::AmmoHoarders::DirectiveActive == true) 
			{
				Directive::AmmoHoarders::Disable();
			}
			else 
			{
				Directive::AmmoHoarders::DirectiveActive = true;
				Directive::AmmoHoarders::Init();
			}
			Directive::AmmoHoarders::Announcer();
		}
		if(mItem.m_szName == "Darken")
		{
			if(Directive::Darken::DirectiveActive == true) 
			{
				Directive::Darken::Disable();
			}
			else 
			{
				Directive::Darken::DirectiveActive = true;
				Directive::Darken::Init();
			}
			Directive::Darken::Announcer();
		}
		if(mItem.m_szName == "BulletKing")
		{
			if(Directive::BulletKing::DirectiveActive == true) 
			{
				Directive::BulletKing::Disable();
			}
			else 
			{
				Directive::BulletKing::DirectiveActive = true;
				Directive::BulletKing::Init();
			}
			Directive::BulletKing::Announcer();
		}
		if(mItem.m_szName == "GroupHeal")
		{
			if(Directive::GroupHeal::DirectiveActive == true) 
			{
				Directive::GroupHeal::Disable();
			}
			else 
			{
				Directive::GroupHeal::DirectiveActive = true;
				Directive::GroupHeal::Init();
			}
			Directive::GroupHeal::Announcer();
		}
		if(mItem.m_szName == "ExplosiveRounds")
		{
			if(Directive::ExplosiveRounds::DirectiveActive == true) 
			{
				Directive::ExplosiveRounds::Disable();
			}
			else 
			{
				Directive::ExplosiveRounds::DirectiveActive = true;
				Directive::ExplosiveRounds::Init();
			}
			Directive::ExplosiveRounds::Announcer();
		}
		if(mItem.m_szName == "CyberArmor")
		{
			if(Directive::CyberArmor::DirectiveActive == true) 
			{
				Directive::CyberArmor::Disable();
			}
			else 
			{
				Directive::CyberArmor::DirectiveActive = true;
				Directive::CyberArmor::Init();
			}
			Directive::CyberArmor::Announcer();
		}
		if(mItem.m_szName == "Bloodlust")
		{
			if(Directive::Bloodlust::DirectiveActive == true) 
			{
				Directive::Bloodlust::Disable();
			}
			else 
			{
				Directive::Bloodlust::DirectiveActive = true;
				Directive::Bloodlust::Init();
			}
			Directive::Bloodlust::Announcer();
		}
		if(mItem.m_szName == "StableShoot")
		{
			if(Directive::StableShoot::DirectiveActive == true) 
			{
				Directive::StableShoot::Disable();
			}
			else 
			{
				Directive::StableShoot::DirectiveActive = true;
				Directive::StableShoot::Init();
			}
			Directive::StableShoot::Announcer();
		}
		if(mItem.m_szName == "SpeedyTackle")
		{
			if(Directive::SpeedyTackle::DirectiveActive == true) 
			{
				Directive::SpeedyTackle::Disable();
			}
			else 
			{
				Directive::SpeedyTackle::DirectiveActive = true;
				Directive::SpeedyTackle::Init();
			}
			Directive::SpeedyTackle::Announcer();
		}
		if(mItem.m_szName == "GrenadeManiac")
		{
			if(Directive::GrenadeManiac::DirectiveActive == true) 
			{
				Directive::GrenadeManiac::Disable();
			}
			else 
			{
				Directive::GrenadeManiac::DirectiveActive = true;
				Directive::GrenadeManiac::Init();
			}
			Directive::GrenadeManiac::Announcer();
		}
		if(mItem.m_szName == "RicochetArmor")
		{
			if(Directive::RicochetArmor::DirectiveActive == true) 
			{
				Directive::RicochetArmor::Disable();
			}
			else 
			{
				Directive::RicochetArmor::DirectiveActive = true;
				Directive::RicochetArmor::Init();
			}
			Directive::RicochetArmor::Announcer();
		}
		DirectiveMenu.Open(0, 0, pPlayer);
    }
}

void MapInit()
{
	Precache();
}

void Precache()
{
	Directive::DecreasedStats::Precache();
	Directive::IncreasedStats::Precache();
	Directive::WeArePilot::Precache();
	Directive::Ragers::Precache();
	Directive::MoveOrDie::Precache();
	Directive::Bleeding::Precache();
	Directive::AmmoHoarders::Precache();
	Directive::Darken::Precache();
	Directive::BulletKing::Precache();
	Directive::GroupHeal::Precache();
	Directive::ExplosiveRounds::Precache();
	Directive::CyberArmor::Precache();
	Directive::Bloodlust::Precache();
	Directive::StableShoot::Precache();
	Directive::SpeedyTackle::Precache();
	Directive::GrenadeManiac::Precache();
	Directive::RicochetArmor::Precache();
}

void MapStart()
{
	if(ignoremaplist.find(g_Engine.mapname) >= 0)
		return;
	
	g_Scheduler.SetTimeout( "DirectiveInit", 1, 20 );
}

void DirectiveInit(int iCount)
{
	g_PlayerFuncs.ClientPrintAll( HUD_PRINTCENTER, "Random directive will be applied in " + iCount + " s\n");
	if(iCount <= 0)
	{
		ApplyDirective();
	}
	else
	{
		g_Scheduler.SetTimeout( "DirectiveInit", 1, iCount - 1 );
	}
}

void ApplyDirective()
{
	string DirectiveName;
	string DirectiveDesc;
	//Return str from random Number
	// Math.RandomLong(0, iReturnVal)
	string ChosenDirective = ReturnStrValue(Math.RandomLong(0, iReturnVal));
	
	if(ChosenDirective == "DecreasedStats")
	{
		DirectiveName = Directive::DecreasedStats::Name;
		DirectiveDesc = Directive::DecreasedStats::Desc;
		Directive::DecreasedStats::DirectiveActive = true;
		
		Directive::DecreasedStats::Init();
	}
	if(ChosenDirective == "IncreasedStats")
	{
		DirectiveName = Directive::IncreasedStats::Name;
		DirectiveDesc = Directive::IncreasedStats::Desc;
		Directive::IncreasedStats::DirectiveActive = true;
		
		Directive::IncreasedStats::Init();
	}
	if(ChosenDirective == "WeArePilot")
	{
		DirectiveName = Directive::WeArePilot::Name;
		DirectiveDesc = Directive::WeArePilot::Desc;
		Directive::WeArePilot::DirectiveActive = true;
		
		Directive::WeArePilot::Init();
	}
	if(ChosenDirective == "Ragers")
	{
		DirectiveName = Directive::Ragers::Name;
		DirectiveDesc = Directive::Ragers::Desc;
		Directive::Ragers::DirectiveActive = true;
		
		Directive::Ragers::Init();
	}
	if(ChosenDirective == "MoveOrDie")
	{
		DirectiveName = Directive::MoveOrDie::Name;
		DirectiveDesc = Directive::MoveOrDie::Desc;
		Directive::MoveOrDie::DirectiveActive = true;
		
		Directive::MoveOrDie::Init();
	}
	if(ChosenDirective == "Bleeding")
	{
		DirectiveName = Directive::Bleeding::Name;
		DirectiveDesc = Directive::Bleeding::Desc;
		Directive::Bleeding::DirectiveActive = true;
		
		Directive::Bleeding::Init();
	}
	if(ChosenDirective == "AmmoHoarders")
	{
		DirectiveName = Directive::AmmoHoarders::Name;
		DirectiveDesc = Directive::AmmoHoarders::Desc;
		Directive::AmmoHoarders::DirectiveActive = true;
		
		Directive::AmmoHoarders::Init();
	}
	if(ChosenDirective == "Darken")
	{
		DirectiveName = Directive::Darken::Name;
		DirectiveDesc = Directive::Darken::Desc;
		Directive::Darken::DirectiveActive = true;
		
		Directive::Darken::Init();
	}
	if(ChosenDirective == "BulletKing")
	{
		DirectiveName = Directive::BulletKing::Name;
		DirectiveDesc = Directive::BulletKing::Desc;
		Directive::BulletKing::DirectiveActive = true;
		
		Directive::BulletKing::Init();
	}
	if(ChosenDirective == "GroupHeal")
	{
		DirectiveName = Directive::GroupHeal::Name;
		DirectiveDesc = Directive::GroupHeal::Desc;
		Directive::GroupHeal::DirectiveActive = true;
		
		Directive::GroupHeal::Init();
	}
	if(ChosenDirective == "ExplosiveRounds")
	{
		DirectiveName = Directive::ExplosiveRounds::Name;
		DirectiveDesc = Directive::ExplosiveRounds::Desc;
		Directive::ExplosiveRounds::DirectiveActive = true;
		
		Directive::ExplosiveRounds::Init();
	}
	if(ChosenDirective == "CyberArmor")
	{
		DirectiveName = Directive::CyberArmor::Name;
		DirectiveDesc = Directive::CyberArmor::Desc;
		Directive::CyberArmor::DirectiveActive = true;
		
		Directive::CyberArmor::Init();
	}
	if(ChosenDirective == "Bloodlust")
	{
		DirectiveName = Directive::Bloodlust::Name;
		DirectiveDesc = Directive::Bloodlust::Desc;
		Directive::Bloodlust::DirectiveActive = true;
		
		Directive::Bloodlust::Init();
	}
	if(ChosenDirective == "StableShoot")
	{
		DirectiveName = Directive::StableShoot::Name;
		DirectiveDesc = Directive::StableShoot::Desc;
		Directive::StableShoot::DirectiveActive = true;
		
		Directive::StableShoot::Init();
	}
	if(ChosenDirective == "SpeedyTackle")
	{
		DirectiveName = Directive::SpeedyTackle::Name;
		DirectiveDesc = Directive::SpeedyTackle::Desc;
		Directive::SpeedyTackle::DirectiveActive = true;
		
		Directive::SpeedyTackle::Init();
	}
	if(ChosenDirective == "GrenadeManiac")
	{
		DirectiveName = Directive::GrenadeManiac::Name;
		DirectiveDesc = Directive::GrenadeManiac::Desc;
		Directive::GrenadeManiac::DirectiveActive = true;
		
		Directive::GrenadeManiac::Init();
	}
	if(ChosenDirective == "RicochetArmor")
	{
		DirectiveName = Directive::RicochetArmor::Name;
		DirectiveDesc = Directive::RicochetArmor::Desc;
		Directive::RicochetArmor::DirectiveActive = true;
		
		Directive::RicochetArmor::Init();
	}
	RDPrint(DirectiveName, DirectiveDesc);	
}

void RDPrint(string&in DirectiveName, string&in DirectiveDesc)
{
	for(int i = 1; i <= g_Engine.maxClients; i++)
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
		if( pPlayer !is null && pPlayer.IsConnected())
		{
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK ,"[" + DirectiveName + "] 将作为本局随机政令启用 - " + DirectiveDesc + "\n");
		}
	}
}

void RDRespawnPrint(CBasePlayer@ pPlayer, string&in DirectiveName, string&in DirectiveDesc)
{
	if(pPlayer !is null && pPlayer.IsConnected())
	{
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK ,"已启用: " + "[" + DirectiveName + "] - " + DirectiveDesc + "\n");
	}
}

HookReturnCode ClientSay(SayParameters@ pParams) 
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
	const CCommand@ pArguments = pParams.GetArguments();
	if(pArguments.ArgC() == 1 ) 
	{
		if(pArguments.Arg(0).ToLowercase() == "!directive") 
		{
			pParams.ShouldHide = true;
			if(g_PlayerFuncs.AdminLevel(pPlayer) < ADMIN_YES)
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Directive] You have no permission.\n");
				return HOOK_HANDLED;
			}
			else
			{
				DirectiveMenu.Open(0, 0, pPlayer);
				return HOOK_HANDLED;
			}
		}
	}
	return HOOK_CONTINUE;
}

HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
{
	if(pPlayer is null || !pPlayer.IsConnected()) 
		return HOOK_HANDLED;

	
	if(Directive::DecreasedStats::DirectiveActive)
	{
		Directive::DecreasedStats::Modifier(pPlayer);
		RDRespawnPrint(pPlayer, Directive::DecreasedStats::Name, Directive::DecreasedStats::Desc);
	}
	
	if(Directive::IncreasedStats::DirectiveActive)
	{
		Directive::IncreasedStats::Modifier(pPlayer);
		RDRespawnPrint(pPlayer, Directive::IncreasedStats::Name, Directive::IncreasedStats::Desc);
	}
	
	if(Directive::WeArePilot::DirectiveActive)
	{
		Directive::WeArePilot::Clean(pPlayer);
		RDRespawnPrint(pPlayer, Directive::WeArePilot::Name, Directive::WeArePilot::Desc);
	}
	
	if(Directive::Ragers::DirectiveActive)
	{
		RDRespawnPrint(pPlayer, Directive::Ragers::Name, Directive::Ragers::Desc);
	}
	
	if(Directive::MoveOrDie::DirectiveActive)
	{
		RDRespawnPrint(pPlayer, Directive::MoveOrDie::Name, Directive::MoveOrDie::Desc);
	}
	
	if(Directive::Bleeding::DirectiveActive)
	{
		RDRespawnPrint(pPlayer, Directive::Bleeding::Name, Directive::Bleeding::Desc);
	}
	
	if(Directive::AmmoHoarders::DirectiveActive)
	{
		Directive::AmmoHoarders::RespawnCut(pPlayer);
		RDRespawnPrint(pPlayer, Directive::AmmoHoarders::Name, Directive::AmmoHoarders::Desc);
	}
	
	if(Directive::Darken::DirectiveActive)
	{
		RDRespawnPrint(pPlayer, Directive::Darken::Name, Directive::Darken::Desc);
	}
	
	if(Directive::BulletKing::DirectiveActive)
	{
		RDRespawnPrint(pPlayer, Directive::BulletKing::Name, Directive::BulletKing::Desc);
	}
	
	if(Directive::GroupHeal::DirectiveActive)
	{
		RDRespawnPrint(pPlayer, Directive::GroupHeal::Name, Directive::GroupHeal::Desc);
	}
	
	if(Directive::ExplosiveRounds::DirectiveActive)
	{
		RDRespawnPrint(pPlayer, Directive::ExplosiveRounds::Name, Directive::ExplosiveRounds::Desc);
	}
	
	if(Directive::CyberArmor::DirectiveActive)
	{
		RDRespawnPrint(pPlayer, Directive::CyberArmor::Name, Directive::CyberArmor::Desc);
	}
	
	if(Directive::Bloodlust::DirectiveActive)
	{
		RDRespawnPrint(pPlayer, Directive::Bloodlust::Name, Directive::Bloodlust::Desc);
	}
	
	if(Directive::StableShoot::DirectiveActive)
	{
		RDRespawnPrint(pPlayer, Directive::StableShoot::Name, Directive::StableShoot::Desc);
	}
	
	if(Directive::SpeedyTackle::DirectiveActive)
	{
		RDRespawnPrint(pPlayer, Directive::SpeedyTackle::Name, Directive::SpeedyTackle::Desc);
	}
	
	if(Directive::GrenadeManiac::DirectiveActive)
	{
		RDRespawnPrint(pPlayer, Directive::GrenadeManiac::Name, Directive::GrenadeManiac::Desc);
	}
	
	if(Directive::RicochetArmor::DirectiveActive)
	{
		RDRespawnPrint(pPlayer, Directive::RicochetArmor::Name, Directive::RicochetArmor::Desc);
	}
	/*
	g_Scheduler.SetTimeout("ProtectionEnable", 0.01, @pPlayer);
	g_Scheduler.SetTimeout("ProtectionDisable", 3.01, @pPlayer); // in case of scheduler get fatal error?
	*/
	return HOOK_HANDLED;
}

HookReturnCode MapChange()
{
	g_Scheduler.ClearTimerList();
	
	Directive::DecreasedStats::Disable();
	Directive::IncreasedStats::Disable();
	Directive::WeArePilot::Disable();
	Directive::Ragers::Disable();
	Directive::MoveOrDie::Disable();
	Directive::Bleeding::Disable();
	Directive::AmmoHoarders::Disable();
	Directive::Darken::Disable();
	Directive::BulletKing::Disable();
	Directive::GroupHeal::Disable();
	Directive::ExplosiveRounds::Disable();
	Directive::CyberArmor::Disable();
	Directive::Bloodlust::Disable();
	Directive::StableShoot::Disable();
	Directive::SpeedyTackle::Disable();
	Directive::GrenadeManiac::Disable();
	Directive::RicochetArmor::Disable();
    return HOOK_HANDLED;
}

HookReturnCode PlayerPreThink( CBasePlayer@ pPlayer, uint& out uiFlags )
{
	if(pPlayer is null || !pPlayer.IsAlive())
		return HOOK_CONTINUE;

	if(Directive::WeArePilot::DirectiveActive)
	{
		Directive::WeArePilot::ResetCheck(pPlayer);
		Directive::WeArePilot::MotionCheck(pPlayer);
	}
	if(Directive::AmmoHoarders::DirectiveActive)
	{
		if(pPlayer.pev.button & IN_RELOAD != 0)
		{
			Directive::AmmoHoarders::ReloadDrop(pPlayer);
		}
	}
	if(Directive::CyberArmor::DirectiveActive)
	{
		if(g_EngineFuncs.CVarGetString("mp_suitpower") != 0)
		{
			Directive::CyberArmor::ArmorChecker(pPlayer);
		}
	}
	return HOOK_CONTINUE;
}

HookReturnCode WeaponPrimaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
{
	CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
	@pWeapon = cast<CBasePlayerWeapon@>(pPlayer.m_hActiveItem.GetEntity());
		
	if(pWeapon is null || pWeapon.PrimaryAmmoIndex() == -1 || pWeapon.iMaxAmmo1() == -1 || pWeapon.m_iClip <= 0)
		return HOOK_CONTINUE;
		
	if(pWeapon.m_iClip == pCustom.GetKeyvalue(g_CustomThisClip).GetInteger())
	{
		if(shortdistanceweaponlist.find(pWeapon.GetClassname()) >= 0)
		{
			g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), g_CustomThisClip, -1);
		}
		return HOOK_CONTINUE;
	}
	
	g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), g_CustomThisClip, pWeapon.m_iClip);

		
	if(Directive::BulletKing::DirectiveActive)
	{
		Directive::BulletKing::BulletCheck(pPlayer);
	}
	if(Directive::ExplosiveRounds::DirectiveActive)
	{
		Directive::ExplosiveRounds::HitCheck(pPlayer);
	}
	if(Directive::StableShoot::DirectiveActive)
	{
		Directive::StableShoot::StableCheck(pPlayer);
	}
	return HOOK_CONTINUE;
}
/*
HookReturnCode WeaponSecondaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
{
	@pWeapon = cast<CBasePlayerWeapon@>(pPlayer.m_hActiveItem.GetEntity());
	
	if(pWeapon.m_iClip <= 0)
		return HOOK_HANDLED;
		
	if(Directive::BulletKing::DirectiveActive)
	{
		Directive::BulletKing::BulletCheck(pPlayer);
	}
	if(Directive::StableShoot::DirectiveActive)
	{
		Directive::StableShoot::StableCheck(pPlayer);
	}
	return HOOK_CONTINUE;
}
*/


HookReturnCode PlayerTakeDamage(DamageInfo@ Info)
{
	if(Info.pVictim is null || Info.pAttacker is null)
		return HOOK_CONTINUE;
	
	CBaseEntity@ pVictim = cast<CBaseEntity@>(g_EntityFuncs.Instance(Info.pVictim.pev));
	CBaseEntity@ pAttacker = cast<CBaseEntity@>(g_EntityFuncs.Instance(Info.pAttacker.pev));
	
	if(pVictim is null || pAttacker is null)
		return HOOK_CONTINUE;
	
	if(Directive::GrenadeManiac::DirectiveActive)
	{
		if(Info.bitsDamageType == DMG_BLAST)
		{
			Directive::GrenadeManiac::Check(pVictim, Info.flDamage);
			Info.flDamage = 0;
		}
	}
	if(Directive::RicochetArmor::DirectiveActive)
	{
		CBasePlayer@ pPlayer = cast<CBasePlayer@>(g_EntityFuncs.Instance(pVictim.pev));
		if(Directive::RicochetArmor::IsCapableRicochet(pPlayer))
		{
			Directive::RicochetArmor::Check(pVictim, pAttacker, Info.flDamage, Info.bitsDamageType);
			Info.flDamage = 0;
		}
	}
	return HOOK_CONTINUE;
}
/*
HookReturnCode PlayerPostTakeDamage(DamageInfo@ Info)
{
	CBaseEntity@ pVictim = cast<CBaseEntity@>(g_EntityFuncs.Instance(Info.pVictim.pev));
	CBaseEntity@ pAttacker = cast<CBaseEntity@>(g_EntityFuncs.Instance(Info.pAttacker.pev));
	
	if(pVictim is null || !pVictim.IsAlive() || !pVictim.IsPlayer())
		return HOOK_CONTINUE;
		

	return HOOK_CONTINUE;
}
*/

HookReturnCode MonsterTakeDamage(DamageInfo@ info)
{
	if(info.pVictim is null || info.pAttacker is null)
		return HOOK_CONTINUE;

	CBaseEntity@ pVictim = cast<CBaseEntity@>(g_EntityFuncs.Instance(info.pVictim.pev));
	CBaseEntity@ pAttacker = cast<CBaseEntity@>(g_EntityFuncs.Instance(info.pAttacker.pev));
	
	if(pVictim is null || pVictim.IsPlayer() || pAttacker is null || !pAttacker.IsPlayer())
		return HOOK_CONTINUE;
	
	CBasePlayer@ pPlayer = cast<CBasePlayer@>(@pAttacker);
	
	if(Directive::Bloodlust::DirectiveActive)
	{
		Directive::Bloodlust::Check(pPlayer, pAttacker, info.flDamage);
	}
	return HOOK_CONTINUE;
}

HookReturnCode MonsterKilled(CBaseMonster@ pMonster, entvars_t@ pevAttacker, int iGib)
{
	CBasePlayer@ pAttacker = cast<CBasePlayer@>(g_EntityFuncs.Instance(pevAttacker));

	if(pMonster is null || pAttacker is null || !pAttacker.IsPlayer())
		return HOOK_CONTINUE;
	
	if(Directive::Ragers::DirectiveActive)
	{
		Directive::Ragers::Check(pMonster);
	}

	return HOOK_CONTINUE;
}

