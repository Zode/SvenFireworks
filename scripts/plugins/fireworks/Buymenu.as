namespace Fireworks
{

// Based on Misfires buymenu (Credits: Zode, Aperture, Original by Solokiller)

Buymenu g_buyMenu;

dictionary g_buyPoints;
dictionary g_oldScore;

CCVar@ g_maxMoney;
CCVar@ g_moneyPerScore;
CCVar@ g_startMoney;
CCVar@ g_fw_maxMoney;
CCVar@ g_fw_moneyPerScore;
CCVar@ g_fw_startMoney;

CCVar@ g_fw_menuEnabled;
bool g_fw_menuEnabled_bool;

CCVar@ g_fw_menuFree;

const array<string> g_validShops =
{
	"!fw",				"/fw",				"fw",
	"!fireworks",		"/fireworks",		"fireworks",
	"!firework",		"/firework",		"firework",
	"!fwmenu",			"/fwmenu",			"fwmenu",
	"!fireworksmenu",	"/fireworksmenu",	"fireworksmenu",
	"!fireworkmenu",	"/fireworkmenu",	"fireworkmenu"
};

void RegisterBuymenu()
{
	@g_maxMoney = CCVar("bm_maxmoney", 16000, "Maximum money the player can have", ConCommandFlag::AdminOnly);
	@g_moneyPerScore = CCVar("bm_moneyperscore", 10, "Money the player will earn per score", ConCommandFlag::AdminOnly);
	@g_startMoney = CCVar("bm_startmoney", 0, "Money the player will start with once he joins the server", ConCommandFlag::AdminOnly);

	@g_fw_maxMoney = CCVar("fw_maxmoney", 0, "Maximum money the player can have, if non-zero this takes precedence over bm_maxmoney", ConCommandFlag::AdminOnly);
	@g_fw_moneyPerScore = CCVar("fw_moneyperscore", 0, "Money the player will earn per score, if non-zero this takes precedence over bm_moneyperscore", ConCommandFlag::AdminOnly);
	@g_fw_startMoney = CCVar("fw_startmoney", 0, "Money the player will start with once he joins the server, if non-zero this takes precedence over bm_startmoney", ConCommandFlag::AdminOnly);

	@g_fw_menuEnabled = CCVar("fw_menu", 1, "If non-zero the fireworks buymenu is enabled", ConCommandFlag::AdminOnly);
	@g_fw_menuFree = CCVar("fw_free", 0, "If non-zero the fireworks buymenu is completely free to use", ConCommandFlag::AdminOnly, UpdateMenuFree);
}

void UpdateMenuFree(CCVar@ cvar, const string& in szOldValue, float flOldValue)
{
	g_buyMenu.ClearMenu();
}

string PlayerID(CBasePlayer@ player)
{
	return g_EngineFuncs.GetPlayerAuthId(player.edict());
}

void MoneyInit()
{
	g_buyPoints.deleteAll();
	g_oldScore.deleteAll();
}

void UpdatePlayerPoints(CBasePlayer@ player, int& in oldScore, int& in frags)
{
	if(oldScore == frags)
	{
		return;
	}

	uint points = uint(g_buyPoints[PlayerID(player)]);
	CCVar@ moneyPerScore;
	if(g_fw_moneyPerScore.GetInt() != 0)
	{
		@moneyPerScore = g_fw_moneyPerScore;
	}
	else
	{
		@moneyPerScore = g_moneyPerScore;
	}

	if(g_oldScore.exists(PlayerID(player)) && oldScore > 0 && player.pev.frags == 0)
	{
		//reconnected player
	}
	else if(g_buyPoints.exists(PlayerID(player)) && player.pev.frags != 0)
	{
		g_buyPoints[PlayerID(player)] = points + (uint(frags) - uint(oldScore)) * moneyPerScore.GetInt();
	}

	CCVar@ maxMoney;
	if(g_fw_maxMoney.GetInt() != 0)
	{
		@maxMoney = g_fw_maxMoney;
	}
	else
	{
		@maxMoney = g_maxMoney;
	}

	if(uint(g_buyPoints[PlayerID(player)]) > uint(maxMoney.GetInt()))
	{
		g_buyPoints[PlayerID(player)] = uint(maxMoney.GetInt());
	}

	g_oldScore[PlayerID(player)] = frags;
}

HookReturnCode Buymenu_ClientPutInServer(CBasePlayer@ player)
{
	if(player is null || !g_fw_menuEnabled_bool || !g_fw_eventactive)
	{
		return HOOK_CONTINUE;
	}

	CCVar@ startMoney;
	if(g_fw_startMoney.GetInt() != 0)
	{
		@startMoney = g_fw_startMoney;
	}
	else
	{
		@startMoney = g_startMoney;
	}

	if(!g_buyPoints.exists(PlayerID(player)))
	{
		g_buyPoints[PlayerID(player)] = uint(startMoney.GetInt());
	}

	if(!g_oldScore.exists(PlayerID(player)))
	{
		g_oldScore[PlayerID(player)] = 0;
	}

	return HOOK_CONTINUE;
}

HookReturnCode Buymenu_PlayerPostThink(CBasePlayer@ player)
{
	if(player is null || !g_fw_menuEnabled_bool || !g_fw_eventactive)
	{
		return HOOK_CONTINUE;
	}

	UpdatePlayerPoints(player, int(g_oldScore[PlayerID(player)]), int(player.pev.frags));

	return HOOK_CONTINUE;
}

void Buymenu_MapInit()
{
	g_fw_menuEnabled_bool = g_fw_menuEnabled.GetInt() > 0;
	g_buyMenu.ClearItems();
	MoneyInit();

	CCVar@ moneyPerScore;
	if(g_fw_moneyPerScore.GetInt() != 0)
	{
		@moneyPerScore = g_fw_moneyPerScore;
	}
	else
	{
		@moneyPerScore = g_moneyPerScore;
	}

	int unit = moneyPerScore.GetInt();

	//hackhack: directly defined here instead of loading off of a config file
	g_buyMenu.AddItem(BuyableItem("crackers",	"Firecrackers",		"weapon_fw_crackers",	2 * unit));
	g_buyMenu.AddItem(BuyableItem("fountain",	"Fountain",			"weapon_fw_fountain",	7 * unit));
	g_buyMenu.AddItem(BuyableItem("roman",		"Roman candle",		"weapon_fw_roman",		5 * unit));
	g_buyMenu.AddItem(BuyableItem("tube",		"Mortar tube",		"weapon_fw_tube",		20 * unit));
	g_buyMenu.AddItem(BuyableItem("cake",		"Cake",				"weapon_fw_cake",		25 * unit));
	g_buyMenu.AddItem(BuyableItem("sizzler",	"Sizzler",			"weapon_fw_sizzler",	25 * unit));
	g_buyMenu.AddItem(BuyableItem("beans",		"Beans",			"weapon_fw_beans",		25 * unit));
	g_buyMenu.AddItem(BuyableItem("bottle",		"Bottle rocket",	"weapon_fw_bottle",		10 * unit));
	g_buyMenu.AddItem(BuyableItem("pop",		"Pop rocket",		"weapon_fw_rocket",		17 * unit));
}

HookReturnCode Buymenu_ClientSay(SayParameters@ params)
{
	CBasePlayer@ player = params.GetPlayer();
	const CCommand@ args = params.GetArguments();

	if(args.ArgC() == 0)
	{
		return HOOK_CONTINUE;
	}

	if(g_validShops.find(args.Arg(0).ToLowercase()) == -1)
	{
		return HOOK_CONTINUE;
	}

	params.ShouldHide = true;
	if(!g_fw_eventactive)
	{
		g_PlayerFuncs.ClientPrint(player, HUD_PRINTTALK, "[Fireworks] Now is not the time for fireworks, see console for dates.\n");
	
		g_PlayerFuncs.ClientPrint(player, HUD_PRINTCONSOLE, "[Fireworks] ========================\n");
		g_PlayerFuncs.ClientPrint(player, HUD_PRINTCONSOLE, "[Fireworks] Dates when fireworks are active:\n");
		DateTime now = DateTime();
		for(uint i = 0; i < g_dateTimeArray.length(); i += 2)
		{
			FauxDateTime@ fauxStartTime = g_dateTimeArray[i];
			FauxDateTime@ fauxEndTime = g_dateTimeArray[i + 1];

			if(g_fw_datetime.GetInt() == 2 && g_dateTimeArray[i].type == "Birthday")
			{
				continue;
			}

			g_PlayerFuncs.ClientPrint(player, HUD_PRINTCONSOLE, "[Fireworks] \"" + fauxStartTime.type + "\" is from " + (now.GetYear() + fauxStartTime.yearBias) + "-" + fauxStartTime.month + "-" + fauxStartTime.day +" to " + (now.GetYear() + fauxEndTime.yearBias) + "-" + fauxEndTime.month + "-" + fauxEndTime.day +"\n");
		}

		g_PlayerFuncs.ClientPrint(player, HUD_PRINTCONSOLE, "[Fireworks] ========================\n");
		g_PlayerFuncs.ClientPrint(player, HUD_PRINTCONSOLE, "[Fireworks] Current server date is: " + now.GetYear() + "-" + now.GetMonth() + "-" + now.GetDayOfMonth() + "\n");
		//figure out next event
		int nextActiveIndex = -1;
		int lowestDays = 2147483647; //Does AS have int.maxvalue lol?
		for(uint i = 0; i < g_dateTimeArray.length(); i += 2)
		{
			FauxDateTime@ fauxStartTime = g_dateTimeArray[i];
			FauxDateTime@ fauxEndTime = g_dateTimeArray[i + 1];
			DateTime startTime = _dateTime(fauxStartTime.day, fauxStartTime.month, now.GetYear() + fauxStartTime.yearBias);
			TimeDifference startTimeDifference = now - startTime;

			if(startTimeDifference.IsPositive())
			{
				continue;
			}

			if(g_fw_datetime.GetInt() == 2 && g_dateTimeArray[i].type == "Birthday")
			{
				continue;
			}
		
			if(lowestDays > startTimeDifference.GetDays())
			{
				lowestDays = startTimeDifference.GetDays();
				nextActiveIndex = int(i);
			}
		}

		if(nextActiveIndex > -1)
		{
			FauxDateTime@ fauxStartTime = g_dateTimeArray[nextActiveIndex];
			FauxDateTime@ fauxEndTime = g_dateTimeArray[nextActiveIndex + 1];

			g_PlayerFuncs.ClientPrint(player, HUD_PRINTCONSOLE, "[Fireworks] Next upcoming event: \"" + fauxStartTime.type + "\" is from " + (now.GetYear() + fauxStartTime.yearBias) + "-" + fauxStartTime.month + "-" + fauxStartTime.day +" to " + (now.GetYear() + fauxEndTime.yearBias) + "-" + fauxEndTime.month + "-" + fauxEndTime.day +"\n");
		}

		return HOOK_CONTINUE;
	}
	
	if(!g_fw_menuEnabled_bool)
	{
		g_PlayerFuncs.ClientPrint(player, HUD_PRINTTALK, "[Fireworks] Menu is currently disabled\n");
		return HOOK_CONTINUE;
	}

	if(g_fw_adstring != "")
	{
		g_PlayerFuncs.ClientPrint(player, HUD_PRINTTALK, "[Fireworks] Happy " + g_fw_adstring + "!\n");
	}

	if(args.ArgC() == 1)
	{
		if(g_fw_menuFree.GetInt() == 0)
		{
			g_PlayerFuncs.ClientPrint(player, HUD_PRINTTALK, "[Fireworks] You have: $" + uint(g_buyPoints[PlayerID(player)]) + "\n");
		}
		
		g_buyMenu.Show(player);
		return HOOK_CONTINUE;
	}

	//direct purchase
	if(g_buyMenu.m_items.length() == 0)
	{
		return HOOK_CONTINUE;
	}

	for(int i = 1; i < args.ArgC(); i++)
	{
		bool invalidBuyable = true;
		for(uint j = 0; j < g_buyMenu.m_items.length(); j++)
		{
			BuyableItem@ item = g_buyMenu.m_items[j];
			if(item.chat == args.Arg(i).ToLowercase())
			{
				invalidBuyable = false;
				item.Buy(player);
				break;
			}
		}

		if(args.Arg(i).ToLowercase() == "ammo")
		{
			invalidBuyable = false;
		
			if(player.m_hActiveItem.GetEntity() is null)
			{
				continue;
			}

			CBasePlayerWeapon@ weapon = cast<CBasePlayerWeapon@>(player.m_hActiveItem.GetEntity());
			if(weapon.GetClassname().SubString(0, 9) != "weapon_fw")
			{
				g_PlayerFuncs.ClientPrint(player, HUD_PRINTTALK, "[Fireworks] You aren't holding a firework!\n");
			}
			else
			{
				for(uint j = 0; j < g_buyMenu.m_items.length(); j++)
				{
					BuyableItem@ item = g_buyMenu.m_items[j];
					if(item.entityName == weapon.GetClassname())
					{
						item.Buy(player);
					}
				}
			}
		}

		if(invalidBuyable)
		{
			string builder = "";
			for(uint j = 0; j < g_buyMenu.m_items.length(); j++)
			{
				BuyableItem@ item = g_buyMenu.m_items[j];

				if(j == g_buyMenu.m_items.length() - 1)
				{
					builder += item.chat;
				}
				else
				{
					builder += item.chat + ", ";
				}
			}

			g_PlayerFuncs.ClientPrint(player, HUD_PRINTTALK, "[Fireworks] Unknown item \"" + args.Arg(i).ToLowercase() + "\"\n");
			g_PlayerFuncs.ClientPrint(player, HUD_PRINTTALK, "[Fireworks] Available are: " + builder + ", or ammo\n");
		}
	}

	return HOOK_CONTINUE;
}

final class BuyableItem
{
	private string m_szChat;
	private string m_szDescription;
	private string m_szEntityName;
	private uint m_uiCost = 0;

	string chat
	{
		get const { return m_szChat; }
		set { m_szChat = value; }
	}

	string description
	{
		get const { return m_szDescription; }
		set { m_szDescription = value; }
	}
	
	string entityName
	{
		get const { return m_szEntityName; }
		set { m_szEntityName = value; }
	}
	
	uint cost
	{
		get const { return m_uiCost; }
		set { m_uiCost = value; }
	}

	BuyableItem(const string& in szChat, const string& in szDescription, const string& in szEntityName, const uint uiCost)
	{
		m_szChat = szChat;
		m_szDescription = szDescription;
		m_szEntityName = szEntityName;
		m_uiCost = uiCost;
	}

	void Buy(CBasePlayer@ player)
	{
		if(player is null)
		{
			return;
		}

		GiveItem(player);
	}

	private void GiveItem(CBasePlayer@ player)
	{
		if(uint(g_buyPoints[PlayerID(player)]) < m_uiCost && g_fw_menuFree.GetInt() == 0)
		{
			g_PlayerFuncs.ClientPrint(player, HUD_PRINTTALK, "[Fireworks] Not enough money to buy that! Cost: $" + m_uiCost + ", you have: $" + uint(g_buyPoints[PlayerID(player)]) + "\n");
			return;
		}

		if(player.HasNamedPlayerItem(m_szEntityName) !is null)
		{
			if(player.GiveAmmo(player.HasNamedPlayerItem(m_szEntityName).GetWeaponPtr().m_iDefaultAmmo, m_szEntityName, player.GetMaxAmmo(m_szEntityName), true) != -1)
			{
				player.SetItemPickupTimes(0.0f);
				player.GiveNamedItem(m_szEntityName);

				if(g_fw_menuFree.GetInt() == 0)
				{
					DeductCost(player);
					g_PlayerFuncs.ClientPrint(player, HUD_PRINTTALK, "[Fireworks] Bought " + m_szDescription + ", you now have: $" + uint(g_buyPoints[PlayerID(player)]) + "\n");
				}
				else
				{
					g_PlayerFuncs.ClientPrint(player, HUD_PRINTTALK, "[Fireworks] Got " + m_szDescription + "\n");
				}
			}
			else
			{
				g_PlayerFuncs.ClientPrint(player, HUD_PRINTTALK, "[Fireworks] Can't carry any more of " + m_szDescription + "\n");
			}

			return;
		}

		player.SetItemPickupTimes(0.0f);
		player.GiveNamedItem(m_szEntityName);
		if(g_fw_menuFree.GetInt() == 0)
		{
			DeductCost(player);
			g_PlayerFuncs.ClientPrint(player, HUD_PRINTTALK, "[Fireworks] Bought " + m_szDescription + ", you now have: $" + uint(g_buyPoints[PlayerID(player)]) + "\n");
		}
		else
		{
			g_PlayerFuncs.ClientPrint(player, HUD_PRINTTALK, "[Fireworks] Got " + m_szDescription + "\n");
		}
	}

	private void DeductCost(CBasePlayer@ player)
	{
		if(g_fw_menuFree.GetInt() > 0)
		{
			return;
		}

		uint points = uint(g_buyPoints[PlayerID(player)]);
		g_buyPoints[PlayerID(player)] = points - m_uiCost;
	}
}

final class Buymenu
{
	array<BuyableItem@> m_items;
	private CTextMenu@ m_menu;

	void AddItem(BuyableItem@ item)
	{
		if(item is null)
		{
			return;
		}

		if(m_items.findByRef(@item) != -1)
		{
			return;
		}

		m_items.insertLast(item);

		if(m_menu !is null)
		{
			@m_menu = null;
		}
	}

	void Show(CBasePlayer@ player)
	{
		if(player is null)
		{
			return;
		}

		if(m_menu is null)
		{
			CreateMenu();
		}

		m_menu.Open(0, 0, player);
	}

	void ClearItems()
	{
		if(m_items !is null)
		{
			m_items.resize(0);
		}
	}

	void ClearMenu()
	{
		@m_menu = null;
	}

	private void CreateMenu()
	{
		@m_menu = CTextMenu(TextMenuPlayerSlotCallback(this.MenuCallback));
		m_menu.SetTitle("Fireworks menu\n");

		for(uint i = 0; i < m_items.length(); i++)
		{
			BuyableItem@ item = m_items[i];
			if(g_fw_menuFree.GetInt() > 0)
			{
				m_menu.AddItem(item.description, any(@item));
			}
			else
			{
				m_menu.AddItem(item.description+" $"+item.cost, any(@item));
			}
		}

		m_menu.Register();
	}
	
	private void MenuCallback(CTextMenu@ menu, CBasePlayer@ player, int iSlot, const CTextMenuItem@ menuItem)
	{
		if(menuItem is null || player is null)
		{
			return;
		}

		BuyableItem@ item = null;
		menuItem.m_pUserData.retrieve(@item);
		if(item is null)
		{
			return;
		}

		item.Buy(player);
		Show(player);
	}
}

}