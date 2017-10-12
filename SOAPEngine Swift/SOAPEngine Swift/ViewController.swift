//
//  ViewController.swift
//  SOAPEngine Swift
//
//  Created by Danilo Priore on 29/01/17.
//  Copyright © 2017 Danilo Priore. All rights reserved.
//

import UIKit

enum IRSoapRequestParam {
    case paramString(key: String, value: String)
    case paramInteger(key: String, value: Int)
}

enum IRSoapResponseType {
    case any(key: String)
    case object(ofType: IRRemoteRecordType.Type, key: String)
    case array(ofType: IRRemoteRecordType.Type, key: String)
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView?
    
    var verses:NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let soap = SOAPEngine()
        soap.licenseKey = "eJJDzkPK9Xx+p5cOH7w0Q+AvPdgK1fzWWuUpMaYCq3r1mwf36Ocw6dn0+CLjRaOiSjfXaFQBWMi+TxCpxVF/FA=="
        soap.actionNamespaceSlash = true
        soap.setValue("Genesis", forKey: "BookName")
        soap.setIntegerValue(1, forKey: "chapter")
        soap.requestURL("http://www.prioregroup.com/services/americanbible.asmx",
                        soapAction: "http://www.prioregroup.com/GetVerses",
                        completeWithDictionary: { (statusCode: Int?, dict: [AnyHashable: Any]?) -> Void in
                            
                            let book:NSDictionary = dict! as NSDictionary
                            self.verses = book["BibleBookChapterVerse"] as! NSArray
                            self.tableView?.reloadData()
                            
        }) { (error: Error?) -> Void in
            
            print(error!)
        }
        
        
        test1()
        test_GetLocationFleetsListWithoutImage()
        test_GetLocationFleets()
    }
    
    func test1() {
//        let soap = SOAPEngine()
//        soap.setIntegerValue(1, forKey: "UDID")
//
//        soap.actionNamespaceSlash = true // requird, otherwise return -1
//        
//        // to work with WCF
//        soap.responseHeader = true
//        soap.version = SOAPVersion.VERSION_WCF_1_1
//
//        soap.requestURL("http://50.21.179.203/FleetService/Service1.svc",
//                        soapAction: "http://tempuri.org/IService1/GetLocationID",
//                        completeWithDictionary: { (statusCode: Int?, dict: [AnyHashable: Any]?) -> Void in
//                            
//                            let book: NSDictionary = dict! as NSDictionary
//                            guard let a = book["Body"] as? NSDictionary
//                                else { return }
//                            guard let b = a["GetLocationIDResponse"] as? NSDictionary
//                                else { return }
//                            guard let c = b["GetLocationIDResult"] as? String
//                                else { return }
//                            print(c)
//                            
//        }) { (error: Error?) -> Void in
//            
//            print(error!)
//        }
        
        
        request(url: "http://50.21.179.203/FleetService/Service1.svc",
                action: "GetLocationID",
                params: [.paramInteger(key: "UDID", value: 1)]) { (success, result) in
            guard let id = result as? String
                else { return }
            print(id)
        }
    }
    
    func test_GetLocationFleetsListWithoutImage() {
        request(url: "http://50.21.179.203/FleetService/Service1.svc",
                action: "GetLocationFleetsListWithoutImage",
                params: [.paramInteger(key: "UDID", value: 1)],
                responseType: .array(ofType: FleetClass.self, key: "FleetClass")) { (success, result) in
            
            guard let fleets = result as? [FleetClass]
                else { return }
            
//            var items: [NSDictionary] = []
//            if let rawItems = r["FleetClass"] as? NSArray {
//                items = (rawItems as? [NSDictionary]) ?? []
//            } else if let rawItem = r["FleetClass"] as? NSDictionary {
//                items.append(rawItem)
//            } else {
//                print("response parsing error")
//            }
//            
//            let a = items.map {
//                return FleetClass(dictionary: $0 as! Dictionary)
//            }
            
            print(fleets)
        }
    }
    
    func test_GetLocationFleets() {
        request(url: "http://50.21.179.203/FleetService/Service1.svc",
                action: "GetLocationFleets",
                params: [.paramInteger(key: "LocationID", value: 1)],
                responseType: .array(ofType: FleetClass.self, key: "FleetClass")) { (success, result) in
                    
//            guard let r = result as? NSDictionary
//                else { return }
//            
//            var items: [NSDictionary] = []
//            if let rawItems = r["FleetClass"] as? NSArray {
//                items = (rawItems as? [NSDictionary]) ?? []
//            } else if let rawItem = r["FleetClass"] as? NSDictionary {
//                items.append(rawItem)
//            } else {
//                print("response parsing error")
//            }
//            
//            let a = items.map {
//                return FleetClass(dictionary: $0 as! Dictionary)
//            }
//
//            print(a)
                    
            guard let fleets = result as? [FleetClass]
                else { return }
            print(fleets)
        }
    }
    
    func request(url: String,
                 action: String,
                 params: [IRSoapRequestParam],
                 responseType: IRSoapResponseType,
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
    
    func request(url: String, action: String, params: [IRSoapRequestParam], completion: @escaping (Bool, Any?) -> () ) {
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
//            guard let result = respWrapper1[respWrapper2Key] as? NSDictionary
//                else { return }
            let result = respWrapper1[respWrapper2Key]
            
            completion(true, result)
                            
        }) { (error: Error?) -> Void in
            completion(false, nil)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.verses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        }
        
        let chapter_verse:NSDictionary = self.verses[indexPath.row] as! NSDictionary
        
        let chapter:String = chapter_verse["Chapter"] as! String
        let verse:String = chapter_verse["Verse"] as! String
        let text:String = chapter_verse["Text"] as! String
        
        cell!.textLabel?.text = String(format: "Chapter %@ Verse %@", chapter, verse)
        cell!.detailTextLabel?.text = text
        
        return cell!
    }


}

protocol IRRemoteRecordType {
    init(dictionary: [String: Any])
}

class FleetClass: IRRemoteRecordType {
    let locationName: String?
    let name: String?
    let pCode: String?
    
    required init(dictionary: [String: Any]) {
        self.locationName = dictionary["LocationName"] as? String
        self.name = dictionary["Name"] as? String
        self.pCode = dictionary["PCode"] as? String
    }
}
