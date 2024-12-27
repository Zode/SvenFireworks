namespace Fireworks
{

class FireworkCrackers : ScriptBaseEntity, BaseFirework
{	
	void Spawn()
	{
		MakeSpawn(Vector(-2, -2, -0), Vector(2, 2, 1));
		self.pev.body = 8;
		self.pev.nextthink = g_Engine.time + 0.1f;
		SetThink(ThinkFunction(this.Think));
		SetTouch(TouchFunction(this.ExplodeTouch));
	}
	
	void ExplodeTouch(CBaseEntity@ pOther)
	{
		g_SoundSystem.StopSound(self.edict(), CHAN_BODY, "fireworks/fuse.ogg");
		
		Vector speed = self.pev.velocity;
		speed.z = speed.z * -1;
		speed = speed * 0.5f;
		CBaseEntity@ pEnt = null;
		for(int i = 0; i < 6; i++)
		{
			@pEnt = g_EntityFuncs.CreateEntity("fw_proj_cracker");
			g_EntityFuncs.DispatchSpawn(pEnt.edict());
			pEnt.pev.origin = self.pev.origin + Vector(0, 0, 2);
			pEnt.pev.velocity = speed + Vector(Math.RandomLong(-200, 200), Math.RandomLong(-200, 200), 100);
			pEnt.pev.angles = Math.VecToAngles(pEnt.pev.velocity);
		}
		
		g_EntityFuncs.Remove(self);
	}
	
	void Think()
	{
		g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/fuse.ogg", 0.2f, 3.0f, SND_FORCE_LOOP, 100 + Math.RandomLong(-10, 10));
	}
}

}