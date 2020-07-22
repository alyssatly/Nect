# Nect

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Platform for people to find friends to play video games with. Every user will have a profile with the games they play and which games they are looking for people to play with. Can add other information to better match people that are compatible. 

### App Evaluation
[Evaluation of your app across the following attributes]
- **Category:** social
- **Mobile:** only available mobile, so functionaity will be limited to mobile devices
- **Story:** In this digital age people are finding more ways to connect, and this way it will be easy for people to find friends and bond through their favorite games 
- **Market:** Will provide huge value to people who play games and want to connect with others
- **Habit:** Wouldn't be too habit forming, a place for people to meet others
- **Scope:** Decent amount of work, should not be too challenging 

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can sign up and log in
* Users can edit profile (self-intro,pictures, names)
* User can add games they play to their profile
* User can view detailed game information
* Can view you own profile
* There is a match up system that matches two people according to games
* Can view other user's profile and add/accept other users
* Can view contacts (friends/pending list)

**Optional Nice-to-have Stories**
* Chat system(prefered) so users can communicate
* Improve UI, add icons and loading screen, custom images
* Improve matching system: can take genres into consideration and give a score value
* Linked to discord - 
    * log in authentication
    * have a connect through discord button?
    * discord could show game user is playing?
* Add a contact information section that user has an option to hide or show to just friends when profile is viewed
* Have specific filters users can fill in for matching up
* User can enter in additional interests to better connect with others
* Users can post
* User can follow others and view a feed


### 2. Screen Archetypes

* Login
* Profile page
* Edit profile page
    * Users can edit profile
* Edit games page
     * User can add games they play to their profile
* game details page
    * User can add games they play to their profile
* (Con)NECT page
   * There is a match up system that matches two people according to games
   * have specific filters for matching up
* User page
    * Can view other people's profiles
* Chat overview page
    * Friends page (intergrated into search system?)
        * Can add/view contacts (friends list)
* Inidividual chat page

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Profile
* NECT
* Prefered Optional:Chat
* Optional:Activity/notifications
* Optional:Feed

**Flow Navigation** (Screen to Screen)

* Login
    * Clicking login or sign up bring you to the nect screen with tab bar
    
* Profile
    * clicking on game cell brings you to games detailed view
    * edit profile
       * edit games (search for games)
           * clicking on cells go to detailed game view
      
* NECT
   * clicking on photo, username or display name brings you to that users profile
       * clicking on games bring you to games detailed view
   * clicking on top right button brings you to your nect requests
       * clicking on each cell brings you to the profile
    * clicking on top left button brings you to friends/pending section
        * Can click on each cell to remove friends or cancel request

* Chat 
    * click add button on top right to start search for people to start conversations with
        * clicking on cell to get to chat screen
    * clicking on cells bring you to an existing chat screen

## Wireframes
[Add picture of your hand sketched wireframes in this section]
<img src="https://i.imgur.com/zUOIjvd.png" width=600>

## Schema 

### Models

Model:User

| Property | Type | description|
| -------- | -------- | -------- |
|objectId|String|unique id for the user (default field)|
|createdAt|DateTime|date when user is created (default field)|
|updatedAt|DateTime|date when user is updated (default field)|
|displayPhoto|File|profile photo display in user's profile|
|username|String|name used to identify each user|
|displayName|String|an additional name that gets displayed to others|
|password|String|user's password (hidden)|
|about|String|description section for users to descirbe themselves|
|interests (opt feature)|array of strings|interests that will help better match players
|gender(opt)|String|Field indicating gender "M"/"F"/nil|
|age(opt)|Number|age of user|
|contactInfo (opt)|pointer to contactInfo object|place that contains a user's different contact methods|
|friends|array of usernames| list of friends the user has connected with|
|pendingFriends|array of usernames| list of friends the user has sent a nect request to|
|nectRequests|array of usernames|list of users who want to connect with current user|
|games|array of games|an array of all games the user plays (https://rapidapi.com/valkiki/api/chicken-coop)|


Model: contactInfo (Optional feature, all fields optional, user does not have to provide contact information)

| Property | Type | description|
| -------- | -------- | -------- |
|objectId|String|unique id for the contactInfo (default field)|
|email|String|user's email|
|phoneNumber|String|user's phone (hidden)|
|discordID|Number|user's discord user identifier|
|createdAt|DateTime|date when contactInfo is created (default field)|
|updatedAt|DateTime|date when contactInfo is updated (default field)|

Model: Friend

| Property | Type | description|
| -------- | -------- | -------- |
|objectId|String|unique id for the friend relationship (default field)|
|createdAt|DateTime|date when friend relationship is created (default field)|
|updatedAt|DateTime|date when friend relationship is updated (default field)|
|friend1|username string|first friend in the relationship|
|friend2|username string|second friend in the relationship|

Model:NectRequest

| Property | Type | description|
| -------- | -------- | -------- |
|objectId|String|unique id for the nect requests relationship (default field)|
|createdAt|DateTime|date when nect requests relationship is created (default field)|
|updatedAt|DateTime|date when nect requests relationship is updated (default field)|
|receiver|username string|username of the user that sends the request|
|sender|username string|username of the user that receives the request|


Model: chat

| Property | Type | description|
| -------- | -------- | -------- |
|objectId|String|unique id for the chat(default field)|
|sender|pointer to user object|user that sent chat|
|receiver|pointer to user object|user that received chat|
|text|String|chat that was sent|
|createdAt|DateTime|date when chat is created (default field)|
|updatedAt|DateTime|date when chat is updated (default field)|

### Networking

#### List of network requests by screen
Login Screen:
* (Create/POST)Create a user
* (Read/GET) Query logged in user object

Edit Profile Screen:
* (Update/PUT) Update user profile image

Nect Screen:
* (Read/GET) get user object to display profile

Game screen/games detail view:
* (Create/POST) save game in database
* (read/GET) get game from api/database to display

Chat Screen:
* (Read/GET)chats that the user has composed and received


- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
