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
