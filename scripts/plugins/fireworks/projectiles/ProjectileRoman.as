namespace Fireworks
{

class FireworkProjectileRoman : ScriptBaseEntity, BaseProjectile
{
	float life = 0.0f;

	void Spawn()
	{
		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_FLY;
		
		life = g_Engine.time + 1.0f + Math.RandomFloat(0.0f, 0.6f);
		
		MakeSpawn(0.3f, "sprites/flare1.spr");

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
			g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/rexp.ogg", 0.8f, 0.5f, 0, 100 + Math.RandomLong(-20, 20));
			
			FXSparks(self.pev);
			MarkForDeath();
		}
	}
}

}