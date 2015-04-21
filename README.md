### Description:
Interact with Mandrill remotely

### Dependencies:
mandrill-api

### Configuration:
MANDRILL_TOKEN - List of name:token pairs. Example "prod:123456,staging:98754678,dev:1234111222"

### Commands:
* hubot (I'm|I'm|Im|I am) missing (an) email - Show Mandrill email backlog count.
* hubot (mandrill|email) (blacklog|queue) - Show Mandrill email backlog count.
* hubot find email (with|that contains) {name, subject, text, etc} - Searches today's emails and displays matches. Supports specified search terms. Subject:{text}, email{text}, etc

#### Author: 
 @riveramj
