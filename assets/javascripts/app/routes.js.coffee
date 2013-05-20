Router = new Cartograph ->

  @map "/test", ->

  @map "/:slug", ( request ) ->
    slug = request.params.slug
    scrollToBottom()
    updateTimeAgo()
    pubsub = new Faye.Client "/faye"
    pubsub.subscribe "/channels/#{ slug }", ( message ) ->
      $li = $("<li>")
        .attr
          "data-author":     message.author,
          "data-created-at": message.created_at,
          "data-time-ago":   moment( message.created_at ).fromNow()
        .html message.body
      $("ul.messages").append $li
      scrollToBottom()
      updateTimeAgo()

    $("#new_message").on "submit keyup", ( event ) ->
      return true if event.type is "keyup" and event.which isnt 13
      event.preventDefault()
      $input = $(@).find("[name=body]")
      body = $input.val()
      $input.val("")
      if body.length
        $.post( "/#{slug}", { body: body }, "json" )
          .done ( data ) ->
            pubsub.publish "/channels/#{slug}", data
          .fail ->
            alert "Failed sending message"

scrollToBottom = ->
  $ul = $("ul.messages")
  $ul.animate({ scrollTop: $ul[0].scrollHeight }, 500 )

updateTimeAgo = ->
  $("ul.messages li").each ->
    $li = $(@)
    $li.attr "data-time-ago", moment( $li.data("createdAt") ).fromNow()

Router.routeRequest()
