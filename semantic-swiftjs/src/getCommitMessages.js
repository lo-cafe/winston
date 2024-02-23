import executeGitCommand from "./executeGitCommand.js";

// Organize commit messages by their prefix
function organizeCommitsByPrefix(commitMessages) {
  const organizedCommits = {};

  commitMessages.forEach((rawCommit) => {
    const [firstLine, description] = rawCommit
      .split("---DETAILS---")
      .map((part) => part.trim());
    const match = firstLine.match(
      /^(feat|fix|docs|style|refactor|test|chore)(?:\((.*)\))?:(.*)$/,
    );
    if (match) {
      const [, type, scope, subject] = match;
      if (!organizedCommits[type]) {
        organizedCommits[type] = [];
      }
      organizedCommits[type].push({
        scope,
        subject: subject.trim(),
        description: description || "",
      });
    } else {
      // Handle commits without a known prefix
      if (!organizedCommits["others"]) {
        organizedCommits["others"] = [];
      }
      organizedCommits["others"].push({
        subject: firstLine.trim(),
        description: description || "",
      });
    }
  });

  return organizedCommits;
}

// Main function
export default function generateCommitReport(cb) {
  // First, find the last tag name
  executeGitCommand("git describe --tags --abbrev=0", (error, lastTagName) => {
    if (error) {
      console.log("Could not determine the last tag name.");
      return;
    }

    // Then, retrieve commit messages since the last tag including descriptions
    executeGitCommand(
      `git log ${lastTagName}..HEAD --pretty=format:"%s---DETAILS---%n%b---COMMITEND---"`,
      (error, stdout) => {
        if (error) {
          console.log("Could not retrieve commit messages.");
          return;
        }

        // Splitting commits using a custom delimiter ("---COMMITEND---")
        const commitDelim = "---COMMITEND---";
        const commitMessages = stdout
          .split(commitDelim)
          .filter((msg) => msg.trim() !== "");
        const organizedCommits = organizeCommitsByPrefix(commitMessages);

        if (cb) cb(organizedCommits);
      },
    );
  });
}
