## this is the data structure required by correlation-matrix
## data :: [Map String, Number]
data = [0 til 30] |> map -> 
    sepal-length: Math.random! * 30
    sepal-width: Math.random! * 30
    petal-length: Math.random! * 30
    petal-width: Math.random! * 30

## the right hand side is what goes in the presentation layer
func = plot correlation-matrix `with-options` {
    traits: <[sepalLength sepalWidth petalLength petalWidth]>
}

[data, func]