-- 01. ����

-- MSSQL ���ν���

CREATE PROCEDURE test_proc 
AS
  -- �ӽ� ���̺� ����
  CREATE #ch13_physicist (
         ids      INT,
         names    VARCAR(30),
         birth_dt DATETIME );
         
  -- ����Ͻ� ���� ó��.
  ....
  ....
  
  -- �ӽ� ���̺� ������ insert
  INSERT INTO #ch13_physicist
  SELECT ....
  
  
  -- �������� �ӽ� ���̺� SELECT
  SELECT *
    FROM #ch13_physicist
    

-- 02. GTT
-- (1) Ʈ����� GTT

CREATE GLOBAL TEMPORARY TABLE ch14_tranc_gtt
     (
       ids        NUMBER,
       names      VARCHAR2(50),
       birth_dt   DATE  
     )
 ON COMMIT DELETE ROWS;  
 
 
       
DECLARE 
   vn_cnt  int  := 0;
   vn_cnt2 int  := 0;

BEGIN
	-- �����͸� �ִ´�. 
	INSERT INTO ch14_tranc_gtt
	SELECT *
	  FROM ch13_physicist;
	  
	-- COMMIT �� ������ �Ǽ�  
  SELECT COUNT(*)
    INTO vn_cnt
    FROM ch14_tranc_gtt;
    
  COMMIT;
  
	-- COMMIT �� ������ �Ǽ�  
  SELECT COUNT(*)
    INTO vn_cnt2
    FROM ch14_tranc_gtt;  
    
  DBMS_OUTPUT.PUT_LINE('COMMIT ��: ' || vn_cnt);
  DBMS_OUTPUT.PUT_LINE('COMMIT ��: ' || vn_cnt2);
    
	
END;          


-- (2) ���� GTT
CREATE GLOBAL TEMPORARY TABLE ch14_sess_gtt
     (
       ids        NUMBER,
       names      VARCHAR2(50),
       birth_dt   DATE  
     )
 ON COMMIT PRESERVE ROWS;
 
DECLARE 
   vn_cnt  int  := 0;
   vn_cnt2 int  := 0;

BEGIN
	-- �����͸� �ִ´�. 
	INSERT INTO ch14_sess_gtt
	SELECT *
	  FROM ch13_physicist;
	  
	-- COMMIT �� ������ �Ǽ�  
  SELECT COUNT(*)
    INTO vn_cnt
    FROM ch14_sess_gtt;
    
  COMMIT;
  
	-- COMMIT �� ������ �Ǽ�  
  SELECT COUNT(*)
    INTO vn_cnt2
    FROM ch14_sess_gtt;  
    
  DBMS_OUTPUT.PUT_LINE('COMMIT ��: ' || vn_cnt);
  DBMS_OUTPUT.PUT_LINE('COMMIT ��: ' || vn_cnt2);
    
	
END; 


-- TABLE �Լ�
-- (2) ����� ���� ���̺� �Լ�
CREATE OR REPLACE TYPE ch14_num_nt IS TABLE OF NUMBER;

CREATE OR REPLACE FUNCTION fn_ch14_table1 ( p_n NUMBER )
    RETURN ch14_num_nt
IS
  -- �÷��� ���� ���� (�÷��� Ÿ���̹Ƿ� �ʱ�ȭ�� �Ѵ�)
  vnt_return ch14_num_nt := ch14_num_nt();
BEGIN
  -- 1���� �Է¸Ű������� p_n��ŭ ���ڸ� �ִ´�.   
  FOR i IN 1..p_n
  LOOP
    vnt_return.EXTEND;
    vnt_return(i) := i;  
  END LOOP;

  RETURN vnt_return; -- �÷��� Ÿ���� ��ȯ�Ѵ�. 
END;

SELECT fn_ch14_table1 (10)
FROM DUAL;

SELECT *
  FROM TABLE(fn_ch14_table1 (10));
  
