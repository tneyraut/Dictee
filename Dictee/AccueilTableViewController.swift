//
//  AccueilTableViewController.swift
//  Dictee
//
//  Created by Thomas Mac on 24/06/2016.
//  Copyright © 2016 ThomasNeyraut. All rights reserved.
//

import UIKit

class AccueilTableViewController: UITableViewController {

    private let dicteesArray: NSArray = ["DICTEE_1_", "DICTEE_2_", "DICTEE_3_", "DICTEE_4_", "DICTEE_5_"]
    
    private let languagesArray: NSArray = ["Français", "Français Canadien", "English-GB", "English-USA"]
    
    private let referenceLanguageArray: NSArray = ["fr-FR", "fr-CA", "en-GB", "en-US"]
    
    private let referenceDicteeLanguageArray: NSArray = ["FR", "FR", "EN", "EN"]
    
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
            self.sauvegarde.setObject(self.languagesArray[0], forKey:"language")
            var i = 0
            while (i < self.dicteesArray.count)
            {
                self.sauvegarde.setInteger(-1, forKey:"NombreFautesDictee" + String(i + 1))
                i += 1
            }
            self.sauvegarde.setBool(true, forKey:"initialisationDone")
            self.sauvegarde.synchronize()
        }
        
        let rightButton = UIBarButtonItem(title:self.sauvegarde.stringForKey("language"), style:UIBarButtonItemStyle.Done, target:self, action:#selector(self.rightButtonActionListener))
        rightButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red:245.0/255.0, green:245.0/255.0, blue:245.0/255.0, alpha:1.0), NSShadowAttributeName: shadow, NSFontAttributeName: UIFont(name:"HelveticaNeue-CondensedBlack", size:21.0)!], forState:UIControlState.Normal)
        
        self.navigationItem.rightBarButtonItem = rightButton
        
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
    
    @objc private func rightButtonActionListener()
    {
        let alertController = UIAlertController(title:"Language", message:"Choose a language", preferredStyle:.ActionSheet)
        
        var i = 0
        while (i < self.languagesArray.count)
        {
            let s: String = self.languagesArray[i] as! String
            let alertAction = UIAlertAction(title:self.languagesArray[i] as? String, style:.Default) { (_) in
                let shadow = NSShadow()
                shadow.shadowColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.8)
                shadow.shadowOffset = CGSizeMake(0, 1)
                
                let rightButton = UIBarButtonItem(title:s, style:UIBarButtonItemStyle.Done, target:self, action:#selector(self.rightButtonActionListener))
                rightButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red:245.0/255.0, green:245.0/255.0, blue:245.0/255.0, alpha:1.0), NSShadowAttributeName: shadow, NSFontAttributeName: UIFont(name:"HelveticaNeue-CondensedBlack", size:21.0)!], forState:UIControlState.Normal)
                
                self.navigationItem.rightBarButtonItem = rightButton
                
                self.sauvegarde.setObject(s, forKey:"language")
                self.sauvegarde.synchronize()
            }
            alertController.addAction(alertAction)
            i += 1
        }
        let cancelAction = UIAlertAction(title:"Cancel", style:.Default) { (_) in }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated:true, completion:nil)
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
    
    private func getIndiceLanguage() -> Int
    {
        var i = 0
        while (i < self.languagesArray.count)
        {
            if (self.navigationItem.rightBarButtonItem?.title == self.languagesArray[i] as? String)
            {
                return i
            }
            i += 1
        }
        return 0
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
        let indice = self.getIndiceLanguage()
        
        let dicteeViewController = DicteeViewController()
        
        dicteeViewController.dictee = indexPath.row + 1
        dicteeViewController.accueilTableViewController = self
        dicteeViewController.text = NSLocalizedString(self.dicteesArray[indexPath.row] as! String + (self.referenceDicteeLanguageArray[indice] as! String), comment:"")
        dicteeViewController.voice = self.referenceLanguageArray[indice] as! String
        dicteeViewController.referenceLanguage = self.referenceDicteeLanguageArray[indice] as! String
        
        self.navigationController?.pushViewController(dicteeViewController, animated:true)
    }

}
