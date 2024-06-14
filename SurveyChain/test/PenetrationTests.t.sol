// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SurveySystem} from "../src/SurveySystem.sol";
import {ReentrancyAttacker, Attacker} from "./Attacker.sol";

contract PenetrationTests is Test {
    SurveySystem public surveySystem;
    Attacker public attacker;
    ReentrancyAttacker public reentrancyAttacker;
    address public voter1 = address(0x1); // Address for a non-owner voter
    address public voter2 = address(0x2); // Address for another non-owner voter

    function setUp() public {
        surveySystem = new SurveySystem();
        attacker = new Attacker(surveySystem);
        reentrancyAttacker = new ReentrancyAttacker(surveySystem);
        vm.deal(address(attacker), 10 ether); // Fund the attacker with ether
        vm.deal(address(reentrancyAttacker), 10 ether); // Fund the reentrancy attacker with ether
        vm.deal(voter1, 1 ether); // Fund voter1 with ether
        vm.deal(voter2, 1 ether); // Fund voter2 with ether
    }

    // Test 1: Attempt to create a survey by an unregistered user
    function testUnregisteredUserCreateSurveyAttack() public {
        vm.expectRevert(bytes("Only registered users can create a survey"));
        attacker.unregistered_user_create_survey_attack();
    }

    // Test 2: Attempt to create a survey with an overflowed duration
    function testTimeOverflowAttack() public {
        vm.expectRevert(bytes("Survey duration must be greater than zero and less than maximum duration of 1 year"));
        attacker.time_overflow_attack();
    }

    // Test 3: Attempt to vote twice from the same user (sybil attack)
    function testSybilAttack1() public {
        // Perform the sybil attack setup
        attacker.sybil_attack_1();

        // Simulate the first vote by voter1
        vm.prank(voter1);
        surveySystem.vote(0, 0);

        // The second vote should revert
        vm.prank(voter1);
        vm.expectRevert(bytes("You have already voted"));
        surveySystem.vote(0, 1);
    }

    // Test 4: Attempt to register the same user twice (sybil attack)
    function testSybilAttack2() public {
        attacker.sybil_attack_2();
        // The second registration should revert
        vm.expectRevert(bytes("User is already registered"));
        attacker.sybil_attack_2();
    }

    // Test 5: Attempt to create a survey without sending reward
    function testCreateSurveyFreeAttack() public {
        vm.expectRevert(bytes("Reward must be greater than zero"));
        attacker.create_survey_free_attack();
    }

    // Test 6: Attempt to withdraw reward twice
    function testDoubleRetrievalAttack1() public {
        // Perform the double retrieval attack setup
        attacker.double_retrieval_attack_1();

        // Simulate voting by voter1
        vm.prank(voter1);
        surveySystem.vote(0, 0);

        // Close the survey and distribute rewards as the attacker (owner of the survey)
        vm.prank(address(attacker));
        surveySystem.closeSurvey(0);
        vm.prank(address(attacker));
        surveySystem.distributeRewards(0);

        // The second reward withdrawal should revert
        vm.prank(address(attacker));
        vm.expectRevert(bytes("Rewards have already been distributed"));
        surveySystem.distributeRewards(0);
    }

    // Test 7: Attempt to withdraw reward twice with short duration
    function testDoubleRetrievalAttack2() public {
        // Perform the double retrieval attack setup
        attacker.double_retrieval_attack_2();

        // Simulate voting by voter1
        vm.prank(voter1);
        surveySystem.vote(0, 0);

        // Try to vote a second time, which should revert
        vm.prank(voter1);
        vm.expectRevert(bytes("You have already voted"));
        surveySystem.vote(0, 1);

        // Close the survey and distribute rewards as the attacker (owner of the survey)
        vm.prank(address(attacker));
        surveySystem.closeSurvey(0);
        vm.prank(address(attacker));
        surveySystem.distributeRewards(0);

        // The second reward withdrawal should revert
        vm.prank(address(attacker));
        vm.expectRevert(bytes("Rewards have already been distributed"));
        surveySystem.distributeRewards(0);
    }

    // Test 8: Attempt to close survey to cause divide by zero error
    function testDivideByZeroAttack() public {
        attacker.divide_by_zero_attack();
        // Check that no divide by zero error occurs
    }

    // Test 9: Attempt to vote as the owner
    function testOwnerVoteAttack() public {
        vm.expectRevert(bytes("Survey owner cannot vote in their own survey"));
        attacker.owner_vote_attack();
    }

    // Test 10: Attempt a reentrancy attack
    function testReentrancyAttack() public {
        reentrancyAttacker.reentrancy_attack();
        // Check that reentrancy attack is prevented
    }
}