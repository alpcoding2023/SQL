-- CLEANING DATA USING SQL

-- CONVERTING DATE - Standardize Date format

SELECT *
FROM PortfolioProject1..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;


UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address data before Breaking out Property Address as it will be deleted if done prior to populate

SELECT *
FROM PortfolioProject1..NashvilleHousing
WHERE PropertyAddress is NULL
ORDER BY ParcelID

-- DO SELF JOIN to see if Parcel ID is refering to same Property Address if NULL

-- use ISNULL if NULL we'd like to populate the address


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-- use Alias when joining
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-- BREAKING PROPERTY ADDRESS to Individual Columns (Address, City, State)

-- look for delimeter - separates different value (for this ex we have ',' as delimeter)
-- use SUBSTRING & CHARINDEX
-- SUBSTRING(PropertyAddress,1, = is looking from the starting value till the CHARINDEX specified which is the delimeter as it's position, less 1 index to not include comma

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress ) -1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress ) +1, LEN(PropertyAddress)) as Address

FROM PortfolioProject1..NashvilleHousing


-- ADD New Column Street, City

ALTER TABLE NashvilleHousing
ADD StreetAddress nvarchar(255);

UPDATE NashvilleHousing
SET StreetAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress ) -1)

ALTER TABLE NashvilleHousing
ADD PropSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropSplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress ) +1, LEN(PropertyAddress))

SELECT * 
FROM PortfolioProject1..NashvilleHousing

-- BREAKING OWNER ADDRESS to Individual Columns (Address, City, State) 
-- USING PARSENAME & REPLACE METHOD

SELECT OwnerAddress 
FROM PortfolioProject1..NashvilleHousing

SELECT *
FROM PortfolioProject1..NashvilleHousing
--WHERE OwnerAddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.OwnerAddress, b.ParcelID, b.OwnerAddress, ISNULL(a.OwnerAddress,b.OwnerAddress)
FROM PortfolioProject1..NashvilleHousing as a
JOIN PortfolioProject1..NashvilleHousing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.OwnerAddress is NULL

UPDATE a
SET OwnerAddress = ISNULL(a.OwnerAddress, b.OwnerAddress)
FROM PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.OwnerAddress is NULL


------------
-- PARSENAME - only works with '.', -- so replace ',' with '.'
-- PARSENAME - works backward as well so 

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject1..NashvilleHousing


-- ADD New Owner Address Column Street, City, State

ALTER TABLE NashvilleHousing
ADD OwnerStreet nvarchar(255);

UPDATE NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT OwnerAddress, OwnerStreet, OwnerCity,OwnerState
FROM PortfolioProject1..NashvilleHousing


----------------------------

-- CHANGE SoldVacant Column values from Y & N - to "Yes" & "No" using CASE WHEN 
-- format CASE WHEN [condition] then [return value], WHEN ,ELSE, END

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant) as SoldCount
FROM PortfolioProject1..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN  SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject1..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN  SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject1..NashvilleHousing

SELECT SoldAsVacant
FROM PortfolioProject1..NashvilleHousing

-------------------------------------------------------------------------
-- REMOVING DUPLICATE
-- USING CTE BY PARTIONING ON THEIR UNIQUE TO EACH ROW, USING ROW_NUMBER() (CAN TRY RANK)
-- COMPARING MULTIPLE UNIQUE COLUMNS TO SEE IF THEIR DUPE


SELECT *
FROM PortfolioProject1..NashvilleHousing

SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) AS RowNum

FROM PortfolioProject1..NashvilleHousing
ORDER BY ParcelID


--- WRITE QUERY INSIDE CTE

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) AS RowNum

FROM PortfolioProject1..NashvilleHousing

)
DELETE 
FROM RowNumCTE
WHERE RowNum > 1

----------------------------------------
--DELETE UNUSED COLUMS

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT *
FROM PortfolioProject1..NashvilleHousing
