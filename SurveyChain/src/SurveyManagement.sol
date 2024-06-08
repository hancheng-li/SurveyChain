// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SurveyManagement {
    struct Survey {
        string description;
        uint256 id;
        string[] choices;
        uint256 startTime;
        uint256 endTime;
        uint256 maxVotes;
        uint256[] votes;
        uint256 reward;
        address[] voters;
        bool isClosed;
        address owner;
    }

    Survey[] public surveys;

    // Function to create a new survey
    function createSurvey(string memory _description, string[] memory _choices, uint256 duration, uint256 _maxVotes, uint256 _reward) public payable {
        require(_choices.length > 0, "Survey must have at least one choice");
        require(duration > 0, "Survey duration must be greater than zero");
        require(_maxVotes > 0, "Max votes must be greater than zero");
        require(_reward > 0, "Reward must be greater than zero");
        require(msg.value == _reward, "Reward value must be sent");

        uint256 surveyId = surveys.length;
        surveys.push();

        Survey storage newSurvey = surveys[surveyId];
        newSurvey.description = _description;
        newSurvey.id = surveyId;
        newSurvey.choices = _choices;
        newSurvey.startTime = block.timestamp;
        newSurvey.endTime = block.timestamp + duration;
        newSurvey.maxVotes = _maxVotes;
        newSurvey.votes = new uint256[](_choices.length);
        newSurvey.reward = _reward;
        newSurvey.isClosed = false;
        newSurvey.owner = msg.sender;
    }

    function getSurvey(uint256 _surveyId) public view returns (Survey memory) {
        require(_surveyId < surveys.length, "Survey does not exist");
        return surveys[_surveyId];
    }

    // To close survey manually by owner or automatically by expiration time
    function closeSurvey(uint256 _surveyId) public {
        require(_surveyId < surveys.length, "Survey does not exist");
        Survey storage survey = surveys[_surveyId];
        require(msg.sender == survey.owner, "Only the owner can close the survey");
        require(!survey.isClosed, "Survey is already closed");

        // Close the survey if it has expired or if the owner decides to close it
        if (block.timestamp > survey.endTime || msg.sender == survey.owner) {
            survey.isClosed = true;
        }
    }
}
