//
//  MessageInputAreaViewController.swift
//  negar
//
//  Created by Negar on 8/7/18.
//  Copyright © 2018 negar. All rights reserved.
//

import MobileCoreServices
import TGCameraViewController

protocol MessageInputAreaViewControllerDelegate: class {
    func adjustInputAreaHeightConstraint(height: CGFloat)
    func sendChat(message: String?, image: UIImage?, filePath: URL?, type: Int)
}

class MessageInputAreaViewController: UIViewController {
    weak var messageVC: ChatVC?
    weak var delegate: MessageInputAreaViewControllerDelegate?

    var conversationID: String
    var recordingViewController: VoiceRecorderViewController?
    var isRecording = false
    var conversationIsEnd: Bool!
    var type: typeEnum
    
    @IBOutlet var textView: UITextView!
    @IBOutlet weak var sendButtonBackground: UIView!
    @IBOutlet weak var textViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var recordingView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var waitingView: UIView!
    @IBOutlet weak var waitingViewIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageButton: UIButton!

    init(conversationID: String, conversationIsEnded: Bool, type: typeEnum) {
        self.conversationID = conversationID
        self.conversationIsEnd = conversationIsEnded
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.waitingView.isHidden = true

        self.view.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.2)
        
        textView.layer.borderColor = UIColor.darkGray.cgColor
        textView.layer.borderWidth = 1
        textView.textContainerInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(sendMessage(_:)))
        let longgesture = UILongPressGestureRecognizer(target: self, action: #selector(startRecording(_:)))
        
        longgesture.delegate = self
        sendButton.addGestureRecognizer(tapgesture)
        sendButton.addGestureRecognizer(longgesture)

        if !conversationIsEnd {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }

        self.sendButton.setImage(UIImage(named:"\(type.toString)BtnVoice"), for: .normal)
        self.sendButton.setImage(UIImage(named:"\(type.toString)BtnVoicePressed"), for: .highlighted)

        self.imageButton.setImage(UIImage(named:"\(type.toString)BtnImg"), for: .normal)
        self.imageButton.setImage(UIImage(named:"\(type.toString)BtnImgPressed"), for: .highlighted)

    }
    
    @IBAction func showAttachOptions() {
        chooseImage()
    }
    
    @objc func sendMessage(_ sender: UIGestureRecognizer) {
        if Connectivity.isConnectedToInternet(){
            if !conversationIsEnd {
                if !isRecording, recordingViewController != nil {
                    recordingViewController!.saveAudio()
                    isRecording = false
                    return
                } else if isRecording, recordingViewController != nil {
                    self.stopRecording()
                    return
                } else if textView.text.isEmpty { return }

                let message = Message()
                message.message = textView.text.trimmingCharacters(in: CharacterSet.whitespaces)
                if message.message.count > 1000 {
                    return
                }

                textView.text = ""
                textViewDidChange(textView)
                delegate?.sendChat(message: message.message, image: nil, filePath: nil, type: 0)
            } else {
                ViewHelper.showToastMessage(message: "The Conversation Is Ended")
            }
        }else{
            let alert = UIAlertController(title: "Connection", message: "Please make sure that your phone is connected to internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok!", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension MessageInputAreaViewController: TGCameraDelegate, UINavigationControllerDelegate {
    func chooseImage() {
        let cameraController = TGCameraNavigationController.new(with: self)!
        cameraController.delegate = self
        TGCamera.setOption("kTGCameraOptionUseOriginalAspect", value: 1)
        present(cameraController, animated: true) {}
    }
    
    func cameraDidCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func cameraDidSelectAlbumPhoto(_ image: UIImage!) {
        
        dismiss(animated: true, completion: {
            self.sendPhoto(image: image)
        })
    }
    
    func cameraDidTakePhoto(_ image: UIImage!) {
        
        dismiss(animated: true, completion: {
            self.sendPhoto(image: image)
        })
    }
}

extension MessageInputAreaViewController {
    fileprivate func sendPhoto(image: UIImage) {

        delegate?.sendChat(message: nil, image: image, filePath: nil, type: 1)
        self.waitingView.isHidden = false
    }
    
    fileprivate func sendVoice(voicePath: URL) {
        delegate?.sendChat(message: nil, image: nil, filePath: voicePath, type: 2)
        self.waitingView.isHidden = false
    }
}

extension MessageInputAreaViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count == 0 { delegate?.adjustInputAreaHeightConstraint(height: 100)
            self.changeConstraintOfTextView(shouldGrow: false); return }
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if newSize.height > 100 {
            textView.isScrollEnabled = true
        } else {
            delegate?.adjustInputAreaHeightConstraint(height: max(100, newSize.height + 12))
            textView.isScrollEnabled = false
        }
        if textView.text.count > 0 {
            changeConstraintOfTextView(shouldGrow: true)
        }
    }
    
    func changeConstraintOfTextView(shouldGrow: Bool) {
        textViewLeftConstraint.constant = shouldGrow ? 6 : 62
        self.changeBackgroundAnPictureOfTheSendButton(backGroundColor: shouldGrow ? .clear : .white, pictureName: shouldGrow ? "BtnSend" : "BtnVoice")
    }
}

extension MessageInputAreaViewController: UIGestureRecognizerDelegate, AudioRecorderViewControllerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) { startRecording(gestureRecognizer) }; return true
    }
    
    func audioRecorderViewControllerDismissed(withFileURL fileURL: URL?) {
        if let url = fileURL {
            sendVoice(voicePath: url)
        } else {
            
        }
        if recordingViewController != nil {
            recordingViewController!.cleanup()
            recordingViewController = nil
            self.changeBackgroundAnPictureOfTheSendButton(backGroundColor: .white, pictureName: "BtnVoice")
            recordingView.alpha = 0
        }
    }
    
    func stopRecording() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.sendButtonBackground.transform = .init(scaleX: 1, y: 1)
        }, completion: { _ in
            if self.recordingViewController != nil && self.recordingViewController?.duration.text != "" {
                self.changeBackgroundAnPictureOfTheSendButton(backGroundColor: .clear, pictureName: "BtnSend")
                self.recordingViewController!.stopRecording()
                self.isRecording = false
            } else {
                self.audioRecorderViewControllerDismissed(withFileURL: nil)
                self.isRecording = false
            }
        })
    }
    
    func changeBackgroundAnPictureOfTheSendButton(backGroundColor: UIColor, pictureName: String) {

        let imgName = "\(type.toString)" + pictureName
        let pressedImgName = "\(type.toString)" + pictureName + "Pressed"

        self.sendButton.setImage(UIImage(named:imgName), for: .normal)
        self.sendButton.setImage(UIImage(named:pressedImgName), for: .highlighted)

        //backgroundColor change by type
        switch type {
        case .english:
            self.sendButtonBackground.backgroundColor = UIColor("#f1dda499")
        case .math:
            self.sendButtonBackground.backgroundColor = UIColor("#c2de9c99")
        case .science:
            self.sendButtonBackground.backgroundColor = UIColor("#c5c9f399")
        case .toefl:
            self.sendButtonBackground.backgroundColor = UIColor("#a7cdee99")
        default:
            break
        }
    }
    
    @objc func startRecording(_ sender: UIGestureRecognizer) {
        if sender.state == .possible {
            if textView.text.isEmpty {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                    self.sendButtonBackground.transform = .init(scaleX: 2, y: 2)
                }, completion: { finished in
                    if finished {
                        self.recordingViewController = VoiceRecorderViewController(size: self.recordingView.frame.width)
                        self.recordingViewController!.audioRecorderDelegate = self
                        self.addChild(self.recordingViewController!)
                        self.view.addSubview(self.recordingViewController!.view)
                        self.recordingViewController!.didMove(toParent: self)
                        self.recordingView.addSubview(self.recordingViewController!.view)
                        self.recordingView.alpha = 1
                        self.isRecording = true
                    }
                })
            }
        } else if sender.state == UIGestureRecognizer.State.ended && isRecording {
            stopRecording()
        }
    }
    
    func timerFinishedCounting() {
        stopRecording()
    }
}

