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
