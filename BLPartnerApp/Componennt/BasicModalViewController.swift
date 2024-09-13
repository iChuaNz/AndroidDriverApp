//
//  BasicModalViewController.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 04/09/24.
//

import UIKit

class BasicModalViewController: BaseViewController {
    @IBOutlet weak var titleErrorLabel: UILabel!
    @IBOutlet weak var messageErrorLabel: UILabel!
    @IBOutlet weak var containerModalView: UIView!
    
    var errorTittle: String = ""
    var messageError: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissContent)))
        self.setupUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0.3, options: [.curveEaseOut], animations: {
            self.containerModalView.alpha = 1
        })
    }
    
    func setupUI() {
        titleErrorLabel.text = errorTittle
        messageErrorLabel.text = messageError
    }

}
