{each, map, id, unique} = require \prelude-ls
$ = require \jquery-browserify

module.exports = ({Plottable, nv, plot-chart}) -> new Plottable do 
    (view, result, {x, y, key, values, x-axis, y-axis1, y-axis2, margin}:options, continuation) !-->

        <- nv.add-graph

        result := result |> map (item) -> 
            {} <<< item <<< {
                key: (key item)
                values: (values item)
                    |> map ->
                        {
                            x: x it
                            y: y it
                        }
            }

        chart = nv.models.multi-chart!
            ..x-axis.tick-format x-axis.format
            ..y-axis1.tick-format y-axis1.format
            ..y-axis2.tick-format y-axis2.format
            ..margin margin

        [
            [x-axis.label, (.x-axis.axis-label)]
            [x-axis.distance, (.x-axis.axis-label-distance)]
            [y-axis1.label, (.y-axis1.axis-label)]
            [y-axis1.distance, (.y-axis1.axis-label-distance)]
            [y-axis2.label, (.y-axis2.axis-label)]
            [y-axis2.distance, (.y-axis2.axis-label-distance)]
        ] |> each ([prop, f]) ->
            if prop is not  null
                (f chart) prop

        plot-chart view, result, chart
        
        if (typeof options?.y-axis1?.show) == \boolean
            $ view .find \div .toggle-class \hide-y1, !options.y-axis1.show

        if (typeof options?.y-axis2?.show) == \boolean
            $ view .find \div .toggle-class \hide-y2, !options.y-axis2.show

        <- continuation chart, result
        chart.update!

    {
        key: (.key)
        values: (.values)
        x: (.0)
        y: (.1)
        y-axis1:
            format: id
            label: null
            show: true
        y-axis2:
            format: id
            label: null
            show: true
        x-axis:
            format: id
            label: null
            distance: 0
        margin: {top: 30, right: 60, bottom: 50, left: 70}
    }