Router = new Cartograph ->

  @map "/test", ->

  @map "/:slug", ChannelsController.action("show")

Router.routeRequest()
