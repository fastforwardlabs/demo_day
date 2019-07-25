-- Impala SQL script to create tables in the arcos database

-- Ian Cook
-- 2019-07-25

CREATE DATABASE arcos;

CREATE EXTERNAL TABLE arcos.arcos_text
		(reporter_dea_no STRING,
		reporter_bus_act STRING,
		reporter_name STRING,
		reporter_addl_co_info STRING,
		reporter_address1 STRING,
		reporter_address2 STRING,
		reporter_city STRING,
		reporter_state STRING,
		reporter_zip STRING,
		reporter_county STRING,
		buyer_dea_no STRING,
		buyer_bus_act STRING,
		buyer_name STRING,
		buyer_addl_co_info STRING,
		buyer_address1 STRING,
		buyer_address2 STRING,
		buyer_city STRING,
		buyer_state STRING,
		buyer_zip STRING,
		buyer_county STRING,
		transaction_code STRING,
		drug_code STRING,
		ndc_no STRING,
		drug_name STRING,
		quantity DECIMAL(6,1),
		unit STRING,
		action_indicator STRING,
		order_form_no STRING,
		correction_no STRING,
		strength STRING,
		transaction_date STRING,
		calc_base_wt_in_gm FLOAT,
		dosage_unit FLOAT,
		transaction_id STRING,
		product_name STRING,
		ingredient_name STRING,
		measure STRING,
		mme_conversion_factor FLOAT,
		combined_labeler_name STRING,
		revised_company_name STRING,
		reporter_family STRING,
		dos_str FLOAT)
	ROW FORMAT DELIMITED
		FIELDS TERMINATED BY '\t'
	TBLPROPERTIES ('skip.header.line.count'='1','serialization.null.format'='null');

CREATE EXTERNAL TABLE arcos.arcos
	STORED AS PARQUET
	AS SELECT * FROM arcos.arcos_text;

DROP TABLE arcos.arcos_text PURGE;

COMPUTE STATS arcos.arcos;

CREATE EXTERNAL TABLE arcos.arcos_clean
		(reporter_dea_no CHAR(9),
		reporter_bus_act STRING,
		reporter_name STRING,
		reporter_addl_co_info STRING,
		reporter_address1 STRING,
		reporter_address2 STRING,
		reporter_city STRING,
		reporter_state CHAR(2),
		reporter_zip CHAR(5),
		reporter_county STRING,
		buyer_dea_no CHAR(9),
		buyer_bus_act STRING,
		buyer_name STRING,
		buyer_addl_co_info STRING,
		buyer_address1 STRING,
		buyer_address2 STRING,
		buyer_city STRING,
		buyer_state CHAR(2),
		buyer_zip CHAR(5),
		buyer_county STRING,
		transaction_code CHAR(1),
		drug_code CHAR(4),
		ndc_no STRING,
		drug_name STRING,
		quantity DECIMAL(6,1),
		unit STRING,
		action_indicator STRING,
		order_form_no STRING,
		correction_no STRING,
		strength STRING,
		transaction_date STRING,
		calc_base_wt_in_gm FLOAT,
		dosage_unit FLOAT,
		transaction_id STRING,
		product_name STRING,
		ingredient_name STRING,
		measure CHAR(3),
		mme_conversion_factor FLOAT,
		combined_labeler_name STRING,
		revised_company_name STRING,
		reporter_family STRING,
		dos_str FLOAT)
	STORED AS PARQUET;

INSERT OVERWRITE arcos_clean SELECT CAST(reporter_dea_no AS CHAR(9)) AS reporter_dea_no,
	reporter_bus_act, reporter_name, reporter_addl_co_info, reporter_address1,
	reporter_address2, reporter_city, CAST(reporter_state AS CHAR(2)) AS reporter_state,
	CAST(lpad(reporter_zip, 5, "0") AS CHAR(5)) AS reporter_zip, reporter_county, 
	CAST(buyer_dea_no AS CHAR(9)) AS buyer_dea_no, buyer_bus_act, buyer_name, buyer_addl_co_info, buyer_address1,
	buyer_address2, buyer_city, CAST(buyer_state AS CHAR(2)) AS buyer_state,
	CAST(lpad(buyer_zip, 5, "0") AS CHAR(5)) AS buyer_zip,
	CASE
		WHEN buyer_county IS NOT NULL THEN buyer_county 
		WHEN buyer_city = "EVANSVILLE" AND buyer_state = "IN" THEN "VANDERBURGH"
		WHEN buyer_city = "BROCKTON" AND buyer_state = "MA" THEN "PLYMOUTH"
		WHEN buyer_city = "ORANGE" AND buyer_state = "CA" THEN "ORANGE"
		WHEN buyer_city = "BAYAMON" AND buyer_state = "PR" THEN "BAYAMON"
		WHEN buyer_city = "LAVONIA" AND buyer_state = "GA" THEN "FRANKLIN"
		WHEN buyer_city = "NORTH LAS VEGAS" AND buyer_state = "NV" THEN "CLARK"
		WHEN buyer_city = "ARLINGTON" AND buyer_state = "MA" THEN "MIDDLESEX"
		WHEN buyer_city = "TOA ALTA" AND buyer_state = "PR" THEN "TOA ALTA"
		WHEN buyer_city = "CAIRO" AND buyer_state = "GA" THEN "GRADY"
		WHEN buyer_city = "IRVINE" AND buyer_state = "CA" THEN "ORANGE"
		WHEN buyer_city = "KENT" AND buyer_state = "IA" THEN "UNION"
		WHEN buyer_city = "CIDRA" AND buyer_state = "PR" THEN "CIDRA"
		WHEN buyer_city = "ELLINGTON" AND buyer_state = "CT" THEN "TOLLAND"
		WHEN buyer_city = "INDIAN ROCKS BEACH" AND buyer_state = "FL" THEN "PINELLAS"
		WHEN buyer_city = "FAIRFIELD" AND buyer_state = "CT" THEN "FAIRFIELD"
		WHEN buyer_city = "PRINCETON" AND buyer_state = "IN" THEN "GIBSON"
		WHEN buyer_city = "AKRON" AND buyer_state = "OH" THEN "SUMMIT"
		WHEN buyer_city = "LAS PIEDRAS" AND buyer_state = "PR" THEN "LAS PIEDRAS"
		ELSE NULL
	END AS buyer_county,
	CAST(transaction_code AS CHAR(1)) AS transaction_code, CAST(drug_code AS CHAR(4)) AS drug_code, ndc_no, drug_name,
	quantity, unit, action_indicator, order_form_no, correction_no, strength, transaction_date,
	calc_base_wt_in_gm, dosage_unit, transaction_id, product_name, ingredient_name,
	CAST(measure AS CHAR(3)) AS measure, mme_conversion_factor, combined_labeler_name, revised_company_name,
	reporter_family, dos_str
	FROM arcos
	WHERE buyer_state NOT IN ("AE","GU","PW","MP","VI");

COMPUTE STATES arcos.arcos_clean;

CREATE EXTERNAL TABLE arcos.population_by_county
		(fips CHAR(5),
		county STRING,
		state CHAR(2),
		population INTEGER)
	ROW FORMAT DELIMITED
		FIELDS TERMINATED BY ',';

CREATE EXTERNAL TABLE arcos.population_by_zcta
		(zcta CHAR(5),
		population INTEGER)
	ROW FORMAT DELIMITED
		FIELDS TERMINATED BY ',';

CREATE EXTERNAL TABLE arcos.buyers_to_exclude
  (buyer_dea_no CHAR(9));
 
