PORT = require("./config.json").port
app = require "./app"

server = app.listen(PORT)
console.log "Listening on port #{PORT}"