//
//  main.swift
//  NextPangeaSetup
//
//  Created by Jonathan Lee on 5/16/25.
//

import NPSInstaller

do {
    let installer = Installer()
    try installer.append(.init("ruby", "3.4.3"))
    try installer.install()
} catch {
    print(error)
}
