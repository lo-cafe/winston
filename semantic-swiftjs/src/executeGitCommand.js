import { exec } from "child_process";

// Function to execute git commands
export default function executeGitCommand(command, callback) {
  exec(command, { maxBuffer: 1024 * 1024 * 10 }, (error, stdout, stderr) => {
    // Increase maxBuffer for large outputs
    if (error) {
      console.error(`exec error: ${error}`);
      callback(error, null);
    } else if (stderr) {
      console.error(`stderr: ${stderr}`);
      callback(stderr, null);
    } else {
      callback(null, stdout.trim());
    }
  });
}
