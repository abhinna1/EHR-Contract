// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "./DoctorContract.sol";

contract EHR is DoctorContract {
    // Structures.

    address public admin;

    struct Record {
        string file;
        Doctor doctor;
        string date;
    }

    struct Patient {
        address PatientAddress;
        string fullName;
        uint256 age;
        Record[] records;
        address[] approvedDoctors;
        address[] accessRequests;
    }

    mapping(address => Patient) public patients;
    address[] patinetAddresses;

    string[] GENDERS = ["Male", "Female"];

    modifier onlyPatient() {
        require(patients[msg.sender].age > 0, "Register first.");
        _;
    }

    function isPatient() public view returns (bool) {
        return patients[msg.sender].age > 0;
    }

    function isAdmin() public view returns(bool){
        return msg.sender==admin;
    }
    

    function registerPatient(
        string memory patientFullName,
        uint256 patientAge
    ) public {
        require((patients[msg.sender].age == 0), "Paitent already registered");
        require(
            bytes(patientFullName).length >= 4,
            "Patient name must be longer than 4 characters."
        );
        require(patientAge > 0, "Invalid age.");
        Patient storage newPatient = patients[msg.sender];
        newPatient.PatientAddress = msg.sender;
        newPatient.fullName = patientFullName;
        newPatient.age = patientAge;
        patinetAddresses.push(msg.sender);
    }

    function getSelfData() public view onlyPatient returns (Patient memory) {
        return patients[msg.sender];
    }

    function requestPatientAccess(address patient_address) public onlyDoctor {
        patients[patient_address].accessRequests.push(msg.sender);
        doctors[msg.sender].patientRequests.push(patient_address);
    }

    function getAllDoctorRequests()
        public
        view
        onlyPatient
        returns (Doctor[] memory)
    {
        Doctor[] memory doctor_list = new Doctor[](doctorAddresses.length);
        uint256 index = 0;

        for (uint256 i = 0; i < patinetAddresses.length; i++) {
            Patient memory current_patient = patients[patinetAddresses[i]];
            for (
                uint256 j = 0;
                j < current_patient.accessRequests.length;
                j++
            ) {
                Doctor memory current_doctor = doctors[
                    current_patient.accessRequests[j]
                ];
                doctor_list[index] = current_doctor;
                index++;
            }
        }

        return doctor_list;
    }

    function getApprovedRequestsAsDoctor()
        public
        view
        onlyDoctor
        returns (Patient[] memory)
    {
        // Get the doctor's address
        address doctorAddress = msg.sender;

        // Get the doctor's approved patients
        address[] memory approvedPatients = doctors[doctorAddress]
            .permittedPatients;

        // Create an array to store the approved patients
        Patient[] memory approvedPatientList = new Patient[](
            approvedPatients.length
        );
        uint256 index = 0;

        // Retrieve the patients from the approvedPatients list
        for (uint256 i = 0; i < approvedPatients.length; i++) {
            address patientAddress = approvedPatients[i];
            Patient memory patient = patients[patientAddress];
            approvedPatientList[index] = patient;
            index++;
        }

        return approvedPatientList;
    }

    function getPatientEHRs(
        address patientAddress
    ) public view onlyDoctor returns (Record[] memory) {
        // Get the doctor's address
        address doctorAddress = msg.sender;

        // Check if the doctor is authorized to access the patient's records
        address[] storage permittedDoctors = patients[patientAddress]
            .approvedDoctors;
        bool isPermittedDoctor = false;
        for (uint256 i = 0; i < permittedDoctors.length; i++) {
            if (permittedDoctors[i] == doctorAddress) {
                isPermittedDoctor = true;
                break;
            }
        }

        require(
            isPermittedDoctor,
            "You are not authorized to access this patient's records."
        );

        // Get the patient's records
        Record[] memory patientRecords = patients[patientAddress].records;

        return patientRecords;
    }

    // function acceptDoctorAccess(address doctorAddress) public onlyPatient {

    //     Patient memory current_patient = patients[msg.sender];
    //     Doctor memory current_doctor  = doctors[msg.sender];
    //     return current_doctor;
    // }

    // function getRequests(){}

    function isValidGender(string memory gender) private view returns (bool) {
        for (uint256 i = 0; i < GENDERS.length; i++) {
            if (
                keccak256(abi.encodePacked(GENDERS[i])) ==
                keccak256(abi.encodePacked(gender))
            ) return true;
        }
        return false;
    }

    // Constructor

    constructor() {
        admin = msg.sender;
    }

    // Modifiers

    modifier onlyAdmin() {
        require(msg.sender == admin, "Forbidden.");
        _;
    }

    modifier onlyDoctor() {
        require(
            doctors[msg.sender].age > 0,
            "Only doctors can acess this resource."
        );
        _;
    }

    modifier onlyHospital() {
        require(bytes(hospitals[msg.sender].name).length > 0);
        _;
    }

    // Hospital Functions.
    function addHospital(
        address hospital_address,
        string memory name,
        string memory location,
        string memory description,
        string memory image
    ) public onlyAdmin returns (Hospital memory) {
        // Check if hospital already exiusts
        require(
            bytes(hospitals[hospital_address].name).length == 0,
            "Hospital already exists"
        );
        // Check if name is valid.
        require(bytes(name).length > 0, "Invalid name.");
        // Check if location is valid.
        require(bytes(location).length > 0, "Invalid location.");

        Hospital memory new_hospital = Hospital({
            hospitalAddress: hospital_address,
            name: name,
            location: location,
            description: description,
            image: image
        });
        hospitals[hospital_address] = new_hospital;
        hospital_count++;
        hospitalAddresses.push(hospital_address);
        return new_hospital;
    }

    function get_hospital_count() public view returns (uint256) {
        return hospital_count;
    }

    function getAllHospitals() public view returns (Hospital[] memory) {
        Hospital[] memory all_hospitals = new Hospital[](
            hospitalAddresses.length
        );

        for (uint256 i = 0; i < hospitalAddresses.length; i++) {
            address curr_address = hospitalAddresses[i];
            all_hospitals[i] = hospitals[curr_address];
        }

        return all_hospitals;
    }

    function approveEHRRequest(address doctorAddress) public onlyPatient {
        require(
            patients[msg.sender].age > 0,
            "Only registered patients can approve EHR requests."
        );
        require(
            doctors[doctorAddress].age > 0,
            "Invalid doctor address, only registered doctors can request access."
        );

        // Check if the requesting doctor is in the access requests list of the patient
        address[] storage accessRequests = patients[msg.sender].accessRequests;
        bool isRequestedDoctor = false;
        for (uint256 i = 0; i < accessRequests.length; i++) {
            if (accessRequests[i] == doctorAddress) {
                isRequestedDoctor = true;
                break;
            }
        }

        require(
            isRequestedDoctor,
            "The requesting doctor is not in the access requests list."
        );

        // Add the doctor to the approvedDoctors list
        address[] storage approvedDoctors = patients[msg.sender]
            .approvedDoctors;
        for (uint256 i = 0; i < approvedDoctors.length; i++) {
            if (approvedDoctors[i] == doctorAddress) {
                revert("Access already granted.");
            }
        }
        approvedDoctors.push(doctorAddress);

        // Remove the doctor from the accessRequests list
        for (uint256 i = 0; i < accessRequests.length; i++) {
            if (accessRequests[i] == doctorAddress) {
                // Swap and pop technique to efficiently remove the element
                accessRequests[i] = accessRequests[accessRequests.length - 1];
                accessRequests.pop();
                break;
            }
        }

        // Remove the doctor from the accessRequests list
        removeFromPatientRequests(doctorAddress, msg.sender);

        // Add the patient to the permittedPatients list of the doctor
        addToPermittedPatients(doctorAddress, msg.sender);
    }

    function revokeDoctorAccess(address doctorAddress) public onlyPatient {
        require(
            patients[msg.sender].age > 0,
            "Only registered patients can revoke doctor access."
        );
        require(
            doctors[doctorAddress].age > 0,
            "Invalid doctor address, only registered doctors can have access revoked."
        );

        // Check if the doctor is in the approved doctors list of the patient
        address[] storage approvedDoctors = patients[msg.sender]
            .approvedDoctors;
        bool isApprovedDoctor = false;
        uint256 approvedDoctorIndex;

        for (uint256 i = 0; i < approvedDoctors.length; i++) {
            if (approvedDoctors[i] == doctorAddress) {
                isApprovedDoctor = true;
                approvedDoctorIndex = i;
                break;
            }
        }

        require(isApprovedDoctor, "The doctor does not have access.");

        // Remove the doctor from the approvedDoctors list
        approvedDoctors[approvedDoctorIndex] = approvedDoctors[
            approvedDoctors.length - 1
        ];
        approvedDoctors.pop();

        // Remove the patient from the permittedPatients list of the doctor
        removeFromPermittedPatients(doctorAddress, msg.sender);
    }

    function insertEHRRecord(
        address patientAddress,
        string memory file,
        string memory date
    ) public onlyDoctor {
        // Check if the doctor is authorized to access the patient's records
        // address[] storage permittedPatients = doctors[msg.sender].permittedPatients;
        address[] storage permittedDoctors = patients[patientAddress]
            .approvedDoctors;
        bool isPermittedPatient = false;
        for (uint256 i = 0; i < permittedDoctors.length; i++) {
            if (permittedDoctors[i] == msg.sender) {
                isPermittedPatient = true;
                break;
            }
        }

        require(
            isPermittedPatient,
            "You are not authorized to access this patient's records."
        );

        // Get the patient's records
        Record[] storage patientRecords = patients[patientAddress].records;

        // Create a new record
        Record memory newRecord = Record({
            file: file,
            doctor: doctors[msg.sender],
            date: date
        });

        // Add the new record to the patient's records
        patientRecords.push(newRecord);
    }

    // function getApprovedDoctors() public returns (Doctor[] memory){
    //     return doctors[msg.sender].doc
    // }

    // Doctor Functions.
    function addDoctor(
        address doctor_address,
        string memory firstname,
        string memory lastname,
        uint256 age,
        string memory gender,
        string memory description,
        string memory image,
        string memory specialization
    ) public onlyHospital returns (Doctor memory) {
        // Check if doctor already exists.
        require(doctors[doctor_address].age == 0, "Doctor already exists.");
        require(bytes(firstname).length > 4, "Invalid first name.");
        require(bytes(lastname).length > 4, "Invalid last name.");
        require(age > 0, "Invalid age.");
        require(isValidGender(gender), "Invalid Gender");

        Doctor memory new_doctor = Doctor({
            doctorAddress: doctor_address,
            firstName: firstname,
            lastName: lastname,
            age: age,
            gender: gender,
            specialization: specialization,
            description: description,
            image: image,
            hospital: hospitals[msg.sender],
            permittedPatients: new address[](0),
            patientRequests: new address[](0)
        });
        doctors[doctor_address] = new_doctor;
        doctor_count++;
        doctorAddresses.push(doctor_address);
        return new_doctor;
    }

    function get_doctor_count() public view returns (uint256) {
        return doctor_count;
    }

    function get_doctor_by_address(
        address doctorAddress
    ) public view returns (Doctor memory) {
        return doctors[doctorAddress];
    }

    function get_doctors_by_hospital(
        address hospitalAddress
    ) public view returns (Doctor[] memory) {
        uint256 doctorsInHospitalCount = 0;

        // Count the number of doctors in the given hospital
        for (uint256 i = 0; i < doctorAddresses.length; i++) {
            if (
                doctors[doctorAddresses[i]].hospital.hospitalAddress ==
                hospitalAddress
            ) {
                doctorsInHospitalCount++;
            }
        }

        // Create an array to store the doctors in the hospital
        Doctor[] memory doctorsInHospital = new Doctor[](
            doctorsInHospitalCount
        );
        uint256 currentIndex = 0;

        // Retrieve the doctors in the given hospital
        for (uint256 i = 0; i < doctorAddresses.length; i++) {
            address doctorAddress = doctorAddresses[i];
            Doctor memory doctor = doctors[doctorAddress];
            if (doctor.hospital.hospitalAddress == hospitalAddress) {
                doctorsInHospital[currentIndex] = doctor;
                currentIndex++;
            }
        }

        return doctorsInHospital;
    }

    function get_hospital_by_address(
        address hospitalAddress
    ) public view returns (Hospital memory) {
        return hospitals[hospitalAddress];
    }

    function is_doctor() public view returns (bool) {
        if (doctors[msg.sender].age != 0) return true;
        return false;
    }

    function is_admin() public view returns (bool) {
        if (msg.sender == admin) return true;
        return false;
    }

    function is_hospital() public view returns (bool) {
        return bytes(hospitals[msg.sender].name).length > 0;
    }
}
