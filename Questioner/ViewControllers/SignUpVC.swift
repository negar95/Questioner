//
//  SignUpVC.swift
//  Questioner
//
//  Created by negar on 97/Farvardin/04 AP.
//  Copyright © 1397 negar. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController, UserDelegate, UITextFieldDelegate {

    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordRepeatView: UIView!
    @IBOutlet weak var conditionsView: UIView!

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var repeatpass: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!

    @IBOutlet weak var indic: UIActivityIndicatorView!
    var userHelper = UserHelper()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indic.isHidden = true
        userHelper.delegate = self
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.

        name.delegate = self
        email.delegate = self
        phoneNumber.delegate = self
        pass.delegate = self
        repeatpass.delegate = self

        self.conditionsView.addBackground(imageName: "background3", contentMode: .scaleAspectFill)

    }


    @IBAction func acceptBtnPressed(_ sender: Any) {
        self.view.addBackground(imageName: "background1", contentMode: .scaleAspectFill)

        self.editView(viewToEdit: nameView)
        self.editView(viewToEdit: emailView)
        self.editView(viewToEdit: phoneView)
        self.editView(viewToEdit: passwordView)
        self.editView(viewToEdit: passwordRepeatView)

        conditionsView.isHidden = true
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
    @IBAction func signUpPressed(_ sender: Any) {
        if validationCheck(){
            if Connectivity.isConnectedToInternet(){
                signUpBtn.isEnabled = false
                self.indic.isHidden = false
                self.indic.startAnimating()
                userHelper.signup(userName: name.text!, password: pass.text!, phone: phoneNumber.text!, email: email.text!)
            }else{
                let alert = UIAlertController(title: "Connection", message: "Please make sure that your phone is connected to internet.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok!", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func validationCheck() -> Bool {
        var valid = true

        if phoneNumber.text == nil || email.text == nil || name.text == nil || pass.text == nil || repeatpass.text == nil {
            ViewHelper.showToastMessage(message: "All fields are required")
            valid = false
        }else{
            if pass.text != repeatpass.text {
                ViewHelper.showToastMessage(message: "Passwords should match")
                valid = false
            }
            if !ValidationHelper.validateName(name: name.text!){
                ViewHelper.showToastMessage(message: "Please enter a valid name")
                valid = false
            }
            if !ValidationHelper.validateEmail(email: email.text!){
                ViewHelper.showToastMessage(message: "Please enter a valid email")
                valid = false
            }
            if !ValidationHelper.validateCellPhone(phone: phoneNumber.text!){
                ViewHelper.showToastMessage(message: "Please enter a valid phone")
                valid = false
            }
        }
        return valid
    }

    func successfulOperation() {
        signUpBtn.isEnabled = true

        self.indic.isHidden = true
        self.indic.stopAnimating()

        ViewHelper.showToastMessage(message: "Signed UP Succesfully")
        navigationController?.popViewController(animated: true)
    }
    func unsuccessfulOperation(error: String) {
        signUpBtn.isEnabled = true
        
        self.indic.isHidden = true
        self.indic.stopAnimating()

        ViewHelper.showToastMessage(message: error)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == name{
            email.becomeFirstResponder()
        }else if textField == email{
            phoneNumber.becomeFirstResponder()
        }else if textField == phoneNumber{
            pass.becomeFirstResponder()
        }else if textField == pass{
            repeatpass.becomeFirstResponder()
        }else{
            dismissKeyboard()
        }
        return true
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
