//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Salman Z on 11/10/24.
//

import SwiftUI

struct FullSpinnerModifier: ViewModifier {
    let amount: Double
    let anchor: UnitPoint
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(amount), anchor: anchor)
            .clipped()
    }
}

extension AnyTransition {
    static var spin: AnyTransition {
        .modifier(
            active: FullSpinnerModifier(amount: 180, anchor: .topLeading),
            identity: FullSpinnerModifier(amount: 0, anchor: .topLeading)
            )
    }
}

struct FlagImage: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 20))
    }
    
}

extension View {
    
    func flagImage() -> some View {
        self.modifier(FlagImage())
    }

}

struct TitleStyle: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .bold()
            .foregroundStyle(.blue)
    }
}

extension View {
    
    func titleStyle() -> some View {
        self.modifier(TitleStyle())
    }
}

struct FlagEffectModifier: ViewModifier {
    var selectedFlag: Int?
    var number: Int
    var countries: [String]
    
    func body(content: Content) -> some View {
        content
        // Rotate the selected flag 360 degrees on selection
        .rotationEffect(
            .degrees(
                selectedFlag == number ? 360 : 0
            ),  anchor: .center
        )
        
        // Dim unselected flags to 25% opacity when a flag is selected
        .opacity(selectedFlag != number && selectedFlag != nil ? 0.25 : 1)
        
        // Dim unselected flags to 25% opacity when a flag is selected
        .scaleEffect(
            selectedFlag != number && selectedFlag != nil
            ? CGSize(width: 0.25, height: 0.25)
            : CGSize(width: 1, height: 1)
        )
        // Dim unselected flags to 25% opacity when a flag is selected
        .accessibilityHint("Tap to select this flag.")
        .accessibilityLabel("Flag of \(countries[number])")
        .animation(.easeInOut(duration: 0.5), value: selectedFlag) // Added animation for smooth effect
        
        
    }
}

extension View {
    func applyFlagModifier(selectedFlag: Int?, number: Int, countries: [String]) -> some View {
        self.modifier(FlagEffectModifier(selectedFlag: selectedFlag, number: number, countries: countries))
    }
}




struct ContentView: View {
    
   
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"]
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var showingScore = false
    @State private var scoreTitle: String = ""
    @State private var userScore = 0
    @State private var numberOfQuestions = 0
    @State private var isGameOver = false
    @State private var selectedFlag: Int?
    
    var body: some View {
        
        ZStack{
            RadialGradient(stops: [
                .init(color: Color(red: 0.84, green: 0.0, blue: 0.43), location: 0.0),  // Fuchsia
                .init(color: Color(red: 0.61, green: 0.15, blue: 0.69), location: 0.5), // Violet
                .init(color: Color(red: 0.25, green: 0.31, blue: 0.71), location: 0.8)  // Indigo (less space)
            ], center: .top, startRadius: 200, endRadius: 400)
            .ignoresSafeArea()
            
            VStack{
                
                Spacer()
                Text("Guess the flag")
                    .foregroundStyle(.black)
                    .titleStyle()
                
                VStack(spacing: 15){
                    VStack(){
                        Text("Tap the flag of ")
                            .font(.subheadline.weight(.heavy))
                            .foregroundStyle(.secondary)
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    ForEach(0..<3) { number in
                        Button{
                            flagTapped(number)
                        } label: {
                            Image(countries[number])
                                .clipShape(.capsule)
                                .shadow(radius: 5)
                                .applyFlagModifier(selectedFlag: selectedFlag, number: number, countries: countries)
                        }
                    }
                }
                .flagImage()
                
                Text("Score: \(userScore)")
                    .font(.title.bold())
                    .foregroundStyle(.black)
   

                Spacer()
                    .foregroundStyle(.white)
                    .font(.title.bold())
                Spacer()
            }
            .padding()

        }
        
        .alert("Game Over", isPresented: $isGameOver) {
            Button("Replay", action: gameOver)
        }
        message: {
                Text("Final Score: \(userScore)")
        }
        
    
        .alert(scoreTitle, isPresented: $showingScore){
            Button("Continue", action: askQuestion)
        } message: {
            Text("Your score is \(userScore)")
        }
        
    }
    
    func flagTapped(_ number: Int){
        
        withAnimation{
            selectedFlag = number
        }
        if number == correctAnswer{
            scoreTitle = "Correct!"
            userScore += 1
        } else{
            scoreTitle = "Wrong that was the flag of \(countries[number])."
        }
        
        showingScore = true
        numberOfQuestions += 1
        
        if numberOfQuestions == 8{
            isGameOver = true
        }
        
        
    }
    
    func askQuestion(){
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        // After the animation is done reset to Nil
        selectedFlag = nil
    }
    
    func gameOver(){
        userScore = 0
        numberOfQuestions = 0
        isGameOver = false
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }
}


    
#Preview {
    ContentView()
}

