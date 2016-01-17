{each} = require \prelude-ls

module.exports = ({Plottable, plot-chart, d3, nv}:params) -> 
    {plotter, options} = (require \./nv-template) params
    new Plottable do
        plotter do 
            # [a] -> Options -> [b]
            (items) -> items 
            
            # Map String, NVModel -> NVModel
            (.scatter-chart)

            # Chart -> DOMElement -> [Series] -> Options -> Void
            (chart, view, result, {show-legend}) !->
                chart
                    .show-legend show-legend

        {} <<< options <<<
            show-legend: true
            x: (.x)
            y: (.y)