-- Producer side: where policy data lives.

DEFINE DATABASE FBL_POLICY_{{env}}
    COMMENT = '{{env}} environment - FBL life insurance policy data';

DEFINE SCHEMA FBL_POLICY_{{env}}.RAW
    COMMENT = 'Source data';

DEFINE SCHEMA FBL_POLICY_{{env}}.SERVE
    COMMENT = 'Consumer-facing views (the contract)';

DEFINE TABLE FBL_POLICY_{{env}}.RAW.POLICY (
    POLICY_ID         NUMBER       NOT NULL,
    POLICYHOLDER_NAME VARCHAR(200) NOT NULL,
    PRODUCT_TYPE      VARCHAR(50)  NOT NULL,
    ISSUE_DATE        DATE         NOT NULL,
    PREMIUM_AMT       NUMBER(12,2) NOT NULL,
    STATUS            VARCHAR(30)  NOT NULL DEFAULT 'ACTIVE'
)
CHANGE_TRACKING = TRUE
DATA_METRIC_SCHEDULE = 'TRIGGER_ON_CHANGES'
COMMENT = 'Life insurance policies';

-- Traceability: one row per release, written by post_deploy.sql
DEFINE TABLE FBL_POLICY_{{env}}.RAW.RELEASE_LOG (
    VERSION     VARCHAR(50) NOT NULL,
    ENV         VARCHAR(10) NOT NULL,
    GIT_SHA     VARCHAR(40),
    DEPLOYED_BY VARCHAR(100),
    DEPLOYED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Deployment history';

-- Data quality: DCM test fails the pipeline if these are violated
ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    TO TABLE FBL_POLICY_{{env}}.RAW.POLICY
    ON (POLICY_ID)
    EXPECTATION NO_NULL_POLICY_ID (value = 0);

ATTACH DATA METRIC FUNCTION SNOWFLAKE.CORE.DUPLICATE_COUNT
    TO TABLE FBL_POLICY_{{env}}.RAW.POLICY
    ON (POLICY_ID)
    EXPECTATION NO_DUPLICATE_POLICY_ID (value = 0);
