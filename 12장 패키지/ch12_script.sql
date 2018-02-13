-- ��Ű�� ���

-- ��Ű�� ����� 
CREATE OR REPLACE PACKAGE hr_pkg IS

  -- ����� �޾� �̸��� ��ȯ�ϴ� �Լ�
  FUNCTION fn_get_emp_name ( pn_employee_id IN NUMBER )
     RETURN VARCHAR2;
     
  -- �ű� ��� �Է�  
  PROCEDURE new_emp_proc ( ps_emp_name   IN VARCHAR2, 
                           pd_hire_date  IN VARCHAR2 );
                               
  -- ��� ��� ó��                          
  PROCEDURE retire_emp_proc ( pn_employee_id IN NUMBER );
  
END  hr_pkg; 
                               
-- ��Ű�� ����
 
CREATE OR REPLACE PACKAGE BODY hr_pkg IS

  -- ����� �޾� �̸��� ��ȯ�ϴ� �Լ�
  FUNCTION fn_get_emp_name ( pn_employee_id IN NUMBER )
     RETURN VARCHAR2
  IS
    vs_emp_name employees.emp_name%TYPE;
  BEGIN
    -- ������� �����´�. 
    SELECT emp_name
      INTO vs_emp_name
      FROM employees
     WHERE employee_id = pn_employee_id;
     
    -- ����� ��ȯ
    RETURN NVL(vs_emp_name, '�ش�������');
  
  END fn_get_emp_name;
     
  -- �ű� ��� �Է�  
  PROCEDURE new_emp_proc ( ps_emp_name   IN VARCHAR2, 
                           pd_hire_date  IN VARCHAR2)
  IS
    
    vn_emp_id    employees.employee_id%TYPE;
    vd_hire_date DATE := TO_DATE(pd_hire_date, 'YYYY-MM-DD');
  BEGIN
     -- �űԻ���� ��� = �ִ� ���+1 
     SELECT NVL(max(employee_id),0) + 1
       INTO vn_emp_id
       FROM employees;
  
    
    INSERT INTO employees (employee_id, emp_name,hire_date, create_date, update_date)
                   VALUES (vn_emp_id, ps_emp_name, NVL(vd_hire_date,SYSDATE), SYSDATE, SYSDATE );
                   
    COMMIT;
    
    EXCEPTION WHEN OTHERS THEN
              DBMS_OUTPUT.PUT_LINE(SQLERRM);
              ROLLBACK;               
  
  
  END new_emp_proc;
  
                               
  -- ��� ��� ó��                          
  PROCEDURE retire_emp_proc ( pn_employee_id IN NUMBER )
  IS
    vn_cnt NUMBER := 0;
    e_no_data    EXCEPTION;
  BEGIN
    -- ����� ����� ������̺��� �������� �ʰ� �ϴ� �������(RETIRE_DATE)�� NULL���� �����Ѵ�.
    UPDATE employees
       SET retire_date = SYSDATE
     WHERE employee_id = pn_employee_id
       AND retire_date IS NULL;
       
    -- UPDATE�� �Ǽ��� �����´�.    
    vn_cnt := SQL%ROWCOUNT;
    
    -- ���ŵ� �Ǽ��� ������ ����� ����ó�� 
    IF vn_cnt = 0 THEN 
       RAISE e_no_data;
    END IF;
    
    COMMIT;
    
    EXCEPTION WHEN e_no_data THEN
                   DBMS_OUTPUT.PUT_LINE (pn_employee_id || '�� �ش�Ǵ� ���ó���� ����� �����ϴ�!');
                   ROLLBACK;
              WHEN OTHERS THEN
                   DBMS_OUTPUT.PUT_LINE (SQLERRM);
                   ROLLBACK;              
  
  
  END retire_emp_proc;
  
END  hr_pkg; 


-- hr_pkg ���
SELECT hr_pkg.fn_get_emp_name (171)
  FROM DUAL;
  
-- �űԻ�� �Է�
EXEC hr_pkg.new_emp_proc ('Julia Roberts', '2014-01-10');

SELECT employee_id, emp_name, hire_date, retire_date, create_date
  FROM employees
 WHERE emp_name like 'Julia R%';  
 
-- ���ó�� 
EXEC hr_pkg.retire_emp_proc (207);

SELECT employee_id, emp_name, hire_date, retire_date, create_date
  FROM employees
 WHERE emp_name like 'Julia R%'; 
 
 
