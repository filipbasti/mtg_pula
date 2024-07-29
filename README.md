# MtgPula #

 ## Module 1  - accounts and users
* defines authentication and authorization logic
* defines user parameters
### To Do: 
* register controller - Complete!
* login controller - Complete!
  * returns token and saves it in database
  * saves account into session
* signout complete - Complete
  * revokes tokens from database
  * dismantles the session
* "middleware" to check if the user changing data is that user - complete!
  * needs to be refactored to be reusable - complete!


## Module 2 - Tournament
*defines tournament logic 
*gives endpoints to create, manage and run tournaments
*defined by tournament, players and matches schema

###To Do/Done:

* define schemas - Complete!
   * generate - Complete!
   * refactor for needs? - Complete!
   
* test schemas  - Complete!
 * add unit tests for schema - Complete!

