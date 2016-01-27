require! \base62
{compile} = require \livescript
{keys, last, map, Str} = require \prelude-ls
{is-equal-to-object} = require \prelude-extension
require! \./presentation-context
{compile-transformation}:pipe-transformation = require \pipe-transformation
{compile-and-execute-sync, from-error-value-tuple}:transpilation = require \transpilation

# poly fill for promises and fetch API
(require \es6-promise).polyfill!
require \isomorphic-fetch 

# process-response :: Response -> p a
process-response = ({ok}:res) ->
    if !ok then 
        res.text!.then (text) -> throw text
    else
        res.json!

# get-json :: String -> p result
get-json = (url) -> 
    fetch url .then process-response

# post-json :: String -> object -> p result
post-json = (url, json) --> 
    (fetch do 
        url
        method: \POST
        headers: 'Content-Type' : \application/json
        body: JSON.stringify json) .then process-response
        
module.exports = web-client = ({end-point}:config) ->

    # compile-document :: Document -> p {execute, transformation-function, presentation-function}
    compile-document = do ->

        cache = {}

        ({
            query-id
            data-source-cue
            query
            client-external-libs
            transpilation
            transformation
            presentation
        }:document?) ->

            return Promise.resolve cache[query-id] if !!cache[query-id]

            # load the dependencies
            <- require-deps (client-external-libs ? []) .then _

            # transformation-function :: result -> Parameters -> result
            transformation-function <- compile-transformation transformation, transpilation.transformation .then _

            # presentation-function :: DOMElement -> result -> Parameters -> DOM()
            presentation-function <- compile-presentation presentation, transpilation.presentation .then _
        
            cache[query-id] = 

                document: document

                # execute :: Boolean -> Parameters -> p result
                execute: (cache, compiled-parameters) --> 

                    op-info = {document}

                    {result}? <- (execute do 
                        data-source-cue
                        query
                        transpilation.query
                        compiled-parameters
                        cache
                        generate-uid!
                        op-info) .then _
                    result

                # transform :: result -> Parameters -> p result
                transformation-function: transformation-function

                # presentation-function :: Parameters -> DOMElement -> result -> Void
                presentation-function: presentation-function

    # compile-query :: String -> p {execute, transformation-function, presentation-function}
    compile-query = do ->
        cache = {}
        (query-id) ->
            document <- (if !!cache[query-id] then Promise.resolve cache[query-id] else load-query query-id).then
            compile-document cache[query-id] = document

    # compile-latest-query :: String -> p {execute, transformation-function, presentation-function}
    compile-latest-query = do ->
        cache = {}
        (branch-id) ->
            document <- (if !!cache[branch-id] then Promise.resolve cache[branch-id] else load-latest-query branch-id).then
            compile-document cache[branch-id] = document

    # compile-presentation-sync :: String -> String -> [Error, (Parameters -> DOMElement -> result -> Void)]
    compile-presentation-sync = (presentation, language) -> 
        compile-and-execute-sync presentation, language, presentation-context!

    # compile-presentation :: String -> String -> p (Parameters -> DOMEelement -> result -> Void)
    compile-presentation = from-error-value-tuple compile-presentation-sync

    # execute :: DataSourceCue -> String -> String -> Parameters -> Boolean -> String -> OpInfo -> p result
    execute = do ->
    
        previous-call = null
        
        (data-source-cue, query, transpilation-language, compiled-parameters, cache, op-id, op-info) ->
            
            args = {data-source-cue, query, transpilation-language, compiled-parameters}

            if !!cache and !!previous-call and (previous-call.args `is-equal-to-object` args)
                new Promise (res, rej) ->
                    {result, execution-end-time} = previous-call.result-with-metadata
                    res {from-cache: true, execution-duration: 0, execution-end-time, result}

            else
                (
                    post-json "#{end-point}/apis/execute", {
                        data-source-cue
                        query
                        transpilation-language
                        compiled-parameters
                        cache
                        op-id
                        op-info
                    }
                ) .then (result-with-metadata) -> 
                    previous-call := {args, result-with-metadata}
                    result-with-metadata

    # generate-uid :: a -> String
    generate-uid = -> base62.encode Date.now!

    # get-all-tags :: a -> p [String]
    get-all-tags = -> 
        get-json "#{end-point}/apis/tags"
    
    # load-default-document :: DatasourceCue -> String -> p Document
    load-default-document = (data-source-cue, transpilation-language) -> 
        post-json "#{end-point}/apis/defaultDocument", [data-source-cue, transpilation-language]
    
    # load-query :: String -> p Document
    load-query = (query-id) -> 
        get-json "#{end-point}/apis/queries/#{query-id}"

    # load-latest-query :: String -> p Document
    load-latest-query = (branch-id) -> 
        get-json "#{end-point}/apis/branches/#{branch-id}" .then -> load-query it.0.latest-query.query-id

    # require-deps :: [String] -> p [DOMElement]
    require-deps = (client-external-libs) ->

        # add urls to head
        return (Promise.resolve client-external-libs) if client-external-libs.length == 0
        
        # load all the urls in parallel 
        Promise.all do 
            client-external-libs |> map (url) -> 

                # TODO: use a different technique to differentiate file types
                new Promise (res) ->
                    element = switch (last url.split \.)
                        | \js =>
                            script = document.create-element \script
                                ..src = url
                        | \css => 
                            link = document.create-element \link
                                ..type = \text/css
                                ..rel = \stylesheet
                                ..href = url
                    element.onload = ~> res url
                    document.head.append-child element

    # save-document :: Document -> p Document
    save-document = post-json "#{end-point}/apis/save"
    
    {} <<< transpilation <<< pipe-transformation <<< {
        compile-presentation
        compile-presentation-sync
        compile-document
        compile-query
        compile-latest-query
        execute
        get-all-tags
        generate-uid
        load-default-document
        load-latest-query
        load-query
        require-deps
        save-document
    }

