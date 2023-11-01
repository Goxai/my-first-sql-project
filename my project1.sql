SELECT *
FROM potfolio_project.dbo.NashvilleHousingg

--looking throught the dataset i started with standardising the saledate
--saledate has both date and time, in this i removed the time since zero althrough the dataset

SELECT saledateconvert, CONVERT(date, SaleDate)
FROM potfolio_project.dbo.NashvilleHousingg

UPDATE potfolio_project.dbo.NashvilleHousingg
SET SaleDate = CONVERT(date, SaleDate)

--Updating didn't give me a satisfying result so i altered the table and later uodated it 

ALTER TABLE potfolio_project.dbo.NashvilleHousingg
ADD saledateconvert date

UPDATE potfolio_project.dbo.NashvilleHousingg
SET saledateconvert = CONVERT(date, SaleDate)

--Populating empty propertyaddress 
SELECT ParcelID, PropertyAddress, SaleDate
FROM potfolio_project..NashvilleHousingg
WHERE PropertyAddress IS NULL

--from above query i discovered that some propertyaddress has same parcelid and same propertyaddress
--some of the empty address has the same parcelid with some that where populated so i did a self join to populated 
--the empty propertyaddress as shown below


SELECT nash.ParcelID, nash.PropertyAddress, vill.PropertyAddress
FROM potfolio_project.dbo.NashvilleHousingg nash
JOIN potfolio_project.dbo.NashvilleHousingg vill
    ON nash.ParcelID = vill.ParcelID
	AND nash.UniqueID <> vill.UniqueID
WHERE nash.PropertyAddress IS NULL

UPDATE nash
SET PropertyAddress = ISNULL(nash.PropertyAddress, vill.PropertyAddress)
FROM potfolio_project.dbo.NashvilleHousingg nash
JOIN potfolio_project.dbo.NashvilleHousingg vill
    ON nash.ParcelID = vill.ParcelID
	AND nash.UniqueID <> vill.UniqueID
WHERE nash.PropertyAddress IS NULL

SELECT ParcelID, PropertyAddress, SaleDate
FROM potfolio_project..NashvilleHousingg
WHERE PropertyAddress IS NULL

--breakdown propertyaddress into individual columns
--looking at the propertyaddress, i discovered that it comprises of the address and city

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',   PropertyAddress) -1) AS placeaddress,
SUBSTRING(PropertyAddress, CHARINDEX(',',   PropertyAddress) +1, LEN(PropertyAddress) ) AS cityaddress
FROM potfolio_project..NashvilleHousingg

ALTER TABLE potfolio_project..NashvilleHousingg
ADD placeaddress VARCHAR(100)

UPDATE potfolio_project..NashvilleHousingg
SET Placeaddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',   PropertyAddress) -1)

ALTER TABLE potfolio_project..NashvilleHousingg
ADD cityaddress VARCHAR(100)

UPDATE potfolio_project..NashvilleHousingg
SET cityaddress = SUBSTRING(PropertyAddress, CHARINDEX(',',   PropertyAddress) +1, LEN(PropertyAddress) ) 

SELECT *
FROM potfolio_project.dbo.NashvilleHousingg

--owneraddress comprises of address, city and state same issues with propertyaddress 
--same problem but i decided to use a much simpler method to rectify the issue

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Owneraddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS Ownercity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS Ownerstate
FROM potfolio_project.dbo.NashvilleHousingg

ALTER TABLE potfolio_project..NashvilleHousingg
ADD Owner_address VARCHAR(100)

UPDATE potfolio_project..NashvilleHousingg
SET Owner_address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE potfolio_project..NashvilleHousingg
ADD Owner_city VARCHAR(100)

UPDATE potfolio_project..NashvilleHousingg
SET Owner_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE potfolio_project..NashvilleHousingg
ADD Owner_state VARCHAR(100)

UPDATE potfolio_project..NashvilleHousingg
SET Owner_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

--Changing 'Y' and 'N' in soldasvacant column to 'YES' and 'NO'

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM potfolio_project.dbo.NashvilleHousingg
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant) DESC

--the query above shows the count of 'Y' and 'NO' in the soldasvacant column

SELECT SoldAsVacant,
  CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
      WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END
FROM potfolio_project.dbo.NashvilleHousingg

UPDATE potfolio_project.dbo.NashvilleHousingg
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
                        WHEN SoldAsVacant = 'N' THEN 'NO'
	                    ELSE SoldAsVacant
	                    END
FROM potfolio_project.dbo.NashvilleHousingg

--removing duplicate from the dataset

WITH Nashvill_CTE AS (
SELECT *,
     ROW_NUMBER() OVER(
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SaleDate,
				  SalePrice,
				  LegalReference
				  ORDER BY 
				  UniqueID) AS row_numberr
FROM potfolio_project.dbo.NashvilleHousingg
)

SELECT *
FROM Nashvill_CTE
WHERE row_numberr > 1

--Delete unused columns
--might not be a good practice generally

SELECT *
FROM potfolio_project.dbo.NashvilleHousingg

ALTER TABLE potfolio_project.dbo.NashvilleHousingg
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress


ALTER TABLE potfolio_project.dbo.NashvilleHousingg
DROP COLUMN TaxDistrict
