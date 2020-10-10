//
//  MusicFeedViewController.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/7/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import UIKit

class MusicFeedViewController: UIViewController {
    
    private var songs: [Song] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        WebProvider.fetchItunesMusic { (result) in
            switch result {
            case .success(let songs):
                self.songs = songs
                self.updateTableView()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    private func updateTableView() {
        print("Reloading data")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
