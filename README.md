# TodoList DB2 backend

[![Swift 3 6-06](https://img.shields.io/badge/Swift%203-6/20 SNAPSHOT-blue.svg)](https://swift.org/download/#snapshots)

> A [Swift DB2](https://github.com/IBM-DTeam/swift-for-db2) implementation of the TodoList backend

## Quick start:

1. Download and install the Swift 6-20 DEVELOPMENT snapshot
2. Install dependencies with Homebrew

  `brew install wget unixodbc`
  
3. Install the DB2 system driver:

  `wget https://github.com/IBM-DTeam/swift-for-db2-cli/archive/master.zip && unzip master.zip && cd swift-for-db2-cli-master && sudo ./cli.sh && . env.sh && cd .. && rm -f master.zip && rm -rf swift-for-db2-cli-master`
  
4. Clone the repository:
 
  `git clone https://github.com/IBM-Swift/todolist-db2`

5. Clone the test cases

  `git clone https://github.com/IBM-Swift/todolist-tests Tests`
  
6. Compile the library

  `swift build -Xcc -I/usr/local/include -Xlinker -L/usr/local/lib`
  
7. Run the test cases with swift test

  `swift test`
  




