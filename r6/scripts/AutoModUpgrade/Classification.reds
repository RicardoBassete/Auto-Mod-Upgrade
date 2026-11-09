module AutoModUpgrade

// Index in this array is the quality tier (0 = Common ... 4 = Legendary).
public func AMU_QualitySuffixes() -> array<String> {
  return ["_Common", "_Uncommon", "_Rare", "_Epic", "_Legendary"];
}

public func AMU_EndsWith(str: String, suffix: String) -> Bool {
  let len: Int32 = StrLen(suffix);
  return StrLen(str) >= len && Equals(StrRight(str, len), suffix);
}

// Returns -1 when the record name has no classic quality suffix (Plus tiers, iconics, legacy names).
public func AMU_GetTier(recordName: String) -> Int32 {
  let suffixes: array<String> = AMU_QualitySuffixes();
  let i: Int32 = 0;
  while i < ArraySize(suffixes) {
    if AMU_EndsWith(recordName, suffixes[i]) {
      return i;
    };
    i += 1;
  };
  return -1;
}

public func AMU_NextTierID(recordName: String, tier: Int32) -> TweakDBID {
  let suffixes: array<String> = AMU_QualitySuffixes();
  let base: String = StrLeft(recordName, StrLen(recordName) - StrLen(suffixes[tier]));
  return TDBID.Create(base + suffixes[tier + 1]);
}

public func AMU_IsWeaponStatModType(type: gamedataItemType) -> Bool {
  return
    Equals(type, gamedataItemType.Prt_AR_SMG_LMGMod) ||
    Equals(type, gamedataItemType.Prt_BladeMod) ||
    Equals(type, gamedataItemType.Prt_BluntMod) ||
    Equals(type, gamedataItemType.Prt_Capacitor) ||
    Equals(type, gamedataItemType.Prt_HandgunMod) ||
    Equals(type, gamedataItemType.Prt_Magazine) ||
    Equals(type, gamedataItemType.Prt_MeleeMod) ||
    Equals(type, gamedataItemType.Prt_Mod) ||
    Equals(type, gamedataItemType.Prt_PowerMod) ||
    Equals(type, gamedataItemType.Prt_Precision_Sniper_RifleMod) ||
    Equals(type, gamedataItemType.Prt_RangedMod) ||
    Equals(type, gamedataItemType.Prt_Receiver) ||
    Equals(type, gamedataItemType.Prt_ShotgunMod) ||
    Equals(type, gamedataItemType.Prt_SmartMod) ||
    Equals(type, gamedataItemType.Prt_Stock) ||
    Equals(type, gamedataItemType.Prt_TargetingSystem) ||
    Equals(type, gamedataItemType.Prt_TechMod) ||
    Equals(type, gamedataItemType.Prt_ThrowableMod) ||
  false;
}

@addMethod(PlayerPuppet)
public func AMU_IsCandidate(data: wref<gameItemData>) -> Bool {
  if !IsDefined(data) || data.HasTag(n"Quest") {
    return false;
  };

  if AMU_IsACSAttachment(data) {
    return this.AMU_AttachmentsEnabled();
  };

  return this.amuConfig.enableStatMods && AMU_IsWeaponStatModType(data.GetItemType());
}
