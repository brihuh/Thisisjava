-- NDS
-- (1) EXECUTE IMMEDIATE

BEGIN
	EXECUTE IMMEDIATE 'SELECT employee_id, emp_name, job_id 
	                     FROM employees WHERE job_id = ''AD_ASST'' ';
	
END;

-- �� ���
DECLARE
  --��� ���� ���� 
  vn_emp_id    employees.employee_id%TYPE;
  vs_emp_name  employees.emp_name%TYPE;
  vs_job_id    employees.job_id%TYPE;
BEGIN
	EXECUTE IMMEDIATE 'SELECT employee_id, emp_name, job_id 
	                     FROM employees WHERE job_id = ''AD_ASST'' '
	                  INTO vn_emp_id, vs_emp_name, vs_job_id;
	                  
  DBMS_OUTPUT.PUT_LINE( 'emp_id : '   || vn_emp_id );	          
  DBMS_OUTPUT.PUT_LINE( 'emp_name : ' || vs_emp_name );	 
  DBMS_OUTPUT.PUT_LINE( 'job_id : '   || vs_job_id );	         
	
END;


-- SQL���� ������
DECLARE
  --��� ���� ���� 
  vn_emp_id    employees.employee_id%TYPE;
  vs_emp_name  employees.emp_name%TYPE;
  vs_job_id    employees.job_id%TYPE;
  
  vs_sql VARCHAR2(1000);
BEGIN
	-- SQL���� ������ ��´�. 
	vs_sql := 'SELECT employee_id, emp_name, job_id 
	                FROM employees WHERE job_id = ''AD_ASST'' ';
	
  EXECUTE IMMEDIATE vs_sql INTO vn_emp_id, vs_emp_name, vs_job_id;
	                  
  DBMS_OUTPUT.PUT_LINE( 'emp_id : '   || vn_emp_id );	          
  DBMS_OUTPUT.PUT_LINE( 'emp_name : ' || vs_emp_name );	 
  DBMS_OUTPUT.PUT_LINE( 'job_id : '   || vs_job_id );	         
END;


-- ���ε� ����
DECLARE
  --��� ���� ���� 
  vn_emp_id    employees.employee_id%TYPE;
  vs_emp_name  employees.emp_name%TYPE;
  vs_job_id    employees.job_id%TYPE;
  
  vs_sql VARCHAR2(1000);
BEGIN
	-- SQL���� ������ ��´�. 
	vs_sql := 'SELECT employee_id, emp_name, job_id 
	            FROM employees 
	           WHERE job_id = ''SA_REP'' 
	             AND salary < 7000
	             AND manager_id  =148 ';
	
  EXECUTE IMMEDIATE vs_sql INTO vn_emp_id, vs_emp_name, vs_job_id;
	                  
  DBMS_OUTPUT.PUT_LINE( 'emp_id : '   || vn_emp_id );	          
  DBMS_OUTPUT.PUT_LINE( 'emp_name : ' || vs_emp_name );	 
  DBMS_OUTPUT.PUT_LINE( 'job_id : '   || vs_job_id );	         
END;

-- ���ε庯�� 2
DECLARE
  --��� ���� ���� 
  vn_emp_id    employees.employee_id%TYPE;
  vs_emp_name  employees.emp_name%TYPE;
  vs_job_id    employees.job_id%TYPE;
  
  vs_sql VARCHAR2(1000);
  
  -- ���ε� ���� ����� �� ����
  vs_job      employees.job_id%TYPE := 'SA_REP';
  vn_sal      employees.salary%TYPE := 7000;
  vn_manager  employees.manager_id%TYPE := 148;
BEGIN
	-- SQL���� ������ ��´�. (���ε� ���� �տ� : �� ���δ�)
	vs_sql := 'SELECT employee_id, emp_name, job_id 
	            FROM employees 
	           WHERE job_id = :a 
	             AND salary < :b
	             AND manager_id = :c ';
	
	-- SQL������ ������ ������� USING ������ ������ �ִ´�. 
  EXECUTE IMMEDIATE vs_sql INTO vn_emp_id, vs_emp_name, vs_job_id
                           USING vs_job, vn_sal, vn_manager;
	                  
  DBMS_OUTPUT.PUT_LINE( 'emp_id : '   || vn_emp_id );	          
  DBMS_OUTPUT.PUT_LINE( 'emp_name : ' || vs_emp_name );	 
  DBMS_OUTPUT.PUT_LINE( 'job_id : '   || vs_job_id );	         
END;

-- INSERT, UPDATE, DELETE, MERGE

CREATE TABLE ch13_physicist ( ids       NUMBER, 
                              names     VARCHAR2(50), 
                              birth_dt  DATE );
                         
