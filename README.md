# FFSNetwork

## ServerConnection
 Runs network dataTasks. Uses URLSession, which can be provided at initialization
 Required parameter to initialize is a configuration conforming to protocol "ServerConfiguring"

 If used with requests, which conform to TypedNetworkRequest, then the result success value
 will match the type defined in the requests mapResponse() function value return type.

 ```swift
struct Backend {
    private let serverConnection: ServerConnection!

    init(_ serverConfiguration: ServerConfiguring) {
        serverConnection = ServerConnection(configuration: serverConfiguration)
    }

    func loadSomeText(_ completion: @escaping (Result<StringResponse, Error>) -> Void) {
        let request = BackendRequest<StringResponse>(path: "/someText")
        runTaskWith(request, completion: completion)
    }
}
```
 Then you can create your own structs conforming to "TypedNetworkResponse" with custom return types.
 The above example returns a StringResponse. StringResponse is a built-in response, which just
 converts the recieved data into a utf-8 string, if prossible.
 
 In the 'Examples' folder is a ExampleRequest, ExampleResponse and ExampleConfiguration file.
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
 

