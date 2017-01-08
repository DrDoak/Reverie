local ts = require("ai.TagScorer")
local AIExtraversion = Class.create("AIExtraversion", Entity)

AIExtraversion.baseConfidence = 30
AIExtraversion.baseRelevance = 50
AIExtraversion.baseAcceptance = 0

tagScores = {
-- positive correlation
{ ts.positive,"social",ts.min},
{ ts.positive, "expressive",ts.min},
{ ts.positive, "fun",ts.min},
--Negative correlation
{ ts.negative ,"private",ts.min},
{ ts.negative , "reserved",ts.min},
{ ts.negative ,"pragmatic",ts.min}, --small
}
return AIExtraversion