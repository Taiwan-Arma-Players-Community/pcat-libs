/*
    spawnGarrison
    _center
    _units
    _has_patrol
    _side
[
    getMarkerPos _m1,
    [
        "rhs_msv_emr_sergeant",
        "rhs_msv_emr_rifleman",
        "rhs_msv_emr_machinegunner",
        "rhs_msv_emr_medic",
        "rhs_msv_emr_marksman"
    ],
    true,
] call PCAT_fnc_spawnGarrison;
*/

/*
_group    the group <GROUP, OBJECT>
_position    centre of area to defend <ARRAY, OBJECT, LOCATION, GROUP> (Default: _group)
_radius    r


_hold    c
*/
params [
    ["_center"],
    ["_units_list"],            
    ["_radius", 50],            // Radius of area to defend <NUMBER> (Default: 50)
    ["_side", opfor],           // Side of group to garrison.
    ["_patrol_chance", 0.2],    // Chance for each unit to patrol instead of garrison, true for default, false for 0% <NUMBER, BOOLEAN> (Default: 0.1)
    ["_threshold", 3],          // Minimum building positions required to be considered for garrison <NUMBER> (Default: 3)
    ["_hold", 0.33]             // Chance for each unit to hold their garrison in combat, true for 100%, false for 0% <NUMBER, BOOLEAN> (Default: 0)
];

private _spawn_pos = _center call CBA_fnc_getPos;

private _grp = [
    _spawn_pos,
    _side,
    _units_list
] call BIS_fnc_spawnGroup;

[
    _grp,
    _spawn_pos,
    _radius,
    _threshold,
    _patrol_chance,
    _hold
] call CBA_fnc_taskDefend;
