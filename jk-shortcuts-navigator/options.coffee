# TODO: remove redundancy
valid_keys = [
    'selectors',
    'search_selector',
    'paginator_selector_next',
    'paginator_selector_prev',
    'allowSubdomains',
    'liveUpdateElement',
    'infiniteScroll'
  ]
defaultJSON = '''
{
  "selectors":null,
  "search_selector":null,
  "paginator_selector_next":null,
  "paginator_selector_prev":null,
  "liveUpdateElement":null,
  "allowSubdomains":null,
  "infiniteScroll":null
}
'''

class SiteView extends Backbone.View
  tagName:'li'

  events: {
    'click .title': 'editSite'
    'click .savesite': 'saveSite'
    'click .removesite': 'removeSite'
    'click .discard': 'discardChanges'
  }

  initialize: (options) ->
    @addnew = options.addnew
    if @model
      @model.bind('change', @render, @)
      @model.bind('destroy', @remove, @)

  render: () ->
    if @addnew
      opts = defaultJSON
    else
      opts = @model.getOpts()

    context = {
      addnew:@addnew
      json_opts:opts
    }

    if @model
      _.extend(context, @model.toJSON())
    html = Handlebars.templates.siteitem(context)
    @$el.html(html)

    if @addnew
      @$el.addClass('addnew')

    @

  editSite: () ->
    if @editMode or @addnew
      return
    @editMode = true
    @$el.addClass('editable')

  saveSite: () ->
    if not @validate()
      return

    @regex = @$('input[name=regex]').val()

    values = {
      'site':@site
      'opts':@opts
      'regex':@regex
      'modified':true
    }

    if not @model
      @model = Sites.create(values)
    else
      @model.set(values)
      @model.save()

    if @$('input[name=submittojk]').is(':checked')
      @model.submitToJK()

    @editMode = false
    @$el.removeClass('editable')


    # Remove addnew item
    if @addnew
      @remove()

  validate: () ->
    @site = @$('input[name=site]').val()
    if not @site
      return false

    opts = @$('textarea[name=opts]').val()
    try
      opts = JSON.parse(opts)
    catch error
      alert 'Invalid JSON'
      return false

    for k in _.keys(opts)
      if valid_keys.indexOf(k) == -1
        alert 'Unknown Key in Options: '+k
        return false

    @opts = opts
    return true

  removeSite: () ->
    if @model
      @model.destroy()
    else
      @remove()

  discardChanges: () ->
    @editMode = false
    @$el.removeClass('editable')
    @site = @$('input[name=site]').val(@model.get('site'))
    @$('textarea[name=opts]').val(@model.getOpts())


class OptionPane extends Backbone.View
  el:'body'

  events: {
    'click .addsite': 'addSite',
    'click .restoresites':'restoreSites',
  }

  initialize: () ->
    Sites.bind('add', this.addOne, @)
    Sites.bind('reset', this.addAll, @)
    Sites.bind('all', this.render, @)
    Sites.fetch()

  addOne: (site) ->
    view = new SiteView({model: site})
    @$(".customsites").prepend(view.render().el)

  addAll: ->
    Sites.each(@addOne)

  addSite: () ->
    view = new SiteView({addnew:true})

    @$(".customsites").prepend(view.render().el)

  restoreSites: ->
    sites = Sites.where({builtin:true})
    for s in sites
      s.destroy()
    Sites.addDefaults()

$(() ->
  options = new OptionPane()
#  options.initialize()
)
