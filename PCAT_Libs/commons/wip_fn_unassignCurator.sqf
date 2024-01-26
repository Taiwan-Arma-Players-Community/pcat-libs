/* ----------------------------------------------------------------------------
    Function: PCAT_fnc_unassignCurator

    Description:
        移除指定的玩家的宙斯權限

    Parameters:
        unit           - <STRING>

    Optional:

    Returns:
        <BOOL>         - true, if function is successed.

    Author:
        Peckcat

    Examples:
        player call PCAT_fnc_unassignCurator;


---------------------------------------------------------------------------- */

params ["_player"];

// 檢查 _unit 是否為玩家控制角色
// if ( !isPlayer _unit) exitwith { false };


unassignCurator (getAssignedCuratorLogic player);

true