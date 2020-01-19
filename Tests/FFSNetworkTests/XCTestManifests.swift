#if !canImport(ObjectiveC)
import XCTest

// terminal: `swift test --generate-linuxmain` - to update this file!

extension BackendRxTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__BackendRxTests = [
        ("testTodosRxWithTodoRequest", testTodosRxWithTodoRequest),
        ("testTodosRxWithTypedRequest", testTodosRxWithTypedRequest),
    ]
}

extension CombineServerTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__CombineServerTests = [
        ("testSimpleStringRx", testSimpleStringRx),
        ("testTodosRxTypedNetworkRequest", testTodosRxTypedNetworkRequest),
        ("testTodosRxUsingJSONTask", testTodosRxUsingJSONTask),
    ]
}

extension ErrorMessageProviderTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ErrorMessageProviderTests = [
        ("testErrorMessageProvider", testErrorMessageProvider),
    ]
}

extension FFSNetworkTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__FFSNetworkTests = [
        ("testAllDataCaseUrlRequestSend", testAllDataCaseUrlRequestSend),
        ("testBackendRequest", testBackendRequest),
        ("testBackendRequestSetHeader", testBackendRequestSetHeader),
        ("testBackendRequestURLRequestCreation", testBackendRequestURLRequestCreation),
        ("testErrorCaseTypedNetworkRequestRun", testErrorCaseTypedNetworkRequestRun),
        ("testErrorCaseUrlRequestRun", testErrorCaseUrlRequestRun),
        ("testNoDataNoErrorCaseTypedJSONNetworkRequestRun", testNoDataNoErrorCaseTypedJSONNetworkRequestRun),
        ("testNoDataNoErrorCaseTypedNetworkRequestRun", testNoDataNoErrorCaseTypedNetworkRequestRun),
        ("testNoDataNoErrorCaseUrlRequestRun", testNoDataNoErrorCaseUrlRequestRun),
        ("testNoDataNoErrorCaseUrlRequestSend", testNoDataNoErrorCaseUrlRequestSend),
        ("testParseErrorCaseTypedJSONNetworkRequestRun", testParseErrorCaseTypedJSONNetworkRequestRun),
        ("testParseErrorCaseTypedNetworkRequestRun", testParseErrorCaseTypedNetworkRequestRun),
        ("testSuccessCaseTodoNetworkRequestRun", testSuccessCaseTodoNetworkRequestRun),
        ("testSuccessCaseTypedNetworkRequestRun", testSuccessCaseTypedNetworkRequestRun),
        ("testSuccessCaseUrlRequestRun", testSuccessCaseUrlRequestRun),
        ("testTodosRequest", testTodosRequest),
        ("testTodosRequestHeaders", testTodosRequestHeaders),
    ]
}

extension IntegrationTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__IntegrationTests = [
        ("testJSONResponse", testJSONResponse),
        ("testSimpleHtmlResponse", testSimpleHtmlResponse),
        ("testTypedJSONResponse", testTypedJSONResponse),
        ("testTypedResponse", testTypedResponse),
    ]
}

extension MockedCombineServerTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__MockedCombineServerTests = [
        ("testMockedCombineNetworkCall", testMockedCombineNetworkCall),
        ("testMockedCombineTypedNetworkCall", testMockedCombineTypedNetworkCall),
    ]
}

extension ServerConfigurationTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ServerConfigurationTests = [
        ("testServerConfigruation", testServerConfigruation),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BackendRxTests.__allTests__BackendRxTests),
        testCase(CombineServerTests.__allTests__CombineServerTests),
        testCase(ErrorMessageProviderTests.__allTests__ErrorMessageProviderTests),
        testCase(FFSNetworkTests.__allTests__FFSNetworkTests),
        testCase(IntegrationTests.__allTests__IntegrationTests),
        testCase(MockedCombineServerTests.__allTests__MockedCombineServerTests),
        testCase(ServerConfigurationTests.__allTests__ServerConfigurationTests),
    ]
}
#endif
