1. ������ ���� �������� LISTAGG �Լ��� ����� ������ ���� �ο츦 �÷����� �и��߾���. 
   
  SELECT department_id,
         LISTAGG(emp_name, ',') WITHIN GROUP (ORDER BY emp_name) as empnames
    FROM employees
   WHERE department_id IS NOT NULL
   GROUP BY department_id;
   
  LISTAGG �Լ� ��� ������ ����, �м��Լ��� ����ؼ� �� ������ ������ ����� �����ϴ� ������ �ۼ��� ����. 
  
  <����>
SELECT department_id, 
       SUBSTR(SYS_CONNECT_BY_PATH(emp_name, ','),2) empnames
 FROM ( SELECT emp_name, 
               department_id, 
               COUNT(*) OVER ( partition BY department_id ) cnt, 
               ROW_NUMBER () OVER ( partition BY department_id order BY emp_name) rowseq 
          FROM employees
         WHERE department_id IS NOT NULL) 
 WHERE rowseq = cnt 
 START WITH rowseq = 1 
CONNECT BY PRIOR rowseq + 1 = rowseq 
    AND PRIOR department_id = department_id; 
    
    
2. �Ʒ��� ������ ������̺��� JOB_ID�� 'SH_CLERK'�� ����� ��ȸ�ϴ� �����̴�. 

SELECT employee_id, emp_name, hire_date
FROM employees
WHERE job_id = 'SH_CLERK'
ORDER By hire_date; 

EMPLOYEE_ID EMP_NAME             HIRE_DATE         
----------- -------------------- -------------------
        184 Nandita Sarchand     2004/01/27 00:00:00 
        192 Sarah Bell           2004/02/04 00:00:00 
        185 Alexis Bull          2005/02/20 00:00:00 
        193 Britney Everett      2005/03/03 00:00:00 
        188 Kelly Chung          2005/06/14 00:00:00
....        
....
        199 Douglas Grant        2008/01/13 00:00:00
        183 Girard Geoni         2008/02/03 00:00:00

������̺��� �������(retire_date)�� ��� ����ִµ�, �� ������� �����ȣ�� 184�� ����� ������ڴ� �������� �Ի����ڰ� ���� 192�� ����� �Ի����ڶ�� �����ؼ�
������ ���� ���·� ����� �����س� �� �ֵ��� ������ �ۼ��� ����. (�Ի����ڰ� ���� �ֱ��� 183�� ����� ������ڴ� NULL�̴�)

EMPLOYEE_ID EMP_NAME             HIRE_DATE             RETIRE_DATE
----------- -------------------- -------------------  ---------------------------
        184 Nandita Sarchand     2004/01/27 00:00:00  2004/02/04 00:00:00
        192 Sarah Bell           2004/02/04 00:00:00  2005/02/20 00:00:00
        185 Alexis Bull          2005/02/20 00:00:00  2005/03/03 00:00:00
        193 Britney Everett      2005/03/03 00:00:00  2005/06/14 00:00:00
        188 Kelly Chung          2005/06/14 00:00:00  2005/08/13 00:00:00
....        
....
        199 Douglas Grant        2008/01/13 00:00:00  2008/02/03 00:00:00
        183 Girard Geoni         2008/02/03 00:00:00
        
        
<����>
SELECT employee_id, emp_name, hire_date,
       LEAD(hire_date) OVER ( PARTITION BY JOB_ID ORDER BY HIRE_DATE) AS retire_date
FROM employees
WHERE job_id = 'SH_CLERK'
ORDER BY hire_date;


3. sales ���̺��� �Ǹŵ�����, customers ���̺��� �������� �ִ�. 2001�� 12��(SALES_MONTH = '200112') �Ǹŵ����� ��
   �������ڸ� �������� ���� ����(customers.cust_year_of_birth)�� ����ؼ� ������ ���� ���ɴ뺰 ����ݾ��� �����ִ� ������ �ۼ��� ����.
   
-------------------------   
���ɴ�    ����ݾ�
-------------------------
10��      xxxxxx
20��      ....
30��      .... 
40��      ....
-------------------------   
   
<����>
WITH basis AS ( SELECT WIDTH_BUCKET(to_char(sysdate, 'yyyy') - b.cust_year_of_birth, 10, 90, 8) AS old_seg,
                       TO_CHAR(SYSDATE, 'yyyy') - b.cust_year_of_birth as olds,
                       s.amount_sold
                  FROM sales s, 
                       customers b
                 WHERE s.sales_month = '200112'
                   AND s.cust_id = b.CUST_ID
              ),
     real_data AS ( SELECT old_seg * 10 || ' ��' AS old_segment,
                           SUM(amount_sold) as old_seg_amt
                      FROM basis
                     GROUP BY old_seg
              )
 SELECT *
 FROM real_data
 ORDER BY old_segment;   
 
 
