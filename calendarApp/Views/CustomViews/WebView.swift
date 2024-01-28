//
//  WebView.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/01/28.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let myRequest = URLRequest(url: url)
        webView.load(myRequest)
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct WebViewCustom: View {
    @EnvironmentObject var customColor: CustomColor
    
    let url: URL
    @Binding var showInfo: Bool
    
    let backSize: CGFloat = 15
    let safariSize: CGFloat = 20
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    showInfo.toggle()
                } label: {
                    Image(systemName: "multiply")
                        .resizable()
                        .fontWeight(.light)
                        .frame(width: backSize, height: backSize)
                        .padding()
                        .foregroundStyle(customColor.foreGround)
                }
                Spacer()
                Link(destination: url) {
                    Image(systemName: "safari")
                        .resizable()
                        .fontWeight(.thin)
                        .frame(width: safariSize, height: safariSize)
                        .foregroundStyle(customColor.foreGround)
                        .padding()
                }
                .onTapGesture {
                    showInfo.toggle()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 30)
            WebView(url: url)
        }
    }
}
