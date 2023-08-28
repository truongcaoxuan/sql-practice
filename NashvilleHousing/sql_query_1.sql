-- ***********************************
-- SQL Data Cleaning
-- ***********************************
USE [Nashville]
GO

SELECT *
FROM Nashville.dbo.Housing

-- ======================================================
-- TASK 1: Standardize date format
-- ======================================================

	SELECT SaleDate,
		   CONVERT(date, SaleDate)
	FROM Nashville.dbo.Housing
 
	ALTER TABLE  Housing
	ADD SaleDateNew date; 

	UPDATE Housing
	SET SaleDateNew = CONVERT(date,SaleDAte)

	ALTER TABLE Housing
	DROP COLUMN SaleDate

-- ======================================================
-- TASK 2: Formatting Property Address
-- ======================================================

	SELECT PropertyAddress
	FROM Nashville.dbo.Housing
	WHERE PropertyAddress IS NULL

	-- looking for a way to find any way to populate the property address
	SELECT *
	FROM Nashville.dbo.Housing
	ORDER BY ParcelID 

	-- We'll inner join itself and fill missing values with matching parcell id with different unique id
	SELECT a.PropertyAddress,
		   b.PropertyAddress,
		   a.ParcelID,
		   b.ParcelID
	FROM Nashville.dbo.Housing AS a
	JOIN Nashville.dbo.Housing AS b ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL

	-- populate a's null places with b's values 
	SELECT ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM Nashville.dbo.Housing AS a
	JOIN Nashville.dbo.Housing AS b ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL

	UPDATE a
	SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM Nashville.dbo.Housing AS a
	JOIN Nashville.dbo.Housing AS b ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL

	--check if it worked

	SELECT PropertyAddress
	FROM Nashville.dbo.Housing
	where PropertyAddress IS NULL


-- ======================================================
-- TASK 3: Segregating Address parts(address,city,state)
-- ======================================================

	SELECT PropertyAddress
	FROM Nashville.dbo.Housing

	-- two ways of doing it. 
	-- First using Substring
	-- Second using Parse name
	
	-- Modifying Property Address format
	SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
		   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS State -- SUBSTRING(var_name, start_index, end_index)
	FROM Nashville.dbo.Housing


	--Add split data to new col
	Alter Table Housing
	ADD PropertySplitAddress Nvarchar(255);

	UPDATE Housing
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress)-1)

	Alter Table Housing
	ADD PropertySplitCity Nvarchar(255);

	UPDATE Housing
	SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress) )


	-- query new col
	SELECT PropertySplitAddress,PropertySplitCity
	FROM Nashville.dbo.Housing
	-- clean old col
	ALTER TABLE Housing
	DROP COLUMN PropertyAddress

	--Modifying Owner Address format
	SELECT OwnerAddress
	FROM Nashville.dbo.Housing

	--Parse name only operates on '.' so, need to replace ',' with '.'
	-- also it words right to left 
	SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3)
	FROM Nashville.dbo.Housing

	SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),2)
	FROM Nashville.dbo.Housing

	SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),1)
	FROM Nashville.dbo.Housing

	-- add new col
	Alter table Housing
	Add OwnerAddressNew Nvarchar(255);

	Alter table Housing
	Add OwnerCity Nvarchar(255);

	Alter table Housing
	Add OwnerState Nvarchar(255);

	-- update value to new col
	Update Housing
	SET OwnerAddressNew = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

	Update Housing
	SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

	Update Housing
	SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

	-- query new col
	Select OwnerAddressNew,OwnerCity,OwnerState
	FROM Nashville.dbo.Housing

	-- drop old col
	Alter table Housing
	DROP column OwnerAddress


-- ======================================================
-- TASK 4: Cleaning 'SoldAsVacant' Col
-- ======================================================

	SELECT DISTINCT (SoldAsVacant), Count(SoldAsVacant)
	FROM Nashville.dbo.Housing
	GROUP BY SoldAsVacant
	ORDER BY 2

	SELECT SoldAsVacant,
		   CASE
			   WHEN SoldAsVacant='Y' THEN 'Yes'
			   WHEN SoldAsVacant='N' THEN 'No'
			   ELSE SoldAsVacant
		   END
	FROM Nashville.dbo.Housing

	UPDATE Housing
	SET SoldAsVacant = CASE
						   WHEN SoldAsVacant='Y' THEN 'Yes'
						   WHEN SoldAsVacant='N' THEN 'No'
						   ELSE SoldAsVacant
					   END

-- ======================================================
-- TASK 5: Remove Duplicates
-- ======================================================

--Using CTE to use Windows function Row_number() and
--adding up duplicate row number count

	WITH RowNumCTE AS
	  (SELECT *,
			  ROW_NUMBER() OVER (PARTITION BY ParcelID,
											  PropertySplitAddress,
											  SalePrice,
											  SaleDateNew,
											  LegalReference,
											  OwnerName
								 ORDER BY UniqueID) row_num
	   FROM Nashville.dbo.Housing)

	SELECT * 
	FROM RowNumCTE
	WHERE row_num >1

	--delete them 
	WITH RowNumCTE AS
	  (SELECT *,
			  ROW_NUMBER() OVER (PARTITION BY ParcelID,
											  PropertySplitAddress,
											  SalePrice,
											  SaleDateNew,
											  LegalReference,
											  OwnerName
								 ORDER BY UniqueID) row_num
	   FROM Nashville.dbo.Housing)

	Delete  
	FROM RowNumCTE
	WHERE row_num > 1

------------------------------------------------------------------------------- 
