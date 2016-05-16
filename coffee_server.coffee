#nodejs-geodata-analitics-api

# ========== DEPENDENCIES
express = require('express')
app = express()
mmdb_reader = require('maxmind-db-reader')
cors = require('cors')

# ========== CONFIGURATION
server_port = process.env.OPENSHIFT_NODEJS_PORT || process.env.PORT || 3000
server_ip_address = process.env.OPENSHIFT_NODEJS_IP || '127.0.0.1'

# ========== SETUP EXPRESS
if process.env.OPENSHIFT_NODEJS_IP
  app.set('trust proxy', process.env.OPENSHIFT_NODEJS_IP )
else if process.env.NODE_ENV == 'production'
  app.set('trust proxy', true)

app.use( cors() )

# ========== MAXMIND DATABASE SETUP
geodataCity = mmdb_reader.openSync('./GeoLite2-City.mmdb')

geodata_cache = {}

get_formatted_ip_address_info = (ip_address)->
  ip_address = "31.179.116.11"
  result = geodataCity.getGeoDataSync(ip_address)
  if result
    formatted_result = result.location
    formatted_result.country_code = result?.country?.iso_code
    formatted_result.country_name = result?.country?.names?.en
    formatted_result.ip_address = ip_address
    formatted_result
  else
    null

get_geodata_info = (ip_address)->
  if ip_address
    if geodata_cache[ip_address]
      geodata_cache[ip_address]
    else
      result = get_formatted_ip_address_info(ip_address)
      geodata_cache[ip_address] = result
      result
  else
    null


#========== APP CODE
createApiResponse = (req) =>
  ip_address = req.ip
  ip_address = ip_address.split(":")[0] if ip_address
  JSON.stringify
    result: get_geodata_info(ip_address),

#========== Express Framework configuration
app.use(express.static('public'))

app.get '/geo.json', (req, res) ->
  res.contentType('application/json')
  res.send createApiResponse req

console.log('starting server...', server_ip_address, server_port)
server = app.listen( server_port, server_ip_address )