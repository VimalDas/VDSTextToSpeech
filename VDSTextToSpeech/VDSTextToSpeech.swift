//
//  VDSTextToSpeech.swift
//  VDSTextToSpeech
//
//  Created by Vimal Das on 22/10/18.
//  Copyright © 2018 Vimal Das. All rights reserved.
//

import UIKit
import Speech

protocol VDSSpeechSynthesizerDelegate: class {
    func speechSynthesizerDidStart()
    func speechSynthesizerDidFinish()
    func speechSynthesizerProgress(_ progress:Float, attributedText:NSMutableAttributedString)
}
class VDSTextToSpeech: NSObject, AVSpeechSynthesizerDelegate {
    
    static let shared = VDSTextToSpeech()
    
    weak var speechSynthesizerDelegate:VDSSpeechSynthesizerDelegate?
    
    var fontColor:UIColor = UIColor.orange
    
    //MARK:- Speech Synthesizer Variables
    private var speechSynthesizer: AVSpeechSynthesizer!
    var rate: Float = 0.0
    var pitch: Float = 0.0
    var volume: Float = 0.0
    var totalUtterances: Int! = 0
    var currentUtterance: Int! = 0
    var totalTextLength: Int = 0
    var spokenTextLengths: Int = 0
    var preferredVoiceLanguageCode: String!
    private var previousSelectedRange: NSRange!
    var text:String = "" {
        didSet{
            attributedText = NSMutableAttributedString(string: text)
        }
    }
    private var attributedText:NSMutableAttributedString = NSMutableAttributedString(string: "")
    
    //MARK:- Main Funcs
    private override init() {
        super.init()
        
        speechSynthesizer = AVSpeechSynthesizer()
        
        setupTextToSpeech()
     
    }
    
   
    // MARK:- AVSpeechSynthesizer
    private func setupTextToSpeech() {
        
        if !loadSettings() {
            registerDefaultSettings()
        }
        
        speechSynthesizer.delegate = self
        
        setInitialFontAttribute()
    }
    
    private func registerDefaultSettings() {
        rate = AVSpeechUtteranceDefaultSpeechRate
        pitch = 1.0
        volume = 1.0
        
        let defaultSpeechSettings = ["rate": rate, "pitch": pitch, "volume": volume]
        
        UserDefaults.standard.register(defaults: defaultSpeechSettings)
    }
    
    
    private func loadSettings() -> Bool {
        let userDefaults = UserDefaults.standard as UserDefaults
        
        if let theRate: Float = userDefaults.value(forKey: "rate") as? Float {
            rate = theRate
            pitch = userDefaults.value(forKey:"pitch") as! Float
            volume = userDefaults.value(forKey:"volume") as! Float
            
            return true
        }
        
        return false
    }
    
    func setInitialFontAttribute() {
        let rangeOfWholeText = NSMakeRange(0, text.utf16.count)
        attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(.font, value: UIFont(name: "Arial", size: 18.0)!, range: rangeOfWholeText)
    }

    private func unselectLastWord() {
        if let selectedRange = previousSelectedRange {
            
            let currentAttributes = attributedText.attributes(at: selectedRange.location, effectiveRange: nil)
            
            let fontAttribute = currentAttributes[NSAttributedString.Key.font] ?? UIFont.boldSystemFont(ofSize: 17)
            
            
            let attributedWord = NSMutableAttributedString(string: attributedText.attributedSubstring(from: selectedRange).string)
            
            
            attributedWord.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, attributedWord.length))
            attributedWord.addAttribute(.font, value: fontAttribute, range: NSMakeRange(0, attributedWord.length))
            
            // Update the text storage property and replace the last selected word with the new attributed string.
            
