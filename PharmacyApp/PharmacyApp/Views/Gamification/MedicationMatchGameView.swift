import SwiftUI

struct MedicationMatchGameView: View {
    @EnvironmentObject private var gamificationViewModel: GamificationViewModel
    let onGameEnd: () -> Void
    
    @State private var medications: [Medication] = []
    @State private var selectedCards: [Medication] = []
    @State private var matchedCards: [String] = []
    @State private var attempts = 0
    @State private var score = 0
    @State private var gameCompleted = false
    
    // Medication data structure
    struct Medication: Identifiable, Hashable {
        let id: String
        let name: String
        let condition: String
    }
    
    // Sample medication data
    private let medicationData = [
        Medication(id: "1", name: "Aspirin", condition: "Pain Relief"),
        Medication(id: "2", name: "Metformin", condition: "Diabetes"),
        Medication(id: "3", name: "Lisinopril", condition: "Blood Pressure"),
        Medication(id: "4", name: "Atorvastatin", condition: "Cholesterol"),
        Medication(id: "5", name: "Levothyroxine", condition: "Thyroid"),
        Medication(id: "6", name: "Amoxicillin", condition: "Bacterial Infection")
    ]
    
    var body: some View {
        VStack {
            // Game header
            HStack {
                Text("Medication Match")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                VStack {
                    Text("Score: \(score)/\(medicationData.count)")
                    Text("Attempts: \(attempts)")
                }
            }
            .padding()
            
            // Game grid
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100)),
                GridItem(.adaptive(minimum: 100)),
                GridItem(.adaptive(minimum: 100))
            ], spacing: 10) {
                ForEach(medications) { medication in
                    CardView(medication: medication,
                             isSelected: selectedCards.contains(medication),
                             isMatched: matchedCards.contains(medication.id))
                        .onTapGesture {
                            selectCard(medication)
                        }
                        .disabled(matchedCards.contains(medication.id))
                }
            }
            .padding()
            
            // Game completion view
            if gameCompleted {
                VStack {
                    Text("Congratulations!")
                        .font(.title)
                        .foregroundColor(Color("PrimaryBlue"))
                    
                    Text("Score: \(score)/\(medicationData.count)")
                        .font(.headline)
                    
                    Text("Attempts: \(attempts)")
                        .font(.subheadline)
                    
                    Button(action: {
                        onGameEnd()
                    }) {
                        Text("Finish Game")
                            .padding()
                            .background(Color("PrimaryBlue"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
        .onAppear(perform: startGame)
    }
    
    private func startGame() {
        // Duplicate and shuffle medications
        medications = (medicationData + medicationData)
            .shuffled()
            .map { Medication(id: UUID().uuidString, name: $0.name, condition: $0.condition) }
        
        // Reset game state
        selectedCards.removeAll()
        matchedCards.removeAll()
        attempts = 0
        score = 0
        gameCompleted = false
    }
    
    private func selectCard(_ medication: Medication) {
        // Prevent selecting already matched or too many cards
        guard !matchedCards.contains(medication.id),
              !selectedCards.contains(medication),
              selectedCards.count < 2 else { return }
        
        selectedCards.append(medication)
        
        // Check for match
        if selectedCards.count == 2 {
            attempts += 1
            
            if selectedCards[0].name == selectedCards[1].name {
                // Match found
                matchedCards.append(selectedCards[0].id)
                matchedCards.append(selectedCards[1].id)
                score += 1
                
                // Check if game is won
                if matchedCards.count == medications.count {
                    // Game completed
                    gameCompleted = true
                    gamificationViewModel.recordMinigamePlay(won: true)
                }
            }
            
            // Clear selections after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                selectedCards.removeAll()
            }
        }
    }
}

// Card view for individual medication cards
struct CardView: View {
    let medication: MedicationMatchGameView.Medication
    let isSelected: Bool
    let isMatched: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(isMatched ? Color.green.opacity(0.3) :
                        (isSelected ? Color.blue.opacity(0.3) : Color.white))
                .shadow(radius: 3)
            
            if isSelected || isMatched {
                VStack {
                    Text(medication.name)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text(medication.condition)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(4)
            } else {
                Text("?")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
        }
        .aspectRatio(2/3, contentMode: .fit)
    }
}

struct MedicationMatchGameView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationMatchGameView(onGameEnd: {})
            .environmentObject(GamificationViewModel())
    }
}
