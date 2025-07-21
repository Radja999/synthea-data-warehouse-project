-- Create and switch to the database
CREATE DATABASE synthea_db;
USE synthea_db;

-- Patients table: stores personal and demographic data
CREATE TABLE patients (
  id VARCHAR(45) PRIMARY KEY,
  ssn VARCHAR(11),
  drivers VARCHAR(9) DEFAULT NULL,
  passport VARCHAR(10) DEFAULT NULL,
  prefix VARCHAR(5) DEFAULT NULL,
  first_name VARCHAR(25),
  last_name VARCHAR(25),
  suffix VARCHAR(7),
  maiden VARCHAR(25) DEFAULT NULL,
  gender VARCHAR(1),
  address VARCHAR(50),
  city VARCHAR(30),
  county VARCHAR(30),
  zip VARCHAR(15) DEFAULT NULL,
  lat DOUBLE,
  lon DOUBLE,
  birth_date DATE DEFAULT NULL,
  death_date VARCHAR(10) DEFAULT NULL,
  marital VARCHAR(5) DEFAULT NULL,
  race VARCHAR(15),
  ethnicity VARCHAR(15),
  birth_place VARCHAR(100),
  healthcare_expenses DOUBLE,
  healthcare_coverage DOUBLE
);

-- Encounters: medical events involving a patient and provider
CREATE TABLE encounters (
  id VARCHAR(45) PRIMARY KEY,
  start_date DATETIME DEFAULT NULL,
  stop_date DATETIME DEFAULT NULL,
  patient_id VARCHAR(45),
  organization_id VARCHAR(45),
  provider_id VARCHAR(45),
  payer_id VARCHAR(45),
  encounter_class VARCHAR(15) DEFAULT NULL,
  encounter_code INT DEFAULT NULL,
  encounter_desc TEXT DEFAULT NULL,
  base_encounter_class DOUBLE DEFAULT NULL,
  total_claim_cost DOUBLE DEFAULT NULL,
  payer_coverage DOUBLE DEFAULT NULL,
  reason_code VARCHAR(20) DEFAULT NULL,
  reason_desc TEXT,
  FOREIGN KEY (patient_id) REFERENCES patients(id),
  FOREIGN KEY (organization_id) REFERENCES organizations(id),
  FOREIGN KEY (provider_id) REFERENCES providers(id),
  FOREIGN KEY (payer_id) REFERENCES payers(id)
);

-- Allergies: records allergy incidents per encounter
CREATE TABLE allergies (
  start_date DATETIME,
  patient_id VARCHAR(45),
  encounter_id VARCHAR(45),
  allergy_code DOUBLE,
  allergy_desc TEXT,
  allergy_type VARCHAR(20),
  category VARCHAR(45),
  reaction1 VARCHAR(20) DEFAULT NULL,
  description1 TEXT DEFAULT NULL,
  severity1 VARCHAR(255) DEFAULT NULL,
  reaction2 VARCHAR(20) DEFAULT NULL,
  description2 TEXT DEFAULT NULL,
  severity2 VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (encounter_id, allergy_code),
  FOREIGN KEY (patient_id) REFERENCES patients(id),
  FOREIGN KEY (encounter_id) REFERENCES encounters(id)
);

-- Organizations: healthcare organizations (e.g., hospitals)
CREATE TABLE organizations (
  id VARCHAR(45) PRIMARY KEY,
  organization_name VARCHAR(90),
  address VARCHAR(90),
  city VARCHAR(50),
  zip VARCHAR(50),
  lat DOUBLE,
  lon DOUBLE,
  phone VARCHAR(40) DEFAULT NULL,
  utilization INT
);

-- Providers: doctors and healthcare professionals
DROP TABLE providers;  -- Drops existing table if needed
CREATE TABLE providers (
  id VARCHAR(45) PRIMARY KEY,
  organization_id VARCHAR(45),
  provider_name VARCHAR(45),
  gender VARCHAR(1),
  specialty VARCHAR(50),
  address VARCHAR(70),
  city VARCHAR(30),
  zip VARCHAR(50),
  lat DOUBLE,
  lon DOUBLE,
  utilization INT,
  FOREIGN KEY (organization_id) REFERENCES organizations(id)
);

-- Payers: insurance companies
CREATE TABLE payers (
  id VARCHAR(45) PRIMARY KEY,
  payer_name VARCHAR(30),
  address VARCHAR(30) DEFAULT NULL,
  city VARCHAR(30) DEFAULT NULL,
  state_headquartered VARCHAR(5) DEFAULT NULL,
  zip VARCHAR(15) DEFAULT NULL,
  phone VARCHAR(15) DEFAULT NULL,
  amount_covered DOUBLE,
  amount_uncovered DOUBLE,
  revenue DOUBLE,
  covered_encounters INT,
  uncovered_encounters INT,
  covered_medications INT,
  uncovered_medications INT,
  covered_procedures INT,
  uncovered_proceduress INT,
  covered_immunizations INT,
  uncovered_immunizations INT,
  unique_customers INT,
  qols_avg DOUBLE,
  member_months INT
);

