//
//  BackendService.swift
//  vulnabankIOs
//

import Foundation
import XMLCoder

enum Result<T, E: Error> {
    case success( T )
    case failure( E )
}

enum ErrorResult: Error {
    case network( string: String )
    case parser( string: String )
    case custom( string: String )
}

protocol BackendServiceProtocol {
    func sendTransaction( transactionRequest: TransactionRequest, completion: @escaping ( Result<Data, ErrorResult> ) -> Void )
}

final class BackendService: BackendServiceProtocol {
   
    func sendTransaction( transactionRequest: TransactionRequest, completion: @escaping ( Result<Data, ErrorResult> ) -> Void ) {
        let session: URLSession = URLSession( configuration: .default )

        var request = URLRequest( url: URL( string: Constants.Values.serverEndpoint )!)
        request.httpMethod = "POST"
        request.setValue( "Application/xml", forHTTPHeaderField: "Content-Type" )

        guard let httpBody = try? XMLEncoder().encode( transactionRequest, withRootKey: "request" ) else {
            return
        }
        request.httpBody = httpBody

        print("Transaction request: ", "\(Constants.Values.serverEndpoint)" , to: &logger)
        
        let task = session.dataTask( with: request ) { ( data, response, error ) in
            if let error = error {
                completion( .failure( .network( string: "An error occurred during request: " + error.localizedDescription ) ) )
                return
            }

            guard let data = data,
                  let xml = try? XMLDecoder().decode( ServerResponse.self, from: data ),
                  let xmlResultValue = xml.resultValue,
                  let base64DecodedData = Data( base64Encoded: xmlResultValue ) else {
                completion( .failure( .parser( string: "XML parser error" ) ) )
                return
            }

            completion( .success( base64DecodedData ) )
        }

        task.resume()
    }
}
