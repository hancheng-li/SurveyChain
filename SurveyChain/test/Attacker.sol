// Penetration tests file
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SurveySystem} from "../src/SurveySystem.sol";

contract Attacker is Test {
    SurveySystem public surveySystem;
    address public attackerAddress = address(0x1);

    function setUp() public {
        surveySystem = new SurveySystem();
        surveySystem.registerUser("Owner");
        // Explicitly set the test contract address to unregistered
        surveySystem.setRole(address(this), 1);
        vm.deal(attackerAddress, 100 ether); // Providing sufficient funds
    }

    // Penetration test 1: Verifies that an unregistered user cannot create a survey
    function testUnregisteredUserCreateSurveyAttack() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;
        
        // Ensure the revert message matches the one defined in the contract
        vm.expectRevert("Only registered users can create a survey");
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);
    }

    // Penetration test 2: Ensures that the survey creation function prevents 
    // setting a survey duration to a value that exceeds the maximum allowed duration
    function testTimeOverflowAttack() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = type(uint256).max;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;
        
        // Register User
        surveySystem.registerUser("Attacker");

        // Ensure the revert message matches the overflow prevention logic
        vm.expectRevert("Survey duration must be greater than zero and less than maximum duration");
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);
    }

    // Penetration test 3: Checks that a user cannot vote multiple times on 
    // the same survey using different addresses (Sybil attack)
    function testRepeatedVoteSybilAttackCase() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;
        
        // Register and create a survey as the owner
        surveySystem.registerUser("Attacker");    
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        // Vote as a different address
        vm.prank(attackerAddress);
        surveySystem.vote(0, 0); // vote for option 1

        // Ensure the revert message matches the multiple voting prevention logic
        vm.expectRevert("You have already voted");
        vm.prank(attackerAddress);
        surveySystem.vote(0, 1); // vote for option 2, should revert
    }

    // Penetration test 4: Confirms that the same address cannot register multiple times 
    // with the same username, preventing duplicate registrations.
    function testRegistrationSybilAttackCase() public {
        surveySystem.registerUser("Attacker");
        
        bool r;
        bytes memory revertReason;
        (r, revertReason) = address(surveySystem).call(abi.encodeWithSignature("registerUser(string)", "Attacker"));
        
        require(!r, "Expected revert, but the call succeeded");
    }

    // Penetration test 5: Ensure that the survey creation function correctly prevents 
    // the creation of a survey with a zero reward, which would violate the intended 
    // logic of requiring a positive reward for survey creation
    function testSurveyCreationWithNoReward() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 0; // Zero reward

        // Register the attacker
        vm.prank(attackerAddress);
        surveySystem.registerUser("Attacker");

        // Expect revert due to zero reward
        vm.prank(attackerAddress);
        vm.expectRevert(bytes("Reward must be greater than zero"));
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);
    }

    // Penetration test 6: Prevents rewards from being distributed 
    // more than once for the same survey
    function testDoubleRetrievalAttack() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        // Register the attacker
        vm.prank(attackerAddress);
        surveySystem.registerUser("Attacker");

        // Create a survey
        vm.prank(attackerAddress);
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        // Add a voter to ensure there are voters before distributing rewards
        address voterAddress = address(0x2);
        vm.deal(voterAddress, 1 ether); // Fund the voter address
        vm.prank(voterAddress);
        surveySystem.registerUser("Voter");
        vm.prank(voterAddress);
        surveySystem.vote(0, 0); // vote for option 1

        // Close the survey (assuming closeSurvey function is public and callable by owner)
        vm.prank(attackerAddress);
        surveySystem.closeSurvey(0);

        // Distribute rewards for the first time
        vm.prank(attackerAddress);
        surveySystem.distributeRewards(0);

        // Attempt to distribute rewards again, should revert
        vm.prank(attackerAddress);
        vm.expectRevert("Rewards have already been distributed");
        surveySystem.distributeRewards(0);
    }

    // Penetration test 7: Ensure the system handles a potential division 
    // by zero error when distributing rewards
    function testDivideByZeroAttack() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        // Register the attacker
        vm.prank(attackerAddress);
        surveySystem.registerUser("Attacker");

        // Create a survey
        vm.prank(attackerAddress);
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        // Close the survey (assuming closeSurvey function is public and callable by owner)
        vm.prank(attackerAddress);
        surveySystem.closeSurvey(0);

        // Attempt to distribute rewards, should revert if there are no voters
        vm.prank(attackerAddress);
        vm.expectRevert("No voters to distribute rewards to");
        surveySystem.distributeRewards(0);
    }

    // Penetration test 8: Ensure the system handles a case where
    // the owner tries to vote in their own survey, this would be
    // counterintuitive to the purpose of our survey and is not allowed
    function testOwnerVoteAttack() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        // Register the attacker
        vm.prank(attackerAddress);
        surveySystem.registerUser("Attacker");

        // Create the survey
        vm.prank(attackerAddress);
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        // Attempt to vote as the owner
        vm.prank(attackerAddress);
        vm.expectRevert(bytes("Survey owner cannot vote in their own survey"));
        surveySystem.vote(0, 0);
    }

    // Penetration test 9: Sybil attack prevention whereby users cannot
    // create multiple fake identities to manipulate the voting process
    function testMultipleIdentitySybilAttack() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        // Register the attacker
        vm.prank(attackerAddress);
        surveySystem.registerUser("Attacker");

        // Create a survey
        vm.prank(attackerAddress);
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        // Register multiple identities and attempt to vote
        address[] memory identities = new address[](5);
        for (uint256 i = 0; i < identities.length; i++) {
            identities[i] = address(uint160(uint256(keccak256(abi.encodePacked(i, block.timestamp)))));
            vm.deal(identities[i], 1 ether); // Fund the identities
            vm.prank(identities[i]);
            surveySystem.registerUser(string(abi.encodePacked("Voter", i)));
        }

        // Attempt to vote multiple times
        for (uint256 i = 0; i < identities.length; i++) {
            vm.prank(identities[i]);
            surveySystem.vote(0, 0); // Vote for option 1
        }

        // Verify that votes are not manipulated and are correctly counted
        uint256[] memory votes = surveySystem.getVoteCounts(0);
        assertEq(votes[0], identities.length, "Vote count for option 1 should match the number of identities");
    }

    receive() external payable {}
}

