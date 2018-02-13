01. �ҽ�����

-- (2) �ҽ� ���
SELECT *
FROM USER_SOURCE
ORDER BY NAME, LINE;


CREATE OR REPLACE PACKAGE ch17_src_test_pkg IS

   pv_name VARCHAR2(30) := 'ch17_SRC_TEST_PKG';

END ch17_src_test_pkg;

SELECT *
FROM USER_SOURCE
WHERE NAME = 'ch17_SRC_TEST_PKG'
ORDER BY LINE;


CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS

   pvv_temp VARCHAR2(30) := 'TEST';

END ch17_src_test_pkg;

SELECT *
FROM USER_SOURCE
WHERE NAME = 'ch17_SRC_TEST_PKG'
ORDER BY TYPE, LINE;


SELECT *
FROM USER_SOURCE
WHERE TEXT LIKE '%EMPLOYEES%'
   OR TEXT LIKE '%employees%' 
ORDER BY name, type, line;


CREATE TABLE bk_source_20150106 AS
SELECT *
FROM USER_SOURCE
ORDER BY NAME, TYPE, LINE;

SELECT *
FROM bk_source_20150106;


-- 02. �������

CREATE TABLE ch17_sales_detail (
             channnel_name VARCHAR2(50),
             prod_name     VARCHAR2(300),
             cust_name     VARCHAR2(100),
             emp_name      VARCHAR2(100),
             sales_date    DATE,
             sales_month   VARCHAR2(6),
             sales_qty     NUMBER   DEFAULT 0,
             sales_amt     NUMBER   DEFAULT 0 );
             
CREATE INDEX idx_ch17_sales_dtl on ch17_sales_detail (sales_month);    



CREATE OR REPLACE PACKAGE ch17_src_test_pkg IS

  pv_name VARCHAR2(30) := 'ch17_SRC_TEST_PKG';
   
  PROCEDURE sales_detail_prc ( ps_month IN VARCHAR2, 
                               pn_amt   IN NUMBER,
                               pn_rate  IN NUMBER
                             );

END ch17_src_test_pkg;



CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS
  
  PROCEDURE sales_detail_prc ( ps_month IN VARCHAR2, 
                               pn_amt   IN NUMBER,
                               pn_rate  IN NUMBER   )
  IS
  
  BEGIN
    --1. p_month�� �ش��ϴ� ���� ch17_SALES_DETAIL ������ ����
    DELETE ch17_SALES_DETAIL
     WHERE sales_month = ps_month;
     
    --2. p_month�� �ش��ϴ� ���� ch17_SALES_DETAIL ������ ����
    INSERT INTO ch17_SALES_DETAIL
    SELECT b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month,
           sum(a.quantity_sold),
           sum(a.amount_sold)
      FROM sales a,
           products b,
           customers c,
           channels d,
           employees e
    WHERE a.sales_month = ps_month
      AND a.prod_id     = b.prod_id
      AND a.cust_id     = c.cust_id
      AND a.channel_id  = d.channel_id
      AND a.employee_id = e.employee_id
    GROUP BY b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month;
           
           
    -- 3. �Ǹűݾ�(sales_amt)�� pn_amt ���� ū ���� pn_rate ���� ��ŭ �����Ѵ�.
    UPDATE ch17_SALES_DETAIL
       SET sales_amt = sales_amt - ( sales_amt * pn_rate * 0.01)
     WHERE sales_month = ps_month
       AND sales_amt   > pn_amt;
       
    
    COMMIT;
    
  EXCEPTION WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE(SQLERRM);
         ROLLBACK;          
  
  
  END sales_detail_prc;

END ch17_src_test_pkg;

-- (1) DBMS_OUTPUT.PUT_LINE
BEGIN
  ch17_src_test_pkg.sales_detail_prc ( ps_month => '200112',
                                       pn_amt   => 0,
                                       pn_rate  => 1 );
END;


SELECT sales_month, count(*)
  FROM ch17_SALES_DETAIL
 GROUP BY sales_month
 ORDER BY sales_month;
 

CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS
  
  PROCEDURE sales_detail_prc ( ps_month IN VARCHAR2, 
                               pn_amt   IN NUMBER,
                               pn_rate  IN NUMBER   )
  IS
  
  BEGIN
  	DBMS_OUTPUT.PUT_LINE('--------------<������ ���>---------------------');
  	DBMS_OUTPUT.PUT_LINE('ps_month : ' || ps_month);
  	DBMS_OUTPUT.PUT_LINE('pn_amt   : ' || pn_amt);
  	DBMS_OUTPUT.PUT_LINE('pn_rate  : ' || pn_rate);  	
  	DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
  	
    --1. p_month�� �ش��ϴ� ���� ch17_SALES_DETAIL ������ ����
    DELETE ch17_SALES_DETAIL
     WHERE sales_month = ps_month;
     
    DBMS_OUTPUT.PUT_LINE('DELETE �Ǽ� : ' || SQL%ROWCOUNT);
     
    --2. p_month�� �ش��ϴ� ���� ch17_SALES_DETAIL ������ ����
    INSERT INTO ch17_SALES_DETAIL
    SELECT b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month,
           sum(a.quantity_sold),
           sum(a.amount_sold)
      FROM sales a,
           products b,
           customers c,
           channels d,
           employees e
    WHERE a.sales_month = ps_month
      AND a.prod_id     = b.prod_id
      AND a.cust_id     = c.cust_id
      AND a.channel_id  = d.channel_id
      AND a.employee_id = e.employee_id
    GROUP BY b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month;
           
    DBMS_OUTPUT.PUT_LINE('INSERT �Ǽ� : ' || SQL%ROWCOUNT);           
           
           
    -- 3. �Ǹűݾ�(sales_amt)�� pn_amt ���� ū ���� pn_rate ���� ��ŭ �����Ѵ�.
    UPDATE ch17_SALES_DETAIL
       SET sales_amt = sales_amt - ( sales_amt * pn_rate * 0.01)
     WHERE sales_month = ps_month
       AND sales_amt   > pn_amt;
       
    DBMS_OUTPUT.PUT_LINE('UPDATE �Ǽ� : ' || SQL%ROWCOUNT);           
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('���⼭�� ����???? : ' || SQL%ROWCOUNT);    
    
  EXCEPTION WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE(SQLERRM);
         ROLLBACK;          
  
  
  END sales_detail_prc;

END ch17_src_test_pkg; 

BEGIN
  ch17_src_test_pkg.sales_detail_prc ( ps_month => '200112',
                                       pn_amt   => 10000,
                                       pn_rate  => 1 );
END;


-- (2) �ҿ�ð� ���

CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS
  
  PROCEDURE sales_detail_prc ( ps_month IN VARCHAR2, 
                               pn_amt   IN NUMBER,
                               pn_rate  IN NUMBER   )
  IS
     vd_sysdate     DATE;        -- �������� 
     vn_total_time NUMBER := 0;  -- �ҿ�ð� ���� ���� 
  
  BEGIN
  	DBMS_OUTPUT.PUT_LINE('--------------<������ ���>---------------------');
  	DBMS_OUTPUT.PUT_LINE('ps_month : ' || ps_month);
  	DBMS_OUTPUT.PUT_LINE('pn_amt   : ' || pn_amt);
  	DBMS_OUTPUT.PUT_LINE('pn_rate  : ' || pn_rate);  	
  	DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
  	
    --1. p_month�� �ش��ϴ� ���� ch17_SALES_DETAIL ������ ����
    
	  -- delete �� vd_sysdate�� ����ð� ����
	  vd_sysdate := SYSDATE;
	      
    DELETE ch17_SALES_DETAIL
     WHERE sales_month = ps_month;
     
    -- DELETE �ҿ�ð� ��� (�ʷ� ����ϱ� ���� * 60 * 60 * 24�� ����)
    vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;
       
     
    DBMS_OUTPUT.PUT_LINE('DELETE �Ǽ� : ' || SQL%ROWCOUNT || ' , �ҿ�ð�: ' || vn_total_time );
     
    --2. p_month�� �ش��ϴ� ���� ch17_SALES_DETAIL ������ ����
    vd_sysdate := SYSDATE;
    
    INSERT INTO ch17_SALES_DETAIL
    SELECT b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month,
           sum(a.quantity_sold),
           sum(a.amount_sold)
      FROM sales a,
           products b,
           customers c,
           channels d,
           employees e
    WHERE a.sales_month = ps_month
      AND a.prod_id     = b.prod_id
      AND a.cust_id     = c.cust_id
      AND a.channel_id  = d.channel_id
      AND a.employee_id = e.employee_id
    GROUP BY b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month;
           
    -- INSERT �ҿ�ð� ��� (�ʷ� ����ϱ� ���� * 60 * 60 * 24�� ����)
    vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;           
           
    DBMS_OUTPUT.PUT_LINE('INSERT �Ǽ� : ' || SQL%ROWCOUNT || ' , �ҿ�ð�: ' || vn_total_time ); 
           
           
    -- 3. �Ǹűݾ�(sales_amt)�� pn_amt ���� ū ���� pn_rate ���� ��ŭ �����Ѵ�.
    vd_sysdate := SYSDATE;
    
    UPDATE ch17_SALES_DETAIL
       SET sales_amt = sales_amt - ( sales_amt * pn_rate * 0.01)
     WHERE sales_month = ps_month
       AND sales_amt   > pn_amt;
       
    -- UPDATE �ҿ�ð� ��� (�ʷ� ����ϱ� ���� * 60 * 60 * 24�� ����)
    vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;               
       
    DBMS_OUTPUT.PUT_LINE('UPDATE �Ǽ� : ' || SQL%ROWCOUNT || ' , �ҿ�ð�: ' || vn_total_time ); 
    
    COMMIT;
  
    
  EXCEPTION WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE(SQLERRM);
         ROLLBACK;          
  
  
  END sales_detail_prc;

