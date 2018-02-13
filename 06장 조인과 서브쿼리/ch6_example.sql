--
1. 101�� ����� ���� �Ʒ��� ����� �����ϴ� ������ �ۼ��� ����. 
---------------------------------------------------------------------------------------
���   �����   job��Ī job��������  job��������   job����μ���
---------------------------------------------------------------------------------------


<����>
select a.employee_id, a.emp_name, d.job_title, b.start_date, b.end_date, c.department_name
  from employees a,
       job_history b,
       departments c,
       jobs d
 where a.employee_id   = b.employee_id
   and b.department_id = c.department_id
   and b.job_id        = d.job_id
   and a.employee_id = 101;  
   

2. �Ʒ��� ������ �����ϸ� ������ �߻��Ѵ�. ������ ������ �����ΰ�?

select a.employee_id, a.emp_name, b.job_id, b.department_id 
  from employees a,
       job_history b
 where a.employee_id      = b.employee_id(+)
   and a.department_id(+) = b.department_id;
   
<����>
�ܺ� ������ ���, �������ǿ��� �����Ͱ� ���� ���̺��� �÷����� (+)�� �ٿ��� �Ѵ�.
���� �� ������ ���, and a.department_id(+) = b.department_id �� �ƴ� and a.department_id = b.department_id(+)�� ���ľ� �Ѵ�. 



3. �ܺ����ν� (+)�����ڸ� ���� ����� �� ���µ�, IN���� ����ϴ� ���� 1���� ���� ��� �����ϴ�. �� ������ �����ϱ�?

<����>
����Ŭ�� IN ���� ���Ե� ���� �������� OR�� ��ȯ�Ѵ�.
���� ���, 
   department_id IN (10, 20, 30) ��
   department_id = 10
   OR department_id = 20
   OR department_id = 30) �� �ٲ� �� �� �ִ�.
   
�׷��� IN���� ���� 1���� ���, �� department_id IN (10)�� ��� department_id = 10 �� ��ȯ�� �� �����Ƿ�, �ܺ������� �ϴ��� ���� 1���� ���� ����� �� �ִ�.



4. ������ ������ ANSI �������� ������ ����.

SELECT a.department_id, a.department_name
  FROM departments a, employees b
 WHERE a.department_id = b.department_id
   AND b.salary > 3000
ORDER BY a.department_name;


<����>
SELECT a.department_id, a.department_name
  FROM departments a
  INNER JOIN employees b
     ON ( a.department_id = b.department_id )
 WHERE b.salary > 3000
ORDER BY a.department_name;



5. ������ ������ �ִ� ���������̴�. �̸� ������ ���� ���������� ��ȯ�� ����. 

SELECT a.department_id, a.department_name
 FROM departments a
WHERE EXISTS ( SELECT 1 
                 FROM job_history b
                WHERE a.department_id = b.department_id );
                
                

<����>
SELECT a.department_id, a.department_name
 FROM departments a
WHERE a.department_id IN ( SELECT department_id
                             FROM job_history  );
                             
                             
6. ������ ���¸� �ִ����װ� ����� �ۼ��ϴ� ������ �н��ߴ�. �� ������ �������� �ִ� ����� �Ӹ� �ƴ϶� �ּҸ���װ� �ش� ����� ��ȸ�ϴ� ������ �ۼ��� ����. 

SELECT emp.years, 
       emp.employee_id,
       emp2.emp_name,
       emp.amount_sold
  FROM ( SELECT SUBSTR(a.sales_month, 1, 4) as years,
                a.employee_id, 
                SUM(a.amount_sold) AS amount_sold
           FROM sales a,
                customers b,
                countries c
          WHERE a.cust_id = b.CUST_ID
            AND b.country_id = c.COUNTRY_ID
            AND c.country_name = 'Italy'     
          GROUP BY SUBSTR(a.sales_month, 1, 4), a.employee_id   
        ) emp,
       ( SELECT  years, 
                 MAX(amount_sold) AS max_sold,
                 MIN(amount_sold) AS min_sold
          FROM ( SELECT SUBSTR(a.sales_month, 1, 4) as years,
                        a.employee_id, 
                        SUM(a.amount_sold) AS amount_sold
                   FROM sales a,
                        customers b,
                        countries c
                  WHERE a.cust_id = b.CUST_ID
                    AND b.country_id = c.COUNTRY_ID
                    AND c.country_name = 'Italy'     
                  GROUP BY SUBSTR(a.sales_month, 1, 4), a.employee_id    
               ) K
          GROUP BY years
       ) sale,
       employees emp2
  WHERE emp.years = sale.years
   AND (emp.amount_sold = sale.max_sold  OR emp.amount_sold = sale.min_sold)
   AND emp.employee_id = emp2.employee_id
  ORDER BY years;
  
  
       
                                    
