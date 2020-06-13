----------------------------------------------------------------------
--HEADER INFORMATION
----------------------------------------------------------------------

--Run 1st

--This file was produced on 030320 @ 11:15 PM
--This file has not been finalized.
--****** Object:  Database ist722_grblock_oa2_dw Script Date: 3/3/2020 11:12:11 PM ******



/*
	Adjusted to be used on ist722_grblock_oa2_dw
	fUDGEMART ROLAP Bus Architecture


	This script creates two conformed dimensional models in the Fudgemart schema
		- FactInventory
		- FactSales		
	
	For use with the ETL Lab (SSIS) and OLAP Lab (SSAS)
	
	IMPORTANT: Execute this script in your data warehouse (dw) database
*/

----------------------------------------------------------------------
--START DATABASE CONNECTION INFORMATION
----------------------------------------------------------------------

---------------------------------
-- Setting up the dynamic db name
---------------------------------

----------------------------------------------------------------------

--DOCUMENTATION
--TEAM PROJECT SHARED DATABASE
--USE ist722_grblock_oa2_dw
--USE ist722_grblock_oa2_stage

USE  ist722_grblock_oa2_dw;
----------------------------------------------------------------------
--END DATABASE CONNECTION INFORMATION
----------------------------------------------------------------------



----------------------------------------------------------------------
--START SCHEMA CREATION
--FUNCTION WORKS CORRECTLY
----------------------------------------------------------------------

-- Create the schema if it does not exist
IF (NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'fudgemart')) 
BEGIN
    EXEC ('CREATE SCHEMA [fudgemart] AUTHORIZATION [dbo]')
	PRINT 'CREATE SCHEMA [fudgemart] AUTHORIZATION [dbo]'
END
go 

----------------------------------------------------------------------
--BEGIN DROP TABLES IF THEY EXIST
--FUNCTIONS WORK CORRECTLY
----------------------------------------------------------------------

PRINT 'Start DELETE FACT TABLES'
-- delete all the fact tables in the schema
DECLARE @fact_table_name varchar(100)
DECLARE cursor_loop CURSOR FAST_FORWARD READ_ONLY FOR 
	select TABLE_NAME from INFORMATION_SCHEMA.TABLES 
		where TABLE_SCHEMA='fudgemart' and TABLE_NAME like 'Fact%'
OPEN cursor_loop
FETCH NEXT FROM cursor_loop  INTO @fact_table_name
WHILE @@FETCH_STATUS= 0
BEGIN
	EXEC ('DROP TABLE [fudgemart].[' + @fact_table_name + ']')
	PRINT 'DROP TABLE [fudgemart].[' + @fact_table_name + ']'
	FETCH NEXT FROM cursor_loop  INTO @fact_table_name
END
CLOSE cursor_loop
DEALLOCATE cursor_loop
go


PRINT 'Start DELETE Dim TABLES'
-- delete all the other tables in the schema
DECLARE @table_name varchar(100)
DECLARE cursor_loop CURSOR FAST_FORWARD READ_ONLY FOR 
	select TABLE_NAME from INFORMATION_SCHEMA.TABLES 
		where TABLE_SCHEMA='fudgemart' and TABLE_TYPE = 'BASE TABLE'
OPEN cursor_loop
FETCH NEXT FROM cursor_loop INTO @table_name
WHILE @@FETCH_STATUS= 0
BEGIN
	EXEC ('DROP TABLE [fudgemart].[' + @table_name + ']')
	PRINT 'DROP TABLE [fudgemart].[' + @table_name + ']'
	FETCH NEXT FROM cursor_loop  INTO @table_name
END
CLOSE cursor_loop
DEALLOCATE cursor_loop
go


----------------------------------------------------------------------
--END DROP TABLES IF THEY EXIST
----------------------------------------------------------------------

----------------------------------------------------------------------
--BEGIN CREATING TABLES
----------------------------------------------------------------------

PRINT 'Start Table Creation'


/* Create table Fudgemart.DimDate */
PRINT 'CREATE TABLE Fudgemart.DimDate'
CREATE TABLE fudgemart.DimDate (
   [DateKey]  int   NOT NULL ,
	[Date]  date   NULL ,  
	[FullDateUSA]  nchar(11)   NOT NULL ,
	[DayOfWeek]  tinyint   NOT NULL ,
	[DayName]  nchar(10)   NOT NULL ,
	[DayOfMonth]  tinyint   NOT NULL ,
	[DayOfYear]  smallint   NOT NULL ,
	[WeekOfYear]  tinyint   NOT NULL ,
	[MonthName]  nchar(10)   NOT NULL ,
	[MonthOfYear]  nvarchar(50)   NOT NULL ,
	[Quarter]  tinyint   NOT NULL ,
	[QuarterName]  nchar(10)   NOT NULL ,
	[Year]  smallint   NOT NULL ,
	[IsWeekday]  bit  DEFAULT 0 NOT NULL ,
 CONSTRAINT [PK_Fudgemart.DimDate] PRIMARY KEY CLUSTERED 
( [DateKey] )
) ON [PRIMARY]
;

