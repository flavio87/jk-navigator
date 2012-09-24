class SiteModel extends Backbone.Model
  getOpts: () ->
    json = JSON.stringify @get('opts')
    json

class SiteCollection extends Backbone.Collection
  model:SiteModel
  localStorage: new Backbone.LocalStorage("JKSites")

Sites = new SiteCollection()

window.Sites = Sites
window.SiteModel = SiteModel
