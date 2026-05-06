//
//  JP_Router.swift
//  自参考工程 JP_Router 迁入
//

import UIKit

/// Swift 6：单例 + 可变字典由调用方在主线程序列化使用；`@unchecked Sendable` 与参考 CocoaPods 版语义一致，仅消除模块编译错误。
@objc public class JP_Router: NSObject, @unchecked Sendable {

    @objc public static let shared = JP_Router()

    private override init() {
        super.init()
    }

    private var urlHandlers: [String: JP_RouteHandler] = [:]
    private var modules: [String: Any] = [:]
}

extension JP_Router: JP_RouterProtocol {

    public func bind(_ url: String, to handler: @escaping JP_RouteHandler) {
        urlHandlers[url] = handler
    }

    public func handle(_ url: String, complexParams: [String: Any?]?, completion: JP_RouteCompletion?) -> Any? {
        guard let handler = urlHandlers[url] else {
            print("⚠️ JP_Router: 未找到 URL 对应的 Handler - \(url)")
            completion?(.failure(.handlerNotRegistered(url: url)))
            return nil
        }

        let result = handler(complexParams ?? [:])
        let valueForResult = result ?? NSNull()
        completion?(.success(valueForResult))
        return result
    }

    public func register<Module>(_ protocolType: Module.Type, module: Module) {
        let key = String(describing: protocolType)
        modules[key] = module
        print("✅ JP_Router: 注册模块 - \(key)")
    }

    public func module<Module>(for protocolType: Module.Type) -> Module? {
        let key = String(describing: protocolType)
        return modules[key] as? Module
    }

    @objc public func setupAllModules() {
        print("🚀 JP_Router: 开始初始化所有模块")

        let sortedModules = modules.values.compactMap { $0 as? JP_BaseModuleProtocol }
            .sorted { $0.priority > $1.priority }

        sortedModules.forEach { $0.setup() }

        print("✅ JP_Router: 所有模块初始化完成")
    }

    @objc public func registerModule(_ module: AnyObject, forProtocolName protocolName: String) {
        modules[protocolName] = module
        print("✅ JP_Router: 注册模块 - \(protocolName)")
    }

    @objc public func getModule(forProtocolName protocolName: String) -> AnyObject? {
        return modules[protocolName] as AnyObject?
    }

    // MARK: - 页面（UIViewController）生命周期转发

    /// 对应 `UIViewController.viewWillAppear`；由宿主或各业务 VC 在 `super` 之后调用（Swift / OC 均可，`@objc` 暴露给 OC）。
    @objc public func forwardViewControllerWillAppear(_ viewController: UIViewController, animated: Bool) {
        forEachViewControllerLifecycleModule { $0.jp_module(viewController, viewWillAppear: animated) }
    }

    /// 对应 `UIViewController.viewDidAppear`。
    @objc public func forwardViewControllerDidAppear(_ viewController: UIViewController, animated: Bool) {
        forEachViewControllerLifecycleModule { $0.jp_module(viewController, viewDidAppear: animated) }
    }

    /// 对应 `UIViewController.viewWillDisappear`。
    @objc public func forwardViewControllerWillDisappear(_ viewController: UIViewController, animated: Bool) {
        forEachViewControllerLifecycleModule { $0.jp_module(viewController, viewWillDisappear: animated) }
    }

    /// 对应 `UIViewController.viewDidDisappear`。
    @objc public func forwardViewControllerDidDisappear(_ viewController: UIViewController, animated: Bool) {
        forEachViewControllerLifecycleModule { $0.jp_module(viewController, viewDidDisappear: animated) }
    }

    private func modulePriority(_ module: Any) -> Int {
        (module as? JP_BaseModuleProtocol)?.priority ?? JP_RouterModulePriority.default
    }

    private func forEachViewControllerLifecycleModule(_ body: (JP_ModuleViewControllerLifecycleProtocol) -> Void) {
        let ordered = modules.values
            .compactMap { $0 as? JP_ModuleViewControllerLifecycleProtocol }
            .sorted { modulePriority($0) > modulePriority($1) }
        for m in ordered {
            body(m)
        }
    }
}
