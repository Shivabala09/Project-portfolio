
/* CLEANING DATA IN SQL QUERIES */

select *
from portfolio_project..Nashvillehousing
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* satndardize date format */

select saledate, convert(date,saledate)
from portfolio_project..Nashvillehousing

alter table portfolio_project..Nashvillehousing
add saledateconvert date;

update portfolio_project..Nashvillehousing
set saledateconvert =convert(date,saledate)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* remove duplicate */ 
--to view the duplicated cell and to delete the duplicated cell

with rownumcte as (
select*,
		ROW_NUMBER()over(
		partition by parcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
		order by
				uniqueID
				) row_num
from portfolio_project..Nashvillehousing
)
select*
--delete
from rownumcte
where row_num >1
--order by ParcelID
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* populate property address data */
select PropertyAddress
from portfolio_project..Nashvillehousing

select PropertyAddress
from portfolio_project..Nashvillehousing
where PropertyAddress is null
--here the property address will show null for the certain rows,
--we cant fill the cells with random address so, we have to verify the related columns to populate the null cells
--here parcelID is a source column to populate the null cells, because there are "two" same parcelID with "one" address which is considered to be the same address for another one

select *
from portfolio_project..Nashvillehousing as a
join portfolio_project..Nashvillehousing as b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--then use "isnull"(it will act as an ifcondition)

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress ,isnull(a.PropertyAddress,b.PropertyAddress)
from portfolio_project..Nashvillehousing as a
join portfolio_project..Nashvillehousing as b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from portfolio_project..Nashvillehousing as a
join portfolio_project..Nashvillehousing as b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* breaking out address into individual column(address, city, state) */
select *
--PropertyAddress
from portfolio_project..Nashvillehousing

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) Address
-- basically we can break the values in one cells into multiple cells by the delimiter(',')
-- the '-1' will show the value before the delimiter and '+1' will show the value after the delimiter
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) city
from portfolio_project..Nashvillehousing

alter table portfolio_project..Nashvillehousing
add PropertySplitAddress nvarchar(255);

update portfolio_project..Nashvillehousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table portfolio_project..Nashvillehousing
add PropertySplitCity nvarchar(255);

update portfolio_project..Nashvillehousing
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* another way to break the address (simple)*/

-- here we will use "Parsename" to split the cell 
-- "parsename" will only split the cell that contains dot(.)
-- it will also execute the result in reverse order
select *
--OwnerAddress
from portfolio_project..Nashvillehousing

select
PARSENAME (REPLACE(OwnerAddress,',','.'),3),
PARSENAME (REPLACE(OwnerAddress,',','.'),2),
PARSENAME (REPLACE(OwnerAddress,',','.'),1)
from portfolio_project..Nashvillehousing

alter table portfolio_project..Nashvillehousing
add ownersplitaddress nvarchar(255);

alter table portfolio_project..Nashvillehousing
add ownersplitcity nvarchar(255);

alter table portfolio_project..Nashvillehousing
add ownersplitstate nvarchar(255);

update portfolio_project..Nashvillehousing
set ownersplitaddress=PARSENAME (REPLACE(OwnerAddress,',','.'),3)

update portfolio_project..Nashvillehousing
set ownersplitcity=PARSENAME (REPLACE(OwnerAddress,',','.'),2)

update portfolio_project..Nashvillehousing
set ownersplitstate=PARSENAME (REPLACE(OwnerAddress,',','.'),1)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* changing "Y" and "N" to "yes" and "no" in SoldAsVacant*/

select distinct(SoldAsVacant)
from portfolio_project..Nashvillehousing
group by SoldAsVacant

--to change the y and n to yes and no
select SoldAsVacant,
case when SoldAsVacant='y' then 'Yes'
	 when SoldAsVacant='n' then 'No'
	 else SoldAsVacant
end
from portfolio_project..Nashvillehousing

update portfolio_project..Nashvillehousing
set SoldAsVacant=case when SoldAsVacant='y' then 'Yes'
	 when SoldAsVacant='n' then 'No'
	 else SoldAsVacant
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* delete the unused column */

alter table portfolio_project..Nashvillehousing
drop column saledateconverted,owneraddress,taxdistrict,propertyaddress

select*
from portfolio_project..Nashvillehousing
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------