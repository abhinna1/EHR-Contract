// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract HospitalContract {
    struct Hospital {
        address hospitalAddress;
        string name;
        string location;
        string description;
        string image;
    }

    // Mapping to store hospitals by their address
    mapping(address => Hospital) public hospitals;
    address[] public hospitalAddresses;
    uint256 hospital_count = 0;

    function isHospital() public view returns (bool) {
        return bytes(hospitals[msg.sender].name).length > 0;
    }
}
