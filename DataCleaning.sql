
-- Standardizing date format

Select SaleDateConverted
From PortfolioProject.dbo.housing;

ALTER TABLE PortfolioProject.dbo.housing
ADD SaleDateConverted Date;

Update PortfolioProject.dbo.housing
SET SaleDateConverted = CONVERT(Date, SaleDate);



-- Populating property address data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.housing a
JOIN PortfolioProject.dbo.housing b
     on a.ParcelID = b.ParcelID
	 and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null;

Update a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.housing a
JOIN PortfolioProject.dbo.housing b
     on a.ParcelID = b.ParcelID
	 and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null;



-- Breaking out address into individual columns
-- Property address

Select PropertyAddress, 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.housing;

ALTER TABLE PortfolioProject.dbo.housing
ADD PropertySplitAddress nvarchar(255);

ALTER TABLE PortfolioProject.dbo.housing
ADD PropertySplitCity varchar(255);

Update PortfolioProject.dbo.housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


-- Owner address
Select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.housing;

ALTER TABLE PortfolioProject.dbo.housing
ADD OwnerSplitAddress nvarchar(255),
OwnerSplitCity nvarchar(255),
OwnerSplitState nvarchar(255);

Update PortfolioProject.dbo.housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);



-- Changing Y and N to Yes and No

Select Distinct(SoldAsVacant), Count(SoldAsVacant) 
From PortfolioProject.dbo.housing
Group by SoldAsVacant
Order by 2;

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END
From PortfolioProject.dbo.housing;

Update PortfolioProject.dbo.housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END;



-- Removing duplicates

WITH RowNum AS(
Select *, 
ROW_NUMBER() OVER(Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                  Order by UniqueID) row_num
From PortfolioProject.dbo.housing
)
Select * 
From RowNum
Where row_num > 1;



-- Deleting unused columns

ALTER TABLE PortfolioProject.dbo.housing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;

ALTER TABLE PortfolioProject.dbo.housing
DROP COLUMN SaleDate;