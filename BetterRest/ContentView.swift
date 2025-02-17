//
//  ContentView.swift
//  BetterRest
//
//  Created by Daniel Collis on 2/13/25.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var showingBedtime = false
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @State private var sleepTime = Date.now
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
        
    var body: some View {
        NavigationStack {
            Form {
                
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section("Desired Amount of Sleep") {
                    Stepper("\(sleepAmount.formatted()) Hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section("How Many Cups of Coffee Per Day?") {
                    Stepper("^[\(coffeeAmount) cup](inflect:true)", value: $coffeeAmount, in: 0...20)
                }
                
                    .alert(alertTitle, isPresented: $showingBedtime) {
                        Button("Confirm") {
                            showingBedtime = false
                        }
                    } message: {
                        Text(alertMessage)
                    }
                
                Section {
                    Text("Recommended Bedtime: \(calculateBedtime())")
                }
            }
            .navigationTitle("Better Rest")
        }
    }
    
    func getCalculableTime(_ wakeTime: Date) -> Double {
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeTime)
        let hoursToSeconds = (components.hour ?? 0) * 3600
        let minutesToSeconds = (components.minute ?? 0) * 60
        
        return (Double)(hoursToSeconds + minutesToSeconds)
    }
    
    func calculateBedtime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try BetterRest(configuration: config)
            
            let calculableTime = getCalculableTime(wakeUp)
            
            let prediction = try model.prediction(wake: calculableTime, estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            //subtracts the amount of sleep that the model predicts we should get from the Date object that stores what time we want to wake up; this gives us the time in which we should go to bed
            let sleepTime = wakeUp - prediction.actualSleep
            let sleepTimeString = sleepTime.formatted(date: .omitted, time: .shortened)
            return sleepTimeString
        } catch {
            return "Error"
        }
    }
}

#Preview {
    ContentView()
}
