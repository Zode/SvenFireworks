namespace Fireworks
{

class FireworkProjectileCracker : ScriptBaseEntity, BaseFirework
{
	float life = 0.0f;

	void Spawn()
	{
		MakeSpawn(Vector(-1, -1, -0), Vector(1, 1, 1));
		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_TOSS;
		self.pev.body = 9;
		life = g_Engine.time + 0.5f + Math.RandomFloat(0.0f, 1.0f);

		self.pev.nextthink = g_Engine.time + 0.01f;
		SetThink(ThinkFunction(this.Think));
		SetTouch(TouchFunction(this.CrackerTouch));
	}
	
	void CrackerTouch(CBaseEntity@ pOther)
	{
		// does not seem to run in solid_not, thus movetype_toss.
		if(pOther.IsBSPModel())
		{
			self.pev.flags |= FL_ONGROUND;
		}
			
		if(self.pev.flags & FL_ONGROUND != 0)
		{
			self.pev.velocity = self.pev.velocity * 0.8f;
			self.pev.velocity.z -= 50;
		}
	}
	
	void Think()
	{
		if(g_Engine.time > life)
		{
			g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/cracker.ogg", 1.0f, 0.5f, 0, 100 + Math.RandomLong(-20, 20));
			
			FXSparks(self.pev);
			g_EntityFuncs.Remove(self);
		}
	
		self.pev.nextthink = g_Engine.time + 0.1f;
	}
}

}