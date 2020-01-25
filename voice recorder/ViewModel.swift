//
//  ViewModel.swift
//  voice recorder
//
//  Created by Максим Храбрый on 23.01.2020.
//  Copyright © 2020 Xaker. All rights reserved.
//

import UIKit
import AVFoundation

var number = FileManager.default.urls(for: .documentDirectory)?.count ?? 0
var name = "recording\(number).m4a"

class ViewModel: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    var audioRecorder: AVAudioRecorder!
    var audioSession: AVAudioSession!
    var audioPlayer: AVAudioPlayer!

    func getFileUrl() -> URL {
        let filename = name
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(name)

        audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord,
                                         mode: .spokenAudio,
                                         options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("error.")
        }
        
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 12000,
                        AVNumberOfChannelsKey: 1,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder,
                                         successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        number += 1
        name = "recording\(number).m4a"
        
        NotificationCenter.default.post(name: .init("AddSound"), object: nil)
        print(FileManager.default.urls(for: .documentDirectory) ?? "none", success)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func preparePlay() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileUrl())
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1
        }
        catch {
            print("Error")
        }
    }
}
