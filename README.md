# FFSNetwork

## ServerConnection
 ServerConnection runs network dataTasks. It uses URLSession, which can be provided at initialization. Required parameter to initialize is a configuration conforming to protocol "ServerConfiguring"

### Structure of the project
The main classes are *ServerConnection.swift* and *CombineServer.swift*.

Find more documentation inside the files.

The folders *Types* and *Protocols* contain the definitions of the required types for FFSNetwork, like enums, protocols, structs and so forth.

The folder *ConvenienceObjects* contains concrete implemantations of the protocols used for requests and responses. Use these objects as convenience or starting point for your own implementations.

The folder *Internal* contains code, which is used only internally by this library.

The folder *Examples* contains examples for serverConfiguration, TypedNetworkRequest and TypedNetworkResponse implementations, which connect to an example REST server and load simple Todo objects from: https://jsonplaceholder.typicode.com. These examples demonstrate typed results.
Further there is a class called *BackendRx*. This class demonstrates the use of the CombineServer. It can be used with SwiftUI in a reactive manner.

### Usage
 If used with requests, which conform to TypedNetworkRequest, then the result success value
 will match the type defined in the requests mapResponse() function value return type.

 ```swift
struct Backend {
    private let serverConnection: ServerConnection!

    init(_ serverConfiguration: ServerConfiguring) {
        serverConnection = ServerConnection(configuration: serverConfiguration)
    }

    func loadSomeText(_ completion: @escaping (Result<StringResponse, Error>) -> Void) {
        let request = TypedRequest<StringResponse>(path: "/someText")
        runTaskWith(request, completion: completion)
    }
}
```
 Then you can create your own structs conforming to "TypedNetworkResponse" with custom return types.
 The above example returns a StringResponse. StringResponse is a built-in response, which just
 converts the recieved data into a string using either .utf8 or .isoLatin1 string encoding, if prossible.
 
 In the 'Examples' folder is an ExampleRequest, ExampleResponse and ExampleConfiguration file.
 Those examples illustrate the usage of ServerConnection for typed results.
 
 Note that for typed results you can use the built-in 'BackendRequest' struct with just a custom "TypedNetworkResponse" type.

 If you add the example files to your project you then can add the following method to your Backend struct:
 ```swift
     func loadTodos(_ completion: @escaping (Result<FetchTodosResponse, Error>) -> Void) {
         let request = FetchTodosRequest()
         serverConnection.runTaskWith(request, completion: completion)
     }
 ```
Now when using the 'Backend' in the UI Layer (UIViewController subclass) you get back an array of 'Todo' objects.
 
```swift
    import UIKit
    
    class TodosViewController: UIViewController {
        private var todos = [Todo]()
        private var backend: Backend!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let serverConfiguration = StagingConfiguration()
            // if this crashes, it's a misconfigured serverConfiguration:
            backend = try! Backend(serverConfiguration)
            
            loadTodos()
        }
        
        func loadTodos() {
            backend.loadTodos { result in
                if case let .success(response) = result {
                    DispatchQueue.main.async {
                        self.todos = response.value
                        // refresh UI now...
                    }
                }
            }
        }
    }
```
 
## CombineServer

The CombineServer is only available starting with Mac Os X 15 and iOS 13, as it uses the newly introduced *Combine framework* in order to use Publishers and Observers. This allows the use of the FFSNetwork package for SwiftUI projects as well.

```swift
    import SwiftUI
    import Combine
    
    struct ContentView: View {
        private let backend = BackendRx()
        @State private var todos = [Todo]()
        @State private var cancellable: Cancellable? = nil
        
        var body: some View {
            List(todos) { todo in
                HStack {
                    Text(todo.title)
                    if todo.completed {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .onAppear {
                self.loadTodos()
            }
            }
        }
        
        func loadTodos() {
            backend.loadTodosRx { result in
                if case let .success(response) = result {
                    DispatchQueue.main.async {
                        self.todos = response.value
                    }
                }
            }
        }
    }
```
