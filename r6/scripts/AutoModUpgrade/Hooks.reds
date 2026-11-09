module AutoModUpgrade

@addField(PlayerPuppet) public let amuTickGeneration: Int32;
@addField(PlayerPuppet) public let amuPassPending: Bool;

public class AutoModUpgradeTickCallback extends DelayCallback {
  public let player: wref<PlayerPuppet>;
  public let generation: Int32;

  public func Call() -> Void {
    let player: wref<PlayerPuppet> = this.player;
    if !IsDefined(player) || player.amuTickGeneration != this.generation {
      return;
    };

    player.AMU_RunUpgradePass();
    player.AMU_ScheduleTick();
  }
}

public class AutoModUpgradePickupCallback extends DelayCallback {
  public let player: wref<PlayerPuppet>;

  public func Call() -> Void {
    let player: wref<PlayerPuppet> = this.player;
    if !IsDefined(player) {
      return;
    };

    player.amuPassPending = false;
    player.AMU_RunUpgradePass();
  }
}

@addMethod(PlayerPuppet)
public func AMU_ScheduleTick() -> Void {
  let callback: ref<AutoModUpgradeTickCallback> = new AutoModUpgradeTickCallback();
  callback.player = this;
  callback.generation = this.amuTickGeneration;
  GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(callback, this.AMU_RetryInterval(), false);
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  let result: Bool = wrappedMethod();

  this.AMU_LoadConfigs();
  this.amuTickGeneration += 1;
  this.amuPassPending = false;
  this.amuUpgrading = false;
  this.AMU_ScheduleTick();

  return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnDetach() -> Bool {
  let result: Bool = wrappedMethod();

  this.amuTickGeneration += 1;
  this.amuConfig = null;
  this.amuAttachmentsConfig = null;

  return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnItemAddedToInventory(evt: ref<ItemAddedEvent>) -> Bool {
  let result: Bool = wrappedMethod(evt);

  if !this.amuUpgrading && !this.amuPassPending && IsDefined(this.amuConfig) && this.AMU_IsCandidate(evt.itemData) {
    this.amuPassPending = true;
    let callback: ref<AutoModUpgradePickupCallback> = new AutoModUpgradePickupCallback();
    callback.player = this;
    // Short delay so a whole loot batch lands first and ACS can swap legacy attachments to their tiered records.
    GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(callback, 0.5, false);
  };

  return result;
}
