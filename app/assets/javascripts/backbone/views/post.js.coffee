class Sugar.Views.Post extends Backbone.View
  el: $('div.post')

  events:
    'click a.quote_post': 'quote'
    'click a.edit_post': 'edit'

  initialize: ->
    if $(this.el.id)
      this.model = this.modelFromExistingElement()
    else
      this.model = new Sugar.Models.Post()

  modelFromExistingElement: ->
    if this.el.id.match(/([\d]+)$/)
      id = this.el.id.match(/([\d]+)$/)[1]
    else
      id = null

    new Sugar.Models.Post({
      id:            id,
      user_id:       $(this.el).data('user_id'),
      exchange_id:   $(this.el).data('exchange_id'),
      body:          this.stripWhitespace(this.$('.body .content').html())
    })

  stripWhitespace: (string) ->
    string
      .replace(/^[\s]*/, '') # Strip leading space
      .replace(/[\s]*$/, '') # Strip trailing space

  wrapInBlockquote: (string) ->
    ("> " + line for line in string.split("\n")).join("\n")

  render: ->
    view = this
    this.$('.post_functions').each ->
      links = []
      if currentUser = Sugar.getCurrentUser()
        if view.model.editableBy(currentUser)
          links.push '<a href="#" class="edit_post">Edit</a>'
        links.push '<a href="#" class="quote_post">Quote</a>'
      $(this).html(links.join(' | '))

    this.applyAmazonReferralCode()
    this.applySpoiler()
    this

  edit: (event) ->
    event.preventDefault();
    this.$('.body').hide()
    $(this.el).append("<div class=\"edit\"><span class=\"ticker\">Loading...</span></div>")
    this.$('.edit').load this.model.editUrl(timestamp: true), ->
      $(Sugar).trigger('modified')

  # Quote the post
  quote: (event) ->
    event.preventDefault();

    if window.getSelection? and window.getSelection().containsNode(this.el, true)
      content = window.getSelection().toString()
    else
      content = this.model.get('body')

    if $(this.el).hasClass('me_post')
      username  = $(this.el).find('.body .poster').text()
    else
      permalink = $(this.el).find('.post_info .permalink a').get()[0].href.replace(/^https?:\/\/([\w\d\.:\-]*)/, '')
      username  = $(this.el).find('.post_info .username a').text()

    if permalink
      cite = "Posted by [#{username}](#{permalink}):"
    else
      cite = "Posted by #{username}:"

    quotedPost = this.wrapInBlockquote("<cite>#{cite}</cite>\n\n#{toMarkdown content}")

    Sugar.compose({add: quotedPost})

  # Apply functionality to spoiler tags
  applySpoiler: ->
    $(this.el).find('.spoiler').each ->
      if $(this).find('.innerSpoiler').length == 0
        $(this)
          .wrapInner('<span class="innerSpoiler"></span>')
          .prepend('<span class="spoilerLabel">Spoiler!</span> ')

        $(this).find('.innerSpoiler').css('visibility', 'hidden')
        $(this).click ->
          if $(this).hasClass('revealed')
            $(this).removeClass('revealed').find('.innerSpoiler').css('visibility', 'hidden')
          else
            $(this).addClass('revealed').find('.innerSpoiler').css('visibility', 'visible')

  # Apply referral code to Amazon links
  applyAmazonReferralCode: ->
    if referral_id = Sugar.Configuration.AmazonAssociatesId
      $(this.el).find('.body a').each ->
        link = this
        if !$.data(link, 'amazon_associates_referral_id') && link.href.match /https?:\/\/([\w\d\-\.])*(amazon|junglee)(\.com?)*\.([\w]{2,3})\//
          $.data(link, 'amazon_associates_referral_id', referral_id)
          return if link.href.match /(\?|&)tag=/

          link.href += if link.href.match(/\?/) then '&' else '?'
          link.href += 'tag=' + referral_id