-- Ŀ���� �Ű�������

CREATE OR REPLACE TYPE ch14_obj_type1 AS OBJECT (
         varchar_col1    VARCHAR2(100),
         varchar_col2    VARCHAR2(100),
         num_col       NUMBER,
         date_col       DATE               );


CREATE OR REPLACE TYPE ch14_cmplx_nt IS TABLE OF ch14_obj_type1;

  
CREATE OR REPLACE PACKAGE ch14_empty_pkg 
IS
  -- ������̺� ���� Ŀ�� 
  TYPE emp_refc_t IS REF CURSOR RETURN employees%ROWTYPE;

END ch14_empty_pkg;

  
CREATE OR REPLACE FUNCTION fn_ch14_table2 ( p_cur ch14_empty_pkg.emp_refc_t )
   RETURN ch14_cmplx_nt
IS
   -- �Է� Ŀ���� ���� ���� ����
   v_cur  p_cur%ROWTYPE;
   
   -- ��ȯ�� �÷��� ���� ���� (�÷��� Ÿ���̹Ƿ� �ʱ�ȭ�� �Ѵ�)
   vnt_return  ch14_cmplx_nt :=  ch14_cmplx_nt();  
BEGIN
   -- ������ ���� �Է� �Ű����� p_cur�� v_cur�� ��ġ
   LOOP
     FETCH p_cur INTO v_cur;
     EXIT WHEN p_cur%NOTFOUND; 
     
     -- �÷��� Ÿ���̹Ƿ� EXTEND �޼Ҹ� ����� �� �ο쾿 �ű� ����
     vnt_return.EXTEND();
     -- �÷��� ����� OBJECT Ÿ�Կ� ���� �ʱ�ȭ 
     vnt_return(vnt_return.LAST) := ch14_obj_type1(null, null, null, null);
     -- �÷��� ������ Ŀ�������� �� �Ҵ� 
     vnt_return(vnt_return.LAST).varchar_col1 := v_cur.emp_name; 
     vnt_return(vnt_return.LAST).varchar_col2 := v_cur.phone_number; 
     vnt_return(vnt_return.LAST).num_col      := v_cur.employee_id;
     vnt_return(vnt_return.LAST).date_col     := v_cur.hire_date;
     
   END LOOP;
   -- �÷��� ��ȯ
   RETURN vnt_return;
END;


SELECT *
FROM TABLE( fn_ch14_table2 ( CURSOR ( SELECT * FROM EMPLOYEES WHERE ROWNUM < 6)
                           ));  

-- (3) ���������� ���̺� �Լ�

CREATE OR REPLACE FUNCTION fn_ch14_pipe_table ( p_n NUMBER )
    RETURN ch14_num_nt
    PIPELINED
IS
  -- �÷��� ���� ���� (�÷��� Ÿ���̹Ƿ� �ʱ�ȭ�� �Ѵ�)
  vnt_return ch14_num_nt := ch14_num_nt();
BEGIN
  -- 1���� �Է¸Ű������� p_n��ŭ ���ڸ� �ִ´�.   
  FOR i IN 1..p_n
  LOOP
    vnt_return.EXTEND;
    vnt_return(i) := i;  
    
    -- �÷��� Ÿ���� ��ȯ�Ѵ�. 
    PIPE ROW (vnt_return(i));
    
  END LOOP;

  RETURN; 
END;

SELECT *
  FROM TABLE(fn_ch14_pipe_table (10));  
  
  
-- �Ϲ� ���̺� �Լ� (4,000,000ȸ ����)
SELECT *
FROM TABLE( fn_ch14_table1 (4000000));

-- ���������� ���̺� �Լ� (4,000,000ȸ ����)
SELECT count(*)
FROM TABLE( fn_ch14_pipe_table (4000000));


CREATE OR REPLACE FUNCTION fn_ch14_pipe_table2 ( p_cur ch14_empty_pkg.emp_refc_t )
   RETURN ch14_cmplx_nt
   PIPELINED
