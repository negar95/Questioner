//
//  HistoryVC.swift
//  Questioner
//
//  Created by negar on 97/Azar/13 AP.
//  Copyright © 1397 negar. All rights reserved.
//

import UIKit

class HistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageDelegate, UserDelegate{

    let defaults = UserDefaults.standard
    let messageHelper = MessageHelper()
    let userHelper = UserHelper()
    var conversations = [Conversation()]

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var conversationsTable: UITableView!
    @IBOutlet weak var noConversationView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addBackground(imageName: "background1", contentMode: .scaleAspectFill)
        self.backBtn.setImage(UIImage(named: "mathBtnBack"), for: .normal)
        self.backBtn.setImage(UIImage(named: "mathBtnBackPressed"), for: .highlighted)
        self.backBtn.addTarget(self, action: #selector(backBtnPressed), for: .touchUpInside)

        indicator.startAnimating()
        // Do any additional setup after loading the view.
        conversationsTable.delegate = self
        conversationsTable.dataSource = self
        conversationsTable.isHidden = true

        messageHelper.delegate = self
        userHelper.delegate = self

        noConversationView.isHidden = true
        noConversationView.layer.masksToBounds = true
        noConversationView.layer.cornerRadius = 20
    }
    override func viewWillAppear(_ animated: Bool) {
        self.checkNet()
    }

    func checkNet() {
        if Connectivity.isConnectedToInternet(){
            self.getConversations()
        }else{
            let alert = UIAlertController(title: "Connection", message: "Please make sure that your phone is connected to internet.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok!", style: .default) {
                UIAlertAction in
                self.checkNet()
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getConversations() {
        if (defaults.object(forKey: "StudentData") != nil) {
            let decoder = try? JSONDecoder().decode(Student.self, from: defaults.object(forKey: "StudentData") as! Data)
            if let stdPhone = decoder?.phone,
                let stdActive = decoder?.active {
                if stdActive{
                    messageHelper.getConversation(studentId: stdPhone)
                }else{
                    ViewHelper.showToastMessage(message: "your account isn't active.")
                }
            }else{
                ViewHelper.showToastMessage(message: "please login again!")
            }
        }else{
            ViewHelper.showToastMessage(message: "please login again!")
        }

    }

    func getConversationsSuccessfully(conversations: [Conversation]) {
        if conversations.count > 0 {
            noConversationView.isHidden = true
            self.conversations = conversations
            conversationsTable.reloadData()
            conversationsTable.isHidden = false

        }else{
            noConversationView.isHidden = false
        }

        indicator.isHidden = true
        indicator.stopAnimating()
    }

    func getMessagesUnsuccessfully(error: String) {
        ViewHelper.showToastMessage(message: error)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath) as! ConversationTVC
        cell.conversation = conversations[indexPath.row]

        cell.layer.cornerRadius = 20
        cell.layer.opacity = 0.6

        cell.awakeFromNib()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ConversationTVC
        let chatVC = SegueHelper.createViewController(storyboardName: "Main", viewControllerId: "ChatVC") as! ChatVC
        let conversation = cell.conversation

        chatVC.conversationId = conversation.conversationId
        chatVC.isRated = conversation.isRated
        chatVC.isEnd = conversation.isEnd
        switch conversation.questionType {
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
    }

    @objc func backBtnPressed(){
        if Connectivity.isConnectedToInternet(){
            let chooseCategoryVC = SegueHelper.createViewController(storyboardName: "Main", viewControllerId: "ChooseCategoryVC")

            if (defaults.object(forKey: "StudentData") != nil) {
                let decoder = try? JSONDecoder().decode(Student.self, from: defaults.object(forKey: "StudentData") as! Data)
                if let stdPhone = decoder?.phone{
                    userHelper.isChattingOrQuestioning(phone: stdPhone)
                } else {
                    SegueHelper.presentViewController(sourceViewController: self, destinationViewController: chooseCategoryVC)
                }
            } else {
                SegueHelper.presentViewController(sourceViewController: self, destinationViewController: chooseCategoryVC)
            }

        }else{
            let alert = UIAlertController(title: "Connection", message: "Please make sure that your phone is connected to internet.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok!", style: .default) {
                UIAlertAction in
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }



    }
    func successfulStatusUpdate(isQuestioning: Bool, isChatting: Bool, questionType: String, conversationId: String) {
        if isChatting{
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
        }else{
            let chooseCategoryVC = SegueHelper.createViewController(storyboardName: "Main", viewControllerId: "ChooseCategoryVC")
            SegueHelper.presentViewController(sourceViewController: self, destinationViewController: chooseCategoryVC)
        }
    }
    func unsuccessfulStatusUpdate(error: String) {
        let chooseCategoryVC = SegueHelper.createViewController(storyboardName: "Main", viewControllerId: "ChooseCategoryVC")
        SegueHelper.presentViewController(sourceViewController: self, destinationViewController: chooseCategoryVC)
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
