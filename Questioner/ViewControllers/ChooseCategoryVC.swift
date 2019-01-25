//
//  ChooseCategoryVC.swift
//  Questioner
//
//  Created by negar on 97/Tir/22 AP.
//  Copyright © 1397 negar. All rights reserved.
//

import UIKit

class ChooseCategoryVC: UIViewController, UserDelegate {

    @IBOutlet weak var mathBtn: UIButton!
    @IBOutlet weak var scienceBtn: UIButton!
    @IBOutlet weak var engBtn: UIButton!
    @IBOutlet weak var toeflBtn: UIButton!

    let defaults = UserDefaults.standard
    let userHelper = UserHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        userHelper.delegate = self

        self.view.addBackground(imageName: "background1", contentMode: .scaleAspectFill)

        mathBtn.setImage(UIImage(named: "typeBtnPressed1"), for: .highlighted)
        scienceBtn.setImage(UIImage(named: "typeBtnPressed2"), for: .highlighted)
        engBtn.setImage(UIImage(named: "typeBtnPressed3"), for: .highlighted)
        toeflBtn.setImage(UIImage(named: "typeBtnPressed4"), for: .highlighted)

        mathBtn.tag = 1
        scienceBtn.tag = 2
        engBtn.tag = 3
        toeflBtn.tag = 4

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func checkExpireDate() -> Bool {
        var isExpired = true
        if (defaults.object(forKey: "StudentData") != nil) {
            let decoder = try? JSONDecoder().decode(Student.self, from: defaults.object(forKey: "StudentData") as! Data)

            if let expireDate = decoder?.expireDate{
                let today = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX'Z'"
                if let date = dateFormatter.date(from: expireDate) {
                    if let daysToExpire = Calendar.current.dateComponents([.day], from: today, to: date).day {
                        if daysToExpire > 0 {
                            isExpired = false
                        } else {
                            isExpired = true
                        }
                    }
                } else {
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                    if let date = dateFormatter.date(from: expireDate) {
                        if let daysToExpire = Calendar.current.dateComponents([.day], from: today, to: date).day {
                            if daysToExpire > 0 {
                                isExpired = false
                            } else {
                                isExpired = true
                            }
                        }
                    }
                }
            } else {
                ViewHelper.showToastMessage(message: "please login again!")
            }
        }else{
            ViewHelper.showToastMessage(message: "please login!")
        }
        return isExpired
    }

    @IBAction func changeLanguage(sender: AnyObject) {
        if checkExpireDate() {
            let paymentVC = SegueHelper.createViewController(storyboardName: "Main", viewControllerId: "PaymentVC") as! PaymentVC
            SegueHelper.presentViewController(sourceViewController: self, destinationViewController: paymentVC)
        } else {
            guard let button = sender as? UIButton else {
                return
            }
            let sendQuestionVC = SegueHelper.createViewController(storyboardName: "Main", viewControllerId: "SendQuestionVC") as! SendQuestionVC
            sendQuestionVC.isSearching = false

            switch button.tag {
            case 1:
                sendQuestionVC.type = .math
            case 2:
                sendQuestionVC.type = .science
            case 3:
                sendQuestionVC.type = .english
            case 4:
                sendQuestionVC.type = .toefl
            default:
                break
            }
            SegueHelper.presentViewController(sourceViewController: self, destinationViewController: sendQuestionVC)
        }
    }

}
