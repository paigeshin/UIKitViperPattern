# UIKitViperPattern

# Viper

- View
- Interactor
- Presenter
- Entity
- Router

# Configure Project

- Delete `Main Storyboard file base name`
- Delete `Storyboard Name` in Application Scene Manifest

# View

```swift
//
//  View.swift
//  Viper
//
//  Created by paige on 2021/11/16.
//

import UIKit

// Object
// protocol
// ref to interactor, router, view 

protocol AnyView {
    var presenter: AnyPresenter? { get set }
    
    func update(with users: [User])
    func update(with error: String)
}

class UserViewController: UIViewController, AnyView, UITableViewDelegate, UITableViewDataSource {

    private var users = [User]()
    var presenter: AnyPresenter?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func update(with users: [User]) {
        print(users)
        DispatchQueue.main.async {
            self.users = users
            self.tableView.reloadData()
        }
    }
    
    func update(with error: String) {
        print(error)
    }
    
    // Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }
    
}
```

# Interactor

```swift
//
//  Interactor.swift
//  Viper
//
//  Created by paige on 2021/11/16.
//

import Foundation

// object
// protocol
// ref to presenter

// some actions has been occurred
protocol AnyInteractor {
    var presenter: AnyPresenter? { get set }
    
    // contract
    func getUsers()
}

class UserInteractor: AnyInteractor {
    var presenter: AnyPresenter?
    
    func getUsers() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
        let tasks = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                self?.presenter?.interactorDidFetchUsers(with: .failure(FetchError.failed))
                return
            }
            do {
                let entities = try JSONDecoder().decode([User].self, from: data)
                self?.presenter?.interactorDidFetchUsers(with: .success(entities))
            }
            catch {
                self?.presenter?.interactorDidFetchUsers(with: .failure(error))
            }
        }
        tasks.resume()
    }
}
```

# Presenter

```swift
//
//  Presenter.swift
//  Viper
//
//  Created by paige on 2021/11/16.
//

import Foundation

// Object
// protocol
// ref to interactor, router, view

enum FetchError: Error {
    case failed 
}

protocol AnyPresenter {
    var router: AnyRouter? { get set }
    var interactor: AnyInteractor? { get set }
    var view: AnyView? { get set }
    
    func interactorDidFetchUsers(with result: Result<[User], Error>)
}

class UserPresenter: AnyPresenter {
    
    var router: AnyRouter?
    var interactor: AnyInteractor? {
        didSet {
            interactor?.getUsers()
        }
    }
    var view: AnyView?
    
    func interactorDidFetchUsers(with result: Result<[User], Error>) {
        switch result {
        case .success(let users):
            view?.update(with: users)
        case .failure:
            view?.update(with: "Something went wrong")
        }
    }
    
}
```

# Entity

```swift
//
//  Entity.swift
//  Viper
//
//  Created by paige on 2021/11/16.
//

import Foundation

// Model 
struct User: Codable {
    let name: String 
}
```

# Router

```swift
//
//  Router.swift
//  Viper
//
//  Created by paige on 2021/11/16.
//

import Foundation
import UIKit

// Object
// Entry Point

typealias EntryPoint = AnyView & UIViewController

protocol AnyRouter {
    var entry: EntryPoint?  { get }
    static func start() -> AnyRouter
}

class UserRouter: AnyRouter {
    var entry: EntryPoint?

    // create all of our components
    static func start() -> AnyRouter {
        let router = UserRouter()
        
        // Assign VIP
        var view: AnyView = UserViewController()
        var presenter: AnyPresenter = UserPresenter()
        var interactor: AnyInteractor = UserInteractor()
        
        // view refs to presenter
        view.presenter = presenter
        
        // interactor refs to presenter
        interactor.presenter = presenter
        
        // presenter refs to router
        // presenter refs to view
        // presenter refs to interactor
        presenter.router = router
        presenter.view = view
        presenter.interactor = interactor
        
        router.entry = view as? EntryPoint
        
        return router
    }
    
}
```

# SceneDelegate

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let userRouter = UserRouter.start()
        let initialVC = userRouter.entry
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = initialVC
        self.window = window
        window.makeKeyAndVisible()
        
    }
```
