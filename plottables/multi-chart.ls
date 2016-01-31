{each, filter, map, id, unique} = require \prelude-ls
$ = require \jquery-browserify

module.exports = ({Plottable, nv, plot-chart}:params) ->
    {plotter, options} = (require \./nv-template) params
    new Plottable do
        plotter do
            # RefinedSeries :: {key :: String, values :: [a], color :: String, ...}
            # [RefinedSeries] -> Options -> [ProjectedSeries]
            (refined-series, {x, y}) -> 
                refined-series |> map ({values}:series) -> {} <<< series <<< 
                    values: values |> map -> x: (x it), y: (y it)

            # Map String, NVModel -> NVModel
            (.multi-chart)

            # Chart -> DOMElement -> [SeriesWithTrendline] -> Options -> ()
            (chart, view, , {y-axis1, y-axis2}) !->
                [
                    [(.y-axis1.tick-format), y-axis1.format]
                    [(.y-axis1.axis-label), y-axis1.label]
                    [(.y-axis1.axis-label-distance), y-axis1.distance]
                    [(.y-axis2.tick-format), y-axis2.format]
                    [(.y-axis2.axis-label), y-axis2.label]
                    [(.y-axis2.axis-label-distance), y-axis2.distance]
                ] 
                    |> filter -> !!it.1
                    |> each ([f, prop]) ~> (f chart) prop

                if (typeof y-axis1?.show) == \boolean
                    $ view .find \div .toggle-class \hide-y1, !y-axis1.show

                if (typeof y-axis2?.show) == \boolean
                    $ view .find \div .toggle-class \hide-y2, !y-axis2.show

        {} <<< options <<<
            y-axis1:
                format: id
                label: null
                show: true
            y-axis2:
                format: id
                label: null
                show: true