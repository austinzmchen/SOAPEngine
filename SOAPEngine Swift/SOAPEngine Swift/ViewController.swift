//
//  ViewController.swift
//  SOAPEngine Swift
//
//  Created by Danilo Priore on 29/01/17.
//  Copyright © 2017 Danilo Priore. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView?
    
    var verses: NSArray = NSArray()
    var soapWrapper = ACSoapEngineWrapper()
    
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
        soapWrapper.request(url: "http://50.21.179.203/FleetService/Service1.svc",
                action: "GetLocationID",
                params: [.paramInteger(key: "UDID", value: 1)]) { (success, result) in
            guard let id = result as? String
                else { return }
            print(id)
        }
    }
    
    func test_GetLocationFleetsListWithoutImage() {
        soapWrapper.request(url: "http://50.21.179.203/FleetService/Service1.svc",
                action: "GetLocationFleetsListWithoutImage",
                params: [.paramInteger(key: "UDID", value: 1)],
                responseType: .array(ofType: FleetClass.self, key: "FleetClass")) { (success, result) in
            
            guard let fleets = result as? [FleetClass]
                else { return }
            
            print(fleets)
        }
    }
    
    func test_GetLocationFleets() {
        soapWrapper.request(url: "http://50.21.179.203/FleetService/Service1.svc",
                action: "GetLocationFleets",
                params: [.paramInteger(key: "LocationID", value: 1)],
                responseType: .array(ofType: FleetClass.self, key: "FleetClass")) { (success, result) in
                    
            guard let fleets = result as? [FleetClass]
                else { return }
            print(fleets)
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
