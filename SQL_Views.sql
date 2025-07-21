-- Select the database
use synthea_db;

-- View combining encounter, patient, provider, and organization info with temporal features and geolocation
CREATE OR REPLACE VIEW v_encounters_base AS
SELECT 
    e.id AS encounter_id,
    e.patient_id,
    p.gender,
    TIMESTAMPDIFF(YEAR, p.birth_date, '2021-12-31') AS age_in_2021,
    p.address AS patient_address,
    p.city AS patient_city,
    p.lat AS patient_lat,
    p.lon AS patient_lon,
    e.start_date,
    YEAR(e.start_date) AS year,
    QUARTER(e.start_date) AS quarter,
    MONTH(e.start_date) AS month,
    e.encounter_class,
    e.total_claim_cost,
    pr.id AS provider_id,
    pr.specialty,
    o.id AS organization_id,
    o.organization_name,
    o.lat,
    o.lon
FROM encounters e
JOIN patients p ON e.patient_id = p.id
JOIN providers pr ON e.provider_id = pr.id
JOIN organizations o ON e.organization_id = o.id;

-- View for analyzing claim transactions with patient insurance status and age grouping
CREATE OR REPLACE VIEW v_claim_transaction_base AS
SELECT
    ct.provider_id,
    p.provider_name,
    ct.claim_type,
    YEAR(ct.start_date) AS year,
    MONTH(ct.start_date) AS month,
    CAST(ct.amount AS DECIMAL(10, 2)) AS amount,
    CASE 
        WHEN ct.patient_insurance_id IS NULL OR ct.patient_insurance_id = '' THEN 'Uninsured'
        ELSE 'Insured'
    END AS insurance_status,
    ct.patient_id,
    pm.birth_date,
    TIMESTAMPDIFF(YEAR, pm.birth_date, DATE('2021-12-31')) AS age_2021,
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, pm.birth_date, DATE('2021-12-31')) < 30 THEN 'Under 30'
        WHEN TIMESTAMPDIFF(YEAR, pm.birth_date, DATE('2021-12-31')) BETWEEN 30 AND 60 THEN '30–60'
        WHEN TIMESTAMPDIFF(YEAR, pm.birth_date, DATE('2021-12-31')) > 60 THEN 'Over 60'
        ELSE 'Unknown'
    END AS age_group
FROM claim_transaction ct
JOIN providers p ON ct.provider_id = p.id
LEFT JOIN patients pm ON ct.patient_id = pm.id
WHERE ct.amount IS NOT NULL;

-- View of observations enriched with age groupings and numeric value parsing
CREATE OR REPLACE VIEW v_observations_base AS
SELECT
  o.id AS observation_id,
  o.patient_id,
  pm.gender,
  pm.birth_date,
  o.date AS observation_date,
  YEAR(o.date) AS observation_year,
  -- New age relative to 2021-12-31
  TIMESTAMPDIFF(YEAR, pm.birth_date, DATE('2021-12-31')) AS age_2021,
  CASE 
    WHEN TIMESTAMPDIFF(YEAR, pm.birth_date, DATE('2021-12-31')) < 30 THEN 'Under 30'
    WHEN TIMESTAMPDIFF(YEAR, pm.birth_date, DATE('2021-12-31')) BETWEEN 30 AND 60 THEN '30–60'
    ELSE 'Over 60'
  END AS age_group_2021,
  o.observation_desc,
  o.observation_type,
  o.value,
  CAST(o.value AS DECIMAL(10,2)) AS value_numeric
FROM observations o
JOIN patients pm ON o.patient_id = pm.id
WHERE o.value IS NOT NULL;

-- View for medication records with filtering on base cost, dispenses, and valid start dates
CREATE OR REPLACE VIEW v_medications_base AS
SELECT
  m.id AS medication_id,
  m.patient_id,
  pm.gender,
  pm.ethnicity,
  pm.birth_date,
  p.payer_name,
  m.medication_desc,
  m.base_cost,
  m.total_cost,
  m.payer_coverage,
  m.dispenses,
  m.start_date,
  YEAR(m.start_date) AS medication_year
FROM medications m
JOIN patients pm ON m.patient_id = pm.id
JOIN payers p ON m.payer_id = p.id
WHERE m.base_cost IS NOT NULL
  AND m.dispenses IS NOT NULL
  AND m.start_date IS NOT NULL;

-- View listing procedures with patient demographics and filtering on valid procedure descriptions
CREATE OR REPLACE VIEW v_procedures_base AS
SELECT
  pr.procedure_desc,
  pr.start_date,
  YEAR(pr.start_date) AS procedure_year,
  pr.patient_id,
  pm.gender,
  pm.birth_date
FROM procedures pr
JOIN patients pm ON pr.patient_id = pm.id
WHERE pr.start_date IS NOT NULL
  AND pr.procedure_desc IS NOT NULL;

-- View for immunization records with patient demographic and temporal data
CREATE OR REPLACE VIEW v_immunizations_base AS
SELECT
  pm.id AS patient_id,
  pm.birth_date,
  pm.gender,
  YEAR(i.date) AS year,
  MONTH(i.date) AS month,
  i.immunization_desc,
  i.base_cost
FROM immunizations i
JOIN patients pm ON i.patient_id = pm.id;
