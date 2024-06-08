// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract UserManagement {
    mapping (address => uint256) public roles; // 0: Registered User, 1: Unregistered User
    mapping (address => string) public usernames;
    mapping(string => bool) public usernameTaken; // For unique username, no 2 registered users can have the same username

    // Function to register a user
    function registerUser(string memory username) public {
        require(bytes(username).length > 0, "Username cannot be empty");
        require(!usernameTaken[username], "Username already taken");

        if (bytes(usernames[msg.sender]).length > 0) {
            usernameTaken[usernames[msg.sender]] = false; // Free the previous username
        }

        usernames[msg.sender] = username;
        roles[msg.sender] = 0; // Registered User
        usernameTaken[username] = true; // Mark the new username as taken
    }
}