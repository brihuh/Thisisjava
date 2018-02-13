
1. ������ ���� ����� �����ϴ� ���ν����� ����� ����. 

   (1) ���ν����� : ch13_exam_crt_table_proc
   (2) �Ű�����   : ���̺�� (pv_src_table )
   (3) ����       : - �Ű������� �Ѿ�� ���̺�� ������ ������ ���̺��� �����ϴµ�, ���� �����ϴ� ���̺���� ���� ���̺�� '_NEW'�� �ٿ� �����Ѵ�. 
                    - NDS ������� �����. 

<����>

CREATE OR REPLACE PROCEDURE ch13_exam_crt_table_proc ( pv_src_table IN VARCHAR2 )
IS
  vs_sql       VARCHAR2(1000);
  vs_new_table VARCHAR2(100) := pv_src_table || '_NEW';
BEGIN
	-- ���̺� ����
	vs_sql := 'CREATE TABLE ' || vs_new_table || ' AS SELECT * FROM ' || pv_src_table;
	
	EXECUTE IMMEDIATE vs_sql;
	
END;



2. ch13_exam_crt_table_proc ���ν������� ������ ���̺��� �̹� ������ �������� �ʵ��� ������ ����. 


<����>

CREATE OR REPLACE PROCEDURE ch13_exam_crt_table_proc ( pv_src_table IN VARCHAR2 )
IS
  vs_sql       VARCHAR2(1000);
  vs_new_table VARCHAR2(100) := pv_src_table || '_NEW';
BEGIN
	
	-- ���̺� ����
	vs_sql := 'CREATE TABLE ' || vs_new_table || ' AS SELECT * FROM ' || pv_src_table;
	
	EXECUTE IMMEDIATE vs_sql;
	
EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
	
END;

3. ch13_physicist ���̺� ���� ���纻 ���̺��� ����� ���纻 �����͸� ���� ����, 
   �ٽ� ch13_physicist ���̺��� �����͸� ������ ������ ���� ���� �� ������ �̿��� ���纻 ���̺� �����͸� �ִ� �͸����� ����� ����. 
   
  
<����>
DECLARE 
  -- Ŀ��Ÿ�� ����
  TYPE query_physicist  IS REF CURSOR;
  -- Ŀ�� ���� ����
  myPhysicist  query_physicist;
  -- ��ȯ���� ���� ���ڵ� ����
  empPhysicist  ch13_physicist%ROWTYPE;
  
  vs_new_table  VARCHAR2(50) := 'ch13_physicist_new';
  vs_insert_sql VARCHAR2(1000);
  vs_select_sql VARCHAR2(1000);

BEGIN
	-- �ű� ���̺� ����
	ch13_exam_crt_table_proc ('ch13_physicist');
	-- ������ ����
	EXECUTE IMMEDIATE  'TRUNCATE TABLE ' || vs_new_table;
	
	-- ���� ��õ ���̺� �����͸� �����Ѵ�. 
  vs_select_sql := 'SELECT * FROM ch13_physicist';
  
  OPEN myPhysicist  FOR  vs_select_sql;
  
  --������ ���� Ŀ�������� ��� ���� ����Ѵ�.
  LOOP
    FETCH myPhysicist  INTO  empPhysicist;
    EXIT WHEN myPhysicist%NOTFOUND;	
    
    -- ���ο� ���̺� INSERT �Ѵ�. 
    vs_insert_sql := 'INSERT INTO ' || vs_new_table || ' VALUES ( ' || empPhysicist.ids || ',' || '''' || empPhysicist.names || '''' || ',' || 
                     'TO_DATE(' || '''' || empPhysicist.birth_dt || '''' ||  ' ))';
                     
    EXECUTE IMMEDIATE vs_insert_sql;                 
  END LOOP;
  -- Ŀ���� �ݴ´�
  CLOSE myPhysicist;
  
  COMMIT;
  
END;  

	
4. 3 ������ �ۼ��� �͸����� DBMS_SQL ��Ű���� ��ȯ�� �ۼ��غ���. 

<����>

DECLARE 
  vn_ids        ch13_physicist.ids%TYPE;
  vs_names      ch13_physicist.names%TYPE;
  vd_birth_dt   ch13_physicist.birth_dt%TYPE;
  
  vs_new_table  VARCHAR2(50) := 'ch13_physicist_new';
  vs_insert_sql VARCHAR2(1000);
  vs_select_sql VARCHAR2(1000);
  
  vn_sel_cur_id NUMBER := DBMS_SQL.OPEN_CURSOR(); 
  vn_ins_cur_id NUMBER := DBMS_SQL.OPEN_CURSOR(); 
  
  vn_sel_return NUMBER;
  vn_ins_return NUMBER;

