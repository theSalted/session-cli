//#!/usr/bin/env swift

import Foundation

var intent: String?
var duration: Int?
var categoryName: String?
var notes : String?
var scheme: Scheme = .start
// Add other parameters as needed

// Parse the command line arguments
let arguments = CommandLine.arguments
var i = 1
while i < arguments.count {
    let argument = arguments[i]
    switch argument {
    case "finish", "-F", "-f":
        scheme = .finish // Stop on going session
    case "repeat", "-R", "-r":
        scheme = .startPrevious
    case "pause", "-P", "-p":
        scheme = .togglePause
    case "break", "-B", "-b":
        scheme = .takeBreak
    case "quit", "-Q", "-q":
        scheme = .abandon
    case "--intent", "-I", "-i":
        intent = arguments[i+1]
        i += 1
    case "--duration", "-D", "-d":
        duration = Int(arguments[i+1])
        i += 1
    case "--category", "-C", "-c":
        categoryName = arguments[i+1]
        i += 1
    case "--notes", "-N", "-n":
        notes = arguments[i+1]
        i += 1
    case "help", "--help", "-H", "-h":
        printHelp()
    // Add other cases as needed
    default:
        printHelp()
        break
    }
    i += 1
}

switch scheme {
case .start:
    startSession(intent: intent, duration: duration, categoryName: categoryName, notes: notes)
case .startPrevious:
    startPreviousSession() 
case .finish:
    finishSession()
case .takeBreak:
    takeBreak()
case .togglePause:
    togglePause()
case .abandon:
    abandonSession()
}

enum Scheme {
    case start, startPrevious, finish, takeBreak, togglePause, abandon
}

func startSession(intent: String?, duration: Int?, categoryName: String?, notes: String?) {
    // Construct the URL
    var urlComponents = URLComponents(string: "session:///start")

    var queryItems = [URLQueryItem]()

    if let intent = intent {
        queryItems.append(URLQueryItem(name: "intent", value: intent))
    }
    if let duration = duration {
        queryItems.append(URLQueryItem(name: "duration", value: "\(duration)"))
    }
    if let categoryName = categoryName {
        queryItems.append(URLQueryItem(name: "categoryName", value: categoryName))
    }
    if let notes = notes {
        queryItems.append(URLQueryItem(name: "notes", value: notes))
    }
    // Add other parameters as needed

    urlComponents?.queryItems = queryItems
    runURLComponents(with: urlComponents)
}

func startPreviousSession() {
    // Construct the URL
    let urlComponents = URLComponents(string: "session:///start-previous")
    runURLComponents(with: urlComponents)
}

func togglePause() {
    // Construct the URL
    let urlComponents = URLComponents(string: "session:///pause")
    runURLComponents(with: urlComponents)
}

func takeBreak() {
    // Construct the URL
    let urlComponents = URLComponents(string: "session:///break")
    runURLComponents(with: urlComponents)
}

func finishSession() {
    // Construct the URL
    let urlComponents = URLComponents(string: "session:///finish")
    runURLComponents(with: urlComponents)
}

func abandonSession() {
    // Construct the URL
    let urlComponents = URLComponents(string: "session:///abandon")
    runURLComponents(with: urlComponents)
}

func runURLComponents(with urlComponents: URLComponents?) {
    // Open the URL using Process
    if let url = urlComponents?.url, let encodedURL = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = [encodedURL]

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            print("Failed to open URL: \(error)")
        }
    } else {
        print("Invalid URL")
    }

}

func printHelp() {
    let helpString = """
    Usage: session [options]

    Options:
      finish, -f        Stop the ongoing session.
      repeat, -r        Start the previous session.
      pause, -p         Toggle pause for the current session.
      break, -b         Take a break.
      quit, -q          Abandon the current session.

      --intent, -i      Set the intent for the session. Requires a following argument with the intent description.
      --duration, -d    Set the duration of the session in minutes. Requires a following argument with the duration as an integer.
      --category, -c    Specify the category by name. Requires a following argument with the category name.
      --notes, -n       Add initial notes to the session. Requires a following argument with the notes content.

    Examples:
      session -i \"Work on project\" -d 25 -c \"Development\" -n \"Focus on coding\"
      session -f   // Stops the ongoing session
      session -r   // Repeats the previous session
      session -p   // Toggles pause on the current session
      session -b   // Takes a break
      session -q   // Abandons the current session

    Note: Options can be combined as needed.
    """

    // You can then print this string when the user enters a help command or an invalid command.
    print(helpString)
}
