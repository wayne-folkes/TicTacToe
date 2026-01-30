import SwiftUI
import Combine

enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var id: String { self.rawValue }
}

struct Word: Identifiable, Equatable {
    let id = UUID()
    let term: String
    let definition: String
    let difficulty: Difficulty
}

@MainActor
class DictionaryGameState: ObservableObject {
    @Published var currentWord: Word?
    @Published var options: [String] = []
    @Published var score: Int = 0
    @Published var isGameOver: Bool = false
    @Published var feedbackColor: Color = .clear
    @Published var selectedOption: String? = nil
    @Published var difficulty: Difficulty = .medium
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var apiAttempts: Int = 0
    private let maxAPIAttempts: Int = 3
    
    private var allWords: [Word] = [
        // Easy
        Word(term: "Happy", definition: "Feeling or showing pleasure or contentment.", difficulty: .easy),
        Word(term: "Strong", definition: "Having the power to move heavy weights or perform other physically demanding tasks.", difficulty: .easy),
        Word(term: "Bright", definition: "Giving out or reflecting a lot of light; shining.", difficulty: .easy),
        Word(term: "Quick", definition: "Moving fast or doing something in a short time.", difficulty: .easy),
        Word(term: "Quiet", definition: "Making little or no noise.", difficulty: .easy),
        Word(term: "Funny", definition: "Causing laughter or amusement; humorous.", difficulty: .easy),
        Word(term: "Simple", definition: "Easily understood or done; presenting no difficulty.", difficulty: .easy),
        Word(term: "Brave", definition: "Ready to face and endure danger or pain; showing courage.", difficulty: .easy),
        Word(term: "Calm", definition: "Not showing or feeling nervousness, anger, or other emotions.", difficulty: .easy),
        Word(term: "Wise", definition: "Having or showing experience, knowledge, and good judgment.", difficulty: .easy),
        
        // Medium
        Word(term: "Ephemeral", definition: "Lasting for a very short time.", difficulty: .medium),
        Word(term: "Serendipity", definition: "The occurrence of events by chance in a happy or beneficial way.", difficulty: .medium),
        Word(term: "Petrichor", definition: "A pleasant smell that frequently accompanies the first rain after a long period of warm, dry weather.", difficulty: .medium),
        Word(term: "Mellifluous", definition: "A sound that is sweet and musical; pleasant to hear.", difficulty: .medium),
        Word(term: "Ineffable", definition: "Too great or extreme to be expressed or described in words.", difficulty: .medium),
        Word(term: "Sonder", definition: "The realization that each random passerby is living a life as vivid and complex as your own.", difficulty: .medium),
        Word(term: "Limerence", definition: "The state of being infatuated or obsessed with another person.", difficulty: .medium),
        Word(term: "Sonorous", definition: "Imposing deep and full sound.", difficulty: .medium),
        Word(term: "Solitude", definition: "The state or situation of being alone.", difficulty: .medium),
        Word(term: "Aurora", definition: "A natural light display in the Earth's sky.", difficulty: .medium),
        
        // Hard
        Word(term: "Vellichor", definition: "The strange wistfulness of used bookstores.", difficulty: .hard),
        Word(term: "Defenestration", definition: "The act of throwing someone or something out of a window.", difficulty: .hard),
        Word(term: "Phosphenes", definition: "The moving patterns you see when you rub your eyes.", difficulty: .hard),
        Word(term: "Apricity", definition: "The warmth of the sun in winter.", difficulty: .hard),
        Word(term: "Cromulent", definition: "Acceptable or adequate.", difficulty: .hard),
        Word(term: "Embiggen", definition: "To make bigger or more expansive.", difficulty: .hard),
        Word(term: "Ubiquitous", definition: "Present, appearing, or found everywhere.", difficulty: .hard),
        Word(term: "Pernicious", definition: "Having a harmful effect, especially in a gradual or subtle way.", difficulty: .hard),
        Word(term: "Esoteric", definition: "Intended for or likely to be understood by only a small number of people.", difficulty: .hard),
        Word(term: "Obfuscate", definition: "Render obscure, unclear, or unintelligible.", difficulty: .hard)
    ]
    
