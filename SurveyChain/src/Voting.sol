// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./SurveyManagement.sol";

contract Voting is SurveyManagement {
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // Function to vote in a survey
    function vote(uint256 _surveyId, uint256 _choice) public {
        require(_surveyId < surveys.length, "Survey does not exist");
        Survey storage survey = surveys[_surveyId];
        require(block.timestamp >= survey.startTime, "Survey has not started yet");
        require(block.timestamp <= survey.endTime, "Survey has ended");
        require(!survey.isClosed, "Survey is closed");
        require(_choice < survey.choices.length, "Invalid choice");
        require(!hasVoted[_surveyId][msg.sender], "You have already voted");
        require(msg.sender != survey.owner, "Survey owner cannot vote in their own survey");

        survey.votes[_choice]++;
        survey.voters.push(msg.sender);
        hasVoted[_surveyId][msg.sender] = true;

        // Close the survey if max votes reached or if expired
        if (survey.voters.length >= survey.maxVotes || block.timestamp > survey.endTime) {
            survey.isClosed = true;
        }
    }
}
