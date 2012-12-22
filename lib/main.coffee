Browser = require 'zombie'
browser = new Browser

[username, password] = process.argv[2..3]

browser.visitParseHome = (cb) ->
  browser.visit 'http://www.parse.com', ->
    loginDiv = browser.document.querySelector '.header_login'
    browser.fire 'click', loginDiv, ->
      browser
        .fill("#user_session_email", username)
        .fill("#user_session_password", password)
        .pressButton '.submit_button', cb

browser.logIntoParse = browser.visitParseHome

list = ->
  browser.visitParseHome ->  
    apps = browser.document.querySelectorAll '.name'
    console.log app.innerHTML.slice(1) for app in apps

newApp = (name) ->
  browser.logIntoParse ->
    browser.visit 'https://parse.com/apps/new', ->
      browser
        .fill('#parse_app_name', name)
        .pressButton 'Create app', ->
          console.log browser.text 'title'

newApp 'new-app'

