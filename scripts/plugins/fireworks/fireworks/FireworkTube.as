namespace Fireworks
{

class FireworkTube : ScriptBaseEntity, BaseFirework
{
	int fuse = 0;
	int projectilesLeft = 12;
	
	void Spawn()
	{
		MakeSpawn(Vector(-5,-5,-0),Vector(5,5,24));
		self.pev.body = 1;
		self.pev.scale = 0.75f;
		self.pev.nextthink = g_Engine.time+0.1;
		SetThink(ThinkFunction(this.Think));
		SetTouch(TouchFunction(FrictionTouch));
	}
	
	void Think()
	{
		if(fuse == 0)
		{
			fuse = 1;
			g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/fuse.ogg", 0.2f, 3.0f, SND_FORCE_LOOP, 100+Math.RandomLong(-10,10));
			self.pev.nextthink = g_Engine.time+3.5+Math.RandomFloat(0.0,1.5);
			return;
		}
		else if(fuse == 1)
		{
			fuse = 2;
			g_SoundSystem.StopSound(self.edict(), CHAN_BODY, "fireworks/fuse.ogg");
		}
		if(projectilesLeft>0)
		{
			self.pev.nextthink = g_Engine.time+1+Math.RandomFloat(0.0,0.66);
			
			int r = Math.RandomLong(0,2);
			switch(r)
			{
			case 0:
				g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/small.ogg", 0.5f, 0.8f, 0, 100+Math.RandomLong(-20,20));
				break;
			case 1:
				g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/small2.ogg", 0.5f, 0.8f, 0, 100+Math.RandomLong(-20,20));
				break;
			case 2:
				g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/small3.ogg", 0.5f, 0.8f, 0, 100+Math.RandomLong(-20,20));
				break;
			}
			
			CBaseEntity@ pEnt = g_EntityFuncs.CreateEntity("fw_proj_small");
			g_EntityFuncs.DispatchSpawn(pEnt.edict());
			Math.MakeVectors(self.pev.angles);
			Vector deltaVelocity = Vector(Math.RandomLong(-150,150),Math.RandomLong(-150,150),1000);
			pEnt.pev.origin = self.pev.origin + g_Engine.v_up * 24.0f;
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