import Foundation


// Pleasure, Arousal, Dominance
let mapPAD : [String:[Double]] = [  "distress": [-0.61,0.28,-0.36],
                                    "fear": [-0.64,0.6,-0.43],
                                    "hope": [0.51,0.23,0.14],
                                    "joy": [0.76,0.48,0.35],
                                    "satisfaction": [0.87,0.2,0.62],
                                    "fear-confirmed": [-0.61,0.06,-0.32], // defeated
                                    "disappointment": [-0.61,-0.15,-0.29],
                                    "relief": [0.29,-0.19,-0.28],
                                    "happy-for": [0.64,0.35,0.25],
                                    "resentment": [-0.35,0.35,0.29],
                                    "pity": [-0.52,0.02,-0.21], // regretful
                                    "gloating": [-0.45,0.48,0.42], // cruel
                                    "gratitude": [0.64,0.16,-0.21], // grateful
                                    "anger": [-0.51,0.59,0.25],
                                    "gratification": [0.69,0.57,0.63], // triumphant
                                    "remorse": [-0.57,0.28,-0.34], // guilty
                                    "dummy": []
]


extension Double {
    func dec2() -> String {
        return String(format: "%.2f", self)
    }
}

public class Gamygdala {
    
    var agents : [Gamygdala.Agent] = []
    var goals : [Gamygdala.Goal] = []
    
    var decayFactor = 0.8
    
    public class Goal {
        
        var name : String = ""
        var utility : Double
        var maintenanceGoal : Bool = false
        var likelihood : Double

        public init(goalName : String, utility : Double, likelihood : Double = 0.5) {
            name = goalName
            self.utility = utility
            self.likelihood = likelihood
        }
        
    }
    
    public class Emotion : CustomStringConvertible, Equatable {
        public static func == (lhs: Gamygdala.Emotion, rhs: Gamygdala.Emotion) -> Bool {
            return lhs.name == rhs.name && lhs.intensity == rhs.intensity
        }
        
        var name : String
        var intensity : Double
        
        public init(name: String, intensity: Double) {
            self.name = name
            self.intensity = intensity
        }
        
        public var description : String {
            return "\(name) (\(intensity))"
        }
        
    } // End of Emotion class
    
    public class Relation : CustomStringConvertible {
        var agentName : String
        var like : Double
        var emotionList : [Emotion] = []
        
        public init(agentName: String, like: Double) {
            self.agentName = agentName
            self.like = like
        }
        
        public var description : String  {
            var output : String = like >= 0 ? "\(agentName) is liked (\(like.dec2())): " : "\(agentName) is disliked (\(like.dec2())): "
            for emotion in emotionList {
                output += "\(emotion)"
                if emotion != emotionList.last {
                    output += ", "
                }
            }
            return output
        }
        
        public func addEmotion(emotion : Emotion) {
            if let existing = emotionList.first(where: {$0.name == emotion.name}) {
                existing.intensity += emotion.intensity
            } else {
                emotionList.append(Emotion(name: emotion.name, intensity: emotion.intensity))
            }
        }
        
        public func decay(brain : Gamygdala) {
            var updatedEmotionList : [Emotion] = []
            for emotion in emotionList {
                let intensity : Double = brain.decay(intensity : emotion.intensity)
                if intensity >= 0 {
                    emotion.intensity = intensity
                    updatedEmotionList.append(emotion)
                }
            }
            emotionList = updatedEmotionList
        }
        
        
    } // End of Relation Class
    
    public class Agent {
        
        var name : String = ""
        var currentRelations : [String:Relation] = [:]
        var internalStates : [Emotion] = []
        var gain : Double = 1
        var goals : [Goal] = []
        
        
        public init(name: String) {
            self.name = name
        }
        
        public func addGoal(newGoal : Goal) {
            goals.append(newGoal)
        }
        
        public func removeGoal(goalName: String) -> Bool {
            if let idx = goals.firstIndex(where: {$0.name == goalName}) {
                goals.remove(at: idx)
                return true
            }
            return false
        }
        
        public func hasGoal(goalName : String) -> Bool {
            return self.goals.contains(where: {$0.name == goalName})
        }
        
        public func getGoalByName(goalName : String) -> Goal? {
            return self.goals.first(where: {$0.name == goalName})
        }
        
        public func setGain(gain : Double) {
            if (gain <= 0 || gain > 20) {
                print("'Error: gain factor for appraisal integration must be between 0 and 20")
            } else {
                self.gain = gain
            }
        }
        
