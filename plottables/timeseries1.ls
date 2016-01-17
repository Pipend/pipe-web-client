module.exports = ({Plottable, nv, d3}:params) -> 
    {plotter, options, continuations, projection} = (require \./timeseries) params
    new Plottable do
        plotter
        options
        continuations
        (data, options) -> 
            [{key: "", values: data}] |> ((fdata) -> projection fdata, options)