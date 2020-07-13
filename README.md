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
- **Story:** In this digital age people are finding more ways to connect, and this way it will be easy for people to find friends and bond through tehir favorite games 
- **Market:** Will provide huge value to people who play games and want to connect with others
- **Habit:** Wouldn't be too habit forming, a place for people to meet others
- **Scope:** Decent amount of work, should not be too challenging 

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can sign up and log in
* Users can edit profile (self-intro, contact infomation, pictures)
* User can add games they play to their profile
* User can view detailed game information
* Can view you own profile
* There is a match up system that matches two people according to games
* Can view other user's profile and add other users
* Can view contacts (friends list)



**Optional Nice-to-have Stories**
* Chat system(prefered)
* Have specific filters for matching up
* User can enter in additional interests to better connect with others
* Implement filters for nect section 
* User can follow others and view a feed
* Linked to discord

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

* [list first screen here]
   * [list screen navigation here]
   * ...
* [list second screen here]
   * [list screen navigation here]
   * ...

## Wireframes
[Add picture of your hand sketched wireframes in this section]
<img src="https://i.imgur.com/zUOIjvd.png" width=600>


### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 

### Models

Model:User

| Property | Type | description|
| -------- | -------- | -------- |
|objectId|String|unique id for the user (default field)|
|displayPhoto|File|profile photo display in user's profile|
|username|String|name used to identify each user|
|displayName|String|an additional name that gets displayed to others|
|password|String|user's password (hidden)|
|about|String|description section for users to descirbe themselves|
|interests (opt feature)|array of strings|interests that will help better match players
|gender(opt)|String|Field indicating gender "M"/"F"/nil|
|age(opt)|Number|age of user|
|contactInfo (opt)|pointer to contactInfo object|place that contains a user's different contact methods|
|friends|array of users| list of friends the user has connected with|
|nectRequests|array of users|list of users who want to connect with current user|
|games|array of game objects|an array of all games the user plays|
|createdAt|DateTime|date when user is created (default field)|
|updatedAt|DateTime|date when user is updated (default field)|

Model: contactInfo (all fields optional, user does not have to provide contact information)

| Property | Type | description|
| -------- | -------- | -------- |
|objectId|String|unique id for the contactInfo (default field)|
|email|String|user's email|
|phoneNumber|String|user's phone (hidden)|
|discordID|Number|user's discord user identifier|
|createdAt|DateTime|date when contactInfo is created (default field)|
|updatedAt|DateTime|date when contactInfo is updated (default field)|

Model: game (get data from https://rapidapi.com/valkiki/api/chicken-coop)

| Property | Type | description|
| -------- | -------- | -------- |
|objectId|String|unique id for the game(default field)|
|gameName|String|name of game|
|genre|Array of Strings|genre game belongs to|
|gameImage|File|game poster|
|description|String|Description of game to display|
|createdAt|DateTime|date when game is created (default field)|
|updatedAt|DateTime|date when game is updated (default field)|

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
