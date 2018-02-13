-- 02. DBMS_JOB
-- (1) DBMS_JOB�� ���ν���

CREATE TABLE ch15_job_test (
             seq          NUMBER,
             insert_date  DATE);
             
CREATE OR REPLACE PROCEDURE ch15_job_test_proc 
IS
  vn_next_seq  NUMBER;
BEGIN
	-- ���� ������ �����´�. 
	SELECT NVL(MAX(seq), 0) + 1
	  INTO vn_next_seq
	  FROM ch15_job_test;
	  
	INSERT INTO ch15_job_test VALUES ( vn_next_seq, SYSDATE);
	
	COMMIT;
	
EXCEPTION WHEN OTHERS THEN
     ROLLBACK;
     DBMS_OUTPUT.PUT_LINE(SQLERRM);
	
END;             


-- �� ��� 
DECLARE 
  v_job_no NUMBER;
BEGIN
	-- ����ð� ���� 1�п� 1���� ch15_job_test_proc ���ν����� �����ϴ� �� ��� 
	DBMS_JOB.SUBMIT  ( job => v_job_no, what => 'ch15_job_test_proc;', next_date => SYSDATE, interval => 'SYSDATE + 1/60/24' );
	COMMIT;
	-- �ý��ۿ��� �ڵ������� �� ��ȣ ���
	DBMS_OUTPUT.PUT_LINE('v_job_no : ' || v_job_no);
END;

SELECT SEQ, TO_CHAR(INSERT_DATE, 'YYYY-MM-DD HH24:MI:SS')
FROM ch15_job_test;

SELECT job, last_date, last_sec, next_date, next_sec, broken, interval, failures, what
FROM   user_jobs;

-- ���� ����, �׸��� ����� 
BEGIN 
 -- ���� ���� 
 DBMS_JOB.BROKEN(30, TRUE); 
 COMMIT;
END; 

SELECT job, last_date, last_sec, next_date, next_sec, broken, interval, failures, what
FROM   user_jobs;


BEGIN 
 -- �� ����� 
 DBMS_JOB.BROKEN(30, FALSE); 
 COMMIT;
END; 

SELECT job, last_date, last_sec, next_date, next_sec, broken, interval, failures, what
FROM   user_jobs;

SELECT SEQ, TO_CHAR(INSERT_DATE, 'YYYY-MM-DD HH24:MI:SS')
FROM ch15_job_test;

-- �� �Ӽ� ����
BEGIN 
 -- �� ����� 
 DBMS_JOB.CHANGE(job => 30, what => 'ch15_job_test_proc;', next_date => SYSDATE, interval => 'SYSDATE + 3/60/24'); 
 COMMIT;
END; 

SELECT job, last_date, last_sec, next_date, next_sec, broken, interval, failures, what
FROM   user_jobs;

SELECT SEQ, TO_CHAR(INSERT_DATE, 'YYYY-MM-DD HH24:MI:SS') AS DATES
FROM ch15_job_test;

-- ���� ���� 
BEGIN 
 -- �� ��������
 DBMS_JOB.RUN(30);
 COMMIT;
END; 


-- ���� ����
BEGIN 
 -- �� ����
 DBMS_JOB.REMOVE(30);
 COMMIT;
END; 

SELECT job, last_date, last_sec, next_date, next_sec, broken, interval, failures, what
FROM   user_jobs;

-- DBMS_SCHEDULER
-- ���α׷� ��ü ����

BEGIN
   DBMS_SCHEDULER.CREATE_PROGRAM (
        program_name => 'my_program1',
        program_type => 'STORED_PROCEDURE',
        program_action => 'ch15_job_test_proc ',
        comments => 'ù��° ���α׷�');
END;

SELECT program_name, program_type, program_action, number_of_arguments, enabled, comments
FROM USER_SCHEDULER_PROGRAMS;

-- ������ ��ü ����

