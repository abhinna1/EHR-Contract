// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract EHR {
    // Structures.

    address public admin;

    struct Hospital {
        address hospitalAddress;
        string name;
        string location;
        string description;
        string image;
    }

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
    }

    // Mapping to store doctors by their address
    mapping(address => Doctor) public doctors;
    address[] public doctorAddresses;
    uint256 doctor_count = 0;
    // Mapping to store hospitals by their address
    mapping(address => Hospital) public hospitals;
    address[] public hospitalAddresses;
    uint256 hospital_count = 0;

    string[] GENDERS = ["Male", "Female"];

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
            hospital: hospitals[msg.sender]
        });
        doctors[doctor_address] = new_doctor;
        doctor_count++;
        doctorAddresses.push(doctor_address);
        return new_doctor;
    }

    function get_doctor_count() public view returns (uint256) {
        return doctor_count;
    }

    function get_doctor_by_address(address doctorAddress)
        public
        view
        returns (Doctor memory)
    {
        return doctors[doctorAddress];
    }

    function get_doctors_by_hospital(address hospitalAddress)
        public
        view
        returns (Doctor[] memory)
    {
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

    function get_hospital_by_address(address hospitalAddress)
        public
        view
        returns (Hospital memory)
    {
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
