--
1. ������ 7�忡�� �н��ߴ� �μ��� ������ �����̴�. 

SELECT department_id, LPAD(' ' , 3 * (LEVEL-1)) || department_name, LEVEL
  FROM departments
  START WITH parent_id IS NULL
CONNECT BY PRIOR department_id  = parent_id;

�� ����� ������ ����� ������ my_dep_hier_proc�� �̸����� ���ν����� ������.
������ ���� ������ ���� ������� ����, Ŀ���� �ݺ����� ����ؼ� ������ ����. 


<����>

CREATE OR REPLACE PROCEDURE my_dep_hier_proc (
               p_start  departments.department_name%TYPE,
               p_level  NUMBER )
IS
BEGIN
	 DBMS_OUTPUT.PUT_LINE( LPAD( ' ', p_level*2, ' ' ) || p_start );
	 
	 FOR c in ( SELECT * 
	                from departments
                 where parent_id in ( select department_id
                                            from departments
                                          where department_name = p_start )
                 order by department_name )
    LOOP
          my_dep_hier_proc ( c.ename, p_level+1 );
    END LOOP;
	
END;



2. ������ �÷��� ������ ����� Ÿ���� ���̺��� ���ڵ��� ��ø���̺��� ������ ��������� ����Ͽ���. 
   �̹����� ��ø���̺� ��� �����迭�� ����ؼ� ������� �ε����� �ؼ� �̸��� ������ ����ϴ� �͸����� �ۼ��غ���. 
   
   
<����>

DECLARE
    -- �����迭 ����
    TYPE av_type IS TABLE OF employees.email%TYPE INDEX BY employees.emp_name%TYPE;

   -- �����迭 ��������
   vav_test  av_type;
BEGIN
  -- Ŀ���� ����� for���� ���鼭 �����迭�� �����͸� �ִ´�. 
  FOR rec IN ( SELECT emp_name, email
                 FROM employees )
  LOOP
     -- �ε��� Ű�� �������, ������ �̸����� �ִ´�. 
     vav_test(rec.emp_name) := rec.email;  
  END LOOP;
    
  DBMS_OUTPUT.PUT_LINE( 'Elizabeth Bates �� �̸��� �ּҴ� ' || vav_test('Elizabeth Bates'));
  DBMS_OUTPUT.PUT_LINE( 'Kimberely Grant �� �̸��� �ּҴ� ' || vav_test('Kimberely Grant'));  

END;
   
   
   
   
3. ������� ������ �ޱ� ���� �ϴ� ��ø���̺� nt_ch11_emp ��� �̸����� ��������� Ÿ������ ������.

<����>

-- ��ø ���̺� Ÿ���� �����. 
CREATE OR REPLACE TYPE nt_ch11_emp IS TABLE OF VARCHAR2(80);
             



4. �Ű������� �μ���ȣ�� �ѱ�� �ش� �μ��� ���� �����ȣ, ����̸�, �μ��̸��� ����ϴ� ���ν����� ������. 
   ��, �����ȣ, ����̸�, �μ��̸� ������ ��ȸ�� ������ ��ø���̺� ���� ����, �ٽ� �� ��ø ���̺� �� �����͸� ����ϵ��� �ۼ��غ���. 


<����>
      
CREATE OR REPLACE PROCEDURE ch11_emp_proc ( p_dep_id departments.department_id%TYPE )


IS
  -- ��������� �޴� Ŀ�� ���� 
  CURSOR c1 IS
    SELECT a.employee_id, a.emp_name, b.department_name
      FROM employees a,
           departments b
     WHERE a.department_id = b.department_id;
      
  -- ��ø���̺� ����     
  TYPE nt_ch11_emp IS TABLE OF c1%ROWTYPE;
  
  -- ��ø���̺� ���� ���� 
  vnt_test nt_ch11_emp; 



BEGIN

  -- 1�� �̻� �����͸� ���� ���� BULK COLLECT INTO ������ ����Ѵ�
  
    SELECT a.employee_id, a.emp_name, b.department_name
    BULK COLLECT INTO vnt_test
      FROM employees a,
           departments b
     WHERE a.department_id = b.department_id
       AND a.department_id = p_dep_id;
  
  FOR i IN vnt_test.FIRST .. vnt_test.LAST 
  LOOP
      DBMS_OUTPUT.PUT_LINE (
           vnt_test(i).employee_id || ' ' ||
           vnt_test(i).emp_name || ', ' ||
           vnt_test(i).department_name
      );
  END LOOP;
  
END;  
   