## this is the data structure required by multi-bar-horizontal
''' 
data :: [{
    key :: String
    values :: [[Number, Number]]
}]
'''
data = 
    * key: \square
      values: [0 til 10] |> map -> 
        [it, it * it]
    * key: \line
      values: [0 til 10] |> map -> 
        [it, -it]
      color: \orange

## the right hand side is what goes in the presentation layer
func = plot multi-bar-horizontal `with-options` {
    margin:
        left: 80
        right: 40
    x-axis:
        label: \x-axis
    y-axis:
        label: \y-axis
    show-values: true
    stacked: false
}

[data, func]