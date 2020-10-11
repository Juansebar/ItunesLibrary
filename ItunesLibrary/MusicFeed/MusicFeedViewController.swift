//
//  MusicFeedViewController.swift
//  ItunesLibrary
//
//  Created by Juan Ramirez on 10/8/20.
//  Copyright © 2020 Sebapps. All rights reserved.
//

import UIKit

class MusicFeedViewController: BaseTableViewController {
    
    private let viewModel: MusicFeedViewModelContract
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Find in Music"
        searchController.searchBar.tintColor = UIColor.systemRed
        searchController.searchBar.enablesReturnKeyAutomatically = true
        return searchController
    }()
    
    init(viewModel: MusicFeedViewModelContract) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Music"
        
        viewModel.setSongsDidChange {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    internal override func setupViews() {
        tableView.register(MusicFeedCell.self, forCellReuseIdentifier: MusicFeedCell.identifier)
    }
    
    private func updateTableView() {
        print("Reloading data")
    }
    
    var timer: Timer?

}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension MusicFeedViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = viewModel.songs[indexPath.row]
        let musicDetailViewController = MusicDetailViewController(viewModel: MusicDetailViewModel(song))
        navigationController?.pushViewController(musicDetailViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.songs.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MusicFeedCell.identifier, for: indexPath) as? MusicFeedCell else {
            return UITableViewCell()
        }

        cell.configure(with: viewModel.songs[indexPath.row])
        return cell
    }
    
    
    
}

// MARK: - UISearchBarDelegate

extension MusicFeedViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()  // Invalidates timer if text is changing quickly
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            // This will actually fire my search
            self.viewModel.fetchMusic(with: searchText)
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.dismiss(animated: true)
    }
    
}

