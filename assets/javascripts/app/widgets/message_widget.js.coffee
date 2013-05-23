class MessageWidget

  constructor: ( message ) ->
    @message = message

  render: ->
    $li = $("<li>")
      .attr
        "data-created-at": @message.created_at,
        "data-time-ago":   moment( @message.created_at ).fromNow()
      .html( @message.body )
      .prepend $("<span class='author'>").html @message.author

@MessageWidget = MessageWidget
