# This is a derivative work adapted from:
#   jQuery Cookie Plugin v1.3.1
#   https://github.com/carhartl/jquery-Cookie
#   Copyright 2013 Klaus Hartl
#   Released under the MIT license
#
# Usage:
#
#   fooCookie = new Cookie("foo")
#   fooCookie.set("bar", { expires: 5 }) # set expiration in 5 days
#   fooCookie.get() # => 'bar'
#   fooCookie.delete()
#

class Cookie

  constructor: ( @key, @_config = {} ) ->
    unless @key?
      throw new Error("cookie key was not provided")

    @_config.defaults ?= {}

  set: ( value, opts = {} ) ->
    unless value?
      throw new Error "cookie value should be provided"

    for own k, v of @_config.defaults
      opts[ k ] = v unless opts[ k ]?

    if typeof opts.expires is "number"
      days = opts.expires
      date = new Date()
      date.setDate( date.getDate() + days )
      opts.expires = date.toUTCString()

    value = if @_config.json then JSON.stringify( value ) else "#{value}"

    unless @_config.raw
      value = @_encode value
      key   = @_encode key

    serialized_options = for k, v of opts
      "#{k}=#{v || ''}"

    document.cookie = "#{@key}=#{value};#{serialized_options.join(';')}"

  get: ->
    cookies = document.cookie.split('; ')
    for cookie, i in cookies
      parts = cookie.split('=')
      name  = parts.shift()
      value = parts.join('=')

      unless @_config.raw
        name  = @_decode name
        value = @_decode value

      return @_convert( value ) if @key is name
    null

  delete: ( opts = {} ) ->
    return false if not @get?

    # Must not alter original opts
    opts_clone = {}
    for k, v of opts
      opts_clone[ k ] = v
    opts_clone.expires = -1
    @set @key, '', opts_clone
    true

  _decode: ( str ) ->
    decodeURIComponent str.replace( /\+/g, " " )

  _encode: ( str ) ->
    encodeURIComponent( str )

  _convert: ( str ) ->
    if /^"/.test str
      # This is a quoted cookie as according to RFC2068, unescape
      str = str[1...-1].replace(/\\"/g, '"').replace(/\\\\/g, '\\')

    if @_config.json
      JSON.parse str
    else
      str

@Cookie = Cookie