-- INSERT ��
DECLARE
  vn_ids   ch13_physicist.ids%TYPE := 10;
  vs_name  ch13_physicist.names%TYPE := 'Albert Einstein';
  vd_dt    ch13_physicist.birth_dt%TYPE := TO_DATE('1879-03-14', 'YYYY-MM-DD');
  
  vs_sql   VARCHAR2(1000);  

BEGIN
	-- INSERT�� �ۼ� 
	vs_sql := 'INSERT INTO ch13_physicist VALUES (:a, :a, :a)';
	
	EXECUTE IMMEDIATE vs_sql USING vn_ids, vs_name, vd_dt;
	
	COMMIT;
	
END;                         
                         
-- UPDATE�� DELETE
DECLARE
  vn_ids   ch13_physicist.ids%TYPE := 10;
  vs_name  ch13_physicist.names%TYPE := 'Max Planck';
  vd_dt    ch13_physicist.birth_dt%TYPE := TO_DATE('1858-04-23', 'YYYY-MM-DD');
  
  vs_sql   VARCHAR2(1000);  
  
  vn_cnt   NUMBER := 0;

BEGIN
	-- UPDATE��
	vs_sql := 'UPDATE ch13_physicist
	              SET names = :a, birth_dt = :a
	            WHERE ids = :a ';
	
	EXECUTE IMMEDIATE vs_sql USING vs_name, vd_dt, vn_ids;
	
	SELECT names
	  INTO vs_name
	  FROM ch13_physicist;
	  
	DBMS_OUTPUT.PUT_LINE('UPDATE �� �̸�: ' || vs_name);
	
	-- DELETE ��
	vs_sql := 'DELETE ch13_physicist
	            WHERE ids = :a ';
	
	EXECUTE IMMEDIATE vs_sql USING vn_ids;	
	
  SELECT COUNT(*)
    INTO vn_cnt
    FROM ch13_physicist;
	
	DBMS_OUTPUT.PUT_LINE('vn_cnt : ' || vn_cnt);
	
	COMMIT;
	
END;  

-- ���ε� ����ó�� 2

CREATE OR REPLACE PROCEDURE ch13_bind_proc1 ( pv_arg1 IN VARCHAR2, 
                                              pn_arg2 IN NUMBER, 
                                              pd_arg3 IN DATE )
IS
BEGIN
	DBMS_OUTPUT.PUT_LINE ('pv_arg1 = ' || pv_arg1);
	DBMS_OUTPUT.PUT_LINE ('pn_arg2 = ' || pn_arg2);
	DBMS_OUTPUT.PUT_LINE ('pd_arg3 = ' || pd_arg3);
	
END;
                                              
                            
-- ���� SQL�� ���ν��� ����
DECLARE
  vs_data1 VARCHAR2(30) := 'Albert Einstein';
  vn_data2 NUMBER := 100;
  vd_data3 DATE   := TO_DATE('1879-03-14', 'YYYY-MM-DD');

  vs_sql   VARCHAR2(1000);
BEGIN
  -- ���ν��� ����
  ch13_bind_proc1 ( vs_data1, vn_data2, vd_data3);
  
  DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    
  vs_sql := 'BEGIN ch13_bind_proc1 (:a, :b, :c); END;';
  
  EXECUTE IMMEDIATE vs_sql USING vs_data1, vn_data2, vd_data3;
  
END;

-- ���ε� ������ �߸� ������ ���
BEGIN
	DBMS_OUTPUT.PUT_LINE ('pv_arg1 = ' || pv_arg1);
	DBMS_OUTPUT.PUT_LINE ('pn_arg2 = ' || pn_arg2);
	DBMS_OUTPUT.PUT_LINE ('pd_arg3 = ' || pd_arg3);
	
END;
                                              
                            
-- ���� SQL�� ���ν��� ����
DECLARE
  vs_data1 VARCHAR2(30) := 'Albert Einstein';
  vn_data2 NUMBER := 100;
  vd_data3 DATE   := TO_DATE('1879-03-14', 'YYYY-MM-DD');

  vs_sql   VARCHAR2(1000);
BEGIN
  -- ���ε� �������� �߸� ������ ���.    
  vs_sql := 'BEGIN ch13_bind_proc1 (:a, :a, :c); END;';
  
  EXECUTE IMMEDIATE vs_sql USING vs_data1, vn_data2, vd_data3;
  
END;


CREATE OR REPLACE PROCEDURE ch13_bind_proc2 ( pv_arg1 IN     VARCHAR2, 
                                              pv_arg2 OUT    VARCHAR2,
                                              pv_arg3 IN OUT VARCHAR2 )
                                              
