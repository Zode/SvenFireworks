namespace Fireworks
{

class FireworkWeaponBottle : BaseWeaponLayer, BaseWeapon
{
	protected float animDrawTime = 0.66f;
	protected float animIdleTime = 3.61f;
	protected float animWindTime = 0.39f;
	protected float animThrowTime = 0.74f;

	void Spawn()
	{
		MakeSpawn(Vector(-1, -1, -0), Vector(1, 1, 33));
		self.pev.body = 7;
		self.FallInit();
		self.m_iDefaultAmmo = 5;
	}

	bool GetItemInfo(ItemInfo& out info)
	{
		info.iMaxAmmo1 = 100;
		info.iAmmo1Drop = 1;
		info.iMaxAmmo2 = -1;
		info.iAmmo2Drop = -1;
		info.iMaxClip = WEAPON_NOCLIP;
		info.iSlot = 7;
		info.iPosition = 23;
		info.iFlags = ITEM_FLAG_EXHAUSTIBLE;
		info.iWeight = 1;
		info.iId = g_ItemRegistry.GetIdForName(self.pev.classname);

		return true;
	}

	bool Deploy()
	{
		return Deploy("models/fireworks/v_bottle.mdl", "models/fireworks/p_bottle.mdl", FW_WEP_DRAW, "hive", animDrawTime);
	}

	void Throw()
	{
		ThrowEntity("fw_bottle");
	}

	int SafetyCheck()
	{
		return SafeToMake(1);
	}
}

}