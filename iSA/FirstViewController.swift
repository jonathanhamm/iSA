//
//  FirstViewController.swift
//  iSA
//
//  Created by Pope Pius VII on 3/30/15.
//  Copyright (c) 2015 Pope Pius VII. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let bob = ["haha", "doohahah", "bruhuhuhuh"]
    let textCellIdentifier = "TextCell"
    
    @IBOutlet weak var usernameList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameList.delegate = self
        usernameList.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func testClicked(sender: AnyObject) {

        let chat = Chatroom(ui: self, username: "obama.in.bubble.bath", password: "", server: Chatroom.Server.S_2D_CENTRAL)
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bob.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = usernameList.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        
        cell.textLabel?.text = bob[row]
        
        return cell
        
    }
    
}

