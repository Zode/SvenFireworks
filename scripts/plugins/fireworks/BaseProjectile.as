namespace Fireworks
{
	
mixin class BaseProjectile
{
	void MakeSpawn(float scale, string sprite)
	{
		self.pev.scale = scale;
		self.pev.renderamt = 255;
		self.pev.rendercolor = HSVtoRGB(Math.RandomFloat(0,360), 0.85f, 1.0f);
		self.pev.rendermode = kRenderTransAdd;
		self.pev.nextthink = g_Engine.time + 0.01f;
		g_EntityFuncs.SetModel(self, sprite);
		g_EntityFuncs.SetOrigin(self, self.pev.origin);
		g_EntityFuncs.SetSize(self.pev, Vector(-1, -1, -1), Vector(1, 1, 1));
	}

	void Touch(CBaseEntity@ pOther)
	{
		string otherClass = string(pOther.pev.classname);
		if(otherClass.SubString(0, 3) == "fw_")
		{
			return;
		}
	}

	void MarkForDeath()
	{
		self.pev.velocity = Vector(0,0,0);
		self.pev.movetype = MOVETYPE_NONE;
		self.pev.solid = SOLID_NOT;

		self.pev.renderamt = 0;
		self.pev.nextthink = g_Engine.time + 0.01f;
		SetThink(ThinkFunction(DeleteThink));
	}

	void DeleteThink()
	{
		g_EntityFuncs.Remove(self);
	}

	void PrecacheSound(string sound)
	{
		g_Game.PrecacheGeneric("sound/" + sound);
		g_SoundSystem.PrecacheSound(sound);
	}
	
	void Precache()
	{
		g_Game.PrecacheModel("sprites/flare1.spr");
		g_Game.PrecacheModel("sprites/fireworks/ex1.spr"); // big
		g_Game.PrecacheModel("sprites/fireworks/ex2.spr"); // small
		g_Game.PrecacheModel("sprites/fireworks/ex3.spr"); // twinkle
		g_Game.PrecacheModel("sprites/fireworks/ex4.spr"); // beans
		g_Game.PrecacheModel("sprites/fireworks/ptrail.spr");
		g_Game.PrecacheModel("sprites/zbeam5.spr");

		//roman
		PrecacheSound("fireworks/rexp.ogg");

		//sizzler
		PrecacheSound("fireworks/szexp.ogg");
		PrecacheSound("fireworks/szexp2.ogg");
		PrecacheSound("fireworks/szexp3.ogg");

		//tube
		PrecacheSound("fireworks/sexp2.ogg");
		PrecacheSound("fireworks/sexp3.ogg");

		//whistler
		PrecacheSound("fireworks/w.ogg");
		PrecacheSound("fireworks/w2.ogg");
		PrecacheSound("fireworks/w3.ogg");
		PrecacheSound("fireworks/wexp1.ogg");
		PrecacheSound("fireworks/wexp2.ogg");
	}
	
}

}