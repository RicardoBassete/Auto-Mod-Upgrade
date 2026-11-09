# 0001 - REDscript + Mod Settings em vez de Cyber Engine Tweaks

## Status

Aceito

## Contexto

O mod precisa de configuração in-game (Quality Ceiling e toggles) e de detectar outros mods instalados para ativar features de compatibilidade. Entre as referências, o Auto Component Upgrade é escrito em Lua sobre o Cyber Engine Tweaks (CET), com configuração por variáveis editadas à mão; o Smarter Scrapper é escrito em REDscript e usa Mod Settings e `@if(ModuleExists(...))`.

## Decisão

Escrever o mod em REDscript, com Mod Settings para configuração. CET não é dependência.

## Consequências

- Configuração no menu do jogo, sem editar arquivos.
- Compatibilidade com outros mods REDscript resolvida em tempo de compilação via `ModuleExists`, sem custo em runtime quando o outro mod não está instalado.
- Intervalo periódico e detecção de combate precisam ser reimplementados em REDscript (DelaySystem e estado do PlayerPuppet), em vez de usar o `onUpdate` do CET.
- Um erro de compilação em REDscript impede o carregamento de todos os scripts do jogador, então só APIs já usadas por mods de referência devem ser adotadas sem teste.
