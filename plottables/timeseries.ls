{map, filter, id, concat-map, each} = require \prelude-ls
{fill-intervals, trend-line, rextend} = require \./_utils
fill-intervals-f = fill-intervals
trend-line-f = trend-line

module.exports = ({Plottable, d3, plot-chart, nv}:params) -> 
    {plotter, options} = (require \./nv-template) params
    new Plottable do
        plotter do
            # [a] -> Options -> [b]
            (items, {fill-intervals, x, y}) ->
                items 
                    |> map -> [(x it), (y it)]
                    |> ->
                        if fill-intervals is not false 
                            fill-intervals-f do 
                                it
                                if fill-intervals is true then 0 else fill-intervals
                        else
                            it

            # Map String, NVModel -> NVModel
            (.line-chart)

            # Chart -> DOMElement -> [Series] -> Options -> Void
            (chart, view, result, options) !->
                chart
                    .x (.0)
                    .y (.1)

        {} <<< options <<<
            x-axis: 
                format: (timestamp) -> (d3.time.format \%x) new Date timestamp
                label: null
                distance: 0