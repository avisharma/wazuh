/*
 * SQL SCHEMA FOR VULNERABILITY DETECTOR MODULE
 * COPYRIGHT (C) 2015-2019, WAZUH INC.
 * JANUARY 28, 2018.
 * THIS PROGRAM IS A FREE SOFTWARE, YOU CAN REDISTRIBUTE IT
 * AND/OR MODIFY IT UNDER THE TERMS OF GPLV2.
 */

BEGIN;

CREATE TABLE IF NOT EXISTS AGENTS (
    AGENT_ID INT NOT NULL,
    TARGET_MAJOR TEXT,
    TARGET_MINOR TEXT,
    CPE_INDEX_ID INT DEFAULT 0,
    VENDOR TEXT,
    PACKAGE_NAME TEXT NOT NULL,
    VERSION TEXT NOT NULL,
    ARCH TEXT NOT NULL,
    PRIMARY KEY(AGENT_ID, VENDOR, PACKAGE_NAME, VERSION, ARCH)
);
CREATE INDEX IF NOT EXISTS IN_AG_ID ON AGENTS (AGENT_ID);
CREATE INDEX IF NOT EXISTS IN_AG_CPEID ON AGENTS (CPE_INDEX_ID);
CREATE INDEX IF NOT EXISTS IN_AG_VEN ON AGENTS (VENDOR);
CREATE INDEX IF NOT EXISTS IN_AG_PACK ON AGENTS (PACKAGE_NAME);
CREATE INDEX IF NOT EXISTS IN_AG_VER ON AGENTS (VERSION);
CREATE INDEX IF NOT EXISTS IN_AG_ARCH ON AGENTS (ARCH);
CREATE INDEX IF NOT EXISTS IN_AG_TARGET_MAJOR ON AGENTS (TARGET_MAJOR);
CREATE INDEX IF NOT EXISTS IN_AG_TARGET_MINOR ON AGENTS (TARGET_MINOR);

CREATE TABLE IF NOT EXISTS AGENT_HOTFIXES (
    AGENT_ID INT NOT NULL,
    HOTFIX TEXT NOT NULL,
    PRIMARY KEY(AGENT_ID, HOTFIX)
);
CREATE INDEX IF NOT EXISTS IN_AGH_ID ON AGENT_HOTFIXES (AGENT_ID);
CREATE INDEX IF NOT EXISTS IN_AGH_HOTFIX ON AGENT_HOTFIXES (HOTFIX);

 CREATE TABLE IF NOT EXISTS METADATA (
    TARGET TEXT PRIMARY KEY NOT NULL,
    PRODUCT_NAME TEXT NOT NULL,
    PRODUCT_VERSION TEXT,
    SCHEMA_VERSION TEXT,
    TIMESTAMP DATE NOT NULL
 );
 CREATE INDEX IF NOT EXISTS IN_MET_TARGET ON METADATA (TARGET);

 CREATE TABLE IF NOT EXISTS DB_METADATA (
    VERSION TEXT PRIMARY KEY NOT NULL
 );

 CREATE TABLE IF NOT EXISTS VULNERABILITIES_INFO (
    ID TEXT NOT NULL,
    TITLE TEXT,
    SEVERITY TEXT,
    PUBLISHED TEXT,
    UPDATED TEXT,
    REFERENCE TEXT,
    TARGET TEXT NOT NULL,
    RATIONALE TEXT,
    CVSS TEXT,
    CVSS_VECTOR TEXT,
    CVSS3 TEXT,
    BUGZILLA_REFERENCE TEXT,
    CWE TEXT,
    ADVISORIES TEXT,
    PRIMARY KEY(ID, TARGET)
 );
CREATE INDEX IF NOT EXISTS IN_VIN_CVE ON VULNERABILITIES_INFO (ID);
CREATE INDEX IF NOT EXISTS IN_VIN_TARGET ON VULNERABILITIES_INFO (TARGET);

