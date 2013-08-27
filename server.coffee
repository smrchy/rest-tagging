PORT = 8102

app = require "./app"

server = app.listen(PORT)
console.log "Listening on port #{PORT}"