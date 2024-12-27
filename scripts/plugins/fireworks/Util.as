namespace Fireworks
{

//h 0-360 | s,v = 0-1
Vector HSVtoRGB(float fH, float fS, float fV)
{
	Vector rgb = Vector(0, 0, 0);
	float fC = fV * fS; // chroma
	float fHPrime = (fH / 60.0f) % 6;
	float fX = fC * ( 1 - abs((fHPrime % 2) - 1));
	float fM = fV - fC;
	
	if(0 <= fHPrime && fHPrime < 1)
	{
		rgb.x = fC;
		rgb.y = fX;
	}
	else if(1 <= fHPrime && fHPrime < 2)
	{
		rgb.x = fX;
		rgb.y = fC;
	}
	else if(2 <= fHPrime && fHPrime < 3)
	{
		rgb.y = fC;
		rgb.z = fX;
	}
	else if(3 <= fHPrime && fHPrime < 4)
	{
		rgb.y = fX;
		rgb.z = fC;
	}
	else if(4 <= fHPrime && fHPrime < 5)
	{
		rgb.z = fC;
		rgb.x = fX;
	}
	else if(5 <= fHPrime && fHPrime < 6)
	{
		rgb.z = fX;
		rgb.x = fC;
	}
	
	rgb.x += fM;
	rgb.y += fM;
	rgb.z += fM;
	
	return Vector(rgb.x * 255, rgb.y * 255, rgb.z * 255);
}

void FXSparks(entvars_t@ pev)
{
	NetworkMessage msg(MSG_PVS, NetworkMessages::SVC_TEMPENTITY, pev.origin);
		msg.WriteByte(TE_SPARKS);
		msg.WriteCoord(pev.origin.x);
		msg.WriteCoord(pev.origin.y);
		msg.WriteCoord(pev.origin.z);
	msg.End();
}

void FXTrail(int entindex, entvars_t@ pev, string sprite, uint8 duration, uint8 size)
{
	NetworkMessage msg(MSG_PVS, NetworkMessages::SVC_TEMPENTITY, pev.origin);
		msg.WriteByte(TE_BEAMFOLLOW);
		msg.WriteShort(entindex);
		msg.WriteShort(g_EngineFuncs.ModelIndex(sprite));
		msg.WriteByte(duration);
		msg.WriteByte(size);
		msg.WriteByte(int(pev.rendercolor.x));
		msg.WriteByte(int(pev.rendercolor.y));
		msg.WriteByte(int(pev.rendercolor.z));
		msg.WriteByte(255);
	msg.End();
}

void FXTrailSmoke(int entindex, entvars_t@ pev, string sprite, uint8 duration, uint8 size)
{
	NetworkMessage msg(MSG_PVS, NetworkMessages::SVC_TEMPENTITY, pev.origin);
		msg.WriteByte(TE_BEAMFOLLOW);
		msg.WriteShort(entindex);
		msg.WriteShort(g_EngineFuncs.ModelIndex(sprite));
		msg.WriteByte(duration);
		msg.WriteByte(size);
		msg.WriteByte(200);
		msg.WriteByte(200);
		msg.WriteByte(200);
		msg.WriteByte(120);
	msg.End();
}

//sven only has 8192 edicts at any given time
//so assume each player carries exactly 15 weapons, and then leave 100 slots free for various temporary things.
enum SafetyCode
{
	SAFETY_OK = 0,
	SAFETY_NUMENTS,
	SAFETY_POTATOLIMIT
}

int SafeToMake(int overhead)
{
	if(g_EngineFuncs.NumberOfEntities() >= g_Engine.maxEntities - 16 * g_Engine.maxClients - 100 - overhead)
	{
		return SAFETY_NUMENTS;
	}

	if(g_fw_potato.GetInt() > 0 && g_potato_active >= g_fw_potato.GetInt())
	{
		return SAFETY_POTATOLIMIT;
	}

	return SAFETY_OK;
}

void QuickRegister(string classname, string entname)
{
	g_CustomEntityFuncs.RegisterCustomEntity(classname, entname);
	g_Game.PrecacheOther(entname);
}

void QuickRegisterWeapon(string classname, string entname, string spr)
{
	QuickRegister(classname, entname);
	g_ItemRegistry.RegisterWeapon(entname, spr, entname, "", entname);
}

Vector SafeThrowPoint(Vector origin, Vector delta, edict_t@ edict)
{
	TraceResult tr;
	g_Utility.TraceHull(origin - delta, origin + delta, ignore_monsters, human_hull, edict, tr);
	return tr.vecEndPos;
}

}