IS
BEGIN
	DBMS_OUTPUT.PUT_LINE ('pv_arg1 = ' || pv_arg1);
	
	pv_arg2 := '�� ��° OUT ����';
	pv_arg3 := '�� ��° INOUT ����';
	
END;

-- 
DECLARE
  vs_data1 VARCHAR2(30) := 'Albert Einstein';
  vs_data2 VARCHAR2(30);
  vs_data3 VARCHAR2(30);

  vs_sql   VARCHAR2(1000);
BEGIN
  -- ���ε� ����  
  vs_sql := 'BEGIN ch13_bind_proc2 (:a, :b, :c); END;';
  
  EXECUTE IMMEDIATE vs_sql USING vs_data1, OUT vs_data2, IN OUT vs_data3;
  
  
  DBMS_OUTPUT.PUT_LINE ('vs_data2 = ' || vs_data2);
  DBMS_OUTPUT.PUT_LINE ('vs_data3 = ' || vs_data3);
END;


-- DDL���� ALTER SESSION
CREATE OR REPLACE PROCEDURE ch13_ddl_proc ( pd_arg1 IN DATE )
IS
BEGIN
	
	 DBMS_OUTPUT.PUT_LINE('pd_arg1 : ' || pd_arg1);
END;


CREATE OR REPLACE PROCEDURE ch13_ddl_proc ( pd_arg1 IN DATE )
IS
BEGIN
	 CREATE TABLE ch13_ddl_tab ( col1 VARCHAR2(30));	
	 DBMS_OUTPUT.PUT_LINE('pd_arg1 : ' || pd_arg1);
END;


CREATE OR REPLACE PROCEDURE ch13_ddl_proc ( pd_arg1 IN DATE )
IS
  vs_sql VARCHAR2(1000);
BEGIN
	 -- DDL���� ����SQL�� ...
	 vs_sql := 'CREATE TABLE ch13_ddl_tab ( col1 VARCHAR2(30) )' ;
	 EXECUTE IMMEDIATE vs_sql;
	 
	 DBMS_OUTPUT.PUT_LINE('pd_arg1 : ' || pd_arg1);
END;



EXEC ch13_ddl_proc ( SYSDATE );


SELECT SYSDATE
  FROM DUAL;
  
CREATE OR REPLACE PROCEDURE ch13_ddl_proc ( pd_arg1 IN DATE )
IS
  vs_sql VARCHAR2(1000);
BEGIN
	 -- ALTER SESSION 
	 vs_sql := 'ALTER SESSION SET NLS_DATE_FORMAT = "YYYY/MM/DD"';
	 EXECUTE IMMEDIATE vs_sql;
	 
	 DBMS_OUTPUT.PUT_LINE('pd_arg1 : ' || pd_arg1);
END; 
  
  
-- (2) ���߷ο� ó��
-- �� OPEN FOR��
TRUNCATE TABLE ch13_physicist ;

INSERT INTO ch13_physicist VALUES (1, 'Galileo Galilei', TO_DATE('1564-02-15','YYYY-MM-DD'));

INSERT INTO ch13_physicist VALUES (2, 'Isaac Newton', TO_DATE('1643-01-04','YYYY-MM-DD'));

INSERT INTO ch13_physicist VALUES (3, 'Max Plank', TO_DATE('1858-04-23','YYYY-MM-DD'));

INSERT INTO ch13_physicist VALUES (4, 'Albert Einstein', TO_DATE('1879-03-14','YYYY-MM-DD'));

COMMIT;

   
DECLARE
  -- Ŀ��Ÿ�� ����
  TYPE query_physicist IS REF CURSOR;
  -- Ŀ�� ���� ����
  myPhysicist query_physicist;
  -- ��ȯ���� ���� ���ڵ� ����
  empPhysicist ch13_physicist%ROWTYPE;
  

  vs_sql VARCHAR2(1000);

BEGIN
	vs_sql := 'SELECT * FROM ch13_physicist';
	-- OPEN FOR���� ����� ���� SQL
	OPEN myPhysicist FOR vs_sql;
	--������ ���� Ŀ�������� ��� ���� ����Ѵ�.
	LOOP
	  FETCH myPhysicist INTO empPhysicist;
    EXIT WHEN myPhysicist%NOTFOUND;	
    DBMS_OUTPUT.PUT_LINE(empPhysicist.names);
  END LOOP;
	
	CLOSE myPhysicist;
END;


