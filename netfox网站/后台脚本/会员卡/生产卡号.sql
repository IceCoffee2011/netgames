

/*----------------------------------------------------------------------
-- 版权：2009,深圳市网狐科技有限公司
-- 时间：2009-04-10
-- 作者：guoshulang@foxmail.com
--
-- 用途：生成会员卡
-- 返回值:
----------------------------------------------------------------------*/

use QPTreasureDB
go

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[WEB_GameCardTypeInsert]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[WEB_GameCardTypeInsert]
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[WEB_GameCardGetInfo]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[WEB_GameCardGetInfo]
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[WEB_GameCardInsert]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[WEB_GameCardInsert]
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[WEB_GameCardDelete]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[WEB_GameCardDelete]
GO

-- 写入卡类
CREATE PROC WEB_GameCardTypeInsert
	@strCardTitle NVARCHAR(64),
	@dwScore INT,
	@dwOverDate INT,
	@bitIsPresent BIT,
	@dwMemberOrder INT,

	@dwCardID INT OUTPUT

WITH ENCRYPTION AS


-- 属性设置
SET NOCOUNT ON

-- 
DECLARE @CardID INT

-- 执行逻辑
BEGIN
	
	SELECT @CardID=CardID FROM GameCardTypeInfo(NOLOCK) 
	WHERE CardTitle=@strCardTitle AND Score=@dwScore 
			AND OverDate=@dwOverDate AND IsPresent=@bitIsPresent AND MemberOrder=@dwMemberOrder

	IF @CardID IS NOT NULL
	BEGIN
		SELECT @dwCardID=@CardID
		RETURN 0
	END
	
	INSERT GameCardTypeInfo (CardTitle, Score, OverDate, IsPresent,	MemberOrder)
	VALUES (@strCardTitle, @dwScore, @dwOverDate, @bitIsPresent, @dwMemberOrder)

	SELECT @CardID=CardID FROM GameCardTypeInfo(NOLOCK) 
	WHERE CardTitle=@strCardTitle AND Score=@dwScore 
			AND OverDate=@dwOverDate AND IsPresent=@bitIsPresent AND MemberOrder=@dwMemberOrder

	SELECT @dwCardID=@CardID		
	
END
RETURN 0
GO

-- 列明文卡号
CREATE PROC WEB_GameCardGetInfo	

WITH ENCRYPTION AS


-- 属性设置
SET NOCOUNT ON


-- 执行逻辑
BEGIN
	SELECT 	* FROM GameCardTmpInfo (NOLOCK)
END
RETURN 0
GO

-- 写入卡号
CREATE PROC WEB_GameCardInsert
	@strCardNo VARCHAR(31),
	@strEncryptionCardPass	VARCHAR(32),
	@strCardPass VARCHAR(16),
	@dwCardTypeID INT,
	@dwBatchNo INT

WITH ENCRYPTION AS


-- 属性设置
SET NOCOUNT ON

DECLARE @CardTypeID INT
DECLARE @Memo VARCHAR(255)

-- 执行逻辑
BEGIN
	
	IF EXISTS (SELECT CardNo FROM GameCardNoInfo(NOLOCK) WHERE CardNo=@strCardNo)
	BEGIN
		RETURN 1
	END

	SELECT @CardTypeID=CardID, @Memo=(CardTitle +'  ' + Memo)
	FROM GameCardTypeInfo WHERE CardID=@dwCardTypeID

	INSERT GameCardNoInfo (CardNo, CardPass, CardTypeID, BatchNo)
	VALUES (@strCardNo, @strEncryptionCardPass, @dwCardTypeID, @dwBatchNo)

	INSERT GameCardTmpInfo (CardNo, CardPassword, CardTypeID, Memo)
	VALUES (@strCardNo, @strCardPass, @CardTypeID, @Memo)

	
END
RETURN 0
GO

-- 删除卡号
CREATE PROC WEB_GameCardDelete
	@strCardIDLists VARCHAR(64)

WITH ENCRYPTION AS


-- 属性设置
SET NOCOUNT ON


-- 执行逻辑
BEGIN
	
	Declare @strDynamicSql VARCHAR(1000)     --动态SQL
	
	Set @strDynamicSql = 'DELETE FROM GameCardNoInfo WHERE [ID] IN(' + @strCardIDLists + ')'
	
	EXEC(@strDynamicSql)

	
END
RETURN 0
GO