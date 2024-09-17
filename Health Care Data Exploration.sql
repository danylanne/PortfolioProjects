-- Health Care Exploratory Data Analysis -- 

-- DATA OVERVIEW
SELECT 
	*
FROM 
	Portfolio_SQL..HealthcareDataset
;

-- SUMMARY STATISTICS --

-- Total Number of Patients
SELECT 
	COUNT(*) AS Total_Patients 
FROM 
	Portfolio_SQL..HealthcareDataset
;

-- Average Age of Patients per Age Bracket
SELECT 
	Age_Bracket, AVG(CAST(Age AS int)) AS AverageAge
FROM 
	Portfolio_SQL..HealthcareDataset
GROUP BY 
	Age_Bracket
;

-- Minimum, Maximum and Average Patient Age 
SELECT
    MIN(CAST(Age AS INT)) AS Min_Age,
    MAX(CAST(Age AS INT)) AS Max_Age,
    AVG(CAST(Age AS INT)) AS Avg_Age
FROM 
	Portfolio_SQL..HealthcareDataset
;

-- Gender Distribution
SELECT 
	Gender, COUNT(*) AS Count 
FROM 
	Portfolio_SQL..HealthcareDataset
GROUP BY
	Gender
;

-- Blood Type Distribution
SELECT
	Blood_Type, COUNT(*) AS Count
FROM
	Portfolio_SQL..HealthcareDataset
GROUP BY
	Blood_Type
ORDER BY
	Blood_Type
;

-- Medical Conditions Count from Highest to Lowest
SELECT 
	Medical_Condition,
	COUNT(*) AS Count
FROM 
	Portfolio_SQL..HealthcareDataset
GROUP BY
	Medical_Condition
ORDER BY
	Count DESC
;



-- ADMISSION ANALYSIS --

-- Average Billing Amount per Admission Type
SELECT
	Admission_Type,
	ROUND(AVG(CAST(Billing_Amount AS float)),2) AS Average_Billing
FROM 
	Portfolio_SQL..HealthcareDataset
GROUP BY
	Admission_Type
ORDER BY
	Average_Billing DESC
;

-- Minimum, Maximum and Average Billing Amount
SELECT
    ROUND(MIN(CAST(Billing_Amount AS FLOAT)),2) AS Min_Billing_Amount,
    ROUND(MAX(CAST(Billing_Amount AS FLOAT)),2) AS Max_Billing_Amount,
    ROUND(AVG(CAST(Billing_Amount AS FLOAT)),2) AS Avg_Billing_Amount
FROM 
	Portfolio_SQL..HealthcareDataset
;

-- Admissions by Doctor
SELECT
	Doctor,
	COUNT(*) AS Total_Admissions
FROM
	Portfolio_SQL..HealthcareDataset
GROUP BY
	Doctor
ORDER BY
	Doctor
;

-- MEDICATION AND TEST ANALYSIS --

-- Common Medications
SELECT 
	Medication,
	COUNT(Medication) AS TotalCountPerMedication
FROM
	Portfolio_SQL..HealthcareDataset
GROUP BY
	Medication
ORDER BY
	TotalCountPerMedication DESC
;

-- Common Test Results
SELECT 
	Test_Results,
	COUNT(Name) AS CountPerTestResult
FROM 
	Portfolio_SQL..HealthcareDataset
GROUP BY
	Test_Results
ORDER BY
	CountPerTestResult
;

-- ADMISSION AND DISCHARGE ANALYSIS --

-- Average Length of Stay
SELECT 
    AVG(DATEDIFF(DAY, CAST(Date_of_Admission AS DATE), CAST(Discharge_Date AS DATE))) AS AverageLengthOfStay
FROM 
    Portfolio_SQL..HealthcareDataset
WHERE
    Discharge_Date IS NOT NULL
    AND Date_of_Admission IS NOT NULL
;

-- Patient Count Per Length of Stay
SELECT
    DATEDIFF(DAY, Date_of_Admission, Discharge_Date) AS Length_of_Stay,
    COUNT(*) AS Count
FROM 
	Portfolio_SQL..HealthcareDataset
GROUP BY 
	DATEDIFF(DAY, Date_of_Admission, Discharge_Date)
ORDER BY 
	Length_of_Stay
;

-- Admissions and Discharges Over Time
SELECT 
    YEAR(Date_of_Admission) AS Admission_Year,
    COUNT(*) AS Count
FROM 
	Portfolio_SQL..HealthcareDataset
GROUP BY
	YEAR(Date_of_Admission)
ORDER BY
	Admission_Year;