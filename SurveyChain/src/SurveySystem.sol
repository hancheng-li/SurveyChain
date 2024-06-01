// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SurveySystem {
    
    mapping (address => uint256) public roles; // 0: Registered User, 1: Unregistered User
    mapping (address => string) public usernames;

    Survey[] public surveys;

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
    
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    function createSurvey(string memory _description, string[] memory _choices, uint256 duration, uint256 _maxVotes, uint256 _reward) public payable {
        require(_choices.length > 0, "Survey must have at least one choice");
        require(duration > 0, "Survey duration must be greater than zero");
        require(_maxVotes > 0, "Max votes must be greater than zero");
        require(_reward > 0, "Reward must be greater than zero");
        require(msg.value >= _reward, "Insufficient Ether sent for reward");

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
        require(_surveyId < surveys.length, "Survey does not exist");
        Survey storage survey = surveys[_surveyId];
        require(block.timestamp >= survey.startTime, "Survey has not started yet");
        require(block.timestamp <= survey.endTime, "Survey has ended");
        require(!survey.isClosed, "Survey is closed");
        require(_choice < survey.choices.length, "Invalid choice");
        require(!hasVoted[_surveyId][msg.sender], "You have already voted");

        survey.votes[_choice]++;
        survey.voters.push(msg.sender);
        hasVoted[_surveyId][msg.sender] = true;
    }

    function closeSurvey(uint256 _surveyId) public {
        require(_surveyId < surveys.length, "Survey does not exist");
        Survey storage survey = surveys[_surveyId];
        require(msg.sender == survey.owner, "Only the owner can close the survey");
        require(!survey.isClosed, "Survey is already closed");

        survey.isClosed = true;

        if (survey.voters.length > 0) {
            uint256 rewardPerVoter = survey.reward / survey.voters.length;
            for (uint256 i = 0; i < survey.voters.length; i++) {
                address voter = survey.voters[i];
                payable(voter).transfer(rewardPerVoter);
            }
        }
    }

    receive() external payable {}
}