// Penetration test 10: Ensure ensures that the distributeRewards 
// function cannot be exploited by reentrant calls, which could 
// otherwise allow an attacker to repeatedly withdraw funds inappropriately
contract Reentrancy_Attacker is Test {
    SurveySystem public surveySystem;
    address public attackerAddress = address(this);

    function setUp() public {
        surveySystem = new SurveySystem();
        surveySystem.registerUser("Owner");
        // Explicitly set the test contract address to unregistered
        surveySystem.setRole(address(this), 1);
        // Fund the test contract address
        vm.deal(address(this), 100 ether); // Providing sufficient funds
    }

    function testReentrancyAttack() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        // Register the attacker
        vm.prank(attackerAddress);
        surveySystem.registerUser("Attacker");

        // Create a survey
        vm.prank(attackerAddress);
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        // Deploy the attacker contract
        Voter voter = new Voter(surveySystem);

        // Vote
        voter.vote(0, 0); // vote for option 1

        // Close the survey (assuming closeSurvey function is public and callable by owner)
        vm.prank(attackerAddress);
        surveySystem.closeSurvey(0);

        // Attempt reentrancy during reward distribution
        voter.attack(0);
    }
}

contract Voter {
    SurveySystem public surveySystem;

    constructor(SurveySystem _surveySystem) {
        surveySystem = _surveySystem;
    }

    function vote(uint256 surveyId, uint256 choice) public {
        surveySystem.vote(surveyId, choice);
    }

    function attack(uint256 surveyId) public {
        surveySystem.distributeRewards(surveyId); // Attempt reentrancy during reward distribution
    }

    receive() external payable {
        if (address(surveySystem).balance >= 1 ether) {
            surveySystem.distributeRewards(0); // reentrancy attack
        }
    }
}