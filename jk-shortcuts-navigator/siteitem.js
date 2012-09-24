(function() {
  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
templates['siteitem'] = template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var buffer = "", stack1, foundHelper, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div class=\"title\">\n<span class=\"clicktoedit\">Click to edit</span>\n";
  foundHelper = helpers.site;
  if (foundHelper) { stack1 = foundHelper.call(depth0, {hash:{}}); }
  else { stack1 = depth0.site; stack1 = typeof stack1 === functionType ? stack1() : stack1; }
  buffer += escapeExpression(stack1) + "\n\n</div>\n<div class=\"edit\">\n<input type=\"text\" name=\"site\" value=\"";
  foundHelper = helpers.site;
  if (foundHelper) { stack1 = foundHelper.call(depth0, {hash:{}}); }
  else { stack1 = depth0.site; stack1 = typeof stack1 === functionType ? stack1() : stack1; }
  buffer += escapeExpression(stack1) + "\" placeholder=\"Site Name\"/><br />\n<textarea name=\"opts\">\n";
  foundHelper = helpers.json_opts;
  if (foundHelper) { stack1 = foundHelper.call(depth0, {hash:{}}); }
  else { stack1 = depth0.json_opts; stack1 = typeof stack1 === functionType ? stack1() : stack1; }
  buffer += escapeExpression(stack1) + "\n</textarea><br />\n  <div class=\"buttons\">\n    <button class=\"savesite\">Save Site</button> <button href=\"#\" class=\"removesite\">Remove Site</button>\n  </div>\n</div>\n\n";
  return buffer;});
})();
