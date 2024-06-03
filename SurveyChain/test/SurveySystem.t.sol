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
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        // Retrieve and verify survey details
        SurveySystem.Survey memory survey = surveySystem.getSurvey(0);
        assertEq(survey.description, description);
        assertEq(survey.choices.length, 2);
        assertEq(survey.choices[0], "Option 1");
        assertEq(survey.choices[1], "Option 2");
        assertEq(survey.startTime, block.timestamp);
        assertEq(survey.endTime, block.timestamp + duration);
        assertEq(survey.maxVotes, maxVotes);
        assertEq(survey.reward, reward);
        assertEq(survey.isClosed, false);
        assertEq(survey.owner, user);

        // Verify that the votes array is initialized correctly
        assertEq(survey.votes.length, 2);
        assertEq(survey.votes[0], 0);
        assertEq(survey.votes[1], 0);

        // Verify that the voters array is initialized correctly
        assertEq(survey.voters.length, 0);
    }

    function testGetSurvey() public {
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
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        // Retrieve survey details using getSurvey
        SurveySystem.Survey memory survey = surveySystem.getSurvey(0);

        // Verify survey details
        assertEq(survey.description, description);
        assertEq(survey.choices.length, 2);
        assertEq(survey.choices[0], "Option 1");
        assertEq(survey.choices[1], "Option 2");
        assertEq(survey.startTime, block.timestamp);
        assertEq(survey.endTime, block.timestamp + duration);
        assertEq(survey.maxVotes, maxVotes);
        assertEq(survey.reward, reward);
        assertEq(survey.isClosed, false);
        assertEq(survey.owner, user);

        // Verify that the votes array is initialized correctly
        assertEq(survey.votes.length, 2);
        assertEq(survey.votes[0], 0);
        assertEq(survey.votes[1], 0);

        // Verify that the voters array is initialized correctly
        assertEq(survey.voters.length, 0);
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
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        // Simulate voting
        vm.prank(user);
        surveySystem.vote(0, 0);

        // Retrieve and verify survey details
        SurveySystem.Survey memory survey = surveySystem.getSurvey(0);
        assertEq(survey.votes[0], 1);
        assertEq(survey.votes[1], 0);

        // Verify that the user is recorded as a voter
        assertEq(survey.voters.length, 1);
        assertEq(survey.voters[0], user);

        // Attempt to vote again and expect failure
        vm.expectRevert("You have already voted");
        vm.prank(user);
        surveySystem.vote(0, 1);
    }

    function testNonyOwnerCantCloseSurvey() public {
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

    function testOwnerCanCloseSurvey() public {
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
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        // Simulate the owner closing the survey
        vm.prank(user);
        surveySystem.closeSurvey(0);

        // Verify the survey is closed
        SurveySystem.Survey memory survey = surveySystem.getSurvey(0);
        assertEq(survey.isClosed, true);
    }
}
