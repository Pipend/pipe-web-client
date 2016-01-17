{map, floor} = require \prelude-ls

ξ = (h, f, g) --> (x) -> (f x) `h` (g x)

module.exports = ({Plottable, d3, nv}:params) -> 
    {plotter, options, continuations, projection} = (require \./scatter) params
    new Plottable do
        plotter
        ({} <<< options <<<
            k: -> "#{&0}_#{&1}_#{floor Math.random!*10000}")
        continuations
        (data, {k, x, y}?) -> 
            projection do 
                data |> map (item) ->
                    {} <<< item <<<
                        key: (ξ k, x, y) item
                        values: [item]
                options
