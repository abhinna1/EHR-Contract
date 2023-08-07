// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "./HospitalContract.sol";
contract DoctorContract is HospitalContract{
    struct Doctor {
        address doctorAddress;
        string firstName;
        string lastName;
        uint256 age;
        string gender;
        string specialization;
        string image;
        string description;
        Hospital hospital;

        address[] permittedPatients;
        address[] patientRequests;
    }

    mapping(address => Doctor) public doctors;
    address[] public doctorAddresses;
    uint256 doctor_count = 0;
}