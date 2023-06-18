// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract EHR {

    // Structures.

    address public admin;

    struct Hospital {
        string name;
        string location;
    }
    
    struct Doctor {
        string firstName;
        string lastName;
        uint age;
        string gender;
        string specialization;
        Hospital hospital;
    }

    // Mapping to store doctors by their address
    mapping(address => Doctor) public doctors;
    uint doctor_count = 0;
    // Mapping to store hospitals by their address
    mapping(address => Hospital) public hospitals;
    uint hospital_count = 0;

    string[] GENDERS = [
      "Male",
      "Female"
    ];

    function isValidGender(string memory gender) private view returns (bool){
      for (uint i=0; i<GENDERS.length; i++){
        if (
          keccak256(abi.encodePacked(GENDERS[i])) == keccak256(abi.encodePacked(gender))
        ) return true ;
      }
      return false;
    }

    // Constructor

    constructor(){
        admin = msg.sender;
    }


    // Modifiers

    modifier onlyAdmin{
        require(msg.sender == admin, "Forbidden.");
        _;
    }

    modifier onlyDoctor{
        require(doctors[msg.sender].age > 0, "Only doctors can acess this resource.");
        _;
    }

    modifier onlyHospital{
      require(bytes(hospitals[msg.sender].name).length > 0);
      _;
    }

    function isDoctor() public view returns(Doctor memory){
        return doctors[msg.sender];
    }


// Hospital Functions.
  function addHospital(
    address hospital_address,
    string memory name,
    string memory location
  ) onlyAdmin public returns (Hospital memory) {
    // Check if hospital already exiusts
    require(
      bytes(hospitals[hospital_address].name).length == 0,
      "Hospital already exists"
    );
    // Check if name is valid.
    require(
      bytes(name).length > 0,
      "Invalid name."
    );
    // Check if location is valid.
    require(
      bytes(location).length > 0,
      "Invalid location."
    );

    
    Hospital memory new_hospital = Hospital(
      {
        name:name,
        location: location
      }
    );
    hospitals[hospital_address] = new_hospital;
    hospital_count++;
    return new_hospital;
  }

  function get_hospital_count() public view returns (uint){
      return hospital_count;
  }


// Doctor Functions.
    function addDoctor(
      address doctor_address,
      string memory firstname,
      string memory lastname,
      uint age,
      string memory gender,
      string memory specialization,
      address hospital
    ) public onlyHospital returns (Doctor memory){
        // Check if doctor already exists.
        require(
          doctors[msg.sender].age == 0,
          "Doctor already exists."
        );
        require(
          bytes(firstname).length > 4,
          "Invalid first name."
        );
        require(
          bytes(lastname).length > 4,
          "Invalid last name."
        );
        require(
          age > 0,
          "Invalid age."
        );
        require(
          isValidGender(gender),
          "Invalid Gender"
        );

        Doctor memory new_doctor = Doctor(
          {
            firstName: firstname,
            lastName: lastname,
            age: age,
            gender: gender,
            specialization: specialization,
            hospital: hospitals[hospital]
          }
        );
        doctors[doctor_address] = new_doctor;
        doctor_count ++;
        return new_doctor;
    }

    function get_doctor_count() public view returns (uint){
      return doctor_count;
    }

    function get_all_doctors() public view returns (Doctor[] memory) {
    uint256 numDoctors = doctor_count;
    address[] memory doctorAddresses = new address[](numDoctors);
    
    // Count the number of doctors
    for (uint256 i = 0; i < doctorAddresses.length; i++) {
        if (doctors[doctorAddresses[i]].age > 0) {
            numDoctors++;
        }
    }
    
    // Create an array to store all doctors
    Doctor[] memory allDoctors = new Doctor[](numDoctors);
    
    // Populate the array with doctors
    uint256 index = 0;
    for (uint256 i = 0; i < doctorAddresses.length; i++) {
        address doctorAddress = doctorAddresses[i];
        if (doctors[doctorAddress].age > 0) {
            allDoctors[index] = doctors[doctorAddress];
            index++;
        }
    }
    
    return allDoctors;
}

    
}
