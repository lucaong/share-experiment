#= require lib/visibility.core
#= require app/widgets/message_widget
#= require app/widgets/message_form_widget
#= require app/widgets/author_form_widget

class ChannelsController extends Controller

  show: ->
    slug = @params.slug
    scrollToBottom()
    loopUpdateTimeAgo()

    @pubsub       = new Faye.Client "/faye"
    @authorCookie = new Cookie("#{slug}_author")

    @pubsub.subscribe "/channels/#{ slug }", ( message ) ->
      message_widget = new MessageWidget( message )
      $("ul.messages").append message_widget.render()
      notifyNewMessage()
      scrollToBottom()
      updateTimeAgo()

    new MessageFormWidget( "#new_message", @ )

    new AuthorFormWidget( "#author_prompt", @ )

  # private

  scrollToBottom = ->
    $ul = $("ul.messages")
    $ul.animate({ scrollTop: $ul[0].scrollHeight }, 500 )

  updateTimeAgo = ->
    $("ul.messages li").each ->
      $li = $(@)
      $li.attr "data-time-ago", moment( $li.data("createdAt") ).fromNow()

  loopUpdateTimeAgo = ->
    updateTimeAgo()
    setTimeout loopUpdateTimeAgo, 30000

  _original_title = null
  _flash_title_iter   = 0

  notifyNewMessage = ->
    _original_title ?= $("head title").text()
    flashTitleLoop( _original_title )

  flashTitleLoop = ( title ) ->
    if Visibility.hidden()
      flashTitle( title )
      setTimeout ( -> flashTitleLoop( title ) ), 1000
    else
      $("head title").text( title )

  flashTitle = ( title ) ->
    prefix = "-"
    if _flash_title_iter % 2
      prefix = "+"
    $("head title").text("#{prefix} #{title}")
    _flash_title_iter += 1

@ChannelsController = ChannelsController
