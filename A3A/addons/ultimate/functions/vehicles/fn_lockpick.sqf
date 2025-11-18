/*
    Author:
        Maxx, Silence
    
    Description:
        Adds the action to lockpick a vehicle locally
    
    Params:
        _vehicle <OBJECT>
    
    Dependencies:
        vehicleLockpickTime
    
    Scope:
        Client
    
    Environment:
        Unscheduled
    
    Usage:
        [_vehicle] call A3U_fnc_lockpick;
    
    Return:
        N/A
*/

params ["_vehicle"];

private _vehicleType = typeOf _vehicle;
private _factionData = missionNamespace getVariable ["A3A_faction_all", createHashMap];
private _tanks = _factionData getOrDefault ["vehiclesTanks", []];
private _apcs = _factionData getOrDefault ["vehiclesAPCs", []];
private _isTank = _vehicleType in _tanks;
private _isAPC = _vehicleType in _apcs;

[format ["Lockpick request for %1 | tank=%2 | apc=%3", _vehicleType, _isTank, _isAPC], _fnc_scriptName] call A3U_fnc_log;

// Skip heavy armor, keep lockpicks for cars/helis/jets
if (_isTank || {_isAPC}) exitWith {
    [format ["Skipping lockpick action for %1 (heavy armor)", _vehicleType], _fnc_scriptName] call A3U_fnc_log;
};

private _existingActionId = _vehicle getVariable ["A3U_lockpickActionId", -1];
if (_existingActionId != -1) then {
    [_vehicle, _existingActionId] call BIS_fnc_holdActionRemove;
    [format ["Removed old lockpick action from %1 (id %2)", _vehicleType, _existingActionId], _fnc_scriptName] call A3U_fnc_log;
};

private _actionId = [ 
    _vehicle,
    localize "STR_A3AU_action_lockpick_title",
    "\a3\ui_f\data\igui\cfg\actions\repair_ca.paa",
    "\a3\ui_f\data\igui\cfg\actions\repair_ca.paa",
    "(_this distance _target < 10) && {alive _target} && {_target call A3U_fnc_isLocked}",
    "(_caller distance _target < 10) && {_caller call A3A_fnc_isEngineer}",
    {
        params ["_target", "_caller", "_actionId", "_arguments"];

        // private _closestZone = (sidesX getVariable [([call A3U_fnc_lockpickZones, _caller] call BIS_fnc_nearestPosition), sideUnknown]);
        // if (_closestZone isEqualTo teamPlayer) exitWith {
        //     [_target, _actionId] call BIS_fnc_holdActionRemove;
        //     [_target, false] remoteExecCall ["A3U_fnc_setLock", (owner _target)];
        // };
        // Re-enable if instant lockpicking after capture is desired

        if !(_caller call A3A_fnc_isEngineer) then {
            [localize "STR_A3AU_action_lockpick_title", localize "STR_A3AU_action_lockpick_not_engineer"] call A3A_fnc_customHint;
        };
    },
    {
        params ["_target", "_caller", "_actionId", "_arguments", "_frame", "_maxFrame"];

        [_target, _caller, _actionId, _frame, _maxFrame] call A3U_fnc_lockpickOnProgress;
    },
    {
        params ["_target", "_caller", "_actionId", "_arguments"];

        [_target, _caller, _actionId] call A3U_fnc_lockpickOnSuccess;
    },
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        
        [_target, _caller] call A3U_fnc_lockpickOnFail;
    },
    [],
    vehicleLockpickTime,
    2026,
    false,
    false
] call BIS_fnc_holdActionAdd;

[format ["Lockpick hold action added to %1 with id %2", _vehicleType, _actionId], _fnc_scriptName] call A3U_fnc_log;
_vehicle setVariable ["A3U_lockpickActionId", _actionId];
[format ["Stored lockpick action id %1 on %2", _actionId, _vehicleType], _fnc_scriptName] call A3U_fnc_log;
[format ["Lockpick hold action added to %1 with id %2", _vehicleType, _actionId], _fnc_scriptName] call A3U_fnc_log;
