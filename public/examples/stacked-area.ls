## this is the data structure required by stacked-area
''' 
data :: [{
    key :: String
    values :: [[Number, Number]]
}]
'''
data = 
    * key: \company1
      values: [0 til 30] |> map -> 
        [Date.now! + (it * 86400000), it * 20]
    * key: \company2
      values: [0 til 30] |> map -> 
        [Date.now! + (it * 86400000), it * it]
      color: \orange

## the right hand side is what goes in the presentation layer
func = plot stacked-area `with-options` {
    use-interactive-guideline: true
    show-controls: true
    show-legend: true
    margin:
        left: 80
        right: 40
    x-axis:
        label: \time
        format: (timestamp) -> (d3.time.format '%a %b %d') new Date timestamp
    y-axis:
        label: \growth
}

[data, func]