CREATE TABLE IF NOT EXISTS VULNERABILITIES (
    CVEID TEXT NOT NULL REFERENCES VULNERABILITIES_INFO(ID),
    TARGET TEXT NOT NULL REFERENCES VULNERABILITIES_INFO(V_OS),
    TARGET_MINOR TEXT,
    PACKAGE TEXT NOT NULL,
    PENDING BOOLEAN NOT NULL,
    OPERATION TEXT NOT NULL,
    OPERATION_VALUE TEXT,
    CHECK_VARS INTEGER DEFAULT 0,
    PRIMARY KEY(CVEID, TARGET, TARGET_MINOR, PACKAGE, OPERATION_VALUE)
);
CREATE INDEX IF NOT EXISTS IN_VUL_PACK ON VULNERABILITIES (PACKAGE);
CREATE INDEX IF NOT EXISTS IN_VUL_CVEID ON VULNERABILITIES (CVEID);
CREATE INDEX IF NOT EXISTS IN_VUL_OP ON VULNERABILITIES (OPERATION);
CREATE INDEX IF NOT EXISTS IN_VUL_OP_VAL ON VULNERABILITIES (OPERATION_VALUE);
CREATE INDEX IF NOT EXISTS IN_VUL_TARGET ON VULNERABILITIES (TARGET);
CREATE INDEX IF NOT EXISTS IN_VUL_TARGET_MINOR ON VULNERABILITIES (TARGET_MINOR);

CREATE TABLE IF NOT EXISTS VARIABLES (
        VID TEXT NOT NULL,
        VALUE TEXT NOT NULL,
        TARGET TEXT NOT NULL,
        PRIMARY KEY(VID, VALUE, TARGET)
);
CREATE INDEX IF NOT EXISTS IN_VAR_ID ON VARIABLES (VID);
CREATE INDEX IF NOT EXISTS IN_VAR_VALUE ON VARIABLES (VALUE);
CREATE INDEX IF NOT EXISTS IN_VAR_TARGET ON VARIABLES (TARGET);

CREATE TABLE IF NOT EXISTS CPE_INDEX (
	ID INTEGER,
    POS INTEGER,
    PART TEXT NOT NULL,
    VENDOR TEXT NOT NULL,
    PRODUCT TEXT NOT NULL,
    VERSION TEXT NOT NULL,
    UPDATEV TEXT,
    EDITION TEXT,
    LANGUAGE TEXT,
    SW_EDITION TEXT,
    TARGET_SW TEXT,
    TARGET_HW TEXT,
    OTHER TEXT,
    MSU_NAME TEXT,
    PRIMARY KEY(ID, POS)
);
CREATE INDEX IF NOT EXISTS IN_CPE_ID ON CPE_INDEX (ID);
CREATE INDEX IF NOT EXISTS IN_CPE_PART ON CPE_INDEX (PART);
CREATE INDEX IF NOT EXISTS IN_CPE_VENDOR ON CPE_INDEX (VENDOR);
CREATE INDEX IF NOT EXISTS IN_CPE_PRODUCT ON CPE_INDEX (PRODUCT);
CREATE INDEX IF NOT EXISTS IN_CPE_VERSION ON CPE_INDEX (VERSION);
CREATE INDEX IF NOT EXISTS IN_CPE_UPDATEV ON CPE_INDEX (UPDATEV);
CREATE INDEX IF NOT EXISTS IN_CPE_EDITION ON CPE_INDEX (EDITION);
CREATE INDEX IF NOT EXISTS IN_CPE_LANGUAGE ON CPE_INDEX (LANGUAGE);
CREATE INDEX IF NOT EXISTS IN_CPE_SW_EDITION ON CPE_INDEX (SW_EDITION);
CREATE INDEX IF NOT EXISTS IN_CPE_TARGET_SW ON CPE_INDEX (TARGET_SW);
CREATE INDEX IF NOT EXISTS IN_CPE_TARGET_HW ON CPE_INDEX (TARGET_HW);
CREATE INDEX IF NOT EXISTS IN_CPE_OTHER ON CPE_INDEX (OTHER);

CREATE TABLE IF NOT EXISTS NVD_METADATA (
    YEAR INTEGER PRIMARY KEY,
    SIZE INTEGER,
    ZIP_SIZE INTEGER,
    GZ_SIZE INTEGER,
    SHA256 TEXT,
    LAST_MODIFIED INTEGER NOT NULL,
    CVES_NUMBER INTEGER,
    ALTERNATIVE INTEGER
);
CREATE INDEX IF NOT EXISTS IN_METADATA_LASTMOD ON NVD_METADATA (LAST_MODIFIED);
CREATE INDEX IF NOT EXISTS IN_METADATA_YEAR ON NVD_METADATA (YEAR);

