//
//  MinigameView.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import SwiftUI

struct MinigameView: View {
    @EnvironmentObject private var gamificationViewModel: GamificationViewModel
    @State private var selectedGame: Minigame?
    @State private var isGameActive = false
    @State private var showingCompletionAlert = false
    @State private var lastGameWon = false
    
    // Sample minigames
    private let minigames = [
        Minigame(id: "game1", name: "Med Match", description: "Match medications with their purposes. Learn about different medications while having fun!", difficultyLevel: "Easy", timeToPlay: "2-3 min", pointsToEarn: 50, imageName: "game_match"),
        
        Minigame(id: "game2", name: "Pill Pursuit", description: "Race to collect your medications on time while avoiding obstacles. This game helps reinforce the importance of medication timing.", difficultyLevel: "Medium", timeToPlay: "3-5 min", pointsToEarn: 75, imageName: "game_pursuit"),
        
        Minigame(id: "game3", name: "Health Quiz", description: "Test your health knowledge with questions about medications, conditions, and general wellness.", difficultyLevel: "Hard", timeToPlay: "5-7 min", pointsToEarn: 100, imageName: "game_quiz"),
        
        Minigame(id: "game4", name: "Body Explorer", description: "Learn how medications work in the body with this interactive educational game.", difficultyLevel: "Medium", timeToPlay: "4-6 min", pointsToEarn: 75, imageName: "game_explorer"),
        
        Minigame(
                id: "game5",
                name: "Medication Match",
                description: "Test your memory by matching medication pairs. Learn drug names while having fun!",
                difficultyLevel: "Easy",
                timeToPlay: "2-3 min",
                pointsToEarn: 50,
                imageName: "game_match"
            )
        
    ]
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Stats section
                HStack(spacing: 20) {
                    StatCard(
                        title: "Games Played",
                        value: "\(gamificationViewModel.minigamesPlayed)",
                        icon: "gamecontroller.fill",
                        color: Color("PrimaryBlue")
                    )
                    
                    StatCard(
                        title: "Win Rate",
                        value: gamificationViewModel.minigamesPlayed > 0 ? "\(Int(Double(gamificationViewModel.minigamesWon) / Double(gamificationViewModel.minigamesPlayed) * 100))%" : "0%",
                        icon: "percent",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Points Earned",
                        value: "\(gamificationViewModel.totalPoints)",
                        icon: "star.fill",
                        color: .orange
                    )
                }
                .padding(.horizontal)
                
                // Games grid
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Available Games")
                            .font(.headline)
                            .foregroundColor(Color("TextColor"))
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                            ForEach(minigames) { game in
                                MinigameCardView(game: game)
                                    .onTapGesture {
                                        selectedGame = game
                                        isGameActive = true
                                    }
                            }
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .padding(.vertical)
                        
                        Text("Why Play Health Games?")
                            .font(.headline)
                            .foregroundColor(Color("TextColor"))
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            BenefitRow(icon: "brain.head.profile", title: "Improve Knowledge", description: "Learn about medications and health while having fun")
                            
                            BenefitRow(icon: "bell.badge", title: "Build Habits", description: "Reinforce good medication and health habits")
                            
                            BenefitRow(icon: "trophy.fill", title: "Earn Rewards", description: "Get points and badges for your health journey")
                            
