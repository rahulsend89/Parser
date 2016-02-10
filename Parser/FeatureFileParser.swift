import Foundation
import UIKit

public class FeatureFileParser {
    
    struct Key {
        static let feature: String = "feature"
        static let scenario: String = "scenario"
        static let meta: String = "meta"
        static let given: String = "given"
        static let when: String = "when"
        static let then: String = "then"
        static let and: String = "and"
        static let examples: String = "examples"
    }
    
    struct ParseError: ErrorType, CustomStringConvertible {
        let description: String
        
        init(_ message: String) {
            description = message
        }
    }
    
    enum ParseState {
        case Unknown
        case Feature
        case Scenario
        case Meta
        case Given
        case When
        case Then
        case And
        case Example
        
        init?(value: String) {
            if value == Key.feature {
                self = .Feature
            } else if value == Key.scenario {
                self = .Scenario
            } else if value == Key.meta {
                self = .Meta
            } else if value == Key.given {
                self = .Given
            } else if value == Key.when {
                self = .When
            } else if value == Key.then {
                self = .Then
            } else if value == Key.and {
                self = .And
            } else if value == Key.examples {
                self = .Example
            } else {
                return nil
            }
        }
        
        func toStep(value: String) -> Step? {
            switch self {
            case .Given:
                return .Given(value)
            case .When:
                return .When(value)
            case .Then:
                return .Then(value)
            case .And:
                return .And(value)
            default:
                return nil
            }
        }
    }

    
    
    static let sharedInstance = FeatureFileParser()
    private var features: [Feature] = []
    private var content: String = ""
    private var line = 0
    private var filePath: Path = Path("")
    private var state = ParseState.Unknown
    private var scenario: Scenario?
    private var example: Example?
    
    private var featureName: String?
    private var scenarios: [Scenario] = []
    private var actualScenarios: [Scenario] = []
    private var exampleKey: [String] = []
    private var exampleValueArray: [[String]] = []
    
    func commitFeature() {
        commitScenario()
        
        if let featureName = featureName {
            var feature = Feature(name: featureName, scenarios: scenarios, filePath: "\(filePath.fileName).\(filePath.extention)")
            feature.actualScenarios = actualScenarios
            features.append(feature)
        }
        
        featureName = nil
        scenarios = []
    }
    
    func commitScenario() {
        if let _ = example{
            convertScenarioFromExample()
            if var scenario = scenario {
                scenario.examples = example
                scenario.examples?.steps = scenario.steps
                actualScenarios.append(scenario)
            }
        }else{
            if let scenario = scenario {
                actualScenarios.append(scenario)
                scenarios.append(scenario)
            }
        }
        
        scenario = nil
        
        example = nil
        exampleKey = []
        exampleValueArray = []
    }
    
    func commitExample() {
        if let example = example where example.dictionaryArray.keys.count > 0{
            scenario?.setExample(example)
        }
    }
    
    func convertScenarioFromExample(){
        if let _scenario = scenario , let examples = _scenario.examples where examples.count > 0{
            for (var exi = 0;exi < examples.count;exi++){
                var exscenario = Scenario(name: _scenario.name, steps: _scenario.steps, file: _scenario.file, line: _scenario.line)
                exscenario.examples = examples
                exscenario.examples?.steps = _scenario.steps
                exscenario.meta = _scenario.meta
                for (_,exvalue) in examples.dictionaryArray.enumerate(){
                    for (var i = 0 ; i < exscenario.steps.count ; i++){
                        var steps = exscenario.steps[i]
                        var stepExample = exscenario.examples!.steps[i]
                        //actual exscenario
                        let regex = try! Regex(expression: "(?<=<)\(exvalue.0)(?=>)")
                        let regexReplace = try! Regex(expression: "<\(exvalue.0)>")
                        
                        //example exscenario
                        let exValueElementExample = "<parameter>\(exvalue.1[exi])</parameter>"
                        
                        let exValueElement = exvalue.1[exi]
                        if let _ = regex.matches(steps.value){
                            steps.setValue(regexReplace.replaceWithString(steps.value, replaceStr: exValueElement))
                            stepExample.setValue(regexReplace.replaceWithString(stepExample.value, replaceStr: exValueElementExample))
                            
                            exscenario.examples?.steps.removeAtIndex(i)
                            exscenario.examples?.steps.insert(stepExample, atIndex: i)
                            exscenario.examples?.currentStep = exi
                            exscenario.steps.removeAtIndex(i)
                            exscenario.steps.insert(steps, atIndex: i)
                        }
                    }
                }
                scenarios.append(exscenario)
            }
        }
    }
    
