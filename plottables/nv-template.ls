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
        
    # RawSeries :: a
    # RefinedSeries :: {key :: String, values :: [a], color :: String, ...}

    # f :: ([RefinedSeries] -> Options -> [ProjectedSeries]) -> 
    # nv-model :: (Map String, NVModel -> NVModel) ->
    # g :: (Chart -> DOMElement -> [SeriesWithTrendline] -> Options -> ()) -> 
    # view :: DOMElement -> 
    # raw-series :: [RawSeries] -> 
    # options :: Options -> 
    # continuation :: (Chart -> [SeriesWithTrendline] -> ()) ->
    # result :: ()
    plotter: (f, nv-model, g, view, raw-series, options, continuation) !-->
        <~ nv.add-graph
        
        {x, x-axis, y, y-axis, force-y, key, values, color, fill-intervals, trend-line, margin} = options

        # [RawSeries] -> [RefinedSeries]
        refined-series = raw-series |> map (series) ->
            {} <<< series <<<
                key: key series
                values: values series
                color: color series

        projected-series = f refined-series, options

        series-with-trendline = 
            | \Function == typeof! trend-line =>
                projected-series ++ do -> 

                    # create a new series for each existing series with a moving average of the values
                    projected-series 
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

            | _ => projected-series

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
            |> each ([get-method, prop]) ~> 
                method = get-method @chart 
                if !!method 
                    method prop

        g @chart, view, series-with-trendline, options

        <~ continuation @chart, series-with-trendline
        svg = d3.select view .select \svg

        if svg.empty!
            d3.select view 
                .append \div .attr \style, "position: absolute; left: 0px; top: 0px; width: 100%; height: 100%" 
                .append \svg .datum series-with-trendline .call @chart
        else
            d3.select view .select \svg .datum series-with-trendline .call @chart

        @chart.update!


    