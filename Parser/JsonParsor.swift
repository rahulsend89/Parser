/*
* JsonParser.swift
*
* Copyright (c) 2015 by General Electric Company. All rights reserved.
*
* The copyright to the computer software herein is the property of
* General Electric Company. The software may be used and/or copied only
* with the written permission of General Electric Company or in accordance
* with the terms and conditions stipulated in the agreement/contract
* under which the software has been supplied.
*/


import UIKit

struct ErrorCode {
    static let networkErrorCode: Int = 404
    static let httpErrorCode: Int = 403
    static let invalidTokenErrorCode: Int = 1000
    static let defaultErrorCode: Int = -1003
    static let cancelledErrorCode: Int = -999
}


class ModelClass: NSObject {
    convenience required init(dictionary dict: NSDictionary) {
        self.init(dictionary: dict)
    }
}
func makeErrorWithDifferentCode(text: String="") -> NSError {
    let code: Int = ErrorCode.httpErrorCode
    return NSError(domain: "HTTPTask", code: code, userInfo: [NSLocalizedDescriptionKey: text])
}
extension ModelClass {
    override var description: String {
        let mirrored_object = Mirror(reflecting: self)
        let className = NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
        var returnStr = "\(className): -> "
        for (_, attr) in mirrored_object.children.enumerate() {
            if let property_name = attr.label as String! {
                returnStr += "\(property_name) = \(attr.value)\n"
            }
        }
        return returnStr
    }
}

class JsonParser: NSObject {
    func parseJson(json: AnyObject!, inToClass parseClass: ModelClass.Type!, keypath: String!) -> AnyObject {
        let paraResponseJson: AnyObject! = json
        if let paraResponseJsonDic = paraResponseJson as? NSDictionary {
            return parseDictionary(paraResponseJsonDic, intoClass: parseClass)
        } else {
            if let paraResponseJsonArray =  paraResponseJson as? [NSDictionary] {
                let list: NSMutableArray! = NSMutableArray()
                for dict: NSDictionary in paraResponseJsonArray {
                    list.addObject(self.parseDictionary(dict, intoClass: parseClass))
                }
                return list
            }
        }
        return paraResponseJson
    }
    
    func parseDictionary(dictionary: NSDictionary, intoClass classObject: ModelClass.Type) -> AnyObject {
        let returnObject: AnyObject =  classObject.init(dictionary: dictionary)
        return returnObject
    }
    
    func parseResponse(response: NSURLResponse!, intoClass parseClass: ModelClass.Type, data: NSData!, handlerError:(error: NSError?) -> Void, handlerResponse:(returnObject: AnyObject?) -> Void) {
        let jsonResponse: AnyObject! = self.parseToJSON(data)
        if (jsonResponse == nil) || jsonResponse.isKindOfClass(NSError) {
            handlerError(error: makeErrorWithDifferentCode("jsonResponseError"))
            return
        }
        let returnObj: AnyObject = self.parseJson(jsonResponse, inToClass: parseClass, keypath: nil)
        handlerResponse(returnObject: returnObj)
    }
    
    func parseToJSON(data: NSData) -> AnyObject? {
        var jsonResponse: AnyObject
        do {
            jsonResponse = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            return jsonResponse
        } catch let jsonError {
            print(jsonError)
            return nil
        }
    }
    
    func iterateJsonObject(json: AnyObject?, intoClass classObject: ModelClass.Type) -> AnyObject! {
        if json != nil {
            if let jsonArray = json as? [NSDictionary] {
                return self.parserJsonArray(jsonArray, intoClass: classObject)
            } else {
                if let jsonDic = json as? NSDictionary {
                    let tempDic: NSDictionary = jsonDic
                    return self.parseDictionary(tempDic, intoClass: classObject)
                }
            }
        }
        return nil
    }
    
    func parserJsonArray(jsonArray: [NSDictionary], intoClass classObject: ModelClass.Type) -> [AnyObject] {
        var array: [AnyObject] = [AnyObject]()
        for (_, item) in jsonArray.enumerate() {
            if item.isKindOfClass(NSDictionary) {
                let instanceObject: AnyObject = self.parseDictionary(item as NSDictionary, intoClass: classObject)
                array.append(instanceObject)
            }
        }
        return array as [AnyObject]
    }
}
