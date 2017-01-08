local ts = require("ai.TagScorer")
local AIAgreeableness = Class.create("AIAgreeableness", Entity)

AIAgreeableness.baseConfidence = 30
AIAgreeableness.baseRelevance = 50
AIAgreeableness.baseAcceptance = 0

tagScores = {
-- Positive Correlation
{ ts.positive,"trusting",ts.min},
{ ts.positive, "cooperative",ts.min},
{ ts.positive,"humble",ts.min},
{ ts.positive,"altruistic",ts.min},
{ ts.positive,"conforming",ts.min},
{ ts.positive,"safe",ts.min},
-- Negative Correlation
{ ts.negative, "competitive",ts.min},
{ ts.negative, "skeptical",ts.min},
{ ts.negative, "prideful",ts.min},
{ ts.negative, "self-interest",ts.min},
{ ts.negative, "independent",ts.min},
{ ts.negative, "defensive",ts.min},
{ ts.negative, "offensive",ts.min},

}
return AIAgreeableness