//
//  ViewController.swift
//  DemoApp
//
//  Created by Lefteris Mantas on 16/2/22.
//

import UIKit
import Network
import Combine

class HomeViewController: UIViewController,UICollectionViewDelegate{
    
        
    enum Section {
        case all
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, User>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, User>
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var syncBtn: UIButton!
    @IBOutlet weak var syncLabel: UILabel!
    
    @Published var networkStatus: Bool = false
    private var isSyncBtnEnabled: AnyCancellable?
    
    let manager = NetworkManager()
    let monitor = NWPathMonitor()
    var users = [User]()
    lazy var dataSource = makeDataSource()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNetworkMonitor(monitor: monitor)
        isSyncBtnEnabled = $networkStatus
                     .receive(on: DispatchQueue.main)
                     .assign(to: \.isEnabled, on: syncBtn)
        addObservers()
        syncBtn.addTarget(self, action: #selector(syncBtnTapped), for: .touchUpInside)
        collectionView.delegate = self
        setupMenu()
        title = "Users"
        self.applySnapshot()
//        collectionView.dataSource = self
//        getUsersOnline()
        getUsersOffline()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        monitor.cancel()
    }
    
    
//  MARK: Fetching data
    func getUsersOffline() {
        guard let cdUsers = CoreDataManager.sharedInstance.fetchUsers(),cdUsers.count>0 else{
            print("No fetched users")
            getUsersOnline()
            return
            
        }
        self.users = cdUsers
        self.applySnapshot()
    }
    
    
    func getUsersOnline(){
        manager.fetchUsers(parameter: "", httpMethod: .get){
            fetchedUsers , error in
            guard let _ = fetchedUsers else{
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .hasEndedSyncWithError, object: nil)
                }
                print("no users fetched")
                return
            }
            CoreDataManager.sharedInstance.saveContext()
            if let coreDataUsers = CoreDataManager.sharedInstance.fetchUsers(){
                self.users = coreDataUsers
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .hasEndedSync, object: nil)
                    self.applySnapshot()
//                    self.collectionView.reloadData()
                }
            }
        }
    }
    
//  MARK: Diffable DataSource implementation and collectionView population
    
    func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: {
                (collectionView, indexPath, user) -> UICollectionViewCell? in
                
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "UserCollectionViewCell",
                for: indexPath) as? UserCollectionViewCell
                
                cell?.name.text = user.name
                cell?.phone.text = "phone: \(user.phone ?? "")"
                cell?.website.text = "website: \(user.website ?? "")"
                cell?.email.text = "email: \(user.email ?? "")"
                
                return cell
        })
        return dataSource
    }
    
    func applySnapshot(animatingDifferences: Bool = false) {
        var snapshot = Snapshot()
        snapshot.appendSections([.all])
        snapshot.appendItems(users)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
//  MARK: Helpers
    
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(setUIForSyncing), name: .isSyncing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setUIForEndSync), name: .hasEndedSync, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hasEndedSyncWithError), name: .hasEndedSyncWithError, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(hasEndedSyncWithError), name: .networkStatusChanged, object: NWPath.Status.self)
        
    }
    
    @objc func setUIForSyncing(){
        syncLabel.text = "Syncing Data..."
        syncBtn.setImage(UIImage(systemName: "arrow.clockwise.icloud.fill"), for: .normal)
    }
    
    @objc func setUIForEndSync(){
        syncLabel.text = "Data synced successfully"
        syncBtn.setImage(UIImage(systemName: "checkmark.icloud.fill"), for: .normal)
    }
    
    @objc func hasEndedSyncWithError(){
        syncLabel.text = "There was an error syncing"
        syncBtn.setImage(UIImage(systemName: "xmark.icloud.fill"), for: .normal)
    }
    
    @objc func syncBtnTapped(){
        NotificationCenter.default.post(name: .isSyncing, object: nil)
        getUsersOnline()
    }
    
    
    func setupMenu(){
        var menuItems: [UIAction] {
            return [
                UIAction(title: "Alphabetical", image: UIImage(systemName: "character"), handler: { _ in
                    self.users.sort{
                        $0.name! < $1.name!
                    }
                    self.applySnapshot()
                })
            ]
        }

        var sortMenu: UIMenu {
            return UIMenu(title: "Sort by", image: nil, identifier: nil, options: [], children: menuItems)
        }

        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", image: nil, primaryAction: nil, menu: sortMenu)
    }
    
    func gotoTodos(ofUser: User){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let todosVC = storyboard.instantiateViewController(withIdentifier: "TodosViewController") as! TodosViewController
        todosVC.ofUser = ofUser
        self.navigationController?.pushViewController(todosVC, animated: true)
        
    }
    
    func setUpNetworkMonitor(monitor: NWPathMonitor){
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.networkStatus = true
//                    self.syncBtn.isEnabled = true
//                    self.syncBtn.layer.opacity = 1
                }
               
            } else {
                DispatchQueue.main.async {
                    self.networkStatus = false

//                    self.syncBtn.isEnabled = false
//                    self.syncBtn.layer.opacity = 0.5
                }
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
//  MARK: CollentionView delegate functions
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedItem = self.dataSource.itemIdentifier(for: indexPath){
            gotoTodos(ofUser: selectedItem)
        }
    }

}

