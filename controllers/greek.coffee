express = require "express"
request = require "request"

if process.env.NODE_ENV == "production"
   config = require "../config"
else 
   config = require "../dev-config"

app = module.exports = express()

fannect = require "../utils/fannectAccess"

app.get "/", (req, res, next) -> 
   res.redirect "/mu"

app.get "/:school", (req, res, next) ->
   school = config[req.params.school]
   return next() unless school
   fannect.request
      url: "/v1/teams/#{school.team_id}/groups"
      qs: { tags: "greek", limit: 60 }
   , (err, groups) ->
      return res.render("error", { error: err }) if err
      res.render "layout", { groups: groups, config: school }
      
      console.log config

   # groups = [ 
   #    {
   #       _id: '511ad0dd8f8e4dda940005fd',
   #       name: 'Sorority 2',
   #       team_id: '51084c08f71f44551a7b1e66',
   #       team_name: 'Kansas Jayhawks',
   #       sport_key: '15008000',
   #       sport_name: 'Basketball',
   #       team_key: 'l.ncaa.org.mbasket-t.B33',
   #       tags: [ 'greek', 'sorority' ],
   #       points: { dedication: 68, passion: 33, knowledge: 115, overall: 216 } },
   #    {
   #       _id: '511ad0a48f8e4dda940005f2',
   #       members: 2,
   #       name: 'Sorority 1',
   #       sport_key: '15008000',
   #       sport_name: 'Basketball',
   #       team_id: '51084c08f71f44551a7b1e66',
   #       team_key: 'l.ncaa.org.mbasket-t.B33',
   #       team_name: 'Kansas Jayhawks',
   #       tags: [ 'greek', 'sorority' ],
   #       points: { dedication: 92, passion: 105, knowledge: 152, overall: 349 } },
   #    {
   #       _id: '511ad0a48f9e4dda940005f2',
   #       members: 2,
   #       name: 'Sorority 3',
   #       sport_key: '15008000',
   #       sport_name: 'Basketball',
   #       team_id: '51084c08f71f44551a7b1e66',
   #       team_key: 'l.ncaa.org.mbasket-t.B33',
   #       team_name: 'Kansas Jayhawks',
   #       tags: [ 'greek', 'sorority' ],
   #       points: { dedication: 0, passion: 0, knowledge: 0, overall: 0 } },
   #    {  
   #       _id: '511ad034b5a7715ec6000571',
   #       members: 2,
   #       name: 'Frat 1',
   #       sport_key: '15008000',
   #       sport_name: 'Basketball',
   #       team_id: '51084c08f71f44551a7b1e66',
   #       team_key: 'l.ncaa.org.mbasket-t.B33',
   #       team_name: 'Kansas Jayhawks',
   #       tags: [ 'greek', 'fraternity' ],
   #       points: { dedication: 92, passion: 105, knowledge: 152, overall: 349 } },
   #    { 
   #       _id: '511acf6db5a7715ec6000552',
   #       members: 2,
   #       name: 'Frat 2',
   #       sport_key: '15008000',
   #       sport_name: 'Basketball',
   #       team_id: '51084c08f71f44551a7b1e66',
   #       team_key: 'l.ncaa.org.mbasket-t.B33',
   #       team_name: 'Kansas Jayhawks',
   #       tags: [ 'greek', 'fraternity' ],
   #       points: { dedication: 92, passion: 105, knowledge: 152, overall: 349 } } ]
   # res.render "layout", { groups: groups, config: school }

app.post "/", (req, res, next) ->
   group_id = req.body.group_id
   email = req.body.email
   fannect.request
      url: "/v1/groups/#{group_id}/teamprofiles"
      method: "POST"
      json: { email: email }
   , (err, body) ->
      res.json body