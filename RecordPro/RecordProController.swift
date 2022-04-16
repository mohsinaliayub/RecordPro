//
//  RecordProController.swift
//  RecordPro
//
//
//  Created by Mohsin Ali Ayub on 15.04.22.
//  Copyright © 2022 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation

class RecordProController: UIViewController {

    @IBOutlet private var stopButton: UIButton!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var recordButton: UIButton!
    @IBOutlet private var timeLabel: UILabel!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    // Configure the recording preparation
    private func configure() {
        // Disable Stop/Play button when application launches
        stopButton.isEnabled = false
        playButton.isEnabled = false
        
        // Get the document directory
        guard let directoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            let alertMessage = UIAlertController(title: "Error", message: "Failed to get the document for recording the audio. Please try again later.", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(alertMessage, animated: true)
            return
        }
        
        // 1. Set the default audio file
        let audioFileUrl = directoryUrl.appendingPathComponent("MyAudioMemo.m4a")
        
        // 2. Set up audio session
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            
            // 3. Define the recorder setting
            let recorderSetting: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            // 4. Initiate and prepare the recorder
            audioRecorder = try AVAudioRecorder(url: audioFileUrl, settings: recorderSetting)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
        } catch {
            print(error)
        }
    }
    

    // MARK: - Action methods
    
    @IBAction func stop(sender: UIButton) {
        recordButton.setImage(UIImage(named: "Record"), for: .normal)
        recordButton.isEnabled = true
        stopButton.isEnabled = false
        playButton.isEnabled = true
        
        // Stop the audio recorder
        audioRecorder?.stop()
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setActive(false)
        } catch {
            print(error)
        }
    }

    @IBAction func play(sender: UIButton) {
        
    }

    @IBAction func record(sender: UIButton) {
        // Stop the audio player before recording
        if let player = audioPlayer, player.isPlaying {
            player.stop()
        }
        
        if !audioRecorder.isRecording {
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setActive(true)
                
                // Start recording
                audioRecorder.record()
                
                // change the pause image
                recordButton.setImage(UIImage(named: "Pause"), for: .normal)
            } catch {
                print(error)
            }
        } else {
            // Pause recording
            audioRecorder.pause()
            
            // Change to the Record image
            recordButton.setImage(UIImage(named: "Record"), for: .normal)
        }
        
        stopButton.isEnabled = true
        playButton.isEnabled = false
    }

}

extension RecordProController: AVAudioRecorderDelegate {
    
}
