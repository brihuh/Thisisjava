--

1. hr_pkg���� ����̸���ȯ, �űԻ���Է�, ������� ó���ϴ� ���� ���α׷��� �ִ�. 
   hr_pkg2��� ��Ű���� �����, �̹����� �μ��̸���ȯ, �űԺμ��Է�, �μ��� �����ϴ� �������α׷��� ����� ����. 
   ( ��, �μ��� ������ ���� ������ �μ��� ���� ����� �ִ��� üũ�ؼ�, ������ �޽���ó���ϰ� ���� ��츸 �����ؾ� �Ѵ�)
   
<����>

CREATE OR REPLACE PACKAGE hr_pkg2 IS

  -- �μ���ȣ�� �޾� �μ����� ��ȯ�ϴ� �Լ�
  FUNCTION fn_get_dep_name ( pn_department_id IN NUMBER )
     RETURN VARCHAR2;
     
  -- �űԺμ� �Է�  
  PROCEDURE new_emp_proc ( ps_dep_name   IN VARCHAR2, 
                           pn_parent_id  IN NUMBER, 
                           pn_manager_id IN NUMBER);
                               
  -- �μ�����ó��                     
  PROCEDURE del_dep_proc ( pn_department_id IN NUMBER );
  
END  hr_pkg2; 

CREATE OR REPLACE PACKAGE BODY hr_pkg2 IS

  -- �μ���ȣ�� �޾� �μ����� ��ȯ�ϴ� �Լ�
  FUNCTION fn_get_dep_name ( pn_department_id IN NUMBER )
     RETURN VARCHAR2
  IS
    vs_dep_name departments.department_name%TYPE;
  BEGIN
  
    SELECT department_name
      INTO vs_dep_name
      FROM departments 
     WHERE department_id = pn_department_id;
     
     RETURN vs_dep_name;

     EXCEPTION WHEN OTHERS THEN
           RETURN '�ش� �μ� ����';
           
  END fn_get_dep_name;
     
  -- �űԺμ� �Է�  
  PROCEDURE new_emp_proc ( ps_dep_name   IN VARCHAR2, 
                           pn_parent_id  IN NUMBER, 
                           pn_manager_id IN NUMBER)
  IS
     vn_max_dep_id departments.department_id%TYPE;
     vn_cnt NUMBER := 0;
  BEGIN
     SELECT COUNT(*)
       INTO vn_cnt
       FROM departments
      WHERE department_name = ps_dep_name;
      
     SELECT NVL(max(department_id),0) + 1
       INTO vn_max_dep_id
       FROM departments;
      
     IF vn_cnt > 0 THEN
        DBMS_OUTPUT.PUT_LINE(ps_dep_name || ' ��� �μ��� �̹� �����մϴ�!');
        RETURN;
     END IF;
     
     INSERT INTO departments (department_id, department_name, parent_id, manager_id, create_date, update_date)
     VALUES (vn_max_dep_id, ps_dep_name, pn_parent_id, pn_manager_id, SYSDATE, SYSDATE);
     
     COMMIT;
     
     EXCEPTION WHEN OTHERS THEN
              DBMS_OUTPUT.PUT_LINE(SQLERRM);
              ROLLBACK;
  END new_emp_proc;
                               
  -- �μ�����ó��                     
  PROCEDURE del_dep_proc ( pn_department_id IN NUMBER )
  IS 
    vn_cnt1 NUMBER := 0;
    vn_cnt2 NUMBER := 0;
  BEGIN
  
    SELECT COUNT(*)
      INTO vn_cnt1
      FROM departments 
     WHERE department_id = pn_department_id;
  
     IF vn_cnt1 = 0 THEN
        DBMS_OUTPUT.PUT_LINE(pn_department_id || ' �μ��� �������� �ʽ��ϴ�!');
        RETURN;
     END IF;  
     
    SELECT COUNT(*)
      INTO vn_cnt2
      FROM employees 
     WHERE department_id = pn_department_id
       AND retire_date IS NOT NULL;
  
     IF vn_cnt2 > 0 THEN
        DBMS_OUTPUT.PUT_LINE(pn_department_id || ' �μ��� ���� ����� �����ϹǷ� ������ �� �����ϴ�');
        RETURN;
     END IF;       
     
     DELETE departments
      WHERE department_id = pn_department_id;
      
     COMMIT;
     
     EXCEPTION WHEN OTHERS THEN
              DBMS_OUTPUT.PUT_LINE(SQLERRM);
              ROLLBACK;     

  END del_dep_proc;
  
