stringScore = require '../vendor/stringscore'

basenameScore = (string, query, score) ->
  index = string.length - 1
  index-- while string[index] is '/' # Skip trailing slashes
  slashCount = 0
  lastCharacter = index
  base = null
  while index >= 0
    if string[index] is '/'
      slashCount++
      base ?= string.substring(index + 1, lastCharacter + 1)
    else if index is 0
      if lastCharacter < string.length - 1
        base ?= string.substring(0, lastCharacter)
      else
        base ?= string
    index--

  # Basename matches count for more.
  if base is string
    score *= 2
  else
    score += stringScore(base, query)

  # Shallow files are scored higher
  depth = Math.max(1, 10 - slashCount)
  score *= depth * 0.01
  score

module.exports = (candidates, query, options={}) ->
  if query
    queryHasNoSlashes = query.indexOf('/') is -1
    scoredCandidates = []
    for candidate in candidates
      string = if options.key? then candidate[options.key] else candidate
      score = stringScore(string, query)
      score = basenameScore(string, query, score) if queryHasNoSlashes
      scoredCandidates.push({candidate, score}) if score > 0

    # Sort scores in descending order
    scoredCandidates.sort (a, b) -> b.score - a.score

    candidates = (scoredCandidate.candidate for scoredCandidate in scoredCandidates)

  candidates = candidates[0...options.maxResults] if options.maxResults?
  candidates
