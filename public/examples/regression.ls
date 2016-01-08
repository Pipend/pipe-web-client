## this is the data structure required by regression
## data :: [{x :: Number, y :: Number, size :: Int}]
data = [0 til 15] |> map -> 
    x: Math.floor Math.random! * 100
    y: Math.floor Math.random! * 100
    size: it

## the right hand side is what goes in the presentation layer
func = plot regression `with-options` {
    margin:
        top: 40
        left: 80
        right: 40
    x-axis:
        label: 'x axis'
    y-axis:
        label: 'y axis'
    tooltip: ({x , y, size}) -> "x: #{x}, y: #{y}, size: #{size}"
}

[data, func]