//
//  ContentView.swift
//  Paste
//
//  Created by 孙双 on 2025/1/28.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var clipboardManager = ClipboardManager()
    @State private var selectedItem: ClipboardItem?
    @State private var editedText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(clipboardManager.isRecording ? "停止记录" : "开始记录") {
                        clipboardManager.toggleRecording()
                    }
                    .foregroundColor(clipboardManager.isRecording ? .red : .green)
                    
                    Spacer()
                    
                    Button("全部追加") {
                        // 按时间顺序从上到下追加所有记录
                        editedText = clipboardManager.history
                            .map { $0.content }
                            .joined(separator: "\n")
                    }
                    .disabled(clipboardManager.history.isEmpty)
                    
                    Button("清空记录") {
                        clipboardManager.clearHistory()
                        editedText = ""
                    }
                    .disabled(clipboardManager.history.isEmpty)
                }
                .padding()
                
                List {
                    ForEach(clipboardManager.history) { item in
                        VStack(alignment: .leading) {
                            Text(item.content)
                                .lineLimit(2)
                            Text(item.timestamp, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if editedText.isEmpty {
                                editedText = item.content
                            } else {
                                editedText += " " + item.content
                            }
                            selectedItem = item
                        }
                        .contextMenu {
                            Button("复制") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(item.content, forType: .string)
                            }
                        }
                    }
                }
            }
            .navigationTitle("剪贴板历史")
            .frame(minWidth: 300)
            
            // 右侧详细内容视图
            ScrollView {
                VStack {
                    TextEditor(text: $editedText)
                        .font(.system(.body))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    
                    HStack {
                        Button("清空") {
                            editedText = ""
                        }
                        .disabled(editedText.isEmpty)
                        
                        Spacer()
                        
                        Button("复制") {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(editedText, forType: .string)
                        }
                        .disabled(editedText.isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .frame(minWidth: 400)
        }
    }
}

#Preview {
    ContentView()
}
