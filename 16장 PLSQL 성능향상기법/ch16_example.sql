-- 16�� �������� 


1. RESULT CACHE ������ V$RESULT_CACHE_STATISTICS �ý��ۺ並 ��ȸ���� �� 'Find Count' �׸��� ���� 107988 �̾���. 
   �� ���ڰ� ��� ������ �� ������ �����غ���. 
   
<����>
÷�� ���� ���� ����. 


2. JOBS ���̺��� JOB_ID ���� �Ű������� �޾� JOB_TITLE�� ��ȯ�ϴ� RESULT CACHE ����� �̿��� �Լ��� ����� ����. 

<����>

CREATE OR REPLACE FUNCTION fn_get_jobtitle_rsltcache ( pv_job_id VARCHAR2 )
     RETURN VARCHAR2
     RESULT_CACHE
     RELIES_ON ( JOBS )
IS
   vs_job_title  JOBS.JOB_TITLE%TYPE;
BEGIN
	
	SELECT job_title
	  INTO vs_job_title
	  FROM JOBS
	 WHERE job_id = pv_job_id;
	 
  RETURN vs_job_title;
  
EXCEPTION WHEN OTHERS THEN
  RETURN '';	
	
END;


3. 3������ ���� �Լ��� �̿��� EMP_BULK ���̺��� JOB_TITLE �÷� ���� �����ϴ� �͸����� ������. 


<����>

DECLARE
  vn_cnt        NUMBER := 0;
  vd_sysdate    DATE;
vn_total_time NUMBER := 0;  

BEGIN
  vd_sysdate := SYSDATE;
  -- RESULT CACHE ����� ž��� �Լ� ȣ��
  UPDATE emp_bulk
     SET job_title = fn_get_jobtitle_rsltcache ( job_id )
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



   