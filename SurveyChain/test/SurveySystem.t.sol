// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SurveySystem} from "../src/SurveySystem.sol";
import {Reentracy_Attacker, Attacker} from "./Attacker.sol";

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
        assertEq(survey.isClosed, 1);
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
        assertEq(survey.isClosed, 1);
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
        assertEq(survey.isClosed, 2);
    }

    function test_unregistered_user_create_survey_attack() public {
        // Simulate an unregistered user creating a survey
        Attacker attacker = new Attacker(surveySystem);
        deal(address(attacker), 10 ether);
        attacker.unregistered_user_create_survey_attack();
        vm.expectRevert("Only registered users can create surveys");
    }

    function test_create_time_overflow_survey_attack() public{
        Attacker attacker = new Attacker(surveySystem);
        deal(address(attacker), 10 ether);
        attacker.time_overflow_attack();
        vm.expectRevert("Duration overflow");
    }

    function test_sybil_attack_1() public {
        Attacker attacker = new Attacker(surveySystem);
        deal(address(attacker), 10 ether);
        attacker.sybil_attack_1();
        vm.expectRevert("You have already voted");
    }

    function test_sybil_attack_2() public {
        Attacker attacker = new Attacker(surveySystem);
        deal(address(attacker), 10 ether);
        attacker.sybil_attack_2();
        vm.expectRevert("Survey is not closed yet");
    }

    function test_reentrancy_attack() public {
        Reentracy_Attacker attacker = new Reentracy_Attacker(surveySystem);
        deal(address(attacker), 10 ether);
        attacker.reentrancy_attack();
        vm.expectRevert("Survey is already closed");
    }

    function test_create_survey_free() public {
        Attacker attacker = new Attacker(surveySystem);
        deal(address(attacker), 10 ether);
        attacker.create_survey_free_attack();
        vm.expectRevert("Reward must be greater than zero");
    }

    function test_double_retrieval_1() public {
        Attacker attacker = new Attacker(surveySystem);
        deal(address(attacker), 10 ether);
        attacker.double_retrieval_attack_1();
        vm.expectRevert("No rewards available");
    }

    function test_double_retrieval_2() public {
        Attacker attacker = new Attacker(surveySystem);
        deal(address(attacker), 10 ether);
        attacker.double_retrieval_attack_2();
        vm.expectRevert("No rewards available");
    }

    function test_divide_by_zero() public {
        Attacker attacker = new Attacker(surveySystem);
        deal(address(attacker), 10 ether);
        attacker.divide_by_zero_attack();
        assertEq(address(attacker).balance, 10 ether);
    }

    function test_owner_vote() public {
        Attacker attacker = new Attacker(surveySystem);
        deal(address(attacker), 10 ether);
        attacker.owner_vote_attack();
        vm.expectRevert("Owner cannot vote");
    }
}
