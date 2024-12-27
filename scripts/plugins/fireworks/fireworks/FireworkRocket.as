namespace Fireworks
{

class FireworkRocket : ScriptBaseEntity, BaseFirework
{
	int fuse = 0;
	float life = 0.0f;
	bool useSkyFix = false;
	
	void Spawn()
	{
		MakeSpawn(Vector(-3, -3, -0), Vector(3, 3, 40));
		self.pev.body = 2;
		self.pev.nextthink = g_Engine.time + 0.1f;
		SetThink(ThinkFunction(this.Think));
		SetTouch(TouchFunction(FrictionTouch));
		self.pev.rendercolor = HSVtoRGB(Math.RandomFloat(0, 360), 0.85f, 1.0f);
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
			self.pev.movetype = MOVETYPE_FLY;
			self.pev.solid = SOLID_NOT;
			self.pev.velocity = Vector(Math.RandomFloat(-400, 400), Math.RandomFloat(-400, 400), 2000);
			g_SoundSystem.StopSound(self.edict(), CHAN_BODY, "fireworks/fuse.ogg");
			g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/bottle.ogg", 0.8f, 0.6f, 0, 80 + Math.RandomLong(-20, 20));
			life = g_Engine.time + 0.9f;
			FXTrailSmoke(g_EntityFuncs.EntIndex(self.edict()), self.pev, "sprites/zbeam5.spr", 8, 8);

			//fix disappearing into the sky by pre-emptively exploding
			TraceResult tr;
			g_Utility.TraceLine(self.pev.origin, self.pev.origin + Vector(0, 0, 2048), ignore_monsters, self.edict(), tr);
			if(tr.fInWater > 0.0f)
			{
				useSkyFix = true;
			}
		}

		self.pev.nextthink = g_Engine.time + 0.1f;

		if(useSkyFix)
		{
			TraceResult tr;
			//there is no info of timestep so blindly 0.1f it is.
			g_Utility.TraceLine(self.pev.origin, self.pev.origin + self.pev.velocity * 0.1f, ignore_monsters, self.edict(), tr);
			if(tr.fInWater > 0.0f)
			{
				self.pev.velocity.z = 0.0f;
				life = 0.0f; //explode instantly
			}
		}
			
		if(g_Engine.time > life)
		{
			self.pev.origin.z -= self.pev.size.z + 1;
			
			switch(Math.RandomLong(0, 2))
			{
				case 0:
					g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/lexp.ogg", 1.0f, 0.1f, 0, 100 + Math.RandomLong(-10, 10));
					break;

				case 1:
					g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/lexp2.ogg", 1.0f, 0.1f, 0, 100 + Math.RandomLong(-10, 10));
					break;

				case 2:
					g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/lexp3.ogg", 1.0f, 0.1f, 0, 100 + Math.RandomLong(-10, 10));
					break;
			}
			
			//stupid workaround because setting this entity to .spr locks it to origin 0,0,0
			CBaseEntity@ pEnt = g_EntityFuncs.CreateEntity("fw_proj_large");
			g_EntityFuncs.DispatchSpawn(pEnt.edict());
			pEnt.pev.origin = self.pev.origin + Vector(0, 0, -42);
			pEnt.pev.rendercolor = self.pev.rendercolor;
			
			NetworkMessage msg(MSG_PVS, NetworkMessages::SVC_TEMPENTITY, self.pev.origin);
				msg.WriteByte(TE_BEAMTORUS);
				msg.WriteCoord(self.pev.origin.x);
				msg.WriteCoord(self.pev.origin.y);
				msg.WriteCoord(self.pev.origin.z);
				msg.WriteCoord(self.pev.origin.x);
				msg.WriteCoord(self.pev.origin.y);
				msg.WriteCoord(self.pev.origin.z + 400);
				msg.WriteShort(g_EngineFuncs.ModelIndex("sprites/fireworks/ptrail.spr"));
				msg.WriteByte(0);
				msg.WriteByte(0); //fps
				msg.WriteByte(12); //life
				msg.WriteByte(80); //width
				msg.WriteByte(0); //noise
				msg.WriteByte(int(self.pev.rendercolor.x)); 
				msg.WriteByte(int(self.pev.rendercolor.y)); 
				msg.WriteByte(int(self.pev.rendercolor.z)); 
				msg.WriteByte(255);
				msg.WriteByte(0); //scrollspeed
			msg.End();
			
			g_EntityFuncs.Remove(self);
		}
	}
}

}