{each, id} = require \prelude-ls

module.exports = ({Plottable, plot-chart, d3, nv}:params) -> 
    {plotter, options} = (require \./nv-template) params
    new Plottable do
        plotter do 
            # RefinedSeries :: {key :: String, values :: [a], color :: String, ...}
            # [RefinedSeries] -> Options -> [ProjectedSeries]
            id
            
            # Map String, NVModel -> NVModel
            (.scatter-chart)

            # Chart -> DOMElement -> [SeriesWithTrendline] -> Options -> ()
            (chart, , , {show-legend}) !->
                chart
                    .show-legend show-legend

        {} <<< options <<<
            show-legend: true
            x: (.x)
            y: (.y)