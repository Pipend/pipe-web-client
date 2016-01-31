{each, concat-map, map, unique, sort, find, id, unique, zip-with} = require \prelude-ls
{fill-intervals, trend-line, rextend} = require \./_utils
fill-intervals-f = fill-intervals

module.exports = ({Plottable, plot-chart, d3, nv}:params) -> 
    {plotter, options} = (require \./nv-template) params
    new Plottable do
        plotter do
            # RefinedSeries :: {key :: String, values :: [a], color :: String, ...}
            # [RefinedSeries] -> Options -> [ProjectedSeries]
            (refined-series, {fill-intervals, x, y}) ->

                # all-values-on-x-axis :: [Number]
                all-values-on-x-axis = refined-series 
                    |> concat-map (.values) 
                    |> map -> (x it)
                    |> unique
                    |> sort
                    |> map -> [it, 0]
                    |> -> if fill-intervals is not false then (fill-intervals-f it, 0) else it
                    |> map (.0)

                refined-series |> map ({values}:series) ->

                    # iterate through all the points on x-axis and extract the y-value from the running series
                    new-values = all-values-on-x-axis |> map (value-on-x-axis) ->
                        
                        # in other words, find a point in this series whose x-value matches the running value
                        point? = values |> find -> value-on-x-axis == x it

                        # if this series does indeed have point whose x-value matches the running value then use that points y-value
                        # otherwise use (options.fill-intervals :: Number | Boolean) as y-value
                        [value-on-x-axis, (if !!point then (y point) else Number(fill-intervals))]

                    {} <<< series <<< values: new-values

            # Map String, NVModel -> NVModel
            (.stacked-area-chart)

            # Chart -> DOMElement -> [SeriesWithTrendline] -> Options -> ()
            (chart, , , {clip-edge, show-controls, show-legend, use-interactive-guideline}) !->
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