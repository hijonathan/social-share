$ = jQuery
hs = window.hubspotShare


generate = (shareType, data) ->
    if shareType is 'twitter'
        c = hs.TwitterShare
    else if shareType is 'facebook'
        c = hs.FacebookShare
    else return

    new c(data).render()

$ ->
    $('.create-code').click (evt) ->
        evt.preventDefault()

        $button = $ @
        $form = $button.parents 'form'
        $target = $ $form.data 'output'
        shareType = $form.attr 'id'

        valStr = $form.formSerialize()
        valArray = valStr.split '&'

        formVals = {}
        for pair in valArray
            vals = pair.split '='
            formVals[vals[0]] = vals[1]

        if shareType is 'twitter'
            formVals.bindOpts = {}
            formVals.bindOpts[formVals.bindEvent] = ->
                img = new Img()
                img.onload ->
                    window.location.href = formVals.redirect_url
                img.src = formVals.bindCallback

        else if shareType is 'facebook'
            formVals.success = ->
                img = new Img()
                img.onload ->
                    window.location.href = formVals.redirect_url
                img.src = formVals.bindCallback

        code = generate shareType, formVals
        $target.val code
