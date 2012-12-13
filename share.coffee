hs = window.hubspotShare ?= {}

hs.TWITTER_MOCK =
    text: "All the resources you need to keep your marketing passion satiated. Download the Marketer's Survival Kit"
    url: 'http://bit.ly/Ub6gz1'
    via: 'HubSpot'
    related: 'HubSpot'
    bindOpts:
        tweet: (evt) ->
            alert 'you tweeted'
        retweet: (evt) ->
            alert 'you retweeted'
        follow: (evt) ->
            alert 'you followed'
        favorite: (evt) ->
            alert 'you favorited'
        click: (evt) ->
            alert 'you clicked'


hs.FACEBOOK_MOCK =
    appId: '123050457758183'
    name: 'People Argue Just to Win'
    caption: 'Bringing Facebook to the desktop and mobile web'
    description: "A small JavaScript library that allows you to harness the power of Facebook, bringing the user's identity, social graph and distribution power to your site."
    link: 'http://bit.ly/Ub6gz1'
    picture: 'http://www.fbrell.com/public/f8.jpg'
    success: (response) ->
        alert 'you did it!'
    fail: (response) ->
        alert 'you suck'


class hs.TwitterShare

    constructor: (@data) ->
        @ENDPOINT_BASE = "https://twitter.com/share"
        @bindOpts = @data.bindOpts

    render: ->
        @_renderButton() + @_renderScript()

    _renderButton: ->
        attrs = @_buildAttrs()
        """<a href="#{@ENDPOINT_BASE}" class='twitter-share-button' #{attrs}>Tweet</a>"""

    _buildAttrs: ->
        data = {}
        data.text = @data.text
        data.url = @data.url
        data.via = @data.via
        data.related = @data.related

        # Some encoding
        data.text = data.text.replace /\s/g, '+'
        data.url = encodeURIComponent data.url

        data.lang = 'en'
        data.size = 'large'
        data.count = 'none'

        attrStr = ''
        _(data).each (v, k) ->
            attrStr += "data-#{k}=\"#{v}\" "

        attrStr

    _renderScript: ->
        """
        <script type="text/javascript" charset="utf-8">
            window.twttr = (function (d,s,id) {
                var t, js, fjs = d.getElementsByTagName(s)[0];
                if (d.getElementById(id)) return; js=d.createElement(s); js.id=id;
                js.src="http://platform.twitter.com/widgets.js"; fjs.parentNode.insertBefore(js, fjs);
                return window.twttr || (t = { _e: [], ready: function(f){ t._e.push(f) } });
            }(document, "script", "twitter-wjs"));
            twttr.ready(function(twttr) {
                #{@_renderListeners()}
            });
        </script>
        """

    _renderListeners: ->
        listeners = ""
        _(@bindOpts).each (callback, eventType) ->
            listeners += "twttr.events.bind('#{eventType}', #{String(callback)});\n"

        listeners

class hs.FacebookShare

    constructor: (@data) ->
        @ENDPOINT_BASE = 'https://www.facebook.com/dialog/send'
        @buttonId = "hubspot-facebook-button-#{+new Date}"
        @success = @data.success
        @fail = @data.fail

    render: ->
        @_renderBoilerPlate() +
        @_renderButton() +
        @_renderScript()

    _renderBoilerPlate: ->
        # Required in order to use the JS SDK
        "<div id='fb-root'></div>"

    _renderButton: ->
        "<a id='#{@buttonId}'>Share</a>"

    _renderScript: ->
        """
        <script>
            window.fbAsyncInit = function() {
                #{@_renderInit()}
                #{@_renderListeners()}
            };
            #{@_renderSDKSource()}
        </script>
        """

    _renderInit: ->
        optionsStr = JSON.stringify @_optionsJSON()
        """
        FB.init(#{optionsStr});
        """

    _optionsJSON: ->
        appId: @data.appId
        status: true
        cookie: true
        xfbml: true

    _renderListeners: ->
        dataStr = JSON.stringify @_dataJSON()
        """
        document.getElementById("#{@buttonId}").addEventListener('click', function(evt) {
            FB.ui(#{dataStr}, function(response) {
                try {
                    if (response && response.post_id) {
                        (#{String(@success)}(response));
                    } else {
                        (#{String(@fail)}(response));
                    }
                } catch (e) {
                    return
                }
            });
        }, false);
        """

    _dataJSON: ->
        method: 'feed'
        name: @data.name
        caption: @data.caption
        description: @data.description
        link: @data.link
        picture: @data.picture

    _renderSDKSource: ->
        """
        (function(d, debug){
            var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
            if (d.getElementById(id)) {return;}
            js = d.createElement('script'); js.id = id; js.async = true;
            js.src = "http://connect.facebook.net/en_US/all" + (debug ? "/debug" : "") + ".js";
            ref.parentNode.insertBefore(js, ref);
        }(document, /*debug*/ false));
        """

hs.t = new hs.TwitterShare(hs.TWITTER_MOCK).render()
hs.f = new hs.FacebookShare(hs.FACEBOOK_MOCK).render()
