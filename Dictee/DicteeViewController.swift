//
//  DicteeViewController.swift
//  Dictee
//
//  Created by Thomas Mac on 24/06/2016.
//  Copyright © 2016 ThomasNeyraut. All rights reserved.
//

import UIKit
import AVFoundation

class DicteeViewController: UIViewController, AVSpeechSynthesizerDelegate, UITextViewDelegate {

    internal var text = ""
    
    internal var accueilTableViewController = AccueilTableViewController()
    
    internal var dictee = -1
    
    private let textView = UITextView()
    
    private let sentencesArray = NSMutableArray()
    
    private var timer = NSTimer()
    
    private var compteur = 0
    
    private var indice = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Dictée N°" + String(self.dictee)
        
        self.compteur = 0
        
        self.indice = 0
        
        let decalage = CGFloat(10.0)
        
        self.textView.frame = CGRectMake(decalage, (self.navigationController?.navigationBar.frame.size.height)! + 30.0, self.view.frame.size.width - 2 * decalage, self.view.frame.size.height - (self.navigationController?.navigationBar.frame.size.height)! - 30.0 - 2 * decalage - (self.navigationController?.toolbar.frame.size.height)!)
        
        self.textView.text = "écrivez ici..."
        self.textView.textColor = UIColor.lightGrayColor()
        self.textView.font = UIFont(name:"HelveticaNeue-CondensedBlack", size:18.0)
        self.textView.autocorrectionType = UITextAutocorrectionType.No
        
        self.textView.contentInset = UIEdgeInsetsMake(-60.0, 0.0, 0.0, 0.0)
        
        self.textView.layer.borderColor = UIColor(red:213.0/255.0, green:210.0/255.0, blue:199.0/255.0, alpha:1.0).CGColor
        self.textView.layer.borderWidth = 2.5
        self.textView.layer.cornerRadius = 7.5
        self.textView.layer.shadowOffset = CGSizeMake(0, 1)
        self.textView.layer.shadowColor = UIColor.lightGrayColor().CGColor
        self.textView.layer.shadowRadius = 8.0
        self.textView.layer.shadowOpacity = 0.8
        self.textView.layer.masksToBounds = false
        
        self.textView.delegate = self
        
        self.view.addSubview(self.textView)
        
