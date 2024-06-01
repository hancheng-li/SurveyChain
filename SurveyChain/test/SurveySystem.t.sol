// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SurveySystem} from "../src/SurveySystem.sol";

contract SurveySystemTest is Test {
    SurveySystem public surveySystem;

    function setUp() public {
        surveySystem = new SurveySystem();
    }

    function testCreateSurvey() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        address user = address(this);
        vm.prank(user);
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

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

        uint256[] memory votes = surveySystem.getSurveyVotes(0);
        assertEq(votes.length, 2);
        assertEq(votes[0], 0);
        assertEq(votes[1], 0);

        address[] memory voters = surveySystem.getSurveyVoters(0);
        assertEq(voters.length, 0);
    }

    function testSurveyVoting() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        address user = address(this);
        vm.prank(user);
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        vm.prank(user);
        surveySystem.vote(0, 0);

        uint256[] memory votes = surveySystem.getSurveyVotes(0);
        assertEq(votes[0], 1);
        assertEq(votes[1], 0);

        address[] memory voters = surveySystem.getSurveyVoters(0);
        assertEq(voters.length, 1);
        assertEq(voters[0], user);

        vm.expectRevert("You have already voted");
        surveySystem.vote(0, 1);
    }

    function testOnlyOwnerCanCloseSurvey() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        address user = address(this);
        vm.prank(user);
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        address nonOwner = address(0x1);
        vm.prank(nonOwner);
        vm.expectRevert("Only the owner can close the survey");
        surveySystem.closeSurvey(0);
    }
}
