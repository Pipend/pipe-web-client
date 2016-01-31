{map, id, each} = require \prelude-ls
{fill-intervals} = require \./_utils
fill-intervals-f = fill-intervals

module.exports = ({Plottable, nv, plot-chart}:params) ->
    {plotter, options} = (require \./nv-template) params
    new Plottable do
        plotter do
            # RefinedSeries :: {key :: String, values :: [a], color :: String, ...}
            # [RefinedSeries] -> Options -> [ProjectedSeries]
            (refined-series, {fill-intervals, x, y}) ->
                refined-series |> map ({values}:series) ->

                    # fill intervals with 0 or options.fill-intervals (if its a number)
                    projected-values = values
                        |> map -> [(x it), (y it)]
                        |> ->
                            if fill-intervals is not false 
                                fill-intervals-f do 
                                    it
                                    if fill-intervals is true then 0 else fill-intervals
                            else
                                it

                    {} <<< series <<< values: projected-values

            # Map String, NVModel -> NVModel
            (.multi-bar-chart)

            # Chart -> DOMElement -> [SeriesWithTrendline] -> Options -> Void
            (chart, , , options) !->
                {group-spacing, reduce-x-ticks, rotate-labels, show-controls, show-legend, transition-duration} = options
                chart
                    .x (.0)
                    .y (.1)
                    .duration transition-duration
                    .group-spacing group-spacing
                    .reduce-x-ticks reduce-x-ticks
                    .rotate-labels rotate-labels
                    .show-controls show-controls
                    .show-legend show-legend

        {} <<< options <<<
            group-spacing: 0.1 # Distance between each group of bars.
            reduce-x-ticks: false # If 'false', every single x-axis tick label will be rendered.
            rotate-labels: 0 # Angle to rotate x-axis labels.
            show-controls: true
            show-legend: true
            transition-duration: 300