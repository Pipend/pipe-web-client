{map, id, filter, Obj, pairs-to-obj, sum, each, take, drop} = require \prelude-ls
{create-class, create-factory, DOM:{div}} = require \react
{find-DOM-node, render} = require \react-dom

module.exports = ({Plottable, d3, plot-chart, nv, plot}) ->

    Cell = create-factory create-class do 

        # get-default-props :: () -> Props
        get-default-props: ->
            # plottable :: Plottable
            # result :: a
            # options :: a
            {}

        # render :: () -> ReactElement
        render: ->
            {style} = @props
            div {style}

        # update-plot :: () -> Void
        update-plot: !->
            plot do 
                @props.plottable 
                find-DOM-node @
                @props.result
                @props.options

        # component-did-mount :: () -> Void
        component-did-mount: !-> @update-plot!

        # component-did-update :: () -> Void
        component-did-update: !-> @update-plot!

    Layout = create-factory create-class do 

        # get-default-props :: () -> Props
        get-default-props: ->
            # cells :: [{size :: Number, plottable :: Plottable}]
            # direction :: String
            # result :: a
            # options :: a
            {}

        # render :: () -> ReactElement
        render: ->

            {cells, direction, result, options} = @props

            # sizes :: [Number] collection of user defined sizes
            sizes = cells 
                |> map (.size)
                |> filter -> !!it and typeof! it == \Number

            # % of empty space
            empty-space = 1 - sum sizes

            # number of cells that do not have any size
            cells-without-size = cells.length - sizes.length

            # size of a cell (in %) that doesn't have user defined size
            default-size = empty-space / cells-without-size

            # update cells array, making sure that each cell has size, 
            # use default size for cells that do not have user-defined size
            cells-with-size = cells |> map -> {} <<< it <<< size: it.size ? default-size

            div null,
                [0 til cells-with-size.length] |> map (i) ~>
                    {size, plottable} = cells-with-size[i]

                    # position is the sum of sizes till the current index
                    position = cells-with-size
                        |> take i
                        |> map (.size)
                        |> sum

                    # a div for each cell
                    Cell do
                        {
                            key: "cell_#{i}"
                            style:
                                overflow: \auto
                                position: \absolute
                                left: if direction == \horizontal then "#{position * 100}%" else "0%"
                                top: if direction == \horizontal then "0%" else "#{position * 100}%"
                                width: if direction == \horizontal then "#{size * 100}%" else "100%"
                                height: if direction == \horizontal then "100%" else "#{size * 100}%"
                            plottable
                            result
                            options
                        }

    # layout :: String -> (Cell -> Cell -> Cell -> ...) -> Plottable
    layout = (direction, ...cells) ->
        new Plottable do 
            (view, result, options, continuation) !->
                render do 
                    Layout {cells: cells, direction: direction, result, options}
                    view

    # cell :: Plottable -> {plottable :: Plottable}
    cell: (plottable) -> {plottable}

    # scell :: Number -> Plottable -> {size :: Number, plottable :: Plottable}
    scell: (size, plottable) -> {size, plottable}

    # layout-horizontal :: Cell -> Cell -> Cell -> ... -> Plottable
    layout-horizontal: -> layout.apply @, <[horizontal]> ++ ([].slice.call arguments)

    # layout-vertical :: Cell -> Cell -> Cell -> ... -> Plottable
    layout-vertical: -> layout.apply @, <[vertical]> ++ ([].slice.call arguments)
