const { exec } = require("child_process");

// Function to execute git commands
function executeGitCommand(command, callback) {
  exec(command, (error, stdout, stderr) => {
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

// Organize commit messages by their prefix
function organizeCommitsByPrefix(commitMessages) {
  const organizedCommits = {};

  commitMessages.forEach((commitMessage) => {
    const match = commitMessage.match(
      /^(feat|fix|docs|style|refactor|test|chore)(?:\((.*)\))?:(.*)$/,
    );
    if (match) {
      const [, type, scope, subject] = match;
      if (!organizedCommits[type]) {
        organizedCommits[type] = [];
      }
      organizedCommits[type].push({ scope, subject: subject.trim() });
    } else {
      // Handle commits without a known prefix
      if (!organizedCommits["others"]) {
        organizedCommits["others"] = [];
      }
      organizedCommits["others"].push({ subject: commitMessage.trim() });
    }
  });

  return organizedCommits;
}

// Main function
function generateCommitReport() {
  // First, find the last tag name
  executeGitCommand("git describe --tags --abbrev=0", (error, lastTagName) => {
    if (error) {
      console.log("Could not determine the last tag name.");
      return;
    }

    // Then, retrieve commit messages since the last tag
    executeGitCommand(
      `git log ${lastTagName}..HEAD --pretty=format:"%s"`,
      (error, stdout) => {
        if (error) {
          console.log("Could not retrieve commit messages.");
          return;
        }

        const commitMessages = stdout
          .split("\n")
          .filter((msg) => msg.trim() !== "");
        const organizedCommits = organizeCommitsByPrefix(commitMessages);

        console.log(JSON.stringify(organizedCommits, null, 2));
      },
    );
  });
}

// Execute the main function
generateCommitReport();
