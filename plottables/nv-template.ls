{map, filter, id, concat-map, each} = require \prelude-ls
{fill-intervals, trend-line, rextend} = require \./_utils
fill-intervals-f = fill-intervals
trend-line-f = trend-line

module.exports = ({d3, nv}) -> 

    # DEFAULT PROPS
    options:
        key: (.key)
        values: (.values)
        color: (.color)
        margin: 
            top: 20
            right:20
            bottom: 50
            left: 50
        x: (.0)
        x-axis: 
            format: id
            label: null
            distance: 0
        y: (.1)
        y-axis:
            format: id
            label: null
            distance: 0
        force-y: null
        fill-intervals: false # Boolean | Number (assigns this value to empty intervals, if it is of type number)
        trend-line: null
        # trend-line: (key) ->
        #     name: "#key trend"
        #     sample-size: 0
        #     color: \red
        
    # Series :: {key :: String, values :: [a], color :: String}
    # (Chart -> [Series] -> Options -> Void) -> ([a] -> Options -> [b])
    # (Map String, NVModel -> NVModel) -> DOMElement -> [RawSeries] -> Options -> (Chart -> [Series] -> Void) -> Void
    plotter: (f, nv-model, g, view, raw-result, options, continuation) !-->
        <~ nv.add-graph
        
        {x, x-axis, y, y-axis, force-y, key, values, color, fill-intervals, trend-line, margin} = options

        # [RawSeries] -> [Series] where Series :: {key :: String, values :: [b], color :: String}
        result = raw-result |> map (series) ->
            {} <<< series <<<
                key: key series
                values: f (values series), options
                color: color series

        if \Function == typeof! trend-line
            result := result ++ do -> 
                result 
                |> map ({key}:me) -> {trend: trend-line key} <<< me
                |> filter (.trend is not null) 
                |> map ({key, values, trend}) ->
                    {name, sample-size, color} = {
                        name: "#key trend"
                        sample-size: 2
                        color: \red
                    } `rextend` trend
                    key: name
                    values: trend-line-f values, sample-size
                    color: color

        # update the chart props
        @chart := @chart ? (nv-model nv.models)!
        [
            [(.margin), margin]
            [(.x-axis.tick-format), x-axis.format]
            [(.x-axis.axis-label), x-axis.label]
            [(.x-axis.axis-label-distance), x-axis.distance]
            [(?.y-axis?.tick-format), y-axis.format]
            [(?.y-axis?.axis-label), y-axis.label]
            [(?.y-axis?.axis-label-distance), y-axis.distance]
            [(.force-y), force-y]
        ] 
            |> filter -> !!it.1
            |> each ([f, prop]) ~> 
                g = f @chart 
                if !!g 
                    g prop

        g @chart, view, result, options

        <~ continuation @chart, result
        svg = d3.select view .select \svg

        if svg.empty!
            d3.select view 
                .append \div .attr \style, "position: absolute; left: 0px; top: 0px; width: 100%; height: 100%" 
                .append \svg .datum result .call @chart
        else
            d3.select view .select \svg .datum result .call @chart

        @chart.update!


    