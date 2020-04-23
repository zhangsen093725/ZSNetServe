//
//  ZSNetWorkingTool+Download.swift
//  Alamofire
//
//  Created by 张森 on 2020/3/12.
//

import Foundation
import Alamofire

extension ZSNetWorkingTool {
    
    class private func destination(cachesURL: URL) -> DownloadRequest.Destination {
        
        return { _, response in
            
            let ext = response.mimeType?.split(separator: "/").last ?? ""
            
            let filename = response.suggestedFilename?.replacingOccurrences(of: ".\(ext)", with: "")
            
            let fileURL = cachesURL.appendingPathComponent((filename ?? "\(Date())") + ".\(ext)")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
    }

    
    /// 资源下载
    /// - Parameters:
    ///   - path: 下载资源的路径
    ///   - url: 下载完成后保存资源的位置，默认为 cachesDirectory
    ///   - progress: 进度
    ///   - completion: 下载完成的回调
    class public func Download(_ path: String,
                               to url: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0],
                               progress: ((Double) -> Void)? = nil,
                               completion: (ZSCompletion<String>)? = nil) {
        
        guard let requestUrl: URL = URL.init(string: path) else { return }

        self.default.download(URLRequest.init(url: (requestUrl)),
                              to: destination(cachesURL: url))
            
            .downloadProgress(queue: DispatchQueue.main, closure: { (progressObject) in
                if progress != nil {
                    progress!(progressObject.fractionCompleted)
                }
            }).responseData { (response) in
                
                guard completion != nil else { return }
                
                completion!(response.fileURL?.path, response.error == nil, response.error as NSError?)
        }
    }
}