-- (3) Ÿ ���α׷����� ��Ű�� ȣ��  
CREATE OR REPLACE PACKAGE hr_pkg IS

  -- ����� �޾� �̸��� ��ȯ�ϴ� �Լ�
  FUNCTION fn_get_emp_name ( pn_employee_id IN NUMBER )
     RETURN VARCHAR2;
     
  -- �ű� ��� �Է�  
  PROCEDURE new_emp_proc ( ps_emp_name   IN VARCHAR2, 
                           pd_hire_date  IN VARCHAR2 );
                               
  -- ��� ��� ó��                          
  PROCEDURE retire_emp_proc ( pn_employee_id IN NUMBER );
  
  -- ����� �Է¹޾� �μ����� ��ȯ�ϴ� �Լ�
  FUNCTION fn_get_dep_name ( pn_employee_id IN NUMBER )
     RETURN VARCHAR2;
  
END  hr_pkg; 

-- �ű� ���ν���
CREATE OR REPLACE PROCEDURE ch12_dep_proc ( pn_employee_id IN NUMBER )
IS
  vs_emp_name employees.emp_name%TYPE;  --����� ����
  vs_dep_name departments.department_name%TYPE;  -- �μ��� ����
BEGIN
	

  
  -- �μ��� ��������
  vs_dep_name := hr_pkg.fn_get_dep_name (pn_employee_id);
  
  -- �μ��� ���
  DBMS_OUTPUT.PUT_LINE(NVL(vs_dep_name, '�μ��� ����'));
	
END;



-- fn_get_dep_name �Լ��� �߰��� ��Ű�� ���� 
CREATE OR REPLACE PACKAGE BODY hr_pkg IS

  -- ����� �޾� �̸��� ��ȯ�ϴ� �Լ�
  FUNCTION fn_get_emp_name ( pn_employee_id IN NUMBER )
     RETURN VARCHAR2
  IS
    vs_emp_name employees.emp_name%TYPE;
  BEGIN
    -- ������� �����´�. 
    SELECT emp_name
      INTO vs_emp_name
      FROM employees
     WHERE employee_id = pn_employee_id;
     
    -- ����� ��ȯ
    RETURN NVL(vs_emp_name, '�ش�������');
  
  END fn_get_emp_name;
     
  -- �ű� ��� �Է�  
  PROCEDURE new_emp_proc ( ps_emp_name   IN VARCHAR2, 
                           pd_hire_date  IN VARCHAR2)
  IS
    
    vn_emp_id    employees.employee_id%TYPE;
    vd_hire_date DATE := TO_DATE(pd_hire_date, 'YYYY-MM-DD');
  BEGIN
     -- �űԻ���� ��� = �ִ� ���+1 
     SELECT NVL(max(employee_id),0) + 1
       INTO vn_emp_id
       FROM employees;
  
    
    INSERT INTO employees (employee_id, emp_name,hire_date, create_date, update_date)
                   VALUES (vn_emp_id, ps_emp_name, NVL(vd_hire_date,SYSDATE), SYSDATE, SYSDATE );
                   
    COMMIT;
    
    EXCEPTION WHEN OTHERS THEN
              DBMS_OUTPUT.PUT_LINE(SQLERRM);
              ROLLBACK;               
  
  
  END new_emp_proc;
  
                               
  -- ��� ��� ó��                          
  PROCEDURE retire_emp_proc ( pn_employee_id IN NUMBER )
  IS
    vn_cnt NUMBER := 0;
    e_no_data    EXCEPTION;
  BEGIN
    -- ����� ����� ������̺��� �������� �ʰ� �ϴ� �������(RETIRE_DATE)�� NULL���� �����Ѵ�.
    UPDATE employees
       SET retire_date = SYSDATE
     WHERE employee_id = pn_employee_id
       AND retire_date IS NULL;
       
    -- UPDATE�� �Ǽ��� �����´�.    
    vn_cnt := SQL%ROWCOUNT;
    
    -- ���ŵ� �Ǽ��� ������ ����� ����ó�� 
    IF vn_cnt = 0 THEN 
       RAISE e_no_data;
    END IF;
    
    COMMIT;
    
    EXCEPTION WHEN e_no_data THEN
                   DBMS_OUTPUT.PUT_LINE (pn_employee_id || '�� �ش�Ǵ� ���ó���� ����� �����ϴ�!');
                   ROLLBACK;
              WHEN OTHERS THEN
                   DBMS_OUTPUT.PUT_LINE (SQLERRM);
                   ROLLBACK;              
  
  
  END retire_emp_proc;
  
  -- ����� �Է¹޾� �μ����� ��ȯ�ϴ� �Լ�
  FUNCTION fn_get_dep_name ( pn_employee_id IN NUMBER )
     RETURN VARCHAR2
  IS
    vs_dep_name departments.department_name%TYPE;
  BEGIN
  	
  	-- �μ����̺�� ������ ����� �̿�, �μ������ �����´�. 
  	SELECT b.department_name
  	  INTO vs_dep_name
  	  FROM employees a, departments b
  	 WHERE a.employee_id = pn_employee_id
  	   AND a.department_id = b.department_id;
  	   
  	-- �μ��� ��ȯ
  	RETURN vs_dep_name;   
  	
  	
  END fn_get_dep_name;
    
  
