builtInSites = {
  'google': {
    opts: {
      selectors: ['h3.r>a'],
      allowSubdomains: false,
      search_selector: '#gbqfq',
      paginator_selector_next: 'a#pnnext.pn',
      paginator_selector_prev: 'a#pnprev.pn',
      liveUpdateElement: '#main'
    },
    regex:'^https?://(www\.)?google\.([a-z\.]+)\/(?!reader\/).*$' # We need to exclude Google Reader
  },

  'news.ycombinator': {
    opts: {
      selectors: ['td.title > a, td.subtext > a:contains(comments), td.subtext > a:contains(discuss)'],
      paginator_selector_next: 'a.morelink',
      search_selector: 'center form input'
    },
    regex: 'https?://news\.ycombinator\.com\/.*'
  },
  'quora': {
    opts: {
      selectors: ['div.pagedlist_item:not(.pagedlist_hidden) a.question_link'],
      search_selector: '.question_box.light',
      infiniteScroll: true,
      liveUpdateElement: '.main .e_col .w4_5 main_col',
    },
    regex: 'https?://(www\.)?quora\.com\/.*'
  },
  'reddit': {
    opts: {
      selectors: ['#siteTable div.entry a.title'],
      search_selector: 'form#search input',
      paginator_selector_next: 'p.nextprev a:last-of-type',
      paginator_selector_prev: 'p.nextprev a:first-of-type'
    },
    regex: 'https?://(www\.)?reddit\.com\/.*'
  },
  'amazon': {
    opts: {
      selectors: ['h3.newaps>a', 'div.data h3.title a.title'],
      search_selector: '#twotabsearchtextbox',
      paginator_selector_next: '#pagnNextLink',
      paginator_selector_prev: '#pagnPrevLink'
    },
    regex: 'https?://(www\.)?amazon\.[a-z\.]+\/.*'
  },
  'ebay': {
    opts: {
      selectors: ['div.ittl a', 'div.ttl a', 'div.ititle a.vip'],
      search_selector: '#_fsb_nkw',
      paginator_selector_next: 'td.botpg-next a',
      paginator_selector_prev: 'td.botpg-prev a'
    },
    regex: 'https?://(www\.)?ebay\.[a-z\.]+\/.*'
  },
  'yelp': {
    opts: {
      selectors: ['div.businessresult h4.itemheading a'],
      search_selector: '#find_desc',
      paginator_selector_next: '#pager_page_next',
      paginator_selector_prev: '#pager_page_prev',
      liveUpdateElement: '#businessresults'
    },
    regex: 'https?://(www\.)?yelp\.com\/.*'
  },
  'craigslist': {
    opts: {
      selectors: ['p.row>a'],
      search_selector: '#query',
      paginator_selector_next: 'h4>span:last-of-type>a',
      paginator_selector_prev: 'h4>span:first-of-type>a'
    },
    regex: 'https?:\/\/(.*\.|)craigslist.org/.*'
  },
  'linkedin': {
    opts: {
      selectors: ['li.vcard>div>h2>a'],
      search_selector: '#keywords-search',
      paginator_selector_next: '.paginator-next',
      paginator_selector_prev: '.paginator-prev'
    },
    regex: 'https?://([a-z]+\.)?linkedin\.com\/.*'
  },
  'facebook': {
    opts: {
      selectors: [['#pagelet_home_stream li.uiStreamStory', '#pagelet_home_stream li.uiStreamStory a:nth(1)']],
      search_selector: 'input#q.inputtext.DOMControl_placeholder',
      liveUpdateElement: '#contentArea',
      infiniteScroll: true
    },
    regex: 'https?://(www\.)?facebook\.com\/.*'
  },
  'youtube': {
    opts: {
      selectors: ['li div div h3 a'],
      search_selector: '#masthead-search-term',
    }
    regex: 'https?://(www\.)?youtube\.com\/.*'
  },
  'stackoverflow|serverfault|superuser|askubuntu|stackexchange': {
    opts: {
      selectors: ['div h3 a.question-hyperlink'],
      search_selector: 'form#search div input.textbox',
    },
    regex: 'https?://([a-z]+\.)?(stackoverflow|serverfault|superuser|askubuntu|stackexchange).com\/.*'
  },
  'techcrunch': {
    opts: {
      selectors: ['h2.headline a'],
      paginator_selector_next: '.page-next>a',
      paginator_selector_prev: '.page-prev>a'
    },
    regex: 'https?://(www\.)?techcrunch\.com\/.*'
  },
  'lobsters': {
    opts: {
      selectors: ['li span.link a']
    },
    regex: 'https?://lobste\.rs\/.*'
  }
}


class SiteModel extends Backbone.Model
  getOpts: () ->
    json = JSON.stringify @get('opts'), undefined, '    '

  submitToJK: () ->
    if @get('onlineId')
      url = "http://http://jknavigator.herokuapp.com/api/v1/site/"+@get('onlineId')+"/"
      method = "PUT"
    else
      url = "http://jknavigator.herokuapp.com/api/v1/site/"
      method = "POST"
    json = _.pick(@.attributes, ['site', 'regex'])
    json['opts'] = @attributes['opts']
    $.ajax({
      type:method
      url:url
      processData: false
      data:JSON.stringify(json)
      contentType:'application/json'
    })

class SiteCollection extends Backbone.Collection
  model:SiteModel
  localStorage: new Backbone.LocalStorage("JKSites")
  addDefaults: () ->
    _.each(builtInSites, (value, key) ->
      Sites.create({
        site: key
        opts: value['opts']
        regex: if value['regex'] then value['regex'] else undefined
        builtin: true
      })
    )

  getSiteByUrl: (url) ->
    sites =  @filter((site) =>
      regex = site.get('regex')
      if not regex then return false
      regex = new RegExp(regex, 'i')
      r = regex.test(url)
    )
    if sites.length > 1 then console.warn("More than one site matched. Defaulted to the first match", sites)
    sites[0]

Sites = new SiteCollection()

$(document).ready(() ->
  # Add builtin sites to localStorage
  Sites.fetch()
  if Sites.models.length == 0
    Sites.addDefaults()
  
)

window.Sites = Sites
window.SiteModel = SiteModel
