namespace Fireworks
{

mixin class BaseFirework
{
	float fadeoutTime = 0.0f;

	void OnCreate()
	{
		g_potato_active++;
	}

	void OnDestroy()
	{
		g_potato_active--;
	}

	void MakeSpawn(Vector vmin, Vector vmax)
	{
		self.pev.solid = SOLID_BBOX;
		self.pev.movetype = MOVETYPE_BOUNCE;
		
		g_EntityFuncs.SetModel(self, "models/fireworks/fw.mdl");
		g_EntityFuncs.SetOrigin(self, self.pev.origin);
		g_EntityFuncs.SetSize(self.pev, vmin, vmax);
		
		self.pev.friction = 0.66f;
		self.pev.gravity = 0.75f;
	}
	
	void FrictionTouch(CBaseEntity@ pOther)
	{
		if(@pOther.edict() == @self.pev.owner)
		{
			return;
		}

		if(pOther.IsBSPModel())
		{
			self.pev.flags |= FL_ONGROUND;
		}
			
		if(self.pev.flags & FL_ONGROUND != 0)
		{
			self.pev.velocity = self.pev.velocity * 0.6f;
		}
	}

	void DoFadeOut()
	{
		fadeoutTime = g_Engine.time + 2.0f;
		SetThink(ThinkFunction(this.FadeoutThink));
		self.pev.nextthink = g_Engine.time + 0.1f;
		self.pev.rendermode = kRenderTransAlpha;
		self.pev.renderamt = 255;
	}

	void FadeoutThink()
	{
		self.pev.renderamt = self.pev.renderamt - 13;
		if(self.pev.renderamt < 0)
		{
			self.pev.renderamt = 0;
		}

		self.pev.nextthink = g_Engine.time + 0.1f;
		if(g_Engine.time > fadeoutTime)
		{
			SetThink(ThinkFunction(this.RemovalThink));
		}
	}

	void RemovalThink()
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
		g_Game.PrecacheModel("models/fireworks/fw.mdl");
		PrecacheSound("fireworks/fuse.ogg");
		
		//tube
		PrecacheSound("fireworks/small.ogg");
		PrecacheSound("fireworks/small2.ogg");
		PrecacheSound("fireworks/small3.ogg");
		
		//roman
		PrecacheSound("fireworks/roman.ogg");
		
		//bottle
		PrecacheSound("fireworks/bottle.ogg");
		PrecacheSound("fireworks/bexp.ogg");
		
		//fountain
		g_Game.PrecacheModel("sprites/flare1.spr");
		
		//bottlerocket
		g_Game.PrecacheModel("sprites/fireworks/ptrail.spr");
		
		//sizzlers etc
		PrecacheSound("fireworks/shoot1.ogg");
		PrecacheSound("fireworks/shoot2.ogg");
		PrecacheSound("fireworks/shoot3.ogg");
		
		//rockets+imagerockets
		PrecacheSound("fireworks/lexp.ogg");
		PrecacheSound("fireworks/lexp2.ogg");
		PrecacheSound("fireworks/lexp3.ogg");
		
		//cracker(s)
		PrecacheSound("fireworks/cracker.ogg");
	}
}

}