            attributedText.replaceCharacters(in: selectedRange, with: attributedWord)
            
        }
    }
    
    
    func speak() {
        if !speechSynthesizer.isSpeaking {
            /**
             let speechUtterance = AVSpeechUtterance(string: tvEditor.text)
             speechUtterance.rate = rate
             speechUtterance.pitchMultiplier = pitch
             speechUtterance.volume = volume
             speechSynthesizer.speakUtterance(speechUtterance)
             */
            
            let textParagraphs = text.components(separatedBy: "\n")
            
            totalUtterances = textParagraphs.count
            currentUtterance = 0
            totalTextLength = 0
            spokenTextLengths = 0
            
            for pieceOfText in textParagraphs {
                let speechUtterance = AVSpeechUtterance(string: pieceOfText)
                speechUtterance.rate = rate
                speechUtterance.pitchMultiplier = pitch
                speechUtterance.volume = volume
                speechUtterance.postUtteranceDelay = 0.005
                
                if let voiceLanguageCode = preferredVoiceLanguageCode {
                    let voice = AVSpeechSynthesisVoice(language: voiceLanguageCode)
                    speechUtterance.voice = voice
                }
                
                totalTextLength = totalTextLength + pieceOfText.utf16.count
                
                speechSynthesizer.speak(speechUtterance)
            }
            
            
        }
        else{
            speechSynthesizer.continueSpeaking()
        }
        
    }
    
    
    func pauseSpeech() {
        speechSynthesizer.pauseSpeaking(at: AVSpeechBoundary.word)
    }
    
    
    func stopSpeech() {
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
    }
    
    
    
    // MARK: AVSpeechSynthesizerDelegate method implementation
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        spokenTextLengths = spokenTextLengths + utterance.speechString.utf16.count + 1
        
        let progress: Float = Float(spokenTextLengths * 100 / totalTextLength)
        speechSynthesizerDelegate?.speechSynthesizerProgress(progress/100, attributedText: attributedText)
        
        if currentUtterance == totalUtterances {
            unselectLastWord()
            previousSelectedRange = nil
        }
        speechSynthesizerDelegate?.speechSynthesizerDidFinish()
    }
    
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        currentUtterance = currentUtterance + 1
        speechSynthesizerDelegate?.speechSynthesizerDidStart()
    }
    
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let progress: Float = Float(spokenTextLengths + characterRange.location) * 100 / Float(totalTextLength)
        speechSynthesizerDelegate?.speechSynthesizerProgress(progress/100, attributedText: attributedText)
        
        // Determine the current range in the whole text (all utterances), not just the current one.
        let rangeInTotalText = NSMakeRange(spokenTextLengths + characterRange.location, characterRange.length)
        
        // Select the specified range in the textfield.
        
        // Store temporarily the current font attribute of the selected text.
        let currentAttributes = attributedText.attributes(at: rangeInTotalText.location, effectiveRange: nil)
        let fontAttribute = currentAttributes[NSAttributedString.Key.font] ?? UIFont.boldSystemFont(ofSize: 17)
        
        // Assign the selected text to a mutable attributed string.
        let attributedString = NSMutableAttributedString(string: attributedText.attributedSubstring(from: rangeInTotalText).string)
        
        // Make the text of the selected area orange by specifying a new attribute.
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: fontColor, range: NSMakeRange(0, attributedString.length))
        
        // Make sure that the text will keep the original font by setting it as an attribute.
        attributedString.addAttribute(NSAttributedString.Key.font, value: fontAttribute, range: NSMakeRange(0, attributedString.string.utf16.count))
        
        attributedText.replaceCharacters(in: rangeInTotalText, with: attributedString)
        
        // If there was another highlighted word previously (orange text color), then do exactly the same things as above and change the foreground color to black.
        if let previousRange = previousSelectedRange {
            let previousAttributedText = NSMutableAttributedString(string: attributedText.attributedSubstring(from: previousRange).string)
            previousAttributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, previousAttributedText.length))
            previousAttributedText.addAttribute(NSAttributedString.Key.font, value: fontAttribute, range: NSMakeRange(0, previousAttributedText.length))
            
            attributedText.replaceCharacters(in: previousRange, with: previousAttributedText)
        }
        
        // Keep the currently selected range so as to remove the orange text color next.
        previousSelectedRange = rangeInTotalText
    }
}