END ch17_src_test_pkg; 


BEGIN
  ch17_src_test_pkg.sales_detail_prc ( ps_month => '200112',
                                       pn_amt   => 50,
                                       pn_rate  => 32.5 );
END;


-- DBMS_UTILITY.GET_TIME ���

CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS
  
  PROCEDURE sales_detail_prc ( ps_month IN VARCHAR2, 
                               pn_amt   IN NUMBER,
                               pn_rate  IN NUMBER   )
  IS
     vn_total_time NUMBER := 0;  -- �ҿ�ð� ���� ���� 
  
  BEGIN
  	DBMS_OUTPUT.PUT_LINE('--------------<������ ���>---------------------');
  	DBMS_OUTPUT.PUT_LINE('ps_month : ' || ps_month);
  	DBMS_OUTPUT.PUT_LINE('pn_amt   : ' || pn_amt);
  	DBMS_OUTPUT.PUT_LINE('pn_rate  : ' || pn_rate);  	
  	DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
  	
    --1. p_month�� �ش��ϴ� ���� ch17_SALES_DETAIL ������ ����
    
	  -- delete �� �ð� �������� 
	  vn_total_time := DBMS_UTILITY.GET_TIME;
	      
    DELETE ch17_SALES_DETAIL
     WHERE sales_month = ps_month;
     
    -- DELETE �ҿ�ð� ��� (�ʷ� ����ϱ� ���� 100���� ������)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time) / 100;
       
     
    DBMS_OUTPUT.PUT_LINE('DELETE �Ǽ� : ' || SQL%ROWCOUNT || ' , �ҿ�ð�: ' || vn_total_time );
     
    --2. p_month�� �ش��ϴ� ���� ch17_SALES_DETAIL ������ ����
    vn_total_time := DBMS_UTILITY.GET_TIME;
    
    INSERT INTO ch17_SALES_DETAIL
    SELECT b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month,
           sum(a.quantity_sold),
           sum(a.amount_sold)
      FROM sales a,
           products b,
           customers c,
           channels d,
           employees e
    WHERE a.sales_month = ps_month
      AND a.prod_id     = b.prod_id
      AND a.cust_id     = c.cust_id
      AND a.channel_id  = d.channel_id
      AND a.employee_id = e.employee_id
    GROUP BY b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month;
           
    -- INSERT �ҿ�ð� ��� (�ʷ� ����ϱ� ���� 100���� ������)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time)  / 100;        
           
    DBMS_OUTPUT.PUT_LINE('INSERT �Ǽ� : ' || SQL%ROWCOUNT || ' , �ҿ�ð�: ' || vn_total_time ); 
           
           
    -- 3. �Ǹűݾ�(sales_amt)�� pn_amt ���� ū ���� pn_rate ���� ��ŭ �����Ѵ�.
    vn_total_time := DBMS_UTILITY.GET_TIME;
    
    UPDATE ch17_SALES_DETAIL
       SET sales_amt = sales_amt - ( sales_amt * pn_rate * 0.01)
     WHERE sales_month = ps_month
       AND sales_amt   > pn_amt;
       
    -- UPDATE �ҿ�ð� ��� (�ʷ� ����ϱ� ���� 100���� ������)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time)  / 100;        
       
    DBMS_OUTPUT.PUT_LINE('UPDATE �Ǽ� : ' || SQL%ROWCOUNT || ' , �ҿ�ð�: ' || vn_total_time ); 
    
    COMMIT;
  
    
  EXCEPTION WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE(SQLERRM);
         ROLLBACK;          
  
  
  END sales_detail_prc;

