pragma solidity >=0.4.21 <0.7.0;
contract Hello {
    string greatings;
    constructor() public {
        greatings = "hello";
    }

    function getGreatings() public view returns (string memory) {
        return greatings;
    }

    function setGreatings(string memory _greetings) public {
        greatings = _greetings;
    }
}
