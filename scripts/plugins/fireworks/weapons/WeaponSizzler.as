namespace Fireworks
{

class FireworkWeaponSizzler : BaseWeaponLayer, BaseWeapon
{
	protected float animDrawTime = 0.66f;
	protected float animIdleTime = 3.61f;
	protected float animWindTime = 0.39f;
	protected float animThrowTime = 0.74f;

	void Spawn()
	{
		MakeSpawn(Vector(-16, -16, -0), Vector(16, 16, 24));
		self.pev.body = 4;
		self.pev.scale = 0.45f;
		self.FallInit();
		self.m_iDefaultAmmo = 1;
	}

	bool GetItemInfo(ItemInfo& out info)
	{
		info.iMaxAmmo1 = 10;
		info.iAmmo1Drop = 1;
		info.iMaxAmmo2 = -1;
		info.iAmmo2Drop = -1;
		info.iMaxClip = WEAPON_NOCLIP;
		info.iSlot = 7;
		info.iPosition = 21;
		info.iFlags = ITEM_FLAG_EXHAUSTIBLE;
		info.iWeight = 1;
		info.iId = g_ItemRegistry.GetIdForName(self.pev.classname);

		return true;
	}

	bool Deploy()
	{
		return Deploy("models/fireworks/v_bigcake.mdl", "models/fireworks/p_bigcake.mdl", FW_WEP_DRAW, "trip", animDrawTime);
	}

	void Throw()
	{
		ThrowEntity("fw_sizzler");
	}

	int SafetyCheck()
	{
		return SafeToMake(11);
	}
}

}