END ch17_src_test_pkg; 


-- (3) �α� ���̺�
CREATE TABLE program_log (
       log_id        NUMBER,         -- �α� ���̵�
       program_name  VARCHAR2(100),  -- ���α׷���
       parameters    VARCHAR2(500),  -- ���α׷� �Ű�����
       state         VARCHAR2(10),   -- ����(Running, Completed, Error) 
       start_time    TIMESTAMP,      -- ���۽ð�
       end_time      TIMESTAMP,      -- ����ð�
       log_desc      VARCHAR2(2000)  -- �α׳��� 
       );
       
-- �α� ���̺� ������
CREATE SEQUENCE prg_log_seq
INCREMENT BY 1
START WITH 1
MINVALUE 1
MAXVALUE 1000000
NOCYCLE
NOCACHE;
              

CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS
  
  PROCEDURE sales_detail_prc ( ps_month IN VARCHAR2, 
                               pn_amt   IN NUMBER,
                               pn_rate  IN NUMBER   )
  IS
     vn_total_time NUMBER := 0;     -- �ҿ�ð� ���� ���� 
     
     vn_log_id     NUMBER;          -- �α� ���̵� 
     vs_parameters VARCHAR2(500);   -- �Ű�����   
     vs_prg_log    VARCHAR2(2000);  -- �α׳���
  BEGIN
  	-- �Ű������� �� ���� �����´� 
  	vs_parameters := 'ps_month => ' || ps_month || ', pn_amt => ' || pn_amt || ' , pn_rate => ' || pn_rate;
  	
  	BEGIN
  	    -- �α� ���̵� �� ����
  	    vn_log_id := prg_log_seq.NEXTVAL;
  	    
  	    -- �α� ���̺� ������ ����
  	    INSERT INTO program_log (
  	                log_id, 
  	                program_name, 
  	                parameters, 
  	                state, 
  	                start_time )
           VALUES ( vn_log_id,
                    'ch17_src_test_pkg.sales_detail_prc',  
                    vs_parameters,
                    'Running',
                    SYSTIMESTAMP);
                    
        COMMIT;
    END;
  	
    --1. p_month�� �ش��ϴ� ���� ch17_SALES_DETAIL ������ ����
    
	  -- delete �� �ð� �������� 
	  vn_total_time := DBMS_UTILITY.GET_TIME;
	      
    DELETE ch17_SALES_DETAIL
     WHERE sales_month = ps_month;
     
    -- DELETE �ҿ�ð� ��� (�ʷ� ����ϱ� ���� 100���� ������)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time) / 100;
    
    -- DELETE �α� ���� �����
    vs_prg_log :=  'DELETE �Ǽ� : ' || SQL%ROWCOUNT || ' , �ҿ�ð�: ' || vn_total_time || CHR(13); 
     
    --2. p_month�� �ش��ϴ� ���� ch17_SALES_DETAIL ������ ����
    vn_total_time := DBMS_UTILITY.GET_TIME;
    
    INSERT INTO ch17_SALES_DETAIL
    SELECT b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month,
           sum(a.quantity_sold),
           sum(a.amount_sold)
      FROM sales a,
           products b,
           customers c,
           channels d,
           employees e
    WHERE a.sales_month = ps_month
      AND a.prod_id     = b.prod_id
      AND a.cust_id     = c.cust_id
      AND a.channel_id  = d.channel_id
      AND a.employee_id = e.employee_id
    GROUP BY b.prod_name, 
           d.channel_desc,
           c.cust_name,
           e.emp_name,
           a.sales_date,
           a.sales_month;
           
    -- INSERT �ҿ�ð� ��� (�ʷ� ����ϱ� ���� 100���� ������)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time)  / 100;    
    
    -- INSERT �α� ���� �����
    vs_prg_log :=  vs_prg_log || 'INSERT �Ǽ� : ' || SQL%ROWCOUNT || ' , �ҿ�ð�: ' || vn_total_time || CHR(13);                 
           
    -- 3. �Ǹűݾ�(sales_amt)�� pn_amt ���� ū ���� pn_rate ���� ��ŭ �����Ѵ�.
    vn_total_time := DBMS_UTILITY.GET_TIME;
    
    UPDATE ch17_SALES_DETAIL
       SET sales_amt = sales_amt - ( sales_amt * pn_rate * 0.01)
     WHERE sales_month = ps_month
       AND sales_amt   > pn_amt;
       
    -- UPDATE �ҿ�ð� ��� (�ʷ� ����ϱ� ���� 100���� ������)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time)  / 100; 
      
    -- UPDATE �α� ���� �����
    vs_prg_log :=  vs_prg_log || 'UPDATE �Ǽ� : ' || SQL%ROWCOUNT || ' , �ҿ�ð�: ' || vn_total_time || CHR(13);          

    COMMIT;  
    
    
    BEGIN
    
       -- �α� ����
       UPDATE program_log
          SET state = 'Completed',
              end_time = SYSTIMESTAMP,
              log_desc = vs_prg_log || '�۾�����!'
        WHERE log_id = vn_log_id;
        
       COMMIT;
     
    END;
    
  EXCEPTION WHEN OTHERS THEN
        BEGIN 
          vs_prg_log := SQLERRM;
          -- ���� �α�
          UPDATE program_log
             SET state = 'Error',
                 end_time = SYSTIMESTAMP,
                 log_desc = vs_prg_log
           WHERE log_id = vn_log_id;
           
          COMMIT;
         
        END;
       
        ROLLBACK;          
  
  
  END sales_detail_prc;

