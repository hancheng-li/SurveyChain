// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SurveySystem} from "../src/SurveySystem.sol";

contract UserManagementTest is Test {
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
}
