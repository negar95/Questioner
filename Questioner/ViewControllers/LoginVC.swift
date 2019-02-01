//
//  LoginVC.swift
//  Questioner
//
//  Created by negar on 97/Farvardin/04 AP.
//  Copyright © 1397 negar. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UserDelegate, UITextFieldDelegate {

    let defaults = UserDefaults.standard

    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var passwordView: UIView!

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var indic: UIActivityIndicatorView!

    @IBOutlet weak var loginBtn: UIButton!

    var userHelper = UserHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.indic.isHidden = true
        userHelper.delegate = self
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
        passwordView.isHidden = true
        usernameView.isHidden = true

        self.view.addBackground(imageName: "background1", contentMode: .scaleAspectFill)
    }

    override func viewDidAppear(_ animated: Bool) {
        editView(viewToEdit: usernameView)
        editView(viewToEdit: passwordView)
        passwordView.isHidden = false
        usernameView.isHidden = false
    }

    func editView(viewToEdit: UIView) {

        viewToEdit.layer.cornerRadius = viewToEdit.frame.height / 2;
        viewToEdit.clipsToBounds = true

        let viewShadowframe = CGRect(x: viewToEdit.frame.origin.x - 5, y: viewToEdit.frame.origin.y + 5, width: viewToEdit.frame.width, height: viewToEdit.frame.height)
        self.view.addSubview(ViewHelper.MakeShadowView(frame: viewShadowframe, color: .black, opacity: 0.5, radius: viewToEdit.frame.height / 2))
        self.view.bringSubviewToFront(viewToEdit)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginPressed(_ sender: Any) {
        if Connectivity.isConnectedToInternet(){
            loginBtn.isEnabled = false

            if usernameTF.text != nil && passwordTF.text != nil {
                self.indic.isHidden = false
                self.indic.startAnimating()
                userHelper.login(phone: usernameTF.text!, password: passwordTF.text!)
            } else {
                ViewHelper.showToastMessage(message: "All fields are required")
            }
        }else{
            let alert = UIAlertController(title: "Connection", message: "Please make sure that your phone is connected to internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok!", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }
    func successfulOperation() {
        loginBtn.isEnabled = true

        self.indic.isHidden = true
        self.indic.stopAnimating()

        userHelper.getExpireDate(phone: usernameTF.text!)
        userHelper.isFreeTrialAvailable(phone: usernameTF.text!)
        userHelper.isChattingOrQuestioning(phone: usernameTF.text!)
    }

    func successfulStatusUpdate(isQuestioning: Bool, isChatting: Bool, questionType: String, conversationId: String) {
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
        } else{
            let chooseCategoryVC = SegueHelper.createViewController(storyboardName: "Main", viewControllerId: "ChooseCategoryVC")
            SegueHelper.presentViewController(sourceViewController: self, destinationViewController: chooseCategoryVC)

        }
    }
    func unsuccessfulOperation(error: String) {
        loginBtn.isEnabled = true

        self.indic.isHidden = true
        self.indic.stopAnimating()
        ViewHelper.showToastMessage(message: error)
    }

    func successfulPaymentOperation(message: String) {
        if (defaults.object(forKey: "StudentData") != nil) {
            let decoder = try? JSONDecoder().decode(Student.self, from: defaults.object(forKey: "StudentData") as! Data)
            decoder?.expireDate = message
            let encoder = JSONEncoder()
            if let studentData = try? encoder.encode(decoder) {
                UserDefaults.standard.set(studentData, forKey: "StudentData")
            }else{
                ViewHelper.showToastMessage(message: "please try to login again!")
            }
        }else{
            ViewHelper.showToastMessage(message: "please try to login again!")
        }

    }

    func unsuccessfulPaymentOperation() {
        userHelper.getExpireDate(phone: usernameTF.text!)
    }

    func successfulTrial(isFreeTrialAvailable: Bool) {
        if (defaults.object(forKey: "StudentData") != nil) {
            let decoder = try? JSONDecoder().decode(Student.self, from: defaults.object(forKey: "StudentData") as! Data)
            decoder?.isFreeTrialAvailable = isFreeTrialAvailable
            let encoder = JSONEncoder()
            if let studentData = try? encoder.encode(decoder) {
                UserDefaults.standard.set(studentData, forKey: "StudentData")
            }else{
                ViewHelper.showToastMessage(message: "please try to login again!")
            }
        }else{
            ViewHelper.showToastMessage(message: "please try to login again!")
        }
    }
    func unsuccessfulTrial() {
        userHelper.isFreeTrialAvailable(phone: usernameTF.text!)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTF{
            passwordTF.becomeFirstResponder()
        }else{
            dismissKeyboard()
        }
        return true
    }
}
