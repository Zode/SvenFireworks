namespace Fireworks
{

class FireworkProjectileWhistler : ScriptBaseEntity, BaseProjectile
{
	float life = 0.0;

	void Spawn()
	{
		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_FLY;
		
		MakeSpawn(0.2f, "sprites/flare1.spr");

		SetThink(ThinkFunction(this.StartThink));
		SetTouch(TouchFunction(Touch));
	}
	
	void StartThink()
	{
		self.pev.nextthink = g_Engine.time + 0.01f;
		SetThink(ThinkFunction(this.Think));
		FXTrail(g_EntityFuncs.EntIndex(self.edict()), self.pev, "sprites/fireworks/ptrail.spr", 16, 6);
		
		life = g_Engine.time + 1;
		
		switch(Math.RandomLong(0, 2))
		{
			case 0:
				g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/w.ogg", 0.5f, 0.15f, 0, 100 + Math.RandomLong(-20, 20));
				break;

			case 1:
				g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/w2.ogg", 0.5f, 0.15f, 0, 100 + Math.RandomLong(-20, 20));
				break;

			case 2:
				g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/w3.ogg", 0.5f, 0.15f, 0, 100 + Math.RandomLong(-20, 20));
				break;
		}
	}
	
	void Think()
	{
		self.pev.nextthink = g_Engine.time + 0.05f;
		self.pev.velocity = self.pev.velocity + Vector(Math.RandomLong(-400, 400), Math.RandomLong(-400, 400), Math.RandomLong(-200, 200));
		 
		if(g_Engine.time > life)
		{
			switch(Math.RandomLong(0, 1))
			{
				case 0:
					g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/wexp1.ogg", 1.0f, 0.2f, 0, 100 + Math.RandomLong(-20, 20));
					break;

				case 1:
					g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/wexp2.ogg", 1.0f, 0.2f, 0, 100 + Math.RandomLong(-20, 20));
					break;
			}
			
			FXSparks(self.pev);
			MarkForDeath();
		}
	}
}

}