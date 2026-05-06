//
//  JP_RouterError.swift
//  自参考工程 JP_Router 迁入
//

import Foundation

public enum JP_RouterError: Error {
    case handlerNotRegistered(url: String)
}
