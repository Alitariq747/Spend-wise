//
//  CloudKitSchemaInit.swift
//  SpendSnap
//
//  DEBUG only. Launch with `-initCloudKitSchema` to upload every model and
//  field to CloudKit's Development schema, before deploying it to Production.
//
//  Development only learns a field when a record carrying it syncs, so empty
//  optionals and models with no rows yet would be missing. Apple's
//  `initializeCloudKitSchema()` uploads one placeholder record per model with
//  every field set, then deletes it. It works against Development only.
//
//  It runs on a throwaway store in the temp folder: the real store is never
//  opened and sync never starts. Rerun it whenever a model or field is added.
//

#if DEBUG
import CoreData
import SwiftData
import SwiftUI

enum CloudKitSchemaInit {
    static var isRequested: Bool {
        ProcessInfo.processInfo.arguments.contains("-initCloudKitSchema")
    }

    /// Blocks for up to a minute; call it off the main thread.
    static func run(models: [any PersistentModel.Type]) -> String {
        guard let model = NSManagedObjectModel.makeManagedObjectModel(for: models) else {
            return "FAILED: couldn't convert the SwiftData models"
        }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("SchemaInit-\(UUID().uuidString).store")
        let description = NSPersistentStoreDescription(url: url)
        description.cloudKitContainerOptions =
            NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.ahmad.SpendWise")
        description.shouldAddStoreAsynchronously = false

        let container = NSPersistentCloudKitContainer(name: "SchemaInit", managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        var loadError: Error?
        container.loadPersistentStores { _, error in loadError = error }
        if let loadError { return "FAILED to open the temp store: \(loadError)" }

        defer {
            for store in container.persistentStoreCoordinator.persistentStores {
                try? container.persistentStoreCoordinator.remove(store)
            }
        }
        do {
            try container.initializeCloudKitSchema()
        } catch {
            return "FAILED: \(error)"
        }
        let names = model.entities.compactMap(\.name).sorted()
        return "OK: \(names.count) record types uploaded: \(names.joined(separator: ", "))"
    }
}

struct CloudKitSchemaInitView: View {
    @State private var result: String?

    var body: some View {
        VStack(spacing: 16) {
            if let result {
                Text(verbatim: result)
                    .font(.footnote.monospaced())
            } else {
                ProgressView()
                Text(verbatim: "Uploading CloudKit schema to Development…")
            }
        }
        .padding()
        .task {
            let models = AppBootController.models
            let outcome = await Task.detached { CloudKitSchemaInit.run(models: models) }.value
            print("CloudKitSchemaInit \(outcome)")
            result = outcome
        }
    }
}
#endif
