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
  "selectors":undefined,
  "search_selector":undefined,
  "paginator_selector_next":undefined,
  "paginator_selector_prev":undefined,
  "liveUpdateElement"
  "allowSubdomains":undefined,
  "infiniteScroll":undefined
}
'''

class SiteView extends Backbone.View
  tagName:'li'
  
  events: {
    'click .title': 'editSite'
    'click .savesite': 'saveSite'
    'click .removesite': 'removeSite'
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
    values = {
      site: @$('input[name=site]').val()
    }
   
    opts = @validateOpts()
    if opts == false
      return
    else
      values['opts'] = opts

    if not @model
      @model = Sites.create(values)
    else
      @model.set(values)
      @model.save()
    
    @editMode = false
    @$el.removeClass('editable')

    # Remove addnew item
    if @addnew
      @remove()

  validateOpts: () ->
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
    
    return opts

  removeSite: () ->
    if @model
      @model.destroy()
    else
      @remove()
    

class OptionPane extends Backbone.View
  el:'body'

  events: {
    'click .addsite': 'addSite',
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
#    el = $('<li>').html(Handlebars.templates.siteitem({site:'New Site'}))
#    el.addClass('addnew')
#    @$(".customsites").prepend(el)

    view = new SiteView({addnew:true})
    
    @$(".customsites").prepend(view.render().el)
 
$(() ->
  options = new OptionPane()
#  options.initialize()
)