-- ���ε� ����    
DECLARE
  -- Ŀ�� ���� ����
  myPhysicist SYS_REFCURSOR;
  -- ��ȯ���� ���� ���ڵ� ����
  empPhysicist ch13_physicist%ROWTYPE;
  

  vs_sql VARCHAR2(1000);
  vn_id    ch13_physicist.ids%TYPE    := 1;
  vs_names ch13_physicist.names%TYPE  := 'Albert%';

BEGIN
	-- ���ε� ���� ����� ���� WHERE���� �߰� 
	vs_sql := 'SELECT * FROM ch13_physicist WHERE IDS > :a AND NAMES LIKE :a ';
	-- OPEN FOR���� ����� ���� SQL
	OPEN myPhysicist FOR vs_sql USING vn_id, vs_names;
	--������ ���� Ŀ�������� ��� ���� ����Ѵ�.
	LOOP
	  FETCH myPhysicist INTO empPhysicist;
    EXIT WHEN myPhysicist%NOTFOUND;	
    DBMS_OUTPUT.PUT_LINE(empPhysicist.names);
  END LOOP;
	
	CLOSE myPhysicist;
END;


-- ���� ����� ���� ���� �ο� ó��

-- BULK COLLECT INTO�� ����� ���� SQL
DECLARE
  -- ���ڵ� ���� 
  TYPE rec_physicist IS RECORD  (
      ids      ch13_physicist.ids%TYPE,
      names    ch13_physicist.names%TYPE,
      birth_dt ch13_physicist.birth_dt%TYPE );
  -- ���ڵ带 �׸����� �ϴ� ��ø���̺� ����
  TYPE NT_physicist IS TABLE OF rec_physicist;
  -- ��ø���̺� ���� ����
  vr_physicist NT_physicist;
BEGIN
  -- BULK COLLECT INTO �� 
	SELECT * 
   BULK COLLECT INTO vr_physicist
   FROM ch13_physicist;
   -- ������ ���� ���
   FOR i IN 1..vr_physicist.count
   LOOP
     DBMS_OUTPUT.PUT_LINE(vr_physicist(i).names);
   END LOOP;

END;

-- BULK COLLECT INTO�� ����� ����  SQL
DECLARE
  -- ���ڵ� ���� 
  TYPE rec_physicist IS RECORD  (
      ids      ch13_physicist.ids%TYPE,
      names    ch13_physicist.names%TYPE,
      birth_dt ch13_physicist.birth_dt%TYPE );
  -- ���ڵ带 �׸����� �ϴ� ��ø���̺� ����
  TYPE NT_physicist IS TABLE OF rec_physicist;
  -- ��ø���̺� ���� ����
  vr_physicist NT_physicist;
  
  vs_sql VARCHAR2(1000);
  vn_ids ch13_physicist.ids%TYPE := 1;
BEGIN
  -- SELECT ���� 
  vs_sql := 'SELECT * FROM ch13_physicist WHERE ids > :a' ;
  
  -- EXECUTE IMMEDIATE .. BULK COLLECT INTO ����
  EXECUTE IMMEDIATE vs_sql BULK COLLECT INTO vr_physicist USING vn_ids;
  
   -- ������ ���� ���
   FOR i IN 1..vr_physicist.count
   LOOP
     DBMS_OUTPUT.PUT_LINE(vr_physicist(i).names);
   END LOOP;

END;

-- �⺻ Ȱ��� (DBMS_SQL)
DECLARE
  --��� ���� ���� 
  vn_emp_id    employees.employee_id%TYPE;
  vs_emp_name  employees.emp_name%TYPE;
  vs_job_id    employees.job_id%TYPE;
  
  vs_sql VARCHAR2(1000);
  
  -- ���ε� ���� ����� �� ����
  vs_job      employees.job_id%TYPE := 'SA_REP';
  vn_sal      employees.salary%TYPE := 7000;
  vn_manager  employees.manager_id%TYPE := 148;
  
  -- DBMS_SQL ��Ű�� ���� ����
  vn_cur_id   NUMBER := DBMS_SQL.OPEN_CURSOR(); -- Ŀ���� ����
  vn_return   NUMBER;