        self.setSentencesArray()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated:true)
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target:self, selector:#selector(self.doDictee), userInfo:nil, repeats:true)
        
        super.viewDidAppear(animated)
    }
    
    @objc private func buttonValidateActionListener()
    {
        let alertController = UIAlertController(title:"Validation", message:"Êtes-vous sûr de valider votre réponse ?", preferredStyle:UIAlertControllerStyle.Alert)
        
        let alertActionOne = UIAlertAction(title:"Oui", style:UIAlertActionStyle.Default) { (_) in
            self.verificationAnswer(self.textView.text)
        }
        
        let alertActionTwo = UIAlertAction(title:"Non", style:UIAlertActionStyle.Default) { (_) in }
        
        alertController.addAction(alertActionOne)
        alertController.addAction(alertActionTwo)
        
        self.presentViewController(alertController, animated:true, completion:nil)
    }
    
    private func verificationAnswer(answer: String)
    {
        var nombreFautes = 0
        
        let limite = min(answer.characters.count, self.textView.text.characters.count)
        var i = 0
        while (i < limite)
        {
            let wordAnswer = self.getNextWord(answer, index:i)
            let wordText = self.getNextWord(self.text, index:i)
            let lim = min(wordAnswer.characters.count, wordText.characters.count)
            nombreFautes += max(wordAnswer.characters.count, wordText.characters.count) - lim
            var j = 0
            while (j < lim)
            {
                if (self.getCharacterAtIndex(wordAnswer, index:j).lowercaseString != self.getCharacterAtIndex(wordText, index:j).lowercaseString)
                {
                    nombreFautes += 1
                }
                j += 1
            }
            if (limite == answer.characters.count)
            {
                i += wordAnswer.characters.count
            }
            else
            {
                i += wordText.characters.count
            }
        }
        
        self.accueilTableViewController.dicteeDone(nombreFautes, dictee:self.dictee)
        
        let alertController = UIAlertController(title:"Résultats", message:"Vous avez fait " + String(nombreFautes) + " faute(s).", preferredStyle:UIAlertControllerStyle.Alert)
        
        let alertAction = UIAlertAction(title:"OK", style:UIAlertActionStyle.Default) { (_) in
            self.accueilTableViewController.tableView.reloadData()
            self.navigationController?.popViewControllerAnimated(true)
        }
        alertController.addAction(alertAction)
        
        self.presentViewController(alertController, animated:true, completion:nil)
    }
    
    private func getNextWord(s: String, index: Int) -> String
    {
        var resultat = ""
        var i = index
        while (self.getCharacterAtIndex(s, index:i) == " ")
        {
            i += 1
        }
        while (i < s.characters.count && self.getCharacterAtIndex(s, index:i) != " ")
        {
            resultat = resultat + self.getCharacterAtIndex(s, index:i)
            i += 1
        }
        return resultat
    }
    
    private func getCharacterAtIndex(s: String, index: Int) -> String
    {
        var i = 0
        for character in s.characters
        {
            if (i == index)
            {
                return String(character)
            }
            i += 1
        }
        return ""
    }
    
    private func getStringWithoutSpace(s: String) -> String
    {
        var resultat = ""
        for character in s.characters
        {
            if (character != " ")
            {
                resultat = resultat + String(character)
            }
        }
        return resultat
    }
    
    private func setSentencesArray()
    {
        var s = ""
        for character in self.text.characters
        {
            s = s + String(character)
            switch character {
            case ",":
                s = s + " virgule"
                self.sentencesArray.addObject(s)
                s = ""
                break
            case "?":
                s = s + " point d'interrogation"
                self.sentencesArray.addObject(s)
                s = ""
                break
            case ";":
                s = s + " point virgule"
                self.sentencesArray.addObject(s)
                s = ""
                break
            case ":":
                s = s + " deux points"
                self.sentencesArray.addObject(s)
                s = ""
                break
            case ".":
                s = s + " point"
                self.sentencesArray.addObject(s)
                s = ""
                break
            default: break
            }
        }
        self.sentencesArray[self.sentencesArray.count - 1] = String(self.sentencesArray[self.sentencesArray.count - 1]) + " final"
    }
    
    @objc private func doDictee()
    {
        self.timer.invalidate()
        self.indice = 0
        if (self.indice < self.sentencesArray.count)
        {
            self.speak(String(self.sentencesArray[self.indice]))
        }
    }
    
    private func speak(toSay: String)
    {
        let sp = AVSpeechUtterance(string:toSay)
        let a = AVSpeechSynthesizer()
        
        a.delegate = self
        
        sp.rate = 0.5
        sp.pitchMultiplier = 1
        sp.voice = AVSpeechSynthesisVoice(language:"fr-FR")
        
        a.speakUtterance(sp)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView.text == "écrivez ici..." && textView.textColor == UIColor.lightGrayColor())
        {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (textView.text == "" && text == "\n")
        {
            textView.text = "écrivez ici..."
            textView.textColor = UIColor.lightGrayColor()
        }
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        self.compteur += 1
        if (self.compteur >= 3)
        {
            self.compteur = 0
            self.indice += 1
            if (self.indice < self.sentencesArray.count)
            {
                self.timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target:self, selector:#selector(self.waitAndSpeak), userInfo:nil, repeats:true)
            }
            else
            {
                self.navigationController?.setToolbarHidden(false, animated:true)
                
                self.navigationController?.toolbar.barTintColor = UIColor(red:0.439, green:0.776, blue:0.737, alpha:1)
                
                let shadow = NSShadow()
                
                shadow.shadowColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.8)
                
                shadow.shadowOffset = CGSizeMake(0, 1)
                
                let buttonValidate = UIBarButtonItem(title:"Valider", style:.Plain, target:self, action:#selector(self.buttonValidateActionListener))
                
                buttonValidate.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red:245.0/255.0, green:245.0/255.0, blue:245.0/255.0, alpha:1.0), NSShadowAttributeName: shadow, NSFontAttributeName: UIFont(name:"HelveticaNeue-CondensedBlack", size:21.0)!], forState:UIControlState.Normal)
                
                let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target:nil, action:nil)
                
                self.navigationController?.toolbar.setItems([flexibleSpace, buttonValidate, flexibleSpace], animated:true)
            }
        }
        else
        {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target:self, selector:#selector(self.waitAndSpeak), userInfo:nil, repeats:true)
        }
    }
    
    @objc private func waitAndSpeak()
    {
        self.timer.invalidate()
        if (self.indice < self.sentencesArray.count)
        {
            self.speak(String(self.sentencesArray[self.indice]))
        }
    }

}