END  hr_pkg; 

-- ���ν��� ����
EXEC ch12_dep_proc(177);


-- 03. ��Ű�� ������
--(1) ����� ���� ����
CREATE OR REPLACE PACKAGE ch12_var IS
  -- �������
     c_test CONSTANT VARCHAR2(10) := 'TEST';
     
  -- �������� 
     v_test VARCHAR2(10);

END ch12_var;

BEGIN
  DBMS_OUTPUT.PUT_LINE('��� ch12_var.c_test = ' || ch12_var.c_test);
  DBMS_OUTPUT.PUT_LINE('���� ch12_var.c_test = ' || ch12_var.v_test);
END;

BEGIN
  DBMS_OUTPUT.PUT_LINE('�� ���� ���� = ' || ch12_var.v_test);
  ch12_var.v_test := 'FIRST';
  DBMS_OUTPUT.PUT_LINE('�� ���� ���� = ' || ch12_var.v_test);
END;


-- �űԼ���
BEGIN
  DBMS_OUTPUT.PUT_LINE('ch12_var.v_test = ' || ch12_var.v_test);
END;


CREATE OR REPLACE PACKAGE BODY ch12_var IS
  -- �������
     c_test_body CONSTANT VARCHAR2(10) := 'CONSTANT_BODY';
     
  -- �������� 
     v_test_body VARCHAR2(10);

END ch12_var;

BEGIN
	 DBMS_OUTPUT.PUT_LINE('ch12_var.c_test_body = '|| ch12_var.c_test_body);	 
	 
	 DBMS_OUTPUT.PUT_LINE('ch12_var.v_test_body = '|| ch12_var.v_test_body);
END;


CREATE OR REPLACE PACKAGE ch12_var IS
  -- �������
     c_test CONSTANT VARCHAR2(10) := 'TEST';     
  -- �������� 
     v_test VARCHAR2(10);
     
  -- ���κ��� ���� �������� �Լ�   
  FUNCTION fn_get_value RETURN VARCHAR2;   
  
  -- ���κ��� ���� �����ϴ� ���ν���
  PROCEDURE sp_set_value ( ps_value VARCHAR2);

END ch12_var;

CREATE OR REPLACE PACKAGE BODY ch12_var IS
  -- �������
     c_test_body CONSTANT VARCHAR2(10) := 'CONSTANT_BODY';
     
  -- �������� 
     v_test_body VARCHAR2(10);
     
  -- ���κ��� ���� �������� �Լ�   
  FUNCTION fn_get_value RETURN VARCHAR2 
  IS
  
  BEGIN  	
  	-- ���� ���� ��ȯ�Ѵ�. 
  	RETURN NVL(v_test_body, 'NULL �̴�');
  END fn_get_value;  
  
  -- ���κ��� ���� �����ϴ� ���ν���
  PROCEDURE sp_set_value ( ps_value VARCHAR2)
  IS
  
  BEGIN
  	--���κ����� �� �Ҵ�
  	v_test_body := ps_value;
  END sp_set_value;

END ch12_var;


DECLARE 
  vs_value VARCHAR2(10);
  
BEGIN
	-- ���� �Ҵ�
	ch12_var.sp_set_value ('EXTERNAL');
	
	-- �� ����
	vs_value :=	ch12_var.fn_get_value;
	DBMS_OUTPUT.PUT_LINE(vs_value);
	
END;


  
BEGIN
	-- �� ����
	DBMS_OUTPUT.PUT_LINE(ch12_var.fn_get_value);	
END;


