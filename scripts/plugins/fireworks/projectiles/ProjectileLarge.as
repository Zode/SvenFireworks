namespace Fireworks
{

class FireworkProjectileLarge : ScriptBaseEntity, BaseProjectile
{
	void Spawn()
	{
		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_FLY;
		
		MakeSpawn(2.0f, "sprites/fireworks/ex1.spr");

		SetThink(ThinkFunction(this.AnimThink));
		SetTouch(TouchFunction(Touch));
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