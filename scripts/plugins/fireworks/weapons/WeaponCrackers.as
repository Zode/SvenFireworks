namespace Fireworks
{

class FireworkWeaponCrackers : BaseWeaponLayer, BaseWeapon
{
	protected float animDrawTime = 0.66f;
	protected float animIdleTime = 3.37f;
	protected float animWindTime = 1.10f;
	protected float animThrowTime = 0.80f;

	void Spawn()
	{
		MakeSpawn(Vector(-2, -2, -0), Vector(2, 2, 1));
		self.pev.body = 8;
		self.FallInit();
		self.m_iDefaultAmmo = 5;
	}

	bool GetItemInfo(ItemInfo& out info)
	{
		info.iMaxAmmo1 = 200;
		info.iAmmo1Drop = 1;
		info.iMaxAmmo2 = -1;
		info.iAmmo2Drop = -1;
		info.iMaxClip = WEAPON_NOCLIP;
		info.iSlot = 7;
		info.iPosition = 16;
		info.iFlags = ITEM_FLAG_EXHAUSTIBLE;
		info.iWeight = 1;
		info.iId = g_ItemRegistry.GetIdForName(self.pev.classname);

		return true;
	}

	bool Deploy()
	{
		return Deploy("models/fireworks/v_crackers.mdl", "models/fireworks/p_crackers.mdl", FW_WEP_DRAW, "gren", animDrawTime);
	}

	void Throw()
	{
		ThrowEntity("fw_crackers");
	}

	int SafetyCheck()
	{
		return SafeToMake(7);
	}
}

}