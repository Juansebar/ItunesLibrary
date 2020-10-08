//
//  MusicFeedViewController.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/7/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import UIKit

class MusicFeedViewController: UIViewController {
    
    private let viewModel: MusicFeedViewModelContract
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    
    init(viewModel: MusicFeedViewModelContract) {
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.setSongsDidChange {
            self.tableView.reloadData()
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

extension MusicFeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("indexPath: \(indexPath.row)")
    }
    
}

extension MusicFeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MusicFeedCell.identifier, for: <#T##IndexPath#>)
    }
    
}
