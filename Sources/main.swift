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

import Kitura
import HeliumLogger
import LoggerAPI
import TodoListWeb
import CloudFoundryEnv
import TodoListAPI

Log.logger = HeliumLogger()

//"credentials": {
//    "port": 50000,
//    "db": "BLUDB",
//    "username": "dash111703",
//    "ssljdbcurl": "jdbc:db2://awh-yp-small02.services.dal.bluemix.net:50001/BLUDB:sslConnection=true;",
//    "host": "awh-yp-small02.services.dal.bluemix.net",
//    "https_url": "https://awh-yp-small02.services.dal.bluemix.net:8443",
//    "dsn": "DATABASE=BLUDB;HOSTNAME=awh-yp-small02.services.dal.bluemix.net;PORT=50000;PROTOCOL=TCPIP;UID=dash111703;PWD=eb0b4bde1722;",
//    "hostname": "awh-yp-small02.services.dal.bluemix.net",
//    "jdbcurl": "jdbc:db2://awh-yp-small02.services.dal.bluemix.net:50000/BLUDB",
//    "ssldsn": "DATABASE=BLUDB;HOSTNAME=awh-yp-small02.services.dal.bluemix.net;PORT=50001;PROTOCOL=TCPIP;UID=dash111703;PWD=eb0b4bde1722;Security=SSL;",
//    "uri": "db2://dash111703:eb0b4bde1722@awh-yp-small02.services.dal.bluemix.net:50000/BLUDB",
//    "password": "eb0b4bde1722"
//}

extension DatabaseConfiguration {
    
    init(withService: Service) {
        if let credentials = withService.credentials{
            self.host = credentials["host"].stringValue
            self.username = credentials["username"].stringValue
            self.password = credentials["password"].stringValue
            self.port = UInt16(credentials["port"].stringValue)!
        } else {
            self.host = "127.0.0.1"
            self.username = "root"
            self.password = ""
            self.port = UInt16(50000)
        }
        self.options = ["test" : "test"]
    }
}

let databaseConfiguration: DatabaseConfiguration
let todos: TodoList

do {
    if let service = try CloudFoundryEnv.getAppEnv().getService(spec: "TodoList-MySQL"){
        Log.verbose("Found TodoList-MySQL")
        databaseConfiguration = DatabaseConfiguration(withService: service)
        todos = TodoList(databaseConfiguration)
    } else {
        Log.info("Could not find Bluemix MySQL service")
        todos = TodoList()
    }
    
    let controller = TodoListController(backend: todos)
    
    let port = try CloudFoundryEnv.getAppEnv().port
    Log.verbose("Assigned port is \(port)")
    
    Kitura.addHTTPServer(onPort: port, with: controller.router)
    Kitura.run()
    
} catch CloudFoundryEnvError.InvalidValue {
    Log.error("Oops... something went wrong. Server did not start.")
}
