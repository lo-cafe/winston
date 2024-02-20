import semver from "semver";
import processItems from "./gptChangelog.js";

// console.log(semver.inc("1.2.3", "patch")); // 1.2.4

import generateCommitReport from "./getCommitMessages.js";

generateCommitReport(async (report) => {
  if (report.feat) {
    console.log(await processItems(report.feat));
  }
  //  /^(feat|fix|docs|style|refactor|test|chore)(?:\((.*)\))?:(.*)$/,

  // if (report.feat) {
  //   console.log(await processItems(report.feat));
  // } else if (report.fix || report.style)
});
