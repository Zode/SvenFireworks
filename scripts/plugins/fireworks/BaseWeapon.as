namespace Fireworks
{

enum FireworkWeaponAnims
{
	FW_WEP_IDLE = 0,
	FW_WEP_DRAW,
	FW_WEP_WINDUP,
	FW_WEP_THROW
}

class BaseWeaponLayer : ScriptBasePlayerWeaponEntity
{
	protected CBasePlayer@ m_pPlayer
	{
		get const
		{
			return cast<CBasePlayer@>(self.m_hPlayer.GetEntity());
		}

		set
		{
			self.m_hPlayer = EHandle(@value);
		}
	};
}

mixin class BaseWeapon
{
	protected float m_fAttackStart = 0.0f;
	protected bool m_bThrown = false;
	protected int m_iAmmoSave = 0;

	void MakeSpawn(Vector vmin, Vector vmax)
	{
		self.pev.solid = SOLID_BBOX;
		self.pev.movetype = MOVETYPE_BOUNCE;
		
		g_EntityFuncs.SetModel(self, "models/fireworks/fw.mdl");
		g_EntityFuncs.SetOrigin(self, self.pev.origin);
		g_EntityFuncs.SetSize(self.pev, vmin, vmax);
		
		self.pev.friction = 0.66f;
		self.pev.gravity = 0.75f;
	}

	bool CanHaveDuplicates()
	{
		return true;
	}

	bool AddToPlayer(CBasePlayer@ player)
	{
		if(!BaseClass.AddToPlayer(player))
		{
			return false;
		}		

		NetworkMessage msg(MSG_ONE, NetworkMessages::WeapPickup, player.edict());
			msg.WriteLong(g_ItemRegistry.GetIdForName(self.pev.classname));
		msg.End();

		return true;
	}

	bool CanDeploy()
	{
		return m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) != 0;
	}

	bool Deploy(string vModel, string pModel, int vAnim, string pAnim, float time)
	{
		self.DefaultDeploy(self.GetV_Model(vModel), self.GetP_Model(pModel), vAnim, pAnim, 0, 0);
		self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = self.m_flNextTertiaryAttack = g_Engine.time + animDrawTime;
		m_iAmmoSave = 0;
		return true;
	}

	bool CanHolster()
	{
		return m_fAttackStart == 0.0f;
	}

	void Holster(int skipLocal = 0)
	{
		m_fAttackStart = 0;
		if(m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) > 0)
		{
			m_iAmmoSave = m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType);
		}

		if(m_iAmmoSave <= 0)
		{
			SetThink(ThinkFunction(DestroyThink));
			self.pev.nextthink = g_Engine.time + 0.1f;
		}

		BaseClass.Holster(skipLocal);
	}

	CBasePlayerItem@ DropItem()
	{
		m_iAmmoSave = m_pPlayer.AmmoInventory(self.m_iPrimaryAmmoType);
		return self;
	}

	void DestroyThink()
	{
		SetThink(null);
		self.DestroyItem();
	}

	void PrimaryAttack()
	{
		int safetycode = SafetyCheck();

		if(safetycode == SAFETY_NUMENTS)
		{
			g_PlayerFuncs.ClientPrint(m_pPlayer, HUD_PRINTCENTER, "No entity slots left.\nPlease wait and try again\n");
			return;
		}
		else if(safetycode == SAFETY_POTATOLIMIT)
		{
			g_PlayerFuncs.ClientPrint(m_pPlayer, HUD_PRINTCENTER, "Server configurable limit hit.\nPlease wait and try again\n(max: " + g_fw_potato.GetInt() + ")\n");
			return;
		}

		if(m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) <= 0 ||
			m_fAttackStart > 0.0f)
		{
			return;
		}

		self.SendWeaponAnim(FW_WEP_WINDUP, 0, 0);

		m_fAttackStart = g_Engine.time + animWindTime;
		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = self.m_flNextTertiaryAttack = g_Engine.time + animWindTime + animThrowTime;
		self.m_flTimeWeaponIdle = g_Engine.time + animWindTime;
	}

	void SecondaryAttack()
	{
	}

	void TertiaryAttack()
	{
	}

	void WeaponIdle()
	{
		if(m_fAttackStart > 0.0f)
		{
			WeaponThrow();
			return;
		}

		if(self.m_flTimeWeaponIdle > g_Engine.time)
		{
			return;
		}

		self.SendWeaponAnim(FW_WEP_IDLE, 0, 0);
		self.m_flTimeWeaponIdle = g_Engine.time + animIdleTime;
	}

	void WeaponThrow()
	{
		if(m_fAttackStart > g_Engine.time || m_bThrown)
		{
			return;
		}

		self.SendWeaponAnim(FW_WEP_THROW, 0, 0);
		self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = self.m_flNextTertiaryAttack = g_Engine.time + animThrowTime;
		m_bThrown = true;
		SetThink(ThinkFunction(ThrowThink));
		self.pev.nextthink = g_Engine.time + animThrowTime;
		m_pPlayer.SetAnimation(PLAYER_ATTACK1);
		Throw();
	}

	void ThrowThink()
	{
		m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) - 1);
		m_fAttackStart = 0.0f;
		m_bThrown = false;
		SetThink(null);

		if(m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) == 0)
		{
			Holster();
			return;
		}
		
		self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = self.m_flNextTertiaryAttack = g_Engine.time + animDrawTime;
		self.SendWeaponAnim(FW_WEP_DRAW, 0, 0);
	}

	void ThrowEntity(string entity)
	{
		CBaseEntity@ ent = g_EntityFuncs.CreateEntity(entity);
		g_EntityFuncs.DispatchSpawn(ent.edict());

		Vector angle = m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle;
		if(angle.x < 0)
		{
			angle.x = -10.0f + angle.x * ((90.0f - 10.0f) / 90.0f);
		}
		else
		{
			angle.x = -10.0f + angle.x * ((90.0f + 10.0f) / 90.0f);
		}

		float velocity = (90.0f - angle.x) * 3.0f;
		if(velocity > 300.0f)
		{
			velocity = 300.0f;
		}

		Math.MakeVectors(angle);

		ent.pev.angles = Vector(0, m_pPlayer.pev.angles.y + 180, 0);
		ent.pev.origin = SafeThrowPoint(m_pPlayer.pev.origin + m_pPlayer.pev.view_ofs, g_Engine.v_forward * 10.0f + g_Engine.v_up * -24.0f + g_Engine.v_right * 8.0f, m_pPlayer.edict());
		ent.pev.velocity = g_Engine.v_forward * velocity + m_pPlayer.pev.velocity * 0.5f;
		@ent.pev.owner = m_pPlayer.edict();
	}

	void PrecacheSound(string sound)
	{
		g_Game.PrecacheGeneric("sound/" + sound);
		g_SoundSystem.PrecacheSound(sound);
	}

	void PrecacheWeapon(string name, string entityName)
	{
		g_Game.PrecacheModel("models/fireworks/v_" + name + ".mdl");
		g_Game.PrecacheModel("models/fireworks/p_" + name + ".mdl");
		g_Game.PrecacheGeneric("sprites/fireworks/" + entityName + ".txt");
	}

	void Precache()
	{
		PrecacheSound("fireworks/light.ogg");
		PrecacheSound("fireworks/light2.ogg");
		PrecacheSound("fireworks/light3.ogg");

		g_Game.PrecacheModel("sprites/fireworks/hud.spr");

		PrecacheWeapon("pop", "weapon_fw_rocket");
		PrecacheWeapon("bottle", "weapon_fw_bottle");
		PrecacheWeapon("fountain", "weapon_fw_fountain");
		PrecacheWeapon("beans", "weapon_fw_beans");
		PrecacheWeapon("cake", "weapon_fw_cake");
		PrecacheWeapon("bigcake", "weapon_fw_sizzler");
		PrecacheWeapon("roman", "weapon_fw_roman");
		PrecacheWeapon("tube", "weapon_fw_tube");
		PrecacheWeapon("crackers", "weapon_fw_crackers");
	}
}

}