exports.getSrcProperty = (tagName) ->
  switch tagName
    when 'script' then 'src'
    when 'link' then 'href'
    else 'href'
