{map} = require \prelude-ls
fill-intervals-f = (require \./_utils).fill-intervals

module.exports = ({Plottable, d3, plot-chart, nv}:params) -> 
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
            (.line-chart)

            # Chart -> DOMElement -> [SeriesWithTrendline] -> Options -> ()
            (chart) !-> chart .x (.0) .y (.1)

        {} <<< options <<<
            x-axis: 
                format: (timestamp) -> (d3.time.format \%x) new Date timestamp
                label: null
                distance: 0