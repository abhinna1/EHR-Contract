// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "./HospitalContract.sol";

contract DoctorContract is HospitalContract {
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



    function removeFromPatientRequests(
        address doctorAddress,
        address patientAddress
    ) internal {
        address[] storage patientRequests = doctors[doctorAddress]
            .patientRequests;
        for (uint256 i = 0; i < patientRequests.length; i++) {
            if (patientRequests[i] == patientAddress) {
                // Swap and pop technique to efficiently remove the element
                patientRequests[i] = patientRequests[
                    patientRequests.length - 1
                ];
                patientRequests.pop();
                break;
            }
        }
    }

    function addToPermittedPatients(
        address doctorAddress,
        address patientAddress
    ) internal {
        doctors[doctorAddress].permittedPatients.push(patientAddress);
    }

    function removeFromPermittedPatients(
        address doctorAddress,
        address patientAddress
    ) public {
        address[] storage permittedPatients = doctors[doctorAddress]
            .permittedPatients;

        for (uint256 i = 0; i < permittedPatients.length; i++) {
            if (permittedPatients[i] == patientAddress) {
                permittedPatients[i] = permittedPatients[
                    permittedPatients.length - 1
                ];
                permittedPatients.pop();
                break;
            }
        }
    }
    

}
