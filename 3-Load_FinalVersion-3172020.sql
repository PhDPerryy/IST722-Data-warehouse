----------------------------------------------------------------------
-- THIS SCRIPT DOES DATA LOAD
----------------------------------------------------------------------

--Run 3rd

USE ist722_grblock_oa2_dw;

----------------------------------------------------------------------
--BEGIN CREATING TABLES
----------------------------------------------------------------------

PRINT 'Start Table Creation'

/* Create table fudgemart.DimOrder */

INSERT INTO [fudgemart].[DimOrder] (
	[OrderID],
	[CustomerID],
	[OrderDate],
	[ShippedDate],
	[RowChangeReason],
	[RowIsCurrent],
	[RowStartDate]
)
SELECT o.order_id, o.customer_id, o.order_date, o.shipped_date, 'NA', 'Y', o.order_date 
FROM [ist722_grblock_oa2_stage].[dbo].[stgFudgemartOrders] o
;


/*Load DimProduct*/
/*Here useing case statement to normalize empty values*/
INSERT INTO [fudgemart].[DimProduct] (
	[ProductID], 
	[ProductName],
	[product_retail_price],
    [product_is_active],
	RowChangeReason,RowIsCurrent,RowStartDate)
SELECT
	[product_id], [product_name],[product_retail_price],[product_is_active], 'NA', 'Y', GETDATE()
	FROM [ist722_grblock_oa2_stage].[dbo].[stgFudgemartProducts]
;


/*Load DimDate*/
INSERT INTO [fudgemart].[DimDate](
    [DateKey],
	[Date], 
	[FullDateUSA], 
	[DayOfWeek], 
	[DayName], 
	[DayOfMonth], 
	[DayOfYear], 
	[WeekOfYear], 
	[MonthName], 
	[MonthOfYear], 
    [Quarter], 
	[QuarterName],
	[Year], 
	[IsWeekday]
)
SELECT 
	[DateKey],[Date], [FullDateUSA], [DayOfWeekUSA], [DayName], [DayOfMonth], [DayOfYear], [WeekOfYear], 
	[MonthName],[MonthYear], [Quarter], [QuarterName],[Year], [IsWeekday]
	FROM [ist722_grblock_oa2_stage].[dbo].[stgFudgemartDates]
;

/* Create table fudgemart.DimTitle */
INSERT INTO [fudgemart].[DimTitle](
   [TitleID],
   [TitleName],
   [TitleBluRayAvailable],
   [TitleDVDAvailable],
   [RowChangeReason],
   [RowIsCurrent],
   [RowStartDate]
)
SELECT 
	[title_id], [title_name],[title_bluray_available],[title_dvd_available],'NA', 'Y', GETDATE()
	FROM [ist722_grblock_oa2_stage].[dbo].[stgFudgemartTitles]
;


/*Load SalesFact*/
INSERT INTO [fudgemart].[FactSales](
    [OrderKey], 
    [ProductKey],
    [ProductName],
    [Quantity],
    [UnitPrice],
    [SoldAmount],
    [OrderDateKey],
    [ShippedDateKey]
)
SELECT 
	[order_id],
	[product_id],
	[product_name],
    [order_qty],
	[product_retail_price],
    [order_qty]*s.product_retail_price AS ExtendedPriceAmount,
	[ExternalSources2].dbo.[getDateKey](s.order_date) 	AS order_date,
	[ExternalSources2].[dbo].[getDateKey](s.shipped_date) AS 	shipped_date
	FROM [ist722_grblock_oa2_stage].[dbo].[stgFudgemartSales] s
;
/*Load table fudgemart.FactInventory*/
INSERT INTO [fudgemart].[FactInventory](
    [TitleID],
	[TitleName],
	[InventoryBluRayInStock],
	[InventoryDVDInStock],
	[InventoryAsOfDate]
)
SELECT 
	[title_id],
	[title_name],
    [title_bluray_available],
	[title_dvd_available],
    [ExternalSources2].[dbo].[getDateKey](f.title_date_modified) AS title_date_modified
FROM [ist722_grblock_oa2_stage].[dbo].[stgFudgemartInventory] f
;








----------------------------------------------------------------------
--END CREATING TABLES
----------------------------------------------------------------------




