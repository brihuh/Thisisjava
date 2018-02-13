-- ����ó������

DECLARE 
   vi_num NUMBER := 0;
BEGIN
	
	 vi_num := 10 / 0;
	 
	 DBMS_OUTPUT.PUT_LINE('Success!');
	 
END;



DECLARE 
   vi_num NUMBER := 0;
BEGIN
	
	 vi_num := 10 / 0;
	 
	 DBMS_OUTPUT.PUT_LINE('Success!');
	 
EXCEPTION WHEN OTHERS THEN
	 
	 DBMS_OUTPUT.PUT_LINE('������ �߻��߽��ϴ�');	
END;


CREATE OR REPLACE PROCEDURE ch10_no_exception_proc 
IS
  vi_num NUMBER := 0;
BEGIN
	vi_num := 10 / 0;
	 
	DBMS_OUTPUT.PUT_LINE('Success!');
	
END;	


CREATE OR REPLACE PROCEDURE ch10_exception_proc 
IS
  vi_num NUMBER := 0;
BEGIN
	vi_num := 10 / 0;
	 
	DBMS_OUTPUT.PUT_LINE('Success!');
	
EXCEPTION WHEN OTHERS THEN
	 
	 DBMS_OUTPUT.PUT_LINE('������ �߻��߽��ϴ�');		
	
END;	


DECLARE 
   vi_num NUMBER := 0;
BEGIN
	
	 ch10_no_exception_proc;
	 	 
	 DBMS_OUTPUT.PUT_LINE('Success!');

END;

DECLARE 
   vi_num NUMBER := 0;
BEGIN
	
	 ch10_exception_proc;
	 	 
	 DBMS_OUTPUT.PUT_LINE('Success!');

END;


-- SQLCODE, SQLERRM�� �̿��� �������� ����

CREATE OR REPLACE PROCEDURE ch10_exception_proc 
IS
  vi_num NUMBER := 0;
BEGIN
	vi_num := 10 / 0;
	 
	DBMS_OUTPUT.PUT_LINE('Success!');
	
EXCEPTION WHEN OTHERS THEN
	 
 DBMS_OUTPUT.PUT_LINE('������ �߻��߽��ϴ�');		
 DBMS_OUTPUT.PUT_LINE( 'SQL ERROR CODE: ' || SQLCODE);
 DBMS_OUTPUT.PUT_LINE( 'SQL ERROR MESSAGE: ' || SQLERRM); -- �Ű����� ���� SQLERRM
 DBMS_OUTPUT.PUT_LINE( SQLERRM(SQLCODE)); -- �Ű����� �ִ� SQLERRM

	
END;	

EXEC ch10_exception_proc;


CREATE OR REPLACE PROCEDURE ch10_exception_proc 
IS
  vi_num NUMBER := 0;
BEGIN
	vi_num := 10 / 0;
	 
	DBMS_OUTPUT.PUT_LINE('Success!');
	
