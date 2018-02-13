-- 02. �ϰ�ó��
-- (1) BULK COLLECT ��

CREATE TABLE emp_bulk (
        bulk_id         NUMBER        NOT NULL, 
        employee_id     NUMBER(6)     NOT NULL,   
        emp_name        VARCHAR2(80)  NOT NULL,
        email           VARCHAR2(50),
        phone_number    VARCHAR2(30),
        hire_date       DATE          NOT NULL,
        salary          NUMBER(8,2),  
        manager_id      NUMBER(6),    
        commission_pct  NUMBER(2,2),  
        retire_date     DATE,         
        department_id   NUMBER(6),    
        job_id          VARCHAR2(10),
        dep_name        VARCHAR2(100),
        job_title       VARCHAR2(80)
        ) ;
        

BEGIN
	FOR i IN 1..10000
	LOOP
	
	  INSERT INTO emp_bulk
	        ( bulk_id, 
	          employee_id, emp_name, email, 
	          phone_number, hire_date, salary, manager_id, 
	          commission_pct, retire_date, department_id, job_id)
	  SELECT i, 
	         employee_id, emp_name, email, 
	         phone_number, hire_date, salary, manager_id, 
	         commission_pct, retire_date, department_id, job_id
	    FROM employees;   
	         
	
	
  END LOOP;
	
	COMMIT;
	
END;


SELECT COUNT(*)
  FROM emp_bulk;
  
  
-- �Ϲ� Ŀ��  
DECLARE
  -- Ŀ������ 
  CURSOR c1 IS
  SELECT employee_id
   FROM emp_bulk;
   
  vn_cnt      NUMBER := 0;  
  vn_emp_id   NUMBER; 
  vd_sysdate  DATE;
  vn_total_time NUMBER := 0;
BEGIN
	-- ������ vd_sysdate�� ����ð� ����
	vd_sysdate := SYSDATE;
	
	OPEN c1;
	
	LOOP
	  FETCH c1 INTO vn_emp_id;
	  EXIT WHEN c1%NOTFOUND;
	  
	  -- ����Ƚ��
	  vn_cnt := vn_cnt + 1;
	
  END LOOP;
  
  CLOSE c1;
  
  -- �� �ҿ�ð� ��� (�ʷ� ����ϱ� ���� * 60 * 60 * 24�� ����)
  vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;
  
  -- ����Ƚ�� ���
  DBMS_OUTPUT.PUT_LINE('��ü�Ǽ� : ' || vn_cnt);
  -- �� �ҿ�ð� ���
  DBMS_OUTPUT.PUT_LINE('�ҿ�ð� : ' || vn_total_time);  
	
END;  


-- BULK COLLECT 
DECLARE
  -- Ŀ������ 
  CURSOR c1 IS
  SELECT employee_id
   FROM emp_bulk;
   
  -- �÷��� Ÿ�� ����
  TYPE bkEmpTP IS TABLE OF emp_bulk.employee_id%TYPE;
  -- bkEmpTP �� ��������
  vnt_bkEmpTP bkEmpTP;

  vd_sysdate  DATE;
  vn_total_time NUMBER := 0;
BEGIN
	-- ������ vd_sysdate�� ����ð� ����
	vd_sysdate := SYSDATE;
	
	OPEN c1;
	-- ������ ������ �ʴ´�. 
	FETCH c1 BULK COLLECT INTO vnt_bkEmpTP;
  
  CLOSE c1;
  
  -- �� �ҿ�ð� ��� (�ʷ� ����ϱ� ���� * 60 * 60 * 24�� ����)
  vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;
  
  -- �÷��Ǻ����� vnt_bkEmpTP ��Ұ��� ��� 
  DBMS_OUTPUT.PUT_LINE('��ü�Ǽ� : ' || vnt_bkEmpTP.COUNT);
  -- �� �ҿ�ð� ���
  DBMS_OUTPUT.PUT_LINE('�ҿ�ð� : ' || vn_total_time);  
	
END;  

--(2) FORALL��

SELECT MIN(bulk_id), MAX(bulk_id), COUNT(*)
  FROM emp_bulk;
  
-- �ε��� ����  
CREATE INDEX emp_bulk_idx01 ON emp_bulk ( bulk_id );  

-- ������� ����
EXECUTE DBMS_STATS.GATHER_TABLE_STATS( 'ORA_USER', 'EMP_BULK');

-- �Ϲ����� Ŀ���� ����
DECLARE
  -- Ŀ������ 
  CURSOR c1 IS
  SELECT DISTINCT bulk_id
   FROM emp_bulk;

  
  -- �÷��� Ÿ�� ����
  TYPE BulkIDTP IS TABLE OF emp_bulk.bulk_id%TYPE;
  
  -- BulkIDTP �� ��������
  vnt_BulkID    BulkIDTP;
  vd_sysdate    DATE;
  vn_total_time NUMBER := 0; 

BEGIN
	
	-- ������ vd_sysdate�� ����ð� ����
	vd_sysdate := SYSDATE;
	
	OPEN c1;
	
  -- BULK COLLECT ���� ����� vnt_BulkID ������ ������ ���
	FETCH c1 BULK COLLECT INTO vnt_BulkID;	
	
	-- ������ ���� DELETE 
	FOR i IN 1..vnt_BulkID.COUNT
  LOOP
	  UPDATE emp_bulk
       SET retire_date = hire_date
	   WHERE bulk_id = vnt_BulkID(i);
  END LOOP;
	
  
  COMMIT;
  
  CLOSE c1;
  
  -- �� �ҿ�ð� ��� (�ʷ� ����ϱ� ���� * 60 * 60 * 24�� ����)
  vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;
  
  -- �÷��Ǻ����� vnt_BulkID ��Ұ��� ��� 
  DBMS_OUTPUT.PUT_LINE('��ü�Ǽ� : ' || vnt_BulkID.COUNT);
  -- �� �ҿ�ð� ���
  DBMS_OUTPUT.PUT_LINE('FOR LOOP �ҿ�ð� : ' || vn_total_time);  	
	
	
