//
//  ViewController.swift
//  voice recorder
//
//  Created by Максим Храбрый on 19.01.2020.
//  Copyright © 2020 Xaker. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

let buttonSize: CGFloat = 50
let viewSize: CGFloat = 60

class ViewController: UIViewController {
    var viewModel: ViewModel!
    
    var recordView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = viewSize/2
        return view
    }()
    
    let recordButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: 0xff3b30)
        button.layer.cornerRadius = buttonSize/2
        button.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        button.increaseTouchArea(radius: 100)
        return button
    }()
    
    let recordContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0x1c1c1e)
        return view
    }()
    
    let soundList: UITableView = {
        let table = UITableView()
        return table
    }()
    
    let gesture = UITapGestureRecognizer(target: self, action: #selector(playSound))
    var fileNames = [String]()
    let searchController = UISearchController(searchResultsController: nil)
    let label = UILabel(frame: .zero)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = ViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "fuck off"
        
        soundList.delegate = self
        soundList.dataSource = self
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "что найти?"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            soundList.tableHeaderView = searchController.searchBar
        }
        
        view.addSubview(soundList)
        view.addSubview(recordContainer)
//        view.addGestureRecognizer(gesture)
        recordContainer.addSubview(recordView)
        recordView.addSubview(recordButton)
        
        recordContainer.addGestureRecognizer(gesture)
        
        soundList.tableFooterView = label
        
        viewModel.audioSession = AVAudioSession.sharedInstance()
        do {
            try viewModel.audioSession.setCategory(.playAndRecord, mode: .default)
            try viewModel.audioSession.setActive(true)
            viewModel.audioSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        print("FuckOff")
                    }
                }
            }
        } catch {
            print(error)
        }
        
        fillingNames()
        
        NotificationCenter.default.addObserver(forName: .init("AddSound"), object: nil, queue: nil) { [weak self] notification in
            self?.fileNames.removeAll()
            self?.fillingNames()
            self?.soundList.reloadData()
        }
        
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let maskPath = UIBezierPath(roundedRect: recordContainer.bounds, byRoundingCorners: [.topRight, .topLeft], cornerRadii: CGSize(width: 10, height: 10))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        recordContainer.layer.mask = shape
    }

    func loadRecordingUI() {
        SetupRecordButton()
    }
    
    @objc func recordTapped() {
        if viewModel.audioRecorder == nil {
            viewModel.startRecording()
            UIView.animate(withDuration: 0.1) {
                self.recordButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.recordButton.layer.cornerRadius = 8
            }
        } else {
            viewModel.finishRecording(success: true)
            UIView.animate(withDuration: 0.1) {
                self.recordButton.transform = .identity
                self.recordButton.layer.cornerRadius = buttonSize/2
            }
        }
    }
    
    func fillingNames() {
        for filePath in FileManager.default.urls(for: .documentDirectory) ?? [] {
            guard let fileName = filePath.path.components(separatedBy: "/").last else { return }
            fileNames.append(fileName)
        }
    }
    
    @objc func playSound() {
        
        print(FileManager.default.fileExists(atPath: viewModel.getFileUrl().path))
        if FileManager.default.fileExists(atPath: viewModel.getFileUrl().path) {
            viewModel.preparePlay()
            viewModel.audioPlayer.play()
            viewModel.audioPlayer.volume = 1
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FileManager.default.urls(for: .documentDirectory)?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = fileNames[indexPath.row]
        return cell
    }
    
}

extension ViewController {
    func SetupRecordButton() {
        recordButton.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(buttonSize)
        }
        recordView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            } else {
                make.bottom.equalToSuperview().offset(-20)
            }
            make.centerX.equalToSuperview()
            make.height.width.equalTo(viewSize)
        }
    }
    
    func setupConstraints() {
        soundList.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            if #available(iOS 11, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalToSuperview()
            }
            make.bottom.equalTo(recordContainer.snp.top)
        }
        recordContainer.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(20 + viewSize + 20)
        }
    }
}

extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
//        filterContentForSearchController(searchController.searchBar.text!)
    }
    
//    func filterContentForSearchController(_ searchText: String) {
//        var filters = [String]()
//        var idxs = [Int]()
//        for (i, elem) in FileManager.default.urls(for: .documentDirectory)!.enumerated() {
//            let name = elem.path.components(separatedBy: "/").last
//            if (name?.lowercased().contains(searchText.lowercased()) ?? false) {
//                filters.append(name!)
//                idxs.append(i)
//            }
//        }
//        filteredRecipes["ds"] = filters
//        filteredRecipes["idx"] = idxs
//        soundList.reloadData()
//    }
}
