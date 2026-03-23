import Foundation

struct NotesStore {
    private let fileManager: FileManager
    private let appDirectoryName: String
    private let fileName: String

    init(
        fileManager: FileManager = .default,
        appDirectoryName: String = "TopMemo",
        fileName: String = "notes.json"
    ) {
        self.fileManager = fileManager
        self.appDirectoryName = appDirectoryName
        self.fileName = fileName
    }

    func load() throws -> [MemoItem] {
        let fileURL = try storageFileURL()

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        guard !data.isEmpty else {
            return []
        }

        return try JSONDecoder.memoDecoder.decode([MemoItem].self, from: data)
    }

    func save(_ notes: [MemoItem]) throws {
        let fileURL = try storageFileURL()
        let directoryURL = fileURL.deletingLastPathComponent()

        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        let data = try JSONEncoder.memoEncoder.encode(notes)
        try data.write(to: fileURL, options: .atomic)
    }

    func storageFileURL() throws -> URL {
        let applicationSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        return applicationSupportURL
            .appendingPathComponent(appDirectoryName, isDirectory: true)
            .appendingPathComponent(fileName, isDirectory: false)
    }
}

private extension JSONEncoder {
    static var memoEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private extension JSONDecoder {
    static var memoDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
