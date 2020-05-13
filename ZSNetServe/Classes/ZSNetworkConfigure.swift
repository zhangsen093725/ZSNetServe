//
//  ZSNetworkConfigure.swift
//  Base
//
//  Created by 张森 on 2019/7/15.
//  Copyright © 2019 张森. All rights reserved.
//

import Foundation
import Alamofire

@objcMembers open class ZSNetworkConfigure: NSObject {
    
    /// 网络请求的httpHeader
    open class var zs_httpHeaders: [String : String] {
        return [:]
    }
    
    /// 网络请求的contentType， defult：["application/json", "text/json", "text/javascript", "text/html", "text/plain", "application/atom+xml", "application/xml", "text/xml", "image/png", "image/jpeg", "multipart/form-data"]
    open class var zs_contentType: Set<String> {
        return []
    }
    
    /// 网络请求超时时长，默认为 30 s
    open class var zs_timeOut: TimeInterval {
        return 30
    }
    
    /// 网络请求编码方式，默认为URLDefult
    open class var zs_requestEncoding: RequestEncoding {
        return .URLDefult
    }
    
    /// 网络请求响应编码方式，默认为JSON
    open class var zs_responseEncoding: ResponseEncoding {
        return .JSON
    }
}
