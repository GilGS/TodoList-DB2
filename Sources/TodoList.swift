/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
import TodoListAPI

import IBMDB

struct TodoList : TodoListAPI {
    
    let db = IBMDB()
    let connString = "DRIVER={DB2};DATABASE=BLUDB;HOSTNAME=awh-yp-small02.services.dal.bluemix.net;PORT=50000;PROTOCOL=TCPIP;UID=dash111703;PWD=eb0b4bde1722;"
    
    func count(withUserID: String?, oncompletion: (Int?, ErrorProtocol?) -> Void) {
        
        db.connect(info: connString) { (error, connection) -> Void in
            if error != nil {
                print(error)
            } else {
                print("Connected to the database!")
                
                let query = "SELECT * FROM 'todos' WHERE 'ownerid'='bob'"
                
                connection!.query(query: query) { (result, error) -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        print(result)
                        
                        oncompletion(1, nil)
                    }
                }
                
            }
        }
        
    }
    
    func clear(withUserID: String?, oncompletion: (ErrorProtocol?) -> Void) {
        
    }
    
    func clearAll(oncompletion: (ErrorProtocol?) -> Void) {
        
    }
    
    func get(withUserID: String?, oncompletion: ([TodoItem]?, ErrorProtocol?) -> Void) {
        
    }
    
    func get(withUserID: String?, withDocumentID: String, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
    }
    
    func add(userID: String?, title: String, order: Int, completed: Bool,
             oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
    }
    
    func update(documentID: String, userID: String?, title: String?, order: Int?,
                completed: Bool?, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
    }
    
    func delete(withUserID: String?, withDocumentID: String, oncompletion: (ErrorProtocol?) -> Void) {
        
    }
    
}