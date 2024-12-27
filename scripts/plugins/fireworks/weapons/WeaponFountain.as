namespace Fireworks
{

class FireworkWeaponFountain : BaseWeaponLayer, BaseWeapon
{
	protected float animDrawTime = 0.66f;
	protected float animIdleTime = 3.61f;
	protected float animWindTime = 0.39f;
	protected float animThrowTime = 0.74f;

	void Spawn()
	{
		MakeSpawn(Vector(-6, -6, -0), Vector(6, 6, 28));
		self.pev.body = 5;
		self.pev.scale = 0.5f;
		self.FallInit();
		self.m_iDefaultAmmo = 1;
	}

	bool GetItemInfo(ItemInfo& out info)
	{
		info.iMaxAmmo1 = 25;
		info.iAmmo1Drop = 1;
		info.iMaxAmmo2 = -1;
		info.iAmmo2Drop = -1;
		info.iMaxClip = WEAPON_NOCLIP;
		info.iSlot = 7;
		info.iPosition = 17;
		info.iFlags = ITEM_FLAG_EXHAUSTIBLE;
		info.iWeight = 1;
		info.iId = g_ItemRegistry.GetIdForName(self.pev.classname);

		return true;
	}

	bool Deploy()
	{
		return Deploy("models/fireworks/v_fountain.mdl", "models/fireworks/p_fountain.mdl", FW_WEP_DRAW, "hive", animDrawTime);
	}

	void Throw()
	{
		ThrowEntity("fw_fountain");
	}

	int SafetyCheck()
	{
		return SafeToMake(1);
	}
}

}