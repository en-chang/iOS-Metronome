//
//  PlaylistTableViewController.swift
//  Metronome
//
//  Created by Ian Chang on 11/11/19.
//  Copyright © 2019 Ian Chang. All rights reserved.
//

import UIKit
import CoreData

class PlaylistTableViewController: UITableViewController {
    
    var songs: [NSManagedObject] = []
    var playlistIndex:String!

    override func viewDidLoad() {
        super.viewDidLoad()
//        deleteAllRecords()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return songs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell", for: indexPath) as! SongTableViewCell

        // Configure the cell...
        let song = songs[indexPath.row]
        let url = URL(string: song.value(forKey: "image") as! String)
        let data = try? Data(contentsOf: url!)
        cell.albumImage.image = UIImage(data: data!)
        cell.songLabel.text = (song.value(forKeyPath: "song") as! String)
        cell.bpmLabel.text = ("Current BPM: \(song.value(forKeyPath: "currentBPM") as! String)       Song BPM: \(song.value(forKeyPath: "songBPM") as! String)")

        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let song = songs[indexPath.row]
            if editingStyle == .delete {
               managedContext.delete(song)
               do {
                   try managedContext.save()
               } catch let error as NSError {
                   print("Error While Deleting Note: \(error.userInfo)")
               }
            }
            songs.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedObjTemp = songs[fromIndexPath.item]
        songs.remove(at: fromIndexPath.item)
        songs.insert(movedObjTemp, at: to.item)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "metronome" {
            let index = sender as? Int
            let vc = segue.destination as! MetronomeViewController
            vc.playlistIndex = index!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "metronome", sender: indexPath.row)
    }
    
    @IBAction func unwindToPlaylist(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func editButton(_ sender: UIBarButtonItem) {
        self.tableView.isEditing = !self.tableView.isEditing
        sender.title = (self.tableView.isEditing) ? "Done" : "Edit"
    }
    
    private func deleteAllRecords() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext

        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Songs")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
}
