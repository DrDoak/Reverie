local ts = require("ai.TagScorer")
local AIConscientiousness = Class.create("AIConscientiousness", Entity)

AIConscientiousness.baseConfidence = 30
AIConscientiousness.baseRelevance = 50
AIConscientiousness.baseAcceptance = 0

tagScores = {
-- Positive Correlation
{ ts.positive,"focused",ts.main},
{ ts.positive,"defensive",ts.min},
{ ts.positive,"cooperative",ts.min},
{ ts.positive,"safe",ts.min},
{ ts.positive, "disciplined",ts.min},
-- Negative Correlation
{ ts.negative, "risky",ts.min},
{ ts.negative, "flexible",ts.min},
{ ts.negative, "calm",ts.min},
{ ts.negative, "independent",ts.min},
{ ts.negative, "impulsive",ts.min}
}
return AIConscientiousness