    func handleComponent(key: String, _ value: String) throws {
        if let newState = ParseState(value: key.lowercaseString) {
            if newState == .Unknown {
                throw ParseError("Invalid content `\(key.lowercaseString)` on line \(line) of \(filePath)")
            }
            
            if newState == .Feature {
                commitFeature()
                featureName = value
            }else if newState == .Scenario {
                commitScenario()
                scenario = Scenario(name: value, steps: [], file: filePath, line: line)
            } else if newState == .Scenario {
                commitScenario()
                scenario = Scenario(name: value, steps: [], file: filePath, line: line)
            } else if newState == .Meta {
                scenario?.setMeta(value)
            } else if newState == .Example{
                example = Example(dictionaryArray: Dictionary<String,[String]>(),line: line)
                commitExample()
            } else if let step = newState.toStep(value) {
                scenario?.steps.append(step)
            }
            
            state = newState
        } else {
            throw ParseError("Invalid content on line \(line) of \(filePath)")
        }
    }
    
    func handleExample(content: String) throws{
        let examplekey = content.componentsSeparatedByString("|").map({ (str) -> String in
            return str.trim
        }).filter({ (str) -> Bool in
            return !str.isEmpty
        })
        if examplekey.count != 0{
            if exampleKey.count == 0 {
                exampleKey.appendContentsOf(examplekey)
            }else{
                exampleValueArray.append(examplekey)
                var dictionaryArray: Dictionary<String,[String]> = Dictionary<String,[String]>()
                for (index,value) in exampleKey.enumerate(){
                    var expAr: [String] = []
                    for (_,valAr) in exampleValueArray.enumerate(){
                        expAr.append(valAr[index])
                    }
                    dictionaryArray[value] = expAr
                }
                example?.setDictionaryArray(dictionaryArray)
                commitExample()
            }
        }else {
            throw ParseError("Invalid examplekey on line \(line) of \(filePath)")
        }
    }
    
    public func parse(paths: [Path]) throws -> [Feature] {
        
        for path in paths {
            
            filePath = path
            self.content = path.content!
            
            for content in self.content.componentsSeparatedByString("\n") {
                ++line
                
                let contents = content.trim
                if contents.isEmpty {
                    continue
                }
                let exampleLoop = contents.containsString("|")
                if exampleLoop {
                    try handleExample(content)
                } else{
                    let containSt = contents.containsString(":")
                    let tokens = contents.split(":", maxSplit: 1)
                    if containSt && tokens.count == 1{
                        let key = String(tokens[0]).trim
                        try handleComponent(key, "")
                    }else{
                        if tokens.count == 2 {
                            let key = String(tokens[0]).trim
                            let value = String(tokens[1]).trim
                            try handleComponent(key, value)
                        } else {
                            let tokens = contents.split(" ", maxSplit: 1)
                            if tokens.count == 2 {
                                let key = String(tokens[0]).trim
                                let value = String(tokens[1]).trim
                                try handleComponent(key, value)
                            } else {
                                throw ParseError("Invalid content on line \(line) of \(path)")
                            }
                        }
                    }
                }
            }
            commitFeature()
        }
        
        return features
    }
}


extension String {
    func split(character: Character, maxSplit: Int) -> [String] {
        return characters.split(maxSplit) { $0 == character }
            .map(String.init)
    }
    var trim: String{
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}