-- Ŀ��
-- ��Ű�� ����ο� Ŀ�� ��ü ����
CREATE OR REPLACE PACKAGE ch12_cur_pkg IS
  -- Ŀ����ü ����
  CURSOR pc_empdep_cur ( dep_id IN DEPARTMENTS.DEPARTMENT_ID%TYPE ) IS
    SELECT a.employee_id, a.emp_name, b.department_name
      FROM employees a, departments b
     WHERE a.department_id = dep_id
       AND a.department_id = b.department_id;   

END ch12_cur_pkg;

-- Ŀ�� ���
BEGIN
	FOR rec IN ch12_cur_pkg.pc_empdep_cur(30)
	LOOP
	  DBMS_OUTPUT.PUT_LINE(rec.emp_name || ' - ' || rec.department_name);
	
  END LOOP;	
END;


-- ROWTYPE�� Ŀ��
CREATE OR REPLACE PACKAGE ch12_cur_pkg IS
  -- Ŀ����ü ����
  CURSOR pc_empdep_cur ( dep_id IN departments.department_id%TYPE ) IS
    SELECT a.employee_id, a.emp_name, b.department_name
      FROM employees a, departments b
     WHERE a.department_id = dep_id
       AND a.department_id = b.department_id;   
       
  -- ROWTYPE�� Ŀ�� ������� 
  CURSOR pc_depname_cur ( dep_id IN departments.department_id%TYPE ) 
      RETURN departments%ROWTYPE;

END ch12_cur_pkg;

-- ��Ű�� ����
CREATE OR REPLACE PACKAGE BODY ch12_cur_pkg IS
       
  -- ROWTYPE�� Ŀ������ 
  CURSOR pc_depname_cur ( dep_id IN departments.department_id%TYPE ) 
      RETURN departments%ROWTYPE 
  IS
      SELECT *
        FROM departments
       WHERE department_id = dep_id;

END ch12_cur_pkg;

-- Ŀ�� ���2
BEGIN
	FOR rec IN ch12_cur_pkg.pc_depname_cur(30)
	LOOP
	  DBMS_OUTPUT.PUT_LINE(rec.department_id || ' - ' || rec.department_name);
	
  END LOOP;	
END;


-- ���ڵ� Ÿ�� Ŀ�� ����
CREATE OR REPLACE PACKAGE ch12_cur_pkg IS
  -- Ŀ����ü ����
  CURSOR pc_empdep_cur ( dep_id IN departments.department_id%TYPE ) IS
    SELECT a.employee_id, a.emp_name, b.department_name
      FROM employees a, departments b
     WHERE a.department_id = dep_id
       AND a.department_id = b.department_id;   
       
  -- ROWTYPE�� Ŀ�� ������� 
  CURSOR pc_depname_cur ( dep_id IN departments.department_id%TYPE ) 
      RETURN departments%ROWTYPE;
      
  -- ��������� ���ڵ� Ÿ��
  TYPE emp_dep_rt IS RECORD (
       emp_id     employees.employee_id%TYPE,
       emp_name   employees.emp_name%TYPE,
       job_title  jobs.job_title%TYPE );
       
  -- ��������� ���ڵ带 ��ȯ�ϴ� Ŀ��
  CURSOR pc_empdep2_cur ( p_job_id IN jobs.job_id%TYPE ) 
       RETURN emp_dep_rt;

END ch12_cur_pkg;

-- ���ڵ� Ÿ�� Ŀ�� ���� �ۼ�(��Ű�� ����)
CREATE OR REPLACE PACKAGE BODY ch12_cur_pkg IS
       
  -- ROWTYPE�� Ŀ������ 
  CURSOR pc_depname_cur ( dep_id IN departments.department_id%TYPE ) 
      RETURN departments%ROWTYPE 
  IS
      SELECT *
        FROM departments
       WHERE department_id = dep_id;
       
  -- ��������� ���ڵ带 ��ȯ�ϴ� Ŀ��
  CURSOR pc_empdep2_cur ( p_job_id IN jobs.job_id%TYPE ) 
      RETURN emp_dep_rt
  IS
      SELECT a.employee_id, a.emp_name, b.job_title
        FROM employees a,
             jobs b
       WHERE a.job_id = p_job_id
         AND a.job_id = b.job_id;

END ch12_cur_pkg;

-- Ŀ�����3
BEGIN
	FOR rec IN ch12_cur_pkg.pc_empdep2_cur('FI_ACCOUNT')
	LOOP
	  DBMS_OUTPUT.PUT_LINE(rec.emp_id || ' - ' || rec.emp_name || ' - ' || rec.job_title );
	
  END LOOP;	
END;