-- Payer transitions: changes in patient insurance coverage
CREATE TABLE payer_transitions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id VARCHAR(45),
  member_id VARCHAR(45),
  start_date DATETIME,
  end_date DATETIME,
  payer_id VARCHAR(45),
  secondary_payer_id VARCHAR(45) DEFAULT NULL,
  ownership VARCHAR(25) DEFAULT NULL,
  owner_name VARCHAR(70) DEFAULT NULL,
  FOREIGN KEY (patient_id) REFERENCES patients(id),
  FOREIGN KEY (payer_id) REFERENCES payers(id)
);

-- Care plans: treatments or interventions planned
CREATE TABLE careplans (
  id VARCHAR(45) PRIMARY KEY,
  start_date DATE,
  end_date VARCHAR(15) DEFAULT NULL,
  patient_id VARCHAR(45),
  encounter_id VARCHAR(45),
  careplan_code DOUBLE,
  careplan_desc TEXT,
  reason_code VARCHAR(30) DEFAULT NULL,
  reason_desc TEXT DEFAULT NULL,
  FOREIGN KEY (patient_id) REFERENCES patients(id),
  FOREIGN KEY (encounter_id) REFERENCES encounters(id)
);

-- Claims: submitted medical service claims
CREATE TABLE claims (
  id VARCHAR(45) PRIMARY KEY,
  patient_id VARCHAR(45),
  provider_id VARCHAR(45),
  department_id INT,
  diagnosis_1 DOUBLE,
  diagnosis_2 VARCHAR(45) DEFAULT NULL,
  diagnosis_3 VARCHAR(45) DEFAULT NULL,
  diagnosis_4 VARCHAR(45) DEFAULT NULL,
  diagnosis_5 VARCHAR(45) DEFAULT NULL,
  diagnosis_6 VARCHAR(45) DEFAULT NULL,
  diagnosis_7 VARCHAR(45) DEFAULT NULL,
  diagnosis_8 VARCHAR(45) DEFAULT NULL,
  appointment_id VARCHAR(45),
  current_illness_date DATETIME,
  service_date DATETIME,
  supervising_provider_id VARCHAR(45),
  healthcare_claim_type_id_1 INT,
  healthcare_claim_type_id_2 INT,
  primary_patient_insurance_id VARCHAR(45) DEFAULT NULL,
  status_1 VARCHAR(7) DEFAULT NULL,
  status_2 VARCHAR(7) DEFAULT NULL,
  status_p VARCHAR(7) DEFAULT NULL,
  last_bill_date_1 DATETIME DEFAULT NULL,
  last_bill_date_2 VARCHAR(45) DEFAULT NULL,
  last_bill_date_p DATETIME DEFAULT NULL,
  FOREIGN KEY (patient_id) REFERENCES patients(id),
  FOREIGN KEY (provider_id) REFERENCES providers(id),
  FOREIGN KEY (supervising_provider_id) REFERENCES providers(id)
);

-- Claim transaction: financial transactions related to claims
CREATE TABLE claim_transaction (
  id VARCHAR(45) PRIMARY KEY,
  claim_id VARCHAR(45),
  charge_id INT,
  patient_id VARCHAR(45),
  claim_type VARCHAR(20),
  amount VARCHAR(45) DEFAULT NULL,
  method VARCHAR(20) DEFAULT NULL,
  start_date DATETIME,
  end_date DATETIME,
  service_place VARCHAR(45),
  procedure_code DOUBLE,
  notes TEXT DEFAULT NULL,
  unit_amount VARCHAR(45) DEFAULT NULL,
  transfer_out_id VARCHAR(45) DEFAULT NULL,
  transfer_type VARCHAR(10) DEFAULT NULL,
  payments VARCHAR(45) DEFAULT NULL,
  adjustments VARCHAR(45) DEFAULT NULL,
  transfers VARCHAR(45) DEFAULT NULL,
  outstanding VARCHAR(45) DEFAULT NULL,
  patient_insurance_id VARCHAR(45) DEFAULT NULL,
  provider_id VARCHAR(45),
  supervisor_provider_id VARCHAR(45),
  FOREIGN KEY (claim_id) REFERENCES claims(id),
  FOREIGN KEY (patient_id) REFERENCES patients(id),
  FOREIGN KEY (provider_id) REFERENCES providers(id)
);

