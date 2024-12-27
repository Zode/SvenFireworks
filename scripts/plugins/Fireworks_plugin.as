#include "fireworks/Includes"

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("Zode (with help from: Gauna, DNIO, The303)");
	g_Module.ScriptInfo.SetContactInfo("github");
	Fireworks::Internal_PluginInit();
}

void MapInit()
{
	Fireworks::Internal_MapInit();
}

void MapActivate()
{
	Fireworks::Internal_MapActivate();
}