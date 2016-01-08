{each, map, id} = require \prelude-ls

module.exports = ({Plottable, d3, plot-chart, nv}) -> new Plottable do
    (view, result, {x, y, key, values, color, maps, stacked, x-axis, y-axis, margin, show-values, tooltips, tooltip, transition-duration, show-controls}, continuation) !-->
        <- nv.add-graph

        result := result |> map (ds) ->
            key: key ds
            values: (values ds) |> map -> 
                label: x it
                value: (y it) |> maps[key ds]?.0 ? id
            color: color ds

        chart = nv.models.multi-bar-horizontal-chart!
            .x (.label)
            .y (.value)
            .margin margin
            .show-values show-values
            .show-controls show-controls
            .stacked stacked
        
        chart
            ..x-axis.tick-format x-axis.format
            ..y-axis.tick-format y-axis.format

        [
            [x-axis.label, (.x-axis.axis-label)]
            [x-axis.distance, (.x-axis.axis-label-distance)]
            [y-axis.label, (.y-axis.axis-label)]
            [y-axis.distance, (.y-axis.axis-label-distance)]
        ] |> each ([prop, f]) ->
            if prop is not  null
                (f chart) prop

        <- continuation chart, result

        plot-chart view, result, chart

        chart.update!

    {
        x: (.0)
        y: (.1)
        stacked: true
        x-axis:
            format: id
            label: null
            distance: 0
        y-axis:
            format: d3.format ',.2f'
            label: null
            distance: 0
        margin: top: 30, right: 20, bottom: 50, left: 175
        show-values: true
        tooltips: true
        tooltip: (key, x, y, e, graph) ->
            '<h3>' + key + ' - ' + x + '</h3>' +
            '<p>' +  y + '</p>'
        transition-duration: 350
        show-controls: true
        key: (.key)
        values: (.values)
        color: (.color)
        maps: {}
    }