EXCEPTION WHEN OTHERS THEN
	 
 DBMS_OUTPUT.PUT_LINE('������ �߻��߽��ϴ�');		
 DBMS_OUTPUT.PUT_LINE( 'SQL ERROR CODE: ' || SQLCODE);
 DBMS_OUTPUT.PUT_LINE( 'SQL ERROR MESSAGE: ' || SQLERRM); 
 
 DBMS_OUTPUT.PUT_LINE( DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	
END;	


-- �ý��� ���� 

CREATE OR REPLACE PROCEDURE ch10_exception_proc 
IS
  vi_num NUMBER := 0;
BEGIN
	vi_num := 10 / 0;
	 
	DBMS_OUTPUT.PUT_LINE('Success!');
	
EXCEPTION WHEN ZERO_DIVIDE THEN
	 
	 DBMS_OUTPUT.PUT_LINE('������ �߻��߽��ϴ�');		
	 DBMS_OUTPUT.PUT_LINE('SQL ERROR CODE: ' || SQLCODE);
	 DBMS_OUTPUT.PUT_LINE('SQL ERROR MESSAGE: ' || SQLERRM);
	
END;	

EXEC ch10_exception_proc;



CREATE OR REPLACE PROCEDURE ch10_exception_proc 
IS
  vi_num NUMBER := 0;
BEGIN
	vi_num := 10 / 0;
	 
	DBMS_OUTPUT.PUT_LINE('Success!');
	
EXCEPTION WHEN ZERO_DIVIDE THEN
	          	 DBMS_OUTPUT.PUT_LINE('����1');		
	             DBMS_OUTPUT.PUT_LINE('SQL ERROR MESSAGE1: ' || SQLERRM);
	        WHEN OTHERS THEN
	          	 DBMS_OUTPUT.PUT_LINE('����2');		
	             DBMS_OUTPUT.PUT_LINE('SQL ERROR MESSAGE2: ' || SQLERRM);	
END;	

EXEC ch10_exception_proc;


CREATE OR REPLACE PROCEDURE ch10_upd_jobid_proc 
                  ( p_employee_id employees.employee_id%TYPE,
                    p_job_id      jobs.job_id%TYPE )
IS
  vn_cnt NUMBER := 0;
BEGIN
	
	SELECT COUNT(*)
	  INTO vn_cnt
	  FROM JOBS
	 WHERE JOB_ID = p_job_id;
	 
	IF vn_cnt = 0 THEN
	   DBMS_OUTPUT.PUT_LINE('job_id�� �����ϴ�');
	   RETURN;
	ELSE
	   UPDATE employees
	      SET job_id = p_job_id
	    WHERE employee_id = p_employee_id;
	
  END IF;
  
  COMMIT;
	
END;

EXEC ch10_upd_jobid_proc (200, 'SM_JOB2');



CREATE OR REPLACE PROCEDURE ch10_upd_jobid_proc 
                  ( p_employee_id employees.employee_id%TYPE,
                    p_job_id      jobs.job_id%TYPE )
IS
  vn_cnt NUMBER := 0;
BEGIN
	
	SELECT 1
	  INTO vn_cnt
	  FROM JOBS
	 WHERE JOB_ID = p_job_id;
	 
   UPDATE employees
      SET job_id = p_job_id
    WHERE employee_id = p_employee_id;
	
  COMMIT;
  
  EXCEPTION WHEN NO_DATA_FOUND THEN
                 DBMS_OUTPUT.PUT_LINE(SQLERRM);
                 DBMS_OUTPUT.PUT_LINE(p_job_id ||'�� �ش��ϴ� job_id�� �����ϴ�');
            WHEN OTHERS THEN
                 DBMS_OUTPUT.PUT_LINE('��Ÿ ����: ' || SQLERRM);
END;
                   

EXEC ch10_upd_jobid_proc (200, 'SM_JOB2');


CREATE OR REPLACE PROCEDURE ch10_upd_jobid_proc 
                  ( p_employee_id employees.employee_id%TYPE,
                    p_job_id      jobs.job_id%TYPE)
IS
  vn_cnt NUMBER := 0;
BEGIN
	
	SELECT 1
	  INTO vn_cnt
	  FROM JOBS
	 WHERE JOB_ID = p_job_id;
	 
   UPDATE employees
      SET job_id = p_job_id
    WHERE employee_id = p_employee_id;
	
  COMMIT;
  
  EXCEPTION WHEN NO_DATA_FOUND THEN
                 DBMS_OUTPUT.PUT_LINE(SQLERRM);
                 DBMS_OUTPUT.PUT_LINE(p_job_id ||'�� �ش��ϴ� job_id�� �����ϴ�');
            WHEN OTHERS THEN
                 DBMS_OUTPUT.PUT_LINE('��Ÿ ����: ' || SQLERRM);
END;

-- ����� ���� ����

CREATE OR REPLACE PROCEDURE ch10_ins_emp_proc ( 
                  p_emp_name       employees.emp_name%TYPE,
                  p_department_id  departments.department_id%TYPE )
IS
   vn_employee_id  employees.employee_id%TYPE;
   vd_curr_date    DATE := SYSDATE;
   vn_cnt          NUMBER := 0;
   
   ex_invalid_depid EXCEPTION; -- �߸��� �μ���ȣ�� ��� ���� ����
BEGIN
	
	 -- �μ����̺��� �ش� �μ���ȣ �������� üũ
	 SELECT COUNT(*)
	   INTO vn_cnt
	   FROM departments
	  WHERE department_id = p_department_id;
	  
	 IF vn_cnt = 0 THEN
	    RAISE ex_invalid_depid; -- ����� ���� ���� �߻�
	 END IF;
	 
	 -- employee_id�� max ���� +1
	 SELECT MAX(employee_id) + 1
	   INTO vn_employee_id
	   FROM employees;
	 
	 -- ����ڿ���ó�� �����̹Ƿ� ��� ���̺� �ּ��� �����͸� �Է���
	 INSERT INTO employees ( employee_id, emp_name, hire_date, department_id )
              VALUES ( vn_employee_id, p_emp_name, vd_curr_date, p_department_id );
              
   COMMIT;              
              
EXCEPTION WHEN ex_invalid_depid THEN -- ����� ���� ���� ó��
               DBMS_OUTPUT.PUT_LINE('�ش� �μ���ȣ�� �����ϴ�');
          WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE(SQLERRM);              
	
END;                	


EXEC ch10_ins_emp_proc ('ȫ�浿', 999);


CREATE OR REPLACE PROCEDURE ch10_ins_emp_proc ( 
                  p_emp_name       employees.emp_name%TYPE,
                  p_department_id  departments.department_id%TYPE,
                  p_hire_month  VARCHAR2  )
IS
   vn_employee_id  employees.employee_id%TYPE;
   vd_curr_date    DATE := SYSDATE;
   vn_cnt          NUMBER := 0;
   
   ex_invalid_depid EXCEPTION; -- �߸��� �μ���ȣ�� ��� ���� ����
   
   ex_invalid_month EXCEPTION; -- �߸��� �Ի���� ��� ���� ����
   PRAGMA EXCEPTION_INIT ( ex_invalid_month, -1843); -- ���ܸ�� �����ڵ� ����
BEGIN
	
	 -- �μ����̺��� �ش� �μ���ȣ �������� üũ
	 SELECT COUNT(*)
	   INTO vn_cnt
	   FROM departments
	  WHERE department_id = p_department_id;
	  
	 IF vn_cnt = 0 THEN
	    RAISE ex_invalid_depid; -- ����� ���� ���� �߻�
	 END IF;
	 
	 -- �Ի�� üũ (1~12�� ������ ������� üũ)
	 IF SUBSTR(p_hire_month, 5, 2) NOT BETWEEN '01' AND '12' THEN
	    RAISE ex_invalid_month; -- ����� ���� ���� �߻�
	 
	 END IF;
	 
	 
	 -- employee_id�� max ���� +1
	 SELECT MAX(employee_id) + 1
	   INTO vn_employee_id
	   FROM employees;
	 
	 -- ����ڿ���ó�� �����̹Ƿ� ��� ���̺� �ּ��� �����͸� �Է���
	 INSERT INTO employees ( employee_id, emp_name, hire_date, department_id )
              VALUES ( vn_employee_id, p_emp_name, TO_DATE(p_hire_month || '01'), p_department_id );
              
   COMMIT;              
              
EXCEPTION WHEN ex_invalid_depid THEN -- ����� ���� ���� ó��
               DBMS_OUTPUT.PUT_LINE('�ش� �μ���ȣ�� �����ϴ�');
          WHEN ex_invalid_month THEN -- �Ի�� ����� ���� ���� ó��
               DBMS_OUTPUT.PUT_LINE(SQLCODE);
               DBMS_OUTPUT.PUT_LINE(SQLERRM);
               DBMS_OUTPUT.PUT_LINE('1~12�� ������ ��� ���Դϴ�');               
          WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE(SQLERRM);              
	
END;    

EXEC ch10_ins_emp_proc ('ȫ�浿', 110, '201314');


-- RAISE�� RAISE_APPLICATOIN_ERROR

CREATE OR REPLACE PROCEDURE ch10_raise_test_proc ( p_num NUMBER)
IS

BEGIN
	IF p_num <= 0 THEN
	   RAISE INVALID_NUMBER;
  END IF;
  
  DBMS_OUTPUT.PUT_LINE(p_num);
  
EXCEPTION WHEN INVALID_NUMBER THEN
               DBMS_OUTPUT.PUT_LINE('����� �Է¹��� �� �ֽ��ϴ�');
          WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE(SQLERRM);
	
END;

EXEC ch10_raise_test_proc (-10);               



CREATE OR REPLACE PROCEDURE ch10_raise_test_proc ( p_num NUMBER)
IS

BEGIN
	IF p_num <= 0 THEN
	   --RAISE INVALID_NUMBER;
	   RAISE_APPLICATION_ERROR (-20000, '����� �Է¹��� �� �ִ� ���Դϴ�!');
  END IF;
  
  DBMS_OUTPUT.PUT_LINE(p_num);
  
EXCEPTION WHEN INVALID_NUMBER THEN
               DBMS_OUTPUT.PUT_LINE('����� �Է¹��� �� �ֽ��ϴ�');
          WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE(SQLCODE);
               DBMS_OUTPUT.PUT_LINE(SQLERRM);
	
END;

EXEC ch10_raise_test_proc (-10);               



-- ���� ���Ͽ�

CREATE TABLE error_log (
             error_seq     NUMBER,        -- ���� ������
             prog_name     VARCHAR2(80),  -- ���α׷���
             error_code    NUMBER,        -- �����ڵ�
             error_message VARCHAR2(300), -- ���� �޽���
             error_line    VARCHAR2(100), -- ���� ����
             error_date    DATE DEFAULT SYSDATE -- �����߻�����
             );
             
CREATE SEQUENCE error_seq
INCREMENT BY 1
START WITH 1
MINVALUE 1
MAXVALUE 999999
NOCYCLE
NOCACHE;

CREATE OR REPLACE PROCEDURE error_log_proc (
                  p_prog_name      error_log.prog_name%TYPE,
                  p_error_code     error_log.error_code%TYPE,
                  p_error_messgge  error_log.error_message%TYPE,
                  p_error_line     error_log.error_line%TYPE  )
IS

BEGIN
	
	INSERT INTO error_log (error_seq, prog_name, error_code, error_message, error_line)
	VALUES ( error_seq.NEXTVAL, p_prog_name, p_error_code, p_error_messgge, p_error_line );
	
	COMMIT;
	
END;                  


CREATE OR REPLACE PROCEDURE ch10_ins_emp2_proc ( 
                  p_emp_name       employees.emp_name%TYPE,
                  p_department_id  departments.department_id%TYPE,
                  p_hire_month     VARCHAR2 )
IS
   vn_employee_id  employees.employee_id%TYPE;
   vd_curr_date    DATE := SYSDATE;
   vn_cnt          NUMBER := 0;
   
   ex_invalid_depid EXCEPTION; -- �߸��� �μ���ȣ�� ��� ���� ����
   PRAGMA EXCEPTION_INIT ( ex_invalid_depid, -20000); -- ���ܸ�� �����ڵ� ����

   ex_invalid_month EXCEPTION; -- �߸��� �Ի���� ��� ���� ����
   PRAGMA EXCEPTION_INIT ( ex_invalid_month, -1843); -- ���ܸ�� �����ڵ� ����
   
   v_err_code error_log.error_code%TYPE;
   v_err_msg  error_log.error_message%TYPE;
   v_err_line error_log.error_line%TYPE;
BEGIN
 -- �μ����̺��� �ش� �μ���ȣ �������� üũ
 SELECT COUNT(*)
   INTO vn_cnt
   FROM departments
  WHERE department_id = p_department_id;
	  
 IF vn_cnt = 0 THEN
    RAISE ex_invalid_depid; -- ����� ���� ���� �߻�
 END IF;

-- �Ի�� üũ (1~12�� ������ ������� üũ)
 IF SUBSTR(p_hire_month, 5, 2) NOT BETWEEN '01' AND '12' THEN
    RAISE ex_invalid_month; -- ����� ���� ���� �߻�
 END IF;

 -- employee_id�� max ���� +1
 SELECT MAX(employee_id) + 1
   INTO vn_employee_id
   FROM employees;
 
-- ����ڿ���ó�� �����̹Ƿ� ��� ���̺� �ּ��� �����͸� �Է���
INSERT INTO employees ( employee_id, emp_name, hire_date, department_id )
            VALUES ( vn_employee_id, p_emp_name, TO_DATE(p_hire_month || '01'), p_department_id );              
 COMMIT;

EXCEPTION WHEN ex_invalid_depid THEN -- ����� ���� ���� ó��
               v_err_code := SQLCODE;
               v_err_msg  := '�ش� �μ��� �����ϴ�';
               v_err_line := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
               ROLLBACK;
               error_log_proc ( 'ch10_ins_emp2_proc', v_err_code, v_err_msg, v_err_line); 
          WHEN ex_invalid_month THEN -- �Ի�� ����� ���� ���� ó��
               v_err_code := SQLCODE;
               v_err_msg  := SQLERRM;
               v_err_line := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
               ROLLBACK;
               error_log_proc ( 'ch10_ins_emp2_proc', v_err_code, v_err_msg, v_err_line); 
          WHEN OTHERS THEN
               v_err_code := SQLCODE;
               v_err_msg  := SQLERRM;
               v_err_line := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
               ROLLBACK;  
               error_log_proc ( 'ch10_ins_emp2_proc', v_err_code, v_err_msg, v_err_line);        	
END;


EXEC ch10_ins_emp2_proc ('HONG', 1000, '201401'); -- �߸��� �μ�

EXEC ch10_ins_emp2_proc ('HONG', 100, '201413'); -- �߸��� ��


SELECT *
  FROM  error_log ;
  
  

CREATE TABLE app_user_define_error (
             error_code    NUMBER,         -- �����ڵ�
             error_message VARCHAR2(300),  -- ���� �޽���
             create_date   DATE DEFAULT SYSDATE, -- ������� 
             PRIMARY KEY (error_code)
             );
             
             
INSERT INTO app_user_define_error ( error_code, error_message ) VALUES (-1843, '������ ���� �������մϴ�');
INSERT INTO app_user_define_error ( error_code, error_message ) VALUES (-20000, '�ش� �μ��� �����ϴ�');

COMMIT;
             
             
CREATE OR REPLACE PROCEDURE error_log_proc (
                  p_prog_name      error_log.prog_name%TYPE,
                  p_error_code     error_log.error_code%TYPE,
                  p_error_messgge  error_log.error_message%TYPE,
                  p_error_line     error_log.error_line%TYPE  )
IS
  vn_error_code     error_log.error_code%TYPE    := p_error_code;
  vn_error_message  error_log.error_message%TYPE := p_error_messgge;
  
BEGIN
	
	-- ����� ���� ���� ���̺��� ���� �޽����� �޾ƿ��� �κ��� BLOCK���� ���Ѵ�.
	-- �ش� �޽����� ���� ��� ó���� ���ؼ�....
	BEGIN
	  -- 
	  SELECT error_message 
	    INTO vn_error_message
	    FROM app_user_define_error 
	   WHERE error_code = vn_error_code;
	 
   	-- �ش� ������ ���̺� ���ٸ� �Ű������� �޾ƿ� �޽����� �״�� �Ҵ��Ѵ�. 
	  EXCEPTION WHEN NO_DATA_FOUND THEN
	               vn_error_message :=  p_error_messgge;
	
  END;
	
	INSERT INTO error_log (error_seq, prog_name, error_code, error_message, error_line)
	VALUES ( error_seq.NEXTVAL, p_prog_name, vn_error_code, vn_error_message, p_error_line );
	
	COMMIT;
	
END;                 


CREATE OR REPLACE PROCEDURE ch10_ins_emp2_proc ( 
                  p_emp_name       employees.emp_name%TYPE,
                  p_department_id  departments.department_id%TYPE,
                  p_hire_month     VARCHAR2 )
IS
   vn_employee_id  employees.employee_id%TYPE;
   vd_curr_date    DATE := SYSDATE;
   vn_cnt          NUMBER := 0;
   
   ex_invalid_depid EXCEPTION; -- �߸��� �μ���ȣ�� ��� ���� ����
   PRAGMA EXCEPTION_INIT ( ex_invalid_depid, -20000); -- ���ܸ�� �����ڵ� ����

   ex_invalid_month EXCEPTION; -- �߸��� �Ի���� ��� ���� ����
   PRAGMA EXCEPTION_INIT ( ex_invalid_month, -1843); -- ���ܸ�� �����ڵ� ����
   
  -- ���� ���� ���� ����
   v_err_code error_log.error_code%TYPE;
   v_err_msg  error_log.error_message%TYPE;
   v_err_line error_log.error_line%TYPE;
BEGIN
 -- �μ����̺��� �ش� �μ���ȣ �������� üũ
 SELECT COUNT(*)
   INTO vn_cnt
   FROM departments
  WHERE department_id = p_department_id;
	  
 IF vn_cnt = 0 THEN
    RAISE ex_invalid_depid; -- ����� ���� ���� �߻�
 END IF;

-- �Ի�� üũ (1~12�� ������ ������� üũ)
 IF SUBSTR(p_hire_month, 5, 2) NOT BETWEEN '01' AND '12' THEN
    RAISE ex_invalid_month; -- ����� ���� ���� �߻�
 END IF;

 -- employee_id�� max ���� +1
 SELECT MAX(employee_id) + 1
   INTO vn_employee_id
   FROM employees;
 
-- ����ڿ���ó�� �����̹Ƿ� ��� ���̺� �ּ��� �����͸� �Է���
INSERT INTO employees ( employee_id, emp_name, hire_date, department_id )
            VALUES ( vn_employee_id, p_emp_name, TO_DATE(p_hire_month || '01'), p_department_id );              
 COMMIT;

EXCEPTION WHEN ex_invalid_depid THEN -- ����� ���� ���� ó��
               v_err_code := SQLCODE;
               v_err_line := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
               ROLLBACK;
               error_log_proc ( 'ch10_ins_emp2_proc', v_err_code, v_err_msg, v_err_line); 
          WHEN ex_invalid_month THEN -- �Ի�� ����� ���� ���� ó��
               v_err_code := SQLCODE;
               v_err_line := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
               ROLLBACK;
               error_log_proc ( 'ch10_ins_emp2_proc', v_err_code, v_err_msg, v_err_line); 
          WHEN OTHERS THEN
               v_err_code := SQLCODE;
               v_err_msg  := SQLERRM;
               v_err_line := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
               ROLLBACK;  
               error_log_proc ( 'ch10_ins_emp2_proc', v_err_code, v_err_msg, v_err_line);        	
END;

-- �߸��� �μ�
EXEC ch10_ins_emp2_proc ('HONG', 1000, '201401');
 
-- �߸��� ��
EXEC ch10_ins_emp2_proc ('HONG', 100, '201413'); 


SELECT *
  FROM  error_log ;



-- COMMIT �� ROLLBACK

CREATE TABLE ch10_sales (
       sales_month   VARCHAR2(8),
       country_name  VARCHAR2(40),
       prod_category VARCHAR2(50),
       channel_desc  VARCHAR2(20),
       sales_amt     NUMBER );
       
       
CREATE OR REPLACE PROCEDURE iud_ch10_sales_proc 
            ( p_sales_month ch10_sales.sales_month%TYPE )
IS

BEGIN
	INSERT INTO ch10_sales (sales_month, country_name, prod_category, channel_desc, sales_amt)
	SELECT A.SALES_MONTH, 
       C.COUNTRY_NAME, 
       D.PROD_CATEGORY,
       E.CHANNEL_DESC,
       SUM(A.AMOUNT_SOLD)
  FROM SALES A, CUSTOMERS B, COUNTRIES C, PRODUCTS D, CHANNELS E
 WHERE A.SALES_MONTH = p_sales_month
   AND A.CUST_ID = B.CUST_ID
   AND B.COUNTRY_ID = C.COUNTRY_ID
   AND A.PROD_ID = D.PROD_ID
   AND A.CHANNEL_ID = E.CHANNEL_ID
 GROUP BY A.SALES_MONTH, 
         C.COUNTRY_NAME, 
       D.PROD_CATEGORY,
       E.CHANNEL_DESC;
	
END;            

EXEC iud_ch10_sales_proc ( '199901');

SELECT COUNT(*)
FROM ch10_sales ;


CREATE OR REPLACE PROCEDURE iud_ch10_sales_proc 
            ( p_sales_month ch10_sales.sales_month%TYPE )
IS

BEGIN
	INSERT INTO ch10_sales (sales_month, country_name, prod_category, channel_desc, sales_amt)	   
	SELECT A.SALES_MONTH, 
       C.COUNTRY_NAME, 
       D.PROD_CATEGORY,
       E.CHANNEL_DESC,
       SUM(A.AMOUNT_SOLD)
  FROM SALES A, CUSTOMERS B, COUNTRIES C, PRODUCTS D, CHANNELS E
 WHERE A.SALES_MONTH = p_sales_month
   AND A.CUST_ID = B.CUST_ID
   AND B.COUNTRY_ID = C.COUNTRY_ID
   AND A.PROD_ID = D.PROD_ID
   AND A.CHANNEL_ID = E.CHANNEL_ID
 GROUP BY A.SALES_MONTH, 
         C.COUNTRY_NAME, 
       D.PROD_CATEGORY,
       E.CHANNEL_DESC;
       
 COMMIT;
 --ROLLBACK;
	
END;         

TRUNCATE TABLE ch10_sales;

EXEC iud_ch10_sales_proc ( '199901');

SELECT COUNT(*)
FROM ch10_sales ;


TRUNCATE TABLE ch10_sales;


ALTER TABLE ch10_sales ADD CONSTRAINTS pk_ch10_sales PRIMARY KEY (sales_month, country_name, prod_category, channel_desc);



CREATE OR REPLACE PROCEDURE iud_ch10_sales_proc 
            ( p_sales_month ch10_sales.sales_month%TYPE )
IS

BEGIN
	
	INSERT INTO ch10_sales (sales_month, country_name, prod_category, channel_desc, sales_amt)	   
	SELECT A.SALES_MONTH, 
       C.COUNTRY_NAME, 
       D.PROD_CATEGORY,
       E.CHANNEL_DESC,
       SUM(A.AMOUNT_SOLD)
  FROM SALES A, CUSTOMERS B, COUNTRIES C, PRODUCTS D, CHANNELS E
 WHERE A.SALES_MONTH = p_sales_month
   AND A.CUST_ID = B.CUST_ID
   AND B.COUNTRY_ID = C.COUNTRY_ID
   AND A.PROD_ID = D.PROD_ID
   AND A.CHANNEL_ID = E.CHANNEL_ID
 GROUP BY A.SALES_MONTH, 
         C.COUNTRY_NAME, 
       D.PROD_CATEGORY,
       E.CHANNEL_DESC;
       
 COMMIT;

EXCEPTION WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE(SQLERRM);
               ROLLBACK;
	
END;   

EXEC iud_ch10_sales_proc ( '199901');

SELECT COUNT(*)
FROM ch10_sales ;


CREATE TABLE ch10_country_month_sales (
               sales_month   VARCHAR2(8),
               country_name  VARCHAR2(40),
               sales_amt     NUMBER,
               PRIMARY KEY (sales_month, country_name) );
              



CREATE OR REPLACE PROCEDURE iud_ch10_sales_proc 
            ( p_sales_month  ch10_sales.sales_month%TYPE, 
              p_country_name ch10_sales.country_name%TYPE )
IS

BEGIN
	
	--���� ������ ����
	DELETE ch10_sales
	 WHERE sales_month  = p_sales_month
	   AND country_name = p_country_name;
	   
	   
	-- �űԷ� ��, ������ �Ű������� �޾� INSERT 
	-- DELETE�� �����ϹǷ� PRIMARY KEY �ߺ��� �߻�ġ ����
	INSERT INTO ch10_sales (sales_month, country_name, prod_category, channel_desc, sales_amt)	   
	SELECT A.SALES_MONTH, 
       C.COUNTRY_NAME, 
       D.PROD_CATEGORY,
       E.CHANNEL_DESC,
       SUM(A.AMOUNT_SOLD)
  FROM SALES A, CUSTOMERS B, COUNTRIES C, PRODUCTS D, CHANNELS E
 WHERE A.SALES_MONTH  = p_sales_month
   AND C.COUNTRY_NAME = p_country_name
   AND A.CUST_ID = B.CUST_ID
   AND B.COUNTRY_ID = C.COUNTRY_ID
   AND A.PROD_ID = D.PROD_ID
   AND A.CHANNEL_ID = E.CHANNEL_ID
 GROUP BY A.SALES_MONTH, 
         C.COUNTRY_NAME, 
       D.PROD_CATEGORY,
       E.CHANNEL_DESC;
       
 -- SAVEPOINT Ȯ���� ���� UPDATE
  -- ����ð����� �ʸ� ������ ���ڷ� ��ȯ�� �� * 10 (�Ź� �ʴ� �޶����Ƿ� ���������� ���� �� �� ���� �Ź� �޶���)
 UPDATE ch10_sales
    SET sales_amt = 10 * to_number(to_char(sysdate, 'ss'))
  WHERE sales_month  = p_sales_month
	   AND country_name = p_country_name;
	   
 -- SAVEPOINT ����      
 SAVEPOINT mysavepoint;      
 
 
 -- ch10_country_month_sales ���̺� INSERT
 -- �ߺ� �Է� �� PRIMARY KEY �ߺ���
 INSERT INTO ch10_country_month_sales 
       SELECT sales_month, country_name, SUM(sales_amt)
         FROM ch10_sales
        WHERE sales_month  = p_sales_month
	        AND country_name = p_country_name
	      GROUP BY sales_month, country_name;         
       
 COMMIT;

EXCEPTION WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE(SQLERRM);
               ROLLBACK TO mysavepoint; -- SAVEPOINT ������ ROLLBACK
               COMMIT; -- SAVEPOINT ���������� COMMIT

	
END;   

TRUNCATE TABLE ch10_sales;

EXEC iud_ch10_sales_proc ( '199901', 'Italy');

SELECT DISTINCT sales_amt
FROM ch10_sales;



EXEC iud_ch10_sales_proc ( '199901', 'Italy');

SELECT DISTINCT sales_amt
FROM ch10_sales;


