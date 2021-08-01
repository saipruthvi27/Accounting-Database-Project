USE H_accounting;
DROP PROCEDURE IF EXISTS `skv2019_sp`;

-- The tpycal delimiter for Stored procedures is a double dollar sign
DELIMITER $$

	CREATE PROCEDURE `skv2019_sp`(varCalendarYear YEAR)
	BEGIN
  
	-- Define variables inside procedure
    DECLARE vRevenue 			DOUBLE DEFAULT 0;
    DECLARE vReturns 			DOUBLE DEFAULT 0;
    DECLARE vCOGS 			DOUBLE DEFAULT 0;
    DECLARE vGrossprofit 		DOUBLE DEFAULT 0;
    DECLARE vSelling 			DOUBLE DEFAULT 0;
    DECLARE vAdmin 			DOUBLE DEFAULT 0;
    DECLARE vOtherIncome		DOUBLE DEFAULT 0;
    DECLARE vOtherExp			DOUBLE DEFAULT 0;
    DECLARE vEBIT				DOUBLE DEFAULT 0;
    DECLARE vIncomeTax		DOUBLE DEFAULT 0;
	DECLARE vOtherTax			DOUBLE DEFAULT 0;
	DECLARE vProfitLoss		DOUBLE DEFAULT 0;

	-- Calculate the value and store them into the variables declared
    #vRevenue
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vRevenue
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'REV';
            
    #vReturns
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vReturns
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'RET';       

    #vCOGS
	SELECT SUM(IFNULL(joen.debit,0)*-1 + IFNULL(joen.credit,0)) INTO vCOGS
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'COGS';   

    #vGrossprofit
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vGrossprofit
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code IN ('REV', 'RET', 'COGS');            

    #vSelling
	SELECT SUM(IFNULL(joen.debit,0)*-1 + IFNULL(joen.credit,0)) INTO vSelling
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'SEXP';   
	
	#vAdmin
	SELECT SUM(IFNULL(joen.debit,0)*-1 + IFNULL(joen.credit,0)) INTO vAdmin
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'GEXP';   

	#vOtherIncome
	SELECT SUM(IFNULL(joen.debit,0) + IFNULL(joen.credit,0)) INTO vOtherIncome
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'OI';  

	#vOtherExp
	SELECT SUM(IFNULL(joen.debit,0)*-1 + IFNULL(joen.credit,0)) INTO vOtherExp
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'OEXP';  
            
	#vEBIT
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vEBIT
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code IN ('REV','RET', 'COGS','GEXP','SEXP','OEXP','OI');  

	#vIncomeTax
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vIncomeTax
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'INCTAX';  
            
	#vOtherTax
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vOtherTax
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'OTHTAX';  

	#vProfitLoss
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vProfitLoss
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0;  

#create P&L table
DROP TABLE IF EXISTS tmp_skv2019_table;

	CREATE TABLE tmp_skv2019_table
		(	Sl_No INT, 
			Label VARCHAR(50), 
			Amount VARCHAR(50)
		);

	-- Insert the header for the report
	INSERT INTO tmp_skv2019_table 
			(Sl_No, Label, Amount)
			VALUES (1, 'PROFIT AND LOSS STATEMENT', "In USD"),
				   (2, '', ''),
				   (3, 'Revenue', format(vRevenue,0)),
                   (4, 'Returns, Refunds, Discounts', format(IFNULL(vReturns,0),0)),
                   (5, 'Cost of goods sold', format(vCOGS,0)),
                   (6, 'Gross Profit (Loss)', format(vGrossprofit, 0)),
                   (7, 'Selling Expenses',format(IFNULL(vSelling,0),0)),
                   (8, 'Administrative Expenses',format(IFNULL(vAdmin,0),0)),
                   (9, 'Other Income' , format(IFNULL(vOtherIncome,0),0)),
                   (10, 'Other Expenses', format(IFNULL(vOtherExp,0),0)),
                   (11, 'Earnings before interest and taxes (EBIT)', format(IFNULL(vEBIT,0),0)),
                   (12, 'Income Tax', format(IFNULL(vIncomeTax,0),0)),
                   (13, 'Other Tax', format(IFNULL(vOtherTax,0),0)),
                   (14, 'Profit for the year', format(IFNULL(vProfitLoss,0),0))
;

END $$

DELIMITER ;

#call stored procedures for PL
CALL skv2019_sp(2019);
	
SELECT * FROM tmp_skv2019_table;    

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

#create BS table
DROP PROCEDURE IF EXISTS `skv2019_sp`;
DROP TABLE IF EXISTS tmp_skv2019_table;

