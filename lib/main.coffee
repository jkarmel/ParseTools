prompt = require 'prompt'
fs = require 'fs'
Browser = require 'zombie'
browser = new Browser

CREDS_FILE = 'parse_creds.txt'

saveCreds = (email, password) ->
  data = email + '\n' + password
  fs.writeFile CREDS_FILE, data

withCreds = (cb) ->
  fs.readFile CREDS_FILE, 'utf8', (err, data) ->
    # Credentials not yet saved
    if err
      prompt.start()
      prompt.get ['email', 'password'], (err, res) ->
        saveCreds res.email, res.password
        cb res.email, res.password
    else 
      [email, password] = data.split('\n')
      cb email, password

browser.visitParseHome = (email, password, cb) ->
  browser.visit 'http://www.parse.com', ->
    loginDiv = browser.document.querySelector '.header_login'
    browser.fire 'click', loginDiv, ->
      browser
        .fill("#user_session_email", email)
        .fill("#user_session_password", password)
        .pressButton '.submit_button', cb

browser.logIntoParse = browser.visitParseHome

list = ->
  browser.visitParseHome ->  
    apps = browser.document.querySelectorAll '.name'
    console.log app.innerHTML.slice(1) for app in apps

newApp = (name) ->
  withCreds (email, password) ->
    browser.logIntoParse email, password, ->
      browser.visit 'https://parse.com/apps/new', ->
        browser
          .fill('#parse_app_name', name)
          .pressButton 'Create app', ->

newApp 'newapp'