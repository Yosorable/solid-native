//
//  ContentView.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import SDWebImageSwiftUI
import SwiftUI

struct TestView: View {
    var id: Int

    init(id: Int) {
        self.id = id
        print("init \(id)")
    }
    var body: some View {
        let _ = print("render \(id)")
        NavigationStack {
            Text("Page \(id)")
                .navigationTitle(Text("Page\(id)"))
        }
    }
}

struct TestView2: View {
    var id: String

    init(id: String) {
        self.id = id
        print("init \(id)")
    }
    var body: some View {
        let _ = print("render \(id)")
        NavigationStack {
            Text("Page \(id)")
                .navigationTitle(Text("Page\(id)"))
        }
    }
}

struct ContentView: View {
    @State var url: String = "http://192.168.0.32:5050/index.js"
    @State var downloading: Bool = false

    @State var openApp = false
    @State var colorSchemeNum: Int

    init() {
        colorSchemeNum = readOrWriteIntegerFromFile()
    }

    var home: some View {
        NavigationStack {
            List {
                TextField(
                    text: $url,
                    label: {
                        Text("url")
                    }
                )
                Button {
                    downloading = true
                    DispatchQueue.global(qos: .background).async {
                        SolidNativeCore.download(baseUrl: url)
                        DispatchQueue.main.async {
                            downloading = false
                        }
                    }
                } label: {
                    Text("download")
                }
                .disabled(downloading)
                Picker("color scheme", selection: $colorSchemeNum) {
                    Text("auto").tag(0)
                    Text("light").tag(1)
                    Text("dark").tag(2)
                }.onChange(of: colorSchemeNum) {
                    _ = readOrWriteIntegerFromFile(write: $1)
                }

                Button {
                    let vc = UIHostingController(rootView: RootPageView())
                    vc.overrideUserInterfaceStyle =
                        colorSchemeNum == 0
                        ? .unspecified : (colorSchemeNum == 1 ? .light : .dark)
                    vc.modalPresentationStyle = .fullScreen
                    GetTopViewController()?.present(vc, animated: true)
                } label: {
                    Text("go")
                }
                .disabled(downloading)
            }
            .navigationTitle(Text("Home"))
        }
        .preferredColorScheme(
            colorSchemeNum == 0 ? nil : (colorSchemeNum == 1 ? .light : .dark)
        )
    }

    var body: some View {
        TabView {
            AnyView(home).tabItem { Label("Home", systemImage: "house") }.tag(0)
            LazyView(TestView(id: 1)).tabItem {
                Label("Test1", systemImage: "book")
            }.tag(1)
            LazyView(TestView(id: 2)).tabItem {
                Label("Test2", systemImage: "book")
            }.tag(2)
        }
    }
}

func readOrWriteIntegerFromFile(write newValue: Int? = nil) -> Int {
    let fileName = "config"
    let fileType = "txt"
    let defaultNumber = 0  // 默认值
    let fileManager = FileManager.default

    // 获取文档目录路径
    let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    let filePath = paths[0].appendingPathComponent("\(fileName).\(fileType)")

    // 写入新值到文件
    if let newValue = newValue {
        do {
            try "\(newValue)".write(
                to: filePath,
                atomically: true,
                encoding: .utf8
            )
            return newValue
        } catch {
            return defaultNumber
        }
    }

    // 读取文件中的值
    if fileManager.fileExists(atPath: filePath.path) {
        do {
            let content = try String(contentsOf: filePath, encoding: .utf8)
            if let number = Int(
                content.trimmingCharacters(in: .whitespacesAndNewlines)
            ) {
                return number
            } else {
                return defaultNumber
            }
        } catch {
            return defaultNumber
        }
    } else {
        // 文件不存在，创建文件并写入默认值
        do {
            try "\(defaultNumber)".write(
                to: filePath,
                atomically: true,
                encoding: .utf8
            )
            return defaultNumber
        } catch {
            return defaultNumber
        }
    }
}