END  hr_pkg2; 


   
2. ����Ŭ������ ä���� �� ��, ���� ������ ��ü�� ����Ѵ�. 
   ���� ���, �ű� ��� �Է� �� ����� �����;� �ϴµ�, �� �� ��� �������� ������ ������ "���������.NEXTVAL"�� ���� ������ ����� ������ �� �ִ�. 
   ch12_seq_pkg�� �̸��� ��Ű���� ������ ó�� �����ϵ��� get_nextval �̶� �Լ��� ������. 
   �� �Լ��� ���Ǻ� ������ ���� �����;� �ϸ� �ʱⰪ�� 1, 1�� �����ϰ� ������ �޶����� �ٽ� �ʱⰪ�� �����;� �Ѵ�. 
   
   
<����>   

CREATE OR REPLACE PACKAGE ch12_seq_pkg IS
   -- ���� ������ ��ȣ ��ȯ �Լ� 
    FUNCTION get_nextval RETURN NUMBER;
END ch12_seq_pkg;


CREATE OR REPLACE PACKAGE BODY ch12_seq_pkg IS
    -- ������ ��ȣ�� ���� ����(PRIVATE) ���� ���� 
    cv_seq NUMBER := 0;
    
    -- ���� ������ ��ȣ ��ȯ �Լ� 
    FUNCTION get_nextval RETURN NUMBER
    IS     
    BEGIN
       -- 1�� ������Ų��. 
       cv_seq := cv_seq + 1;
       -- ������ ��ȣ ��ȯ 
       RETURN cv_seq;
    END get_nextval;
END ch12_seq_pkg;

   
3. ��Ű�� Ŀ���� ����� ���� �����ؾ� �Ѵ�. ��, ��� �� Ŀ���� ���� �ʾ��� ���, ���� ���ǿ��� �ٽ� �ش� Ŀ���� ����� �� ������ �߻��Ѵ�. 
   
   CREATE OR REPLACE PACKAGE ch12_exacur_pkg IS 
       
     -- ROWTYPE�� Ŀ�� ������� 
     CURSOR pc_depname_cur ( dep_id IN departments.department_id%TYPE ) 
         RETURN departments%ROWTYPE;

   END ch12_exacur_pkg;
   
   ch12_exacur_pkg ��Ű���� ������ε�. pc_depname_cur Ŀ���� ����� �μ������� �����ϴ� ���ν����� �߰��غ���. 
   ��, �� ���ν��� ���ο����� �ش� Ŀ���� "����-��ġ-�ݱ�" �۾��� �����ؾ� �ϸ�, 
   �ش� Ŀ���� ���� Ȥ�ö� ���� ���� ���� ��쿡�� ������ �߻���Ű�� ���� �ݴ� �۾����� �����ϵ��� �ۼ��ؾ� �Ѵ�. 
   
   
<����>   

   CREATE OR REPLACE PACKAGE ch12_exacur_pkg IS 
       
     -- ROWTYPE�� Ŀ�� ������� 
     CURSOR pc_depname_cur ( p_parent_id IN departments.department_id%TYPE ) 
         RETURN departments%ROWTYPE;
         
     -- Ŀ�� ó�� ���ν���     
     PROCEDURE cur_example_proc ( p_parent_id IN NUMBER);

   END ch12_exacur_pkg;
   
   
   CREATE OR REPLACE PACKAGE BODY ch12_exacur_pkg IS 
       
     -- ROWTYPE�� Ŀ�� ���� 
     CURSOR pc_depname_cur ( p_parent_id IN departments.department_id%TYPE ) 
         RETURN departments%ROWTYPE
     IS 
        SELECT *
          FROM departments
         WHERE parent_id = p_parent_id;
         
     -- Ŀ�� ó�� ���ν���     
     PROCEDURE cur_example_proc ( p_parent_id IN NUMBER)
     IS
      -- Ŀ������ ����
      dep_cur  ch12_exacur_pkg.pc_depname_cur%ROWTYPE;

     BEGIN
     
       -- Ŀ���� ���� ������ Ŀ���� �ݴ´�. 
       IF ch12_exacur_pkg.pc_depname_cur%ISOPEN THEN
          CLOSE ch12_exacur_pkg.pc_depname_cur;
       END IF;
       
       OPEN ch12_exacur_pkg.pc_depname_cur(p_parent_id);

       LOOP
         FETCH ch12_exacur_pkg.pc_depname_cur INTO dep_cur;
         EXIT WHEN ch12_exacur_pkg.pc_depname_cur%NOTFOUND;
         DBMS_OUTPUT.PUT_LINE ( dep_cur.department_id || ' - ' || dep_cur.department_name);
       END LOOP;
       
       -- Ŀ���ݱ� 
       CLOSE ch12_exacur_pkg.pc_depname_cur;	     
     
     END cur_example_proc;        

   END ch12_exacur_pkg;   
   


