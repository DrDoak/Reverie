local ts = require("ai.TagScorer")
local AICuriousity = Class.create("AICuriousity", Entity)

AICuriousity.baseConfidence = 30
AICuriousity.baseRelevance = 50
AICuriousity.baseAcceptance = 0

tagScores = {
-- Positive Correlation
{ ts.positive,"novel",ts.min},
{ ts.positive,"independent",ts.min},
{ ts.positive,"risky",ts.min},
-- Negative Correlation
{ ts.negative, "pragmatic",ts.min},
{ ts.negative, "conforming",ts.min},
{ ts.negative, "safe",ts.min},
{ ts.negative, "calm",ts.min},
{ ts.negative, "routine",ts.min}
}
return AICuriousity