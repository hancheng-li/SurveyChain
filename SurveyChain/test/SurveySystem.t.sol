// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SurveySystem} from "../src/SurveySystem.sol";

contract SurveySystemTest is Test {
    SurveySystem public surveySystem;

    function setUp() public {
        surveySystem = new SurveySystem();
    }

    function testRegisterUser() public {
        // Test scenario: Register a user with a valid username
        address user = address(0x123);
        string memory username = "Alice";

        // Initially, the roles mapping should not explicitly store any value for the user
        // The default value should be zero, which represents "Registered User" in our contract.
        assertEq(surveySystem.roles(user), 0, "Initial role should be 0 (Registered User)");
        assertEq(bytes(surveySystem.usernames(user)).length, 0, "Initial username should be empty");

        // Register the user
        vm.prank(user); // Sets the msg.sender to 'user' for the next call
        surveySystem.registerUser(username);

        // Verify that the user is registered
        assertEq(surveySystem.roles(user), 0, "Role should be 0 (Registered User)");
        assertEq(surveySystem.usernames(user), username, "Username should be Alice");
    }

    function testRegisterUserEmptyUsername() public {
        // Test scenario: Try to register a user with an empty username
        address user = address(0x456);

        // Attempt to register with an empty username
        vm.prank(user);
        vm.expectRevert(bytes("Username cannot be empty"));
        surveySystem.registerUser("");
    }

    function testRegisterUserMultipleTimes() public {
        // Test scenario: Register a user multiple times with different usernames
        address user = address(0x789);
        string memory username1 = "Bob";
        string memory username2 = "Charlie";

        // Register the user the first time
        vm.prank(user);
        surveySystem.registerUser(username1);

        // Verify the first registration
        assertEq(surveySystem.roles(user), 0, "Role should be 0 (Registered User) after first registration");
        assertEq(surveySystem.usernames(user), username1, "Username should be Bob after first registration");

        // Register the user again with a different username
        vm.prank(user);
        surveySystem.registerUser(username2);

        // Verify that the username is updated
        assertEq(surveySystem.roles(user), 0, "Role should remain 0 (Registered User) after second registration");
        assertEq(surveySystem.usernames(user), username2, "Username should be Charlie after second registration");
    }

    function testRegisterUserWithDuplicateUsername() public {
        // Test scenario: Ensure duplicate usernames are not allowed
        address user1 = address(0xAAA);
        address user2 = address(0xBBB);
        string memory username = "DuplicateUser";

        // Register the first user
        vm.prank(user1);
        surveySystem.registerUser(username);

        // Attempt to register the second user with the same username
        vm.prank(user2);
        vm.expectRevert(bytes("Username already taken"));
        surveySystem.registerUser(username);
    }
    
    function testCreateSurveyAsRegisteredUser() public {
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

    function testFailCreateSurveyAsUnregisteredUser() public {
        // Set up survey parameters
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        // Attempt to create a survey without registering
        vm.expectRevert("Only registered users can create a survey");
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);
    }
    
    function testOwnerCannotVoteInOwnSurvey() public {
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

        // Attempt to vote in own survey and expect failure
        vm.prank(user);
        vm.expectRevert("Survey owner cannot vote in their own survey");
        surveySystem.vote(0, 0);
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

        // Register the user
        address user = address(this);
        vm.prank(user);
        surveySystem.registerUser("TestUser");

        // Register another user for voting
        address voter = address(0x2);
        vm.prank(voter);
        surveySystem.registerUser("VoterUser");

        // Simulate a registered user creating a survey
        vm.prank(user);
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        // Simulate voting by another user
        vm.prank(voter);
        surveySystem.vote(0, 0);

        // Retrieve and verify survey details
        SurveySystem.Survey memory survey = surveySystem.getSurvey(0);
        assertEq(survey.votes[0], 1);
        assertEq(survey.votes[1], 0);

        // Verify that the user is recorded as a voter
        assertEq(survey.voters.length, 1);
        assertEq(survey.voters[0], voter);

        // Attempt to vote again and expect failure
        vm.prank(voter);
        vm.expectRevert("You have already voted");
        surveySystem.vote(0, 1);
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

    function testOwnerCanCloseSurvey() public {
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

        // Simulate the owner closing the survey
        vm.prank(user);
        surveySystem.closeSurvey(0);

        // Verify the survey is closed
        SurveySystem.Survey memory survey = surveySystem.getSurvey(0);
        assertEq(survey.isClosed, true);
    }
}