--��Ű�� Ŀ�� ���� ������
DECLARE
  -- Ŀ������ ����
  dep_cur ch12_cur_pkg.pc_depname_cur%ROWTYPE;
BEGIN
  -- Ŀ������
	OPEN ch12_cur_pkg.pc_depname_cur(30);
	
	LOOP
	  FETCH ch12_cur_pkg.pc_depname_cur INTO dep_cur;
    EXIT WHEN ch12_cur_pkg.pc_depname_cur%NOTFOUND;
	  DBMS_OUTPUT.PUT_LINE ( dep_cur.department_id || ' - ' || dep_cur.department_name);
  END LOOP;
  -- Ŀ���ݱ� 
  CLOSE ch12_cur_pkg.pc_depname_cur;	
END;


-- ���ڵ�� �÷���
-- ��Ű�� �����
CREATE OR REPLACE PACKAGE ch12_col_pkg IS
    -- ��ø ���̺� ����
    TYPE nt_dep_name IS TABLE OF VARCHAR2(30);
    
    -- ��ø ���̺� ���� ���� �� �ʱ�ȭ 
    pv_nt_dep_name nt_dep_name := nt_dep_name();
    
    -- ������ ��ø���̺� ������ ���� ���ν���
    PROCEDURE make_dep_proc ( p_par_id IN NUMBER) ;
    
END ch12_col_pkg;


-- ��Ű�� ����
CREATE OR REPLACE PACKAGE BODY ch12_col_pkg IS
   -- ������ ��ø���̺� ������ ���� ���ν���
  PROCEDURE make_dep_proc ( p_par_id IN NUMBER)
  IS
    
  BEGIN
  	-- �μ� ���̺��� PARENT_ID�� �޾� �μ����� �����´�. 
  	FOR rec IN ( SELECT department_name
  	               FROM departments
  	              WHERE parent_id = p_par_id )
  	LOOP
  	  -- ��ø ���̺� ���� EXTEND
  	  pv_nt_dep_name.EXTEND();
  	  -- ��ø ���̺� ������ �����͸� �ִ´�.
  	  pv_nt_dep_name( pv_nt_dep_name.COUNT) := rec.department_name;  	
  	
    END LOOP;  	
  	
  END make_dep_proc;
  
END ch12_col_pkg;
    	
    	
-- �÷��� ������ ���(1)
BEGIN
	-- 100�� �μ��� ���� �μ����� �÷��� ������ ��´�. 
	ch12_col_pkg.make_dep_proc(100);
	
	-- ������ ���� �÷��� ���� ���� ����Ѵ�
	FOR i IN 1..ch12_col_pkg.pv_nt_dep_name.COUNT
	LOOP
	  DBMS_OUTPUT.PUT_LINE( ch12_col_pkg.pv_nt_dep_name(i));
  END LOOP;
	
END;

-- �÷��� ������ ���(2)
BEGIN

	-- ������ ���� �÷��� ���� ���� ����Ѵ�
	FOR i IN 1..ch12_col_pkg.pv_nt_dep_name.COUNT
	LOOP
	  DBMS_OUTPUT.PUT_LINE( ch12_col_pkg.pv_nt_dep_name(i));
  END LOOP;
	
END;


--PRAGMA SERIALLY_REUSABLE �ɼ�
CREATE OR REPLACE PACKAGE ch12_col_pkg IS
    PRAGMA SERIALLY_REUSABLE;
    
    -- ��ø ���̺� ����
    TYPE nt_dep_name IS TABLE OF VARCHAR2(30);
    
    -- ��ø ���̺� ���� ���� �� �ʱ�ȭ 
    pv_nt_dep_name nt_dep_name := nt_dep_name();
    
    -- ������ ��ø���̺� ������ ���� ���ν���
    PROCEDURE make_dep_proc ( p_par_id IN NUMBER) ;
    
END ch12_col_pkg;


CREATE OR REPLACE PACKAGE BODY ch12_col_pkg IS

  PRAGMA SERIALLY_REUSABLE; 

   -- ������ ��ø���̺� ������ ���� ���ν���
  PROCEDURE make_dep_proc ( p_par_id IN NUMBER)
  IS
    
  BEGIN
  	-- �μ� ���̺��� PARENT_ID�� �޾� �μ����� �����´�. 
  	FOR rec IN ( SELECT department_name
  	               FROM departments
  	              WHERE parent_id = p_par_id )
  	LOOP
  	  -- ��ø ���̺� ���� EXTEND
  	  pv_nt_dep_name.EXTEND();
  	  -- ��ø ���̺� ������ �����͸� �ִ´�.
  	  pv_nt_dep_name( pv_nt_dep_name.COUNT) := rec.department_name;  	
  	
    END LOOP;  	
  	
  END make_dep_proc;
  
