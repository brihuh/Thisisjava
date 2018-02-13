
1. ������̺�(employees)���� phone_number��� �÷��� ����� ��ȭ��ȣ�� ###.###.#### ���·� ����Ǿ� �ִ�.
���⼭ ó�� 3�ڸ� ���� ��� ���� ������ȣ�� (02)�� �ٿ� ��ȭ��ȣ�� ����ϵ��� ������ �ۼ��� ����.

<����>

SELECT employee_id,
       LPAD(SUBSTR(phone_number, 5), 12, '(02)')
  FROM employees;


2. �������� �������� ������̺��� �Ի�����(hire_date)�� �����ؼ� �ټӳ���� 10�� �̻��� ����� ������ ���� ������ ����� ����ϵ��� ������ �ۼ��غ���. 
   (�ټӳ���� ���� ���������� ����� �������� ����)

--------------------------------------
�����ȣ  �����  �Ի����� �ټӳ��
--------------------------------------


<����>

SELECT employee_id, emp_name, HIRE_DATE, 
       ROUND((sysdate - hire_date) / 365)
  FROM employees
 WHERE ROUND((sysdate - hire_date) / 365) >= 10
 ORDER BY 3;
 
 
3. �� ���̺�(CUSTOMERS)���� �� ��ȭ��ȣ(cust_main_phone_number) �÷��� �ִ�. �� �÷� ���� ###-###-#### �����ε�,
   '-' ��� '/'�� �ٲ� ����ϴ� ������ �ۼ��� ����.
   
   
<����>

SELECT cust_name, cust_main_phone_number, 
       REPLACE(cust_main_phone_number, '-', '/') new_phone_number
  FROM customers;


4. �� ���̺�(CUSTOMERS)�� �� ��ȭ��ȣ(cust_main_phone_number) �÷��� �ٸ� ���ڷ� ��ü(������ ��ȣȭ)�ϵ��� ������ �ۼ��� ����.


<����>

SELECT cust_name, cust_main_phone_number, 
       TRANSLATE(cust_main_phone_number, '0123456789', 'acielsifke') new_phone_number
  FROM customers;
   
   

5. �� ���̺�(CUSTOMERS)���� ���� ����⵵(cust_year_of_birth) �÷��� �ִ�. ������ �������� �� �÷��� Ȱ����
   30��, 40��, 50�븦 ������ ����ϰ�, ������ ���ɴ�� '��Ÿ'�� ����ϴ� ������ �ۼ��غ���. 
   
<����>

SELECT CUST_NAME, 
       CUST_YEAR_OF_BIRTH, 
       DECODE( TRUNC((TO_CHAR(SYSDATE, 'YYYY') - CUST_YEAR_OF_BIRTH)/10), 3, '30��', 
                                                                          4, '40��',
                                                                          5, '50��',
                                                                          '��Ÿ') generation
FROM CUSTOMERS;   

6. 4�� ������ 30~50�� ������ ǥ���ߴµ�, �� ���ɴ븦 ǥ���ϵ��� ������ �ۼ��ϴµ�, 
   �̹����� DECODE ��� CASE ǥ������ ����غ���. 
   
<����>
   
SELECT CUST_NAME, 
       CUST_YEAR_OF_BIRTH, 
       CASE WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - CUST_YEAR_OF_BIRTH)/10)  BETWEEN  1 AND 19 THEN '10��'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - CUST_YEAR_OF_BIRTH)/10)  BETWEEN 20 AND 29 THEN '20��'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - CUST_YEAR_OF_BIRTH)/10)  BETWEEN 30 AND 39 THEN '30��'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - CUST_YEAR_OF_BIRTH)/10)  BETWEEN 40 AND 49 THEN '40��'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - CUST_YEAR_OF_BIRTH)/10)  BETWEEN 50 AND 59 THEN '50��'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - CUST_YEAR_OF_BIRTH)/10)  BETWEEN 60 AND 69 THEN '60��'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - CUST_YEAR_OF_BIRTH)/10)  BETWEEN 70 AND 79 THEN '70��'
          ELSE '��Ÿ' END AS new_generation
FROM CUSTOMERS;     


