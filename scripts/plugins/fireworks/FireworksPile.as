namespace Fireworks
{

const array<string> g_randomStocklist = 
{
	"weapon_fw_beans",
	"weapon_fw_tube",
	"weapon_fw_roman",
	"weapon_fw_fountain",
	"weapon_fw_bottle",
	"weapon_fw_cake",
	"weapon_fw_sizzler",
	"weapon_fw_rocket",
	"weapon_fw_crackers"
};

CCVar@ g_fw_piles;
CCVar@ g_fw_pileRespawn;
CCVar@ g_fw_pileCount;

void FireworksPile_RegisterPlugin()
{
	@g_fw_piles = CCVar("fw_piles", 1, "If non-zero the plugin will spawn firework piles in random locations", ConCommandFlag::AdminOnly);
	@g_fw_pileRespawn = CCVar("fw_pile_respawn", 10, "Amount of time until a pile respawns, 0 or less disables", ConCommandFlag::AdminOnly);
	@g_fw_pileCount = CCVar("fw_pile_count", 12, "The amount of random firework piles to spawn", ConCommandFlag::AdminOnly);
}

void FireworksPile_RegisterMap()
{
	QuickRegister("Fireworks::FireworksPile", "fw_pile");
}

void FireworksPile_MapActivate()
{
	g_fireworksPile_totalSpawned = 0;
	g_fireworksPile_totalTried = 0;

	g_fireworksPilePotentialLocations.resize(0);
	g_fireworksPileSpawnedLocations.resize(0);

	if(g_fw_piles.GetInt() <= 0)
	{
		return;
	}

	FireworksPile_AddByClassname("info_player_*");
	FireworksPile_AddByClassname("item_*");
	FireworksPile_AddByClassname("weapon_*");
	FireworksPile_AddByClassname("ammo_*");

	//just in case the map doesn't have enough entities: map a grid of positions too.
	for(int x = -4; x <= 4; x++)
	{
		for(int y = -4; y <= 4; y++)
		{
			for(int z = -4; z <= 4; z++)
			{
				g_fireworksPilePotentialLocations.insertLast(Vector(1024 * x, 1024 * y, 1024 * z));
			}
		}
	}

	g_Scheduler.SetTimeout("FireworksPile_Spawn", 0.1f);
}

void FireworksPile_AddByClassname(const string& in classname)
{
	CBaseEntity@ entity = null;
	while((@entity = g_EntityFuncs.FindEntityByClassname(entity, classname)) !is null)
	{
		g_fireworksPilePotentialLocations.insertLast(entity.pev.origin);
	}
}

int g_fireworksPile_totalSpawned = 0;
int g_fireworksPile_totalTried = 0;
array<Vector> g_fireworksPilePotentialLocations = {};
array<Vector> g_fireworksPileSpawnedLocations = {};
void FireworksPile_Spawn()
{
	if(g_fireworksPile_totalSpawned > g_fw_pileCount.GetInt() || g_fireworksPile_totalTried > g_fw_pileCount.GetInt() * 10)
	{
		if(g_fireworksPile_totalSpawned > g_fw_pileCount.GetInt())
		{
			g_Game.AlertMessage(at_logged, "[Fireworks] Spawned " + (g_fireworksPile_totalSpawned - 1) + " gift piles (bailed tries: " + g_fireworksPile_totalTried + " )\n");
		}
		else
		{
			g_Game.AlertMessage(at_logged, "[Fireworks] Failed to spawn all gift piles. (Spawned: " + (g_fireworksPile_totalSpawned - 1) + ", bailed tries: " + g_fireworksPile_totalTried + " )\n");
		}

		g_fireworksPilePotentialLocations.resize(0);
		g_fireworksPileSpawnedLocations.resize(0);
		return;
	}

	bool spawned = false;
	for(int bailout = 0; bailout < 100; bailout++)
	{
		Vector referenceLocation = g_fireworksPilePotentialLocations[Math.RandomLong(0, g_fireworksPilePotentialLocations.length() - 1)];
		Vector potentialLocation = referenceLocation;
		//find a suitable location near the entities
		potentialLocation.z += 64;
		array<Vector> acceptableLocations = {};
		for(int x = -16; x <= 16; x++)
		{
			potentialLocation.x = referenceLocation.x + (16 * x);
			for(int y = -16; y <= -16; y++)
			{
				potentialLocation.y = referenceLocation.y + (16 * y);

				if(g_EngineFuncs.PointContents(potentialLocation) == CONTENTS_EMPTY)
				{
					TraceResult tr;
					g_Utility.TraceHull(potentialLocation, potentialLocation + Vector(0, 0, -8192), ignore_monsters, human_hull, null, tr);
					if(tr.fAllSolid == 0 && tr.fStartSolid == 0 && tr.fInOpen > 0 && tr.fInWater == 0)
					{
						acceptableLocations.insertLast(tr.vecEndPos);
					}
				}
			}
		}

		if(acceptableLocations.length() == 0)
		{
			continue;
		}
		
		Vector selectedLocation = acceptableLocations[Math.RandomLong(0, acceptableLocations.length() - 1)];

		bool tooClose = false;
		for(uint i = 0; i < g_fireworksPileSpawnedLocations.length(); i++)
		{
			Vector delta = selectedLocation - g_fireworksPileSpawnedLocations[i];
			if(delta.Length() < 250.0f)
			{
				tooClose = true;
				break;
			}
		}

		if(tooClose)
		{
			continue;
		}

		CBaseEntity@ pile = g_EntityFuncs.Create("fw_pile", selectedLocation, Vector(0, 0, 0), true);
		if(pile !is null)
		{
			g_fireworksPileSpawnedLocations.insertLast(selectedLocation);
			g_EntityFuncs.DispatchSpawn(pile.edict());
			spawned = true;
			break;
		}
	}

	if(spawned)
	{
		g_fireworksPile_totalSpawned++;
	}
	else
	{
		g_fireworksPile_totalTried++;
	}

	g_Scheduler.SetTimeout("FireworksPile_Spawn", 0.1f);
}

class FireworksPile : ScriptBaseEntity
{
	void Spawn()
	{
		Precache();
		pev.solid = SOLID_TRIGGER;
		self.pev.movetype = MOVETYPE_BOUNCE;
		g_EntityFuncs.SetModel(self, "models/fireworks/fwpile.mdl");
		g_EntityFuncs.SetOrigin(self, pev.origin);
		g_EntityFuncs.SetSize(pev, Vector(-11, -11, 0), Vector(11, 11, 27));
		self.pev.angles.y = Math.RandomFloat(0, 360);
		self.pev.friction = 1.0f;
		self.pev.gravity = 1.0f;
	}

	void PrecacheSound(string sound)
	{
		g_Game.PrecacheGeneric("sound/" + sound);
		g_SoundSystem.PrecacheSound(sound);
	}

	void Precache()
	{
		g_Game.PrecacheModel("models/fireworks/fwpile.mdl");
		g_Game.PrecacheModel("sprites/steam1.spr");
		PrecacheSound("fireworks/poof.ogg");
		PrecacheSound("fireworks/poof2.ogg");
	}

	void Smoke()
	{
		NetworkMessage msg(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
			msg.WriteByte(TE_SMOKE);
			msg.WriteCoord(pev.origin.x);
			msg.WriteCoord(pev.origin.y);
			msg.WriteCoord(pev.origin.z);
			msg.WriteShort(g_EngineFuncs.ModelIndex("sprites/steam1.spr"));
			msg.WriteByte(20);
			msg.WriteByte(15);
		msg.End();
	}

	void Touch(CBaseEntity@ other)
	{
		if(other is null || !other.IsPlayer() || other.pev.health <= 0)
		{
			return;
		}

		CBasePlayer@ player = cast<CBasePlayer@>(other);

		for(int i = 0; i < 3; i++)
		{
			player.GiveNamedItem(g_randomStocklist[Math.RandomLong(0, g_randomStocklist.length() - 1)]);
		}

		Smoke();

		g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/poof.ogg", 1.0f, 0.75f, 0, 100 + Math.RandomLong(-10, 10));

		if(g_fw_pileRespawn.GetInt() < 1)
		{
			g_EntityFuncs.Remove(self);
			return;
		}

		self.pev.solid = SOLID_NOT;
		SetThink(ThinkFunction(this.AppearThink));
		self.pev.nextthink = g_Engine.time + g_fw_pileRespawn.GetInt();
		self.pev.effects |= EF_NODRAW;
	}

	void AppearThink()
	{
		g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/poof2.ogg", 1.0f, 0.75f, 0, 100 + Math.RandomLong(-10, 10));
		Smoke();
		SetThink(ThinkFunction(this.RespawnThink));
		self.pev.nextthink = g_Engine.time + 0.2f;
	}

	void RespawnThink()
	{
		SetThink(null);
		self.pev.solid = SOLID_TRIGGER;
		self.pev.effects &= ~(EF_NODRAW);
	}
}

}