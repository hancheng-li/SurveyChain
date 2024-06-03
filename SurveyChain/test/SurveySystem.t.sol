// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SurveySystem} from "../src/SurveySystem.sol";

contract SurveySystemTest is Test {
    SurveySystem public surveySystem;

    function setUp() public {
        surveySystem = new SurveySystem();
    }

    function testCreateSurvey() public {
        // Set up survey parameters
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        // Simulate a user creating a survey
        address user = address(this);
        vm.prank(user);
        surveySystem.createSurvey(description, choices, duration, maxVotes, reward);

        // Retrieve and verify survey details in parts to avoid stack too deep error
        assertEq(surveySystem.getSurveyDescription(0), description);
        assertEq(surveySystem.getSurveyChoices(0).length, 2);
        assertEq(surveySystem.getSurveyChoices(0)[0], "Option 1");
        assertEq(surveySystem.getSurveyChoices(0)[1], "Option 2");
        assertEq(surveySystem.getSurveyStartTime(0), block.timestamp);
        assertEq(surveySystem.getSurveyEndTime(0), block.timestamp + duration);
        assertEq(surveySystem.getSurveyMaxVotes(0), maxVotes);
        assertEq(surveySystem.getSurveyReward(0), reward);
        assertEq(surveySystem.getSurveyIsClosed(0), false);
        assertEq(surveySystem.getSurveyOwner(0), user);

        // Verify that the votes array is initialized correctly
        uint256[] memory votes = surveySystem.getSurveyVotes(0);
        assertEq(votes.length, 2);
        assertEq(votes[0], 0);
        assertEq(votes[1], 0);

        // Verify that the voters array is initialized correctly
        address[] memory voters = surveySystem.getSurveyVoters(0);
        assertEq(voters.length, 0);
        
    }
    function testSurveyVoting() public {
        // Set up survey parameters
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        // Simulate a user creating a survey
        address user = address(this);
        vm.prank(user);
        surveySystem.createSurvey(description, choices, duration, maxVotes, reward);

        // Simulate voting
        vm.prank(user);
        surveySystem.vote(0, 0);

        // Retrieve and verify votes
        uint256[] memory votes = surveySystem.getSurveyVotes(0);
        assertEq(votes[0], 1);
        assertEq(votes[1], 0);

        // Verify that the user is recorded as a voter
        address[] memory voters = surveySystem.getSurveyVoters(0);
        assertEq(voters.length, 1);
        assertEq(voters[0], user);

        // Attempt to vote again and expect failure
        vm.expectRevert("You have already voted");
        surveySystem.vote(0, 1);
    }
}
