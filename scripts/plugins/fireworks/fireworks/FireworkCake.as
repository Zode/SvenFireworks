namespace Fireworks
{

class FireworkCake : ScriptBaseEntity, BaseFirework
{
	int fuse = 0;
	int projectilesLeft = 30;
	
	void Spawn()
	{
		MakeSpawn(Vector(-8, -8, -0), Vector(8, 8, 16));
		self.pev.body = 3;
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
			self.pev.nextthink = g_Engine.time + 0.25f + Math.RandomFloat(0.0f, 0.66f);
			
			switch(Math.RandomLong(0, 2))
			{
				case 0:
					g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/small.ogg", 0.5f, 0.8f, 0, 100 + Math.RandomLong(-20, 20));
					break;

				case 1:
					g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/small2.ogg", 0.5f, 0.8f, 0, 100 + Math.RandomLong(-20, 20));
					break;

				case 2:
					g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/small3.ogg", 0.5f, 0.8f, 0, 100 + Math.RandomLong(-20, 20));
					break;
			}
			
			CBaseEntity@ pEnt = g_EntityFuncs.CreateEntity("fw_proj_whistler");
			g_EntityFuncs.DispatchSpawn(pEnt.edict());
			Math.MakeVectors(self.pev.angles);
			Vector deltaOrigin = Vector(Math.RandomFloat(-5, 5), Math.RandomFloat(-5, 5), 12);
			Vector deltaVelocity = Vector(Math.RandomLong(-200, 200), Math.RandomLong(-200, 200), 800);
			pEnt.pev.origin = self.pev.origin + g_Engine.v_right * deltaOrigin.x + g_Engine.v_forward * deltaOrigin.y + g_Engine.v_up * deltaOrigin.z;
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