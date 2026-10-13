-- =============================================================
-- post_deploy.sql — Seed data + release log entry
-- Run after `snow dcm deploy` via:
--   snow sql -f post_deploy.sql -D VERSION=$VERSION -D ENV=$ENV \
--     -D GIT_SHA=$GIT_SHA -D DEPLOYED_BY=$DEPLOYED_BY -c <conn>
--
-- NOTE: Companion scripts do NOT support Jinja.
--       We use Snowflake CLI's -D flag for variable substitution.
-- =============================================================

-- Seed ~50 realistic life insurance policies (only if table is empty)
INSERT INTO FBL_POLICY_&{ENV}.RAW.POLICY
    (POLICY_ID, POLICYHOLDER_NAME, PRODUCT_TYPE, ISSUE_DATE, PREMIUM_AMT, STATUS)
SELECT * FROM (
    SELECT column1, column2, column3, column4::DATE, column5, column6
    FROM VALUES
    (1001, 'Margaret A. Thompson',  'Whole Life',       '2018-03-15', 2450.00, 'ACTIVE'),
    (1002, 'James R. Henderson',    'Term Life 20yr',   '2019-07-22', 1180.00, 'ACTIVE'),
    (1003, 'Patricia L. Chen',      'Universal Life',   '2017-11-03', 3200.00, 'ACTIVE'),
    (1004, 'Robert W. Fitzgerald',  'Term Life 10yr',   '2020-01-10', 780.00,  'ACTIVE'),
    (1005, 'Linda S. Morales',      'Whole Life',       '2016-05-28', 2875.00, 'ACTIVE'),
    (1006, 'Michael D. Johansson',  'Variable Life',    '2021-09-14', 4100.00, 'ACTIVE'),
    (1007, 'Susan K. Blackwell',    'Term Life 30yr',   '2019-02-01', 1520.00, 'ACTIVE'),
    (1008, 'David E. Nakamura',     'Universal Life',   '2018-08-19', 2980.00, 'LAPSED'),
    (1009, 'Jennifer M. O''Brien',  'Whole Life',       '2015-12-07', 3450.00, 'ACTIVE'),
    (1010, 'William T. Gustafson',  'Term Life 20yr',   '2022-04-30', 1050.00, 'ACTIVE'),
    (1011, 'Karen A. Petrov',       'Whole Life',       '2017-06-11', 2650.00, 'ACTIVE'),
    (1012, 'Charles F. Dominguez',  'Variable Life',    '2020-10-25', 3750.00, 'ACTIVE'),
    (1013, 'Nancy J. Lindstrom',    'Term Life 10yr',   '2021-03-08', 690.00,  'CANCELLED'),
    (1014, 'Thomas B. Kaur',        'Universal Life',   '2019-01-17', 2800.00, 'ACTIVE'),
    (1015, 'Lisa G. Whitaker',      'Whole Life',       '2016-09-23', 3100.00, 'ACTIVE'),
    (1016, 'Christopher P. Okonkwo','Term Life 30yr',   '2022-07-05', 1480.00, 'ACTIVE'),
    (1017, 'Mary E. Van Der Berg',  'Variable Life',    '2018-04-12', 4250.00, 'ACTIVE'),
    (1018, 'Daniel L. Reeves',      'Term Life 20yr',   '2020-11-29', 1120.00, 'LAPSED'),
    (1019, 'Sandra H. Kowalski',    'Whole Life',       '2017-02-14', 2780.00, 'ACTIVE'),
    (1020, 'Paul J. Matsumoto',     'Universal Life',   '2021-06-19', 3050.00, 'ACTIVE'),
    (1021, 'Deborah R. Andersen',   'Term Life 10yr',   '2019-08-03', 820.00,  'ACTIVE'),
    (1022, 'Mark A. Fernandez',     'Whole Life',       '2015-10-21', 3600.00, 'ACTIVE'),
    (1023, 'Barbara C. Ivanova',    'Variable Life',    '2022-01-09', 3900.00, 'ACTIVE'),
    (1024, 'Steven D. Olsen',       'Term Life 30yr',   '2018-12-16', 1650.00, 'ACTIVE'),
    (1025, 'Dorothy M. Schwartz',   'Universal Life',   '2020-05-07', 2700.00, 'CANCELLED'),
    (1026, 'Andrew K. Takahashi',   'Whole Life',       '2017-07-30', 2950.00, 'ACTIVE'),
    (1027, 'Michelle L. Bergström', 'Term Life 20yr',   '2021-11-11', 1250.00, 'ACTIVE'),
    (1028, 'Joshua P. De Luca',     'Variable Life',    '2019-04-25', 4050.00, 'ACTIVE'),
    (1029, 'Amanda S. Krishnan',    'Whole Life',       '2016-01-18', 3350.00, 'ACTIVE'),
    (1030, 'Kevin R. Johansson',    'Term Life 10yr',   '2022-09-02', 750.00,  'ACTIVE'),
    (1031, 'Stephanie A. Novak',    'Universal Life',   '2018-06-14', 2850.00, 'ACTIVE'),
    (1032, 'Brian W. Yamamoto',     'Whole Life',       '2020-02-28', 2500.00, 'LAPSED'),
    (1033, 'Sharon E. Lindqvist',   'Term Life 30yr',   '2017-09-09', 1580.00, 'ACTIVE'),
    (1034, 'Jeffrey D. Okafor',     'Variable Life',    '2021-12-20', 3850.00, 'ACTIVE'),
    (1035, 'Donna G. Patel',        'Whole Life',       '2019-05-06', 2680.00, 'ACTIVE'),
    (1036, 'Timothy J. Eriksson',   'Term Life 20yr',   '2016-08-13', 1320.00, 'ACTIVE'),
    (1037, 'Cynthia M. Fontaine',   'Universal Life',   '2022-03-27', 3150.00, 'ACTIVE'),
    (1038, 'Jason L. Kapoor',       'Whole Life',       '2018-10-04', 2750.00, 'CANCELLED'),
    (1039, 'Angela B. Sorensen',    'Term Life 10yr',   '2020-07-21', 880.00,  'ACTIVE'),
    (1040, 'Scott H. Watanabe',     'Variable Life',    '2017-04-16', 4180.00, 'ACTIVE'),
    (1041, 'Kathleen P. Müller',    'Whole Life',       '2021-08-08', 2620.00, 'ACTIVE'),
    (1042, 'Gregory S. Desai',      'Term Life 30yr',   '2019-11-30', 1450.00, 'ACTIVE'),
    (1043, 'Diane C. Antonov',      'Universal Life',   '2016-03-12', 3280.00, 'ACTIVE'),
    (1044, 'Larry T. Nakagawa',     'Whole Life',       '2022-06-24', 2400.00, 'ACTIVE'),
    (1045, 'Marie F. Johansson',    'Variable Life',    '2018-01-19', 3950.00, 'LAPSED'),
    (1046, 'Henry A. Baptiste',     'Term Life 20yr',   '2020-09-15', 1150.00, 'ACTIVE'),
    (1047, 'Janet K. Kovačević',    'Whole Life',       '2017-12-01', 3020.00, 'ACTIVE'),
    (1048, 'Ryan M. Sato',          'Term Life 10yr',   '2021-04-17', 710.00,  'ACTIVE'),
    (1049, 'Carolyn D. Lindgren',   'Universal Life',   '2019-06-23', 2900.00, 'ACTIVE'),
    (1050, 'Roger B. Chowdhury',    'Whole Life',       '2016-11-08', 3500.00, 'ACTIVE')
) AS seed
WHERE NOT EXISTS (SELECT 1 FROM FBL_POLICY_&{ENV}.RAW.POLICY LIMIT 1);

-- Log this release
INSERT INTO FBL_POLICY_&{ENV}.RAW.RELEASE_LOG (VERSION, ENV, GIT_SHA, DEPLOYED_BY)
SELECT '&{VERSION}', '&{ENV}', '&{GIT_SHA}', '&{DEPLOYED_BY}';
