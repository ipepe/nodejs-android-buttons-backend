module.exports = {
  # ========== MAXMIND DATABASE SETUP
  _geodataCity: (require('maxmind-db-reader').openSync('./GeoLite2-City.mmdb'))
  _geodata_cache: {}
  get_formatted_ip_address_info: (ip_address)->
    result = @_geodataCity.getGeoDataSync(ip_address)
    if result
      formatted_result = result.location
      formatted_result.country_code = result?.country?.iso_code
      formatted_result.country_name = result?.country?.names?.en
      formatted_result.ip_address = ip_address
      formatted_result
    else
      null

  get_ip_address_geodata_info: (ip_address)->
    if ip_address
      if @_geodata_cache[ip_address] != undefined
        @_geodata_cache[ip_address]
      else
        result = @get_formatted_ip_address_info(ip_address)
        @_geodata_cache[ip_address] = result
        result
    else
      null
}