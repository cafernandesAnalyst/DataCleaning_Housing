-- Cleaning Data in SQL Queries --

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

SELECT SaleDate
FROM PortfolioProject.dbo.NashvilleHousing

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted Date

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address Data

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
FROM PortfolioProject.dbo.NashvilleHousing 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing 


-- To separete all

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing 

SELECT 
PARSENAME (REPLACE(OwnerAddress, ',' , '.'), 3)
, PARSENAME (REPLACE(OwnerAddress, ',' , '.'), 2)
, PARSENAME (REPLACE(OwnerAddress, ',' , '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',' , '.'), 3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',' , '.'), 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',' , '.'), 1)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing 

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing 

SELECT DISTINCT (SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant 
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing 

UPDATE PortfolioProject.dbo.NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-- Remove Duplicates --
-- Creating a CTE

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns --

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress