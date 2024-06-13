// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SurveySystem {

    mapping (address => uint256) public roles; // ****** 1: Registered User, 0: Unregistered User ******
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
        uint256 isClosed; // ****** 1: Open, 2: Closed ******
        address owner;
    }

    mapping(uint256 => mapping(address => uint256)) public hasVoted;

    // Function to register a user
    function registerUser(string memory username) public {
        require(bytes(username).length > 0, "Username cannot be empty");
        require(roles[msg.sender] == 0, "User is already registered");
        usernames[msg.sender] = username;
        roles[msg.sender] = 1; // Registered User
    }

    // Function to create a new survey
    function createSurvey(string memory _description, string[] memory _choices, uint256 duration, uint256 _maxVotes) public payable { // ****** Removed _reward ******
        require(_choices.length > 0, "Survey must have at least one choice"); 
        require(duration > 0, "Survey duration must be greater than zero");
        require(duration < type(uint256).max - block.timestamp, "Duration overflow"); // ****** Check for overflow ******
        require(_maxVotes > 0, "Max votes must be greater than zero");
        require(msg.value > 0, "Reward must be greater than zero"); // ****** Check if reward is greater than zero ******
        // require(msg.value == _reward, "Reward value must be sent"); // ****** Removed ******
        require(roles[msg.sender] == 0, "Only registered users can create surveys"); // ****** Check if user is registered ******

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
        newSurvey.reward = msg.value;
        newSurvey.isClosed = 1; // ****** Open ******
        newSurvey.owner = msg.sender;
    }

    function getSurvey(uint256 _surveyId) public view returns (Survey memory) {
        require(_surveyId < surveys.length, "Survey does not exist");
        return surveys[_surveyId];
    }

    // Function to vote in a survey
    function vote(uint256 _surveyId, uint256 _choice) public {
        require(_surveyId < surveys.length, "Survey does not exist");
        Survey storage survey = surveys[_surveyId];
        require(block.timestamp >= survey.startTime, "Survey has not started yet");
        require(block.timestamp <= survey.endTime, "Survey has ended");
        require(survey.isClosed == 1, "Survey is closed"); // ****** Check if survey is open ******
        require(_choice < survey.choices.length, "Invalid choice");
        require(hasVoted[_surveyId][msg.sender] == 0, "You have already voted"); // ****** Check if user has already voted ******
        require(survey.voters.length < survey.maxVotes, "Max votes reached");
        require(msg.sender != survey.owner, "Owner cannot vote");

        survey.votes[_choice]++;
        survey.voters.push(msg.sender);
        hasVoted[_surveyId][msg.sender] = 1; // ***** Mark user as voted *****
    }

    // Function to withdraw reward
    function withdrawReward(uint256 _surveyId) public {
        require(_surveyId < surveys.length, "Survey does not exist");
        Survey storage survey = surveys[_surveyId];
        require(survey.isClosed == 2, "Survey is not closed yet"); // ****** Check if survey is closed ******
        require(survey.reward > 0, "No rewards available"); 
        require(msg.sender == survey.owner, "Only the owner can withdraw the reward");
        survey.reward = 0;

        uint256 rewardPerVoter = survey.reward / survey.voters.length;
        uint256 rewardLeft = survey.reward % survey.voters.length;
        for (uint256 i = 0; i < survey.voters.length; i++) {
            address voter = survey.voters[i];
            payable(voter).transfer(rewardPerVoter);
        }
        payable(survey.owner).transfer(rewardLeft); // ****** Transfer remaining reward to owner ******
    }

    // Function to check if a user has participated in a survey
    function hasUserParticipated(uint256 _surveyId, address user) public view returns (uint256) {
        require(_surveyId < surveys.length, "Survey does not exist");
        return hasVoted[_surveyId][user];
    }

    // Function to get survey participants
    function getSurveyParticipants(uint256 _surveyId) public view returns (address[] memory) {
        require(_surveyId < surveys.length, "Survey does not exist");
        return surveys[_surveyId].voters;
    }

    // Function to get total number of surveys
    function getTotalSurveys() public view returns (uint256) {
        return surveys.length;
    }

    // Function to close a survey
    function closeSurvey(uint256 _surveyId) public {
        require(_surveyId < surveys.length, "Survey does not exist");
        Survey storage survey = surveys[_surveyId];
        require(msg.sender == survey.owner, "Only the owner can close the survey");
        require(survey.isClosed == 1, "Survey is already closed"); // ****** Check if survey is open ******

        uint256 reward = survey.reward; // ****** Store reward in a variable ******
        survey.reward = 0; // ****** Set reward to zero ******
        survey.isClosed = 2; // ****** Closed ******

        if (survey.voters.length > 0) {
            uint256 rewardPerVoter = reward / survey.voters.length;
            uint256 rewardLeft = reward % survey.voters.length;
            for (uint256 i = 0; i < survey.voters.length; i++) {
                address voter = survey.voters[i];
                payable(voter).transfer(rewardPerVoter);
            }
            payable(survey.owner).transfer(rewardLeft);
        }
        else {
            payable(survey.owner).transfer(reward);
        }
    }

    receive() external payable {}
}
