#include "fireworks/Includes"

Fireworks fireworks;

void Fireworks_Call()
{
	fireworks.RegisterExpansion(fireworks);
}

class Fireworks : AFBaseClass
{
	void ExpansionInfo()
	{
		this.AuthorName = "Zode (with help from: Gauna, DNIO, The303)";
		this.ExpansionName = "Fireworks";
		this.ShortName = "FW";
	}
	
	void ExpansionInit()
	{
		RegisterCommand("fw_throw", "i", "(type) - Throw a firework (0 to 8)", ACCESS_X, @Fireworks::throw);

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
}

namespace Fireworks
{	
	void throw(AFBaseArguments@ AFArgs)
	{
		int throwtype = AFArgs.GetInt(0);
		CBasePlayer@ player = AFArgs.User;

		if(!Fireworks::g_fw_eventactive)
		{
			fireworks.Tell("Event is not active.", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}

		array<string> choices = 
		{
			"fw_crackers",
			"fw_fountain",
			"fw_roman",
			"fw_tube",
			"fw_cake",
			"fw_sizzler",
			"fw_beans",
			"fw_bottle",
			"fw_rocket"
		};

		array<int> safetyLimits =
		{
			7, //crackers
			1, //fountain
			4, //roman
			7, //tube
			4, //cake
			11, //sizzler
			3, //beans
			1, // bottle
			2 //rocket
		};

		
		if(throwtype < 0)
		{
			throwtype = 0;
		}
		else if(throwtype >= int(choices.length()))
		{
			throwtype = int(choices.length() - 1);
		}

		int safetycode = SafeToMake(safetyLimits[throwtype]);
		if(safetycode == SAFETY_NUMENTS)
		{
			fireworks.Tell("No entity slots left. Please wait and try again.", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}
		else if(safetycode == SAFETY_POTATOLIMIT)
		{
			fireworks.Tell("Server configurable limit hit. Please wait and try again (max: " + g_fw_potato.GetInt() + ").", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}

		CBaseEntity@ ent = g_EntityFuncs.CreateEntity(choices[throwtype]);
		g_EntityFuncs.DispatchSpawn(ent.edict());

		Vector angle = player.pev.v_angle + player.pev.punchangle;
		if(angle.x < 0)
		{
			angle.x = -10.0f + angle.x * ((90.0f - 10.0f) / 90.0f);
		}
		else
		{
			angle.x = -10.0f + angle.x * ((90.0f + 10.0f) / 90.0f);
		}

		float velocity = (90.0f - angle.x) * 3.0f;
		if(velocity > 300.0f)
		{
			velocity = 300.0f;
		}

		Math.MakeVectors(angle);

		ent.pev.angles = Vector(0, player.pev.angles.y + 180, 0);
		ent.pev.origin = SafeThrowPoint(player.pev.origin + player.pev.view_ofs, g_Engine.v_forward * 10.0f + g_Engine.v_up * -24.0f + g_Engine.v_right * 8.0f, player.edict());
		ent.pev.velocity = g_Engine.v_forward * velocity + player.pev.velocity * 0.5f;
		@ent.pev.owner = player.edict();
		
		fireworks.Tell("Made a firework of type: " + string(throwtype) + " - " + choices[throwtype], AFArgs.User, HUD_PRINTCONSOLE);
	}
}