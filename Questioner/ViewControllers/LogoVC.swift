//
//  LogoVC.swift
//  Questioner
//
//  Created by negar on 97/Farvardin/09 AP.
//  Copyright © 1397 negar. All rights reserved.
//

import UIKit

class LogoVC: UIViewController , UserDelegate{
    let defaults = UserDefaults.standard
    let userHelper = UserHelper()
    var repeatTime = 0

    var stdPhone = ""
    var stdActive = false

    @IBOutlet weak var logoView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        userHelper.delegate = self
        repeatTime = 0


        if (defaults.object(forKey: "StudentData") != nil) {
            let decoder = try? JSONDecoder().decode(Student.self, from: defaults.object(forKey: "StudentData") as! Data)
            if let stdPhone = decoder?.phone,
                let stdActive = decoder?.active {
                self.stdPhone = stdPhone
                self.stdActive = stdActive
            } else {
                self.performSegue(withIdentifier: "AfterLogoSegue", sender: self)
            }
        } else {
            self.performSegue(withIdentifier: "AfterLogoSegue", sender: self)
        }

        // Do any additional setup after loading the view.

    }

    func checks() {
        if Connectivity.isConnectedToInternet(){
            flowDetector()
        }else{
            let alert = UIAlertController(title: "Connection", message: "Please make sure that your phone is connected to internet.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok!", style: .default) {
                UIAlertAction in
                self.checks()
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {

        UIView.animate(withDuration: 1, delay: 2, options: .curveEaseOut, animations: {
            self.logoView.layer.opacity = 0
        }, completion: nil)

    }

    override func viewDidAppear(_ animated: Bool) {
        sleep(3)
        checks()
    }



    func flowDetector() {
        if stdActive {
            userHelper.getExpireDate(phone: stdPhone)
            userHelper.isFreeTrialAvailable(phone: stdPhone)
            userHelper.isChattingOrQuestioning(phone: stdPhone)
            userHelper.setFCMToken(phone: stdPhone)
        } else {
            self.performSegue(withIdentifier: "AfterLogoSegue", sender: self)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func successfulStatusUpdate(isQuestioning: Bool, isChatting: Bool, questionType: String, conversationId: String) {
        repeatTime = 0
        if isChatting {
            let chatVC = SegueHelper.createViewController(storyboardName: "Main", viewControllerId: "ChatVC") as! ChatVC
            chatVC.conversationId = conversationId
            switch questionType {
            case "science":
                chatVC.type = .science
            case "math":
                chatVC.type = .math
            case "english":
                chatVC.type = .english
            case "toefl":
                chatVC.type = .toefl
            default:
                break
            }
            SegueHelper.presentViewController(sourceViewController: self, destinationViewController: chatVC)
        } else if isQuestioning {
            let sendQVC = SegueHelper.createViewController(storyboardName: "Main", viewControllerId: "SendQuestionVC") as! SendQuestionVC
            switch questionType {
            case "science":
                sendQVC.type = .science
            case "math":
                sendQVC.type = .math
            case "english":
                sendQVC.type = .english
            case "toefl":
                sendQVC.type = .toefl
            default:
                break
            }
            sendQVC.isSearching = true
            SegueHelper.presentViewController(sourceViewController: self, destinationViewController: sendQVC)
        } else if (defaults.object(forKey: "StudentData") != nil) {
            let chooseCategoryVC = SegueHelper.createViewController(storyboardName: "Main", viewControllerId: "ChooseCategoryVC")
            SegueHelper.presentViewController(sourceViewController: self, destinationViewController: chooseCategoryVC)

        } else {
            self.performSegue(withIdentifier: "AfterLogoSegue", sender: self)
        }
    }

    func unsuccessfulStatusUpdate(error: String) {
        repeatTime += 1
        if repeatTime < 6{
            userHelper.isChattingOrQuestioning(phone: stdPhone)
        } else if repeatTime == 6{
            ViewHelper.showToastMessage(message: error)
            repeatTime = 0
        }
    }

    func successfulPaymentOperation(message: String) {
        repeatTime = 0
        if (defaults.object(forKey: "StudentData") != nil) {
            let decoder = try? JSONDecoder().decode(Student.self, from: defaults.object(forKey: "StudentData") as! Data)
            decoder?.expireDate = message
            let encoder = JSONEncoder()
            if let studentData = try? encoder.encode(decoder) {
                UserDefaults.standard.set(studentData, forKey: "StudentData")
            }else{
                ViewHelper.showToastMessage(message: "please try to login again!")
            }
        }
    }

    func unsuccessfulPaymentOperation() {
        repeatTime += 1
        if repeatTime < 6{
            userHelper.getExpireDate(phone: stdPhone)
        } else if repeatTime == 6{
            repeatTime = 0
        }
    }

    func successfulTrial(isFreeTrialAvailable: Bool) {
        repeatTime = 0
        if (defaults.object(forKey: "StudentData") != nil) {
            let decoder = try? JSONDecoder().decode(Student.self, from: defaults.object(forKey: "StudentData") as! Data)
            decoder?.isFreeTrialAvailable = isFreeTrialAvailable
            let encoder = JSONEncoder()
            if let studentData = try? encoder.encode(decoder) {
                UserDefaults.standard.set(studentData, forKey: "StudentData")
            }else{
                ViewHelper.showToastMessage(message: "please try to login again!")
            }
        }
    }
    func unsuccessfulTrial() {
        repeatTime += 1
        if repeatTime < 6{
            userHelper.isFreeTrialAvailable(phone: stdPhone)
        } else if repeatTime == 6{
            repeatTime = 0
        }
    }

    func successfulOperation() {
        repeatTime = 0
    }

    func unsuccessfulOperation(error: String) {
        repeatTime += 1
        if repeatTime < 6{
            userHelper.setFCMToken(phone: stdPhone)
        } else if repeatTime == 6{
            ViewHelper.showToastMessage(message: error)
            repeatTime = 0
        }
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
