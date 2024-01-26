# PCAT_Libs

這個庫包含了一些自用的 Arma 3 腳本函式，可以幫助開發者更快速地開發 Arma 3 遊戲。

## 版本

None.

## 簡介

這個庫包含了一些自用的 Arma 3 腳本函式，主要為協助自己更快速地開發 Arma 3 任務。
這些函式包括了各種不同的功能，例如指定玩家角色為宙斯、清除地圖上的所有物件和單位等等。

## 如何使用

1. 下載 `PCAT_Libs` 庫。
2. 在你的 Arma 3 遊戲中，將 `PCAT_Libs` 資料夾放置在 `任務資料夾的最上層`中。
3. 在`description.ext`中，使用以下指令引入。

```sqf
#include "PCAT_Libs\define.hpp"
class CfgFunctions   //  CfgFunctions 只能一個，如果有重複的，再自行合併
{
    #include "PCAT_Libs\cfgFunctions.hpp"
};
```

## 目前有以下函式

- `getPrefixVariables`

這個函式的功能是給予一個前綴字串，並取得有指定前綴的所有變數(Variable)。

- `getPrefixMarkers`

這個函式的功能是給予一個前綴字串，並取得指定前綴的所有地圖標示(Marker)。

- `infReinforcement`

這個函式的功能是在 Arma 3 遊戲中生成指定的敵軍增援。

- `removeAllEquips`

這個函式的功能是移除一個單位身上的所有裝備，只保留或指定的制服。

- `cleanUp`

這個函式的功能是清除地圖上冗餘物件和單位；減少運算需求，進而提昇運算效率。

- `parachuting`

這個函式的功能是讓指定的單位進行跳傘。

- `parachutingDialog`

這個函式的功能是顯示一個跳傘介面，讓玩家可以簡單的選擇跳傘的高度和位置。

- `assignCurator`

這個函式的功能是將一個玩家角色指定為宙斯。這個函式可以幫助你在遊戲中進行一些特殊的挑戰，例如讓玩家成為宙斯。

- `unassignCurator`

這個函式的功能是取消一個玩家角色的宙斯身份。這個函式可以幫助你在遊戲中進行一些特殊的挑戰，例如取消玩家的宙斯身份。

