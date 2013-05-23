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

@ChannelsController = ChannelsController