    init(startImmediately: Bool = true) {
        if startImmediately {
            startNewGame()
        }
    }
    
    func setDifficulty(_ newDifficulty: Difficulty) {
        difficulty = newDifficulty
        startNewGame()
    }
    
    func startNewGame() {
        score = 0
        isGameOver = false
        apiAttempts = 0
        nextQuestion()
    }
    
    func nextQuestion() {
        // Always try API first; fallback to local if needed
        fetchWordFromAPI()
    }
    
    func loadLocalQuestion() {
        feedbackColor = .clear
        selectedOption = nil
        errorMessage = nil
        isLoading = false
        
        let filteredWords = allWords.filter { $0.difficulty == difficulty }
        guard let newWord = filteredWords.randomElement() else { return }
        currentWord = newWord
        
        generateOptions(for: newWord, pool: filteredWords)
    }
    
    private func generateOptions(for word: Word, pool: [Word]) {
        var distractorDefinitions = pool.filter { $0.id != word.id }.map { $0.definition }
        
        // Fallback to all words if pool is small
        if distractorDefinitions.count < 3 {
             distractorDefinitions = allWords.filter { $0.id != word.id }.map { $0.definition }
        }
        
        distractorDefinitions.shuffle()
        
        var currentOptions = Array(distractorDefinitions.prefix(3))
        currentOptions.append(word.definition)
        options = currentOptions.shuffled()
    }
    
    // MARK: - API Integration
    
    func fetchWordFromAPI() {
        isLoading = true
        feedbackColor = .clear
        selectedOption = nil
        errorMessage = nil
        apiAttempts = 0

        Task {
            await requestRandomWordAsync()
        }
    }
    
    private func requestRandomWordAsync() async {
        let randomURL = URL(string: "https://random-word-api.herokuapp.com/word?number=1")!
        while apiAttempts < maxAPIAttempts {
            do {
                let (data, _) = try await URLSession.shared.data(from: randomURL)
                let words = try JSONDecoder().decode([String].self, from: data)
                if let randomWord = words.first {
                    if await fetchDefinitionAsync(for: randomWord) { return }
                }
            } catch {
                // ignore and retry
            }
            apiAttempts += 1
        }
        errorMessage = "Using local words (API unavailable)."
        loadLocalQuestion()
    }
    
    private func fetchDefinitionAsync(for word: String) async -> Bool {
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)") else { return false }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let entries = try JSONDecoder().decode([DictionaryEntry].self, from: data)
            if let firstEntry = entries.first,
               let firstMeaning = firstEntry.meanings.first,
               let firstDef = firstMeaning.definitions.first {
                let newWord = Word(term: firstEntry.word.capitalized, definition: firstDef.definition, difficulty: self.difficulty)
                self.currentWord = newWord
                self.isLoading = false
                let pool = self.allWords.filter { $0.difficulty == self.difficulty }
                self.generateOptions(for: newWord, pool: pool.isEmpty ? self.allWords : pool)
                self.apiAttempts = 0
                return true
            }
        } catch {
            // ignore and retry
        }
        return false
    }

    func checkAnswer(_ answer: String) {
        guard let currentWord = currentWord else { return }
        selectedOption = answer
        
        let isCorrect = answer == currentWord.definition
        if isCorrect {
            score += 1
            feedbackColor = .green
            HapticManager.shared.notification(type: .success)
        } else {
            feedbackColor = .red
            HapticManager.shared.notification(type: .error)
        }
        
        // Record statistics after checking the answer
        GameStatistics.shared.recordDictionaryGame(score: score)
    }
}

// MARK: - API Models
struct DictionaryEntry: Codable {
    let word: String
    let meanings: [Meaning]
}

struct Meaning: Codable {
    let definitions: [Definition]
}

struct Definition: Codable {
    let definition: String
}

