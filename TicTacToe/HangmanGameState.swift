import SwiftUI
import Combine

enum WordCategory: String, CaseIterable, Identifiable {
    case animals = "Animals"
    case food = "Food"
    case sports = "Sports"
    case colors = "Colors"
    case countries = "Countries"
    
    var id: String { self.rawValue }
}

@MainActor
class HangmanGameState: ObservableObject {
    @Published var currentWord: String = ""
    @Published var guessedLetters: Set<Character> = []
    @Published var wrongGuesses: Int = 0
    @Published var score: Int = 0
    @Published var gamesWon: Int = 0
    @Published var gamesLost: Int = 0
    @Published var isGameOver: Bool = false
    @Published var hasWon: Bool = false
    @Published var selectedCategory: WordCategory = .animals
    
    let maxWrongGuesses = 8
    private var usedWords: [WordCategory: Set<String>] = [:]
    private let usedWordsDefaultsKey = "HangmanUsedWords"
    
    private let wordBank: [WordCategory: [String]] = [
        .animals: [
            "CAT", "DOG", "BEAR", "LION", "TIGER", "ELEPHANT",
            "GIRAFFE", "MONKEY", "ZEBRA", "RABBIT", "HORSE", "BIRD",
            "FISH", "SHARK", "WHALE", "DOLPHIN", "EAGLE", "PENGUIN",
            "KOALA", "PANDA", "FOX", "WOLF", "DEER", "MOOSE"
        ],
        .food: [
            "PIZZA", "BURGER", "PASTA", "TACO", "RICE", "BREAD",
            "CHEESE", "APPLE", "BANANA", "ORANGE", "GRAPE", "BERRY",
            "SALAD", "SOUP", "STEAK", "CHICKEN", "FISH", "SHRIMP",
            "COOKIE", "CAKE", "PIE", "CANDY", "HONEY", "BUTTER"
        ],
        .sports: [
            "SOCCER", "TENNIS", "HOCKEY", "GOLF", "RUGBY", "CRICKET",
            "BOXING", "SKIING", "SURFING", "RUNNING", "SWIMMING", "CYCLING",
            "BASEBALL", "FOOTBALL", "BOWLING", "FENCING", "ARCHERY", "SKATING"
        ],
        .colors: [
            "RED", "BLUE", "GREEN", "YELLOW", "ORANGE", "PURPLE",
            "PINK", "BROWN", "BLACK", "WHITE", "GRAY", "SILVER",
            "GOLD", "BRONZE", "VIOLET", "INDIGO", "CYAN", "MAGENTA"
        ],
        .countries: [
            "USA", "CANADA", "MEXICO", "BRAZIL", "FRANCE", "SPAIN",
            "ITALY", "GREECE", "EGYPT", "CHINA", "JAPAN", "INDIA",
            "RUSSIA", "POLAND", "TURKEY", "IRELAND", "SWEDEN", "NORWAY"
        ]
    ]
    
    init() {
        loadPersistedUsedWords()
        startNewGame()
    }
    
    func setCategory(_ category: WordCategory) {
        selectedCategory = category
        startNewGame()
    }
    
    func startNewGame() {
        guessedLetters = []
        wrongGuesses = 0
        isGameOver = false
        hasWon = false
        
        // Select a random word from the selected category, avoiding correctly-guessed words until exhausted
        if let words = wordBank[selectedCategory], !words.isEmpty {
            let used = usedWords[selectedCategory] ?? []
            let available = words.filter { !used.contains($0) }
            let pool = available.isEmpty ? words : available
            if available.isEmpty {
                // All words exhausted; reset the used list for this category
                usedWords[selectedCategory] = []
                persistUsedWords()
            }
            currentWord = pool.randomElement() ?? "CAT"
        } else {
            currentWord = "CAT"
        }
    }
    
    func guessLetter(_ letter: Character) {
        // Don't allow guesses if game is over or letter already guessed
        guard !isGameOver, !guessedLetters.contains(letter) else { return }
        
        guessedLetters.insert(letter)
        
        // Check if letter is in the word
        if !currentWord.contains(letter) {
            wrongGuesses += 1
            
            // Check for loss
            if wrongGuesses >= maxWrongGuesses {
                isGameOver = true
                hasWon = false
                gamesLost += 1
            }
        } else {
            // Check for win (all letters guessed)
            if isWordComplete() {
                isGameOver = true
                hasWon = true
                gamesWon += 1
                score += 10
                // Store the word as used only when guessed correctly
                usedWords[selectedCategory, default: []].insert(currentWord)
                persistUsedWords()
            }
        }
    }
    
    func isWordComplete() -> Bool {
        for letter in currentWord {
            if !guessedLetters.contains(letter) {
                return false
            }
        }
        return true
    }
    
    func getDisplayWord() -> String {
        var display = ""
        for letter in currentWord {
            if guessedLetters.contains(letter) {
                display += String(letter)
            } else {
                display += "_"
            }
            display += " "
        }
        return display.trimmingCharacters(in: .whitespaces)
    }
    
    private func persistUsedWords() {
        var dict: [String: [String]] = [:]
        for (category, set) in usedWords {
            dict[category.rawValue] = Array(set)
        }
        UserDefaults.standard.set(dict, forKey: usedWordsDefaultsKey)
    }

    private func loadPersistedUsedWords() {
        guard let dict = UserDefaults.standard.dictionary(forKey: usedWordsDefaultsKey) as? [String: [String]] else { return }
        var result: [WordCategory: Set<String>] = [:]
        for (key, values) in dict {
            if let category = WordCategory(rawValue: key) {
                result[category] = Set(values)
            }
        }
        usedWords = result
    }
    
    func resetStats() {
        score = 0
        gamesWon = 0
        gamesLost = 0
        startNewGame()
    }
}
