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
        isRegistered[user] = (role == 0); // Update isRegistered based on role
    }
}