END ch17_src_test_pkg; 


BEGIN
  ch17_src_test_pkg.sales_detail_prc ( ps_month => '200112',
                                       pn_amt   => 50,
                                       pn_rate  => 32.5 );
END;


SELECT *
  FROM program_log;

-- 03. �������� �����
-- (1) ����

CREATE OR REPLACE PROCEDURE ch17_dynamic_test ( p_emp_id   NUMBER, 
                                                p_emp_name VARCHAR2, 
                                                p_job_id   VARCHAR2
                                              )
IS
  vs_query    VARCHAR2(1000);
  vn_cnt      NUMBER := 0;
  vs_empname  employees.emp_name%TYPE := '%' || p_emp_name || '%';
  
BEGIN
	
	-- �������� ����
	vs_query :=             'SELECT COUNT(*) ' || CHR(13);
	vs_query := vs_query || '  FROM employees ' || CHR(13);
  vs_query := vs_query || ' WHERE 1=1 ' || CHR(13);
  
  -- ����� NULL�� �ƴϸ� �����߰�
  IF p_emp_id IS NOT NULL THEN     
     vs_query := vs_query || ' AND employee_id = ' || p_emp_id || CHR(13);
  END IF;
  
  -- ������� NULL�� �ƴϸ� �����߰�	
  IF p_emp_name IS NOT NULL THEN     
     vs_query := vs_query || ' AND emp_name like ' || '''' || vs_empname || '''' || CHR(13);
  END IF;	
	-- JOB_ID�� NULL�� �ƴϸ� �����߰� 
  IF p_job_id IS NOT NULL THEN     
     vs_query := vs_query || ' AND job_id = ' || '''' || p_job_id || '''' || CHR(13);
  END IF;		
  -- �������� ����, �Ǽ��� vn_cnt ������ ��´�. 
  EXECUTE IMMEDIATE vs_query INTO vn_cnt;
  
  DBMS_OUTPUT.PUT_LINE('����Ǽ� : ' || vn_cnt);
  DBMS_OUTPUT.PUT_LINE(vs_query);  
	