BEGIN
	-- 1.SQL���� ������ ��´�. (���ε� ���� �տ� : �� ���δ�)
	vs_sql := 'SELECT employee_id, emp_name, job_id 
	            FROM employees 
	           WHERE job_id = :a 
	             AND salary < :b
	             AND manager_id = :c ';
	             
  -- 2. �Ľ�
  DBMS_SQL.PARSE (vn_cur_id, vs_sql, DBMS_SQL.NATIVE);
  
  -- 3. ���ε� ���� ���� (WHERE ���� ����� ������ 3�� �̹Ƿ� �� �������� �� 3ȸ ȣ��)
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':a', vs_job);
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':b', vn_sal);
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':c', vn_manager);
  
  -- 4. ������� �÷� ���� ( ���, �����, job_id �� 3���� �÷��� ���������Ƿ� ���� ������� ȣ��)
  -- SELECT ������ ���� ������ ���߰� ����� ���� ������ �����Ѵ�. 
  DBMS_SQL.DEFINE_COLUMN ( vn_cur_id, 1, vn_emp_id);
  DBMS_SQL.DEFINE_COLUMN ( vn_cur_id, 2, vs_emp_name, 80); --�������� ũ����� ���� 
  DBMS_SQL.DEFINE_COLUMN ( vn_cur_id, 3, vs_job_id, 10);
  
  -- 5. ��������
  vn_return := DBMS_SQL.EXECUTE (vn_cur_id);
  
  -- 6. �����ġ 
  LOOP
    -- ����Ǽ��� ������ ������ ����������. 
    IF DBMS_SQL.FETCH_ROWS (vn_cur_id) = 0 THEN
       EXIT;
    END IF;
    
    -- 7. ��ġ�� ����� �޾ƿ��� 
    DBMS_SQL.COLUMN_VALUE ( vn_cur_id, 1, vn_emp_id);
    DBMS_SQL.COLUMN_VALUE ( vn_cur_id, 2, vs_emp_name);
    DBMS_SQL.COLUMN_VALUE ( vn_cur_id, 3, vs_job_id);
    
    -- ��� ���
    DBMS_OUTPUT.PUT_LINE( 'emp_id : '   || vn_emp_id );	          
    DBMS_OUTPUT.PUT_LINE( 'emp_name : ' || vs_emp_name );	 
    DBMS_OUTPUT.PUT_LINE( 'job_id : '   || vs_job_id );	  
  
  END LOOP;
  
  -- 8. Ŀ�� �ݱ�
    DBMS_SQL.CLOSE_CURSOR (vn_cur_id);
           
END;

-- DBMS_SQL�� �̿��� INSERT
DECLARE
  vn_ids   ch13_physicist.ids%TYPE := 1;
  vs_name  ch13_physicist.names%TYPE := 'Galileo Galilei';
  vd_dt    ch13_physicist.birth_dt%TYPE := TO_DATE('1564-02-15', 'YYYY-MM-DD');
  
  vs_sql   VARCHAR2(1000);  
  
  -- DBMS_SQL ��Ű�� ���� ����
  vn_cur_id   NUMBER := DBMS_SQL.OPEN_CURSOR(); -- Ŀ���� ����
  vn_return   NUMBER;  

BEGIN
	-- 1. INSERT�� �ۼ� 
	vs_sql := 'INSERT INTO ch13_physicist VALUES (:a, :b, :c)';
	
  -- 2. �Ľ�
  DBMS_SQL.PARSE (vn_cur_id, vs_sql, DBMS_SQL.NATIVE);
  
  -- 3. ���ε� ���� ���� (VALUES ������ ����� ������ 3�� �̹Ƿ� �� �������� �� 3ȸ ȣ��)
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':a', vn_ids);
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':b', vs_name);
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':c', vd_dt);
  
  -- 4. ��������
  vn_return := DBMS_SQL.EXECUTE (vn_cur_id);  
  
  -- 5. Ŀ�� �ݱ�
  DBMS_SQL.CLOSE_CURSOR (vn_cur_id);  
  --����Ǽ� ���
  DBMS_OUTPUT.PUT_LINE('����Ǽ�: ' || vn_return);
	
	COMMIT;
	
END; 


INSERT INTO ch13_physicist VALUES (2, 'Isaac Newton', TO_DATE('1643-01-04', 'YYYY-MM-DD'));

INSERT INTO ch13_physicist VALUES (3, 'Max Plank', TO_DATE('1858-04-23', 'YYYY-MM-DD'));

INSERT INTO ch13_physicist VALUES (4, 'Albert Einstein', TO_DATE('1879-03-14', 'YYYY-MM-DD'));

COMMIT;

-- DBMS_SQL�� �̿��� UPDATE
DECLARE
  vn_ids   ch13_physicist.ids%TYPE := 3;
  vs_name  ch13_physicist.names%TYPE := ' UPDATED';
  
  vs_sql   VARCHAR2(1000);  
  
  -- DBMS_SQL ��Ű�� ���� ����
  vn_cur_id   NUMBER := DBMS_SQL.OPEN_CURSOR(); -- Ŀ���� ����
  vn_return   NUMBER;  

