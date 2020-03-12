//
//  ZSNetWorkingTool+Download.swift
//  Alamofire
//
//  Created by 张森 on 2020/3/12.
//

import Foundation
import Alamofire

extension ZSNetWorkingTool {
    
    /// 资源下载
    /// - Parameters:
    ///   - path: 下载资源的路径
    ///   - destination: 下载完成后保存资源的位置，默认为 cachesDirectory
    ///   - progress: 进度
    ///   - completion: 下载完成的回调
    class public func Download(_ path: String,
                               to destination: DownloadRequest.DownloadFileDestination? = nil,
                               progress: ((Double) -> Void)? = nil,
                               completion: (ZSCompletion<String>)? = nil) {
        
        guard let requestUrl: URL = URL.init(string: path) else { return }
        
        let _destination_: DownloadRequest.DownloadFileDestination = { _, response in
            
            let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            
            let ext = response.mimeType?.split(separator: "/").last ?? ""
            
            let filename = response.suggestedFilename?.replacingOccurrences(of: ".\(ext)", with: "")
            
            let fileURL = cachesURL.appendingPathComponent((filename ?? "\(Date())") + ".\(ext)")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        self.default.download(URLRequest.init(url: (requestUrl)),
                              to: (destination == nil ? _destination_ : destination))
            
            .downloadProgress(queue: DispatchQueue.main, closure: { (progressObject) in
                if progress != nil {
                    progress!(progressObject.fractionCompleted)
                }
            })
            .responseData { (response) in
                
                guard completion != nil else { return }
                
                completion!(response.destinationURL?.path, response.error == nil, response.error as NSError?)
        }
    }
}
