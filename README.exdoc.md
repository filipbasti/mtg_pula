# MTG Pula API Documentation

## Overview

MTG Pula is a platform for managing Magic: The Gathering tournaments. Below is a diagram of the system architecture:

![System Architecture](https://i.imgur.com/Tqxzsgs.png "System Architecture")
![Use Case Diagram](https://i.imgur.com/K23zIxl.png "Use Case diagram")
## Features
- User authentication and authorization
- Tournament creation and management
- Real-time updates via Phoenix Channels

## **Schemas**

### **1. [Account Schema](MtgPula.Accounts.Account.html)**
- Represents an account in the system.
- Stores account-related information such as email and hashed passwords.

### **2. [User Schema](MtgPula.Users.User.html)**
- Represents a user in the system.
- Stores user-related information such as full name, gender, and biography.

### **3. [Tournament Schema](MtgPula.Tournaments.Tournament.html)**
- Represents a tournament.
- Stores tournament-related information such as name, rounds, and players.

### **4. [Player Schema](MtgPula.Tournaments.Player.html)**
- Represents a player participating in a tournament.
- Stores player-related information such as points, deck, and match history.

### **5. [Match Schema](MtgPula.Tournaments.Match.html)**
- Represents a match between players in a tournament.
- Stores match-related information such as players, scores, and the winner.

---
## **Phoenix Channel Documentation**
---

  - Tournamemnt channels track **[Presence](https://hexdocs.pm/phoenix/js/#presence)**.
  - You can see all events that can be used **[HERE](MtgPulaWeb.TournamentChannel.html)**
  - If you are using Node based framework, I recommend connecting by **[Phoenix Channels JavaScript client](https://www.npmjs.com/package phoenix-channels)**
 .

### **Example**
  ```
  
  const { Socket } = require('phoenix-channels')
  //connect to socket
  let socket = new Socket(baseURL, { params: { token: userToken },})

  socket.connect()

  // Now that you are connected, you can join channels with
   a topic for example a tournament with join_code of 12345:
  let channel = socket.channel("tournament:12345", {})
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })
  //push an event to socket
  channel.push("add_player", {user_id: "any_id", deck: "deck"})
            .receive("ok", resp => resolve(resp))
            .receive("error", resp => reject(resp));
  ```



## **REST API Documentation**

These are all exposed that can be used to access data and modify it. Authentication is done by jwt.
 
---




### **Public Endpoints (No Authentication Required)**

#### **1. GET `/api/`**
- **Description**: Health check endpoint to verify the API is running.
- **Request**: No parameters required.
- **Response**:
  ```text
  MTG PULA IS LIVE!
  ```

---

#### **2. POST `/api/accounts/create`**
- **Description**: Creates a new account.
- **Request**:
  - **Body Parameters**:
    ```json
    {
      "account": {
        "email": "user@example.com",
        "hash_password": "password123"
      }
    }
    ```
- **Response**:
  ```json
  {
    "id": "account_id",
    "email": "user@example.com",
    "token": "jwt_token"
  }
  ```

---

#### **3. POST `/api/accounts/sign_in`**
- **Description**: Authenticates a user and returns a JWT token.
- **Request**:
  - **Body Parameters**:
    ```json
    {
      "email": "user@example.com",
      "hash_password": "password123"
    }
    ```
- **Response**:
  ```json
  {
    "id": "account_id",
    "email": "user@example.com",
    "token": "jwt_token"
  }
  ```

---

#### **4. GET `/api/tournaments/standings/by_id/:id`**
- **Description**: Retrieves the standings for a specific tournament by its ID.
- **Request**:
  - **Path Parameters**:
    - `id` (string, required): The ID of the tournament.
- **Response**:
  ```json
  {
    "standings": [
      {
        "id": "player_id",
        "user_id": "user_id",
        "full_name": "John Doe",
        "deck": "Mono Red Aggro",
        "points": 15
      }
    ]
  }
  ```

---

#### **5. GET `/api/tournaments`**
- **Description**: Retrieves a list of all tournaments.
- **Request**: No parameters required.
- **Response**:
  ```json
  {
    "tournaments": [
      {
        "id": "tournament_id",
        "name": "Summer Cup",
        "current_round": 1,
        "number_of_rounds": 5,
        "join_code": "ABC123",
        "finished": false
      }
    ]
  }
  ```
#### **6. GET `/api/tournaments/matches/by_join_code/:join_code`**
- **Description**: Retrieves all matches for a tournament using its join code.
- **Request**:
  - **Path Parameters**:
    - `join_code` (string, required): The join code of the tournament.
- **Response**:
  ```json
  {
    "data": [
      {
        "match_id": "match_id",
        "round": 1,
        "player1_id": "player1_id",
        "player1_fullname": "John Doe",
        "player_1_wins": 2,
        "player_2_wins": 1,
        "player2_id": "player2_id",
        "player2_fullname": "Jane Smith"
      },
      {
        "match_id": "match_id_2",
        "round": 1,
        "player1_id": "player3_id",
        "player1_fullname": "Alice Johnson",
        "bye": true
      }
    ]
  }
  ```
- **Error Response**:
  ```json
  {
    "errors": "Pairings for this tournament not found"
  }
  ```

---


### **Protected Endpoints (Require JWT Authentication)**

### **Authentication**

These endpoints are protected and require a valid JWT token for access. For these endpoints, include the following header in your requests:

```
Authorization: Bearer <your_jwt_token>
```

---
#### **7. GET `/api/accounts/by_id/:id`**
- **Description**: Retrieves account details by ID.
- **Authentication**: Requires JWT.
- **Request**:
  - **Path Parameters**:
    - `id` (string, required): The ID of the account.
- **Response**:
  ```json
  {
    "id": "account_id",
    "email": "user@example.com",
    "user": {
      "id": "user_id",
      "full_name": "John Doe",
      "gender": "male",
      "biography": "Avid MTG player"
    }
  }
  ```

---

#### **8. GET `/api/accounts/current`**
- **Description**: Retrieves the currently authenticated account.
- **Authentication**: Requires JWT.
- **Request**: No parameters required.
- **Response**:
  ```json
  {
    "id": "account_id",
    "email": "user@example.com",
    "user": {
      "id": "user_id",
      "full_name": "John Doe",
      "gender": "male",
      "biography": "Avid MTG player"
    }
  }
  ```

---

#### **9. PATCH `/api/accounts/update`**
- **Description**: Updates account details.
- **Authentication**: Requires JWT.
- **Request**:
  - **Body Parameters**:
    ```json
    {
      "account": {
        "email": "new_email@example.com",
        "hash_password": "new_password"
      }
    }
    ```
- **Response**:
  ```json
  {
    "id": "account_id",
    "email": "new_email@example.com"
  }
  ```

---

#### **10. POST `/api/accounts/sign_out`**
- **Description**: Signs out the currently authenticated account.
- **Authentication**: Requires JWT.
- **Request**: No parameters required.
- **Response**:
  ```json
  {
    "message": "Signed out successfully"
  }
  ```

---

#### **11. POST `/api/accounts/refresh_session`**
- **Description**: Refreshes the session token for the authenticated account.
- **Authentication**: Requires JWT.
- **Request**: No parameters required.
- **Response**:
  ```json
  {
    "token": "new_jwt_token"
  }
  ```

---

#### **12. PUT `/api/users/update`**
- **Description**: Updates user details.
- **Authentication**: Requires JWT.
- **Request**:
  - **Body Parameters**:
    ```json
    {
      "user": {
        "full_name": "Jane Doe",
        "gender": "female",
        "biography": "MTG enthusiast"
      }
    }
    ```
- **Response**:
  ```json
  {
    "id": "user_id",
    "full_name": "Jane Doe",
    "gender": "female",
    "biography": "MTG enthusiast"
  }
  ```

---

#### **13. POST `/api/tournaments/create`**
- **Description**: Creates a new tournament.
- **Authentication**: Requires JWT.
- **Request**:
  - **Body Parameters**:
    ```json
    {
      "tournament": {
        "name": "Summer Cup",
        "number_of_rounds": 5
      }
    }
    ```
- **Response**:
  ```json
  {
    "id": "tournament_id",
    "name": "Summer Cup",
    "current_round": 0,
    "number_of_rounds": 5,
    "join_code": "ABC123",
    "finished": false
  }
  ```

---

#### **14. POST `/api/tournaments/add_player`**
- **Description**: Adds a player to a tournament.
- **Authentication**: Requires JWT.
- **Request**:
  - **Body Parameters**:
    ```json
    {
      "player": {
        "tournament_id": "tournament_id",
        "user_id": "user_id",
        "deck": "Mono Red Aggro"
      }
    }
    ```
- **Response**:
  ```json
  {
    "id": "player_id",
    "deck": "Mono Red Aggro",
    "points": 0,
    "had_bye": false
  }
  ```

---

#### **15. GET `/api/tournaments/prepare_round/:tournament_id`**
- **Description**: Prepares the next round for a tournament.
- **Authentication**: Requires JWT.
- **Request**:
  - **Path Parameters**:
    - `tournament_id` (string, required): The ID of the tournament.
- **Response**:
  ```json
  {
    "data": [
      {
        "match_id": "match_id",
        "player1_id": "player1_id",
        "player2_id": "player2_id",
        "round": 2
      }
    ]
  }
  ```

---

#### **16. GET `/api/tournaments/current_matches/:tournament_id`**
- **Description**: Retrieves the current matches for a tournament.
- **Authentication**: Requires JWT.
- **Request**:
  - **Path Parameters**:
    - `tournament_id` (string, required): The ID of the tournament.
- **Response**:
  ```json
  {
    "matches": [
      {
        "match_id": "match_id",
        "player1_id": "player1_id",
        "player2_id": "player2_id",
        "round": 2
      }
    ]
  }
  ```

---

#### **17. PATCH `/api/tournaments/matches/:id`**
- **Description**: Updates the score and play status of a match.
- **Authentication**: Requires JWT.
- **Request**:
  - **Path Parameters**:
    - `id` (string, required): The ID of the match.
  - **Body Parameters**:
    ```json
    {
      "match": {
        "player_1_wins": 2,
        "player_2_wins": 1,
        "on_play_id": "player1_id"
      }
    }
    ```
- **Response**:
  ```json
  {
    "id": "match_id",
    "round": 1,
    "player_1_wins": 2,
    "player_2_wins": 1,
    "player1_id": "player1_id",
    "player2_id": "player2_id",
    "on_play_id": "player1_id"
  }
  ```

---
