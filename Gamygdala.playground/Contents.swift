import Foundation





let brain = Gamygdala()
brain.createAgent(agentName: "village")
/* Example 1 Relief */

brain.createGoalForAgent(agentName: "village", goalName: "village destroyed", goalUtility: -0.9, initialLikelihood: 0.0)
brain.decayAll()
print("-----------================== \("Village is surrounded".uppercased()) ==================-----------")
brain.appraiseBelief(likelihood: 0.6, affectedGoals: ["village destroyed"], goalCongruences: [1.0], isIncremental: false)
brain.decayAll()
print("-----------================== \("Village is no longer surrounded".uppercased()) ==================-----------")
brain.appraiseBelief(likelihood: 1.0, affectedGoals: ["village destroyed"], goalCongruences: [-1.0], isIncremental: false)

/* Example 2 Gratification */
print("\n--- End of Example 1 ---\n\n")
let brain2 = Gamygdala()
brain2.createAgent(agentName: "village")

brain2.createAgent(agentName: "blacksmith")
brain2.createGoalForAgent(agentName: "village", goalName: "village destroyed", goalUtility: -1, initialLikelihood: 0.0)
brain2.createGoalForAgent(agentName: "blacksmith", goalName: "to live", goalUtility: 0.7, initialLikelihood: 0.0)

print("-----------================== \("Village provides housing".uppercased()) ==================-----------")
brain2.appraiseBelief(likelihood: 1.0, causalAgentName: "village", affectedGoals: ["to live"], goalCongruences: [1.0], isIncremental: false)
brain2.createRelation(sourceName: "blacksmith", targetName: "village", relation: 1.0)
brain2.decayAll()

print("-----------================== \("Village is unarmed".uppercased()) ==================-----------")
brain2.appraiseBelief(likelihood: 0.7, causalAgentName: "army", affectedGoals: ["village destroyed"], goalCongruences: [1.0], isIncremental: false)
brain2.decayAll()

print("-----------================== \("Blacksmith provide weapons".uppercased()) ==================-----------")
brain2.appraiseBelief(likelihood: 1.0, causalAgentName: "blacksmith", affectedGoals: ["village destroyed"], goalCongruences: [-1.0], isIncremental: false)
print("\n--- End of Example 2 ---")


