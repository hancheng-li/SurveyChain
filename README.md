# SurveyChain
__SurveyChain__ is a cutting-edge survey participation system built on blockchain technology, designed to streamline the creation and distribution of surveys. Our lightweight and user-friendly platform offers a comprehensive API that covers every aspect of the survey process, from creation and participation to closure. Engineered with robust security features, SurveyChain guarantees financial safety for both survey creators and participants. Additionally, we have implemented various techniques to minimize gas consumption, ensuring that creating and participating in surveys remains cost-effective.

 ## System Overview
As a survey owner, you can pose multiple single-option questions and close the survey at any time or allow it to close automatically upon reaching the expiry block timestamp. The platform ensures real-time data availability through this expiration mechanism. Survey participants can select only one answer from the provided choices. When creating a survey, the survey creator specifies a total reward amount, which is uniformly distributed among all participants based on their participation, with leftovers sent back to the survey creator. The survey creator can manually close a survey or wait until the survey has expired or reached the maximum number of votes. If the survey is automatically closed, the survey creator can withdraw funds/distribute rewards by calling suitable functions. By default, all expired surveys will be accessible to everyone, including unregistered users, but no editing can be done on those surveys. 

 ## Environment Setup and Intialization
Our application is built using foundry. To tryout our application, please install foundry first. You can follow the instructions here: [https://book.getfoundry.sh/getting-started/installation](https://book.getfoundry.sh/getting-started/installation)

## APIs of SurveyChain
After you are done installing foundry, you can try out our application. 
### SurveySystem
*Relavant functions and data structures here, with detailed explanation*
### SurveyManagement
*Relavant functions and data structures here, with detailed explanation*
### UserManagement
*Relavant functions and data structures here, with detailed explanation*
### Voting
*Relavant functions and data structures here, with detailed explanation*
### RewardDistribution
*Relavant functions and data structures here, with detailed explanation*
## How to Interact with our Application
For now, you can ony interact with our application using test files. You can create users inside test functions and interact with all the functionalities of the survey system. 
In the future, we plan to build a frontend for this application with a vision interface, which is a lot easier and more intuitive for the users

### An Example of how to Interact with our Application Using Test Files
*Please do an example*