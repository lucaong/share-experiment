class MessageFormWidget

  constructor: ( selector, context ) ->
    $( selector ).on "submit keyup", ( event ) ->
      return true if event.type is "keyup" and event.which isnt 13

      event.preventDefault()

      author = context.authorCookie.get()
      unless author?
        $("#author_prompt").modal()
        return true

      $input = $(@).find("[name=body]")
      body   = $input.val()
      slug   = context.params.slug
      $input.val("")

      if body.length
        $.post( "/#{slug}", { body: body, author: author }, "json" )
          .fail ->
            alert "Failed sending message"

@MessageFormWidget = MessageFormWidget