END;              

EXEC ch17_dynamic_test (171, NULL, NULL );

EXEC ch17_dynamic_test (NULL, 'Jon', NULL );

EXEC ch17_dynamic_test (NULL, NULL, 'SA_REP' );

EXEC ch17_dynamic_test (NULL, 'Jon', 'SA_REP' );

-- (2) CLOB Ÿ���� �̿��� �����

CREATE TABLE ch17_dyquery (
             program_name  VARCHAR2(50),
             query_text    CLOB );
             
             
CREATE OR REPLACE PROCEDURE ch17_dynamic_test ( p_emp_id   NUMBER, 
                                                p_emp_name VARCHAR2, 
                                                p_job_id   VARCHAR2
                                              )
IS
  vs_query    VARCHAR2(1000);
  vn_cnt      NUMBER := 0;
  vs_empname  employees.emp_name%TYPE := '%' || p_emp_name || '%';
  
BEGIN
	
	-- �������� ����
	vs_query :=             'SELECT COUNT(*) ' || CHR(13);
	vs_query := vs_query || '  FROM employees ' || CHR(13);
  vs_query := vs_query || ' WHERE 1=1 ' || CHR(13);
  
  -- ����� NULL�� �ƴϸ� �����߰�
  IF p_emp_id IS NOT NULL THEN     
     vs_query := vs_query || ' AND employee_id = ' || p_emp_id || CHR(13);
  END IF;
  
  -- ������� NULL�� �ƴϸ� �����߰�	
  IF p_emp_name IS NOT NULL THEN     
     vs_query := vs_query || ' AND emp_name like ' || '''' || vs_empname || '''' || CHR(13);
  END IF;	
	-- JOB_ID�� NULL�� �ƴϸ� �����߰� 
  IF p_job_id IS NOT NULL THEN     
     vs_query := vs_query || ' AND job_id = ' || '''' || p_job_id || '''' || CHR(13);
  END IF;		
  -- �������� ����, �Ǽ��� vn_cnt ������ ��´�. 
  EXECUTE IMMEDIATE vs_query INTO vn_cnt;
  
  DBMS_OUTPUT.PUT_LINE('����Ǽ� : ' || vn_cnt);
  --DBMS_OUTPUT.PUT_LINE(vs_query);  
  
  -- ���� �����͸� ��� �����Ѵ�. 
  DELETE ch17_dyquery;
  
  -- ���������� ch17_dyquery �� �ִ´�.
  INSERT INTO ch17_dyquery (program_name, query_text)
  VALUES ( 'ch17_dynamic_test', vs_query);
  
  COMMIT;
	
END;                   


EXEC ch17_dynamic_test (NULL, 'Jon', 'SA_REP' );

SELECT  *
FROM ch17_dyquery;

-- 04. DML���� ������ ������ ����
--(1) ����ǰų� ���� �� �����͸� �����غ���

CREATE OR REPLACE ch17_upd_test_prc ( pn_emp_id NUMBER,
                                      pn_rate   NUMBER )
IS

BEGIN
	-- �޿� = �޿� * pn_rate * 0.01
	UPDATE employees
     SET salary = salary * pn_rate * 0.01
   WHERE employee_id = pn_emp_id;
   
  DBMS_OUTPUT.PUT_LINE('��� : ' || pn_emp_id);
  DBMS_OUTPUT.PUT_LINE('�޿���??? : ');
 
 COMMIT;
	
END;



CREATE OR REPLACE PROCEDURE ch17_upd_test_prc ( pn_emp_id NUMBER,
                                      pn_rate   NUMBER )
IS
  vn_salary NUMBER := 0; -- ���ŵ� �޿��� �޾ƿ� ����
BEGIN
	-- �޿� = �޿� * pn_rate * 0.01
	UPDATE employees
     SET salary = salary * pn_rate * 0.01
   WHERE employee_id = pn_emp_id;
   
  -- �޿��� ��ȸ�Ѵ�.
  SELECT salary 
    INTO vn_salary
    FROM employees
   WHERE employee_id = pn_emp_id;
   
  DBMS_OUTPUT.PUT_LINE('��� : ' || pn_emp_id);
  DBMS_OUTPUT.PUT_LINE('�޿� : ' || vn_salary);
 
 COMMIT;
	
