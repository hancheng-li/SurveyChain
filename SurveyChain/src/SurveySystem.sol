// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SurveySystem {
    
    // mapping (address => string) public usernames;
    mapping (address => uint256) public roles; // 0: Registered User, 1: Unregistered User
    mapping (address => string) public usernames;

    Survey[] public surveys;

    struct Survey {
        string description;
        uint256 id;
        string[] choices; // Descriptions of the choices (changed to string[])
        uint256 startTime;
        uint256 endTime;
        uint256 maxVotes;
        uint256[] votes;
        uint256 reward;
        address[] voters;
        bool isClosed;
        // Added in line below, Address of the survey creator
        address owner;
    }

    // Function to create a new survey
    function createSurvey(string memory _description, string[] memory _choices, uint256 duration, uint256 _maxVotes, uint256 _reward) public {
        require(_choices.length > 0, "Survey must have at least one choice");
        require(duration > 0, "Survey duration must be greater than zero");
        require(_maxVotes > 0, "Max votes must be greater than zero");
        require(_reward > 0, "Reward must be greater than zero");

        uint256 surveyId = surveys.length;  // Use the length of the surveys array as the new survey ID
        surveys.push();

        Survey storage newSurvey = surveys[surveyId];
        newSurvey.description = _description;
        newSurvey.id = surveyId;
        newSurvey.choices = _choices;
        newSurvey.startTime = block.timestamp;
        newSurvey.endTime = block.timestamp + duration;
        newSurvey.maxVotes = _maxVotes;
        newSurvey.votes = new uint256[](_choices.length);  // Initialize the votes array
        newSurvey.reward = _reward;
        newSurvey.isClosed = false;
        newSurvey.owner = msg.sender;
    }

    // Getter functions to retrieve survey details in parts
    function getSurveyBasicDetails(uint256 _surveyId) public view returns (
        string memory description,
        uint256 id,
        string[] memory choices,
        uint256 startTime,
        uint256 endTime,
        uint256 maxVotes,
        uint256 reward,
        bool isClosed,
        address owner
    ) {
        Survey storage survey = surveys[_surveyId];
        return (
            survey.description,
            survey.id,
            survey.choices,
            survey.startTime,
            survey.endTime,
            survey.maxVotes,
            survey.reward,
            survey.isClosed,
            survey.owner
        );
    }

    // Getter functions to retrieve survey details in parts
    function getSurveyDescription(uint256 _surveyId) public view returns (string memory) {
        return surveys[_surveyId].description;
    }

    function getSurveyChoices(uint256 _surveyId) public view returns (string[] memory) {
        return surveys[_surveyId].choices;
    }

    function getSurveyStartTime(uint256 _surveyId) public view returns (uint256) {
        return surveys[_surveyId].startTime;
    }

    function getSurveyEndTime(uint256 _surveyId) public view returns (uint256) {
        return surveys[_surveyId].endTime;
    }

    function getSurveyMaxVotes(uint256 _surveyId) public view returns (uint256) {
        return surveys[_surveyId].maxVotes;
    }

    function getSurveyReward(uint256 _surveyId) public view returns (uint256) {
        return surveys[_surveyId].reward;
    }

    function getSurveyIsClosed(uint256 _surveyId) public view returns (bool) {
        return surveys[_surveyId].isClosed;
    }

    function getSurveyOwner(uint256 _surveyId) public view returns (address) {
        return surveys[_surveyId].owner;
    }

    function getSurveyVotes(uint256 _surveyId) public view returns (uint256[] memory) {
        return surveys[_surveyId].votes;
    }

    function getSurveyVoters(uint256 _surveyId) public view returns (address[] memory) {
        return surveys[_surveyId].voters;
    }

    function vote(uint256 _surveyId, uint256 _choice) public {
        
    }

    function closeSurvey(uint256 _surveyId) public {
        
    }

}