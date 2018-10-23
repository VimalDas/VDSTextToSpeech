# VDSTextToSpeech

To use VDSTextToSpeech, follow the simple steps

1. drag VDSTextToSpeech to your project.

2. create a variable for easy access to VDSTextToSpeech

        let vds = VDSTextToSpeech.shared

3. give the message to be read.
        
        vds.text = "welcome to VDS Text to speech module. Hope you enjoy"
        
4. speak() : to make VDSTextToSpeech read the message

   stopSpeech() : to stop reading
   
   pauseSpeech() : to pause reading (to resume call speak() again)
        
8. to get callbacks and progress, add VDSTextToSpeech delegate to class
          eg: 

        class ViewController: UIViewController,VDSSpeechSynthesizerDelegate {
    
        vds.speechSynthesizerDelegate = self
        
        
        //MARK:- VDSSpeechSynthesizerDelegate
        func speechSynthesizerProgress(_ progress: Float, attributedText: NSMutableAttributedString) {
            messageLabel.attributedText = attributedText
            progressView.progress = progress
        }

        func speechSynthesizerDidStart() {
            print("speechSynthesizerDidStart")
        }

        func speechSynthesizerDidFinish() {
            print("speechSynthesizerDidFinish")
        }
        
        
    <a href="https://imgflip.com/gif/2kqm4r"><img src="https://i.imgflip.com/2kqm4r.gif" title="made at imgflip.com"/></a>