BEGIN
	-- 1. UPDATE�� �ۼ� 
	vs_sql := 'UPDATE ch13_physicist SET names = names || :a WHERE ids < :b' ;
	
  -- 2. �Ľ�
  DBMS_SQL.PARSE (vn_cur_id, vs_sql, DBMS_SQL.NATIVE);
  
  -- 3. ���ε� ���� ���� 
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':a', vs_name);
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':b', vn_ids);
  
  -- 4. ��������
  vn_return := DBMS_SQL.EXECUTE (vn_cur_id);  
  
  -- 5. Ŀ�� �ݱ�
  DBMS_SQL.CLOSE_CURSOR (vn_cur_id);  
  --����Ǽ� ���
  DBMS_OUTPUT.PUT_LINE('UPDATE ����Ǽ�: ' || vn_return);
	
	COMMIT;
	
END; 


SELECT *
  FROM ch13_physicist;
  
  
-- DBMS_SQL�� �̿��� DELETE
DECLARE
  vn_ids   ch13_physicist.ids%TYPE := 3;
  
  vs_sql   VARCHAR2(1000);  
  
  -- DBMS_SQL ��Ű�� ���� ����
  vn_cur_id   NUMBER := DBMS_SQL.OPEN_CURSOR(); -- Ŀ���� ����
  vn_return   NUMBER;  

BEGIN
	--  DELETE �� �ۼ� 
	vs_sql := 'DELETE ch13_physicist WHERE ids < :b' ;
	
  -- 2. �Ľ�
  DBMS_SQL.PARSE (vn_cur_id, vs_sql, DBMS_SQL.NATIVE);
  
  -- 3. ���ε� ���� ���� 
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':b', vn_ids);
  
  -- 4. ��������
  vn_return := DBMS_SQL.EXECUTE (vn_cur_id);  
  
  -- 5. Ŀ�� �ݱ�
  DBMS_SQL.CLOSE_CURSOR (vn_cur_id);  
  --����Ǽ� ���
  DBMS_OUTPUT.PUT_LINE('DELETE ����Ǽ�: ' || vn_return);
	
	COMMIT;
	
END;   


TRUNCATE TABLE ch13_physicist;


-- DBMS_SQL�� �̿��� INSERT 2
DECLARE
  -- DBMS_SQL ��Ű������ �����ϴ� �÷��� Ÿ�� ���� ���� 
  vn_ids_array   DBMS_SQL.NUMBER_TABLE;
  vs_name_array  DBMS_SQL.VARCHAR2_TABLE;
  vd_dt_array    DBMS_SQL.DATE_TABLE;
  
  vs_sql   VARCHAR2(1000);  
  
  -- DBMS_SQL ��Ű�� ���� ����
  vn_cur_id   NUMBER := DBMS_SQL.OPEN_CURSOR(); -- Ŀ���� ����
  vn_return   NUMBER;  

BEGIN
	-- 0. �Է��� �� ����
	vn_ids_array(1)  := 1;
	vs_name_array(1) := 'Galileo Galilei'; 
	vd_dt_array(1)   := TO_DATE('1564-02-15', 'YYYY-MM-DD');
	
	vn_ids_array(2)  := 2;
	vs_name_array(2) := 'Isaac Newton'; 
	vd_dt_array(2)   := TO_DATE('1643-01-04', 'YYYY-MM-DD');
	
	vn_ids_array(3)  := 3;
	vs_name_array(3) := 'Max Plank';
	vd_dt_array(3)   := TO_DATE('1858-04-23', 'YYYY-MM-DD');
	
	vn_ids_array(4)  := 4;
	vs_name_array(4) := 'Albert Einstein';
	vd_dt_array(4)   := TO_DATE('1879-03-14', 'YYYY-MM-DD');	
	
	
	-- 1. INSERT�� �ۼ� 
	vs_sql := 'INSERT INTO ch13_physicist VALUES (:a, :b, :c)';
	
  -- 2. �Ľ�
  DBMS_SQL.PARSE (vn_cur_id, vs_sql, DBMS_SQL.NATIVE);
  
  -- 3. ���ε� ���� ���� (BIND_VARIABLE ��� BIND_ARRAY ���)
  DBMS_SQL.BIND_ARRAY ( vn_cur_id, ':a', vn_ids_array);
  DBMS_SQL.BIND_ARRAY ( vn_cur_id, ':b', vs_name_array);
  DBMS_SQL.BIND_ARRAY ( vn_cur_id, ':c', vd_dt_array);
  
  -- 4. ��������
  vn_return := DBMS_SQL.EXECUTE (vn_cur_id);  
  
  -- 5. Ŀ�� �ݱ�
  DBMS_SQL.CLOSE_CURSOR (vn_cur_id);  
  --����Ǽ� ���
  DBMS_OUTPUT.PUT_LINE('����Ǽ�: ' || vn_return);
	
	COMMIT;
	
