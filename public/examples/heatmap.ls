points = [0 til 100]
    |> map ->
        x: Math.random! * 850
        y: Math.random! * 300
        value: Math.random! * 30

## this is the data structure required by heatmap
'''
data :: {
    max :: Number
    data :: [{
        x :: Number,
        y :: Number,
        value :: Number
    }]
}
'''
data =
    max: points 
        |> map (.value) 
        |> maximum
    data: points

## the right hand side is what goes in the presentation layer
func = plot heatmap `with-options` {
    width: 850
    height: 300
    background-color: \black
}

[data, func]