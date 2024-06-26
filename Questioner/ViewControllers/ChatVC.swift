//
//  SendQuestionVC.swift
//  Questioner
//
//  Created by negar on 97/Tir/23 AP.
//  Copyright © 1397 negar. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift
import FloatRatingView
import MobileCoreServices

class ChatVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, MessageDelegate, UICollectionViewDataSource, FloatRatingViewDelegate{

    @IBOutlet weak var historyBtn: UIButton!

    @IBOutlet weak var questionView: UIView!

//    @IBOutlet weak var questionTF: UITextField!
//    @IBOutlet weak var attachmentBtn: UIButton!
//    @IBOutlet weak var imageBtn: UIButton!
//    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var messagesCollectionView: UICollectionView!

    @IBOutlet weak var buttonOfTheQuestionView: NSLayoutConstraint!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var rateBox: UIView!
    @IBOutlet weak var rateConfirmBtn: UIButton!
    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var rateTitleLbl: UILabel!
    @IBOutlet weak var rateLbl: UILabel!

    var timer = Timer()
    var currentVoiceCell = VoiceMessageCVC()
    var messageHelper = MessageHelper()

    var type = typeEnum.none
    var isEnd = false
    var isRated = false
    var teacherId = ""
    var conversationId = ""

    var messages = [Message()]
    var numOfCurrentMessages : Int = 0
    @IBOutlet weak var inputAreaHeightConstraint: NSLayoutConstraint!

