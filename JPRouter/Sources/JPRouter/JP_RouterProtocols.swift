//
//  JP_RouterProtocols.swift
//  自参考工程 JP_Router 迁入（模块名 JPRouter，类型名保持 JP_*）
//

import UIKit

public protocol JP_RouterProtocol: AnyObject {
    func bind(_ url: String, to handler: @escaping JP_RouteHandler)
    func handle(_ url: String, complexParams: [String: Any?]?, completion: JP_RouteCompletion?) -> Any?

    func register<Module>(_ protocolType: Module.Type, module: Module)
    func module<Module>(for protocolType: Module.Type) -> Module?
    func setupAllModules()
}

public protocol JP_BaseModuleProtocol: AnyObject {
    func setup()
    var priority: Int { get }
}

public extension JP_BaseModuleProtocol {
    func setup() {}
    var priority: Int { JP_RouterModulePriority.default }
}

// MARK: - 页面（UIViewController）生命周期（供模块可选遵守）

/// 业务模块可选遵守：接收宿主转发的 **UIViewController 可见性** 生命周期。
///
/// **命名说明**：文档中的 `JP_ApplicationLifeCycleProtocol` 多指 **App 级**；页面出现/消失请用本协议，勿混用命名。
///
/// 宿主在 `viewWillAppear` 等中调用 `JP_Router.shared.forwardViewControllerWillAppear` 等；Router 按 **`JP_BaseModuleProtocol.priority`**（否则 `JP_RouterModulePriority.default`）从高到低通知各模块。
public protocol JP_ModuleViewControllerLifecycleProtocol: AnyObject {
    func jp_module(_ viewController: UIViewController, viewWillAppear animated: Bool)
    func jp_module(_ viewController: UIViewController, viewDidAppear animated: Bool)
    func jp_module(_ viewController: UIViewController, viewWillDisappear animated: Bool)
    func jp_module(_ viewController: UIViewController, viewDidDisappear animated: Bool)
}

public extension JP_ModuleViewControllerLifecycleProtocol {
    func jp_module(_ viewController: UIViewController, viewWillAppear animated: Bool) {}
    func jp_module(_ viewController: UIViewController, viewDidAppear animated: Bool) {}
    func jp_module(_ viewController: UIViewController, viewWillDisappear animated: Bool) {}
    func jp_module(_ viewController: UIViewController, viewDidDisappear animated: Bool) {}
}
