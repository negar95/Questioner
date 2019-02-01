//
//  PaymentVC.swift
//  Questioner
//
//  Created by negar on 97/Tir/23 AP.
//  Copyright © 1397 negar. All rights reserved.
//

import UIKit
import ZarinPalSDKPayment    

class PaymentVC: UIViewController, ZarinPalPaymentDelegate, UserDelegate {

    @IBOutlet weak var indicatorBackView: UIView!
    
    @IBOutlet weak var indicatorView: UIView!
    var firstAmount = 10000
    var secondAmount = 10000

    var retryCount = 0
    var expireDate = Date()

    let defaults = UserDefaults.standard
    let userHelper = UserHelper()

    var phone = ""

    @IBOutlet weak var freeTrialBtn: UIButton!
    @IBOutlet weak var oneOneBtn: UIButton!
    @IBOutlet weak var oneAllBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        userHelper.delegate = self
        retryCount = 0
        indicatorBackView.isHidden = true

        if (defaults.object(forKey: "StudentData") != nil) {
            let decoder = try? JSONDecoder().decode(Student.self, from: defaults.object(forKey: "StudentData") as! Data)
            if let phone = decoder?.phone {
                self.phone = phone
            } else {
                ViewHelper.showToastMessage(message: "an authentication error occurred, please contact us!")
            }
        } else {
            ViewHelper.showToastMessage(message: "an authentication error occurred, please contact us!")
        }

        setBtnImgs()
        setBtns()

        self.view.addBackground(imageName: "background1", contentMode: .scaleAspectFill)
        indicatorView.layer.cornerRadius = 20
        indicatorView.layer.masksToBounds = true
        indicatorView.alpha = 0.7