BEGIN
   DBMS_SCHEDULER.CREATE_SCHEDULE (
        schedule_name => 'my_schedule1',
        start_date => NULL,
        repeat_interval => 'FREQ=MINUTELY; INTERVAL=1',
        end_date => NULL,
        comments => '1�и��� ����');
END;


SELECT schedule_name, schedule_type, start_date, repeat_interval, end_date, comments
FROM USER_SCHEDULER_SCHEDULES;

-- �� ��ü ����(����1)

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
       job_name            => 'my_job1',
       job_type            => 'STORED_PROCEDURE',
       job_action          => 'ch15_job_test_proc ',
       repeat_interval     => 'FREQ=MINUTELY; INTERVAL=1',
       comments            => '����1 �ⰴü' );
END;

SELECT job_name, job_style, job_type, job_action, repeat_interval, enabled, auto_drop, state, comments
FROM USER_SCHEDULER_JOBS;

TRUNCATE TABLE ch15_job_test;

-- MY_JOB1 Ȱ��ȭ

BEGIN
  DBMS_SCHEDULER.ENABLE ('my_job1');
END;  

SELECT job_name, job_style, job_type, job_action, repeat_interval, enabled, auto_drop, state, comments
FROM USER_SCHEDULER_JOBS;


SELECT SEQ, TO_CHAR(INSERT_DATE, 'YYYY-MM-DD HH24:MI:SS')
FROM ch15_job_test;


SELECT log_id, log_date, job_name, operation, status
FROM USER_SCHEDULER_JOB_LOG;

SELECT log_date, job_name, status, error#, req_start_date, actual_start_date, run_duration
FROM USER_SCHEDULER_JOB_RUN_DETAILS;

-- ���� 2 �� ��ü ����

BEGIN
  DBMS_SCHEDULER.DISABLE ('my_job1');
END;  

TRUNCATE TABLE ch15_job_test;

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
       job_name            => 'my_job2',
       program_name        => 'MY_PROGRAM1',
       schedule_name       => 'MY_SCHEDULE1',
       comments            => '����2 �� ��ü' );
END;


SELECT job_name, program_name, job_type, job_action, schedule_name, schedule_type, repeat_interval,  enabled, auto_drop, state, comments
FROM USER_SCHEDULER_JOBS;


-- my_job2 Ȱ��ȭ 
BEGIN
  DBMS_SCHEDULER.ENABLE ('my_job2');
END;  

SELECT SEQ, TO_CHAR(INSERT_DATE, 'YYYY-MM-DD HH24:MI:SS')
FROM ch15_job_test;

-- my_program1 Ȱ��ȭ 
BEGIN
  DBMS_SCHEDULER.ENABLE ('my_program1');
END;  

SELECT SEQ, TO_CHAR(INSERT_DATE, 'YYYY-MM-DD HH24:MI:SS')
FROM ch15_job_test;


SELECT log_date, job_name, status, error#, req_start_date, actual_start_date, run_duration
FROM USER_SCHEDULER_JOB_RUN_DETAILS
WHERE JOB_NAME = 'MY_JOB2';

-- �ܺ� ���α׷� ����
TRUNCATE TABLE ch15_job_test;

SELECT SEQ, TO_CHAR(INSERT_DATE, 'YYYY-MM-DD HH24:MI:SS')
FROM ch15_job_test;

-- �� ��ü ����
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
       job_name            => 'MY_EX_JOB1',   -- �� ��
       job_type            => 'EXECUTABLE',   -- �ܺ� ��������
       number_of_arguments => 2,              -- �Ű������� 2����� �ǹ�
       job_action          => 'c:\windows\system32\cmd.exe',   -- �������� CMD.EXE�� ����
       repeat_interval     => 'FREQ=MINUTELY; INTERVAL=1',     -- 1�п� 1ȸ�� ����
       comments            => '�ܺ����� ���� �ⰴü' );        -- �� ���� 
       
      DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('MY_EX_JOB1',1,'/c');                     -- �Ű�����1
      DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE('MY_EX_JOB1',2,'c:\scheduler_test.bat');  -- �Ű�����2 (���� ��ġ����)
      
      DBMS_SCHEDULER.ENABLE ('MY_EX_JOB1'); -- �� Ȱ��ȭ 
