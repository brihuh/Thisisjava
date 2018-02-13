-- 15�� �������� 


1. DBMS_STATS ��Ű���� GATHER_TABLE_STATS ���ν����� ���̺�� �÷��� ��������� �����ϴ� ���ν����̴�. 
   ���̺� ��������� ���̺� ���� ���� ������ ������ ������ �̴� ����Ŭ ���ο���(��Ƽ������)�� SQL �����ȹ�� ����� �����ϴ� �����̴�. 
   GATHER_TABLE_STATS ���ν����� ������ ������ ����. 
   
   EXEC DBMS_STATS.GATHER_TABLE_STATS ( �����ڸ�, ���̺�� );
   
   USER_TABLES �ý��� �並 �о� �� ���̺� ���� ��������� �����ϴ� ���ν����� ch15__example1_prc�� �̸����� ������. 
   
   
<����>

CREATE OR REPLACE PROCEDURE ch15__example1_prc 
IS 
  vs_owner   VARCHAR2(30) := 'ORA_USER'; -- ����Ŭ��ġ ȯ�濡 ���� �����ڸ��� �ٸ�...
  vs_tab_nm  VARCHAR2(100);
BEGIN

  FOR C_TAB IN ( SELECT TABLE_NAME
                   FROM USER_TABLES 
                )
  LOOP
    vs_tab_nm := C_TAB.TABLE_NAME;
    
    DBMS_STATS.GATHER_TABLE_STATS ( vs_owner, vs_tab_nm );

  END LOOP;

END; 
   
   
2. DBMS_JOB ��Ű���� ����� ���� ���� 5�ÿ� �� ���� ���̺� ��������� �����ϴ� ���� ������. 


<����>

DECLARE 
  v_job_no NUMBER;
BEGIN
  
  DBMS_JOB.SUBMIT  ( 
    job       => v_job_no, 
    what      => 'ch15__example1_prc;', 
    next_date =>  SYSDATE, 
    interval  => 'TRUNC(SYSDATE) + 17/24' );

  COMMIT;
  
END;  
  

3. 2�� ���� �۾��� ����µ� �̹����� DBMS_SCHEDULER ��Ű���� �����(�� ��Ű���� �����) ������. 

<����>
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
       job_name        => 'MY_EX_JOB1',
       job_type        => 'STORED_PROCEDURE',
       job_action      => 'ch15__example1_prc ',
       repeat_interval => 'FREQ=DAILY; INTERVAL=1; BYHOUR=17;',
       comments        => '��������15-3' );
END;



4. 3�� ������ ���� ����µ� �̹����� ���α׷� ��ü, ������ ��ü�� ����� ������. 

<����>

BEGIN
   DBMS_SCHEDULER.CREATE_PROGRAM (
        program_name   => 'MY_EX_PRG1',
        program_type   => 'STORED_PROCEDURE',
        program_action => 'ch15__example1_prc ',
        comments       => '��������15-4');
END;

BEGIN
   DBMS_SCHEDULER.CREATE_SCHEDULE (
        schedule_name   => 'MY_EX_SCH1',
        start_date      => NULL,
        repeat_interval => 'FREQ=DAILY; INTERVAL=1; BYHOUR=17;',
        end_date        => NULL,
        comments        => '��������15-4');
END;


BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
       job_name            => 'MY_EX_JOB2',
       program_name        => 'MY_EX_PRG1',
       schedule_name       => 'MY_EX_SCH1',
       comments            => '��������15-4' );
END;