        freeTrialBtn.addTarget(self, action: #selector(self.freeTrialUsed(sender:)), for: .touchUpInside)
        
        oneOneBtn.addTarget(self, action: #selector(self.firstBtnFunction(sender:)), for: .touchUpInside)

        oneAllBtn.addTarget(self, action: #selector(self.secondBtnFunction(sender:)), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }

    
    func setBtnImgs() {
        freeTrialBtn.setImage(UIImage(named: "paymentBtn1"), for: .normal)
        freeTrialBtn.setImage(UIImage(named: "paymentBtnPressed1"), for: .highlighted)

        oneOneBtn.setImage(UIImage(named: "paymentBtn2"), for: .normal)
        oneOneBtn.setImage(UIImage(named: "paymentBtnPressed2"), for: .highlighted)
        oneOneBtn.setImage(UIImage(named: "paymentBtnDisabled2"), for: .disabled)

        oneAllBtn.setImage(UIImage(named: "paymentBtn3"), for: .normal)
        oneAllBtn.setImage(UIImage(named: "paymentBtnPressed3"), for: .highlighted)
        oneAllBtn.setImage(UIImage(named: "paymentBtnDisabled3"), for: .disabled)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func isFreeTrialAvailable() -> Bool {
        if (defaults.object(forKey: "StudentData") != nil) {
            let decoder = try? JSONDecoder().decode(Student.self, from: defaults.object(forKey: "StudentData") as! Data)

            if let isFreeTrialAvailable = decoder?.isFreeTrialAvailable{
                return isFreeTrialAvailable
            } else {
                ViewHelper.showToastMessage(message: "please login again!")
            }
        }else{
            ViewHelper.showToastMessage(message: "please login again!")
        }
        return false
    }

    func setBtns(){
        if isFreeTrialAvailable(){
            freeTrialBtn.isHidden = false
            oneOneBtn.isEnabled = false
            oneAllBtn.isEnabled = false
        }else{
            freeTrialBtn.isHidden = true
            oneOneBtn.isEnabled = true
            oneAllBtn.isEnabled = true
        }
    }


    func didSuccess(refID: String, authority: String, builder: ZarinPal.Builder) {
        let date = Date()
        var dateComponent = DateComponents()
        if builder.amount == firstAmount {
            dateComponent.month = 1
            dateComponent.day = 2
            expireDate = Calendar.current.date(byAdding: dateComponent, to: date)!
            userHelper.setExpireDate(phone: phone, expireDate: expireDate)
        } else if builder.amount == secondAmount {
            dateComponent.month = 3
            dateComponent.day = 2
            expireDate = Calendar.current.date(byAdding: dateComponent, to: date)!
            userHelper.setExpireDate(phone: phone, expireDate: expireDate)
        } else {
            ViewHelper.showToastMessage(message: "some error occurred with the amount you payed, please contact us!")
        }
    }

    func didFailure(code: Int, authority: String?) {
        indicatorBackView.isHidden = true

        ViewHelper.showToastMessage(message: "unsuccessful payment")
    }

    @objc func freeTrialUsed(sender: UIButton){
        indicatorBackView.isHidden = false

        if Connectivity.isConnectedToInternet(){
            let date = Date()
            var dateComponent = DateComponents()
            dateComponent.day = 8
            expireDate = Calendar.current.date(byAdding: dateComponent, to: date)!
            userHelper.setExpireDate(phone: phone, expireDate: expireDate)
        }else{
            let alert = UIAlertController(title: "Connection", message: "Please make sure that your phone is connected to internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok!", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }

    @objc func firstBtnFunction(sender: UIButton) {
        indicatorBackView.isHidden = false

        if Connectivity.isConnectedToInternet(){

            let zarinpal = ZarinPal.Builder(vc: self, merchantID: "783b49c8-4485-11e7-bb64-000c295eb8fc", amount: firstAmount, description: "description");

            zarinpal.indicatorColor = UIColor.white; //this set indicator color *optional
            zarinpal.title = "Payment Gateway"; //this set title of payment page *optional
            zarinpal.pageBackgroundColor = UIColor.lightGray; // this set background payment color *optional
            zarinpal.email = "farzad.shadafza@gmail.com"; //this set email *optional
            zarinpal.mobile = "09123800378"; //this set mobile *optional
            zarinpal
                .build()
                .start(delegate: self)
        }else{
            let alert = UIAlertController(title: "Connection", message: "Please make sure that your phone is connected to internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok!", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }

    @objc func secondBtnFunction(sender: UIButton) {
        indicatorBackView.isHidden = false

        if Connectivity.isConnectedToInternet(){
            let zarinpal = ZarinPal.Builder(vc: self, merchantID: "783b49c8-4485-11e7-bb64-000c295eb8fc", amount: secondAmount, description: "description");

            zarinpal.indicatorColor = UIColor.white; //this set indicator color *optional
            zarinpal.title = "Payment Gateway"; //this set title of payment page *optional
            zarinpal.pageBackgroundColor = UIColor.lightGray; // this set background payment color *optional
            zarinpal.email = "farzad.shadafza@gmail.com"; //this set email *optional
            zarinpal.mobile = "09123800378"; //this set mobile *optional
            zarinpal
                .build()
                .start(delegate: self)
        }else{
            let alert = UIAlertController(title: "Connection", message: "Please make sure that your phone is connected to internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok!", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func successfulPaymentOperation(message: String) {
        let encoder = JSONEncoder()
        let formatter = DateFormatter()

        retryCount = 0
        indicatorBackView.isHidden = true

        if (defaults.object(forKey: "StudentData") != nil) {
            let decoder = try? JSONDecoder().decode(Student.self, from: defaults.object(forKey: "StudentData") as! Data)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000001Z'"
            decoder?.expireDate = formatter.string(from: expireDate)

            if isFreeTrialAvailable(){
                    decoder?.isFreeTrialAvailable = false
            }

            if let studentData = try? encoder.encode(decoder) {
                UserDefaults.standard.set(studentData, forKey: "StudentData")
            }
        }
        let sendQuestionVC = SegueHelper.createViewController(storyboardName: "Main", viewControllerId: "SendQuestionVC")
        SegueHelper.presentViewController(sourceViewController: self, destinationViewController: sendQuestionVC)
    }

    func unsuccessfulOperation(error: String) {
        indicatorBackView.isHidden = true

        if retryCount<10{
            userHelper.setExpireDate(phone: phone, expireDate: expireDate)
            retryCount += 1
        }else{
            ViewHelper.showToastMessage(message: error + ", please contact us!")
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
