 Kakuro Application

A modern, feature-rich implementation of the classic Japanese number puzzle game Kakuro, built with Swift and SwiftUI.

 📖 About Kakuro

Kakuro is a logic-based number puzzle that originated in Japan in the 1960s. The name comes from the Japanese words meaning "addition cross," which perfectly describes the gameplay. Similar to a crossword puzzle in appearance, Kakuro challenges players to fill white cells with numbers (1-9) that satisfy sum constraints shown in black clue cells, with the added constraint that numbers cannot repeat within the same sum.

✨ Features

1. Core Gameplay
- **Three Difficulty Levels**: Easy, Medium, and Hard puzzles
- **10 Puzzles per Difficulty**: 30 unique puzzles to solve
- **Real-time Validation**: Instant feedback on correct and incorrect entries
- **Error Tracking**: Game ends after 5 accumulated errors per puzzle
- **Countdown Timer**: Time limits vary by difficulty (Easy: 10min, Medium: 15min, Hard: 25min)
- **Bonus Scoring**: Earn extra points for fast completion

2. Smart Features
- **Hint System**: 
  - Guest users: 3 hints per puzzle
  - Registered users: Unlimited hints
- **Pencil Marks/Notes**: Write candidate numbers before committing
- **Undo/Redo**: Track last 10-20 moves
- **Auto-Save**: Progress saved automatically every few minutes

3. User Experience
- **Interactive Tutorial**: Step-by-step guide for beginners
- **Progress Tracking**: 
  - Total puzzles completed
  - Average completion time
  - Accuracy rate
  - Personal best times
- **Achievement System**: Badges and milestones
- **Daily Challenges**: Maintain streaks like Duolingo
- **Statistics Dashboard**: Comprehensive analytics and improvement graphs

4. Customization
- **Theme Options**:
  - Light mode
  - Dark mode
  - High contrast mode
  - Custom color themes
- **Visual Settings**:
  - Custom backgrounds
  - Grid color customization
  - Font size adjustment
- **Sound Effects**: Optional audio feedback (can be muted)
  - Number placement sounds
  - Completion chimes
  - Error alerts
  - Victory fanfare

5. User Authentication

6. Guest Users (Limited Access)
- Play all puzzles at any difficulty
- Access tutorial and How to Play
- Basic hints (max 3 per puzzle)
- Pencil marks and undo/redo
- View leaderboards (read-only)
- Session-only progress save
- Default theme only

7. Registered Users (Full Access)
All guest features plus:
- Unlimited hints and AI solver
- Cloud save and sync across devices
- Full theme customization
- Complete statistics tracking
- Achievement and badge system
- Leaderboard participation and ranking
- Daily challenge streak tracking
- Challenge friends feature
- Profile management

## 🎮 How to Play

### The Grid
- **Black cells** contain clues (sum constraints)
- **White cells** are filled with numbers to solve the puzzle
- Diagonal lines in black cells separate horizontal (bottom-left) and vertical (top-right) clues

### Rules
1. Use only numbers 1-9 (no zeros, no repeats in the same sum)
2. Numbers must add up to exactly match the clue
3. No repeating numbers within the same sum
4. Every white cell must be filled
5. Most cells satisfy both horizontal and vertical constraints

### Starting Strategy
1. Find clues with few possible answers (e.g., 3 with 2 cells → only 1+2)
2. Fill in obvious combinations first
3. Use intersections where horizontal and vertical clues meet
4. Apply elimination logic
5. Build progressively using each solved cell

### Difficulty Levels
- **Easy** (5×5 or 6×6 grids): More single-solution clues, less overlap
- **Medium** (8×8 or 10×10 grids): Multiple possibilities, more connections
- **Hard** (10×10 to 15×15 grids): Few obvious clues, heavy interconnection

## 🛠 Tech Stack

- **Programming Language**: Swift
- **IDE**: Xcode
- **GUI Framework**: SwiftUI/AppKit
- **Backend**: Firebase Firestore
- **Architecture**: MVC (Model-View-Controller)
- **UML Modeling**: Draw.io

## 🏗 Architecture

### MVC Structure

#### Model Layer
- Cell models representing individual grid positions
- Run models for groups of cells with sum constraints
- Validation logic implementing Kakuro rules
- Data structures mapping Firebase documents to Swift objects

#### View Layer (SwiftUI)
- Game grid rendering
- Clue cells and input cells display
- Visual indicators for invalid entries
- Real-time UI updates

#### Controller Layer
- User input handling
- Model updates based on user actions
- Validation triggering
- Firebase data retrieval
- UI state management

### Backend Design (Firebase)
Each puzzle stored as a document containing:
- Grid layouts
- Run layouts
- Puzzle metadata (size, difficulty, completion status)
- Player scoreboard

## 🎯 Project Goals

This project aims to create more than just a functional puzzle game. The goal is to build an application that:
- People genuinely enjoy using
- Serves as an effective learning tool for beginners
- Provides a calming, entertaining experience
- Offers meaningful progress tracking and achievement
- Maintains high code quality and modern design principles



 👥 Authors

Evelyne Mukarukundo
Shaquille Osborne Neil
Hope Jeanine Ukundimana