                            BenefitRow(icon: "heart.fill", title: "Better Outcomes", description: "Games can help improve your overall health management")
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    .padding(.top)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Health Games")
        .sheet(isPresented: $isGameActive) {
            if let game = selectedGame {
                GamePlayView(game: game, isPresented: $isGameActive, onComplete: { won in
                    gamificationViewModel.recordMinigamePlay(won: won)
                    lastGameWon = won
                    showingCompletionAlert = true
                })
            }
        }
        .alert(isPresented: $showingCompletionAlert) {
            Alert(
                title: Text(lastGameWon ? "Congratulations!" : "Good Try!"),
                message: Text(lastGameWon
                              ? "You've earned points and improved your health knowledge!"
                              : "Keep playing to improve your skills and health knowledge!"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("TextColor"))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct MinigameCardView: View {
    let game: Minigame
    
    var body: some View {
        VStack {
            // Game icon (in a real app, this would be an image)
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("PrimaryBlue").opacity(0.2))
                    .frame(height: 100)
                
                Image(systemName: gameIcon)
                    .font(.system(size: 40))
                    .foregroundColor(Color("PrimaryBlue"))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(game.name)
                    .font(.headline)
                    .foregroundColor(Color("TextColor"))
                
                Text(game.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(3)
                    .frame(height: 50)
                
                HStack {
                    // Difficulty pill
                    Text(game.difficultyLevel)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .background(difficultyColor(game.difficultyLevel))
                        .cornerRadius(10)
                    
                    Spacer()
                    
                    // Points
                    Text("\(game.pointsToEarn) pts")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Text(game.timeToPlay)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(12)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Sample icon (in a real app, this would use actual game images)
    private var gameIcon: String {
        switch game.name {
        case "Med Match":
            return "rectangle.grid.2x2.fill"
        case "Pill Pursuit":
            return "figure.run"
        case "Health Quiz":
            return "questionmark.app.fill"
        case "Body Explorer":
            return "heart.fill"
        default:
            return "gamecontroller.fill"
        }
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Easy":
            return .green
        case "Medium":
            return .orange
        case "Hard":
            return .red
        default:
            return .gray
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color("PrimaryBlue"))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color("TextColor"))
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct GamePlayView: View {
    let game: Minigame
    @Binding var isPresented: Bool
    let onComplete: (Bool) -> Void
    
    @State private var timeRemaining = 180 // 3 minutes for memory game
    @State private var timer: Timer?
    @State private var progress = 0.0
    @State private var showingControls = true
    @State private var gameView: AnyView?
    
    var body: some View {
        VStack(spacing: 20) {
            Text(game.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color("TextColor"))
                .padding(.top, 30)
            
            if showingControls {
                // Game instructions
                VStack(spacing: 16) {
                    Image(systemName: gameIcon)
                        .font(.system(size: 80))
                        .foregroundColor(Color("PrimaryBlue"))
                        .padding(.vertical, 20)
                    
                    Text("Game Instructions")
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))
                    
                    Text(game.description)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                    
                    Button(action: {
                        // Start the game
                        showingControls = false
                        startTimer()
                        
                        // Dynamically create game view based on game ID
                        switch game.id {
                        case "game5": // Medication Match
                            gameView = AnyView(
                                MedicationMatchGameView(
                                    onGameEnd: {
                                        timer?.invalidate()
                                        isPresented = false
                                        onComplete(true) // Always pass true, or determine success based on game performance
                                    }
                                )
                            )
                        default:
                            // Existing placeholder game
                            gameView = AnyView(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(height: 300)
                                    
                                    Text("Game in progress...")
                                        .font(.title3)
                                        .foregroundColor(Color("TextColor"))
                                }
                            )
                        }
                    }) {
                        Text("Start Game")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("PrimaryBlue"))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                }
            } else {
                // Game content area
                VStack(spacing: 20) {
                    // Progress bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(height: 10)
                            .foregroundColor(Color.gray.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: CGFloat(progress) * UIScreen.main.bounds.width * 0.8, height: 10)
                            .foregroundColor(Color("PrimaryBlue"))
                    }
                    .padding(.horizontal, 40)
                    
                    Text("Time remaining: \(timeRemaining)")
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))
                    
                    // Dynamic game view
                    if let view = gameView {
                        view
                    }
                }
            }
            
            Spacer()
            
            // Exit button
            Button(action: {
                timer?.invalidate()
                isPresented = false
                onComplete(false)
            }) {
                Text("End Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
    }
    
    // Sample icon (in a real app, this would use actual game images)
    private var gameIcon: String {
        switch game.name {
        case "Medication Match":
            return "rectangle.grid.2x2.fill"
        case "Med Match":
            return "rectangle.grid.2x2.fill"
        case "Pill Pursuit":
            return "figure.run"
        case "Health Quiz":
            return "questionmark.app.fill"
        case "Body Explorer":
            return "heart.fill"
        default:
            return "gamecontroller.fill"
        }
    }
    
    private func startTimer() {
        progress = 0.0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                progress = Double(180 - timeRemaining) / 180.0
            } else {
                timer?.invalidate()
                isPresented = false
                onComplete(false)
            }
        }
    }
}

struct MinigameView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MinigameView()
                .environmentObject(GamificationViewModel())
        }
    }
}
