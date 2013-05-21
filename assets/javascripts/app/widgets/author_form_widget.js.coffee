class AuthorFormWidget

  constructor: ( selector, context ) ->
    $( selector ).on "submit keyup", ( event ) ->
      return true if event.type is "keyup" and event.which isnt 13

      event.preventDefault()
      $form = $(@)
      name  = $form.find("[name=author_name]").val()

      if name.length
        context.authorCookie.set( name )
        $form.modal("hide")
        $("#new_message").submit()

@AuthorFormWidget = AuthorFormWidget
