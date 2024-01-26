/* ----------------------------------------------------------------------------
    Function: PCAT_fnc_infReinforcement

    Description:
        依照清單生成增援小隊並前往目標。
        若有提供載具，則生成足夠數量載具。

    Parameters:
        _position          - 生成地點 <MARKER, OBJECT, LOCATION, GROUP, TASK, WAYPOINT or POSITION>
        _target            - 目標地點 <MARKER, OBJECT, LOCATION, GROUP, TASK, WAYPOINT or POSITION>
        _units_list        - 小隊成員的 classname 清單 <ARRAY>

    Optional:
        _vehicle_type      - default: "",   小隊配置的載具 classname <STRING or [STRING,[ARRAY]]>
        _vehicle_crew_type - default: "",
        _drop_radius       - default: 100,  載具釋放半徑
        _vehicle_init      - default: [],   設置載具初始值，如塗裝等
        _is_berserkers     - default: true, 小隊成員是否為狂戰士，無視逃逸值/體力值等 <BOOL>
        _side              - default: east, 小隊所屬的陣營 <SIDE>

    Returns:
        <HASHMAP>
        [
            "infGrp",  <GROUP>
            "vehGrps", <ARRAY of GROUP>
        ]

    Author:
        Peckcat

    Examples:
        _units = [
            "rhs_msv_emr_sergeant",
            "rhs_msv_emr_rifleman",
            "rhs_msv_emr_machinegunner",
            "rhs_msv_emr_medic",
            "rhs_msv_emr_marksman"
        ];
        [pos_0, pos_4, _units,  "rhs_gaz66_msv"] call PCAT_fnc_infReinforcement;

---------------------------------------------------------------------------- */
params [
     "_from",
     "_to",
     "_units_list",

    ["_vehicle_type"     , ""  , [""]   ],
    ["_vehicle_crew_type", ""  , [""]   ],
    ["_drop_radius"      , 150 , [0]    ],
    ["_vehicle_init"     , []  , []     ],
    ["_is_berserker"     , true, [true] ],
    ["_side"             , east, [east] ]
];

//  轉換生成點、目的地的座標
private _spawn_pos  = _from call CBA_fnc_getPos;
private _target_pos = _to   call CBA_fnc_getPos;


private _inf_grop  = grpNull;
private _veh_groups = [];


//  生成步兵班
private _inf_grop = [
    _spawn_pos,
    _side,
    _units_list
] call BIS_fnc_spawnGroup;               //  依照參數建立 Group


_inf_grop deleteGroupWhenEmpty true;          //  當 Group 全滅為空後，刪除 Group，以避免 Group 數量達到上限

//  若提供載具，則生成載具並移動至載具上
if ( !(_vehicle_type isEqualTo "") ) then {

    private _veh = objNull;
    {
        // 當載具不存在/滿員，則再生成一輛，並設置運輸邏輯
        if( (_veh emptyPositions "Cargo") == 0 ) then {
            _veh = _vehicle_type createVehicle _spawn_pos;
            _veh setUnloadInCombat [true,false];

            // 設定客製初始化載具
            if (  _vehicle_init isNotEqualTo [] ) then {
                _vehicle_init params [
                    "_variant",
                    "_animations"
                ];
                [
                    _veh, _variant, _animations
                ] call BIS_fnc_initVehicle;
            };

            // 生成載具乘組員

            // Mode 1
            /*
            private _veh_dummy_grp = createGroup [_side, true];
            private _veh_grp =  createGroup [_side, true]; 

            [_veh,_veh_dummy_grp, false, "", _vehicle_crew_type] call BIS_fnc_spawnCrew;
            (units _veh_dummy_grp) joinSilent _veh_grp;
            */ 

            // Mode 2
            private _veh_grp =  createGroup [_side, true]; 
            
            _veh_groups pushback _veh_grp;

            [
                _veh_grp,                            //  Groups
                _target_pos,                     //  Target Position
                50,                               //  Radius
                "TR UNLOAD",                        //  Waypoint Type
                "AWARE",                         //  Behaviour
                "YELLOW",                        //  Combat Mode
                "FULL",                        //  Waypoint Speed
                "FILE",                          //  Formation
                "
                    private _cargo_units = [];
                    private _cargo_grp = grpNull;

                    {
                        _cargo_units pushback (_x#0);
                    }foreach ( fullCrew [vehicle this,'cargo'] );
                    _cargo_grp = group (_cargo_units#0);

                    if( (allTurrets [vehicle this, false]) isEqualTo [] ) then {
                        thisList join _cargo_grp;
                    };
                    doGetOut _cargo_units;
                    _cargo_grp leaveVehicle (vehicle this);
                    
                ",  //  運送到指定地點後，強制放下乘客，以避免乘客不下車
                    //  若車輛無武裝，則讓乘組員下車，並加入被運輸的 Group
                [0, 0, 0],
                _drop_radius
            ] call CBA_fnc_addWaypoint;

            //  若車輛具有武裝而『沒有』在前一個 Waypoint 被併入乘客的 Group，則在放下乘客後，開始進行 哨兵
            [
                _veh_grp,                      //  Groups
                _target_pos,                   //  Target Position
                -1,                            //  Radius
                "SENTRY",                         //  Waypoint Type
                "AWARE",                       //  Behaviour
                "YELLOW",                      //  Combat Mode
                "NORMAL",                      //  Waypoint Speed
                "FILE",                         //  Formation
                "",
                [0,0,0],
                _drop_radius
            ] call CBA_fnc_addWaypoint;

             _veh engineOn true;
        };

        _x assignAsCargo _veh;
        _x moveInCargo   _veh;                 //  將部隊移動到載具上
    } foreach (units _inf_grop);

};


//  步兵班能力職
if ( _is_berserker ) then {
    {
        _x allowFleeing 0;               //  設置為不可逃逸
        _x enableStamina false;          //  設置為無體力上限

        _x disableAI "SUPPRESSION";      //  設置為不受壓制
        //_X disableAI "COVER";          //  設置為不找掩護
    } foreach (units _inf_grop);
};

//  設定步兵班步行目標
[
    _inf_grop,                            //  Groups
    _target_pos,                     //  Target Position
    0,                               //  Radius
    "SAD",                           //  Waypoint Type
    "COMBAT",                        //  Behaviour
    "RED",                        //  Combat Mode
    "FULL",                          //  Waypoint Speed
    "FILE"                           //  Formation
] call CBA_fnc_addWaypoint;

private _grp_hash_map = createHashMapFromArray [ ["infGrp",_inf_grop], ["vehGrps", _veh_groups] ];

_grp_hash_map