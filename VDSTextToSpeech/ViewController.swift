//
//  ViewController.swift
//  VDSTextToSpeech
//
//  Created by Vimal Das on 22/10/18.
//  Copyright © 2018 Vimal Das. All rights reserved.
//

import UIKit

class ViewController: UIViewController,VDSSpeechSynthesizerDelegate {
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var progressView: UIProgressView! {
        didSet{
            progressView.progressTintColor = UIColor.orange
            progressView.progress = 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        message.text = "YEs you're right but when we pass a String to a function, then that receiving parameter will become immutable. var string: String"
        
        let vds = VDSTextToSpeech.shared
        vds.speechSynthesizerDelegate = self
        
        vds.text = message.text ?? "no text found."
        
        vds.speak()
    }
    
    //MARK:- VDSSpeechSynthesizerDelegate
    func speechSynthesizerProgress(_ progress: Float, attributedText: NSMutableAttributedString) {
        message.attributedText = attributedText
        progressView.progress = progress
    }
    
    func speechSynthesizerDidStart() {
        print("speechSynthesizerDidStart")
    }
    
    func speechSynthesizerDidFinish() {
        print("speechSynthesizerDidFinish")
    }
    
    
}

