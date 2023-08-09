import Foundation


let brain = Gamygdala()

brain.createAgent(agentName: "village")
brain.createAgent(agentName: "blacksmith")
brain.createGoalForAgent(agentName: "village", goalName: "village destroyed", goalUtility: -1, initialLikelihood: 0.0)
brain.createGoalForAgent(agentName: "blacksmith", goalName: "to live", goalUtility: 0.7, initialLikelihood: 0.0)

print("-----------================== \("Village provides housing".uppercased()) ==================-----------")
brain.appraiseBelief(likelihood: 1.0, causalAgentName: "village", affectedGoals: ["to live"], goalCongruences: [1.0], isIncremental: false)
brain.createRelation(sourceName: "blacksmith", targetName: "village", relation: 1.0)

print("-----------================== \("Village is unarmed".uppercased()) ==================-----------")
brain.appraiseBelief(likelihood: 0.7, causalAgentName: "army", affectedGoals: ["village destroyed"], goalCongruences: [1.0], isIncremental: false)

print("-----------================== \("Blacksmith provide weapons".uppercased()) ==================-----------")
brain.appraiseBelief(likelihood: 1.0, causalAgentName: "blacksmith", affectedGoals: ["village destroyed"], goalCongruences: [-1.0], isIncremental: false)