        public func updateEmotionalState(emotion : Emotion) {
            for internalState in internalStates {
                if internalState.name == emotion.name {
                    print("\(name) updated emotion \(emotion.name) with intensity \(emotion.intensity.dec2())")
                    internalState.intensity += emotion.intensity
                    return
                }
            }
            print("\(name) added emotion \(emotion.name) with intensity \(emotion.intensity.dec2())")
            internalStates.append(emotion)
        }
                
        public func getEmotionalState(useGain : Bool) -> [Emotion] {
            if useGain {
                var gainState : [Emotion] = []
                for emotion in internalStates {
                    let gainEmo = self.gain * emotion.intensity / (self.gain + emotion.intensity + 1)
                    gainState.append(Emotion(name: emotion.name, intensity: gainEmo))
                }
                return gainState
            } else {
                return internalStates
            }
        }
        
        public func getPADState(useGain : Bool) -> (pleasure : Double, arousal : Double, dominance : Double) {
            var PAD : (pleasure : Double, arousal : Double, dominance : Double)  = (0,0,0)
            for emotion in internalStates {
                if let PADValues = mapPAD[emotion.name] {
                    PAD.pleasure += emotion.intensity * PADValues[0]
                    PAD.arousal += emotion.intensity * PADValues[1]
                    PAD.dominance += emotion.intensity * PADValues[2]
                }
                if useGain {
                    PAD.pleasure = (PAD.pleasure >= 0 ? gain * PAD.pleasure / (gain * PAD.pleasure + 1) : -gain * PAD.pleasure / (gain * PAD.pleasure - 1))
                    PAD.arousal = (PAD.arousal >= 0 ? gain * PAD.arousal / (gain * PAD.arousal + 1) : -gain * PAD.arousal / (gain * PAD.arousal - 1))
                    PAD.dominance = (PAD.dominance >= 0 ? gain * PAD.dominance / (gain * PAD.dominance + 1) : -gain * PAD.dominance / (gain * PAD.dominance - 1))
                }
            }
            return PAD
        }
        
        public func printEmotionalState(useGain : Bool) {
            var output = "\(self.name) feels: \n\t"
            let emotionalState = self.getEmotionalState(useGain: useGain)
            var i = 0
            for emotion in emotionalState {
                output += "\(emotion.name) : \(emotion.intensity.dec2()), "
                i += 1
            }
            if i > 0 {
                print(output)
            }
        }
        
        public func updateRelation(targetName : String, like : Double) -> Relation {
            if let relation = currentRelations[targetName] {
                relation.like = like
                currentRelations[targetName] = relation
                return relation
            } else {
                let relation = Relation(agentName: targetName, like: like)
                currentRelations[targetName] = relation
                return relation
            }
            
        }
        
        public func hasRelation(with agentName : String) -> Bool {
            return currentRelations.keys.contains(agentName)
        }
        
        public func getRelation(agentName : String) -> Relation? {
            return currentRelations[agentName]
        }

        public func printRelations(filterName : String = "") {
            if currentRelations.count == 0 {
                return
            }
            var output = "\(name) has the following sentiments: \n\t"
            var counter = 0
            for (targetName, relation) in currentRelations {
                
                if targetName == filterName || filterName == "" {
                    for emotion in relation.emotionList {
                        output += "\(emotion.name) (\(emotion.intensity.dec2()))"
                        if emotion != relation.emotionList.last {
                            output += ", "
                        }
                    }
                    output += " for \(targetName)"
                }
                counter += 1
                if counter < currentRelations.keys.count {
                    output += "\n\t"
                }
            }
            print(output)
        }
        
        public func decay(brain : Gamygdala) {
            var updatedStates : [Emotion] = []
            for state in internalStates {
                if state == internalStates.first {
                    //print("\(name) was decaying for:")
                }
                let newIntensity = brain.decay(intensity : state.intensity)
                //print("\t \(state.name) (\(state.intensity.dec2()) -> \(newIntensity.dec2()))")
                if (newIntensity >= 0) {
                    state.intensity = newIntensity
                    updatedStates.append(state)
                }
            }
            for (_,relation) in currentRelations {
                relation.decay(brain: brain)
            }
            internalStates = updatedStates
        }
        
        
    } // End of Agent Class
    
    public class Belief : CustomStringConvertible {
        
