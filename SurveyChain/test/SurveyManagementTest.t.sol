// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SurveySystem} from "../src/SurveySystem.sol";

contract SurveyManagementTest is Test {
    SurveySystem public surveySystem;

    function setUp() public {
        surveySystem = new SurveySystem();
    }

    function testCreateSurvey() public {
        // Test scenario: Create a survey with valid parameters
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        // Create the survey
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
        assertEq(survey.owner, address(this));

        // Verify that the votes array is initialized correctly
        assertEq(survey.votes.length, 2);
        assertEq(survey.votes[0], 0);
        assertEq(survey.votes[1], 0);

        // Verify that the voters array is initialized correctly
        assertEq(survey.voters.length, 0);
    }

    function testCreateSurveyWithoutChoices() public {
        // Test scenario: Attempt to create a survey without choices
        string memory description = "Test Survey";
        string[] memory choices = new string[](0); // No choices
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        // Expect revert due to lack of choices
        vm.expectRevert(bytes("Survey must have at least one choice"));
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);
    }

    function testCreateSurveyWithZeroDuration() public {
        // Test scenario: Attempt to create a survey with zero duration
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 0; // Zero duration
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        // Expect revert due to zero duration
        vm.expectRevert(bytes("Survey duration must be greater than zero"));
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);
    }

    function testCreateSurveyWithZeroMaxVotes() public {
        // Test scenario: Attempt to create a survey with zero max votes
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 0; // Zero max votes
        uint256 reward = 10 ether;

        // Expect revert due to zero max votes
        vm.expectRevert(bytes("Max votes must be greater than zero"));
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);
    }

    function testCreateSurveyWithZeroReward() public {
        // Test scenario: Attempt to create a survey with zero reward
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 0; // Zero reward

        // Expect revert due to zero reward
        vm.expectRevert(bytes("Reward must be greater than zero"));
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);
    }

    function testCreateSurveyWithInvalidReward() public {
        // Test scenario: Attempt to create a survey with invalid reward (mismatch between msg.value and reward)
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        // Expect revert due to reward value mismatch
        vm.expectRevert(bytes("Reward value must be sent"));
        surveySystem.createSurvey{value: reward - 1}(description, choices, duration, maxVotes, reward); // Sending less ether than reward
    }

    function testCloseSurveyManuallyByOwner() public {
        // Test scenario: Close a survey by the owner
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        // Create the survey
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        // Close the survey
        surveySystem.closeSurvey(0);

        // Retrieve and verify survey details
        SurveySystem.Survey memory survey = surveySystem.getSurvey(0);
        assertEq(survey.isClosed, true, "Survey should be closed");
    }

    function testNonOwnerCantCloseSurvey() public {
        // Set up survey parameters
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        // Register the user
        address user = address(this);
        vm.prank(user);
        surveySystem.registerUser("TestUser");

        // Simulate a registered user creating a survey
        vm.prank(user);
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        // Attempt to close the survey by a non-owner and expect failure
        address nonOwner = address(0x1);
        vm.prank(nonOwner);
        vm.expectRevert("Only the owner can close the survey");
        surveySystem.closeSurvey(0);
    }

    function testSurveyExpiration() public {
        // Test scenario: Close a survey automatically after expiration
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 days; // 1 day duration
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        // Create the survey
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        // Fast forward time to after the survey expiration
        vm.warp(block.timestamp + 2 days);

        // Close the expired survey
        surveySystem.closeSurvey(0);

        // Retrieve and verify survey details
        SurveySystem.Survey memory survey = surveySystem.getSurvey(0);
        assertEq(survey.isClosed, true, "Survey should be closed after expiration");
    }
}
