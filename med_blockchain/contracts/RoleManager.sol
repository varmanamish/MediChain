// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RoleManager {

    enum Role { MANUFACTURER, DISTRIBUTOR, PHARMACY, END_USER, NONE }

    mapping(address => Role) private roles;

    address public admin;

    event RoleAssigned(address indexed account, Role role);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function assignRole(address _account, Role _role) public onlyAdmin {
        require(_role != Role.NONE, "Invalid role");
        roles[_account] = _role;
        emit RoleAssigned(_account, _role);
    }

    function getRole(address _account) public view returns (Role) {
        return roles[_account];
    }

    function isManufacturer(address _account) public view returns (bool) {
        return roles[_account] == Role.MANUFACTURER;
    }

    function isDistributor(address _account) public view returns (bool) {
        return roles[_account] == Role.DISTRIBUTOR;
    }

    function isPharmacy(address _account) public view returns (bool) {
        return roles[_account] == Role.PHARMACY;
    }

    function isEndUser(address _account) public view returns (bool) {
        return roles[_account] == Role.END_USER;
    }
}
