# FBFS DCM Demo

Snowflake infrastructure as code with **DCM (Database Change Management)**, versioned in GitHub and promoted DEV → TEST with automation and approval.

## The one-sentence version

You describe the Snowflake objects you want in SQL files (`DEFINE TABLE ...`). DCM compares that to what exists in Snowflake and makes only the needed changes. GitHub stores the files, reviews changes, and runs DCM for you.

## Who does what

| Piece | Job |
|---|---|
| `sources/definitions/*.sql` | What should exist in Snowflake (DCM `DEFINE` syntax) |
| `manifest.yml` | DCM config: DEV and TEST targets, `{{env}}` swaps database names |
| `snow dcm plan` | DCM shows what would change. Changes nothing. |
| `snow dcm deploy` | DCM applies the changes, recorded under a version alias |
| `snow dcm test` | DCM runs the data quality expectations |
| `contracts/*.yml` | What we promise consumers about each view |
| `.github/workflows/pr.yml` | On every PR: DCM plan + contract check, posted as a PR comment |
| `.github/workflows/release.yml` | On a version tag: deploy DEV, then TEST after approval |

## Demo script

### Part 1: Version, deploy DEV → TEST, automation, approval

1. **Repo tour.** Show `policy.sql` (table), `serve.sql` (consumer view), `manifest.yml` (two targets, same files).
2. **Cut a release:** `git tag v2.0.0 && git push origin v2.0.0`
3. **Actions tab.** `dev` deploys automatically. `test` waits: *"Review deployments"* → Approve.
   - Talk track: *"Same tag, same files, two environments. Nobody can reach TEST without a reviewer."*
4. **Snowsight. Traceability:**
   ```sql
   SELECT * FROM FBL_POLICY_DEV.RAW.RELEASE_LOG  ORDER BY DEPLOYED_AT DESC;
   SELECT * FROM FBL_POLICY_TEST.RAW.RELEASE_LOG ORDER BY DEPLOYED_AT DESC;
   SHOW VERSIONS IN DCM PROJECT FBL_DEMO.DCM.POLICY_PROJECT_DEV;
   ```
   - Talk track: *"Every deployment points back to a git tag and commit."*

### Part 2: Nonbreaking change (compatibility)

Branch `demo/add-renewal-date`: add one column to `POLICY_V1` in `serve.sql`:
```sql
    STATUS,
    DATEADD(year, 1, ISSUE_DATE) AS RENEWAL_DATE
```
Open a PR. The bot comment shows:
- DCM plan: the view will be altered
- ✅ `RENEWAL_DATE` is new (non-breaking). Existing consumers are unaffected.

Merge, tag `v2.1.0`, promote.

### Part 3: Breaking change (detected)

Branch `demo/rename-premium`: in `POLICY_V1` change `PREMIUM_AMT,` to `PREMIUM_AMT AS ANNUAL_PREMIUM,`.
Open a PR. The check **fails** and the comment says:
- 🚨 `POLICY_V1.PREMIUM_AMT` was removed or renamed (consumers: POLICY_ANALYST, CLAIMS_APP)

Talk track: *"Caught at review time, before it reached any environment. The comment names who would break. That's consumer notification."*

### Part 4: Deprecation handling (the right way to make a breaking change)

On the same branch, undo the edit to `POLICY_V1` and instead:
1. Add a new view `POLICY_V2` in `serve.sql` with `ANNUAL_PREMIUM` (and grants).
2. Add `contracts/policy_v2.yml`.
3. In `contracts/policy_v1.yml` set:
   ```yaml
   status: deprecated
   sunset_date: 2027-03-31
   replaced_by: POLICY_V2
   ```
PR comment now shows: no breaking changes, `POLICY_V1` deprecated, consumers named, sunset date, replacement.
Talk track: *"V1 keeps working, V2 is available, consumers have a date to move. After the sunset date we delete V1 in a PR labeled `breaking-change`."*

## One-time setup (already done for this account)

- Snowflake: `FBL_DEMO.DCM` schema, roles `DCM_DEV_DEPLOYER` / `DCM_TEST_DEPLOYER`, warehouse `FBL_DEMO_WH`, consumer roles `POLICY_ANALYST` / `CLAIMS_APP`, service user `GITHUB_ACTIONS_SVC` (key pair) with network policy `GITHUB_ACTIONS_POLICY`.
- GitHub repo **Settings → Secrets and variables → Actions**: `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `SNOWFLAKE_PRIVATE_KEY`.
- GitHub **Settings → Environments**: create `dev` (no rules) and `test` (Required reviewers: you).
- GitHub **Issues → Labels**: create `breaking-change`.
