{each, concat-map, map, unique, sort, find, id, zip-with} = require \prelude-ls
{fill-intervals, trend-line, rextend} = require \./_utils
fill-intervals-f = fill-intervals

module.exports = ({Plottable, plot-chart, d3, nv}) -> new Plottable do
    (view, result, {x, y, margin, y-axis, x-axis, show-legend, show-controls, use-interactive-guideline, clip-edge, fill-intervals, key, values, color}, continuation) !-->

        <- nv.add-graph 

        all-values = result 
            |> concat-map (-> (values it) |> concat-map x) 
            |> unique 
            |> sort

        if fill-intervals is not false
            all-values := all-values 
                |> map (-> [it, 0]) 
                |> (-> fill-intervals-f it, if fill-intervals is true then 0 else fill-intervals) 
                |> map (.0)
        
        result := result |> map (d) ->
            key: key d
            values: all-values |> map (v) -> 
                    [
                        v
                        (values d) 
                            |> find (-> (x it) == v) 
                            |> (-> if !!it then (y it) else (fill-intervals))
                    ]
            color: color d

        chart = nv.models.stacked-area-chart!
            .x (.0)
            .y (.1)
            .use-interactive-guideline use-interactive-guideline
            .show-controls show-controls
            .clip-edge clip-edge
            .show-legend show-legend


        chart
            ..x-axis.tick-format x-axis.format
            ..y-axis.tick-format y-axis.format
            ..margin margin

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
        margin: {top: 20, right:20, bottom: 50, left: 50}
        key: (.key)
        values: (.values)
        color: (.color)
        show-legend: true
        show-controls: true
        clip-edge: true
        fill-intervals: false
        use-interactive-guideline: true
        x-axis: 
            format: (timestamp)-> (d3.time.format \%x) new Date timestamp
            label: null
            distance: 0
        y-axis:
            format: (d3.format ',')
            label: null
            distance: 0
    }