        public var likelihood : Double
        var causalAgent : String?
        var affectedGoalNames : [String]
        var goalCongruences : [Double]
        var isIncremental : Bool
        
        public init(likelihood: Double, causalAgent: String?, affectedGoalNames: [String], goalCongruences: [Double], isIncremental: Bool) {
            self.likelihood = likelihood
            if let agent = causalAgent {
                self.causalAgent = agent
            }
            self.affectedGoalNames = affectedGoalNames
            self.goalCongruences = goalCongruences
            self.isIncremental = isIncremental
        }
        
        public var description: String {
            var output : String = "Some event with likelihood \(likelihood.dec2()): \n"
            var i : Int = 0
            for affectedGoalName in affectedGoalNames {
                output += goalCongruences[i] > 0.0 ? "promotes " : "deminish "
                output += "\(affectedGoalName)"
                if affectedGoalName != affectedGoalNames.last {
                    output += ", "
                } else {
                    if let agent = causalAgent {
                        output += "\n and is caused by \(agent) \n"
                    } else {
                        output += "\n"
                    }
                }
                i += 1
            }
            return output
        }
        
        
    }
    
    
    public init() {
        print("brain is operating ... ")
    }
    
    
    public func createAgent(agentName : String) {
        if let _ = getAgentByName(NameOfAgent: agentName) {
            print("Error: Agent '\(agentName) already exist. Agent names have to be unique")
        }
        let newAgent = Agent(name: agentName)
        registerAgent(newAgent: newAgent)
    }
    
    public func createGoalForAgent(agentName : String, goalName : String, goalUtility: Double, initialLikelihood : Double = 0.5, isMaintenanceGoal : Bool = false) -> Goal? {
        if let tempAgent = getAgentByName(NameOfAgent: agentName) {
            if let tempGoal = getGoalByName(goalName: goalName) {
                print("Warning: I cannot make a new goal with the same name '\(goalName)' as one is registered already. I assume the goal is a common goal and will add the already known goal with that name to the agent '\(agentName)'")
                if isMaintenanceGoal {
                    tempGoal.maintenanceGoal = isMaintenanceGoal
                }
                tempAgent.addGoal(newGoal: tempGoal)
                return tempGoal
            } else {
                let tempGoal = Gamygdala.Goal(goalName: goalName, utility: goalUtility, likelihood: initialLikelihood)
                registerGoal(newGoal: tempGoal)
                if isMaintenanceGoal {
                    tempGoal.maintenanceGoal = isMaintenanceGoal
                }
                tempAgent.addGoal(newGoal: tempGoal)
                return tempGoal
            }
        }
        print("Error: agent with name '\(agentName)' does not exist, so I cannot create a goal for it.")
        return nil
    }
    
    public func createRelation(sourceName : String, targetName : String, relation : Double ) {
        if let source = getAgentByName(NameOfAgent: sourceName) {
            if let target = getAgentByName(NameOfAgent: targetName){
                if(relation >= -1 && relation <= 1) {
                   let _ = source.updateRelation(targetName: targetName,like: relation)
                } else {
                    print("Error: Relation value for '\(source.name)' and '\(target.name)' was outside of boundary [-1: +1]")
                }
            } else {
                print("Error: Relation value could not be updated since target Agent '\(targetName)' does not exist")
            }
        } else {
            print("Error: Relation value could not be updated since source Agent '\(sourceName)' does not exist")
        }
    }
    
    
    
    public func decayAll( iterations : Int = 3) {
        for _ in 0..<iterations {
            for agent in agents {
                agent.decay(brain: self)
            }
        }
        print("updating decay of emotions .... ")
    }
    
    public func decay (intensity : Double) -> Double {
        return intensity * pow(decayFactor, 1)

    }
    
    public func outputAll(gain : Bool) {
        for agent in agents {
            agent.printEmotionalState(useGain: gain)
            agent.printRelations()
        }
    }
    
    private func registerAgent(newAgent : Gamygdala.Agent) {
        self.agents.append(newAgent)
    }

    private func registerGoal(newGoal : Gamygdala.Goal) {
        self.goals.append(newGoal)
    }

    public func getAgentByName( NameOfAgent name : String) -> Gamygdala.Agent?  {
        for agent in self.agents {
            if agent.name == name {
                return agent
            }
        }
        return nil
    }
    
