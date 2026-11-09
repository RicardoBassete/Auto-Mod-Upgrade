module AutoModUpgrade

@addField(PlayerPuppet) public let amuUpgrading: Bool;

@addMethod(PlayerPuppet)
public func AMU_CanUpgradeNow() -> Bool {
  if !IsDefined(this.amuConfig) || this.IsInCombat() || this.IsReplacer() {
    return false;
  };

  if GameInstance.GetWorkspotSystem(this.GetGame()).IsActorInWorkspot(this) {
    return false;
  };

  let uiSystem: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_System);
  if IsDefined(uiSystem) && uiSystem.GetBool(GetAllBlackboardDefs().UI_System.IsInMenu) {
    return false;
  };

  return true;
}

@addMethod(PlayerPuppet)
public func AMU_RunUpgradePass() -> Void {
  if this.amuUpgrading || !this.AMU_CanUpgradeNow() {
    return;
  };

  this.amuUpgrading = true;
  let ceiling: Int32 = this.AMU_QualityCeiling();
  // Each round lifts every group by one tier, so a full Common -> Legendary chain needs at most 4 rounds.
  let rounds: Int32 = 0;
  while rounds < 8 && this.AMU_UpgradeRound(ceiling) {
    rounds += 1;
  };
  this.amuUpgrading = false;
}

@addMethod(PlayerPuppet)
private func AMU_UpgradeRound(ceiling: Int32) -> Bool {
  let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGame());
  let items: array<wref<gameItemData>>;
  ts.GetItemList(this, items);

  let ids: array<TweakDBID>;
  let counts: array<Int32>;
  for item in items {
    if this.AMU_IsCandidate(item) {
      let id: TweakDBID = ItemID.GetTDBID(item.GetID());
      let index: Int32 = AMU_IndexOf(ids, id);
      if index < 0 {
        ArrayPush(ids, id);
        ArrayPush(counts, item.GetQuantity());
      } else {
        counts[index] = counts[index] + item.GetQuantity();
      };
    };
  };

  let upgraded: Bool = false;
  let i: Int32 = 0;
  while i < ArraySize(ids) {
    if counts[i] >= 2 && this.AMU_UpgradeGroup(ts, items, ids[i], counts[i], ceiling) {
      upgraded = true;
    };
    i += 1;
  };
  return upgraded;
}

@addMethod(PlayerPuppet)
private func AMU_UpgradeGroup(ts: ref<TransactionSystem>, items: array<wref<gameItemData>>, id: TweakDBID, count: Int32, ceiling: Int32) -> Bool {
  let recordName: String = TDBID.ToStringDEBUG(id);
  let tier: Int32 = AMU_GetTier(recordName);
  if tier < 0 || tier >= ceiling {
    return false;
  };

  let nextID: TweakDBID = AMU_NextTierID(recordName, tier);
  if !IsDefined(TweakDBInterface.GetItemRecord(nextID)) {
    return false;
  };

  let consumed: Int32 = this.AMU_Consume(ts, items, id, (count / 2) * 2);
  if consumed % 2 == 1 {
    ts.GiveItemByTDBID(this, id, 1);
  };

  let produced: Int32 = consumed / 2;
  if produced <= 0 {
    return false;
  };

  // Not flagged silent: vanilla PlayerPuppet.OnItemAddedToInventory shows the regular "Looted" message.
  return ts.GiveItemByTDBID(this, nextID, produced);
}

@addMethod(PlayerPuppet)
private func AMU_Consume(ts: ref<TransactionSystem>, items: array<wref<gameItemData>>, id: TweakDBID, amount: Int32) -> Int32 {
  let remaining: Int32 = amount;
  for item in items {
    if remaining <= 0 {
      break;
    };

    if IsDefined(item) && Equals(ItemID.GetTDBID(item.GetID()), id) {
      let itemID: ItemID = item.GetID();
      let quantity: Int32 = Min(item.GetQuantity(), remaining);
      if quantity > 0 {
        item.SetDynamicTag(n"SkipActivityLogOnRemove");
        if ts.RemoveItem(this, itemID, quantity) {
          remaining -= quantity;
        };
        if IsDefined(item) && ts.GetItemQuantity(this, itemID) > 0 {
          item.RemoveDynamicTag(n"SkipActivityLogOnRemove");
        };
      };
    };
  };
  return amount - remaining;
}

public func AMU_IndexOf(ids: array<TweakDBID>, id: TweakDBID) -> Int32 {
  let i: Int32 = 0;
  while i < ArraySize(ids) {
    if Equals(ids[i], id) {
      return i;
    };
    i += 1;
  };
  return -1;
}