END; 


-- DBMS_SQL�� �̿��� UPDATE 2
DECLARE
  -- DBMS_SQL ��Ű������ �����ϴ� �÷��� Ÿ�� ���� ���� 
  vn_ids_array   DBMS_SQL.NUMBER_TABLE;
  vs_name_array  DBMS_SQL.VARCHAR2_TABLE;

  vs_sql   VARCHAR2(1000);  
  
  -- DBMS_SQL ��Ű�� ���� ����
  vn_cur_id   NUMBER := DBMS_SQL.OPEN_CURSOR(); -- Ŀ���� ����
  vn_return   NUMBER;  

BEGIN
	-- 0. ������ �� ����
	vn_ids_array(1)  := 1;
	vs_name_array(1) := 'Albert Einstein';
	
	vn_ids_array(2)  := 2;
	vs_name_array(2) := 'Galileo Galilei'; 
	
	vn_ids_array(3)  := 3;
	vs_name_array(3) := 'Isaac Newton'; 

	vn_ids_array(4)  := 4;
	vs_name_array(4) := 'Max Plank';
	
	
	-- 1. UPDATE�� �ۼ� 
	vs_sql := 'UPDATE ch13_physicist SET names = :a WHERE ids = :b';
	
  -- 2. �Ľ�
  DBMS_SQL.PARSE (vn_cur_id, vs_sql, DBMS_SQL.NATIVE);
  
  -- 3. ���ε� ���� ���� (BIND_VARIABLE ��� BIND_ARRAY ���)
  DBMS_SQL.BIND_ARRAY ( vn_cur_id, ':a', vs_name_array);
  DBMS_SQL.BIND_ARRAY ( vn_cur_id, ':b', vn_ids_array);
  
  -- 4. ��������
  vn_return := DBMS_SQL.EXECUTE (vn_cur_id);  
  
  -- 5. Ŀ�� �ݱ�
  DBMS_SQL.CLOSE_CURSOR (vn_cur_id);  
  --����Ǽ� ���
  DBMS_OUTPUT.PUT_LINE('����Ǽ�: ' || vn_return);
	
	COMMIT;
	
END; 


select ids, names
from ch13_physicist;


-- DBMS_SQ.TO_REFCURSOR �Լ�
DECLARE
  --��¿� ���� ���� 
  vc_cur       SYS_REFCURSOR;
  va_emp_id    DBMS_SQL.NUMBER_TABLE;
  va_emp_name  DBMS_SQL.VARCHAR2_TABLE;
  
  vs_sql VARCHAR2(1000);
  
  -- ���ε� ���� ����� �� ����
  vs_job      employees.job_id%TYPE := 'SA_REP';
  vn_sal      employees.salary%TYPE := 9000;
  vn_manager  employees.manager_id%TYPE := 148;
  
  -- DBMS_SQL ��Ű�� ���� ����
  vn_cur_id   NUMBER := DBMS_SQL.OPEN_CURSOR(); -- Ŀ���� ����
  vn_return   NUMBER;
BEGIN
	-- 1.SQL���� ������ ��´�. (���ε� ���� �տ� : �� ���δ�)
	vs_sql := 'SELECT employee_id, emp_name
	            FROM employees 
	           WHERE job_id = :a 
	             AND salary < :b
	             AND manager_id = :c ';
	             
  -- 2. �Ľ�
  DBMS_SQL.PARSE (vn_cur_id, vs_sql, DBMS_SQL.NATIVE);
  
  -- 3. ���ε� ���� ���� (WHERE ���� ����� ������ 3�� �̹Ƿ� �� �������� �� 3ȸ ȣ��)
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':a', vs_job);
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':b', vn_sal);
  DBMS_SQL.BIND_VARIABLE ( vn_cur_id, ':c', vn_manager);  
 
  -- 4. ��������
  vn_return := DBMS_SQL.EXECUTE (vn_cur_id);
  
  -- 5. DBMS_SQL.TO_REFCURSOR�� ����� Ŀ���� ��ȯ 
  vc_cur := DBMS_SQL.TO_REFCURSOR (vn_cur_id);
  
  -- 6. ��ȯ�� Ŀ���� ����� ����� ��ġ�ϰ� ��� ���
  FETCH vc_cur BULK COLLECT INTO va_emp_id, va_emp_name;
   
  FOR i IN 1 .. va_emp_id.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE(va_emp_id(i) || ' - ' || va_emp_name(i));
  END LOOP; 
  
  -- 7. Ŀ�� �ݱ�
  CLOSE vc_cur;
           
