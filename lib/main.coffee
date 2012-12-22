prompt = require 'prompt'
fs = require 'fs'
_ = require('underscore')._
Browser = require 'zombie'
browser = new Browser

LOGIN_CREDS_FILE = 'login_creds.txt'
APP_CREDS_FILE = 'app_creds.json'

saveCreds = (email, password) ->
  data = email + '\n' + password
  fs.writeFile LOGIN_CREDS_FILE, data

withCreds = (cb) ->
  fs.readFile LOGIN_CREDS_FILE, 'utf8', (err, data) ->
    # Credentials not yet saved
    if err
      prompt.start()
      prompt.get ['email', 'password'], (err, res) ->
        saveCreds res.email, res.password
        cb res.email, res.password
    else 
      [email, password] = data.split('\n')
      cb email, password

browser.visitParseHome = (cb) ->
  withCreds (email,password) ->
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
  browser.logIntoParse ->
    browser.visit 'https://parse.com/apps/new', ->
      browser
        .fill('#parse_app_name', name)
        .pressButton 'Create app', ->

saveAppCreds = ->
  browser.logIntoParse ->
    browser.visit 'https://parse.com/account/keys', ->
      keyElts = browser.document.querySelectorAll '.app_key p'
      valueElts = browser.document.querySelectorAll '.app_key input'
      keys = (keyElt.innerHTML[..-4] for keyElt in keyElts)
      values = (valueElt.value for valueElt in valueElts)
      keyValPairs = _.zip keys, values
      nameElts = browser.document.querySelectorAll '.header a'
      names = (elt.innerHTML for elt in nameElts)
      res = {}
      for name, i in names
        res[name] = {}
        for [key, val] in keyValPairs[i * 5.. i * 5 + 5]
          res[name][key] = val
      fs.writeFile APP_CREDS_FILE, JSON.stringify res, null, 2

saveAppCreds()