class MessageFormWidget

  constructor: ( selector, context ) ->
    $( selector ).on "submit keyup", ( event ) ->
      return true if event.type is "keyup" and event.which isnt 13

      author = context.authorCookie.get()
      unless author?
        $("#author_prompt").modal()
        return true

      event.preventDefault()

      $input = $(@).find("[name=body]")
      body   = $input.val()
      slug   = context.params.slug
      $input.val("")

      if body.length
        $.post( "/#{slug}", { body: body, author: author }, "json" )
          .done ( data ) ->
            context.pubsub.publish "/channels/#{slug}", data
          .fail ->
            alert "Failed sending message"

@MessageFormWidget = MessageFormWidget
