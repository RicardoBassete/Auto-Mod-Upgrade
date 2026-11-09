module AutoModUpgrade

@if(ModuleExists("AttachmentsCraftingSystem"))
public class AutoModUpgradeAttachmentsConfig {
  @runtimeProperty("ModSettings.mod", "Auto Mod Upgrade")
  @runtimeProperty("ModSettings.category", "Attachments (Attachments Crafting System)")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "Upgrade attachments")
  @runtimeProperty("ModSettings.description", "Automatically combine loose scopes, silencers and muzzle brakes made craftable by Attachments Crafting System. Attachments installed in weapons are never touched.")
  public let enabled: Bool = true;
}

@if(!ModuleExists("AttachmentsCraftingSystem"))
public class AutoModUpgradeAttachmentsConfig {
  public let enabled: Bool = false;
}

@addField(PlayerPuppet) public let amuAttachmentsConfig: ref<AutoModUpgradeAttachmentsConfig>;

// Tag added by ACS to every tiered (_Common ... _Legendary) attachment record.
public func AMU_IsACSAttachment(data: wref<gameItemData>) -> Bool {
  return data.HasTag(n"CraftableAndUpgradableScopes");
}

@if(ModuleExists("AttachmentsCraftingSystem"))
@addMethod(PlayerPuppet)
public func AMU_AttachmentsEnabled() -> Bool {
  return IsDefined(this.amuAttachmentsConfig) && this.amuAttachmentsConfig.enabled;
}

@if(!ModuleExists("AttachmentsCraftingSystem"))
@addMethod(PlayerPuppet)
public func AMU_AttachmentsEnabled() -> Bool {
  return false;
}