4. ������ ���� ����� �����ϴ� get_dep_hierarchy_proc �� �̸����� 2���� ���ν����� ������. 
   (1) �Ű����� : department_id
       ���     : �μ� ��ȣ�� �μ���
       
   (2) �Ű����� : department_id, parent_id
       ���     : �ش� �μ���ȣ�� �μ���,
                  parent_id�� ���ϴ� ��� �μ���ȣ�� �μ���
                  
<����>
                  
CREATE OR REPLACE PACKAGE ch12_exam4_pkg IS

    PROCEDURE get_dep_hierarchy_proc ( p_dep_id IN NUMBER);
    
    PROCEDURE get_dep_hierarchy_proc ( p_dep_id IN NUMBER, 
                                       p_par_id IN NUMBER);

END ch12_exam4_pkg;


CREATE OR REPLACE PACKAGE BODY ch12_exam4_pkg IS

    PROCEDURE get_dep_hierarchy_proc ( p_dep_id IN NUMBER)
    IS
      vn_dep_id    departments.department_id%TYPE;
      vs_dep_name  departments.department_name%TYPE;
    BEGIN
    	
    	SELECT department_id, department_name
    	  INTO vn_dep_id, vs_dep_name
    	  FROM departments
    	 WHERE department_id = p_dep_id;
    	
    	DBMS_OUTPUT.PUT_LINE('�μ���ȣ: ' || vn_dep_id);
    	DBMS_OUTPUT.PUT_LINE('�μ��� : ' ||  vs_dep_name);
    	
    END get_dep_hierarchy_proc;
    
    PROCEDURE get_dep_hierarchy_proc ( p_dep_id IN NUMBER, 
                                       p_par_id IN NUMBER )
    IS
      vn_dep_id    departments.department_id%TYPE;
      vs_dep_name  departments.department_name%TYPE;   
      
    -- Ŀ�� ���� 
    CURSOR my_dep ( p_par_id departments.parent_id%TYPE ) IS
      SELECT department_id AS dep_id, LPAD(' ' , 3 * (LEVEL-1)) || department_name AS dep_nm
        FROM departments
       START WITH parent_id = p_par_id
     CONNECT BY PRIOR department_id  = parent_id;      
    
    BEGIN
    	
    	SELECT department_id, department_name
    	  INTO vn_dep_id, vs_dep_name
    	  FROM departments
    	 WHERE department_id = p_dep_id;
    	
    	DBMS_OUTPUT.PUT_LINE('�μ���ȣ: ' || vn_dep_id);
    	DBMS_OUTPUT.PUT_LINE('�μ��� : ' ||  vs_dep_name);    
    	
    	FOR rec IN my_dep(p_par_id)
    	LOOP
    	   DBMS_OUTPUT.PUT_LINE( rec.dep_id || ' - ' || rec.dep_nm);
    	
      END LOOP;
    		
    	
    END get_dep_hierarchy_proc;    

END ch12_exam4_pkg;



5. �ý��� ��Ű���� DBMS_METADATA�� ����� DBMS_OUTPUT ��Ű�� �ҽ��� �����غ���. 

<����>

SELECT DBMS_METADATA.GET_DDL('PACKAGE', 'DBMS_OUTPUT', 'SYS')
  FROM DUAL;

   --�ҽ��� �����غ��� �̻��� ���ڷ� ������ ���� ���̴�. �� ������ dbms_output �ý��� ��Ű����
   --��(����)�� ���������� body �κ��� �������ֱ� �����̴�. 

