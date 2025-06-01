//
//  String+Additional.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/31/25.
//

import struct CryptoKit.SHA256
import struct Foundation.Data

extension Data {
    
    public var sha256: String {
        let digest = SHA256.hash(data: self)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}