-- Conditions: patient medical conditions per encounter
CREATE TABLE conditions (
  start_date DATE DEFAULT NULL,
  end_date VARCHAR(30) DEFAULT NULL,
  patient_id VARCHAR(45),
  encounter_id VARCHAR(45),
  condition_code DOUBLE,
  condition_desc TEXT DEFAULT NULL,
  PRIMARY KEY (patient_id, encounter_id, condition_code),
  FOREIGN KEY (patient_id) REFERENCES patients(id),
  FOREIGN KEY (encounter_id) REFERENCES encounters(id)
);

-- Devices: medical devices used per encounter
CREATE TABLE devices (
  start_date DATETIME DEFAULT NULL,
  end_date VARCHAR(70) DEFAULT NULL,
  patient_id VARCHAR(45),
  encounter_id VARCHAR(45),
  device_code INT,
  device_desc TEXT DEFAULT NULL,
  udi VARCHAR(150) PRIMARY KEY,
  FOREIGN KEY (patient_id) REFERENCES patients(id),
  FOREIGN KEY (encounter_id) REFERENCES encounters(id)
);

-- Procedures: medical procedures performed
CREATE TABLE procedures (
  start_date DATETIME,
  end_date DATETIME,
  patient_id VARCHAR(45),
  encounter_id VARCHAR(45),
  procedure_code DOUBLE,
  procedure_desc TEXT,
  base_cost DOUBLE,
  reason_code VARCHAR(30) DEFAULT NULL,
  reason_desc TEXT DEFAULT NULL,
  PRIMARY KEY (start_date, end_date, encounter_id, procedure_code),
  FOREIGN KEY (patient_id) REFERENCES patients(id),
  FOREIGN KEY (encounter_id) REFERENCES encounters(id)
);

-- Imaging studies: radiological imaging records
CREATE TABLE imaging_studies (
  id VARCHAR(200),
  date DATETIME DEFAULT NULL,
  patient_id VARCHAR(45),
  encounter_id VARCHAR(45),
  series_uid VARCHAR(100),
  bodysite_code INT,
  bodysite_desc TEXT,
  modality_code VARCHAR(2),
  modality_desc TEXT,
  instance_uid VARCHAR(100),
  sop_code VARCHAR(70),
  sop_desc TEXT,
  procedure_code DOUBLE,
  PRIMARY KEY (id, instance_uid),
  FOREIGN KEY (patient_id) REFERENCES patients(id),
  FOREIGN KEY (encounter_id) REFERENCES encounters(id)
);

-- Immunizations: vaccination records
CREATE TABLE immunizations (
  date DATETIME,
  patient_id VARCHAR(45),
  encounter_id VARCHAR(45),
  immunization_code INT,
  immunization_desc TEXT,
  base_cost DOUBLE,
  PRIMARY KEY (encounter_id, immunization_code),
  FOREIGN KEY (patient_id) REFERENCES patients(id),
  FOREIGN KEY (encounter_id) REFERENCES encounters(id)
);

-- Medications: prescribed medications
DROP TABLE medications;
CREATE TABLE medications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  start_date DATETIME,
  end_date VARCHAR(30),
  patient_id VARCHAR(45),
  payer_id VARCHAR(45),
  encounter_id VARCHAR(45),
  medication_code INT,
  medication_desc TEXT,
  base_cost DOUBLE,
  payer_coverage DOUBLE,
  dispenses INT,
  total_cost DOUBLE,
  reason_code VARCHAR(45),
  reason_desc TEXT,
  FOREIGN KEY (patient_id) REFERENCES patients(id),
  FOREIGN KEY (encounter_id) REFERENCES encounters(id),
  FOREIGN KEY (payer_id) REFERENCES payers(id)
);

-- Observations: clinical observations (e.g., lab results)
CREATE TABLE observations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  date DATETIME,
  patient_id VARCHAR(45),
  category VARCHAR(20) DEFAULT NULL,
  observation_code VARCHAR(15),
  observation_desc TEXT,
  value VARCHAR(150),
  units VARCHAR(25) DEFAULT NULL,
  observation_type VARCHAR(7),
  FOREIGN KEY (patient_id) REFERENCES patients(id)
);

-- Supplies: medical supplies used per encounter
CREATE TABLE supplies (
  id INT AUTO_INCREMENT PRIMARY KEY,
  date DATETIME,
  patient_id VARCHAR(45),
  encounter_id VARCHAR(45),
  supply_code INT,
  supply_desc TEXT,
  quantity INT,
  FOREIGN KEY (patient_id) REFERENCES patients(id),
  FOREIGN KEY (encounter_id) REFERENCES encounters(id)
);
