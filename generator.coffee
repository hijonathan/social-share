$ = jQuery
hs = window.hubspotShare


$ ->
    $('.create-code').click (evt) ->
        evt.preventDefault()

        $button = $ @
        $form = $button.parents 'form'
        $target = $ $form.data 'output'
        $live = $ $form.data 'test-output'
        shareType = $form.attr 'id'

        valStr = decodeURIComponent $form.formSerialize()
        valArray = valStr.split '&'

        formVals = {}
        for pair in valArray
            vals = pair.split '='
            formVals[vals[0]] = vals[1]

        if shareType is 'twitter'
            c = hs.TwitterShare

        else if shareType is 'facebook'
            c = hs.FacebookShare

        shareInstance = new c formVals
        code = shareInstance.render()
        $target.val code

        # Insert code into page for a live test
        $live.html code
