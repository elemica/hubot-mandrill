# Description:
#   Interact with Mandrill remotely
#
# Dependencies:
#   mandrill-api
#
# Configuration:
#   MANDRILL_TOKEN - List of name:token pairs. Example "prod:123456,staging:98754678,dev:1234111222"
#
# Commands:
#   hubot (I'm|I'm|Im|I am) missing (an) email - Show Mandrill email backlog count.
#   hubot (mandrill|email) (blacklog|queue) - Show Mandrill email backlog count.
#   hubot find email (with|that contains) {name, subject, text, etc} - Searches today's emails and displays matches. Supports specified search terms. Subject:{text}, email{text}, etc
#   hubot find all email (with|that contains) {name, subject, text, etc} - Searches emails from the past 90 days and displays matches. Supports specified search terms. Subject:{text}, email{text}, etc
#
# Author: 
#   @riveramj

rawMandrillTokens = process.env.MANDRILL_TOKEN
mandrillTokenPairs = rawMandrillTokens.split(',')
mandrillTokens = for pair in mandrillTokenPairs
                   pair.split(':')

mandrillApi = require 'mandrill-api/mandrill'

mandrillClients = for token in mandrillTokens
                    [token[0], new mandrillApi.Mandrill(token[1])]

module.exports = (robot) ->

  getUsersForAllAccounts = (msg) ->
    for client in mandrillClients
      do (client) ->
        client[1].users.info {}, (user) ->
          msg.send "#{client[0]} : #{user.backlog}"

  findEmail = (msg, query, dateFrom, dateTo) ->
    mandrillClients[0][1].messages.search {"query": query, "date_from": dateFrom, "date_to": dateTo}, (emails)  ->
      if emails.length > 0
        for email in emails
          do (email) ->
            date = new Date(email.ts * 1000)
            opened = if email.opens > 0
              "yes"
            else
              "no"

            msg.send """
              to: #{email.email}
              subject: #{email.subject}
              sent: #{date}
              state: #{email.state}
              account: #{email.subaccount}
              opened: #{opened}
            """
      else
        msg.send "Did not find any emails"

  robot.respond /(I'm|I'm|Im|I am)\s?missing (an )?email/i, (msg) ->
    msg.send "Looking to see if it's in the backlog."
    getUsersForAllAccounts msg

  robot.respond /(mandrill|email) (backlog|queue)/i, (msg) ->
    msg.send "Retrieving backlog. This may take a second."
    getUsersForAllAccounts msg

  robot.respond /find all email (?:with|that contains) (.*)/i, (msg) ->
    query = msg.match[1].trim()

    todayDate = new Date().toISOString().replace(/T.*/,'')
    datePast = new Date()
    datePast.setDate(datePast.getDate() - 90)
    dateFrom = datePast.toISOString().replace(/T.*/,'')
    dateTo = todayDate

    msg.send """What we're gonna do right here is go back
                Way back
                Back into time
              """

    findEmail msg, query, dateFrom, dateTo

  robot.respond /find email (?:with|that contains) (.*)/i, (msg) ->
    query = msg.match[1].trim()
    todayDate = new Date().toISOString().replace(/T.*/,'')
    dateFrom = todayDate
    dateTo = todayDate

    findEmail msg, query, dateFrom, dateTo