PRINT 'Lets insert some Data in Fudgemart.DimDate'
INSERT INTO Fudgemart.DimDate (DateKey, Date, FullDateUSA, DayOfWeek, DayName, DayOfMonth, DayOfYear, WeekOfYear, MonthName, MonthOfYear, Quarter, QuarterName, Year, IsWeekday)
VALUES (-1, '', 'Unk date', 0, 'Unk date', 0, 0, 0, 'Unk month', 0, 0, 'Unk qtr', 0, 0)
;


--Added customer_firstname & customer_lastname
/* Create table fudgemart.DimOrder */
PRINT 'CREATE TABLE Fudgemart.DimOrder'
CREATE TABLE fudgemart.DimOrder (
    [OrderKey]  int IDENTITY  NOT NULL ,
	[OrderID]  int   NOT NULL ,
	[CustomerID]  int   NOT NULL ,
	[OrderDate]  datetime   NOT NULL , 
	[ShippedDate]  datetime   NOT NULL ,
--metadata
	[RowIsCurrent]  nchar(1) DEFAULT 'Y'  NOT NULL ,
	[RowStartDate]  datetime DEFAULT '1/1/1900'  NOT NULL, 
	[RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL ,
	[RowChangeReason]  nvarchar(200) DEFAULT 'NA'   NOT NULL ,
	CONSTRAINT [PK_fudgemart.DimOrder] PRIMARY KEY CLUSTERED 
( [OrderKey] )
) ON [PRIMARY]
;

SET IDENTITY_INSERT fudgemart.DimOrder ON
;
PRINT 'Lets insert some Data in Fudgemart.DimOrder'
INSERT INTO fudgemart.DimOrder (OrderKey, OrderID, CustomerID, OrderDate, ShippedDate, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, -1, '12/31/1899', '1/1/1900', 'Y', '1/1/1900', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT fudgemart.DimOrder OFF
;


--Removed ProductRetailPrice and ProductWholesalePrice to Face Sales
/* Create table fudgemart.DimProduct */
PRINT 'CREATE TABLE fudgemart.DimProduct'
CREATE TABLE Fudgemart.DimProduct (
    [ProductKey]  int IDENTITY  NOT NULL ,
	[ProductID]  int   NOT NULL ,
	[ProductName]  nvarchar(50)   NOT NULL ,
	[product_retail_price] money NOT NULL,
    [product_is_active] bit NOT NULL,
--metadata
	[RowIsCurrent]  nchar(1) DEFAULT 'Y'  NOT NULL ,
	[RowStartDate]  datetime DEFAULT '1/1/1900'  NOT NULL ,
	[RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL ,
	[RowChangeReason]  nvarchar(200)   NOT NULL ,
	CONSTRAINT [PK_fudgemart.DimProduct] PRIMARY KEY CLUSTERED 
( [ProductKey] )
) ON [PRIMARY]
;


SET IDENTITY_INSERT fudgemart.DimProduct ON
;
PRINT 'Lets insert some Data in Fudgemart.DimProduct'
INSERT INTO fudgemart.DimProduct (ProductKey, ProductID , ProductName, product_retail_price, product_is_active, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, 'unknown', -1, 0, 'Y', '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT fudgemart.DimProduct OFF
;



/* Create table fudgemart.DimTitle */
PRINT 'CREATE TABLE Fudgemart.DimTitle'
CREATE TABLE fudgemart.DimTitle (
    [TitleKey]  int IDENTITY  NOT NULL ,
	[TitleID]  nvarchar(20)   NOT NULL ,
	[TitleName]  nvarchar(200)   NOT NULL ,
	[TitleBluRayAvailable]  bit   NOT NULL ,
	[TitleDVDAvailable]  bit   NOT NULL ,
--metadata
	[RowIsCurrent]  nchar(1) DEFAULT 'Y'  NULL ,
	[RowStartDate]  datetime DEFAULT '1/1/1900'  NULL ,
	[RowEndDate]  datetime  DEFAULT '12/31/9999'  NULL ,
	[RowChangeReason]  nvarchar(200)   NOT NULL ,
	CONSTRAINT [PK_fudgemart.DimTitle] PRIMARY KEY CLUSTERED 
( [TitleKey] )
) ON [PRIMARY]
;


SET IDENTITY_INSERT fudgemart.DimTitle ON
;
PRINT 'Lets insert some Data in Fudgemart.DimTitle'
INSERT INTO fudgemart.DimTitle (TitleKey, TitleID, TitleName, TitleBluRayAvailable, TitleDVDAvailable, RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason)
VALUES (-1, -1, 'unknown', -1, -1, 'Y', '12/31/1899', '12/31/9999', 'N/A')
;
SET IDENTITY_INSERT fudgemart.DimTitle OFF
;




PRINT 'HERE COMES THE FACT TABLES!!'



--Edited to move ProductRetailPrice and ProductWholesalePrice
--From DimProduct
/* Create table fudgemart.FactSales */
PRINT 'CREATE TABLE Fudgemart.FactSales'
CREATE TABLE fudgemart.FactSales (
    [OrderKey]  int  NOT NULL ,
	[ProductKey]  int  NOT NULL ,
	[ProductName] nvarchar(50) NOT NULL,
	[InsertAuditKey]  int  NULL ,
	[UpdateAuditKey]  int  NULL ,
	[Quantity]  int   NOT NULL ,
	[UnitPrice]  money   NOT NULL ,
	[SoldAmount]  money   NOT NULL ,
	[OrderDateKey]  int   NOT NULL ,
	[ShippedDateKey]  int   NOT NULL ,
 CONSTRAINT [PK_fudgemart.FactSales] PRIMARY KEY NONCLUSTERED ( [OrderKey] , [ProductKey] )) ON [PRIMARY]
;



/* Create table fudgemart.FactInventory */
PRINT 'CREATE TABLE Fudgemart.FactInventory'
CREATE TABLE fudgemart.FactInventory (
    [TitleKey]  int IDENTITY,
	[TitleID]  nvarchar(20)  NOT NULL ,
	[TitleName] nvarchar(200)  NOT NULL ,
	[InventoryBluRayInStock]  bit   NOT NULL ,
	[InventoryDVDInStock]  bit   NOT NULL ,
    [InventoryAsOfDate]  INT  NULL ,
	[InsertAuditKey]  int NULL ,
	[UpdateAuditKey]  int NULL ,
	CONSTRAINT [PK_fudgemart.FactInventory] PRIMARY KEY  ( [TitleKey])) ON [PRIMARY]

;

--DROP TABLE fudgemart.FactInventory

----------------------------------------------------------------------
--END CREATING TABLES
----------------------------------------------------------------------



----------------------------------------------------------------------
--CREATING CONSTRAINT
----------------------------------------------------------------------
PRINT 'Start ALTER TABLE Statements'

ALTER TABLE fudgemart.FactSales ADD CONSTRAINT
   FK_Fudgemart_FactSales_OrderKey FOREIGN KEY
   (
   OrderKey
   ) REFERENCES Fudgemart.DimOrder
   ( OrderKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;


 ALTER TABLE fudgemart.FactSales ADD CONSTRAINT
   FK_Fudgemart_FactSales_ProductKey FOREIGN KEY
   (
   ProductKey
   ) REFERENCES fudgemart.DimProduct
   ( ProductKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;


ALTER TABLE fudgemart.FactInventory ADD CONSTRAINT
   FK_fudgemart_FactInventory_Account_TitleKey FOREIGN KEY
   (
  TitleKey
   ) REFERENCES fudgemart.DimTitle
   ( TitleKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;


ALTER TABLE fudgemart.FactInventory ADD CONSTRAINT
   FK_fudgemart_FactInventory_DateKey FOREIGN KEY
   (
   InventoryAsOfDate
   ) REFERENCES fudgemart.DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;



ALTER TABLE fudgemart.FactSales ADD CONSTRAINT
   FK_fudgemart_FactSales_OrderDateKey FOREIGN KEY
   (
   OrderDateKey
   ) REFERENCES fudgemart.DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;



ALTER TABLE fudgemart.FactSales ADD CONSTRAINT
   FK_fudgemart_FactSales_ShippedDateKey FOREIGN KEY
   (
   ShippedDateKey
   ) REFERENCES fudgemart.DimDate
   ( DateKey )
     ON UPDATE  NO ACTION
     ON DELETE  NO ACTION
;


-- PRINT 'End ALTER TABLE Statements'

----------------------------------------------------------------------
--END THE CREATION CONSTRAINT
----------------------------------------------------------------------
