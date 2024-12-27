namespace Fireworks
{

class FireworkBeans : ScriptBaseEntity, BaseFirework
{
	int fuse = 0;
	int projectilesLeft = 8;
	
	void Spawn()
	{
		MakeSpawn(Vector(-15, -15, 0), Vector(15 , 15, 24));
		self.pev.body = 0;
		self.pev.scale = 0.66f;
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
			self.pev.nextthink = g_Engine.time + 1.25f + Math.RandomFloat(0.0f, 0.66f);
			
			switch(Math.RandomLong(0, 2))
			{
				case 0:
					g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/shoot1.ogg", 0.5f, 0.8f, 0, 100 + Math.RandomLong(-20, 20));
					break;

				case 1:
					g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/shoot2.ogg", 0.5f, 0.8f, 0, 100 + Math.RandomLong(-20, 20));
					break;

				case 2:
					g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/shoot3.ogg", 0.5f, 0.8f, 0, 100 + Math.RandomLong(-20, 20));
					break;
			}
			
			CBaseEntity@ pEnt = g_EntityFuncs.CreateEntity("fw_proj_beans");
			g_EntityFuncs.DispatchSpawn(pEnt.edict());
			Vector deltaOrigin = Vector(0, 0, 0);
			Math.MakeVectors(self.pev.angles);
			pEnt.pev.velocity = Vector(Math.RandomLong(-10, 10), Math.RandomLong(-10, 10), 900);
			switch(projectilesLeft)
			{
				case 8:
				case 7:
				case 2:
				case 1:
					deltaOrigin = Vector(-7.5f, 5.0f, 17.5f);
					break;

				case 6:
				case 5:
				case 4:
				case 3:
					deltaOrigin = Vector(-1.5f, 5.0f, 17.5f);
					break;
			}

			//alternate sides
			if(projectilesLeft % 2 == 1)
			{
				deltaOrigin.y *= -1.0f;
				pEnt.pev.velocity = pEnt.pev.velocity + g_Engine.v_forward * -150;
			}
			else
			{
				pEnt.pev.velocity = pEnt.pev.velocity + g_Engine.v_forward * 150;
			}

			//mirror
			if(projectilesLeft <= 4)
			{
				deltaOrigin.x *= -1.0f;
			}
			
			pEnt.pev.origin = self.pev.origin;
			pEnt.pev.origin = pEnt.pev.origin + g_Engine.v_right * deltaOrigin.x;
			pEnt.pev.origin = pEnt.pev.origin + g_Engine.v_forward * deltaOrigin.y;
			pEnt.pev.origin = pEnt.pev.origin + g_Engine.v_up * deltaOrigin.z;

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