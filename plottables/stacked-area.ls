{each, concat-map, map, unique, sort, find, id, zip-with} = require \prelude-ls
{fill-intervals, trend-line, rextend} = require \./_utils
fill-intervals-f = fill-intervals

module.exports = ({Plottable, plot-chart, d3, nv}:params) -> 
    {plotter, options} = (require \./nv-template) params
    new Plottable do
        plotter do 
            # [a] -> Options -> [b]
            (items, {fill-intervals, x, y}) ->
                items 
                    |> map -> [(x it), y it]
                    |> ->
                        if fill-intervals is not false 
                            fill-intervals-f do 
                                it
                                if fill-intervals is true then 0 else fill-intervals
                        else
                            it
            
            # Map String, NVModel -> NVModel
            (.stacked-area-chart)

            # Chart -> DOMElement -> [Series] -> Options -> Void
            (chart, view, result, {clip-edge, show-controls, show-legend, use-interactive-guideline}) !->
                chart
                    .x (.0)
                    .y (.1)
                    .clip-edge clip-edge
                    .show-controls show-controls
                    .show-legend show-legend
                    .use-interactive-guideline use-interactive-guideline

        {} <<< options <<<
            clip-edge: true
            fill-intervals: false
            show-legend: true
            show-controls: true
            use-interactive-guideline: true