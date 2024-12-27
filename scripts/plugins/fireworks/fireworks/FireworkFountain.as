namespace Fireworks
{

class FireworkFountain : ScriptBaseEntity, BaseFirework
{
	float life = 0.0f;
	
	void Spawn()
	{
		MakeSpawn(Vector(-6, -6, -0), Vector(6, 6, 28));
		self.pev.body = 5;
		self.pev.scale = 0.5f;
		self.pev.nextthink = g_Engine.time + 0.1f;
		SetThink(ThinkFunction(this.StartThink));
		SetTouch(TouchFunction(FrictionTouch));
	}
	
	void StartThink()
	{
		self.pev.nextthink = g_Engine.time + 3.5f + Math.RandomFloat(0.0, 1.5);
		g_SoundSystem.PlaySound(self.edict(), CHAN_BODY, "fireworks/fuse.ogg", 0.4f, 2.0f, SND_FORCE_LOOP, 100 + Math.RandomLong(-10, 10));
		SetThink(ThinkFunction(this.Think));
		life = g_Engine.time + 13.0f;
	}
	
	void Think()
	{
		self.pev.nextthink = g_Engine.time + 0.06f;
		
		Math.MakeVectors(self.pev.angles);
		Vector position1 = self.pev.origin + g_Engine.v_up * 16;
		Vector position2 = self.pev.origin + g_Engine.v_up * 17;
		NetworkMessage msg(MSG_PVS, NetworkMessages::SVC_TEMPENTITY, self.pev.origin);
			msg.WriteByte(TE_SPRITETRAIL);
			msg.WriteCoord(position1.x);
			msg.WriteCoord(position1.y);
			msg.WriteCoord(position1.z);
			msg.WriteCoord(position2.x);
			msg.WriteCoord(position2.y);
			msg.WriteCoord(position2.z);
			msg.WriteShort(g_EngineFuncs.ModelIndex("sprites/flare1.spr"));
			msg.WriteByte(1); // count
			msg.WriteByte(1); //life
			msg.WriteByte(1); //scale
			msg.WriteByte(8); //speedNoise
			msg.WriteByte(32); //speed
		msg.End();
	
		if(g_Engine.time > life)
		{
			g_SoundSystem.StopSound(self.edict(), CHAN_BODY, "fireworks/fuse.ogg");
			DoFadeOut();
		}
	}
}

}