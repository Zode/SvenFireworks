namespace Fireworks
{

class FireworkProjectileSmall : ScriptBaseEntity, BaseProjectile
{
	float life = 0.0f;

	void Spawn()
	{
		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_FLY;
		
		MakeSpawn(0.25f, "sprites/flare1.spr");
		life = g_Engine.time + 1.0f + Math.RandomFloat(0.0f, 0.3f);

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
		self.pev.velocity = self.pev.velocity * 0.8f;
		self.pev.velocity = self.pev.velocity + Vector(Math.RandomFloat(-10, 10), Math.RandomFloat(-10, 10), 0);

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
			
			g_EntityFuncs.SetModel(self, "sprites/fireworks/ex2.spr");
			self.pev.frame = 0;
			self.pev.velocity = Vector(0,0,0);
			self.pev.movetype = MOVETYPE_NONE;
			self.pev.scale = 1.0f;
			self.pev.renderamt = 255;
			self.pev.nextthink = g_Engine.time + 0.01f;
			self.pev.origin = self.pev.origin - Vector(0, 0, 12);
			SetThink(ThinkFunction(this.AnimThink));
		}
	}
	
	void AnimThink()
	{
		self.pev.nextthink = g_Engine.time + 0.04166f; //24, more or less.
		self.pev.frame = self.pev.frame + 1;
		if(self.pev.frame >= 49)
		{
			self.pev.frame = 48;
			MarkForDeath();
		}
		
	}
}

}