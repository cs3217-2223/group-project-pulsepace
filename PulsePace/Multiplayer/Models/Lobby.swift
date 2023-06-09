//
//  Lobby.swift
//  PulsePace
//
//  Created by Charisma Kausar on 26/3/23.
//

class Lobby {
    var lobbyId: String
    var hostId: String
    var modeName: String
    var lobbyStatus: LobbyStatus
    var players: [String: Player] = [:]
    var preMatchData: PreMatchData?

    let roomSetting: RoomSetting

    let dataManager: LobbyDataManager
    let lobbyDataChangeHandler: (() -> Void)?

    var playerCount: Int {
        players.count
    }

    var isUserHost: Bool {
        guard let userConfigManager = UserConfigManager.instance else {
            fatalError("No user config manager")
        }
        return hostId == userConfigManager.userId
    }

    var isEligibleToPlay: Bool {
        playerCount >= roomSetting.minPlayerCount && playerCount <= roomSetting.maxPlayerCount
    }

    private init(lobbyId: String, hostId: String, roomSetting: RoomSetting,
                 modeName: String, players: [String: Player] = [:],
                 lobbyStatus: LobbyStatus = .waitingForPlayers,
                 preMatchData: PreMatchData? = nil,
                 lobbyDataChangeHandler: (() -> Void)? = { }) {
        self.lobbyId = lobbyId
        self.hostId = hostId
        self.players = players
        self.lobbyStatus = lobbyStatus
        self.preMatchData = preMatchData
        self.lobbyDataChangeHandler = lobbyDataChangeHandler
        self.roomSetting = roomSetting
        self.modeName = modeName
        self.dataManager = LobbyDataManager(lobbyDatabase: FirebaseDatabase<Lobby>(),
                                            lobbyListener: FirebaseListener<Lobby>(),
                                            playersListener: FirebaseListener<Player>(),
                                            lobbyDataChangeHandler: lobbyDataChangeHandler)
    }

    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let modeName = try values.decode(String.self, forKey: .modeName)
        self.init(lobbyId: try values.decode(String.self, forKey: .lobbyId),
                  hostId: try values.decode(String.self, forKey: .hostId),
                  roomSetting: ModeFactory.getModeAttachment(modeName).roomSetting,
                  modeName: modeName,
                  lobbyStatus: try values.decode(LobbyStatus.self, forKey: .lobbyStatus),
                  preMatchData: try values.decode(PreMatchData.self, forKey: .preMatchData))
    }

    /**
     Creates a new lobby and saves it in the database.
     */
    convenience init(modeName: String, selectedBeatmapIndex: Int, lobbyDataChangeHandler: (() -> Void)? = {}) {
        let id = NanoID.new(alphabet: .numbers, size: 6)
        guard let userConfigManager = UserConfigManager.instance else {
            fatalError("No user config manager")
        }
        let player = Player(playerId: userConfigManager.userId, name: userConfigManager.name)
        self.init(lobbyId: id, hostId: userConfigManager.userId,
                  roomSetting: ModeFactory.getModeAttachment(modeName).roomSetting,
                  modeName: modeName, players: [userConfigManager.userId: player],
                  preMatchData: PreMatchData(selectedBeatmapIndex: selectedBeatmapIndex),
                  lobbyDataChangeHandler: lobbyDataChangeHandler)
        dataManager.createLobby(lobby: self)
    }

    /**
     Joins a lobby with the given `lobbyId`, if it exists.
     */
    convenience init(lobbyId: String, modeName: String,
                     lobbyDataChangeHandler: (() -> Void)? = {}) {
        guard let userConfigManager = UserConfigManager.instance else {
            fatalError("No user config manager")
        }
        self.init(lobbyId: lobbyId, hostId: userConfigManager.userId,
                  roomSetting: ModeFactory.getModeAttachment(modeName).roomSetting,
                  modeName: modeName,
                  lobbyDataChangeHandler: lobbyDataChangeHandler)
        let player = Player(playerId: userConfigManager.userId, name: userConfigManager.name)
        dataManager.joinLobby(lobby: self, player: player)
    }

    func startMatch() {
        let match = Match(matchId: lobbyId, lobby: self)
        dataManager.startMatch(match: match)
    }
}

extension Lobby: Codable {
    private enum CodingKeys: String, CodingKey {
        case lobbyId
        case hostId
        case modeName
        case lobbyStatus
        case players
        case preMatchData
    }
}

enum LobbyStatus: String, Codable {
    case waitingForPlayers
    case closed
    case matchStarted
    case disconnected
}