END;


-- ���� ���Ͽ� 

CREATE OR REPLACE PROCEDURE print_table( p_query IN VARCHAR2 )
IS
    l_theCursor     INTEGER DEFAULT DBMS_SQL.OPEN_CURSOR;
    l_columnValue   VARCHAR2(4000);
    l_status        INTEGER;
    l_descTbl       DBMS_SQL.DESC_TAB;
    l_colCnt        NUMBER;
BEGIN
    -- �������� ��ü�� p_query �Ű������� �޾ƿ´�. 
    -- �޾ƿ� ������ �Ľ��Ѵ�. 
    DBMS_SQL.PARSE(  l_theCursor,  p_query, DBMS_SQL.NATIVE );
    
    -- DESCRIBE_COLUMN ���ν��� : Ŀ���� ���� �÷������� DBMS_SQL.DESC_TAB �� ������ �ִ´�. 
    DBMS_SQL.DESCRIBE_COLUMNS ( l_theCursor, l_colCnt, l_descTbl );

    -- ���õ� �÷� ������ŭ ������ ���� DEFINE_COLUMN ���ν����� ȣ���� �÷��� �����Ѵ�. 
    FOR i IN 1..l_colCnt 
    LOOP
        DBMS_SQL.DEFINE_COLUMN (l_theCursor, i, l_columnValue, 4000);
    END LOOP;

    -- ���� 
    l_status := DBMS_SQL.EXECUTE(l_theCursor);

    WHILE ( DBMS_SQL.FETCH_ROWS (l_theCursor) > 0 ) 
    LOOP
        -- �÷� ������ŭ �ٽ� ������ ���鼭 �÷� ���� l_columnValue ������ ��´�.
        -- DBMS_SQL.DESC_TAB �� ������ l_descTbl.COL_NAME�� �÷� ��Ī�� �ְ� 
        -- l_columnValue���� �÷� ���� ����ִ�. 
        FOR i IN 1..l_colCnt 
        LOOP
          DBMS_SQL.COLUMN_VALUE ( l_theCursor, i, l_columnValue );
          DBMS_OUTPUT.PUT_LINE  ( rpad( l_descTbl(i).COL_NAME, 30 ) || ': ' || l_columnValue );
        END LOOP;
        DBMS_OUTPUT.PUT_LINE( '-----------------' );
    END LOOP;
    
    DBMS_SQL.CLOSE_CURSOR (l_theCursor);

END;


EXEC print_table ( 'SELECT * FROM ch13_physicist');


CREATE OR REPLACE PROCEDURE insert_ddl ( p_table IN VARCHAR2 )
IS
    l_theCursor     INTEGER DEFAULT DBMS_SQL.OPEN_CURSOR;
    l_status        INTEGER;
    l_descTbl       DBMS_SQL.DESC_TAB;
    l_colCnt        NUMBER;   
    
    v_sel_sql       VARCHAR2(1000);  -- SELECT ����
    v_ins_sql       VARCHAR2(1000);  -- INSERT ����
BEGIN
	  -- �Է¹��� ���̺������ SELECT ������ �����. 
    v_sel_sql := 'SELECT * FROM ' || p_table || ' WHERE ROWNUM = 1';


    -- �޾ƿ� ������ �Ľ��Ѵ�. 
    DBMS_SQL.PARSE(  l_theCursor,  v_sel_sql, DBMS_SQL.NATIVE );
    
    -- DESCRIBE_COLUMN ���ν��� : Ŀ���� ���� �÷������� DBMS_SQL.DESC_TAB �� ������ �ִ´�. 
    DBMS_SQL.DESCRIBE_COLUMNS ( l_theCursor, l_colCnt, l_descTbl );

    -- INSERT�� ������ �����. 
    v_ins_sql := 'INSERT INTO ' || p_table || ' ( ';   

    FOR i IN 1..l_colCnt 
    LOOP
      -- �� ������ �÷��� ���� ���� ��ȣ�� ���δ�. 
      IF i = l_colCnt THEN        
        v_ins_sql := v_ins_sql || l_descTbl(i).COL_NAME || ' )';     
      ELSE -- ������ ���� '�÷���,' ���·� �����. 
        v_ins_sql := v_ins_sql || l_descTbl(i).COL_NAME || ', ';      
      END IF;
    END LOOP;
  
    DBMS_OUTPUT.PUT_LINE ( v_ins_sql );
    
    DBMS_SQL.CLOSE_CURSOR (l_theCursor);

END;

EXEC insert_ddl ( 'ch13_physicist');

EXEC insert_ddl ( 'CUSTOMERS');