END;

                                
-- (2) RETURNING INTO ���� �̿��� �����

-- �� ���� �ο� UPDATE
DECLARE
  vn_salary   NUMBER := 0;
  vs_empname  VARCHAR2(30); 
BEGIN

  -- 171�� ����� �޿��� 10000�� ����
  UPDATE employees
     SET salary = 10000
   WHERE employee_id = 171
  RETURNING emp_name, salary 
       INTO vs_empname, vn_salary;
       
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('���� ����� : ' || vs_empname);
  DBMS_OUTPUT.PUT_LINE('���� �޿� : ' || vn_salary); 
END;


-- �� ���� �ο� UPDATE
DECLARE
  -- ���ڵ� Ÿ�� ����  
  TYPE NT_EMP_REC IS RECORD (
       emp_name      employees.emp_name%type,
       department_id employees.department_id%type,
       retire_date   employees.retire_date%type);
       
  -- NT_EMP_REC ���ڵ带 ��ҷ� �ϴ� ��ø���̺� ����
  TYPE NTT_EMP IS TABLE OF NT_EMP_REC;
  -- NTT_EMP ��ø���̺� ���� ����
  VR_EMP NTT_EMP;
  
BEGIN
  -- 100�� �μ��� retire_date�� �������ڷ� ...
  UPDATE employees
     SET retire_date = SYSDATE
   WHERE department_id = 100
  RETURNING emp_name, department_id, retire_date
  BULK COLLECT  INTO VR_EMP;
       
  COMMIT;
  
  FOR i in VR_EMP.FIRST .. VR_EMP.LAST
  LOOP
    DBMS_OUTPUT.PUT_LINE(i || '--------------------------------');
    DBMS_OUTPUT.PUT_LINE('���� ����� : ' || VR_EMP(i).emp_name);
    DBMS_OUTPUT.PUT_LINE('���� �μ� : ' || VR_EMP(i).department_id);
    DBMS_OUTPUT.PUT_LINE('retire_date : ' || VR_EMP(i).retire_date);
  END LOOP;
  

END;

-- �� ���� �ο� DELETE

CREATE TABLE emp_bk AS
SELECT *
FROM employees;


DECLARE
  vn_salary   NUMBER := 0;
  vs_empname  VARCHAR2(30); 
BEGIN

  -- 171�� ��� ����
  DELETE emp_bk
   WHERE employee_id = 171
  RETURNING emp_name, salary 
       INTO vs_empname, vn_salary;
       
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('���� ����� : ' || vs_empname);
  DBMS_OUTPUT.PUT_LINE('������ �޿� : ' || vn_salary); 
END;


-- �� ���� �ο� DELETE
DECLARE
  -- ���ڵ� Ÿ�� ����  
  TYPE NT_EMP_REC IS RECORD (
       emp_name      employees.emp_name%type,
       department_id employees.department_id%type,
       job_id        employees.job_id%type);
        
  -- NT_EMP_REC ���ڵ带 ��ҷ� �ϴ� ��ø���̺� ����
  TYPE NTT_EMP IS TABLE OF NT_EMP_REC;
  -- NTT_EMP ��ø���̺� ���� ����
  VR_EMP NTT_EMP;
  
BEGIN
  -- 60�� �μ��� ���� ��� ����  ...
  DELETE emp_bk
   WHERE department_id = 60
  RETURNING emp_name, department_id, job_id
  BULK COLLECT  INTO VR_EMP;
       
  COMMIT;
  
  FOR i in VR_EMP.FIRST .. VR_EMP.LAST
  LOOP
    DBMS_OUTPUT.PUT_LINE(i || '--------------------------------');
    DBMS_OUTPUT.PUT_LINE('���� ����� : ' || VR_EMP(i).emp_name);
    DBMS_OUTPUT.PUT_LINE('���� �μ� : ' || VR_EMP(i).department_id);
    DBMS_OUTPUT.PUT_LINE('retire_date : ' || VR_EMP(i).job_id);
  END LOOP;
  

END;