    public func getGoalByName( goalName name : String) -> Gamygdala.Goal?  {
        for goal in self.goals {
            if goal.name == name {
                return goal
            }
        }
        return nil
    }

    
    public func appraiseBelief(likelihood : Double, causalAgentName : String? = nil, affectedGoals : [String], goalCongruences : [Double], isIncremental : Bool) {
        let tempBelief = Belief(likelihood: likelihood, causalAgent: causalAgentName, affectedGoalNames: affectedGoals, goalCongruences: goalCongruences, isIncremental: isIncremental)
        appraise(someBelief: tempBelief)
    }
    
    
    public func appraise (someBelief : Belief) {
        //print(someBelief)
        if someBelief.goalCongruences.count != someBelief.affectedGoalNames.count {
            print("Error: the congruence list was not of the same length as the affected goal list")
            return
        }
        if goals.count == 0 {
            print("Warning: no goals registered to Gamygdala, all goals to be considered in appraisal need to be registered.")
            return
        }
        
        for goalIdx in 0..<someBelief.affectedGoalNames.count {
            let goalName : String = someBelief.affectedGoalNames[goalIdx]
            if let currentGoal = getGoalByName(goalName: goalName) {
                let utility = currentGoal.utility
                let preLH = currentGoal.likelihood
                let desirability = someBelief.goalCongruences[goalIdx] * utility
                let deltaLikelihood = calculateDeltaLikelihood(goal: currentGoal, eventCongruence: someBelief.goalCongruences[goalIdx], eventLikelihood: someBelief.likelihood, isIncremental: someBelief.isIncremental)
                
                //let desirability = deltaLikelihood * utility
                //print("==================================================================================================================")
                print("Evaluated goal '\(goalName)': (utility = \(utility.dec2()), deltaLH = \(deltaLikelihood.dec2()), oldLH = \(preLH.dec2()), newLH = \(currentGoal.likelihood.dec2()), desirability = \(desirability.dec2()))")
                //print("==================================================================================================================")
                for agent in agents {
                    if agent.hasGoal(goalName: goalName) {
                        print("..... owned by \(agent.name)")
                        evaluateInternalEmotion(utility: utility, deltaLikelihood: deltaLikelihood, likelihood: currentGoal.likelihood, agent: agent)
                        EvaluateActions(affectedName: agent.name, causalAgentName: someBelief.causalAgent, selfName: agent.name, desirability: desirability, utility: utility, DeltaLikelihood: deltaLikelihood)
                        for other in agents {
                            if let relation = other.getRelation(agentName: agent.name) {
                                print("\(other.name) has relationship with \(agent.name)")
                                print("\(relation)")
                                evaluateSocialEmotion(utility: utility, desirability: desirability, deltaLikelihood: deltaLikelihood, relation: relation, agent: other)
                                EvaluateActions(affectedName: agent.name, causalAgentName: someBelief.causalAgent, selfName: other.name, desirability: desirability, utility: utility, DeltaLikelihood: deltaLikelihood)
                            }
                        }
                    }
                }
            }
        }
        outputAll(gain: false)
    }

////////////////////////////////////////////////////////
//Below this is internal gamygdala stuff not to be used publicly (i.e., never call these methods).
////////////////////////////////////////////////////////
    
    
// Defines the change in a goal's likelihood due to the congruence and likelihood of a current event.
// We cope with two types of beliefs: incremental and absolute beliefs. Incrementals have their likelihood added to the goal, absolute define the current likelihood of the goal
// And two types of goals: maintenance and achievement. If an achievement goal (the default) is -1 or 1, we can't change it any more (unless externally and explicitly by changing the goal.likelihood).

    private func calculateDeltaLikelihood(goal : Goal, eventCongruence : Double, eventLikelihood : Double, isIncremental : Bool) -> Double {
        let oldLikelihood = goal.likelihood
        var newLikelihood : Double = 0
        if (goal.maintenanceGoal == false && (oldLikelihood >= 1 || oldLikelihood <= -1)) {
            print("-== Goal \(goal.name) likelihood \(oldLikelihood.dec2()) was at maximum and was not adjusted ==-")
            return 0
        } else {
            if isIncremental {
                newLikelihood = oldLikelihood + eventLikelihood * eventCongruence
                newLikelihood = newLikelihood > 1 ? 1 : (newLikelihood < -1 ? -1 : newLikelihood)
            } else {
                newLikelihood = (eventCongruence * eventLikelihood + 1.0) / 2.0
            }
            goal.likelihood = newLikelihood
            //print("-== Goal \(goal.name) likelihood was adjusted from \(oldLikelihood) to \(newLikelihood) ==-")
            return newLikelihood - oldLikelihood
        }
        
    }
    
