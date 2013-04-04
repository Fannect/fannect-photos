express = require "express"
path = require "path"
dateFormat = require "../utils/date"
fannect = require "../utils/fannectAccess"
fannect({
   login_url: process.env.LOGIN_URL or "http://localhost:2200"
   resource_url: process.env.RESOURCE_URL or "http://localhost:2100"
   client_id: process.env.CLIENT_ID or "some_clientid"
   client_secret: process.env.CLIENT_SECRET or "clientsecret"
})

# client_id: process.env.CLIENT_ID or "867acebcf49037d7238393aa33affd3b"
# client_secret: process.env.CLIENT_SECRET or "11bd7d64b8eb490420225a50c5986647ca63a4b54010a61feef4909f163f7011"

app = module.exports = express()

# Settings
app.set "view engine", "jade"
app.set "view options", layout: false
app.set "views", path.join __dirname, "../views"

app.configure "development", () ->
   app.use express.logger "dev"
   app.use express.errorHandler { dumpExceptions: true, showStack: true }

app.configure "production", () ->
   app.use express.errorHandler()

# Middleware
app.use express.query()
app.use express.bodyParser()
app.use require("connect-assets")()
app.use express.static path.join __dirname, "../public"

# Controllers
app.get "/:highlight_id", (req, res, next) ->
   highlight_id = req.params.highlight_id
   
   if highlight_id.indexOf(".") != -1 or highlight_id.indexOf("/") != -1
      return next()
   
   fannect.request
      url: "/v1/highlights/#{highlight_id}"
   , (err, highlight) ->

      now = new Date()
      date = new Date(parseInt(highlight._id.substring(0,8), 16) * 1000)
      time = dateFormat(date, "h:MM TT")
      if (
         date.getMonth() == now.getMonth() and
         date.getFullYear() == now.getFullYear()
      )
         if date.getDate() == now.getDate()
            highlight.date_text = "Today at #{time}"
         else if date.getDate() == now.getDate() - 1
            highlight.date_text = "Yesterday at #{time}"
         else
            highlight.date_text = "#{dateFormat(date, "mm/dd/yyyy")} at #{time}"
      else
         highlight.date_text = "#{dateFormat(date, "mm/dd/yyyy")} at #{time}"

      highlight.image_url = getUrl(highlight.image_url, 848, 848)
      highlight.owner_profile_image_url = getUrl(highlight.owner_profile_image_url, 86, 86)
     
      res.render "layout", { highlight: highlight }

getUrl = (url, w, h, quality = 85) ->
      return "" if url == "" 
      return url unless url.indexOf("cloudinary") >= 0 
      parsed = url.split("/")
      parsed[parsed.length - 2] = "q_#{quality},w_#{w},h_#{h}"
      return parsed.join("/")


