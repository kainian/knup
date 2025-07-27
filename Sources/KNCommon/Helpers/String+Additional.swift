//
//  String+Additional.swift
//  KainianSetup
//
//  Created by Jonathan Lee on 5/31/25.
//

import struct CryptoKit.SHA256
import struct Foundation.Data

extension String {
    
    public var sha256: String {
        return Data(utf8).sha256
    }
}
