namespace Fireworks
{

class FireworkRoman : ScriptBaseEntity, BaseFirework
{
	int fuse = 0;
	int projectilesLeft = 16;
	
	void Spawn()
	{
		MakeSpawn(Vector(-2, -2, -0), Vector(2, 2, 40));
		self.pev.body = 6;
		self.pev.scale = 0.5f;
		self.pev.nextthink = g_Engine.time + 0.1f;
		SetThink(ThinkFunction(this.Think));
		SetTouch(TouchFunction(FrictionTouch));
	}
	
	void Think()
	{
		if(fuse == 0)
		{
			fuse = 1;
			g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/fuse.ogg", 0.2f, 3.0f, SND_FORCE_LOOP, 100 + Math.RandomLong(-10, 10));
			self.pev.nextthink = g_Engine.time + 3.5f + Math.RandomFloat(0.0f, 1.5f);
			return;
		}
		else if(fuse == 1)
		{
			fuse = 2;
			g_SoundSystem.StopSound(self.edict(), CHAN_BODY, "fireworks/fuse.ogg");
		}

		if(projectilesLeft > 0)
		{
			self.pev.nextthink = g_Engine.time + 1.0f + Math.RandomFloat(0.0f, 0.44f);
			
			g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/roman.ogg", 0.6f, 0.6f, 0, 100 + Math.RandomLong(-20, 20));
			
			CBaseEntity@ pEnt = g_EntityFuncs.CreateEntity("fw_proj_roman");
			g_EntityFuncs.DispatchSpawn(pEnt.edict());
			Math.MakeVectors(self.pev.angles);
			pEnt.pev.origin = self.pev.origin + g_Engine.v_up * 25.0f;
			Vector deltaVelocity = Vector(Math.RandomLong(-50, 50), Math.RandomLong(-50, 50), 800);
			pEnt.pev.velocity = g_Engine.v_right * deltaVelocity.x + g_Engine.v_forward * deltaVelocity.y + g_Engine.v_up * deltaVelocity.z;
			
			projectilesLeft--;
			return;
		}
		else
		{
			DoFadeOut();
		}
	}
}

}