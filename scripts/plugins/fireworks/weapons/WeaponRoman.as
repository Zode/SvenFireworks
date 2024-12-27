namespace Fireworks
{

class FireworkWeaponRoman : BaseWeaponLayer, BaseWeapon
{
	protected float animDrawTime = 0.66f;
	protected float animIdleTime = 4.21f;
	protected float animWindTime = 0.39f;
	protected float animThrowTime = 0.74f;

	void Spawn()
	{
		MakeSpawn(Vector(-2, -2, -0), Vector(2, 2, 40));
		self.pev.body = 6;
		self.pev.scale = 0.5f;
		self.FallInit();
		self.m_iDefaultAmmo = 4;
	}

	bool GetItemInfo(ItemInfo& out info)
	{
		info.iMaxAmmo1 = 50;
		info.iAmmo1Drop = 1;
		info.iMaxAmmo2 = -1;
		info.iAmmo2Drop = -1;
		info.iMaxClip = WEAPON_NOCLIP;
		info.iSlot = 7;
		info.iPosition = 18;
		info.iFlags = ITEM_FLAG_EXHAUSTIBLE;
		info.iWeight = 1;
		info.iId = g_ItemRegistry.GetIdForName(self.pev.classname);

		return true;
	}

	bool Deploy()
	{
		return Deploy("models/fireworks/v_roman.mdl", "models/fireworks/p_roman.mdl", FW_WEP_DRAW, "hive", animDrawTime);
	}

	void Throw()
	{
		ThrowEntity("fw_roman");
	}

	int SafetyCheck()
	{
		return SafeToMake(4);
	}
}

}