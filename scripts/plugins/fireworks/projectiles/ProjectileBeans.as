namespace Fireworks
{

class FireworkProjectileBeans: ScriptBaseEntity, BaseProjectile
{
	float life = 0.0f;

	void Spawn()
	{
		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_FLY;
		
		life = g_Engine.time + 0.6f + Math.RandomFloat(0.0f, 0.6f);
		
		MakeSpawn(0.4f, "sprites/flare1.spr");

		SetThink(ThinkFunction(this.StartThink));
		SetTouch(TouchFunction(Touch));
	}
	
	void StartThink()
	{
		self.pev.nextthink = g_Engine.time + 0.01f;
		SetThink(ThinkFunction(this.Think));
		FXTrailSmoke(g_EntityFuncs.EntIndex(self.edict()), self.pev, "sprites/zbeam5.spr", 5, 5);
	}
	
	void Think()
	{
		self.pev.nextthink = g_Engine.time + 0.1f;
		self.pev.velocity = self.pev.velocity + Vector(0, 0, -100);
		 
		if(g_Engine.time > life)
		{
			switch(Math.RandomLong(0, 1))
			{
				case 0:
					g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/sexp2.ogg", 1.0f, 0.15f, 0, 100 + Math.RandomLong(-5, 10));
					break;
			
				case 1:
					g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/sexp3.ogg", 1.0f, 0.15f, 0, 100 + Math.RandomLong(-5, 10));
					break;
			}

			g_EntityFuncs.SetModel(self, "sprites/fireworks/ex4.spr");
			self.pev.velocity = Vector(0,0,0);
			self.pev.frame = 0;
			self.pev.scale = 1.0f;
			self.pev.renderamt = 255;
			self.pev.origin = self.pev.origin - Vector(0, 0, 12);
			self.pev.nextthink = g_Engine.time + 0.01f;
			SetThink(ThinkFunction(this.AnimThink));
		}
	}

	void AnimThink()
	{	
		self.pev.nextthink = g_Engine.time + 0.04166f; //24, more or less.
		self.pev.frame = self.pev.frame + 1;
		if(self.pev.frame >= 99)
		{
			self.pev.frame = 98;
			MarkForDeath();
		}
	}
}

}