IS
   -- �Է� Ŀ���� ���� ���� ����
   v_cur  p_cur%ROWTYPE;
   
   -- ��ȯ�� �÷��� ���� ���� (�÷��� Ÿ���̹Ƿ� �ʱ�ȭ�� �Ѵ�)
   vnt_return  ch14_cmplx_nt :=  ch14_cmplx_nt();  
BEGIN
   -- ������ ���� �Է� �Ű����� p_cur�� v_cur�� ��ġ
   LOOP
     FETCH p_cur INTO v_cur;
     EXIT WHEN p_cur%NOTFOUND; 
     
     -- �÷��� Ÿ���̹Ƿ� EXTEND �޼Ҹ� ����� �� �ο쾿 �ű� ����
     vnt_return.EXTEND();
     -- �÷��� ����� OBJECT Ÿ�Կ� ���� �ʱ�ȭ 
     vnt_return(vnt_return.LAST) := ch14_obj_type1(null, null, null, null);
     -- �÷��� ������ Ŀ�������� �� �Ҵ� 
     vnt_return(vnt_return.LAST).varchar_col1 := v_cur.emp_name; 
     vnt_return(vnt_return.LAST).varchar_col2 := v_cur.phone_number;      
     vnt_return(vnt_return.LAST).num_col      := v_cur.employee_id;
     vnt_return(vnt_return.LAST).date_col     := v_cur.hire_date;
     PIPE ROW ( vnt_return(vnt_return.LAST)); -- ù ��° ��ȯ
     
     vnt_return(vnt_return.LAST).varchar_col1 := v_cur.job_id; 
     vnt_return(vnt_return.LAST).varchar_col2 := v_cur.email;  
     PIPE ROW ( vnt_return(vnt_return.LAST)); -- �� ��° ��ȯ
   END LOOP;
   RETURN; 
END;

-- ������Ͽ�
CREATE TABLE ch14_score_table (
       YEARS     VARCHAR2(4),   -- ����
       GUBUN     VARCHAR2(30),  -- ����(�߰�/�⸻)
       SUBJECTS  VARCHAR2(30),  -- ����
       SCORE     NUMBER );      -- ����
       
INSERT INTO ch14_SCORE_TABLE VALUES('2014','�߰����','����',92);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','�߰����','����',87);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','�߰����','����',67);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','�߰����','����',80);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','�߰����','����',93);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','�߰����','���Ͼ�',82);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','�⸻���','����',88);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','�⸻���','����',80);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','�⸻���','����',93);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','�⸻���','����',91);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','�⸻���','����',89);
INSERT INTO ch14_SCORE_TABLE VALUES('2014','�⸻���','���Ͼ�',83);
COMMIT;

SELECT *
FROM ch14_score_table;

-- �ο츦 �÷�����
-- DECODE�� CASE

SELECT years, 
       gubun, 
       CASE WHEN subjects = '����'   THEN score ELSE 0 END "����",
       CASE WHEN subjects = '����'   THEN score ELSE 0 END "����",
       CASE WHEN subjects = '����'   THEN score ELSE 0 END "����",
       CASE WHEN subjects = '����'   THEN score ELSE 0 END "����",
       CASE WHEN subjects = '����'   THEN score ELSE 0 END "����",
       CASE WHEN subjects = '���Ͼ�' THEN score ELSE 0 END "���Ͼ�"
  FROM ch14_score_table a;
  
SELECT years, gubun, 
       SUM(����) AS ����, SUM(����) AS ����, SUM(����) AS ����,
       SUM(����) AS ����, SUM(����) AS ����, SUM(���Ͼ�) AS ���Ͼ�
