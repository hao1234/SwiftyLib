//
//  FileClientError.swift
//  BPOSFoundation
//
//  Created by Andrew Eng on 27/12/16.
//  Copyright © 2016 Garena. All rights reserved.
//

import Foundation

public enum FileClientError: Error {
    case emptyUserInfo
    case emptyChainInfo
    case writeFailed(String)
    case unknown(String)
}
