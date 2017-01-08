local ts = require("ai.TagScorer")
local AINeuroticism = Class.create("AINeuroticism", Entity)

AINeuroticism.baseConfidence = 30
AINeuroticism.baseRelevance = 50
AINeuroticism.baseAcceptance = 0

tagScores = {
-- Positive Correlation
{ ts.positive,"expressive",ts.min},
{ ts.positive,"negative",ts.min},
{ ts.positive,"emotional",ts.min},
{ ts.positive, "defensive",ts.min},
{ ts.positive, "safe",ts.min},
{ ts.positive, "impulsive",ts.min},
{ ts.positive, "tense",ts.min},
-- Negative Correlation
{ ts.negative, "calm",ts.min},
{ ts.negative, "pragmatic",ts.min},
{ ts.negative, "positive",ts.min},
{ ts.negative, "flexible",ts.min}

}
return AINeuroticism