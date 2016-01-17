module.exports = ({Plottable, nv}:params) -> 
    {plotter, options, continuations, projection} = (require \./histogram) params
    new Plottable do
        plotter
        options
        continuations
        (data, options) -> [{key: "", values: data}] |> ((fdata) -> projection fdata, options)