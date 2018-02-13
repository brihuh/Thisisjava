--
1. ������ ���� ������ ���̺��� ������ ����.
- ���̺� : ORDERS
- �÷� :   ORDER_ID	    NUMBER(12,0)
           ORDER_DATE   DATE 
           ORDER_MODE	  VARCHAR2(8 BYTE)
           CUSTOMER_ID	NUMBER(6,0)
           ORDER_STATUS	NUMBER(2,0)
           ORDER_TOTAL	NUMBER(8,2)
           SALES_REP_ID	NUMBER(6,0)
           PROMOTION_ID	NUMBER(6,0)
- ������� : �⺻Ű�� ORDER_ID  
             ORDER_MODE���� 'direct', 'online'�� �Է°���
             ORDER_TOTAL�� ����Ʈ ���� 0
             
<����>
            
  CREATE TABLE ORDERS (
           ORDER_ID	    NUMBER(12,0),
           ORDER_DATE   DATE ,
           ORDER_MODE	  VARCHAR2(8 BYTE),
           CUSTOMER_ID	NUMBER(6,0),
           ORDER_STATUS	NUMBER(2,0) DEFAULT 0,
           ORDER_TOTAL	NUMBER(8,2),
           SALES_REP_ID	NUMBER(6,0),
           PROMOTION_ID	NUMBER(6,0),
           CONSTRAINT PK_ORDER PRIMARY KEY (ORDER_ID),
           CONSTRAINT CK_ORDER_MODE CHECK (ORDER_MODE in ('direct','online'))
           ); 



2. ������ ���� ������ ���̺��� ������ ����.
- ���̺� : ORDER_ITEMS 
- �÷� :   ORDER_ID	    NUMBER(12,0)
           LINE_ITEM_ID NUMBER(3,0) 
           PRODUCT_ID   NUMBER(3,0) 
           UNIT_PRICE   NUMBER(8,2) 
           QUANTITY     NUMBER(8,0)
- ������� : �⺻Ű�� ORDER_ID�� LINE_ITEM_ID
             UNIT_PRICE, QUANTITY �� ����Ʈ ���� 0
             
<����>
            
  CREATE TABLE ORDER_ITEMS (
           ORDER_ID	    NUMBER(12,0),
           LINE_ITEM_ID NUMBER(3,0) ,
           ORDER_MODE	  VARCHAR2(8 BYTE),
           PRODUCT_ID   NUMBER(3,0), 
           UNIT_PRICE   NUMBER(8,2) DEFAULT 0, 
           QUANTITY     NUMBER(8,0) DEFAULT 0,
           CONSTRAINT PK_ORDER_ITEMS PRIMARY KEY (ORDER_ID, LINE_ITEM_ID)
           ); 
           
3. ������ ���� ������ ���̺��� ������ ����.
- ���̺� : PROMOTIONS
- �÷� :   PROMO_ID	    NUMBER(6,0)
           PROMO_NAME   VARCHAR2(20) 
- ������� : �⺻Ű�� PROMO_ID

<����>

  CREATE TABLE PROMOTIONS (
           PROMO_ID	    NUMBER(12,0),
           PROMO_NAME	  VARCHAR2(8 BYTE),
           CONSTRAINT PK_PROMOTIONS PRIMARY KEY (PROMO_ID)
           ); 


4. FLOAT Ÿ���� ���, ��ȣ�ȿ� �����ϴ� ���� ������ ���� �ڸ������ �ߴ�.
   FLOAT(126)�� ��� 126 * 0.30103 = 37.92978 �� �Ǿ� NUMBER Ÿ���� 38�ڸ��� ����.
   �׷��� �� 0.30103�� ���ϴ� ���ϱ�?
   
<����>
�������� �������� ��ȯ�ϴ� ���̴�. 10���� �������� LOG(2)�� ���� �ٷ� 0.30103 �̴�.
��, 10���� 0.30103 ������ �ϸ� 2�� ������ ���̴�.


5. �ּҰ� 1, �ִ밪 99999999, 1000���� �����ؼ� 1�� �����ϴ� ORDERS_SEQ ��� �������� ������.

<����>

CREATE SEQUENCE ORDERS_SEQ  
MINVALUE 1 
MAXVALUE 99999999
INCREMENT BY 1 
START WITH 1000 
NOCACHE  
NOORDER  
NOCYCLE ;
    
