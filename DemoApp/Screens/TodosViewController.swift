//
//  TodosViewController.swift
//  DemoApp
//
//  Created by Lefteris Mantas on 20/2/22.
//

import UIKit
import Network
import Combine

class TodosViewController: UIViewController,UICollectionViewDelegate {
    
    enum Section {
        case all
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Todo>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Todo>
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var syncBtn: UIButton!
    @IBOutlet weak var syncLabel: UILabel!
    
    var ofUser: User!
    
    let manager = NetworkManager()
    let monitor = NWPathMonitor()
    var todos = [Todo]()
    lazy var dataSource = makeDataSource()
    
    @Published var networkStatus: Bool = false
    private var isSyncBtnEnabled: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNetworkMonitor(monitor: monitor)
        var config = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            
            let delete = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
                self?.delete(at: indexPath)
                completion(true)
            }
            let swipe = UISwipeActionsConfiguration(actions: [delete])
            return swipe
        }
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: config)
        collectionView.delegate = self
        syncBtn.addTarget(self, action: #selector(syncBtnTapped), for: .touchUpInside)
        addObservers()
        setupMenu()
        
        self.title = "Tasks of \(ofUser.name ?? "some user")"
        self.applySnapshot()
//        getTodosOnline(ofUser: ofUser.id)
        getTodosOffline(ofUser: ofUser.id)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        monitor.cancel()
    }
    
    
//  MARK: Diffable DataSource implementation and collectionView population

    func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: {
                (collectionView, indexPath, todo) -> UICollectionViewCell? in
                
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "TodoCollectionViewCell",
                for: indexPath) as? TodoCollectionViewCell
                
//                cell?.title.text = todo.title
                
                var config = UIListContentConfiguration.cell()

                config.text = todo.title
                cell?.contentConfiguration = config
                
                cell?.accessories = [.checkmark(displayed: .always, options: .init(isHidden: !todo.completed, reservedLayoutWidth: .standard, tintColor: .blue))]
                
                
                return cell
        })
        return dataSource
    }
    
    func applySnapshot(animatingDifferences: Bool = false) {
        var snapshot = Snapshot()
        snapshot.appendSections([.all])
        snapshot.appendItems(todos)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
//  This also deletes from coreData, if there is time make it a separate function
    func delete(at ip: IndexPath) {
        let managedContext = CoreDataManager.sharedInstance.managedContext
        var snapshot = self.dataSource.snapshot()
        if let id = self.dataSource.itemIdentifier(for: ip) {
//          show the change immidiatelly
            snapshot.deleteItems([id])
            managedContext.delete(id)
            CoreDataManager.sharedInstance.saveContext()
        }
//      secure the change by changing the datasource array and informing the snapshot
        getTodosOffline(ofUser: ofUser.id)
        applySnapshot()
//        self.dataSource.apply(snapshot)
    }
    
//  MARK: Fetching Data
    func getTodosOnline(ofUser: Int64){
        manager.fetchTodos(parameter: "/?userId=\(ofUser)", httpMethod: .get){
            fetchedTodos , error in
            guard let _ = fetchedTodos else{
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .hasEndedSyncWithError, object: nil)
                }
                print("no users fetched")
                return
            }
            CoreDataManager.sharedInstance.saveContext()
            if let coreDataTodos = CoreDataManager.sharedInstance.fetchTodos(ofUser: ofUser){
                self.todos = coreDataTodos
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .hasEndedSync, object: nil)
                    self.applySnapshot()
//                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func getTodosOffline(ofUser:Int64){
        guard let coreDataTodos = CoreDataManager.sharedInstance.fetchTodos(ofUser: ofUser), coreDataTodos.count>0 else {
            getTodosOnline(ofUser: ofUser)
            return
        }
        self.todos = coreDataTodos
        applySnapshot()
    }
    
//  MARK: Helpers
    
    func showAlert(selectedItem:Todo){
        let alertController = UIAlertController(title: "Completed?", message: "Press ok to change the completion status of this task", preferredStyle: .alert)
        let alertActionOk = UIAlertAction(title: "Do it!", style: .default, handler: { _ in
            self.markAsCompleted(selectedItem: selectedItem)
        })
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertActionOk)
        alertController.addAction(alertActionCancel)
        present(alertController, animated: true, completion: nil)
            
    }
    
    func markAsCompleted(selectedItem:Todo){
//        let fetchRequest = Todo.fetchRequest()
//        let predicate = NSPredicate(format: "id = %ld", selectedItem.id)
//        fetchRequest.predicate = predicate
//        do {
//            let fetchedTodo = try CoreDataManager.sharedInstance.managedContext.fetch(fetchRequest).first
//            fetchedTodo?.completed = true
//            CoreDataManager.sharedInstance.saveContext()
//            applySnapshot()
//        } catch (let error) {
//            print(error.localizedDescription)
//        }
        
        let item = selectedItem
        item.completed.toggle()
        CoreDataManager.sharedInstance.saveContext()
        applySnapshot()
//      collectionview doesnt reflect the change automatically, maybe because of the reusable nature of cells. Needs R
        collectionView.reloadData()
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(setUIForSyncing), name: .isSyncing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setUIForEndSync), name: .hasEndedSync, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hasEndedSyncWithError), name: .hasEndedSyncWithError, object: nil)
    }
    
    func setupMenu(){
        var menuItems: [UIAction] {
            return [
                UIAction(title: "Alphabetical", image: UIImage(systemName: "character"), handler: { _ in
                    self.todos.sort{
                        $0.title! < $1.title!
                    }
                    self.applySnapshot()
                }),
                UIAction(title: "Completed", image: UIImage(systemName: "checkmark"), handler: { _ in
                    self.todos.sort{
                        NSNumber(value: $0.completed).intValue > NSNumber(value: $1.completed).intValue
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
        getTodosOnline(ofUser: ofUser.id)
    }
    
    func setUpNetworkMonitor(monitor: NWPathMonitor){
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.syncBtn.isEnabled = true
                    self.syncBtn.layer.opacity = 1
                }
                
            } else {
                DispatchQueue.main.async {
                    self.syncBtn.isEnabled = false
                    self.syncBtn.layer.opacity = 0.5
                }
                
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    
//  MARK: CollentionView delegate functions
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedItem = self.dataSource.itemIdentifier(for: indexPath){
            showAlert(selectedItem: selectedItem)
        }
    }

}
