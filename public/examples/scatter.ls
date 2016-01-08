shapes = ['circle', 'cross', 'triangle-up', 'triangle-down', 'diamond', 'square']

## this is the data structure required by scatter
''' 
data :: [{
    key :: String,
    values :: [{x :: Number, y :: Number, size :: Int, shape :: String}]
}]
'''
data = [0 til 3] |> map ->
    key: "group #{it}"
    values:
        [0 til 15] |> map -> 
            x: Math.floor Math.random! * 100
            y: Math.floor Math.random! * 10
            size: it
            shape: shapes[it % (shapes.length - 1)]

## the right hand side is what goes in the presentation layer
func = plot scatter `with-options` {
    margin:
        left: 80
        right: 40
    x-axis:
        label: 'x axis'
    y-axis:
        label: 'y axis'
}

[data, func]