-- �����Լ�
SELECT COUNT(*)
  FROM employees;


SELECT COUNT(employee_id)
  FROM employees;
  
SELECT COUNT(department_id)
  FROM employees;
  
SELECT COUNT(DISTINCT department_id)
  FROM employees;    

SELECT DISTINCT department_id
  FROM employees
  ORDER BY 1;  
  
SELECT SUM(salary)
  FROM employees;  
  
SELECT SUM(salary), SUM(DISTINCT salary)
  FROM employees;    
  
SELECT AVG(salary), AVG(DISTINCT salary)
  FROM employees;     
  
SELECT MIN(salary), MAX( salary)
  FROM employees;       
  
SELECT MIN(DISTINCT salary), MAX(DISTINCT salary)
  FROM employees;       
  
SELECT VARIANCE(salary), STDDEV(salary)
  FROM employees; 
  
-- GROUP BY �� HAVING ��

SELECT department_id, SUM(salary)
  FROM employees
 GROUP BY department_id
 ORDER BY department_id;  
 
CREAE TABLE KOR_LOAN_STATUS (
           PERIOD        VARCHAR2(6),
           REGION        VARCHAR2(10),
           GUBUN         VARCHAR2(30),
           LOAN_JAN_AMT  NUMBER) ; 

SELECT *
FROM kor_loan_status;

SELECT period, region, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%' 
 GROUP BY period, region
 ORDER BY period, region;  


SELECT period, region, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period = '201311' 
 GROUP BY region
 ORDER BY region;  
 

SELECT period, region, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period = '201311' 
 GROUP BY period, region
 HAVING SUM(loan_jan_amt) > 100000
 ORDER BY region;
 
-- ROLLUP�� CUBE

SELECT period, gubun, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%' 
 GROUP BY period, gubun
 ORDER BY period; 
 
 SELECT period, gubun, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%' 
 GROUP BY ROLLUP(period, gubun); 
 
SELECT period, gubun, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%' 
 GROUP BY period, ROLLUP( gubun );
 
SELECT period, gubun, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%' 
 GROUP BY ROLLUP(period), gubun ;
 
 
 SELECT period, gubun, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%' 
 GROUP BY CUBE(period, gubun) ;
 
  
 SELECT period, gubun, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%' 
 GROUP BY period, CUBE( gubun );
 
 
-- ���� ������

CREATE TABLE exp_goods_asia (
       country VARCHAR2(10),
       seq     NUMBER,
       goods   VARCHAR2(80));
       
INSERT INTO exp_goods_asia VALUES ('�ѱ�', 1, '�������� ������');
INSERT INTO exp_goods_asia VALUES ('�ѱ�', 2, '�ڵ���');
INSERT INTO exp_goods_asia VALUES ('�ѱ�', 3, '��������ȸ��');
INSERT INTO exp_goods_asia VALUES ('�ѱ�', 4, '����');
INSERT INTO exp_goods_asia VALUES ('�ѱ�', 5,  'LCD');
INSERT INTO exp_goods_asia VALUES ('�ѱ�', 6,  '�ڵ�����ǰ');
INSERT INTO exp_goods_asia VALUES ('�ѱ�', 7,  '�޴���ȭ');
INSERT INTO exp_goods_asia VALUES ('�ѱ�', 8,  'ȯ��źȭ����');
INSERT INTO exp_goods_asia VALUES ('�ѱ�', 9,  '�����۽ű� ���÷��� �μ�ǰ');
INSERT INTO exp_goods_asia VALUES ('�ѱ�', 10,  'ö �Ǵ� ���ձݰ�');

INSERT INTO exp_goods_asia VALUES ('�Ϻ�', 1, '�ڵ���');
INSERT INTO exp_goods_asia VALUES ('�Ϻ�', 2, '�ڵ�����ǰ');
INSERT INTO exp_goods_asia VALUES ('�Ϻ�', 3, '��������ȸ��');
INSERT INTO exp_goods_asia VALUES ('�Ϻ�', 4, '����');
INSERT INTO exp_goods_asia VALUES ('�Ϻ�', 5, '�ݵ�ü������');
INSERT INTO exp_goods_asia VALUES ('�Ϻ�', 6, 'ȭ����');
INSERT INTO exp_goods_asia VALUES ('�Ϻ�', 7, '�������� ������');
INSERT INTO exp_goods_asia VALUES ('�Ϻ�', 8, '�Ǽ����');
INSERT INTO exp_goods_asia VALUES ('�Ϻ�', 9, '���̿���, Ʈ��������');
INSERT INTO exp_goods_asia VALUES ('�Ϻ�', 10, '����');

COMMIT;

SELECT goods
  FROM exp_goods_asia
 WHERE country = '�ѱ�'
 ORDER BY seq;

SELECT goods
  FROM exp_goods_asia
 WHERE country = '�Ϻ�'
 ORDER BY seq;
 
 
SELECT goods
  FROM exp_goods_asia
 WHERE country = '�ѱ�'
UNION 
SELECT goods
  FROM exp_goods_asia
 WHERE country = '�Ϻ�';

SELECT goods
  FROM exp_goods_asia
 WHERE country = '�ѱ�'
UNION ALL
SELECT goods
  FROM exp_goods_asia
 WHERE country = '�Ϻ�';
 
 
SELECT goods
  FROM exp_goods_asia
 WHERE country = '�ѱ�'
INTERSECT
SELECT goods
  FROM exp_goods_asia
 WHERE country = '�Ϻ�'; 
 
SELECT goods
  FROM exp_goods_asia
 WHERE country = '�ѱ�'
MINUS
SELECT goods
  FROM exp_goods_asia
 WHERE country = '�Ϻ�';  
 
SELECT goods
  FROM exp_goods_asia
 WHERE country = '�Ϻ�'
MINUS
SELECT goods
  FROM exp_goods_asia
 WHERE country = '�ѱ�';   
 
 
SELECT goods
  FROM exp_goods_asia
 WHERE country = '�ѱ�'
UNION 
SELECT seq, goods
  FROM exp_goods_asia
 WHERE country = '�Ϻ�'; 
 
 
SELECT seq, goods
  FROM exp_goods_asia
 WHERE country = '�ѱ�'
INTERSECT
SELECT seq, goods
  FROM exp_goods_asia
 WHERE country = '�Ϻ�';  
 
SELECT seq
  FROM exp_goods_asia
 WHERE country = '�ѱ�'
UNION
SELECT goods
  FROM exp_goods_asia
 WHERE country = '�Ϻ�';   
 
 
 SELECT goods
  FROM exp_goods_asia
 WHERE country = '�ѱ�'
 ORDER BY goods
UNION
SELECT goods
  FROM exp_goods_asia
 WHERE country = '�Ϻ�'; 
 
 
 SELECT goods
  FROM exp_goods_asia
 WHERE country = '�ѱ�'
UNION
SELECT goods
  FROM exp_goods_asia
 WHERE country = '�Ϻ�'
  ORDER BY goods;  
 
-- GROUPING SETS
SELECT period, gubun, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%' 
 GROUP BY GROUPING SETS(period, gubun);


SELECT period, gubun, region, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%' 
   AND region IN ('����', '���')
 GROUP BY GROUPING SETS(period, (gubun, region)); 
 
 