/* ----------------------------------------------------------------------------
    Function: PCAT_fnc_assignCurator

    Description:
        將指定的玩家設定為宙斯

    Parameters:
        unit           - <STRING>

    Optional:

    Returns:
        <BOOL>         - true, if function is successed.

    Author:
        Peckcat

    Examples:
        player call PCAT_fnc_assignCurator;


---------------------------------------------------------------------------- */

params ["_player"];

// 檢查 _unit 是否為玩家控制角色
// if ( !isPlayer _unit) exitwith { false };

if (isNil "PCAT_zeus_group") then {
    missionNamespace setVariable ["PCAT_zeus_group", createGroup sideLogic];
};

"ModuleCurator_F" createUnit [
    [0,0],            
    PCAT_zeus_group,
    format [
        "(%1) assignCurator this;
        this setVariable ['BIS_fnc_initModules_disableAutoActivation', false, true];",
        _player
    ]
];

true