END;


-- FORALL �� ���
DECLARE
  -- Ŀ������ 
  CURSOR c1 IS
  SELECT DISTINCT bulk_id
   FROM emp_bulk;

  
  -- �÷��� Ÿ�� ����
  TYPE BulkIDTP IS TABLE OF emp_bulk.bulk_id%TYPE;
  
  -- BulkIDTP �� ��������
  vnt_BulkID    BulkIDTP;
  vd_sysdate    DATE;
  vn_total_time NUMBER := 0;  

BEGIN
	
	-- ������ vd_sysdate�� ����ð� ����
	vd_sysdate := SYSDATE;
	
	OPEN c1;
	
	-- BULK COLLECT ���� ����� vnt_BulkID ������ ������ ���
	FETCH c1 BULK COLLECT INTO vnt_BulkID;
	
	-- ������ ������ �ʰ� DELETE. 	
	FORALL i IN 1..vnt_BulkID.COUNT
	  UPDATE emp_bulk
       SET retire_date = hire_date
	   WHERE bulk_id = vnt_BulkID(i);
	
  COMMIT;
  
  CLOSE c1;
  
  -- �� �ҿ�ð� ��� (�ʷ� ����ϱ� ���� * 60 * 60 * 24�� ����)
  vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;
  
  -- �÷��Ǻ����� vnt_bkEmpTP ��Ұ��� ��� 
  DBMS_OUTPUT.PUT_LINE('��ü�Ǽ� : ' || vnt_BulkID.COUNT);
  -- �� �ҿ�ð� ���
  DBMS_OUTPUT.PUT_LINE('FORALL �ҿ�ð� : ' || vn_total_time);  	
	
	
END;


-- 03. �Լ� ���� ���

-- �Ϲ��Լ� ����
CREATE OR REPLACE FUNCTION fn_get_depname_normal ( pv_dept_id VARCHAR2 )
     RETURN VARCHAR2
IS
   vs_dep_name DEPARTMENTS.DEPARTMENT_NAME%TYPE;
BEGIN
	
	SELECT department_name
	  INTO vs_dep_name
	  FROM DEPARTMENTS
	 WHERE department_id = pv_dept_id;
	 
  RETURN vs_dep_name;
  
EXCEPTION WHEN OTHERS THEN
  RETURN '';	
	
END;

-- �Ϲ��Լ��� �̿��� UPDATE
DECLARE
  vn_cnt        NUMBER := 0;
  vd_sysdate    DATE;
  vn_total_time NUMBER := 0;  
BEGIN

  vd_sysdate := SYSDATE;
  
  -- dep_name �÷��� �μ����� ������ ���� 
  UPDATE emp_bulk
     SET dep_name = fn_get_depname_normal ( department_id )
   WHERE bulk_id BETWEEN 1 AND 1000;
  
  vn_cnt := SQL%ROWCOUNT;
  
  COMMIT;

  -- �� �ҿ�ð� ��� (�ʷ� ����ϱ� ���� * 60 * 60 * 24�� ����)
  vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;
  
  -- UPDATE �Ǽ� ���  
  DBMS_OUTPUT.PUT_LINE('UPDATE �Ǽ� : ' || vn_cnt);
  -- �� �ҿ�ð� ���
  DBMS_OUTPUT.PUT_LINE('�ҿ�ð� : ' || vn_total_time);  

END;


SELECT department_id, dep_name, COUNT(*)
  FROM emp_bulk
 WHERE bulk_id BETWEEN 1 AND 1000
 GROUP BY department_id, dep_name
 ORDER BY department_id, dep_name;
 
 
-- RESULT CACHE ����� ž��� �Լ�  
CREATE OR REPLACE FUNCTION fn_get_depname_rsltcache ( pv_dept_id VARCHAR2 )
     RETURN VARCHAR2
     RESULT_CACHE
     RELIES_ON ( DEPARTMENTS )
IS
   vs_dep_name DEPARTMENTS.DEPARTMENT_NAME%TYPE;
BEGIN
	-- �μ����� �����´�.
	SELECT department_name
	  INTO vs_dep_name
	  FROM DEPARTMENTS
	 WHERE department_id = pv_dept_id;
	 
  RETURN vs_dep_name;
  
EXCEPTION WHEN OTHERS THEN
  RETURN '';	
	
END;


DECLARE
  vn_cnt        NUMBER := 0;
  vd_sysdate    DATE;
  vn_total_time NUMBER := 0;  
BEGIN

  vd_sysdate := SYSDATE;
  
  UPDATE emp_bulk
     SET dep_name = fn_get_depname_rsltcache ( department_id )
   WHERE bulk_id BETWEEN 1 AND 1000;
  
  vn_cnt := SQL%ROWCOUNT;
  
  COMMIT;

  -- �� �ҿ�ð� ��� (�ʷ� ����ϱ� ���� * 60 * 60 * 24�� ����)
  vn_total_time := (SYSDATE - vd_sysdate) * 60 * 60 * 24;
  
  -- UPDATE �Ǽ� ���  
  DBMS_OUTPUT.PUT_LINE('��ü�Ǽ� : ' || vn_cnt);
  -- �� �ҿ�ð� ���
  DBMS_OUTPUT.PUT_LINE('�ҿ�ð� : ' || vn_total_time);  

END;

SELECT * FROM V$RESULT_CACHE_STATISTICS;
