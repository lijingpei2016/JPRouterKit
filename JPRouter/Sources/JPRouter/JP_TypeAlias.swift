//
//  JP_TypeAlias.swift
//  自参考工程 JP_Router 迁入
//

import Foundation

public typealias JP_RouteHandler = ([String: Any?]) -> Any?

public typealias JP_RouteCompletion = (Result<Any, JP_RouterError>) -> Void
