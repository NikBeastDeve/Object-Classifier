//
//  ContentView.swift
//  Object Classifier
//
//  Created by Nikita Galaganov on 28.02.2020.
//  Copyright © 2020 Nikita Galaganov. All rights reserved.
//
import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var envData = EnviromentExchanger()
    
    var body: some View {
        NavigationView {
            ZStack {
                InputViewController()
                
                VStack {
                    Text(envData.observation)
                        .bold()
                        .padding()
                        .foregroundColor(.black)
                        .frame(minWidth: UIScreen.main.bounds.width - 40, maxWidth: UIScreen.main.bounds.width - 40)
                        .font(.system(size: 20))
                        .background(Color.white.opacity(0.4))
                        .cornerRadius(10)
                }
                    .padding()
            }
                .edgesIgnoringSafeArea(.all)
                
        }
    }
}

struct PrevPrevView: View {
    @State private var isPressed: Bool = false
    var body: some View {
        NavigationView {
            ZStack {
                    Button(action: {
                        print("button pressed")
                    }) {
                        Image(systemName: "flashlight.off.fill")
                            .foregroundColor(.white)
                    }
                    .frame(width: 100, height: 100, alignment: .center)
                    .background(Color.black)
            }
                .edgesIgnoringSafeArea(.all)
                
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        PrevPrevView()
    }
}
