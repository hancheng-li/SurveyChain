// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {SurveySystem} from "../src/SurveySystem.sol";

contract Attacker {
    SurveySystem public surveySystem;

    constructor(SurveySystem _surveySystem) {
        surveySystem = _surveySystem;
    }

    function unregistered_user_create_survey_attack() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;

        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);
    }

    function time_overflow_attack() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = type(uint256).max;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;
        surveySystem.registerUser("Attacker");

        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);
    }

    function sybil_attack_1() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;
        
        surveySystem.registerUser("Attacker");
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        surveySystem.vote(0,0); // vote for option 1
        surveySystem.vote(0,1); // vote for option 2, should revert
    }

    function sybil_attack_2() public {
        surveySystem.registerUser("Attacker");
        surveySystem.registerUser("Attacker2"); // register another user, should revert
    }

    function create_survey_free_attack() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 0;
        surveySystem.registerUser("Attacker");

        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);
    }

    function double_retrieval_attack_1() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;
        surveySystem.registerUser("Attacker");

        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);
        surveySystem.closeSurvey(0);
        surveySystem.withdrawReward(0); // withdraw reward again, should revert
    }

    function double_retrieval_attack_2() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 seconds;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;
        surveySystem.registerUser("Attacker");

        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);
        surveySystem.withdrawReward(0);
        surveySystem.withdrawReward(0); // withdraw reward again, should revert
    }

    function divide_by_zero_attack() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;
        surveySystem.registerUser("Attacker");

        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);
        surveySystem.closeSurvey(0);
    }

    function owner_vote_attack() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;
        surveySystem.registerUser("Attacker");

        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);
        surveySystem.vote(0, 0); // should revert, owner cannot vote
    }

    receive() external payable {}
}

contract Reentracy_Attacker {
    SurveySystem public surveySystem;

    constructor(SurveySystem _surveySystem) {
        surveySystem = _surveySystem;
    }

    function reentrancy_attack() public {
        string memory description = "Test Survey";
        string[] memory choices = new string[](2);
        choices[0] = "Option 1";
        choices[1] = "Option 2";
        uint256 duration = 1 weeks;
        uint256 maxVotes = 100;
        uint256 reward = 10 ether;
        
        surveySystem.registerUser("Attacker");
        surveySystem.createSurvey{value: reward}(description, choices, duration, maxVotes, reward);

        Voter voter = new Voter(surveySystem);
        voter.vote(0, 0); // vote for option 1

        surveySystem.closeSurvey(0); // close the survey
    }

    receive() external payable {
        surveySystem.closeSurvey(0); // reentrancy attack
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
}