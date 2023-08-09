import Foundation


// testing function
func testing () {
    let brain = Gamygdala()

    brain.createAgent(agentName: "Lucy")
    brain.createAgent(agentName: "Mr. Brown")
    brain.createAgent(agentName: "Samson")


    // Problem - all goals are assigned same utility . Exclusivity not clear.
    _ = brain.createGoalForAgent(agentName: "Lucy", goalName: "Kill Orc", goalUtility: 1.0, isMaintenanceGoal: true)
    _ = brain.createGoalForAgent(agentName: "Mr. Brown", goalName: "Kill Orc", goalUtility: 1.0, isMaintenanceGoal: true)
    _ = brain.createGoalForAgent(agentName: "Samson", goalName: "Not Kill Orc", goalUtility: 1.0, isMaintenanceGoal: true)

    brain.createRelation(sourceName: "Lucy", targetName: "Mr. Brown", relation: 1.0)
    brain.createRelation(sourceName: "Mr. Brown", targetName: "Lucy", relation: -1.0)

    brain.createRelation(sourceName: "Samson", targetName: "Lucy", relation: 1.0)
    brain.createRelation(sourceName: "Samson", targetName: "Mr. Brown", relation: -1.0)

    print(String.init(repeatElement("-", count: 60)))
    print(String.init(repeatElement("-", count: 60)))
    brain.appraiseBelief(likelihood: 1.0, causalAgentName: "Boris", affectedGoals: ["Kill Orc", "Not Kill Orc"], goalCongruences: [1.0, -1.0], isIncremental: false)
    //print(String.init(repeatElement("-", count: 60)))
    //brain.appraiseBelief(likelihood: 0.1, causalAgentName: "Boris", affectedGoals: ["Kill Orc", "Not Kill Orc"], goalCongruences: [-0.5, 0.2], isIncremental: true)
    //print(String.init(repeatElement("-", count: 60)))
    //brain.appraiseBelief(likelihood: 1.0, causalAgentName: "Vouz", affectedGoals: ["Kill Orc", "Not Kill Orc"], goalCongruences: [1.0, -1.0], isIncremental: false)


    //print(String.init(repeatElement("-", count: 60)))
    brain.appraiseBelief(likelihood: -1.0, causalAgentName: "Vouz", affectedGoals: ["Kill Orc", "Not Kill Orc"], goalCongruences: [1.0, -1.0], isIncremental: false)

    print(String.init(repeatElement("-", count: 60)))

    brain.outputAll(gain: false)

    let lucy = brain.getAgentByName(NameOfAgent: "Lucy")
    print(lucy?.getPADState(useGain: false) as Any)
    let brown = brain.getAgentByName(NameOfAgent: "Mr. Brown")
    print(brown?.getPADState(useGain: false) as Any)
    let samson = brain.getAgentByName(NameOfAgent: "Samson")
    print(samson?.getPADState(useGain: false) as Any)
}
