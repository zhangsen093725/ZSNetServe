//
//  ZSNetWorkingTool+Result.swift
//  Alamofire
//
//  Created by 张森 on 2020/3/12.
//

import Foundation

@objc public enum ResponseEncoding: Int {
    case JSON = 1, Data
}

extension ZSNetWorkingTool {
    
    public typealias ZSCompletion<ResultType> =
        (_ responseObject: ResultType?,
        _ isSuccess: Bool,
        _ error: Error?) -> Void
}
