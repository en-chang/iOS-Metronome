//
//  MetronomeViewController.swift
//  Metronome
//
//  Created by Ian Chang on 11/11/19.
//  Copyright © 2019 Ian Chang. All rights reserved.
//

import UIKit
import CoreData
import AudioKit

class MetronomeViewController: UIViewController {
    
    var songs: [NSManagedObject] = []
    var playlistIndex = 0
    var songName = ""
    var artist = ""
    var currentBPM = ""
    var songBPM = ""
    var timeSig = ""
    var numBeats = ""
    var noteVal = ""
    var playButton = true
    let generator = AKOperationGenerator { parameters in
        let metronome = AKOperation.metronome(frequency: parameters[0] / 60)
        let count = metronome.count(maximum: parameters[1], looping: true)
        let beep = AKOperation.sineWave(frequency: 480 * (2 - (count / parameters[1] + 0.49).round()))
        let beeps = beep.triggeredWithEnvelope(
            trigger: metronome,
            attack: 0.01, hold: 0, release: 0.05)
        return beeps
    }
    
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var bpmSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try AudioKit.stop()
            self.albumImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        } catch {
            AKLog("AudioKit did not stop!")
        }
        DispatchQueue.main.async {
            let song = self.songs[self.playlistIndex]
            let url = URL(string: song.value(forKey: "image") as! String)
            let data = try? Data(contentsOf: url!)
            self.songName = (song.value(forKey: "song") as! String)
            self.artist = (song.value(forKey: "artist") as! String)
            self.currentBPM = song.value(forKey: "currentBPM") as! String
            self.songBPM = song.value(forKey: "songBPM") as! String
            self.timeSig = song.value(forKey: "timeSig") as! String
            let timeArray = self.timeSig.components(separatedBy: "/")
            self.numBeats = timeArray[0]
//            print(self.numBeats)
            self.noteVal = timeArray[1]
            self.songLabel.text = self.songName
            self.artistLabel.text = self.artist
            self.albumImage.image = UIImage(data: data!)
            self.bpmSlider.setValue(Float(self.currentBPM)!, animated: true)
            self.bpmLabel.text = "\(self.currentBPM)/\(self.songBPM) BPM"
            let updateButton = UIImage(named: "pause")
            self.playPauseButton.setImage(updateButton, for: .normal)
            
            self.generator.parameters = [Double(self.currentBPM)!, Double(self.numBeats)!]
            AudioKit.output = self.generator
            do {
                try AudioKit.start()
            } catch {
                AKLog("AudioKit did not start!")
            }
            self.generator.start()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Songs")
        do {
            songs = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func prevSong(_ sender: UIButton) {
        do {
            self.playButton = true
            let updateButton = UIImage(named: "pause")
            self.playPauseButton.setImage(updateButton, for: .normal)
            try AudioKit.stop()
        } catch {
            AKLog("AudioKit did not stop!")
        }
        if ((self.playlistIndex - 1) >= 0) {
            self.playlistIndex -= 1
        } else {
            self.playlistIndex = self.songs.count - 1
        }
        DispatchQueue.main.async {
            self.viewDidLoad()
        }
    }
    
    @IBAction func playPauseButton(_ sender: UIButton) {
        self.playButton = !playButton
        if self.playButton == true {
            self.generator.restart()
            let updateButton = UIImage(named: "pause")
            sender.setImage(updateButton, for: .normal)
            UIView.animate(withDuration: 1.0,
                delay: 0,
                usingSpringWithDamping: CGFloat(0.6),
                initialSpringVelocity: CGFloat(1.1),
                options: UIView.AnimationOptions.allowUserInteraction,
                animations: {
                    self.albumImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                },
                completion: { Void in()  }
            )
        } else {
            self.generator.stop()
            let updateButton = UIImage(named: "play")
            sender.setImage(updateButton, for: .normal)
            UIView.animate(withDuration: 0.75,
                delay: 0,
                usingSpringWithDamping: CGFloat(1.0),
                initialSpringVelocity: CGFloat(1.0),
                options: UIView.AnimationOptions.allowUserInteraction,
                animations: {
                    self.albumImage.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                },
                completion: { Void in()  }
            )
        }
    }
    
    @IBAction func nextSong(_ sender: UIButton) {
        do {
            self.playButton = true
            let updateButton = UIImage(named: "pause")
            self.playPauseButton.setImage(updateButton, for: .normal)
            try AudioKit.stop()
        } catch {
            AKLog("AudioKit did not stop!")
        }
        if ((self.playlistIndex + 1) < self.songs.count) {
            self.playlistIndex += 1
        } else {
            self.playlistIndex = 0
        }
        DispatchQueue.main.async {
            self.viewDidLoad()
        }
    }
    
    @IBAction func bpmSlider(_ sender: UISlider) {
        let newBPM = Int(sender.value)
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Songs", in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        let predicate = NSPredicate(format: "(song = %@)", songName)
        fetchRequest.predicate = predicate
        do {
            let results = try context.fetch(fetchRequest)
            let objectUpdate = results[0] as! NSManagedObject
            objectUpdate.setValue(String(newBPM), forKey: "currentBPM")
            do {
                try context.save()
            } catch {
                print("failed saving")
            }
        } catch {
            print("Error")
        }
        bpmLabel.text = "\(newBPM)/\(songBPM) BPM"
        self.generator.parameters[0] = Double(newBPM)
    }
}
