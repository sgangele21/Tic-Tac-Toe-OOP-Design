enum PlayerType {
    
    case PlayerOne
    case PlayerTwo
    
    func decision() -> BoardSlot {
        switch self {
        case .PlayerOne:
            return .X
        case .PlayerTwo:
            return .O
        }
    }
    
}

enum BoardSlot: String {
    
    case X
    case O
    case empty
    
}

enum Status {
    
    case Winner(PlayerType)
    case Tie
    case Playing
    
}

public struct Board {
    
    var array: [[BoardSlot]]!
    var boardGameStatus: Status
    var size: Int {
        return self.array.count
    }
    
    init(size: Int) {
        self.boardGameStatus = .Playing
        self.setupArray(size: size)
    }
    
    private func setupArray(size: Int) {
        var array: [[BoardSlot]] = [[]]
        for _ in 1...size {
            var nestedArray: [BoardSlot] = []
            for _ in 1...size {
                nestedArray.append(.empty)
            }
            array.append(nestedArray)
        }
    }
    
}

public struct Placement: Equatable {
    
    var row: Int
    var col: Int
    
    public static func ==(lhs: Placement, rhs: Placement) -> Bool {
        return lhs.row == rhs.row && lhs.col == rhs.col
    }
    
}

public enum InvalidSlot: Error {
    
    case SlotTaken
    
}

// Purpose of this is to manipulate the board
// Through actions by a player
public class BoardLogic {
    
    var board: Board
    
    init(board: Board) {
        self.board = board
        
    }
    
    // TODO: Well... a player can write an empty into the slot? Fix this
    func write(player: Player, placement: Placement)  throws -> Void  {
        
        let slot = self.board.array[placement.row][placement.col]
        switch slot {
        case .empty:
            self.board.array[placement.row][placement.col] = player.playerType.decision()
        default:
            throw InvalidSlot.SlotTaken
        }
        
        // Look adjacent to the place where there could be more matches
        // There are at most 4 places you can look
        
        
    }
    
    func checkForWinner(player: Player, givenMove: Placement) {
        if player.history.count < self.board.size {
            return
        }
        
        if self.winHorizontally(player: player, placement: givenMove) || self.winVertically(player: player, placement: givenMove) || self.winDiagonally(player: player) {
            self.board.boardGameStatus = .Winner(player.playerType)
        }
        
    }
    
    func winHorizontally(player: Player, placement: Placement) -> Bool {
        // We're given a coordinate (1,3) and we need to check if they won horizontally
        // We need to check (1,1) , (1,2)
        let size = self.board.size
        let row = placement.row
        for j in 0..<size {
            if self.board.array[row][j] != player.playerType.decision() {
                return false
            }
        }
        return true
    }
    
    func winVertically(player: Player, placement: Placement) -> Bool {
        let size = self.board.size
        let col = placement.col
        
        for i in 0..<size {
            if self.board.array[i][col] != player.playerType.decision() {
                return false
            }
        }
        return true
    }
    
    
    // We need to check if the players histories contains either corners
    func winDiagonally(player: Player) -> Bool {
        let size = self.board.size
        
        var hasBottomLeftToTopRightCorner = true
        var col = 1
        
        for i in (0..<size).reversed() {
            let currentDiagonalPlacement = Placement(row: i, col: col)
            if !player.history.contains(where: { (placement) -> Bool in
                return placement == currentDiagonalPlacement
            }) {
                hasBottomLeftToTopRightCorner = false
                break
            }
            col += 1
        }
        
        var hasTopLeftToBottomRightCorner = true
        for i in (0..<size) {
            let currentDiagonalPlacement = Placement(row: i, col: i)
            if !player.history.contains(where: { (placement) -> Bool in
                return placement == currentDiagonalPlacement
            }) {
                hasTopLeftToBottomRightCorner = false
                break
            }
        }
        
        return hasBottomLeftToTopRightCorner || hasTopLeftToBottomRightCorner
        
    }
    
    
    

}

public class Player {
    
    var board: Board
    var boardLogic: BoardLogic
    var playerType: PlayerType
    var history: [Placement]
    
    init(board: Board, boardLogic: BoardLogic, playerType: PlayerType) {
        self.board = board
        self.boardLogic = boardLogic
        self.playerType = playerType
        self.history = []
        
        self.boardLogic.board = self.board
        
    }
    
    public func write(placement: Placement, completion: (Error) -> Void ) {
        do {
            try self.boardLogic.write(player: self, placement: placement)
            self.recordHistory(placement: placement)
        } catch(let error) {
            completion(error)
        }
    }
    
    func recordHistory(placement: Placement) {
        self.history.append(placement)
    }
    
}