4. 3�� ������ �̿��� ������ �Ǹűݾ��� ���� ������ ���ϴ� ��� ����� �̾ƺ���.
   ( �������� countries ���̺��� country_region�� ������, country_id �÷����� customers ���̺�� ������ �ؼ� ���Ѵ�.)
   
---------------------------------   
�����    ����(���)  ����ݾ� 
---------------------------------
199801    Oceania      xxxxxx
199803    Oceania      xxxxxx
...
---------------------------------

<����>
WITH basis AS ( SELECT c.country_region, s.sales_month, SUM(s.amount_solD) AS amt
                  FROM sales s, 
                       customers b,
                       countries c
                 WHERE s.cust_id = b.CUST_ID
                   AND b.COUNTRY_ID = c.COUNTRY_ID
                 GROUP BY c.country_region, s.sales_month
              ),
     real_data AS ( SELECT sales_month, 
                           country_region,
                           amt,
                           RANK() OVER ( PARTITION BY sales_month ORDER BY amt ) ranks
                      FROM basis
                   )
 select *
 from real_data
 where ranks = 1;




5. 5�� �������� 5���� ���� ����� �̿��� ������ ���� ������, ����������, ���� �����ܾװ� ������ ��Ƽ���� ����� ���������� �����ܾ��� %�� ���ϴ� ������ �ۼ��غ���. 

------------------------------------------------------------------------------------------------
����    ��������        201111         201112    201210    201211   201212   203110    201311
------------------------------------------------------------------------------------------------
����    ��Ÿ����       73996.9( 36% )
����    ���ô㺸����   130105.9( 64% ) 
�λ�
...
...
-------------------------------------------------------------------------------------------------

  <����>
WITH basis AS (
SELECT REGION, GUBUN,
       SUM(AMT1) AS AMT1, 
       SUM(AMT2) AS AMT2, 
       SUM(AMT3) AS AMT3, 
       SUM(AMT4) AS AMT4, 
       SUM(AMT5) AS AMT5, 
       SUM(AMT6) AS AMT6, 
       SUM(AMT6) AS AMT7 
  FROM ( 
         SELECT REGION,
                GUBUN,
                CASE WHEN PERIOD = '201111' THEN LOAN_JAN_AMT ELSE 0 END AMT1,
                CASE WHEN PERIOD = '201112' THEN LOAN_JAN_AMT ELSE 0 END AMT2,
                CASE WHEN PERIOD = '201210' THEN LOAN_JAN_AMT ELSE 0 END AMT3, 
                CASE WHEN PERIOD = '201211' THEN LOAN_JAN_AMT ELSE 0 END AMT4, 
                CASE WHEN PERIOD = '201212' THEN LOAN_JAN_AMT ELSE 0 END AMT5, 
                CASE WHEN PERIOD = '201310' THEN LOAN_JAN_AMT ELSE 0 END AMT6,
                CASE WHEN PERIOD = '201311' THEN LOAN_JAN_AMT ELSE 0 END AMT7
         FROM KOR_LOAN_STATUS
       )
GROUP BY REGION, GUBUN
)   
SELECT REGION, 
       GUBUN,
       AMT1 || '( ' || ROUND(RATIO_TO_REPORT(amt1) OVER ( PARTITION BY REGION ),2) * 100 || '% )' AS "201111",
       AMT2 || '( ' || ROUND(RATIO_TO_REPORT(amt2) OVER ( PARTITION BY REGION ),2) * 100 || '% )' AS "201112",
       AMT3 || '( ' || ROUND(RATIO_TO_REPORT(amt3) OVER ( PARTITION BY REGION ),2) * 100 || '% )' AS "201210",
       AMT4 || '( ' || ROUND(RATIO_TO_REPORT(amt4) OVER ( PARTITION BY REGION ),2) * 100 || '% )' AS "201211",
       AMT5 || '( ' || ROUND(RATIO_TO_REPORT(amt5) OVER ( PARTITION BY REGION ),2) * 100 || '% )' AS "201212",
       AMT6 || '( ' || ROUND(RATIO_TO_REPORT(amt6) OVER ( PARTITION BY REGION ),2) * 100 || '% )' AS "201310",
       AMT7 || '( ' || ROUND(RATIO_TO_REPORT(amt7) OVER ( PARTITION BY REGION ),2) * 100 || '% )' AS "201311"
FROM basis
ORDER BY REGION;