FROM (
SELECT years, 
       gubun, 
       CASE WHEN subjects = '����'   THEN score ELSE 0 END "����",
       CASE WHEN subjects = '����'   THEN score ELSE 0 END "����",
       CASE WHEN subjects = '����'   THEN score ELSE 0 END "����",
       CASE WHEN subjects = '����'   THEN score ELSE 0 END "����",
       CASE WHEN subjects = '����'   THEN score ELSE 0 END "����",
       CASE WHEN subjects = '���Ͼ�' THEN score ELSE 0 END "���Ͼ�"
  FROM ch14_score_table a
)
GROUP BY years, gubun;

-- WITH���� �̿��� ���
WITH mains AS ( SELECT years, 
                       gubun, 
                       CASE WHEN subjects = '����'   THEN score ELSE 0 END "����",
                       CASE WHEN subjects = '����'   THEN score ELSE 0 END "����",
                       CASE WHEN subjects = '����'   THEN score ELSE 0 END "����",
                       CASE WHEN subjects = '����'   THEN score ELSE 0 END "����",
                       CASE WHEN subjects = '����'   THEN score ELSE 0 END "����",
                       CASE WHEN subjects = '���Ͼ�' THEN score ELSE 0 END "���Ͼ�"
                  FROM ch14_score_table a
              )
SELECT years, gubun, 
       SUM(����) AS ����, SUM(����) AS ����, SUM(����) AS ����,
       SUM(����) AS ����, SUM(����) AS ����, SUM(���Ͼ�) AS ���Ͼ�
FROM mains       
GROUP BY years, gubun;
       
       
-- PIVOT
SELECT * 
  FROM ( SELECT years, gubun, subjects, score 
           FROM ch14_score_table )
  PIVOT ( SUM(score)
          FOR subjects IN ( '����', '����', '����', '����', '����', '���Ͼ�')
        );
        
-- �÷��� �ο��

CREATE TABLE ch14_score_col_table  (
       YEARS     VARCHAR2(4),   -- ����
       GUBUN     VARCHAR2(30),  -- ����(�߰�/�⸻)
       KOREAN    NUMBER,        -- ��������
       ENGLISH   NUMBER,        -- ��������
       MATH      NUMBER,        -- ��������
       SCIENCE   NUMBER,        -- ��������
       GEOLOGY   NUMBER,        -- ��������
       GERMAN    NUMBER         -- ���Ͼ�����
      );
  
INSERT INTO ch14_score_col_table
VALUES ('2014', '�߰����', 92, 87, 67, 80, 93, 82 );

INSERT INTO ch14_score_col_table
VALUES ('2014', '�⸻���', 88, 80, 93, 91, 89, 83 );

COMMIT;

SELECT *
FROM ch14_score_col_table;


-- UNION ALL

SELECT YEARS, GUBUN, '����' AS SUBJECT, KOREAN AS SCORE       
  FROM ch14_score_col_table
UNION ALL
SELECT YEARS, GUBUN, '����' AS SUBJECT, ENGLISH AS SCORE       
  FROM ch14_score_col_table
UNION ALL
SELECT YEARS, GUBUN, '����' AS SUBJECT, MATH AS SCORE       
  FROM ch14_score_col_table
UNION ALL
SELECT YEARS, GUBUN, '����' AS SUBJECT, SCIENCE AS SCORE       
  FROM ch14_score_col_table
UNION ALL
SELECT YEARS, GUBUN, '����' AS SUBJECT, GEOLOGY AS SCORE       
  FROM ch14_score_col_table
UNION ALL
SELECT YEARS, GUBUN, '���Ͼ�' AS SUBJECT, GERMAN AS SCORE       
  FROM ch14_score_col_table
ORDER BY 1, 2 DESC;

-- UNPIVOT 
SELECT *
  FROM ch14_score_col_table 
  UNPIVOT ( score 
            FOR subjects IN ( KOREAN   AS '����', 
                              ENGLISH  AS '����', 
                              MATH     AS '����',  
                              SCIENCE  AS '����', 
                              GEOLOGY  AS '����', 
                              GERMAN   AS '���Ͼ�'
                            )
        );
        
        
