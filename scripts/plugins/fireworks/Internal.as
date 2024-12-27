namespace Fireworks
{

CCVar@ g_fw_potato;
CCVar@ g_fw_datetime;
int g_potato_active;

bool g_fw_eventactive;

class FauxDateTime
{
	int day;
	int month;
	int yearBias;
	string type;

	FauxDateTime(int day, int month, int yearBias, string type)
	{
		this.day = day;
		this.month = month;
		this.yearBias = yearBias;
		this.type = type;
	}
}

//from-to pairs
const array<FauxDateTime@> g_dateTimeArray =
{
	FauxDateTime(31, 12, 0, "New Year"),			FauxDateTime(1, 1, 1, "New Year"),
	FauxDateTime(31, 12, -1, "New Year"),			FauxDateTime(1, 1, 0, "New Year"),
	FauxDateTime(4, 7, 0, "4th of July"),			FauxDateTime(5, 7, 0, "4th of July"),
	FauxDateTime(5, 11, 0, "Guy Fawkes Night"),		FauxDateTime(6, 11, 0, "Guy Fawkes Night"),
	FauxDateTime(1, 11, 0, "Day of the Dead"),		FauxDateTime(3, 11, 0, "Day of the Dead"),

	FauxDateTime(10, 2, 0, "Birthday"),				FauxDateTime(11, 2, 0, "Birthday"),
	FauxDateTime(29, 4, 0, "Birthday"),				FauxDateTime(30, 4, 0, "Birthday"),
	FauxDateTime(30, 11, 0, "Birthday"),			FauxDateTime(1, 12, 0, "Birthday"),
	FauxDateTime(24, 1, 0, "Birthday"),				FauxDateTime(25, 1, 0, "Birthday"),
	FauxDateTime(13, 11, 0, "Birthday"),			FauxDateTime(14, 11, 0, "Birthday"),
	FauxDateTime(22, 6, 0, "Birthday"),				FauxDateTime(23, 6, 0, "Birthday"),
	FauxDateTime(27, 6, 0, "Birthday"),				FauxDateTime(28, 6, 0, "Birthday"),
	FauxDateTime(20, 10, 0, "Birthday"),			FauxDateTime(21, 10, 0, "Birthday")
};

DateTime _dateTime(int day, int month, int year)
{
	DateTime dateTime = DateTime();
	dateTime.SetDayOfMonth(day);
	dateTime.SetMonth(month);
	dateTime.SetYear(year);
	return dateTime;
}

string g_fw_adstring;
void CheckEventDateTime()
{
	g_fw_adstring = "";
	if(g_fw_datetime.GetInt() == 0)
	{
		g_fw_eventactive = true;
		return;
	}

	DateTime now = DateTime();
	g_fw_eventactive = false;
	for(uint i = 0; i < g_dateTimeArray.length(); i += 2)
	{
		FauxDateTime@ fauxStartTime = g_dateTimeArray[i];
		FauxDateTime@ fauxEndTime = g_dateTimeArray[i + 1];
		DateTime startTime = _dateTime(fauxStartTime.day, fauxStartTime.month, now.GetYear() + fauxStartTime.yearBias);
		DateTime endTime = _dateTime(fauxEndTime.day, fauxEndTime.month, now.GetYear() + fauxEndTime.yearBias);
		TimeDifference startTimeDifference = now - startTime;
		TimeDifference endTimeDifference = now - endTime;

		if(g_fw_datetime.GetInt() == 2 && g_dateTimeArray[i].type == "Birthday")
		{
			continue;
		}

		if((startTimeDifference.IsPositive() && !endTimeDifference.IsPositive()) || 
			(startTimeDifference.IsPositive() && endTimeDifference.IsPositive() && endTimeDifference.GetDays() == 0))
		{
			g_fw_eventactive = true;
			g_fw_adstring = g_dateTimeArray[i].type;
			break;
		}
	}
}

void Internal_PluginInit()
{
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @Buymenu_ClientSay );
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @Buymenu_ClientPutInServer );
	g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @Buymenu_PlayerPostThink );

	@g_fw_potato = CCVar("fw_potato", 0, "Maximum amount of fireworks allowed on server, zero value means unlimited", ConCommandFlag::AdminOnly);
	@g_fw_datetime = CCVar("fw_datetime", 1, "Constrain fireworks to specific dates only, 0:always enabled, 1:all enabled, 2:no birthdays", ConCommandFlag::AdminOnly);
	g_potato_active = 0;
	CheckEventDateTime();

	RegisterBuymenu();
	FireworksPile_RegisterPlugin();
}

void Internal_MapInit()
{
	CheckEventDateTime();
	if(!g_fw_eventactive)
	{
		return;
	}

	QuickRegister("Fireworks::FireworkProjectileSmall", "fw_proj_small");
	QuickRegister("Fireworks::FireworkProjectileRoman", "fw_proj_roman");
	QuickRegister("Fireworks::FireworkProjectileWhistler", "fw_proj_whistler");
	QuickRegister("Fireworks::FireworkProjectileSizzler", "fw_proj_sizzler");
	QuickRegister("Fireworks::FireworkProjectileLarge", "fw_proj_large");
	QuickRegister("Fireworks::FireworkProjectileCracker", "fw_proj_cracker");
	QuickRegister("Fireworks::FireworkProjectileBeans", "fw_proj_beans");

	QuickRegister("Fireworks::FireworkTube", "fw_tube");
	QuickRegister("Fireworks::FireworkRoman", "fw_roman");
	QuickRegister("Fireworks::FireworkFountain", "fw_fountain");
	QuickRegister("Fireworks::FireworkBottle", "fw_bottle");
	QuickRegister("Fireworks::FireworkCake", "fw_cake");
	QuickRegister("Fireworks::FireworkSizzler", "fw_sizzler");
	QuickRegister("Fireworks::FireworkRocket", "fw_rocket");
	QuickRegister("Fireworks::FireworkCrackers", "fw_crackers");
	QuickRegister("Fireworks::FireworkBeans", "fw_beans");

	QuickRegisterWeapon("Fireworks::FireworkWeaponTube", "weapon_fw_tube", "fireworks");
	QuickRegisterWeapon("Fireworks::FireworkWeaponRoman", "weapon_fw_roman", "fireworks");
	QuickRegisterWeapon("Fireworks::FireworkWeaponFountain", "weapon_fw_fountain", "fireworks");
	QuickRegisterWeapon("Fireworks::FireworkWeaponBottle", "weapon_fw_bottle", "fireworks");
	QuickRegisterWeapon("Fireworks::FireworkWeaponCake", "weapon_fw_cake", "fireworks");
	QuickRegisterWeapon("Fireworks::FireworkWeaponSizzler", "weapon_fw_sizzler", "fireworks");
	QuickRegisterWeapon("Fireworks::FireworkWeaponRocket", "weapon_fw_rocket", "fireworks");
	QuickRegisterWeapon("Fireworks::FireworkWeaponCrackers", "weapon_fw_crackers", "fireworks");
	QuickRegisterWeapon("Fireworks::FireworkWeaponBeans", "weapon_fw_beans", "fireworks");

	FireworksPile_RegisterMap();

	g_potato_active = 0;
	Buymenu_MapInit();
}

void Internal_MapActivate()
{
	if(!g_fw_eventactive)
	{
		return;
	}

	FireworksPile_MapActivate();
}

}