CREATE TABLE IF NOT EXISTS NVD_CVE (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    NVD_METADATA_YEAR INTEGER,
    CVE_ID TEXT NOT NULL,
    CWE_ID TEXT,
    DESCRIPTION TEXT,
    PUBLISHED INTEGER,
    LAST_MODIFIED INTEGER
);
CREATE INDEX IF NOT EXISTS IN_NVD_CVE_ID ON NVD_CVE (ID);
CREATE INDEX IF NOT EXISTS IN_NVD_CVE_YEAR ON NVD_CVE (NVD_METADATA_YEAR);

CREATE TABLE IF NOT EXISTS NVD_METRIC_CVSS (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    NVD_CVE_ID INTEGER,
    VERSION TEXT,
    VECTOR_STRING TEXT,
    BASE_SCORE REAL,
    EXPLOITABILITY_SCORE REAL,
    IMPACT_SCORE REAL
);
CREATE INDEX IF NOT EXISTS IN_CVSS_NVDCVE_ID ON NVD_METRIC_CVSS (NVD_CVE_ID);

CREATE TABLE IF NOT EXISTS NVD_REFERENCE (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    NVD_CVE_ID INTEGER,
    URL TEXT,
    REF_SOURCE TEXT
);
CREATE INDEX IF NOT EXISTS IN_REF_NVDCVE_ID ON NVD_REFERENCE (NVD_CVE_ID);

CREATE TABLE IF NOT EXISTS NVD_CVE_CONFIGURATION (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    NVD_CVE_ID INTEGER,
    PARENT INTEGER DEFAULT 0,
    OPERATOR TEXT
);
CREATE INDEX IF NOT EXISTS IN_CONF_ID ON NVD_CVE_CONFIGURATION (ID);
CREATE INDEX IF NOT EXISTS IN_CONF_PARENT ON NVD_CVE_CONFIGURATION (PARENT);
CREATE INDEX IF NOT EXISTS IN_CONF_OPERATOR ON NVD_CVE_CONFIGURATION (OPERATOR);
CREATE INDEX IF NOT EXISTS IN_CONF_CVE_ID ON NVD_CVE_CONFIGURATION (NVD_CVE_ID);

CREATE TABLE IF NOT EXISTS NVD_CVE_MATCH (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    NVD_CVE_CONFIGURATION_ID INTEGER,
    ID_CPE INTEGER,
    VULNERABLE INTEGER,
    URI TEXT,
    VERSION_START_INCLUDING TEXT,
    VERSION_START_EXCLUDING TEXT,
    VERSION_END_INCLUDING TEXT,
    VERSION_END_EXCLUDING TEXT
);
CREATE INDEX IF NOT EXISTS IN_MATCH_ID ON NVD_CVE_MATCH (ID);
CREATE INDEX IF NOT EXISTS IN_MATCH_NVDCVE_ID ON NVD_CVE_MATCH (NVD_CVE_CONFIGURATION_ID);
CREATE INDEX IF NOT EXISTS IN_MATCH_ID_CPE ON NVD_CVE_MATCH (ID_CPE);
CREATE INDEX IF NOT EXISTS IN_MATCH_VULNERABLE ON NVD_CVE_MATCH (VULNERABLE);