    private func evaluateInternalEmotion(utility : Double, deltaLikelihood : Double, likelihood : Double, agent : Agent) {
        var positive : Bool = false
        var intensity : Double = 0
        var emotions : [String] = []
        if( utility >= 0) {
            if ( deltaLikelihood >= 0) {
                positive = true
            }else {
                positive = false
            }
        } else if ( utility < 0 ) {
            if( deltaLikelihood >= 0) {
                positive = false
            } else {
                positive = true
            }
        }
        if(likelihood > 0 && likelihood < 1) {
            if (positive){
                emotions.append("hope")
            }else {
                emotions.append("fear")
            }
        } else if(likelihood == 1){
            if (utility >= 0){
                if(abs(deltaLikelihood) < 0.5){
                    emotions.append("satisfaction")
                }
                emotions.append("joy")
            }
            else {
                if(abs(deltaLikelihood)  < 0.5 ) {
                    emotions.append("fear-confirmed")
                }
                emotions.append("distress")
            }
        } else if (likelihood == 0.0) {
            if( utility >= 0) {
                if( abs(deltaLikelihood) > 0.5 ) {
                    emotions.append("disappointment")
                }
                emotions.append("distress")
            }else {
                if( abs(deltaLikelihood) > 0.5 ) {
                    emotions.append("relief")
                }
                emotions.append("joy")
            }
        }
        intensity = abs(utility * deltaLikelihood)
        if (intensity != 0){
            for emotion in emotions {
                //print("Emotion to be added \(emotion) ... ")
                agent.updateEmotionalState(emotion: Emotion(name: emotion, intensity: intensity))
            }
        }
    }
    
    private func evaluateSocialEmotion(utility : Double, desirability : Double, deltaLikelihood : Double, relation : Relation, agent : Agent) {
        var name : String = ""
        if (desirability >= 0) {
            if (relation.like >= 0) {
                name = "happy-for"
            } else {
                name = "resentment"
            }
        } else {
            if (relation.like >= 0) {
                name = "pity"
            } else {
                name = "gloating"
            }
        }
        let intensity = abs(utility * deltaLikelihood * relation.like)
        if intensity != 0 {
            let emotion = Emotion(name: name, intensity : intensity)
            relation.addEmotion(emotion: emotion)
            agent.updateEmotionalState(emotion: emotion)
        }
    }
    
    private func EvaluateActions(affectedName : String, causalAgentName : String?, selfName : String, desirability : Double, utility : Double, DeltaLikelihood : Double) {
        if let causalName = causalAgentName {
            var emotionName = ""
            
            if (affectedName == selfName && selfName != causalName) {
                if (desirability >= 0) {
                    emotionName = "gratitude"
                } else {
                    emotionName = "anger"
                }
                let emotion = Emotion(name: emotionName, intensity: abs(utility * DeltaLikelihood))
                if let agent = getAgentByName(NameOfAgent: selfName) {
                    if let relation = agent.getRelation(agentName: causalName) {
                        relation.addEmotion(emotion: emotion)
                    } else {
                        let relation = agent.updateRelation(targetName: causalName, like: 0.0)
                        relation.addEmotion(emotion: emotion)
                    }
                    agent.updateEmotionalState(emotion: emotion)
                }
            }
            
            if (affectedName == selfName && selfName == causalName) {
                // Not implemented here
                // Should include pride and shame
            }
            
            if (affectedName != selfName && selfName == causalName) {
                if let agent = getAgentByName(NameOfAgent: causalName) {
                    if let relation = agent.getRelation(agentName: affectedName) {
                        if desirability >= 0 {
                            if relation.like >= 0 {
                                let emotionName = "gratification"
                                let emotion = Emotion(name: emotionName, intensity: abs(utility * DeltaLikelihood * relation.like))
                                relation.addEmotion(emotion: emotion)
                                agent.updateEmotionalState(emotion: emotion)
                            }
                        } else {
                            if relation.like >= 0 {
                                let emotionName = "remorse"
                                let emotion = Emotion(name: emotionName, intensity: abs(utility * DeltaLikelihood * relation.like))
                                relation.addEmotion(emotion: emotion)
                                agent.updateEmotionalState(emotion: emotion)

                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
}
