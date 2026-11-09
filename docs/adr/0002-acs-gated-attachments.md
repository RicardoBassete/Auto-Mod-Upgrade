# 0002 - Weapon Attachments só com o Attachments Crafting System

## Status

Aceito

## Contexto

No jogo vanilla (2.0+), Weapon Attachments não têm variantes por Quality Tier que possam ser combinadas 2 para 1. O Attachments Crafting System (ACS) cria essas variantes (`_Common` ... `_Legendary`), marca-as com a tag `CraftableAndUpgradableScopes` e define a receita "2 do tier anterior geram 1 do próximo".

A alternativa seria o Auto Mod Upgrade criar suas próprias variantes por tier e receitas para attachments via TweakXL.

## Decisão

O Auto Upgrade de Weapon Attachments só existe quando o módulo `AttachmentsCraftingSystem` está presente. Sem ele, attachments são ignorados e a opção correspondente não aparece no Mod Settings. O Auto Mod Upgrade não define variantes nem receitas de attachments.

## Consequências

- Nenhuma duplicação das TweakDB records do ACS e nenhum conflito de receitas.
- A identificação de attachments elegíveis depende da tag e dos sufixos de tier definidos pelo ACS; se o ACS mudar essa convenção, a compatibilidade quebra.
- Jogadores sem ACS só recebem o Auto Upgrade de Weapon Stat Mods.
