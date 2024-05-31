// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SurveySystem {
    
    // mapping (address => string) public usernames;
    mapping (address => uint256) public roles; // 0: Registered User, 1: Unregistered User
    mapping (address => string) public usernames;

    Survey[] public surveys;

    struct Survey {
        string description;
        uint256 id;
        uint256[] choices;
        uint256 startTime;
        uint256 endTime;
        uint256 maxVotes;
        uint256[] votes;
        uint256 reward;
        address[] voters;
        bool isClosed;
    }

    function createSurvey(string memory _description, uint256[] memory _choices, uint256 duration, uint256 _maxVotes, uint256 _reward) public {
        
    }

    function vote(uint256 _surveyId, uint256 _choice) public {
        
    }

    function closeSurvey(uint256 _surveyId) public {
        
    }

    function getSurvey(uint256 _surveyId) public view returns (Survey memory) {
        
    }
}