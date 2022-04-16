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
    
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var elapsedTimeInSeconds = 0
    
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
    
    // MARK: - Timer
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            self.elapsedTimeInSeconds += 1
            self.updateTimeLabel()
        })
    }
    
    func pauseTimer() {
        timer?.invalidate()
    }
    
    func resetTimer() {
        timer?.invalidate()
        elapsedTimeInSeconds = 0
        updateTimeLabel()
    }
    
    func updateTimeLabel() {
        let seconds = elapsedTimeInSeconds % 60
        let minutes = (elapsedTimeInSeconds / 60) % 60
        
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Action methods
    
    @IBAction func stop(sender: UIButton) {
        recordButton.setImage(UIImage(named: "Record"), for: .normal)
        recordButton.isEnabled = true
        stopButton.isEnabled = false
        playButton.isEnabled = true
        
        // Stop the audio recorder
        audioRecorder?.stop()
        resetTimer()
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setActive(false)
        } catch {
            print(error)
        }
    }

    @IBAction func play(sender: UIButton) {
        if audioRecorder.isRecording { return }
        
        guard let player = try? AVAudioPlayer(contentsOf: audioRecorder.url) else {
            print("Failed to initialize AVAudioPlayer")
            return
        }
        
        audioPlayer = player
        audioPlayer?.delegate = self
        audioPlayer?.play()
        startTimer()
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
                startTimer()
                
                // change the pause image
                recordButton.setImage(UIImage(named: "Pause"), for: .normal)
            } catch {
                print(error)
            }
        } else {
            // Pause recording
            audioRecorder.pause()
            pauseTimer()
            
            // Change to the Record image
            recordButton.setImage(UIImage(named: "Record"), for: .normal)
        }
        
        stopButton.isEnabled = true
        playButton.isEnabled = false
    }

}

extension RecordProController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag { return }
        
        let alertController = UIAlertController(title: "Finish Recording", message: "Successfully recorded the audio!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alertController, animated: true)
    }
}

extension RecordProController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.isSelected = false
        resetTimer()
        
        let alertController = UIAlertController(title: "Finish Playing", message: "Finish playing the recording!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