CREATE TABLE IF NOT EXISTS NVD_CPE (
    ID INTEGER,
    PART TEXT NOT NULL,
    VENDOR TEXT,
    PRODUCT TEXT,
    VERSION TEXT,
    UPDATED TEXT,
    EDITION TEXT,
    LANGUAGE TEXT,
    SW_EDITION TEXT,
    TARGET_SW TEXT,
    TARGET_HW TEXT,
    OTHER TEXT,
    PRIMARY KEY(PART, VENDOR, PRODUCT, VERSION, UPDATED, EDITION, LANGUAGE, SW_EDITION, TARGET_SW, TARGET_HW, OTHER)
);
CREATE INDEX IF NOT EXISTS IN_NVD_CPE_ID ON NVD_CPE (ID);
CREATE INDEX IF NOT EXISTS IN_NVD_CPE_PART ON NVD_CPE (PART);
CREATE INDEX IF NOT EXISTS IN_NVD_CPE_VENDOR ON NVD_CPE (VENDOR);
CREATE INDEX IF NOT EXISTS IN_NVD_CPE_PRODUCT ON NVD_CPE (PRODUCT);
CREATE INDEX IF NOT EXISTS IN_NVD_CPE_VERSION ON NVD_CPE (VERSION);
CREATE INDEX IF NOT EXISTS IN_NVD_CPE_UPDATED ON NVD_CPE (UPDATED);
CREATE INDEX IF NOT EXISTS IN_NVD_CPE_EDITION ON NVD_CPE (EDITION);
CREATE INDEX IF NOT EXISTS IN_NVD_CPE_LANGUAGE ON NVD_CPE (LANGUAGE);
CREATE INDEX IF NOT EXISTS IN_NVD_CPE_SW_EDITION ON NVD_CPE (SW_EDITION);
CREATE INDEX IF NOT EXISTS IN_NVD_CPE_TARGET_SW ON NVD_CPE (TARGET_SW);
CREATE INDEX IF NOT EXISTS IN_NVD_CPE_TARGET_HW ON NVD_CPE (TARGET_HW);
CREATE INDEX IF NOT EXISTS IN_NVD_CPE_OTHER ON NVD_CPE (OTHER);

CREATE TABLE IF NOT EXISTS CPE_HELPER (
    ID INTEGER PRIMARY KEY,
    TARGET TEXT,
    ACTION INT
);
CREATE INDEX IF NOT EXISTS IN_CPE_HELPER ON CPE_HELPER (ID);
CREATE INDEX IF NOT EXISTS IN_CPE_HELPER_ACTION ON CPE_HELPER (ACTION);

CREATE TABLE IF NOT EXISTS CPE_HELPER_SOURCE (
    ID_HELPER INTEGER,
    CORRELATION_ID INTEGER,
    TYPE TEXT NOT NULL,
    TERM TEXT,
    PRIMARY KEY(ID_HELPER, TYPE, TERM)
);
CREATE INDEX IF NOT EXISTS IN_CPE_SOURCE_ID ON CPE_HELPER_SOURCE (ID_HELPER);
CREATE INDEX IF NOT EXISTS IN_CPE_SOURCE_COR_ID ON CPE_HELPER_SOURCE (CORRELATION_ID);
CREATE INDEX IF NOT EXISTS IN_CPE_SOURCE_TYPE ON CPE_HELPER_SOURCE (TYPE);
CREATE INDEX IF NOT EXISTS IN_CPE_SOURCE_TERM ON CPE_HELPER_SOURCE (TERM);

CREATE TABLE IF NOT EXISTS CPE_HELPER_TRANSLATION (
    ID_HELPER INTEGER,
    CORRELATION_ID INTEGER,
    TYPE TEXT NOT NULL,
    TERM TEXT NOT NULL,
    COMPARE_FIELD TEXT,
    CONDITION TEXT,
    PRIMARY KEY(ID_HELPER, TYPE, TERM, COMPARE_FIELD, CONDITION)
);
CREATE INDEX IF NOT EXISTS IN_CPE_TRANSLATION_ID ON CPE_HELPER_TRANSLATION (ID_HELPER);
CREATE INDEX IF NOT EXISTS IN_CPE_TRANSLATION_COR_ID ON CPE_HELPER_TRANSLATION (CORRELATION_ID);
CREATE INDEX IF NOT EXISTS IN_CPE_TRANSLATION_TYPE ON CPE_HELPER_TRANSLATION (TYPE);
CREATE INDEX IF NOT EXISTS IN_CPE_TRANSLATION_TERM ON CPE_HELPER_TRANSLATION (TERM);
CREATE INDEX IF NOT EXISTS IN_CPE_TRANSLATION_COND ON CPE_HELPER_TRANSLATION (CONDITION);

CREATE TABLE IF NOT EXISTS MSU (
    CVEID TEXT NOT NULL,
    PRODUCT TEXT NOT NULL,
    PATCH TEXT NOT NULL,
    TITLE TEXT,
    URL TEXT,
    SUBTYPE TEXT,
    RESTART_REQUIRED TEXT,
    PRIMARY KEY(CVEID, PRODUCT, PATCH)
);
CREATE INDEX IF NOT EXISTS IN_MSU_CVEID ON MSU (CVEID);
CREATE INDEX IF NOT EXISTS IN_MSU_PRODUCT ON MSU (PRODUCT);

DELETE FROM DB_METADATA;

END;