END ch12_col_pkg;

-- �÷��� ������ ���(1)
BEGIN
	-- 100�� �μ��� ���� �μ����� �÷��� ������ ��´�. 
	ch12_col_pkg.make_dep_proc(100);
	
	-- ������ ���� �÷��� ���� ���� ����Ѵ�
	FOR i IN 1..ch12_col_pkg.pv_nt_dep_name.COUNT
	LOOP
	  DBMS_OUTPUT.PUT_LINE( ch12_col_pkg.pv_nt_dep_name(i));
  END LOOP;
	
END;


-- �����ε�
CREATE OR REPLACE PACKAGE ch12_overload_pkg IS
   -- �Ű������� ����� �޾� �ش� ����� �μ����� ���
   PROCEDURE get_dep_nm_proc ( p_emp_id IN NUMBER);
   
   -- �Ű������� ������� �޾� �ش� ����� �μ����� ���
   PROCEDURE get_dep_nm_proc ( p_emp_name IN VARCHAR2);

END ch12_overload_pkg;


CREATE OR REPLACE PACKAGE BODY ch12_overload_pkg IS
   -- �Ű������� ����� �޾� �ش� ����� �μ����� ���
   PROCEDURE get_dep_nm_proc ( p_emp_id IN NUMBER)
   IS
     -- �μ��� ����
     vs_dep_nm departments.department_name%TYPE;
   BEGIN
   	 SELECT b.department_name
   	   INTO vs_dep_nm
   	   FROM employees a, departments b
   	  WHERE a.employee_id = p_emp_id
   	    AND a.department_id = b.department_id;
   	
   	 DBMS_OUTPUT.PUT_LINE('emp_id: ' || p_emp_id || ' - ' || vs_dep_nm);
   	
   END get_dep_nm_proc;
   
   -- �Ű������� ������� �޾� �ش� ����� �μ����� ���
   PROCEDURE get_dep_nm_proc ( p_emp_name IN VARCHAR2)
   IS
     -- �μ��� ����
     vs_dep_nm departments.department_name%TYPE;
   BEGIN
   	 SELECT b.department_name
   	   INTO vs_dep_nm
   	   FROM employees a, departments b
   	  WHERE a.emp_name      = p_emp_name
   	    AND a.department_id = b.department_id;
   	
   	 DBMS_OUTPUT.PUT_LINE('emp_name: ' || p_emp_name || ' - ' || vs_dep_nm);
   	
   END get_dep_nm_proc;


END ch12_overload_pkg;

-- ���ν��� �׽�Ʈ
BEGIN
	-- ����� ���� �μ��� ���
	ch12_overload_pkg.get_dep_nm_proc (176);
	
	-- ������� ���� �μ��� ���
	ch12_overload_pkg.get_dep_nm_proc ('Jonathon Taylor');	
	
END;


-- ���� ���Ͽ� : �ý��� ��Ű��

SELECT OWNER, OBJECT_NAME, OBJECT_TYPE, STATUS 
FROM ALL_OBJECTS
WHERE OBJECT_TYPE = 'PACKAGE'
  AND ( OBJECT_NAME LIKE 'DBMS%'  OR OBJECT_NAME LIKE 'UTL%')
ORDER BY OBJECT_NAME;


-- DBMS_METADATA ��Ű�� 
SELECT DBMS_METADATA.GET_DDL('TABLE', 'EMPLOYEES', 'ORA_USER')
 FROM DUAL;
 
 
SELECT DBMS_METADATA.GET_DDL('PACKAGE', 'ch12_OVERLOAD_PKG', 'ORA_USER')
 FROM DUAL; 
 
-- DBMS_RANDOM ��Ű��
SELECT DBMS_RANDOM.STRING ('U', 10) AS �빮��, 
       DBMS_RANDOM.STRING ('L', 10) AS �ҹ���,
       DBMS_RANDOM.STRING ('A', 10) AS ��ҹ���_ȥ��,
       DBMS_RANDOM.STRING ('X', 10) AS �빮�ڼ���_ȥ��,
       DBMS_RANDOM.STRING ('P', 10) AS Ư�����ڱ���_ȥ��
FROM DUAL;