-- The tpycal delimiter for Stored procedures is a double dollar sign
DELIMITER $$

	CREATE PROCEDURE `skv2019_sp`(varCalendarYear YEAR)
	BEGIN
  
	-- Define variables inside procedure
    DECLARE vCA 			DOUBLE DEFAULT 0;
    DECLARE vFA 			DOUBLE DEFAULT 0;
    DECLARE vDA 			DOUBLE DEFAULT 0;
    DECLARE vCL				DOUBLE DEFAULT 0;
    DECLARE vLLL 			DOUBLE DEFAULT 0;
    DECLARE vDL 			DOUBLE DEFAULT 0;
    DECLARE vEQ				DOUBLE DEFAULT 0;
    DECLARE vTotalAsset		DOUBLE DEFAULT 0;
    DECLARE vTotalLiabi		DOUBLE DEFAULT 0;
    DECLARE vEquiLiabi		DOUBLE DEFAULT 0;

	-- Calculate the value and store them into the variables declared
    #vCA
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vCA
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'CA'
            AND je.debit_credit_balanced = 1;

    #vFA
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vFA
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'FA'
            AND je.debit_credit_balanced = 1;		

    #vDA
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vDA
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'DA'
            AND je.debit_credit_balanced = 1;

    #vCL
	SELECT SUM(IFNULL(joen.debit,0)*-1 + IFNULL(joen.credit,0)) INTO vCL
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'CL'
            AND je.debit_credit_balanced = 1;	

    #vLLL
	SELECT SUM(IFNULL(joen.debit,0)*1 + IFNULL(joen.credit,0)) INTO vLLL
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'LLL'
            AND je.debit_credit_balanced = 1;	

    #vDL
	SELECT SUM(IFNULL(joen.debit,0)*1 + IFNULL(joen.credit,0)) INTO vDL
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'DL'
            AND je.debit_credit_balanced = 1;

    #vEQ
	SELECT SUM(IFNULL(joen.debit,0)*1 + IFNULL(joen.credit,0)) INTO vEQ
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'EQ'
            AND je.debit_credit_balanced = 1;	

    #vTotalAsset
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vTotalAsset
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code IN ('CA','FA','DA')
            AND je.debit_credit_balanced = 1;	

    #vTotalLiabi
	SELECT SUM(IFNULL(joen.debit,0)*-1 + IFNULL(joen.credit,0)) INTO vTotalLiabi
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code IN ('CL','LLL','DL')
            AND je.debit_credit_balanced = 1;	
	
        #vEquiLiabi
	SELECT SUM(IFNULL(joen.debit,0)*-1 + IFNULL(joen.credit,0)) INTO vEquiLiabi
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code NOT IN ('CA','FA','DA')
            AND je.debit_credit_balanced = 1;	
            
	-- Create BS table
	CREATE TABLE tmp_skv2019_table
		(	balance_sheet_line_number INT, 
			label VARCHAR(50), 
			amount VARCHAR(50)
		);
  
	-- Insert the header for the report
	INSERT INTO tmp_skv2019_table 
			(balance_sheet_line_number, label, amount)
			VALUES (1, 'BALANCE SHEET', "In USD"),
				   (2, '', ''),
				   (3, 'Current Assets', format(IFNULL(varCA, 0),0)),
                   (4, 'Fixed Assets', format(IFNULL(varFA, 0),0)),
                   (5, 'Deferred Assets', format(IFNULL(varDA, 0),0)),
                   (6, 'Total Assets', format(IFNULL(varTotalAsset, 0),0)),
                   (7, 'Current Liabilities', format(IFNULL(varCL, 0),0)),
                   (8, 'Long-term Liabilities', format(IFNULL(varLLL, 0),0)),
                   (9, 'Deferred Liabilities' , format(IFNULL(varDL, 0),0)),
                   (10, 'Total Liabilities', format(IFNULL(varTotalLiabi, 0),0)),
                   (11, 'Equity', format(IFNULL(varEQ, 0),0)),
                   (12, 'Total Equity and Liabilities', format(IFNULL(varEquiLiabi, 0),0));
            
  END $$

DELIMITER ;          

#call stored procedures for BS
CALL skv2019_sp(2019);
	
SELECT * FROM tmp_skv2019_table;  
  
	-- Insert value
	INSERT INTO tmp_skv2019_table 
			(balance_sheet_line_number, label, amount)
			VALUES (3, Revenue, format(varRetainedEarnings, 0)),
				   (3, 'Gross Profit (Loss)', format(varRetainedEarnings, 0))
            ;
            
            
	

-- Create P/L 
  SELECT ss.statement_section,
			SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) as balance
		
    FROM journal_entry_line_item AS joen
		
			INNER JOIN `account` 				AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 			AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section		AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
    WHERE YEAR(je.entry_date) = varCalendarYear
		AND ac.profit_loss_section_id <> 0
	
    GROUP BY ac.profit_loss_section_id;

-- Create B/S
  SELECT ss.statement_section,
			SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) as balance
		
    FROM journal_entry_line_item AS joen
		
			INNER JOIN `account` 				AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 			AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section		AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
    WHERE YEAR(je.entry_date) = varCalendarYear
		AND ac.balance_sheet_section_id <> 0
	
    GROUP BY ac.balance_sheet_section_id;	
    



CREATE PROCEDURE `skv2019_sp`
    
-- Define variables inside procedure
DECLARE varRetainedEarnings 	DOUBLE DEFAULT 0;

-- Calculate the value and store them into the variables declared
SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO varRetainedEarnings
    FROM journal_entry_line_item AS joen
		
			INNER JOIN `account` 				AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 			AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section		AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
    WHERE YEAR(je.entry_date) = varCalendarYear
		AND ac.profit_loss_section_id <> 0;

DROP TABLE IF EXISTS tmp_skv2019_table;

CREATE TABLE tmp_skv2019_table
	(	balance_sheet_line_number INT, 
		label VARCHAR(50), 
		amount VARCHAR(50)
	);
  
  
-- Insert the header for the report
INSERT INTO tmp_skv2019_table 
	(balance_sheet_line_number, label, amount)
  VALUES (1, 'PROFIT AND LOSS STATEMENT', "In '000s of USD");
	
    
-- Insert an empth line
INSERT INTO tmp_skv2019_table 
	(balance_sheet_line_number, label, amount)
  VALUES (2, '', '');
  
  
-- Insert value
INSERT INTO tmp_skv2019_table 
	(balance_sheet_line_number, label, amount)
    VALUES (3, 'Gross Profit (Loss)', format(varGrossprofit / 1000, 2));
    
    
    END $$
    
DELIMITER ;
