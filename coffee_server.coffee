#nodejs-android-buttons-backend

# ========== DEPENDENCIES
express = require('express')
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)
cors = require('cors')
geolocation = require('./geolocation')
fs = require('fs')

# ========== CONFIGURATION
server_port = process.env.PORT || 3000
data_file_path = './count_value.data'

# ========== SETUP EXPRESS
app.use(cors())
if process.env.NODE_ENV == 'production'
  app.set('trust proxy', true)

#========== APP CODE
process.countValue =
  try
    parseInt(fs.readFileSync(data_file_path) || '0')
  catch
    0

setInterval((=>
  fs.writeFile(data_file_path, process.countValue.toString(), 'utf8', undefined)
), 1000)

#createApiResponse = (req) =>
#  ip_address = req.ip
#  ip_address = ip_address.split(":")[0] if ip_address
#    result: geolocation.get_ip_address_geodata_info(if ip_address == '127.0.0.1' then '8.8.8.8' else ip_address)

#========== Express Framework configuration
app.use(express.static('public'))

app.get '/api/v1/counter_value', (req, res) ->
  res.contentType('application/json')
  res.send(JSON.stringify
    count_value: process.countValue
  )

app.post '/api/v1/increment_counter', (req, res) ->
  process.countValue++
  io.emit('update_counter', process.countValue)
  res.contentType('application/json')
  res.send(JSON.stringify
    count_value: process.countValue
  )

console.log('starting server...', server_port)
http.listen(server_port)