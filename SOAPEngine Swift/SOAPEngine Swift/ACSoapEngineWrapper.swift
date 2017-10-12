//
//  ACSoapEngineWrapper.swift
//  SOAPEngine Swift
//
//  Created by Austin Chen on 2017-10-12.
//  Copyright © 2017 Danilo Priore. All rights reserved.
//

import Foundation

enum ACSoapRequestParam {
    case paramString(key: String, value: String)
    case paramInteger(key: String, value: Int)
}

enum ACSoapResponseType {
    case any(key: String)
    case object(ofType: ACSoapRemoteRecordType.Type, key: String)
    case array(ofType: ACSoapRemoteRecordType.Type, key: String)
}

class ACSoapEngineWrapper {
    
    func request(url: String,
                 action: String,
                 params: [ACSoapRequestParam],
                 responseType: ACSoapResponseType,
                 completion: @escaping (Bool, Any?) -> () )
    {
        request(url: url, action: action, params: params) { (success, result) in
            
            guard let r = result as? NSDictionary
                else { return }
            
            switch responseType {
            case .object(let type, let key):
                guard let item = r[key] as? NSDictionary else {
                    completion(false, nil)
                    return
                }
                
                let objectResult = type.init(dictionary: item as! Dictionary)
                completion(success, objectResult)
                
            case .array(let type, let key):
                var items: [NSDictionary] = []
                if let rawItems = r[key] as? NSArray {
                    items = (rawItems as? [NSDictionary]) ?? []
                } else if let rawItem = r[key] as? NSDictionary {
                    items.append(rawItem)
                } else {
                    print("response parsing error")
                }
                
                let arrayResult = items.map {
                    return type.init(dictionary: $0 as! Dictionary)
                }
                
                completion(success, arrayResult)
                
            case .any(let key):
                completion(success, r[key])
            }
        }
    }
    
    func request(url: String, action: String, params: [ACSoapRequestParam], completion: @escaping (Bool, Any?) -> () ) {
        let soap = SOAPEngine()
        
        // set params
        for p in params {
            switch p {
            case .paramString(let k, let v):
                soap.setValue(v, forKey: k)
            case .paramInteger(let k, let v):
                soap.setIntegerValue(v, forKey: k)
            default:
                break
            }
        }
        
        soap.actionNamespaceSlash = true // requird, otherwise return -1
        
        // to work with WCF
        soap.responseHeader = true
        soap.version = SOAPVersion.VERSION_WCF_1_1
        
        soap.requestURL(url,
                        soapAction: "http://tempuri.org/IService1/\(action)",
                        completeWithDictionary: { (statusCode: Int?, dict: [AnyHashable: Any]?) -> Void in
                
            let book: NSDictionary = dict! as NSDictionary
            let respWrapper1Key = "\(action)Response"
            let respWrapper2Key = "\(action)Result"
            
            guard let body = book["Body"] as? NSDictionary
                else { return }
            guard let respWrapper1 = body[respWrapper1Key] as? NSDictionary
                else { return }
            
            let result = respWrapper1[respWrapper2Key]
            completion(true, result)
                
        }) { (error: Error?) -> Void in
            completion(false, nil)
        }
    }
}
