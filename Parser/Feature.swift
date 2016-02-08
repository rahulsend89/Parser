import Foundation
import UIKit

public enum Step {
    case Given(String)
    case When(String)
    case Then(String)
    case And(String)
}
extension Step: Equatable, CustomStringConvertible{
    var value: String{
        switch self {
        case .Given(let v1):
            return v1
        case .When(let v1):
            return v1
        case .Then(let v1):
            return v1
        case .And(let v1):
            return v1
        }
    }
    mutating func setValue(str: String){
        switch self {
        case .Given( _):
            self = .Given(str)
        case .When( _):
            self = When(str)
        case .Then( _):
            self = Then(str)
        case .And( _):
            self = And(str)
        }
    }
    func isEqual(st: Step)->Bool {
        switch self {
        case .Given(let v1):
            switch st {
            case .Given(let v2): return v1 == v2
            default: return false
            }
        case .When(let v1):
            switch st {
            case .When(let v2): return v1 == v2
            default: return false
            }
        case .Then(let v1):
            switch st {
            case .Then(let v2): return v1 == v2
            default: return false
            }
        case .And(let v1):
            switch st {
            case .And(let v2): return v1 == v2
            default: return false
            }
        }
    }
    public var description: String {
        switch self {
        case .Given(let given):
            return "Given \(given)"
        case .When(let when):
            return "When \(when)"
        case .Then(let then):
            return "Then \(then)"
        case .And(let and):
            return "And \(and)"
        }
    }
}
public func ==(lhs: Step, rhs: Step) -> Bool {
    return lhs.isEqual(rhs)
}

public struct Path {
    public let fileName: String
    public let extention: String
    public let content: String?
    
    init(_ fileName: String){
        let fileNameAr = fileName.componentsSeparatedByString(".")
        self.fileName = fileNameAr[0]
        self.extention = fileNameAr[1]
        if let path = NSBundle.mainBundle().pathForResource(self.fileName, ofType: self.extention){
            let data = try! String(contentsOfFile:path, encoding: NSUTF8StringEncoding)
            self.content = data
        }else{
            self.content = nil
        }
    }
}

public struct Scenario {
    public let name: String
    public var steps: [Step]
    public var examples: Example?
    
    public let file: Path
    public let line: Int
    
    init(name: String, steps: [Step], file: Path, line: Int, examples: Example? = nil) {
        self.name = name
        self.steps = steps
        self.file = file
        self.line = line
        self.examples = examples
    }
    mutating func setExample(example: Example){
        self.examples = example
    }
}

public struct Example {
    public var dictionaryArray: Dictionary<String,[String]>
    public var line: Int
    public var count: Int
    init(dictionaryArray: Dictionary<String,[String]>,line: Int) {
        self.dictionaryArray = dictionaryArray
        self.count = 0
        self.line = line
    }
    mutating func setDictionaryArray(dictionaryArray: Dictionary<String,[String]>){
        self.dictionaryArray = dictionaryArray
        for (_,strAr) in dictionaryArray.enumerate(){
            self.count = strAr.1.count
            break
        }
    }
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
    case Given
    case When
    case Then
    case And
    case Example
    
    init?(value: String) {
        if value == "feature" {
            self = .Feature
        } else if value == "scenario" {
            self = .Scenario
        } else if value == "given" {
            self = .Given
        } else if value == "when" {
            self = .When
        } else if value == "then" {
            self = .Then
        } else if value == "and" {
            self = .And
        } else if value == "examples" {
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



public struct Feature {
    public let name: String
    public let scenarios: [Scenario]
    
    public static func parse(paths: [Path]) throws -> [Feature] {
        var features: [Feature] = []
        
        for path in paths {
            let content: String = path.content!
            var line = 0
            var state = ParseState.Unknown
            var scenario: Scenario?
            var example: Example?
            
            var featureName: String?
            var scenarios: [Scenario] = []
            var exampleKey: [String] = []
            var exampleValueArray: [[String]] = []
            
            func commitFeature() {
                commitScenario()
                
                if let featureName = featureName {
                    features.append(Feature(name: featureName, scenarios: scenarios))
                }
                
                featureName = nil
                scenarios = []
            }
            
            func commitScenario() {
                if let _ = example{
                    convertScenarioFromExample()
                }else{
                    if let scenario = scenario {
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
                        for (_,exvalue) in examples.dictionaryArray.enumerate(){
                            for (var i = 0 ; i < exscenario.steps.count ; i++){
                                var steps = exscenario.steps[i]
                                let regex = try! Regex(expression: "(?<=<)\(exvalue.0)(?=>)")
                                let regexReplace = try! Regex(expression: "<\(exvalue.0)>")
                                let exValueElement = exvalue.1[exi]
                                if let _ = regex.matches(steps.value){
                                    steps.setValue(regexReplace.expression.stringByReplacingMatchesInString(steps.value, options: .WithTransparentBounds, range: NSMakeRange(0, steps.value.characters.count), withTemplate: "\(exValueElement)"))
                                    exscenario.steps.removeAtIndex(i)
                                    exscenario.steps.insert(steps, atIndex: i)
                                }
                            }
                        }
                        //print("exscenario : \(exscenario.steps)")
                        scenarios.append(exscenario)
                    }
                }
            }
            
            func handleComponent(key: String, _ value: String) throws {
                if let newState = ParseState(value: key.lowercaseString) {
                    if newState == .Unknown {
                        throw ParseError("Invalid content `\(key.lowercaseString)` on line \(line) of \(path)")
                    }
                    
                    if newState == .Feature {
                        commitFeature()
                        featureName = value
                    } else if newState == .Scenario {
                        commitScenario()
                        scenario = Scenario(name: value, steps: [], file: path, line: line)
                    }else if newState == .Example{
                        example = Example(dictionaryArray: Dictionary<String,[String]>(),line: line)
                        commitExample()
                    } else if let step = newState.toStep(value) {
                        scenario?.steps.append(step)
                    }
                    
                    state = newState
                } else {
                    throw ParseError("Invalid content on line \(line) of \(path)")
                }
            }
            func handleExample(content: String) throws{
                let examplekey = content.componentsSeparatedByString("|").map({ (str) -> String in
                    return str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
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
                    throw ParseError("Invalid examplekey on line \(line) of \(path)")
                }
            }
            
            for content in content.componentsSeparatedByString("\n") {
                ++line
                
                let contents = content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
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
                        let key = String(tokens[0]).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        try handleComponent(key, "")
                    }else{
                        if tokens.count == 2 {
                            let key = String(tokens[0]).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                            let value = String(tokens[1]).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                            try handleComponent(key, value)
                        } else {
                            let tokens = contents.split(" ", maxSplit: 1)
                            if tokens.count == 2 {
                                let key = String(tokens[0]).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                                let value = String(tokens[1]).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
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
    
    init(name: String, scenarios: [Scenario]) {
        self.name = name
        self.scenarios = scenarios
    }
}


extension String {
    func split(character: Character, maxSplit: Int) -> [String] {
        return characters.split(maxSplit) { $0 == character }
            .map(String.init)
    }
}