    lazy var messageInputAreaVC: MessageInputAreaViewController = {
        MessageInputAreaViewController(conversationID: conversationId, conversationIsEnded: isEnd, type: type)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        AudioPlayInstance.delegate = self
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
        self.initViews()
        self.initRateView()

        ratingView.isHidden = true

        messageHelper.delegate = self
        messageHelper.sendDelegate = self
        floatRatingView.delegate = self

        messagesCollectionView.delegate = self
        messagesCollectionView.dataSource = self

        messageHelper.conversationId = conversationId

//
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.getMessages()

        messageInputAreaVC.messageVC = self
        messageInputAreaVC.delegate = self
        addChild(messageInputAreaVC)
        view.addSubview(messageInputAreaVC.view)
        messageInputAreaVC.didMove(toParent: self)

        UIView.performWithoutAnimation {
            questionView.addSubview(messageInputAreaVC.view)
        }

        if !isEnd{
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.getMessages), userInfo: nil, repeats: true)
        }else{
            messageInputAreaVC.waitingView.isHidden = false
            messageInputAreaVC.waitingViewIndicator.isHidden = true
        }
    }

    func checkNet() {
        if !Connectivity.isConnectedToInternet() {
            let alert = UIAlertController(title: "Connection", message: "Please make sure that your phone is connected to internet.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok!", style: .default) {
                UIAlertAction in
                self.checkNet()
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkNet()
        let contentSize: CGSize? = messagesCollectionView?.collectionViewLayout.collectionViewContentSize
        if (messagesCollectionView?.bounds.size.height.isLess(than: (contentSize?.height)!))! {
            let targetContentOffset = CGPoint(x: 0.0, y: (contentSize?.height)! - (messagesCollectionView?.bounds.size.height)!)
            messagesCollectionView?.contentOffset = targetContentOffset
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func initViews() {
        messagesCollectionView.isHidden = true

        switch type {
        case .english:
            self.view.addBackground(imageName: "background3", contentMode: .scaleAspectFill)
            self.questionView.backgroundColor = UIColor("#f1dda499")
            self.setBtnImgs(type: "eng")
        case .math:
            self.view.addBackground(imageName: "background4", contentMode: .scaleAspectFill)
            self.questionView.backgroundColor = UIColor("#c2de9c99")
            self.setBtnImgs(type: "math")
        case .science:
            self.view.addBackground(imageName: "background5", contentMode: .scaleAspectFill)
            self.questionView.backgroundColor = UIColor("#c5c9f399")
            self.setBtnImgs(type: "science")
        case .toefl:
            self.view.addBackground(imageName: "background2", contentMode: .scaleAspectFill)
            self.questionView.backgroundColor = UIColor("#a7cdee99")
            self.setBtnImgs(type: "toefl")
        default:
            break
        }

//        self.questionTF.layer.cornerRadius = 30
//        self.questionView.layer.cornerRadius = 30
//        self.questionView.clipsToBounds = true
//
//        if isEnd{
//            sendBtn.isEnabled = false
//        }else{
//            sendBtn.isEnabled = true
//        }

    }

    func initRateView() {
        rateBox.layer.cornerRadius = 30
        rateBox.layer.masksToBounds = true

        self.rateConfirmBtn.setImage(#imageLiteral(resourceName: "confirmBtn"), for: .normal)
        self.rateConfirmBtn.setImage(#imageLiteral(resourceName: "confirmBtnPressed"), for: .highlighted)

        self.floatRatingView.emptyImage = #imageLiteral(resourceName: "emptyStar")
        self.floatRatingView.fullImage = #imageLiteral(resourceName: "fullStar")
        self.floatRatingView.contentMode = .scaleAspectFill
        self.floatRatingView.maxRating = 5
        self.floatRatingView.minRating = 0
        self.floatRatingView.editable = true
        self.floatRatingView.halfRatings = true
    }

    func setBtnImgs(type : String) {
       self.historyBtn.setImage(UIImage(named: "\(type)BtnHistory"), for: .normal)
        self.historyBtn.setImage(UIImage(named: "\(type)BtnHistoryPressed"), for: .highlighted)

//        self.attachmentBtn.setImage(UIImage(named: "\(type)BtnAttachment"), for: .normal)
//        self.attachmentBtn.setImage(UIImage(named: "\(type)BtnAttachment"), for: .highlighted)
//
//        self.imageBtn.setImage(UIImage(named: "\(type)BtnImg"), for: .normal)
//        self.imageBtn.setImage(UIImage(named: "\(type)BtnImgPressed"), for: .highlighted)
//
//        self.sendBtn.setImage(UIImage(named: "\(type)BtnSend"), for: .normal)
//        self.sendBtn.setImage(UIImage(named: "\(type)BtnSendPressed"), for: .highlighted)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.buttonOfTheQuestionView.constant = keyboardHeight
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.buttonOfTheQuestionView.constant = 30
    }

//    @IBAction func imgPressed(_ sender: Any) {
//        let alert = UIAlertController(title: "Alert", message: "Please choose to upload image or take new one:", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "take photo", style: .default, handler: {action in
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                let imagePicker = UIImagePickerController()
//                imagePicker.delegate = self
//                imagePicker.sourceType = .camera;
//                imagePicker.allowsEditing = true
//                self.present(imagePicker, animated: true, completion: nil)
//
//            }else{
//                return
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "upload", style: .default, handler: {action in
//            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//                let imagePicker = UIImagePickerController()
//                imagePicker.delegate = self
//                imagePicker.sourceType = .photoLibrary;
//                imagePicker.allowsEditing = true
//
//                self.present(imagePicker, animated: true, completion: nil)
//            }else{
//                return
//            }
//        }))
//        self.present(alert, animated: true)
//    }

    func sendMessageUnsuccessfully(error: String) {
//        sendBtn.isEnabled = true
//        imageBtn.isEnabled = true
//        attachmentBtn.isEnabled = true

        if error == ""{
            checkNet()
        }else{
            ViewHelper.showToastMessage(message: error)
        }

    }

    @objc func getMessages(){
        messageHelper.getMessage(conversationId: self.conversationId)
    }

    func getMessagesSuccessfully(messages: [Message]) {

        if messages.count > numOfCurrentMessages{
            self.messagesCollectionView.isHidden = false
            self.messages = messages

            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToItem(at: IndexPath(item: messages.count-1, section: 0), at: .top, animated: true)
            numOfCurrentMessages = messages.count

            if (messages.last?.isEnd)! && !isRated{
                self.teacherId = (messages.last?.teacherId)!
                self.ratingView.isHidden = false
                isRated = true
            }
        }
    }

    func getMessagesUnsuccessfully(error: String) {
        if error == ""{
            checkNet()
        }else{
            ViewHelper.showToastMessage(message: error)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if messages.count>0{
            let message = messages[indexPath.row]
            switch message.messageType{
            case 0:
                let textCell = collectionView.dequeueReusableCell(withReuseIdentifier: "txtMessageCell", for: indexPath) as! MessageCVC
                textCell.message = message
                textCell.type = type
                cell = textCell

                cell.awakeFromNib()
            case 1:
                let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageMessageCVC
                imageCell.parentVC = self
                imageCell.message = message
                imageCell.type = type
                imageCell.showImage()
                cell = imageCell

                cell.awakeFromNib()
            case 2:
                let voiceCell = collectionView.dequeueReusableCell(withReuseIdentifier: "voiceCell", for: indexPath) as! VoiceMessageCVC
                voiceCell.message = message
                voiceCell.type = type
                voiceCell.delegate = self
                voiceCell.indexpathraw = indexPath.row
                voiceCell.parentVeiwController = self
                cell = voiceCell

                cell.awakeFromNib()
            default:
                break
            }
        }

        return cell
    }

    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        rateLbl.text = "\(floatRatingView.rating)"
    }

    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Float) {
        rateLbl.text = "\(floatRatingView.rating)"
    }

    @IBAction func sendRate(_ sender: Any) {
        if Connectivity.isConnectedToInternet(){
            rateConfirmBtn.isEnabled = false
            messageHelper.sendRate(teacherId: self.teacherId, rate: floatRatingView.rating * 2, conversationId: self.conversationId)
        }else{
            let alert = UIAlertController(title: "Connection", message: "Please make sure that your phone is connected to internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok!", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func sendRateSuccessfully() {
        ViewHelper.showToastMessage(message: "Thanks!")

        rateConfirmBtn.isEnabled = true
        self.ratingView.isHidden = true
        let historyVC = SegueHelper.createViewController(storyboardName: "Main", viewControllerId: "HistoryVC") as! HistoryVC
        SegueHelper.presentViewController(sourceViewController: self, destinationViewController: historyVC)
    }

    func sendRateUnsuccessfully(error: String) {
        rateConfirmBtn.isEnabled = true
        ViewHelper.showToastMessage(message: error)
    }
}

extension ChatVC: PlayAudioDelegate, ContactAndVoiceMessageCellProtocol {

    func audioPlayStatus(status: AudioPlayerStatus) {
        ViewHelper.showToastMessage(message: status.rawValue)
        currentVoiceCell.resetVoiceAnimation(audioPlayStatus: status)
    }

    func cellDidTapedVoiceButton(_ cell: VoiceMessageCVC, isPlayingVoice: Bool, index: Int) {
        if self.currentVoiceCell == cell {
            ViewHelper.showToastMessage(message:"finished")
            currentVoiceCell.resetVoiceAnimation(audioPlayStatus: .finished)
        }
        
        if isPlayingVoice {
            self.currentVoiceCell = cell
            AudioPlayInstance.startPlaying(messages[index])
        } else {
            AudioPlayInstance.stopPlayer()
        }
    }
}

extension ChatVC: MessageInputAreaViewControllerDelegate {
    func sendChat(message: String?, image: UIImage?, filePath: URL?, type: Int) {
        var typeString = String()
        switch self.type {
        case .english:
            typeString = "english"
        case .math:
            typeString = "math"
        case .science:
            typeString = "science"
        case .toefl:
            typeString = "toefl"
        default:
            break
        }
        messageHelper.sendChat(message: message, filePath: filePath, type: type, images: image, typeString: typeString)
    }

    func adjustInputAreaHeightConstraint(height: CGFloat) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.inputAreaHeightConstraint.constant = height
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension ChatVC: sendChatDelegate {
    func sendChatStatus(isSucceed: Bool) {
        self.messageInputAreaVC.waitingView.isHidden = true
        getMessages()
    }
}
