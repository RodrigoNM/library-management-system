# Library Management System

## Requirements

* **Rails 7.2**
* **Ruby 3.3.1**
* **SQLite**

### Gems used
* devise
* devise-jwt
* pundit
* rspec-rails
* factory_bot_rails
* faker

### Basic Structure
* As Librarian and Member are user types, a User parent class was created with an attribute role, which can be :librarian or :member
defined in an enum within User class
* To add permissions to what a user can or cannot do, a book policy was created, in order to validate which actions are allowed for each type of user
* To authenticate first the user needs to send a post request to `login` endpoint, it will return a token which can be used to send further requests to the other endpoints

### Improvements opportunity
* Create an API error handling to track better errors and return more user friendly messages
* Created serializer models to serialize objects and build responses
* Create an STI polimorphic user table instead of a role attribute
* Move some logic from user class to its child classes, so it would avoid checking user type like in dashboards imdex action
* Move book policy and sessions to be under api/v1 namespace
* User more logs to register important steps
* Use docker

### Notes
* This is a rails api only project
* No views were created because there are too much business rules and specs to be implemented within the time range to acomplish the challenge
