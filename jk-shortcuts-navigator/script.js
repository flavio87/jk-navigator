// note: key library was modified to enable capture in addEventListener

(function() {
chrome.extension.sendMessage({action: 'getOpts', url: document.location.href}, function(site_data) {

    if (!site_data) { return; }
    chrome.extension.sendMessage({action: 'showPageAction'});
    if (site_data.enabled === false) { return; }

    var group_selector_all = null;
    var group_selector = null;
    var site_opts = site_data.opts;
    var site = site_data.site;
    var oldHTML = null;
    var isEnabled = true;

    function activeElement(idx) {
        return $(group_selector_all).slice(parseInt(idx), parseInt(idx)+1);
    }

    if (!localStorage.idx)
        localStorage.idx = 0;

    var previousSelection = null;
    var select = function(focus) {
        var link = activeElement(localStorage.idx);
        if (previousSelection) {
            if (link.get()[0] == previousSelection) {
                return link;
            }
            $(previousSelection).css('background-color', 'inherit');
        }
        link.css('background-color', '#fcc');
        if (focus) { link.focus(); }
        previousSelection = link.get()[0];
        return link;
    };

    var node = null;

    function start(focusResult) {
        if (!isEnabled) return;

        if (!group_selector) {
            $(site_opts.selectors).each(function(n, selector) {
                if (selector instanceof Array) {
                    group_selector_all = selector[0];
                    group_selector = selector[1];
                } else {
                    group_selector_all = selector.replace(':nth(*)', '');
                    group_selector = selector;
                }
                var result_links_container = $(group_selector_all);
                if (result_links_container.length) {
                    return false; // break
                } else {
                    group_selector = group_selector_all = null;
                }
            });
        }

        if (!group_selector)
            return;

        var result_links_container = $(group_selector_all);
        if (result_links_container.length) {
            //store the links into the local storage
            result_links = []
            result_links_container.each(function(m, link) {
                if (site == 'google') {
                    // HACK: Google rewrites links into tracking links when clicking them. Compare the text instead.
                    result_links.push($(link).text());
                } else {
                    result_links.push($(link).attr('href'));
                }
            });
            new_result_links = JSON.stringify(result_links);
            if (localStorage.result_links != new_result_links)
            {
                if ((focusResult || !site_opts.infiniteScroll) && localStorage.idx != -1) { localStorage.idx = 0; }
                localStorage.result_links = new_result_links;
            }
            localStorage.start_page = location.href;
            if (localStorage.idx == -1) {
                localStorage.idx = result_links.length-1;
            }
        }

        var newNode = activeElement(localStorage.idx);
        if (!node || (node != newNode)) {
            if (!localStorage.idx) {
                localStorage.idx = 0;

                select(focusResult);
                node = newNode.get()[0];
            }
            else {
                select(focusResult);
                node = newNode.get()[0];
            }
        }

    }

    var lock = false;
    var updateTimeout = null;

    $(function() {
        if (!site_opts) return;
        start(true);
        if (site_opts.liveUpdateElement) {
            var main = $(site_opts.liveUpdateElement).get()[0];
            if (main) {
                main.addEventListener("DOMSubtreeModified", function () {
                    if (updateTimeout) {
                        clearTimeout(updateTimeout);
                    }

                    updateTimeout = setTimeout(function() {
                        var newHTML = main && main.innerHTML;
                        if (newHTML == oldHTML)
                            return;

                        oldHTML = newHTML;

                        start(false);
                    }, 100);
                });
            }
        }

        //define what the different keystrokes do
        if (site_opts)
        {
            // Wraps the original function and doesn't execute it if there is a
            // contenteditable element or if isEnabled is false.
            var wrap = function(f) {
                var wrapped = function(ev) {
                    if ($('*[contenteditable=true]').is(':focus'))
                        return;

                    if (!isEnabled)
                        return;

                    return f(ev);
                };

                return wrapped;
            };
            key('j', wrap(function(ev) {
                if (group_selector) {
                    if (localStorage.idx < $(group_selector_all).length-1) {
                        localStorage.idx++;
                        select(true);
                    }
                    else {
                        if (site_opts.paginator_selector_next && $(site_opts.paginator_selector_next).length) {
                            localStorage.idx = 0;
                            location.href = $(site_opts.paginator_selector_next).attr('href');
                            isEnabled = false;
                        }
                    }
                    ev.stopPropagation();
                }
                else {
                    result_links = JSON.parse(localStorage.result_links);
                    if (link = result_links[++localStorage.idx]) {
                        location.href = link;
                        isEnabled = false;
                    }
                    else {
                       localStorage.idx--;
                    }

                }
            }));
            key('k', wrap(function(ev) {
                if (group_selector) {
                    if (localStorage.idx > 0) {
                        localStorage.idx--;
                        select(true);
                    }
                    else {
                        if (site_opts.paginator_selector_prev && $(site_opts.paginator_selector_prev).length && $(site_opts.paginator_selector_prev).attr('href') != 'javascript:;') {
                            localStorage.idx = -1;
                            location.href = $(site_opts.paginator_selector_prev).attr('href');
                            isEnabled = false;
                        }

                    }
                    ev.stopPropagation();
                }
                else {
                    result_links = JSON.parse(localStorage.result_links);
                    if (link = result_links[--localStorage.idx]) {
                        location.href = link;
                        isEnabled = false;
                    }
                    else {
                        localStorage.idx++;
                    }
                }
            }));
            key('/', wrap(function(ev) {
                if (site_opts.search_selector)
                    $(site_opts.search_selector).focus();
                ev.stopPropagation();
                ev.preventDefault();
            }));
            function open_link(ev, newWindow, force) {
                var link = select();

                // If no particular element is focused, open the selected link.
                // Else, use the browser implementation to open the focused link
                // which already does the right thing.
                if (force || ev.target == document.body) {
                    if (newWindow) {
                        window.open(link.attr('href'));
                    } else {
                        location.href = link.attr('href');
                    }
                    ev.stopPropagation();
                    ev.preventDefault();
                }
            }

            key('return', wrap(function(ev) {
                open_link(ev, false);
            }));

            key('⌘+return', wrap(function(ev) {
                open_link(ev, true);
            }));

            key('o', wrap(function(ev) {
                open_link(ev, false, true);
            }));

            key('i', wrap(function(ev) {
                if (group_selector) {
                    if (localStorage.idx > 0) {
                        localStorage.idx=0;
                        select(true);
                    }
                    ev.stopPropagation();
                }
                else {
                    location.href = localStorage.start_page;
                    isEnabled = true;
                }
            }));
        }
    });

});

})();
