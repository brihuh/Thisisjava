-- ���̺� �����̽� ����

CREATE TABLESPACE myts DATAFILE 
 'C:\app\chongs\oradata\myoracle\myts.dbf' SIZE 100M AUTOEXTEND ON NEXT 5M;
 
 
-- ����� ����
CREATE USER ora_user IDENTIFIED BY hong 
DEFAULT TABLESPACE MYTS
TEMPORARY TABLESPACE TEMP;

-- DBA �� �ο�
GRANT DBA TO ora_user;

