// Runs Contents/Resources/launch.sh and waits for it.
import Foundation

let script = Bundle.main.resourcePath! + "/launch.sh"
let task = Process()
task.executableURL = URL(fileURLWithPath: "/bin/bash")
task.arguments = [script]
try task.run()
task.waitUntilExit()