BEGIN
	-- �ű� ���̺� ����
	ch13_exam_crt_table_proc ('ch13_physicist');
	-- ������ ����
	EXECUTE IMMEDIATE  'TRUNCATE TABLE ' || vs_new_table;
	
	-- ���� ��õ ���̺� �����͸� �����Ѵ�. 
  vs_select_sql := 'SELECT * FROM ch13_physicist';
  
  DBMS_SQL.PARSE (vn_sel_cur_id, vs_select_sql, DBMS_SQL.NATIVE);  
  
  DBMS_SQL.DEFINE_COLUMN ( vn_sel_cur_id, 1, vn_ids);
  DBMS_SQL.DEFINE_COLUMN ( vn_sel_cur_id, 2, vs_names, 80);   
  DBMS_SQL.DEFINE_COLUMN ( vn_sel_cur_id, 3, vd_birth_dt);
  
  vn_sel_return := DBMS_SQL.EXECUTE (vn_sel_cur_id);
  
  -- INSERT�� ó��
  vs_insert_sql := 'INSERT INTO ' || vs_new_table || ' VALUES (:a, :b, :c)';
  DBMS_SQL.PARSE (vn_ins_cur_id, vs_insert_sql, DBMS_SQL.NATIVE);
  
  LOOP
    -- ����Ǽ��� ������ ������ ����������. 
    IF DBMS_SQL.FETCH_ROWS (vn_sel_cur_id) = 0 THEN
       EXIT;
    END IF;
    
    --  ��ġ�� ����� �޾ƿ��� 
    DBMS_SQL.COLUMN_VALUE ( vn_sel_cur_id, 1, vn_ids);
    DBMS_SQL.COLUMN_VALUE ( vn_sel_cur_id, 2, vs_names);
    DBMS_SQL.COLUMN_VALUE ( vn_sel_cur_id, 3, vd_birth_dt);
    
    -- INSERT�� ���ε� ���� ó�� 
    DBMS_SQL.BIND_VARIABLE ( vn_ins_cur_id, ':a', vn_ids);
    DBMS_SQL.BIND_VARIABLE ( vn_ins_cur_id, ':b', vs_names);
    DBMS_SQL.BIND_VARIABLE ( vn_ins_cur_id, ':c', vd_birth_dt);
    
    -- INSERT�� ����
    vn_ins_return := DBMS_SQL.EXECUTE (vn_ins_cur_id);
    
  END LOOP;
  
  -- Ŀ�� �ݱ�
  DBMS_SQL.CLOSE_CURSOR (vn_sel_cur_id);  -- select �� Ŀ��  
  DBMS_SQL.CLOSE_CURSOR (vn_ins_cur_id);  -- insert �� Ŀ�� 
  
  
END;  
  

5. 4 ������ �ۼ��� �͸����� �ڵ带 �� �� �����ϰ� �ٿ�����. (��Ʈ: BULK DML ���·� �ۼ��� ��)

<����>

DECLARE 
  vc_cur          SYS_REFCURSOR;  -- Ŀ������
  vn_ids_array    DBMS_SQL.NUMBER_TABLE;
  vs_name_array   DBMS_SQL.VARCHAR2_TABLE;
  vd_dt_array     DBMS_SQL.DATE_TABLE;
  
  vs_new_table  VARCHAR2(50) := 'ch13_physicist_new';
  vs_insert_sql VARCHAR2(1000);
  vs_select_sql VARCHAR2(1000);
  
  vn_sel_cur_id NUMBER := DBMS_SQL.OPEN_CURSOR(); 
  vn_ins_cur_id NUMBER := DBMS_SQL.OPEN_CURSOR(); 
  
  vn_sel_return NUMBER;
  vn_ins_return NUMBER;

BEGIN
	-- �ű� ���̺� ����
	ch13_exam_crt_table_proc ('ch13_physicist');
	-- ������ ����
	EXECUTE IMMEDIATE  'TRUNCATE TABLE ' || vs_new_table;
	
	-- ���� ��õ ���̺� �����͸� �����Ѵ�. 
  vs_select_sql := 'SELECT * FROM ch13_physicist';
  
  DBMS_SQL.PARSE (vn_sel_cur_id, vs_select_sql, DBMS_SQL.NATIVE);  
  
  vn_sel_return := DBMS_SQL.EXECUTE (vn_sel_cur_id);
  
  -- DBMS_SQL.TO_REFCURSOR�� ����� Ŀ���� ��ȯ 
  vc_cur := DBMS_SQL.TO_REFCURSOR ( vn_sel_cur_id );
  
  -- ��ȯ�� Ŀ���� ����� ����� ��ġ�ϰ� ��� ���
  FETCH vc_cur  BULK COLLECT INTO vn_ids_array, vs_name_array, vd_dt_array;
  
  -- INSERT�� ó��
  vs_insert_sql := 'INSERT INTO ' || vs_new_table || ' VALUES (:a, :b, :c)';
  DBMS_SQL.PARSE (vn_ins_cur_id, vs_insert_sql, DBMS_SQL.NATIVE);
  
  -- ���ε� �迭 ���� 
  DBMS_SQL.BIND_ARRAY ( vn_ins_cur_id, ':a', vn_ids_array);
  DBMS_SQL.BIND_ARRAY ( vn_ins_cur_id, ':b', vs_name_array);
  DBMS_SQL.BIND_ARRAY ( vn_ins_cur_id, ':c', vd_dt_array);
  
  -- INSERT�� ����
  vn_ins_return := DBMS_SQL.EXECUTE (vn_ins_cur_id);
  
  -- Ŀ�� �ݱ�
  
  CLOSE vc_cur; -- SELECT�� Ŀ��   
  DBMS_SQL.CLOSE_CURSOR (vn_ins_cur_id);  -- insert �� Ŀ��
  
  COMMIT;  
  
END;  