-- 17�� �������� 


1. ��� ���̺�(employees)�� �����ϰ� �ִ� ��� ���α׷��� ã�� 2���� ����� �����϶�. 

<����>
1. USER_SOURCE �ý��� �信�� TEXT �÷� ���� ������̺��, �� employees�� ��Ī�� �ִ��� �˻��Ѵ�. 

SELECT *
FROM USER_SOURCE
WHERE TEXT LIKE '%EMPLOYEES%'
OR    TEXT LIKE '%employees%';

2. USER_DEPENDENCIES �ý��� �信�� REFERENCED_NAME �÷� ���� ������̺���� �ִ��� �˻��Ѵ�. 
SELECT *
FROM  USER_DEPENDENCIES
WHERE REFERENCED_NAME = 'EMPLOYEES';


2. "����� ��� - �α� ���̺�" ������ �α� ���̺� �α׸� ����� ��ƾ�� SALES_DETAIL_PRC ���ν����� �߰��ߴ�.
   �׷��� �ڼ��� ���� �α� ���̺� �����͸� �״� �κ��� ������ BEGIN ~ END ���� ������µ�, �� ������ �����ϱ�?

<����>   
SALES_DETAIL_PRC ���ν����� ����Ǹ鼭 ���� ������ ���� ����ó���η� ��� �Ű��� ROLLBACK�� �ȴ�. 
�׷��� ������ �߻��� ROLLBACK �Ǵ��� �α� ���̺��� ���������� �ԷµǾ�� �ϱ� ������,
������ BEGIN ~END ���� ���� Ʈ����� ó���� ���� �� ���̴�. 
   
   
3. �α� ���̺� �α׸� �״� ��ƾ�� �ϳ��� ���ν����� ������. ��, ������ Ʈ����� ó���� �ϵ��� �ؾ� �Ѵ�. 

<����>   

CREATE OR REPLACE PROCEDURE my_log_prc ( pn_log_id   NUMBER    -- �α� ���̵�
                                        ,ps_prg_name VARCHAR2  -- ���α׷���
                                        ,ps_param    VARCHAR2  -- �Ķ����
                                        ,ps_status   VARCHAR2  -- ����(START, END, ERROR)
                                        ,ps_desc     VARCHAR2  -- �α׳���
                                       )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;  -- ������ Ʈ����� ó��
BEGIN
	-- ps_status, ���� ���� ���� ó����ƾ�� �޸��Ѵ�. 
	
  IF ps_status = 'START' THEN   -- ���۷α��� ��� 
  
     INSERT INTO program_log (
  	                log_id, 
  	                program_name, 
  	                parameters, 
  	                state, 
  	                start_time )
           VALUES ( pn_log_id,
                    ps_prg_name,  
                    ps_param,
                    'Running',
                    SYSTIMESTAMP);  
  
  ELSIF ps_status = 'END' THEN -- ����α��� ��� 
  
      UPDATE program_log
         SET state    = 'Completed',
             end_time = SYSTIMESTAMP,
             log_desc = ps_desc || '�۾�����!'
      WHERE log_id    = pn_log_id;
  
  ELSIF ps_status = 'ERROR' THEN  -- �����α��� ��� 
  
      UPDATE program_log
         SET state   = 'Error',
             end_time = SYSTIMESTAMP,
             log_desc = ps_desc
       WHERE log_id   = pn_log_id; 
  
  END IF;
  
  COMMIT;
  
EXCEPTION WHEN OTHERS THEN 
   ROLLBACK;
   DBMS_OUTPUT.PUT_LINE('LOG ERROR : ' || SQLERRM);  
	
	
END;


4. �߰��� �α׷�ƾ�� �����ϰ� ��� 3������ ���� ���� ���ν����� ��ü�ϵ��� SALES_DETAIL_PRC ���ν����� �����غ���. 

<����>      

CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS
  
  PROCEDURE sales_detail_prc ( ps_month IN VARCHAR2, 
                               pn_amt   IN NUMBER,
                               pn_rate  IN NUMBER   )
  IS
     vn_total_time NUMBER := 0;     -- �ҿ�ð� ���� ���� 
     
     vn_log_id       NUMBER;          -- �α� ���̵� 
     vs_parameters  VARCHAR2(500);   -- �Ű�����   
     vs_prg_log      VARCHAR2(2000);  -- �α׳���
  BEGIN
    -- �Ű������� �� ���� �����´� 
    vs_parameters := 'ps_month => ' || ps_month || ', pn_amt => ' || pn_amt || ' , pn_rate => ' || pn_rate;
  	
      -- �α� ���̵� �� ����
      vn_log_id := prg_log_seq.NEXTVAL;  	    

      -- �α� ���ν��� ȣ�� (���� -> START)
      my_log_prc ( vn_log_id, 'ch17_src_test_pkg.sales_detail_prc', vs_parameters, 'START', '' );                  
                                       
  	
    --1. p_month�� �ش��ϴ� ���� CH17_SALES_DETAIL ������ ����
    vn_total_time := DBMS_UTILITY.GET_TIME;
	      
    DELETE CH17_SALES_DETAIL
     WHERE sales_month = ps_month;
     
    -- DELETE �ҿ�ð� ��� (�ʷ� ����ϱ� ���� 100���� ������)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time) / 100;
    
    -- DELETE �α� ���� �����
    vs_prg_log :=  'DELETE �Ǽ� : ' || SQL%ROWCOUNT || ' , �ҿ�ð�: ' || vn_total_time || CHR(13); 
     
    --2. p_month�� �ش��ϴ� ���� CH17_SALES_DETAIL ������ ����
    vn_total_time := DBMS_UTILITY.GET_TIME;
    
    INSERT INTO CH17_SALES_DETAIL
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
           
    -- INSERT �ҿ�ð� ���(�ʷ� ����ϱ� ���� 100���� ������)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time)  / 100;    
    
    -- INSERT �α� ���� �����
    vs_prg_log :=  vs_prg_log || 'INSERT �Ǽ� : ' || SQL%ROWCOUNT || ' , �ҿ�ð�: ' || vn_total_time || CHR(13);                 
           
    -- 3. �Ǹűݾ�(sales_amt)�� pn_amt ���� ū ���� pn_rate ���� ��ŭ �����Ѵ�.
    vn_total_time := DBMS_UTILITY.GET_TIME;
    
    UPDATE CH17_SALES_DETAIL
       SET sales_amt = sales_amt - ( sales_amt * pn_rate * 0.01)
     WHERE sales_month = ps_month
       AND sales_amt   > pn_amt;
       
    -- UPDATE �ҿ�ð� ��� (�ʷ� ����ϱ� ���� 100���� ������)
    vn_total_time := (DBMS_UTILITY.GET_TIME - vn_total_time)  / 100; 
      
    -- UPDATE �α� ���� �����
    vs_prg_log :=  vs_prg_log || 'UPDATE �Ǽ� : ' || SQL%ROWCOUNT || ' , �ҿ�ð�: ' || vn_total_time || CHR(13);          

    COMMIT; 
    
    -- �α� ���ν��� ȣ�� (���� -> END)
    my_log_prc ( vn_log_id, '', '', 'END', vs_prg_log);                   
    
    
  EXCEPTION WHEN OTHERS THEN
  
    -- �α� ���ν��� ȣ�� (���� -> ERROR)
    my_log_prc ( vn_log_id, '', '', 'ERROR', vs_prg_log);  
                 
        ROLLBACK;   
  
  END sales_detail_prc;
END ch17_src_test_pkg; 



   

   
