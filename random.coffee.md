Random
======

    module.exports =
      binomial: (n=1, p=0.5) ->
        [0...n].map ->
          if Math.random() < p
            1
          else
            0
        .sum()
