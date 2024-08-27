/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM 
	Portfolio..Nashville_Housing_Data

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE
	Portfolio..Nashville_Housing_Data
ADD 
	SaleDateConverted Date
	
SELECT 
	SaleDateConverted
FROM
	Portfolio..Nashville_Housing_Data

UPDATE
	Portfolio..Nashville_Housing_Data
SET
	SaleDateConverted = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM 
	Portfolio..Nashville_Housing_Data
--Where PropertyAddress is null
ORDER BY
	ParcelID

SELECT t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress, ISNULL(t1.PropertyAddress,t2.PropertyAddress)
FROM 
	Portfolio..Nashville_Housing_Data t1
JOIN Portfolio..Nashville_Housing_Data t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.UniqueID <> t2.UniqueID
WHERE
	t1.PropertyAddress IS NULL

UPDATE t1
SET PropertyAddress = ISNULL(t1.PropertyAddress,t2.PropertyAddress)
FROM 
	Portfolio..Nashville_Housing_Data t1
JOIN 
	Portfolio..Nashville_Housing_Data t2
	ON 
		t1.ParcelID = t2.ParcelID
		AND 
		t1.UniqueID <> t2.UniqueID
WHERE
	t1.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT *
FROM 
	Portfolio..Nashville_Housing_Data

SELECT
	PARSENAME(REPLACE(PropertyAddress, ',', '.') , 2)
	,PARSENAME(REPLACE(PropertyAddress, ',', '.') , 1)
FROM
	Portfolio..Nashville_Housing_Data

ALTER TABLE
	Portfolio..Nashville_Housing_Data
ADD 
	PropertySplitAddress Nvarchar(255);

UPDATE
	Portfolio..Nashville_Housing_Data
SET
	PropertySplitAddress = PARSENAME(REPLACE(PropertyAddress, ',', '.') , 2)

ALTER TABLE
	Portfolio..Nashville_Housing_Data
ADD 
	PropertySplitCity Nvarchar(255);

UPDATE
	Portfolio..Nashville_Housing_Data
SET
	PropertySplitCity = PARSENAME(REPLACE(PropertyAddress, ',', '.') , 1)

---
SELECT 
	OwnerAddress
FROM 
	Portfolio..Nashville_Housing_Data

SELECT 
	PARSENAME(Replace(OwnerAddress,',','.'),3),
	PARSENAME(Replace(OwnerAddress,',','.'),2),
	PARSENAME(Replace(OwnerAddress,',','.'),1)
FROM 
	Portfolio..Nashville_Housing_Data

ALTER TABLE
	Portfolio..Nashville_Housing_Data
ADD 
	OwnerSplitAddress Nvarchar(255);

UPDATE
	Portfolio..Nashville_Housing_Data
SET
	OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

ALTER TABLE
	Portfolio..Nashville_Housing_Data
ADD 
	OwnerSplitCity Nvarchar(255);

UPDATE
	Portfolio..Nashville_Housing_Data
SET
	OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE
	Portfolio..Nashville_Housing_Data
ADD 
	OwnerSplitState Nvarchar(255);

UPDATE
	Portfolio..Nashville_Housing_Data
SET
	OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM 
	Portfolio..Nashville_Housing_Data
GROUP BY
	SoldAsVacant

ALTER TABLE Portfolio..Nashville_Housing_Data
ALTER COLUMN SoldAsVacant nvarchar(255);

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM 
	Portfolio..Nashville_Housing_Data

UPDATE Portfolio..Nashville_Housing_Data
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM 
	Portfolio..Nashville_Housing_Data)
DELETE
FROM 
	RowNumCTE
WHERE
	row_num > 1;



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
SELECT *
FROM 
	Portfolio..Nashville_Housing_Data

ALTER TABLE Portfolio..Nashville_Housing_Data
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate
