_ <- id
## Data structure required by table
## data :: [object]
data = 
    * language: \javascript
      active-repos: 323938
      appeared-in-year: 1995

    * language: \scala
      active-repos: 10853
      appeared-in-year: 2003
      
    * language: \haskell
      active-repos: 8789
      appeared-in-year: 1990
      
## Presentation snippet

func = plot table `with-options` {
    
    # optional used for ordering columns
    cols-order: <[language appearedInYear activeRepos]>
    
}
 
[data, func]