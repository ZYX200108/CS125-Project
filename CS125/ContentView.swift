//
//  ContentView.swift
//  CS125
//
//  Created by Yuxue Zhou on 1/23/24.
//


import SwiftUI

struct ContentView: View {
    @State private var progress: CGFloat = 0.75 // Example progress, set to 75%

    var body: some View {
        TabView(selection: .constant(1)) {
                    VStack(spacing: 20) {
                        Text("You have walked \(Int(progress * 10000)) steps today")
                            .font(.title)
                            .padding(.top)

                        // Custom circular progress indicator
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 20)
                                .opacity(0.3)
                                .foregroundColor(Color.blue) // Changed color

                            Circle()
                                .trim(from: 0.0, to: progress)
                                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                                .foregroundColor(Color.blue) // Changed color
                                .rotationEffect(Angle(degrees: 270.0))
                                .animation(.linear, value: progress)

                            Text("\(Int(progress * 100))% of daily goal")
                                .font(.title2)
                                .bold()
                        }
                        .frame(width: 200, height: 200)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(Int(progress * 1000)) cal")
                                    .font(.headline)
                                Text("Cal Burned")
                                    .font(.caption)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("1,000")
                                    .font(.headline)
                                Text("Daily Goal")
                                    .font(.caption)
                            }
                        }
                        .padding()

                        // Statistic Bar Graph Placeholder
                        VStack(alignment: .leading) {
                            Text("Statistic")
                                .font(.headline)
                                .padding(.bottom, 5)
                            // Placeholder for bar graph, you'll need to implement this with your own custom view or library
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 100)
                            Text("Insight")
                                .font(.headline)
                                .padding(.top, 5)
                        }
                        
                        Spacer() // Pushes everything to the top
                    }
                    .padding()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(1)
            
            
            // Tab 2
        TabView {
            List {
                Section(header: Text("Account")) {
                    HStack {
                        Text("Username")
                        Spacer()
                        Text("User123")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Email")
                        Spacer()
                        Text("user@example.com")
                            .foregroundColor(.gray)
                    }
                }

                Section(header: Text("Settings")) {
                    Toggle(isOn: .constant(true)) {
                        Text("Notifications")
                    }
                    Toggle(isOn: .constant(false)) {
                        Text("Dark Mode")
                    }
                }

                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Settings")
        }
        .tabItem {
            Label("Settings", systemImage: "gear")
        }
        .tag(2)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

