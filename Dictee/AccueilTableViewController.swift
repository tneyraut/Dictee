//
//  AccueilTableViewController.swift
//  Dictee
//
//  Created by Thomas Mac on 24/06/2016.
//  Copyright © 2016 ThomasNeyraut. All rights reserved.
//

import UIKit

class AccueilTableViewController: UITableViewController {

    private let dicteesArray: NSArray = [
        NSLocalizedString("DICTEE_1", comment:""),
        NSLocalizedString("DICTEE_2", comment:""),
        NSLocalizedString("DICTEE_3", comment:""),
        NSLocalizedString("DICTEE_4", comment:""),
        NSLocalizedString("DICTEE_5", comment:""),
    ]
    
    private let sauvegarde = NSUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.tableView.registerClass(TableViewCellWithImage.classForCoder(), forCellReuseIdentifier:"cell")
        
        self.title = "Menu Principal"
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.8)
        shadow.shadowOffset = CGSizeMake(0, 1)
        
        let buttonPrevious = UIBarButtonItem(title:"Retour", style:UIBarButtonItemStyle.Done, target:nil, action:nil)
        buttonPrevious.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red:245.0/255.0, green:245.0/255.0, blue:245.0/255.0, alpha:1.0), NSShadowAttributeName: shadow, NSFontAttributeName: UIFont(name:"HelveticaNeue-CondensedBlack", size:21.0)!], forState:UIControlState.Normal)
        
        self.navigationItem.backBarButtonItem = buttonPrevious
        
        if (!self.sauvegarde.boolForKey("initialisationDone"))
        {
            var i = 0
            while (i < self.dicteesArray.count)
            {
                self.sauvegarde.setInteger(-1, forKey:"NombreFautesDictee" + String(i + 1))
                i += 1
            }
            self.sauvegarde.setBool(true, forKey:"initialisationDone")
            self.sauvegarde.synchronize()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated:true)
        
        super.viewDidAppear(animated)
    }

    internal func dicteeDone(nombreFautes: Int, dictee: Int)
    {
        let ancienScore = self.sauvegarde.integerForKey("NombreFautesDictee" + String(dictee))
        if (ancienScore == -1 || ancienScore > nombreFautes)
        {
            self.sauvegarde.setInteger(nombreFautes, forKey:"NombreFautesDictee" + String(dictee))
            self.sauvegarde.synchronize()
        }
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dicteesArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TableViewCellWithImage

        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        cell.textLabel?.text = "Dictée N°" + String(indexPath.row + 1)
        
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.textLabel?.numberOfLines = 0
        
        if (self.sauvegarde.integerForKey("NombreFautesDictee" + String(indexPath.row + 1)) != -1)
        {
            cell.textLabel?.text = cell.textLabel!.text! + " : " + String(self.sauvegarde.integerForKey("NombreFautesDictee" + String(indexPath.row))) + " faute(s) (meilleur score)"
        }

        cell.imageView?.image = UIImage(named:"dictee.png")
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dicteeViewController = DicteeViewController()
        
        dicteeViewController.dictee = indexPath.row + 1
        dicteeViewController.accueilTableViewController = self
        dicteeViewController.text = self.dicteesArray[indexPath.row] as! String
        
        self.navigationController?.pushViewController(dicteeViewController, animated:true)
    }

}
