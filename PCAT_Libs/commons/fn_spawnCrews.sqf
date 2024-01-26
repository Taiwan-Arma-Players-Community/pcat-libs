/*
    註解使用中文
*/

params [
    "_veh",         // <OBJECT> vehicle to spawn crew for
    ["_grp_or_side","",["",grpNull, sideEmpty]],         // <GROUP> group to add crew to
    ["_crew_type",[""],[[]]]   // <ARRAY> of <STRING> crew types to spawn : ["","driver","commander","gunner","turret","cargo"];
];
if( _grp_or_side isNotEqualTo (group _veh) ) exitWith { grpNull };

private _veh_type        = typeOf _veh;
private _config_entry    = configFile >> "CfgVehicles" >> _veh_type;

private _side            = getNumber(_config_entry >> "side" ) call BIS_fnc_sideType;
private _crew_grp;

switch( typeName _grp_or_side) do {
    case "SIDE": {
        _side      = _grp_or_side;
        _crew_grp  
    };
    case "GROUP": {
        _crew_grp  = _grp_or_side;
    };
    default:{
        _side      = getNumber(_config_entry >> "side" ) call BIS_fnc_sideType;
        _crew_grp  = if( isNull (group _veh) ) then { createGroup [_side, true] } else { group _veh };
    };
};

private _crew_seats_path = _veh_type call BIS_fnc_vehicleCrewTurrets;

private _commander_map   = createHashMap;
// Find and get commander seat.
{
    
    private _turret_path = _x;
    private _turret_config = [_veh,_turret_path] call BIS_fnc_turretConfig;
    _commander_map set [getNumber( _turret_config >> "commanding" ), _turret_path];    
    
} foreach _crew_seats_path;

private _commander_path = if( selectMax ( keys _commander_map) > -1) then {
    _commander_map get ( selectMax ( keys _commander_map) )
} else {
    // Default: driver as leader.
    [-1]
};


private _crew_type    = getText ( _config_entry >> "crew" );
{
    private _turret_path = _x;
    private _turret_config = [_veh,_turret_path] call BIS_fnc_turretConfig;

    // Get unit's type.
    private _gunner_type = getText( ([_veh_type, _turret_path] call BIS_fnc_turretConfig) >> "gunnerType");
    if( isNil _gunner_type ) then {
        _gunner_type = _crew_type;
    };

    private _unit = _crew_grp createUnit [_gunner_type, [0,0,0], [], 0, "CAN_COLLIDE"];

    // Only driver can't use moveInTurret command.
    if( _turret_path isEqualTo [-1] ) then {
        _unit moveInDriver _veh;
    } else {
        _unit moveInTurret [_veh,_turret_path];
    };

    // Assign leader.
    if ( _turret_path isEqualTo _commander_path ) then {
         _grp selectLeader _unit;
    };

} forEach _crew_seats_path;


_grp
