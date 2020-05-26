//
//  AddSongViewController.swift
//  Metronome
//
//  Created by Ian Chang on 11/11/19.
//  Copyright © 2019 Ian Chang. All rights reserved.
//

import UIKit
import CoreData

class AddSongViewController: UIViewController {
    
    var songs: [NSManagedObject] = []
    let index = 0
    
    @IBOutlet weak var songTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var addSongButton: UIButton!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bpmTextField: UITextField!
    
    var songData = [SearchData]() {
        didSet {
            DispatchQueue.main.async {
                /*
                let url = URL(string: self.weatherData[self.index].weatherIconUrl[self.index].value)
                let data = try? Data(contentsOf: url!)
                self.iconImage.image = UIImage(data: data!)
                self.tempLabel.text = "\(self.weatherData[self.index].temp_C)°C/\(self.weatherData[self.index].temp_F)°F"
                self.cloudLabel.text = "Cloud Cover: \(self.weatherData[self.index].cloudcover)%"
                self.humidityLabel.text = "Humidity: \(self.weatherData[self.index].humidity)%"
                self.pressureLabel.text = "Pressure: \(self.weatherData[self.index].pressure)mbar"
                self.precipitationLabel.text = "Precipitation: \(self.weatherData[self.index].precipMM)mm"
                self.windLabel.text = "Wind: \(self.weatherData[self.index].windspeedKmph)kmph/\(self.weatherData[self.index].windspeedMiles)mph \(self.weatherData[self.index].winddir16Point) (\(self.weatherData[self.index].winddirDegree))"
                self.errorLabel.text = ""
                */
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
        selector: #selector(noSong),
        name: NSNotification.Name(rawValue: "error"),
        object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func noSong(notification: NSNotification) {
//        print("Received Notification")
        DispatchQueue.main.async {
            self.addSongButton.isEnabled = true
            self.resultsLabel.text = "Sorry we couldn't find that song!"
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
    
    @IBAction func addSongButton(_ sender: UIButton) {
        sender.isEnabled = false
        var song = songTextField.text!
        song = song.replacingOccurrences(of: " ", with: "+")
        
        var artist = artistTextField.text!
        artist = artist.replacingOccurrences(of: " ", with: "+")
        
        let search = "song:\(song)%20artist:\(artist)"
        
        let searchRequest = SearchRequest(search: search)
            searchRequest.getData { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                self?.songData = data
                DispatchQueue.main.async {
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let entity = NSEntityDescription.entity(forEntityName: "Songs", in: context)
                    let newSong = NSManagedObject(entity: entity!, insertInto: context)
                    newSong.setValue(self?.songData[self!.index].song_title, forKey: "song")
                    newSong.setValue(self?.songData[self!.index].artist.name, forKey: "artist")
                    newSong.setValue(self?.songData[self!.index].album.img, forKey: "image")
                    newSong.setValue(self?.songData[self!.index].tempo, forKey: "currentBPM")
                    newSong.setValue(self?.songData[self!.index].tempo, forKey: "songBPM")
                    newSong.setValue(self?.songData[self!.index].time_sig, forKey: "timeSig")
                    do {
                        try context.save()
                        self?.resultsLabel.text = ""
//                        print("saved")
                    } catch {
                        print("failed saving")
                    }
                }
//                print("Song: \(self!.songData[self!.index].song_title)")
//                print("Artist: \(self!.songData[self!.index].artist.name)")
//                print("BPM: \(self!.songData[self!.index].tempo)")
//                print("Time Signature: \(self!.songData[self!.index].time_sig)")
                DispatchQueue.main.async {
                    self!.performSegue(withIdentifier: "playlist", sender: self)
                }
            }
        }
    }
    
    @IBAction func addSessionButton(_ sender: UIButton) {
        sender.isEnabled = false
        let session = titleTextField.text!
        let bpm = bpmTextField.text!
        DispatchQueue.main.async {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Songs", in: context)
            let newSession = NSManagedObject(entity: entity!, insertInto: context)
            newSession.setValue(session, forKey: "song")
            newSession.setValue("", forKey: "artist")
            newSession.setValue("https://cdn.shopify.com/s/files/1/0757/9731/products/Cufflink_-_Notes_B_W_300x300.jpg?v=1542920210", forKey: "image")
            newSession.setValue(bpm, forKey: "currentBPM")
            newSession.setValue(bpm, forKey: "songBPM")
            newSession.setValue("4/4", forKey: "timeSig")
            do {
                try context.save()
//                print("saved")
            } catch {
                print("failed saving")
            }
        }
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "playlist", sender: self)
        }
    }
}
