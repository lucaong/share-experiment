class Controller

  @action: ( name ) ->
    Self = @
    ( args... ) ->
      instance = new Self( args... )
      instance[ name ]()

  constructor: ( request = {} ) ->
    @request = request
    @params  = request.params

@Controller = Controller
