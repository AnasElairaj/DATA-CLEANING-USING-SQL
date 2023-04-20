------------------------------------------------ Data Cleaning using SQL made by EL AIRAJ ANAS --------------------

-- Cleaning Data in SQL Queries 

Select * 
from Data_Cleaning.dbo.Sheet1$


-- Standarize Date format 

Select dateconverted, Convert (Date,Saledate) 
from Data_Cleaning.dbo.Sheet1$

Update Data_Cleaning.dbo.Sheet1$ 
SEt SaleDate = Convert (Date,Saledate)  

Alter table Data_Cleaning.dbo.Sheet1$ 
add dateconverted date; 

Update Data_Cleaning.dbo.Sheet1$ 
SEt dateconverted = Convert (Date,Saledate)  

-- populate proprety Adress data 


Select * 
from Data_Cleaning.dbo.Sheet1$
where PropertyAddress is null
--order by [UniqueID ]

Select a.ParcelID, a.PropertyAddress , b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress )
from Data_Cleaning.dbo.Sheet1$ a
join Data_Cleaning.dbo.Sheet1$ b 
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]

where a.PropertyAddress is null 


update a 
Set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress )
from Data_Cleaning.dbo.Sheet1$ a
join Data_Cleaning.dbo.Sheet1$ b 
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null 

-- Breaking out adress into individual colums ( Adress, city, state )

-- Using SUBSTRING Fonctions 

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address ,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as Address 
from Data_Cleaning.dbo.Sheet1$ 

-- UPDATING OUR DATA WITH THE NEW COLUMN PropertySplitAddress And PropertySplitCity

-- adding PropertySplitAddress
Alter table Data_Cleaning.dbo.Sheet1$ 
add PropertySplitAddress varchar(400); 
Update Data_Cleaning.dbo.Sheet1$ 
SEt PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) 

-- adding PropertySplitCity

Alter table Data_Cleaning.dbo.Sheet1$ 
add PropertySplitCity varchar(400); 
Update Data_Cleaning.dbo.Sheet1$ 
SEt PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))

-- We wil do the same for Owner Adress using anther method 


Select OwnerAddress
from Data_Cleaning.dbo.Sheet1$

-- Using PARSENAME 
/*NB : REPLACE Combining PARSENAME() and REPLACE(), you get Excel’s Text to Column. 
The issue with PARSENAME is that it could only work with “.”. Therefore you need REPLACE to change whatever delimiter it is, to “.”     */


Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from Data_Cleaning.dbo.Sheet1$

-- UPDATING OUR DATA WITH THE NEW COLUMN OwnerAddress_Address And OwnerAddressCity And OwnerAddressState
-- adding OwnerAddress_Address

Alter table Data_Cleaning.dbo.Sheet1$ 
add OwnerAddress_Address varchar(400); 
Update Data_Cleaning.dbo.Sheet1$ 
SEt OwnerAddress_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

-- adding OwnerAddressCity

Alter table Data_Cleaning.dbo.Sheet1$ 
add OwnerAddressCity varchar(400); 
Update Data_Cleaning.dbo.Sheet1$ 
SEt OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

-- adding OwnerAddressCity

Alter table Data_Cleaning.dbo.Sheet1$ 
add OwnerAddressState varchar(400); 
Update Data_Cleaning.dbo.Sheet1$ 
SEt OwnerAddressState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *	
from Data_Cleaning.dbo.Sheet1$ 

--- in this step we are looking to change 'Y' and 'N' in SoldAsVacant with Yes and No 

--  Searching for Y and N and exploring our data 

-- Method 1 :  Updating Our Data 
Select SoldAsVacant
from Data_Cleaning.dbo.Sheet1$ 
where SoldAsVacant like 'N'
OR SoldAsVacant like 'Y'
Order by SoldAsVacant 

Update Data_Cleaning.dbo.Sheet1$ 
SEt SoldAsVacant = 'Yes' 
where SoldAsVacant = 'Y'  
Update Data_Cleaning.dbo.Sheet1$ 
Set SoldAsVacant = 'No' 
where SoldAsVacant = 'N' 

-- Method 2 Using Case When :  

Select SoldAsVacant,
Case when SoldAsVacant ='Y' THEN 'Yes' 
     When SoldAsVacant = 'N' THEN 'No' 
	 ELSE SoldAsVacant 
	 end 
from Data_Cleaning.dbo.Sheet1$ 

Update Data_Cleaning.dbo.Sheet1$ 
Set SoldAsVacant =
Case when SoldAsVacant ='Y' THEN 'Yes' 
     When SoldAsVacant = 'N' THEN 'No' 
	 ELSE SoldAsVacant 
	 end  


-- CHECK IN OUR RESULTS Using Disctinct and Count to exploring all contents of SoldAsVacant

Select Distinct (SoldAsVacant), count (SoldAsVacant)
from Data_Cleaning.dbo.Sheet1$ 
Group by SoldAsVacant


-- REMOVE DUPLICATE :  


Select *
from Data_Cleaning.dbo.Sheet1$ 

-- USING CTE AND PARTITION TO DETECT DUPLICATE

with rowNumCTE AS( 
Select *, 
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID, 
                PropertyAddress, 
				SalePrice,
				SaleDate,
				LegalReference 
				Order by 
				UniqueID 
				) row_num 

from Data_Cleaning.dbo.Sheet1$ 
) 
select *
from rowNumCTE 
where row_num >1 
order by PropertyAddress  

-- DELETING DUPLICATE ( IN THIS CASE WE WILL JUST CHANGE SELECT* BY DELETE ) 

with rowNumCTE AS( 
Select *, 
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID, 
                PropertyAddress, 
				SalePrice,
				SaleDate,
				LegalReference 
				Order by 
				UniqueID 
				) row_num 

from Data_Cleaning.dbo.Sheet1$ 
) 
DELETE 
from rowNumCTE 
where row_num >1 
--order by PropertyAddress  

-- Delete unused columns 

select * 
from Data_Cleaning.dbo.Sheet1$ 

Alter table Data_Cleaning.dbo.Sheet1$ 
DROP COLUMN OwnerAddress, TaxDistrict , PropertyAddress 