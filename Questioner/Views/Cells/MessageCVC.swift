//
//  MessageCVC.swift
//  Questioner
//
//  Created by negar on 97/Mordad/15 AP.
//  Copyright © 1397 negar. All rights reserved.
//

import UIKit

class MessageCVC: UICollectionViewCell {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!

    var message = Message()
    var type = typeEnum.none

    override func awakeFromNib() {
        self.layer.opacity = 1

        messageLbl.layer.cornerRadius = 10;
        messageLbl.clipsToBounds = true

        messageLbl.text = " " + message.message
        nameLbl.text = message.name
        timeLbl.text = message.time

        switch type {
        case .english:
            nameLbl.textColor = UIColor("#66320F99")
            timeLbl.textColor = UIColor("#AF371699")
        case .math:
            nameLbl.textColor = UIColor("#455D2099")
            timeLbl.textColor = UIColor("#95C45799")
        case .science:
            nameLbl.textColor = UIColor("#47184C99")
            timeLbl.textColor = UIColor("#66408A99")
        case .toefl:
            nameLbl.textColor = UIColor("#1C3E5C99")
            timeLbl.textColor = UIColor("#175D9999")
        default:
            break
        }
    }

}


class ImageMessageCVC : UICollectionViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var imageCell: UIImageView!

    var message = Message()
    var parentVC = ChatVC()

    var type = typeEnum.none

    @IBAction func loadData(_ sender: Any) {
        let imageVC = SegueHelper.createViewController(storyboardName: "Chat", viewControllerId: "imagePreview") as! ImageVC
        imageVC.image.image = imageCell.image
        SegueHelper.presentViewController(sourceViewController: parentVC, destinationViewController: imageVC)
    }
    func showImage() {
        let dataDecoded:Data = Data(base64Encoded: message.image, options: Data.Base64DecodingOptions(rawValue: 0))!
        if let decodedimage:UIImage = UIImage(data: dataDecoded) {
            print(decodedimage)
            imageCell.image = decodedimage
        }
    }

}

protocol ContactAndVoiceMessageCellProtocol: class {
    func cellDidTapedVoiceButton(_ cell: VoiceMessageCVC, isPlayingVoice: Bool, index: Int)
}

class VoiceMessageCVC: UICollectionViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var playVoiceButton: UIButton!
    weak var delegate: ContactAndVoiceMessageCellProtocol?
    weak var parentVeiwController: ChatVC?
    var message = Message()

    var indexpathraw = Int()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func playVoice(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let delegate = self.delegate else { return }
        delegate.cellDidTapedVoiceButton(self, isPlayingVoice: sender.isSelected, index: indexpathraw)
    }
}