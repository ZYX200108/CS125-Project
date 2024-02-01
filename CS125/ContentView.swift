//
//  ContentView.swift
//  CS125
//
//  Created by Yuxue Zhou on 1/23/24.
//

//import SwiftUI
//    
//struct ContentView: View {
//    var body: some View {
//        VStack {
//            ProgressView(value:5, total:20)
//            HStack{
//                VStack {
//                    Text("Daily Goal Progress")
//                    Text("150/600")
//                }
//            }
//            Circle().strokeBorder(lineWidth: 24)
//        }
//        
//        
//    }
//}
//    
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
import SwiftUI

struct ContentView: View {
    @State private var progress: CGFloat = 0.75 // Example progress, set to 75%

    var body: some View {
        VStack(spacing: 20) {
            // Improved ProgressView with text indicating the current progress
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)

            Text("Daily Goal Progress")
                .font(.headline)

            // Displaying numeric progress (for example, 150 out of 200)
            Text("\(Int(progress * 200))/200")
                .font(.caption)

            // Custom circular progress indicator
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(Color.blue)

                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.blue)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)

                // Text showing the percentage in the middle of the circle
                Text("\(Int(progress * 100))%")
                    .font(.title)
                    .bold()
            }
            .frame(width: 150, height: 150)

        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
