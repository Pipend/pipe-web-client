_ => {

  // Data structure required by table
  // data :: [object]

  const data = [
    {
      language: 'javascript',
      activeRepos: 323938,
      appearedInYear: 1995
    }, {
      language: 'scala',
      activeRepos: 10853,
      appearedInYear: 2003
    }, {
      language: 'haskell',
      activeRepos: 8789,
      appearedInYear: 1990
    }
  ];

  // Presentation snippet 

  const func = plot(withOptions(table, {
    // optional used for ordering columns
    colsOrder: ['language', 'appearedInYear', 'activeRepos']
  }));
  
  return [data, func]
}