

/*Cleaning Data in SQL Queries*/



SELECT *
FROM PORTOFOLIO..NashvileHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standarisasi Format Date

--Menambahkan kolom terlebih dahulu untuk meletakkan hasil konversi, dikarenakan tidak bisa langsung di update dikolom SaleDate
ALTER TABLE PORTOFOLIO..NashvileHousing 
ADD SaleDateConverted Date

UPDATE PORTOFOLIO..NashvileHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PORTOFOLIO..NashvileHousing





 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


SELECT *
FROM PORTOFOLIO..NashvileHousing
WHERE PropertyAddress IS NULL
ORDER BY [UniqueID ],ParcelID

-- Terdapat PropertyAddress yang bernilai NULL, tetapi setelah dilihat lagi ternyata datanya duplikat (PercelID sama) dan hanya salah satu yang bernilai null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PORTOFOLIO..NashvileHousing a
JOIN PORTOFOLIO..NashvileHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PORTOFOLIO..NashvileHousing a
JOIN PORTOFOLIO..NashvileHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


---------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

/*Property Address*/

SELECT PropertyAddress
FROM PORTOFOLIO..NashvileHousing

--memisahkan alamat yang di batasi koma
SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress)) as City
FROM PORTOFOLIO..NashvileHousing

--membuat kolom address dan city yang baru
ALTER TABLE PORTOFOLIO..NashvileHousing 
ADD PropertySplitAddress Nvarchar(255)

UPDATE PORTOFOLIO..NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PORTOFOLIO..NashvileHousing 
ADD PropertySplitCity Nvarchar(255)

UPDATE PORTOFOLIO..NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress))

--cek hasil update kolom
SELECT *
FROM PORTOFOLIO..NashvileHousing

/*Owner Address*/
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PORTOFOLIO..NashvileHousing

--membuat kolom address, city dan State yang baru
ALTER TABLE PORTOFOLIO..NashvileHousing 
ADD OwnerSplitAddress Nvarchar(255)

UPDATE PORTOFOLIO..NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE PORTOFOLIO..NashvileHousing 
ADD OwnerSplitCity Nvarchar(255)

UPDATE PORTOFOLIO..NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE PORTOFOLIO..NashvileHousing 
ADD OwnerSplitState Nvarchar(255)

UPDATE PORTOFOLIO..NashvileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT *
FROM PORTOFOLIO..NashvileHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant)
FROM PORTOFOLIO..NashvileHousing

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PORTOFOLIO..NashvileHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant='Y' THEN 'Yes'
		WHEN SoldAsVacant='N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PORTOFOLIO..NashvileHousing

UPDATE PORTOFOLIO..NashvileHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
		WHEN SoldAsVacant='N' THEN 'No'
		ELSE SoldAsVacant
		END





-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PORTOFOLIO..NashvileHousing
--ORDER BY ParcelID
)
--DELETE
--FROM RowNumCTE
--WHERE row_num > 1

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT*
FROM PORTOFOLIO..NashvileHousing

ALTER TABLE PORTOFOLIO..NashvileHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

