import semver from "semver";
import xcode from "xcode";
import fs from "fs";

import executeGitCommand from "./executeGitCommand.js";
import generateCommitReport from "./getCommitMessages.js";
import config from "../settings.json" assert { type: 'json' };

const bundleIds = config.targets.reduce((acc, target) => {
  const targetBundleIds = config.branches.map((branch) => {
    if (branch.label) {
      return `${config.companyBundleId}.${target}.${branch.label}`;
    }
    return `${config.companyBundleId}.${target}`;
  });
  return acc.concat(targetBundleIds);
}, []);

function removeQuotes(str) {
  if (!str || typeof str !== "string") return "";
  return str.replace(/^"|"$/g, "");
}

executeGitCommand("git branch --show-current", (_, currBranch) => {
  const branchConfig = config.branches.find((b) => b.name === currBranch);
  if (!branchConfig) {
    return;
  }
  const branchConfigIndex = config.branches.findIndex(
    (b) => b.name === currBranch,
  );

  generateCommitReport(async (report) => {
    // /^(feat|fix|docs|style|refactor|test|chore)(?:\((.*)\))?:(.*)$/,

    const projectPath = "../../winston.xcodeproj/project.pbxproj";

    const project = xcode.project(projectPath).parse(() => {
      const config = project.pbxXCBuildConfigurationSection();
      const versionsObj = {};
      Object.keys(config).forEach((key) => {
        const bundleId = removeQuotes(
          config[key].buildSettings &&
            config[key].buildSettings.PRODUCT_BUNDLE_IDENTIFIER,
        );
        if (bundleIds.includes(bundleId)) {
          versionsObj[bundleId] = {
            version: config[key].buildSettings.MARKETING_VERSION,
            setVersion: (newVer) => {
              config[key].buildSettings.MARKETING_VERSION = newVer;
            },
          };
        }
      });

      const currentVersion = `${config.companyBundleId}.`

      if (report.feat) {
        // console.log(await processItems(report.feat));
      } else if (report.fix || report.style) {
      }

      versionsObj["lo.cafe.winston"].setVersion("1.2.3");

      fs.writeFileSync(projectPath, project.writeSync());
      console.log("new project written");
      // console.log(releaseScheme);
    });

    // await processItems(report.feat)
  });
});