-- ���������� ���̺� �Լ�
CREATE OR REPLACE TYPE ch14_obj_subject AS OBJECT (
       YEARS     VARCHAR2(4),   -- ����
       GUBUN     VARCHAR2(30),  -- ����(�߰�/�⸻)
       SUBJECTS  VARCHAR2(30),  -- ����
       SCORE     NUMBER         -- ����
      ); 
         
CREATE OR REPLACE TYPE ch14_subject_nt IS TABLE OF ch14_obj_subject;     

   


CREATE OR REPLACE FUNCTION fn_ch14_pipe_table3 
   RETURN ch14_subject_nt
   PIPELINED
IS

   vp_cur  SYS_REFCURSOR;
   v_cur   ch14_score_col_table%ROWTYPE;
   
   -- ��ȯ�� �÷��� ���� ���� (�÷��� Ÿ���̹Ƿ� �ʱ�ȭ�� �Ѵ�)
   vnt_return  ch14_subject_nt :=  ch14_subject_nt();  
BEGIN
	 -- SYS_REFCURSOR ������ ch14_score_col_table ���̺��� ������ Ŀ���� ���� 
	 OPEN vp_cur FOR SELECT * FROM ch14_score_col_table ;
	 
   -- ������ ���� �Է� �Ű����� vp_cur�� v_cur�� ��ġ
   LOOP
     FETCH vp_cur INTO v_cur;
     EXIT WHEN vp_cur%NOTFOUND; 
     
     -- �÷��� Ÿ���̹Ƿ� EXTEND �޼Ҹ� ����� �� �ο쾿 �ű� ����
     vnt_return.EXTEND();
     -- �÷��� ����� OBJECT Ÿ�Կ� ���� �ʱ�ȭ 
     vnt_return(vnt_return.LAST) := ch14_obj_subject(null, null, null, null);
     
     -- �÷��� ������ Ŀ�������� �� �Ҵ� 
     vnt_return(vnt_return.LAST).YEARS     := v_cur.YEARS; 
     vnt_return(vnt_return.LAST).GUBUN     := v_cur.GUBUN;      
     vnt_return(vnt_return.LAST).SUBJECTS  := '����';
     vnt_return(vnt_return.LAST).SCORE     := v_cur.KOREAN;
     PIPE ROW ( vnt_return(vnt_return.LAST)); -- ���� ��ȯ
     
     vnt_return(vnt_return.LAST).SUBJECTS  := '����';
     vnt_return(vnt_return.LAST).SCORE     := v_cur.ENGLISH;
     PIPE ROW ( vnt_return(vnt_return.LAST)); -- ���� ��ȯ
     
     vnt_return(vnt_return.LAST).SUBJECTS  := '����';
     vnt_return(vnt_return.LAST).SCORE     := v_cur.MATH;
     PIPE ROW ( vnt_return(vnt_return.LAST)); -- ���� ��ȯ
     
     vnt_return(vnt_return.LAST).SUBJECTS  := '����';
     vnt_return(vnt_return.LAST).SCORE     := v_cur.SCIENCE;
     PIPE ROW ( vnt_return(vnt_return.LAST)); -- ���� ��ȯ
     
     vnt_return(vnt_return.LAST).SUBJECTS  := '����';
     vnt_return(vnt_return.LAST).SCORE     := v_cur.GEOLOGY;
     PIPE ROW ( vnt_return(vnt_return.LAST)); -- ���� ��ȯ
     
     vnt_return(vnt_return.LAST).SUBJECTS  := '���Ͼ�';
     vnt_return(vnt_return.LAST).SCORE     := v_cur.GERMAN;
     PIPE ROW ( vnt_return(vnt_return.LAST)); -- ���Ͼ� ��ȯ                    
     
     
   END LOOP;
   RETURN; 
END;



SELECT *
  FROM TABLE ( fn_ch14_pipe_table3 );