// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./UserManagement.sol";
import "./Voting.sol";
import "./RewardDistribution.sol";
import "./SurveyManagement.sol";

contract SurveySystem is 
    UserManagement, SurveyManagement, 
    Voting, RewardDistribution {

    // Helper function for testing to set roles
    function setRole(address user, uint256 role) external {
        roles[user] = role;
    }

    // Helper function to get vote counts for a survey
    // For preventing sybil attacks
    function getVoteCounts(uint256 _surveyId) external view returns (uint256[] memory) {
        require(_surveyId < surveys.length, "Survey does not exist");
        return surveys[_surveyId].votes;
    }
}
