/*

Cleaning Data in SQL Queries

*/


Select *
from PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate =CONVERT(Date, SaleDate)


-- If it doesn't Update properly

 ALTER TABLE NashvilleHousing
 Add SaleDateConverted Date;

 Update NashvilleHousing
SET SaleDateConverted =CONVERT(Date, SaleDate)


---------------------------------------------------------------------------

--Populate Property Address Date

select *
From PortfolioProject.dbo.NashvilleHousing
-- Where PropertyAddress is null
order by ParcelID



select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



Update a
SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




-----------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns(Address, City, State)


select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
-- Where PropertyAddress is null
--order by ParcelID


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1,  Len(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing

 ALTER TABLE NashvilleHousing
 Add PropertySplitAddress Nvarchar(255);

 Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)



 ALTER TABLE NashvilleHousing
 Add PropertySplitcity Nvarchar(255);

 Update NashvilleHousing
SET PropertySplitcity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1,  Len(PropertyAddress))





Select *
From PortfolioProject.dbo.NashvilleHousing




Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
 Add OwnerSplitAddress Nvarchar(255);

 Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)



 ALTER TABLE NashvilleHousing
 Add OwnerSplitCity Nvarchar(255);

 Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)



 ALTER TABLE NashvilleHousing
 Add OwnerSplitstate Nvarchar(255);

 Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)




-----------------------------------------------------------------------------

--Change Y and N to Yes and No in  'Sold as Vacant' field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2



Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant 
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant 
	   END




-------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE As(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1
Order by PropertyAddress




-------------------------------------------------------------------------------------------

--Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