END;


SELECT SEQ, TO_CHAR(INSERT_DATE, 'YYYY-MM-DD HH24:MI:SS')
FROM ch15_job_test;


SELECT log_date, job_name, status, error#, req_start_date, actual_start_date, run_duration
FROM USER_SCHEDULER_JOB_RUN_DETAILS
WHERE JOB_NAME = 'MY_EX_JOB1';


-- ü��

CREATE TABLE ch15_changed_object ( 
    
    OBJECT_NAME      VARCHAR2(128),   -- ��ü ��
    OBJECT_TYPE      VARCHAR2(50),    -- ��ü ����
    CREATED          DATE,            -- ��ü ��������
    LAST_DDL_TIME    DATE,            -- ��ü ��������
    STATUS           VARCHAR2(7),     -- ��ü ����
    CREATION_DATE    DATE             -- ��������
     );
     
     
CREATE OR REPLACE PROCEDURE ch15_check_objects_prc 
IS
  vn_cnt  NUMBER := 0;
BEGIN
	
	-- �����ϰ� ����� ��ü �� ch15_changed_object�� ���� ��ü�� ã�´�. 
	-- �ֳ��ϸ� ���� ���ν��� ���� �� ����� ��ü�� ������ �̹� ch15_changed_object�� �ԷµƱ� ���� 
	SELECT COUNT(*)
	INTO   vn_cnt
  FROM USER_OBJECTS a
  WHERE LAST_DDL_TIME BETWEEN SYSDATE - 7
                          AND SYSDATE
    AND NOT EXISTS ( SELECT 1
                       FROM ch15_changed_object b
                      WHERE a.object_name = b.object_name);                

  -- ����� ��ü�� ������ RAISE_APPLICATION_ERROR�� �߻����� �����ڵ带 �ѱ��. 
  -- �����ڵ带 �ѱ�� ������ �꿡�� ó���ϱ� �����̴�.                           
  IF vn_cnt = 0 THEN
     RAISE_APPLICATION_ERROR(-20001, '����� ��ü ����');  
  END IF;                         
	
	
END;     


CREATE OR REPLACE PROCEDURE ch15_make_objects_prc
IS 

BEGIN 
	
	INSERT INTO ch15_changed_object (
	            object_name, object_type, 
	            created,     last_ddl_time,
	            status,      creation_date )
  SELECT object_name, object_type, 
         created,     last_ddl_time,
         status,      SYSDATE
   FROM  USER_OBJECTS a
  WHERE LAST_DDL_TIME BETWEEN SYSDATE - 7
                          AND SYSDATE
    AND NOT EXISTS ( SELECT 1
                       FROM ch15_changed_object b
                      WHERE a.object_name = b.object_name);     	   
                      
  COMMIT;
  
EXCEPTION WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
      RAISE_APPLICATION_ERROR(-20002, SQLERRM);
      ROLLBACK;
END;

-- ���α׷� ��ü ����
BEGIN
	 -- ch15_check_objects_prc�� ���� ���α׷� ��ü ����
   DBMS_SCHEDULER.CREATE_PROGRAM (
        program_name   => 'MY_CHAIN_PROG1',
        program_type   => 'STORED_PROCEDURE',
        program_action => 'ch15_check_objects_prc',
        comments       => 'ù��° ü�� ���α׷�');
        
	 -- ch15_make_objects_prc�� ���� ���α׷� ��ü ����        
   DBMS_SCHEDULER.CREATE_PROGRAM (
        program_name   => 'MY_CHAIN_PROG2',
        program_type   => 'STORED_PROCEDURE',
        program_action => 'ch15_make_objects_prc',
        comments       => '�ι�° ü�� ���α׷�'); 
        
   -- ���α׷� ��ü Ȱ��ȭ      
   DBMS_SCHEDULER.ENABLE ('MY_CHAIN_PROG1');   
   DBMS_SCHEDULER.ENABLE ('MY_CHAIN_PROG2');   
           
