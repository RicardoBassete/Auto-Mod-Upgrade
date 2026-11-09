module AutoModUpgrade

enum AutoModUpgradeQuality {
  Common = 0,
  Uncommon = 1,
  Rare = 2,
  Epic = 3,
  Legendary = 4
}

public class AutoModUpgradeConfig {
  @runtimeProperty("ModSettings.mod", "Auto Mod Upgrade")
  @runtimeProperty("ModSettings.category", "General")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Quality ceiling")
  @runtimeProperty("ModSettings.description", "Highest quality the auto upgrade can produce. Two identical items of the same quality are combined into one of the next quality until this ceiling is reached.")
  @runtimeProperty("ModSettings.displayValues.Common", "LocKey#1814")
  @runtimeProperty("ModSettings.displayValues.Uncommon", "LocKey#1817")
  @runtimeProperty("ModSettings.displayValues.Rare", "LocKey#1816")
  @runtimeProperty("ModSettings.displayValues.Epic", "LocKey#1813")
  @runtimeProperty("ModSettings.displayValues.Legendary", "LocKey#1815")
  public let qualityCeiling: AutoModUpgradeQuality = AutoModUpgradeQuality.Legendary;

  @runtimeProperty("ModSettings.mod", "Auto Mod Upgrade")
  @runtimeProperty("ModSettings.category", "General")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Upgrade weapon mods")
  @runtimeProperty("ModSettings.description", "Automatically combine loose weapon mods (e.g. Pax) in the backpack. Mods installed in weapons are never touched.")
  public let enableStatMods: Bool = true;

  @runtimeProperty("ModSettings.mod", "Auto Mod Upgrade")
  @runtimeProperty("ModSettings.category", "General")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Retry interval (seconds)")
  @runtimeProperty("ModSettings.description", "How often the backpack is checked again for items that can be upgraded.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "2")
  @runtimeProperty("ModSettings.max", "60")
  public let retryIntervalSec: Int32 = 6;
}

@addField(PlayerPuppet) public let amuConfig: ref<AutoModUpgradeConfig>;

@addMethod(PlayerPuppet)
public func AMU_LoadConfigs() -> Void {
  this.amuConfig = new AutoModUpgradeConfig();
  this.amuAttachmentsConfig = new AutoModUpgradeAttachmentsConfig();
}

@addMethod(PlayerPuppet)
public func AMU_QualityCeiling() -> Int32 {
  return Cast<Int32>(EnumInt(this.amuConfig.qualityCeiling));
}

@addMethod(PlayerPuppet)
public func AMU_RetryInterval() -> Float {
  return Cast<Float>(Max(2, this.amuConfig.retryIntervalSec));
}

public class AutoModUpgradeRefreshConfigEvent extends Event {}

@addMethod(PlayerPuppet)
protected cb func OnAutoModUpgradeRefreshConfigEvent(evt: ref<AutoModUpgradeRefreshConfigEvent>) -> Bool {
  this.AMU_LoadConfigs();
  return true;
}

@wrapMethod(PauseMenuBackgroundGameController)
protected cb func OnUninitialize() -> Bool {
  this.GetPlayerControlledObject().QueueEvent(new AutoModUpgradeRefreshConfigEvent());
  return wrappedMethod();
}
