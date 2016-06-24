require! \base62
require! \querystring
{keys, last, map, Str} = require \prelude-ls
{is-equal-to-object} = require \prelude-extension
require! \./presentation-context
{compile-transformation}:pipe-transformation = require \pipe-transformation
{compile-and-execute-sync, from-error-value-tuple}:transpilation = require \transpilation
{UnAuthorizedException, UnAuthenticatedException} = Exceptions = require \./exceptions

# poly fill for promises and fetch API
(require \es6-promise).polyfill!
require \isomorphic-fetch 

# bind-p :: p a -> (a -> p b) -> p b
bind-p = (p, f) --> p.then f

# return-p :: a -> p a
return-p = Promise.resolve

# :: Url -> ProjectId -> API
module.exports = (end-point, project-id) --> 

    # fetch-with-options :: String -> object -> p result
    fetch-with-options = (url, options) ->
        default-options = 
            credentials: \same-origin
            headers: \Content-Type : \application/json

        {ok}:res <- bind-p (fetch "#{end-point}/apis/#{url}", {} <<< default-options <<< options)
        if !ok then 
            res.text!.then (text) -> 
                match res.status
                | 401 => throw new UnAuthenticatedException text
                | 403 => throw new UnAuthorizedException text
                | _   => throw new Error text
                throw text
        else
            res.json!

    # get-json :: String -> p result
    get-json = (url) -> 
        fetch-with-options url, method: \GET

    # post-json :: String -> object -> p result
    post-json = (url, json) --> 
        fetch-with-options do 
            url
            method: \POST
            body: JSON.stringify json

    # delete-fetch :: String -> p a
    delete-fetch = (url) ->
        fetch-with-options url, method: \DELETE

    # put-json :: String -> object -> p a
    put-json = (url, json) ->
        fetch-with-options do
            url
            method: \PUT
            body: JSON.stringify json
    

    # ----------- projects -----------

    # get-projects :: String -> p [Project]
    get-projects = (user-id) -> 
        get-json "users/#{user-id}/projects"

    # get-my-projects :: () -> p [Project]
    get-my-projects = -> 
        get-json "projects"
    

    # ----------- data sources -----------

    get-connections = (query-type, query-object = {}) -> 
        get-json "projects/#{project-id}/queryTypes/#{query-type}/connections#{querystring.stringify query-object}"


    # ----------- documents -----------

    # :: Document -> String -> Int -> p Document
    save-document = (document) ->
        post-json "projects/#{project-id}/documents", document

    # get-documents :: () -> p [Document]
    get-documents = ->
        get-json "projects/#{project-id}/documents"

    # :: DatasourceCue -> String -> p Document
    load-default-document = (data-source-cue, transpilation-language) --> 
        post-json "projects/#{project-id}/defaultDocument", {data-source-cue, transpilation-language}
    
    # :: String -> Int -> p Document
    load-document-version = (document-id, version) -->
        get-json "projects/#{project-id}/documents/#{document-id}/versions/#{version}"

    # :: String -> p Document
    load-latest-document = (document-id) -> 
        get-json "projects/#{project-id}/documents/#{document-id}" 

    # delete-document-version :: String -> Int -> p a
    delete-document-version = (document-id, version) --> 
        delete-fetch "projects/#{project-id}/documents/#{document-id}/versions/#{version}"
    
    # delete-document-and-history :: String -> p a
    delete-document-and-hisotry = (document-id) -> 
        delete-fetch "projects/#{project-id}/documents/#{document-id}"

    # :: [String] -> p [DOMElement]
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

    # ----------- projects  -----------

    add-project = (project) ->
        post-json "projects", project

    update-project = (project) ->
        put-json "projects/#{project-id}", project

    get-project = ->
        get-json "projects/#{project-id}"

    # ----------- execution -----------

    execute = do ->
        previous-call = null

        (
            task-id # :: String
            display # :: Display
            
            # document-id & version are used for security purposes 
            # to prevent guest user from executing changes to existing documents
            document-id # :: String
            version # :: Int
            
            data-source-cue # :: {queryType :: String, connectionKind :: String, connectionName :: String, ...}
            query # :: String
            transpilation-language # :: String
            compiled-parameters # :: object
            cache # :: Boolean
        ) ->

            args = {data-source-cue, query, transpilation-language, compiled-parameters}

            if cache and previous-call and (args `is-equal-to-object` previous-call.args)
                {result, execution-end-time} = previous-call.result-with-metadata
                return-p do 
                    from-cache: true
                    execution-duration: 0
                    execution-end-time: execution-end-time
                    result: result

            else
                result-with-metadata <- bind-p do 
                    post-json do 
                        "projects/#{project-id}/documents/#{document-id}/versions/#{version}/execute"
                        {
                            task-id
                            display
                            data-source-cue
                            query
                            transpilation-language
                            compiled-parameters
                            cache
                        }
                previous-call := {args, result-with-metadata}
                result-with-metadata


    # ----------- storyboard -----------

    # generate-uid :: () -> String
    generate-uid = -> 
        base62.encode Date.now!

    # :: Document -> p {execute, transformation-function, presentation-function}
    compile-document1 = do ->

        cache = {}

        ({
            document-id
            version
            data-source-cue
            query
            client-external-libs
            transpilation
            transformation
            presentation
        }:document?) ->

            cache-key = "#{document-id}-#{version}"

            if cache[cache-key]
                Promise.resolve cache[cache-key] 

            else

                # load the dependencies
                <- require-deps (client-external-libs ? []) .then _

                # transformation-function :: result -> Parameters -> result
                transformation-function <- compile-transformation transformation, transpilation.transformation .then _

                # presentation-function :: DOMElement -> result -> Parameters -> DOM()
                presentation-function <- compile-presentation presentation, transpilation.presentation .then _
            
                cache[cache-key] = 

                    document: document

                    # execute :: Boolean -> Parameters -> p result
                    execute: (cache, compiled-parameters) --> 

                        op-info = {document}
                        
                        # TODO: call execute with projectId
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

    # :: (DocumentId :: String) -> p {execute, transformation-function, presentation-function}
    compile-document = do ->
        (document-id, version) ->
            document <- bind-p (load-document-version document-id, version)
            compile-document1 document

    # :: String -> p {execute, transformation-function, presentation-function}
    compile-latest-document = do ->
        cache = {}
        (document-id) ->
            document <- bind-p load-latest-document document-id
            compile-document1 cache[cache-key] = document


    # ----------- presentation -----------

    # compile-presentation-sync :: String -> String -> [Error, (Parameters -> DOMElement -> result -> Void)]
    compile-presentation-sync = (presentation, language) -> 
        compile-and-execute-sync presentation, language, presentation-context!

    # compile-presentation :: String -> String -> p (Parameters -> DOMEelement -> result -> Void)
    compile-presentation = from-error-value-tuple compile-presentation-sync


    {} <<< transpilation <<< pipe-transformation <<< {
        add-project
        update-project
        get-project
        get-my-projects
        get-connections
        save-document
        get-documents
        load-default-document
        load-document-version
        load-latest-document
        delete-document-version
        delete-document-and-hisotry
        require-deps
        execute
        generate-uid
        compile-document
        compile-latest-document
        compile-presentation-sync
        compile-presentation
        Exceptions
    }