END;

-- ü�� ����
BEGIN
  DBMS_SCHEDULER.CREATE_CHAIN (
       chain_name          => 'MY_CHAIN1',
       rule_set_name       => NULL,
       evaluation_interval => NULL,
       comments            => 'ù ��° ü��');
END;

-- ���� ����
BEGIN
	-- STEP1
	DBMS_SCHEDULER.DEFINE_CHAIN_STEP(
	     chain_name   => 'MY_CHAIN1',
	     step_name    => 'STEP1', 
	     program_name => 'MY_CHAIN_PROG1');
	     
  -- STEP2
	DBMS_SCHEDULER.DEFINE_CHAIN_STEP(
	     chain_name   => 'MY_CHAIN1',
	     step_name    => 'STEP2', 
	     program_name => 'MY_CHAIN_PROG2');
END;

-- �� ����

BEGIN
  -- ���� STEP1�� ���۽�Ű�� �� 
  DBMS_SCHEDULER.DEFINE_CHAIN_RULE (
       chain_name => 'MY_CHAIN1',
       condition  => 'TRUE',
       action     => 'START STEP1',
       rule_name  => 'MY_RULE1',
       comments   => 'START ��' );
		
END;


BEGIN
  -- �� ��° ��, �����ϰ� ����� ��ü�� ���ٸ� ����� ������.
  -- �̴� STEP1�� ������ �� ����� �����ڵ带 �޾��� �� �����ϵ��� ó���Ѵ�. 
  DBMS_SCHEDULER.DEFINE_CHAIN_RULE (
       chain_name => 'MY_CHAIN1',
       condition  => 'STEP1 ERROR_CODE = 20001',
       action     => 'END',
       rule_name  => 'MY_RULE2',
       comments   => '��2' );
		
END;

BEGIN
  -- STEP1���� STEP2�� ���� ��
  DBMS_SCHEDULER.DEFINE_CHAIN_RULE (
       chain_name => 'MY_CHAIN1',
       condition  => 'STEP1 SUCCEEDED',
       action     => 'START STEP2',
       rule_name  => 'MY_RULE3',
       comments   => '��3' );
       
  -- STEP2�� ��ġ�� �����ϴ� �� 
  DBMS_SCHEDULER.DEFINE_CHAIN_RULE (
       chain_name => 'MY_CHAIN1',
       condition  => 'STEP2 SUCCEEDED',
       action     => 'END',
       rule_name  => 'MY_RULE4',
       comments   => '��4' );   
END;

-- �� ��ü ����	
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
       job_name            => 'MY_CHAIN_JOBS',
       job_type            => 'CHAIN',
       job_action          => 'MY_CHAIN1',
       repeat_interval     => 'FREQ=MINUTELY; INTERVAL=1',
       comments            => 'ü���� �����ϴ� ��' );
END;	
	
SELECT *
FROM user_scheduler_chains;

SELECT chain_name, step_name, program_name, step_type, skip, pause
FROM user_scheduler_chain_steps;

SELECT *
FROM user_scheduler_chain_rules;

BEGIN
	-- ü�� Ȱ��ȭ
	DBMS_SCHEDULER.ENABLE('MY_CHAIN1');
	
	-- �� Ȱ��ȭ
	DBMS_SCHEDULER.ENABLE('MY_CHAIN_JOBS');	
	
END;


select log_date, job_subname, operation, status, additional_info
from user_scheduler_job_log
where job_name = 'MY_CHAIN_JOB';

SELECT log_date, job_subname, status, actual_start_date, run_duration, additional_info
FROM user_scheduler_job_run_details
WHERE job_name = 'MY_CHAIN_JOB';


SELECT *
FROM ch15_changed_object
ORDER BY OBJECT_NAME;