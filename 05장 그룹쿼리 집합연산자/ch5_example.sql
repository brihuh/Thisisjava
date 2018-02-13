

1. ������̺��� �Ի�⵵�� ������� ���ϴ� ������ �ۼ��غ���. 

<����>

SELECT TO_CHAR(hire_date, 'YYYY') AS hire_year,
       COUNT(*)
  FROM employees
GROUP BY TO_CHAR(hire_date, 'YYYY')
ORDER BY TO_CHAR(hire_date, 'YYYY');

2. kor_loan_status ���̺��� 2012�⵵ ����, ������ ���� �� �ܾ��� ���ϴ� ������ �ۼ��϶�. 

<����>

SELECT period, region, SUM(loan_jan_amt)
FROM kor_loan_status
WHERE period LIKE '2012%'
GROUP BY period, region
ORDER BY period, region;


3. �Ʒ��� ������ ���� ROLLUP�� ������ �����̴�.

SELECT period, gubun, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%' 
 GROUP BY period, ROLLUP( gubun );
 
 �� ������ ROLLUP�� ������� �ʰ�, ���տ����ڸ� ����ؼ� ������ ����� �������� ������ �ۼ��غ���. 
 
<����>
SELECT period, gubun, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%' 
 GROUP BY period,  gubun
UNION 
SELECT period, '', SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%' 
 GROUP BY period;  
 
 
4. ���� ������ �����ؼ� ����� Ȯ���� ��, ���� �����ڸ� ����� ������ ����� �����ϵ��� ������ �ۼ��� ����. 

SELECT period, 
       CASE WHEN gubun = '���ô㺸����' THEN SUM(loan_jan_amt) ELSE 0 END ���ô㺸�����,
       CASE WHEN gubun = '��Ÿ����'     THEN SUM(loan_jan_amt) ELSE 0 END ��Ÿ����� 
  FROM kor_loan_status
 WHERE period = '201311' 
 GROUP BY period, gubun;
 
 <����>
SELECT period, SUM(loan_jan_amt) ���ô㺸�����, 0 ��Ÿ�����
  FROM kor_loan_status
 WHERE period = '201311' 
   AND gubun = '���ô㺸����'
 GROUP BY period, gubun
 UNION ALL
SELECT period, 0 ���ô㺸�����, SUM(loan_jan_amt) ��Ÿ�����
  FROM kor_loan_status
 WHERE period = '201311' 
   AND gubun = '��Ÿ����'
 GROUP BY period, gubun ;


5. ������ ���� ����, �� ������ �� ���� �������ܾ��� ���ϴ� ������ �ۼ��� ����.

---------------------------------------------------------------------------------------
����   201111   201112    201210    201211   201212   203110    201311
---------------------------------------------------------------------------------------
����   
�λ�
...
...
---------------------------------------------------------------------------------------

<����>

SELECT REGION, 
       SUM(AMT1) AS "201111", 
       SUM(AMT2) AS "201112", 
       SUM(AMT3) AS "201210", 
       SUM(AMT4) AS "201211", 
       SUM(AMT5) AS "201312", 
       SUM(AMT6) AS "201310",
       SUM(AMT6) AS "201311"
  FROM ( 
         SELECT REGION,
                CASE WHEN PERIOD = '201111' THEN LOAN_JAN_AMT ELSE 0 END AMT1,
                CASE WHEN PERIOD = '201112' THEN LOAN_JAN_AMT ELSE 0 END AMT2,
                CASE WHEN PERIOD = '201210' THEN LOAN_JAN_AMT ELSE 0 END AMT3, 
                CASE WHEN PERIOD = '201211' THEN LOAN_JAN_AMT ELSE 0 END AMT4, 
                CASE WHEN PERIOD = '201212' THEN LOAN_JAN_AMT ELSE 0 END AMT5, 
                CASE WHEN PERIOD = '201310' THEN LOAN_JAN_AMT ELSE 0 END AMT6,
                CASE WHEN PERIOD = '201311' THEN LOAN_JAN_AMT ELSE 0 END AMT7
         FROM KOR_LOAN_STATUS
       )
GROUP BY REGION
ORDER BY REGION       
;