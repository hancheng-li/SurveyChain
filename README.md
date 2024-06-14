# SurveyChain Documentation

## Table of Contents
- [Overview](#overview)
- [APIs](#apis)
  - [User Management](#user-management)
  - [Survey Management](#survey-management)
  - [Voting](#voting)
  - [Reward Distribution](#reward-distribution)
- [Setup and Initialization](#setup-and-initialization)
- [Components](#components)
- [User Roles](#user-roles)

## Overview
SurveyChain is a cutting-edge survey participation system built on blockchain technology, designed to streamline the creation and distribution of surveys. Our lightweight and user-friendly platform offers a comprehensive API that covers every aspect of the survey process, from creation and participation to closure. Engineered with robust security features, SurveyChain guarantees financial safety for both survey creators and participants. Additionally, we have implemented various techniques to minimize gas consumption, ensuring that creating and participating in surveys remains cost-effective.

## APIs

### User Management

#### `registerUser(string memory username)`

**Description:** Registers a user with a customized account name linked to their blockchain address.

**How to Call:**

\`\`\`solidity
surveySystem.registerUser("Username");
\`\`\`

**Returns:** None

**Special and Security Notes:** Only unregistered users can call this function. Usernames must be unique and non-empty.

### Survey Management

#### `createSurvey(string memory _description, string[] memory _choices, uint256 duration, uint256 _maxVotes, uint256 _reward) payable`

**Description:** Creates a new survey with specified parameters.

**How to Call:**

\`\`\`solidity
surveySystem.createSurvey{value: reward}("Survey Description", ["Option 1", "Option 2"], 1 weeks, 100, 10 ether);
\`\`\`

**Returns:** None

**Special and Security Notes:** Only registered users can create surveys. Surveys must have at least one choice, a valid duration, a positive number of max votes, and a positive reward amount.

#### `getSurvey(uint256 _surveyId)`

**Description:** Returns the details of a survey.

**How to Call:**

\`\`\`solidity
Survey memory survey = surveySystem.getSurvey(0);
\`\`\`

**Returns:** Survey struct containing survey details.

**Special and Security Notes:** The survey ID must exist.

#### `closeSurvey(uint256 _surveyId)`

**Description:** Closes a survey manually or automatically after expiry.

**How to Call:**

\`\`\`solidity
surveySystem.closeSurvey(0);
\`\`\`

**Returns:** None

**Special and Security Notes:** Only the survey owner can manually close the survey. Surveys can also be closed automatically after expiry.

### Voting

#### `vote(uint256 _surveyId, uint256 _choice)`

**Description:** Submits a vote for a specified survey.

**How to Call:**

\`\`\`solidity
surveySystem.vote(0, 0);
\`\`\`

**Returns:** None

**Special and Security Notes:** Only one vote per user per survey is allowed. The survey must be active, and the user must not be the survey owner.

### Reward Distribution

#### `distributeRewards(uint256 _surveyId)`

**Description:** Distributes rewards to participants after the survey is closed.

**How to Call:**

\`\`\`solidity
surveySystem.distributeRewards(0);
\`\`\`

**Returns:** None

**Special and Security Notes:** Rewards can only be distributed once, and only if the survey is closed and has participants.

## Setup and Initialization

### Prerequisites

Install Forge

### Installation

Clone the repository:

\`\`\`bash
git clone https://github.com/hancheng-li/cs190j_final.git
cd SurveyChain
\`\`\`

Install dependencies:

\`\`\`bash
forge install
\`\`\`

Compile the contracts:

\`\`\`bash
forge build
\`\`\`

Run the tests:

\`\`\`bash
forge test
\`\`\`

## Components

### Contracts

- **UserManagement:** Manages user registration and roles.
- **SurveyManagement:** Handles survey creation, viewing, and closing.
- **Voting:** Manages the voting process for surveys.
- **RewardDistribution:** Handles the distribution of rewards to survey participants.
- **SurveySystem:** Integrates all components into a single contract.

## User Roles

### Registered Users

**Capabilities:**
- Create surveys
- View surveys
- Vote in surveys

### Unregistered Users

**Capabilities:**
- View surveys
- Vote in surveys

### Survey Owners

**Capabilities:**
- Create surveys
- Close surveys
- Distribute rewards