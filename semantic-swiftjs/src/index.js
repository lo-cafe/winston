import semver from "semver"
import xcode from "xcode"
import fs from "fs"

import executeGitCommand from "./executeGitCommand.js"
import generateCommitReport from "./getCommitMessages.js"
import processItems from "./gptChangelog.js"
import config from "../settings.json" assert { type: "json" }

const bundleIds = config.targets.reduce((acc, target) => {
  const targetBundleIds = config.branches.map((branch) => {
    if (branch.preReleaseLabel) {
      return `${config.companyBundleId}.${target}.${branch.preReleaseLabel}`
    }
    return `${config.companyBundleId}.${target}`
  })
  return acc.concat(targetBundleIds)
}, [])

function removeQuotes(str) {
  if (!str || typeof str !== "string") return ""
  return str.replace(/^"|"$/g, "")
}

executeGitCommand("git branch --show-current", (_, currBranch) => {
  const branchConfig = config.branches.find((b) => b.name === currBranch)
  if (!branchConfig || branchConfig.versionate === false) {
    return
  }
  const branchConfigIndex = config.branches.findIndex((b) => b.name === currBranch)

  const smallerBranchesLabels = config.branches
    .slice(branchConfigIndex + 1)
    // .filter((x) => x.versionate !== false)
    .map((x) => (x.preReleaseLabel ? x.preReleaseLabel : ""))

  generateCommitReport(async (report) => {
    // /^(feat|fix|docs|style|refactor|test|chore)(?:\((.*)\))?:(.*)$/,

    const projectPath = "../winston.xcodeproj/project.pbxproj"

    const project = xcode.project(projectPath).parse(async () => {
      const configSection = project.pbxXCBuildConfigurationSection()
      const versionsObj = {}
      const buildVersionsObj = {}
      Object.keys(configSection).forEach((key) => {
        const bundleId = removeQuotes(
          configSection[key].buildSettings && configSection[key].buildSettings.PRODUCT_BUNDLE_IDENTIFIER
        )
        if (bundleIds.includes(bundleId)) {
          const bundleIdSuffix = bundleId.split(".").pop()
          let preReleaseLabel = bundleIdSuffix

          if (config.targets.includes(bundleIdSuffix)) {
            preReleaseLabel = ""
          }

          buildVersionsObj[bundleId] = {
            buildVersion: configSection[key].buildSettings.CURRENT_PROJECT_VERSION,
            setBuildVersion: (newVer) => {
              configSection[key].buildSettings.CURRENT_PROJECT_VERSION = newVer
            },
          }

          versionsObj[bundleId] = {
            preReleaseLabel,
            version: removeQuotes(configSection[key].buildSettings.MARKETING_VERSION),
            setVersion: (newVer) => {
              configSection[key].buildSettings.MARKETING_VERSION = newVer
            },
          }
        }
      })

      const allVersionsSorted = Object.values(versionsObj)
        .filter((x) => x.preReleaseLabel == branchConfig.preReleaseLabel)
        .map((x) => x.version)
        .sort(semver.compare)
      let currentVersion = allVersionsSorted[allVersionsSorted.length - 1]

      const smallerVersionsConfigs = Object.values(versionsObj).filter((x) =>
        smallerBranchesLabels.includes(x.preReleaseLabel)
      )

      let newVersion = currentVersion

      if (report.feat) {
        newVersion = branchConfig.preReleaseLabel
          ? semver.inc(currentVersion, "preminor", branchConfig.preReleaseLabel, false)
          : semver.inc(currentVersion, "minor", false)
      } else if (report.fix || report.style) {
        newVersion = branchConfig.preReleaseLabel
          ? semver.inc(currentVersion, "prepatch", branchConfig.preReleaseLabel, false)
          : semver.inc(currentVersion, "patch", false)
      }

      if (newVersion === currentVersion) return

      const formattedReportFeat = await processItems(report.feat)
      const formattedReport = {...report, feat: formattedReportFeat}

      const currVer = Object.values(versionsObj).find(
        (x) => x.preReleaseLabel == branchConfig.preReleaseLabel
      )

      if (currVer) {
        currVer.setVersion(newVersion)
      }

      writeReportToChangelog(formattedReport, newVersion, branchConfig.preReleaseLabel)

      smallerVersionsConfigs.forEach((x) => {
        const smallerVersion = semver.inc(newVersion, "prerelease", x.preReleaseLabel, false)
        x.setVersion(smallerVersion)
        if (config.branches.find((y) => x.preReleaseLabel === y.preReleaseLabel).versionate !== false) {
          writeReportToChangelog(formattedReport, smallerVersion, x.preReleaseLabel)
        }
      })

      const highestBuildVersion = Math.max(...Object.values(buildVersionsObj).map((x) => x.buildVersion))

      Object.values(buildVersionsObj).forEach((x) => {
        x.setBuildVersion(highestBuildVersion + 1)
      })

      fs.writeFileSync(projectPath, project.writeSync())
      console.log("new project written")
    })
  })
})

function writeReportToChangelog(report, newVersion, preReleaseLabel) {
  const changelogFile = `./changelogs/${preReleaseLabel ? preReleaseLabel : "production"}.json`
  const fileContent = fs.readFileSync(changelogFile)
  const changelog = JSON.parse(fileContent)
  const foundChangelogIndex = changelog.findIndex((x) => x.version === newVersion)
  if (foundChangelogIndex !== -1) {
    changelog[foundChangelogIndex] = { version: newVersion, report }
  } else {
    changelog.unshift({ version: newVersion, timestamp: Date.now(), report })
  }
  fs.writeFileSync(changelogFile, JSON.stringify(changelog))
}
