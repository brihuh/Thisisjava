-- 18��. ���ν����� �̸����� ������

-- 01.���� �غ����

BEGIN

DBMS_NETWORK_ACL_ADMIN.CREATE_ACL ( 
          acl => 'my_mail.xml', 
          description => '�������ۿ� ACL',
          principal => 'ORA_USER',  -- ORA_USER�� ����ڿ��� ���� �Ҵ�
          is_grant => true,
          privilege => 'connect');

  COMMIT;
END; 


BEGIN

DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE ( 
          acl => 'my_mail.xml', 
          principal => 'ORA_USER',  -- ORA_USER�� ����ڿ��� ���� �Ҵ�
          is_grant => true,
          privilege => 'resolve');

  COMMIT;
END; 


BEGIN

DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL ( 
          acl => 'my_mail.xml', 
          host => 'localhost',  -- ȣ��Ʈ��
          lower_port => 25 );

  COMMIT;
END; 


SELECT *
FROM DBA_NETWORK_ACLS;


BEGIN
  DBMS_NETWORK_ACL_ADMIN.DROP_ACL(
       acl =>'my_mail.xml');
END;


-- 02. UTL_SMTP�� �̿��� ���� ����
-- �� ������ ���� ����

DECLARE
  vv_host    VARCHAR2(30) := 'localhost'; -- SMTP ������
  vn_port    NUMBER := 25;                -- ��Ʈ��ȣ
  vv_domain  VARCHAR2(30) := 'hong.com';
  
  vv_from    VARCHAR2(50) := 'charieh@hong.com';  -- ������ �ּ�
  vv_to      VARCHAR2(50) := 'charieh@hong.com';  -- �޴� �ּ� 
  
  c utl_smtp.connection;

  
BEGIN
  c := UTL_SMTP.OPEN_CONNECTION(vv_host, vn_port);

  UTL_SMTP.HELO(c, vv_domain); -- HELO
  
  UTL_SMTP.MAIL(c, vv_from);   -- �����»��
  UTL_SMTP.RCPT(c, vv_to);     -- �޴»��  
   
  UTL_SMTP.OPEN_DATA(c); -- ���Ϻ��� �ۼ� ���� 
  -- �� �޽����� <CR><LF>�� �и��Ѵ�. �̴� UTL_TCP.CRLF �Լ��� �̿��Ѵ�. 
  
  UTL_SMTP.WRITE_DATA(c,'From: ' || '"hong2" <charieh@hong.com>' || UTL_TCP.CRLF ); -- �����»��
  UTL_SMTP.WRITE_DATA(c,'To: ' || '"hong1" <charieh@hong.com>' || UTL_TCP.CRLF );   -- �޴»��
  UTL_SMTP.WRITE_DATA(c,'Subject: Test' || UTL_TCP.CRLF );                          -- ����
  UTL_SMTP.WRITE_DATA(c, UTL_TCP.CRLF );                                            -- �� �� ����
  UTL_SMTP.WRITE_DATA(c,'THIS IS SMTP_TEST1 ' || UTL_TCP.CRLF );                    -- ���� 
  
  UTL_SMTP.CLOSE_DATA(c); -- ���� ���� �ۼ� ����
  
  -- ����
  UTL_SMTP.QUIT(c);


EXCEPTION 
  WHEN UTL_SMTP.INVALID_OPERATION THEN
       dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.TRANSIENT_ERROR THEN
       dbms_output.put_line(' Temporary e-mail issue - try again'); 
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.PERMANENT_ERROR THEN
       dbms_output.put_line(' Permanent Error Encountered.'); 
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN OTHERS THEN 
     dbms_output.put_line(sqlerrm);
     UTL_SMTP.QUIT(c);
END;

-- �� �ѱ� ���� ����

-- �ѱ��� ������ ��� 
DECLARE
  vv_host    VARCHAR2(30) := 'localhost'; -- SMTP ������
  vn_port    NUMBER := 25;                -- ��Ʈ��ȣ
  vv_domain  VARCHAR2(30) := 'hong.com';
  
  vv_from    VARCHAR2(50) := 'charieh@hong.com';  -- ������ �ּ�
  vv_to      VARCHAR2(50) := 'charieh@hong.com';  -- �޴� �ּ� 
  
  c utl_smtp.connection;

  
BEGIN
  c := UTL_SMTP.OPEN_CONNECTION(vv_host, vn_port);

  UTL_SMTP.HELO(c, vv_domain); -- HELO
  
  UTL_SMTP.MAIL(c, vv_from);   -- �����»��
  UTL_SMTP.RCPT(c, vv_to);     -- �޴»��  
   
  UTL_SMTP.OPEN_DATA(c); -- ���Ϻ��� �ۼ� ���� 
  -- �� �޽����� <CR><LF>�� �и��Ѵ�. �̴� UTL_TCP.CRLF �Լ��� �̿��Ѵ�. 
  
  UTL_SMTP.WRITE_DATA(c,'From: ' || '"hong2" <charieh@hong.com>' || UTL_TCP.CRLF ); -- �����»��
  UTL_SMTP.WRITE_DATA(c,'To: ' || '"hong1" <charieh@hong.com>' || UTL_TCP.CRLF );   -- �޴»��
  UTL_SMTP.WRITE_DATA(c,'Subject: Test' || UTL_TCP.CRLF );                          -- ����
  UTL_SMTP.WRITE_DATA(c, UTL_TCP.CRLF );                                            -- �� �� ����
  UTL_SMTP.WRITE_DATA(c,'�ѱ� ���� �׽�Ʈ' || UTL_TCP.CRLF );                       -- ������ �ѱ۷�...
  
  UTL_SMTP.CLOSE_DATA(c); -- ���� ���� �ۼ� ����
  
  -- ����
  UTL_SMTP.QUIT(c);


EXCEPTION 
  WHEN UTL_SMTP.INVALID_OPERATION THEN
       dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.TRANSIENT_ERROR THEN
       dbms_output.put_line(' Temporary e-mail issue - try again'); 
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.PERMANENT_ERROR THEN
       dbms_output.put_line(' Permanent Error Encountered.'); 
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN OTHERS THEN 
     dbms_output.put_line(sqlerrm);
     UTL_SMTP.QUIT(c);
END;

-- �ѱ� ������ ���ֱ� ���� WRITE_RAW_DATA�� ����Ѵ�. 
DECLARE
  vv_host    VARCHAR2(30) := 'localhost'; -- SMTP ������
  vn_port    NUMBER := 25;                -- ��Ʈ��ȣ
  vv_domain  VARCHAR2(30) := 'hong.com';
  
  vv_from    VARCHAR2(50) := 'charieh@hong.com';  -- ������ �ּ�
  vv_to      VARCHAR2(50) := 'charieh@hong.com';  -- �޴� �ּ� 
  
  c utl_smtp.connection;

  
BEGIN
  c := UTL_SMTP.OPEN_CONNECTION(vv_host, vn_port);

  UTL_SMTP.HELO(c, vv_domain); -- HELO
  
  UTL_SMTP.MAIL(c, vv_from);   -- �����»��
  UTL_SMTP.RCPT(c, vv_to);     -- �޴»��  
   
  UTL_SMTP.OPEN_DATA(c); -- ���Ϻ��� �ۼ� ���� 
  -- �� �޽����� <CR><LF>�� �и��Ѵ�. �̴� UTL_TCP.CRLF �Լ��� �̿��Ѵ�. 
  
  UTL_SMTP.WRITE_DATA(c,'From: ' || '"hong2" <charieh@hong.com>' || UTL_TCP.CRLF ); -- �����»��
  UTL_SMTP.WRITE_DATA(c,'To: ' || '"hong1" <charieh@hong.com>' || UTL_TCP.CRLF );   -- �޴»��
  UTL_SMTP.WRITE_DATA(c,'Subject: Test' || UTL_TCP.CRLF );                          -- ����
  UTL_SMTP.WRITE_DATA(c, UTL_TCP.CRLF );                                            -- �� �� ����
  -- ������ �ѱ۷� �ۼ��ϰ�, �̸� RAW Ÿ������ ��ȯ�Ѵ�. 
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW('�ѱ� ���� �׽�Ʈ' || UTL_TCP.CRLF)  );
  
  UTL_SMTP.CLOSE_DATA(c); -- ���� ���� �ۼ� ����
  
  -- ����
  UTL_SMTP.QUIT(c);


EXCEPTION 
  WHEN UTL_SMTP.INVALID_OPERATION THEN
       dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.TRANSIENT_ERROR THEN
       dbms_output.put_line(' Temporary e-mail issue - try again'); 
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.PERMANENT_ERROR THEN
       dbms_output.put_line(' Permanent Error Encountered.'); 
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN OTHERS THEN 
     dbms_output.put_line(sqlerrm);
     UTL_SMTP.QUIT(c);
END;


-- �����»��, �޴»��, ����, ���� ��ü�� �ѱ۷� �Ѵ�. 
DECLARE
  vv_host    VARCHAR2(30) := 'localhost'; -- SMTP ������
  vn_port    NUMBER := 25;                -- ��Ʈ��ȣ
  vv_domain  VARCHAR2(30) := 'hong.com';
  
  vv_from    VARCHAR2(50) := 'charieh@hong.com';  -- ������ �ּ�
  vv_to      VARCHAR2(50) := 'charieh@hong.com';  -- �޴� �ּ� 
  vv_text    VARCHAR2(300);
  
  c utl_smtp.connection;

  
BEGIN
  c := UTL_SMTP.OPEN_CONNECTION(vv_host, vn_port);

  UTL_SMTP.HELO(c, vv_domain); -- HELO
  
  UTL_SMTP.MAIL(c, vv_from);   -- �����»��
  UTL_SMTP.RCPT(c, vv_to);     -- �޴»��  
   
  UTL_SMTP.OPEN_DATA(c); -- ���Ϻ��� �ۼ� ���� 
  
  vv_text := 'From: ' || '"ȫ�浿" <charieh@hong.com>' || UTL_TCP.CRLF;            -- �����»��
  vv_text :=  vv_text || 'To: ' || '"ȫ�浿" <charieh@hong.com>' || UTL_TCP.CRLF;  -- �޴� ���
  vv_text :=  vv_text || 'Subject: �ѱ�����' || UTL_TCP.CRLF;                         -- ����
  vv_text :=  vv_text || UTL_TCP.CRLF;                                            -- �� �� ����
  vv_text :=  vv_text || '�ѱ� ���� �׽�Ʈ' || UTL_TCP.CRLF;                      -- ���Ϻ���
    

  -- ���� ��ü�� �ѹ��� RAW Ÿ������ ��ȯ �� ���ϳ��� �ۼ� 
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW(vv_text)  ); 
  
  UTL_SMTP.CLOSE_DATA(c); -- ���� ���� �ۼ� ����
  
  -- ����
  UTL_SMTP.QUIT(c);


EXCEPTION 
  WHEN UTL_SMTP.INVALID_OPERATION THEN
       dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.TRANSIENT_ERROR THEN
       dbms_output.put_line(' Temporary e-mail issue - try again'); 
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.PERMANENT_ERROR THEN
       dbms_output.put_line(' Permanent Error Encountered.'); 
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN OTHERS THEN 
     dbms_output.put_line(sqlerrm);
     UTL_SMTP.QUIT(c);
END;


-- (3) HTML ���� ������
DECLARE
  vv_host    VARCHAR2(30) := 'localhost'; -- SMTP ������
  vn_port    NUMBER := 25;                -- ��Ʈ��ȣ
  vv_domain  VARCHAR2(30) := 'hong.com';  
  vv_from    VARCHAR2(50) := 'charieh@hong.com';  -- ������ �ּ�
  vv_to      VARCHAR2(50) := 'charieh@hong.com';  -- �޴� �ּ� 
  
  c utl_smtp.connection;
  vv_html    VARCHAR2(200); -- HTML �޽����� ���� ����
BEGIN
  c := UTL_SMTP.OPEN_CONNECTION(vv_host, vn_port);

  UTL_SMTP.HELO(c, vv_domain); -- HELO  
  UTL_SMTP.MAIL(c, vv_from);   -- �����»��
  UTL_SMTP.RCPT(c, vv_to);     -- �޴»��  
   
  UTL_SMTP.OPEN_DATA(c); -- ���Ϻ��� �ۼ� ���� 
  UTL_SMTP.WRITE_DATA(c,'MIME-Version: 1.0' || UTL_TCP.CRLF ); -- MIME ����
  -- Content-Type: HTML ����, �ѱ��� ����ϹǷ� ���ڼ��� euc-kr
  UTL_SMTP.WRITE_DATA(c,'Content-Type: text/html; charset="euc-kr"' || UTL_TCP.CRLF ); 
  
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW('From: ' || '"ȫ�浿" <charieh@hong.com>' || UTL_TCP.CRLF) ); -- �����»��
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW('To: ' || '"ȫ�浿" <charieh@hong.com>' || UTL_TCP.CRLF) );   -- �޴»��
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW('Subject: HTML �׽�Ʈ ����' || UTL_TCP.CRLF) );               -- ����
  UTL_SMTP.WRITE_DATA(c, UTL_TCP.CRLF );                                            -- �� �� ����
  
  -- HTML ������ �ۼ�
  vv_html := '<HEAD>
   <TITLE>HTML �׽�Ʈ</TITLE>
 </HEAD>
 <BDOY>
    <p>�� ������ <b>HTML</b> <i>����</i> ���� </p>
    <p>�ۼ��� <strong>����</strong>�Դϴ�. </p>
 </BODY>
</HTML>';

  -- ���� ���� 
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW(vv_html || UTL_TCP.CRLF)  );
  
  UTL_SMTP.CLOSE_DATA(c); -- ���� ���� �ۼ� ����  
  UTL_SMTP.QUIT(c);       -- ���� ���� ����

EXCEPTION 
  WHEN UTL_SMTP.INVALID_OPERATION THEN
       dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.TRANSIENT_ERROR THEN
       dbms_output.put_line(' Temporary e-mail issue - try again'); 
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.PERMANENT_ERROR THEN
       dbms_output.put_line(' Permanent Error Encountered.'); 
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN OTHERS THEN 
     dbms_output.put_line(sqlerrm);
     UTL_SMTP.QUIT(c);
END;


--(4) ÷������ ������
--�� ���� ó��

-- Directory ��ü ����
CREATE OR REPLACE DIRECTORY SMTP_FILE AS 'C:\ch18_file';

-- �� UTL_FILE ��Ű��

CREATE OR REPLACE FUNCTION fn_get_raw_file ( p_dir   VARCHAR2,
                                             p_file  VARCHAR2)
    RETURN RAW
IS
    vf_buffer RAW(32767);
    vf_raw    RAW(32767); --��ȯ�� ���� 
    
    vf_type  UTL_FILE.FILE_TYPE;
BEGIN
	  -- ������ ����Ʈ���� �д´�. 
	  -- p_dir : ���丮��, p_file : ���ϸ�, rb: ����Ʈ���� �б�
	  vf_type := UTL_FILE.FOPEN ( p_dir, p_file, 'rb');
	  
	  -- ������ ���µƴ��� IS_OPEN �Լ��� �̿��� Ȯ��. 
	  IF UTL_FILE.IS_OPEN ( vf_type ) THEN
	     
	     -- ������ ���� ������ �д´�. 
	     LOOP
	        BEGIN 
	           -- GET_RAW ���ν����� ������ �о� vf_buffer ������ ��´�.  
	           UTL_FILE.GET_RAW(vf_type, vf_buffer, 32767);
	           -- ��ȯ�� RAW Ÿ�� ������ vf_buffer�� �Ҵ�.
	           vf_raw := vf_raw || vf_buffer;
	           
	        EXCEPTION 
	           -- �� �̻� ������ �����Ͱ� ������ ������ ����������. 
	           WHEN NO_DATA_FOUND THEN 
	                EXIT;
	        END;
	     END LOOP;
	  
	      
	  END IF;
	  
	  -- ������ �ݴ´�. 
	  UTL_FILE.FCLOSE(vf_type);
	  
	  RETURN vf_raw;
END;  


-- �� ������ ÷���� ���� ����

DECLARE
  vv_host    VARCHAR2(30) := 'localhost'; -- SMTP ������
  vn_port    NUMBER := 25;                -- ��Ʈ��ȣ
  vv_domain  VARCHAR2(30) := 'hong.com';  
  vv_from    VARCHAR2(50) := 'charieh@hong.com';  -- ������ �ּ�
  vv_to      VARCHAR2(50) := 'charieh@hong.com';  -- �޴� �ּ� 
  
  c utl_smtp.connection;
  vv_html      VARCHAR2(200); -- HTML �޽����� ���� ����
  -- boundary ǥ�ø� ���� ����, unique�� ������ ���� ����ϸ� �ȴ�. 
  vv_boundary  VARCHAR2(50) := 'DIFOJSLKDFO.WEFOWJFOWE'; 
  
  vv_directory  VARCHAR2(30) := 'SMTP_FILE'; --������ �ִ� ���丮�� 
  vv_filename   VARCHAR2(30) := 'ch18_txt_file.txt';  -- ���ϸ�  
  vf_file_buff  RAW(32767);   -- ���� ������ ���� RAWŸ�� ���� 
  vf_temp_buff  RAW(54);
  vn_file_len   NUMBER := 0;  -- ���� ����
  
  -- �� �ٴ� �� �� �ִ� BASE64 ��ȯ�� ������ �ִ� ���� 
  vn_base64_max_len  NUMBER := 54; --76 * (3/4);
  vn_pos             NUMBER := 1; --���� ��ġ�� ��� ���� 
  -- ������ �� �پ� �ڸ� �� ����� ���� ����Ʈ �� 
  vn_divide          NUMBER := 0;
BEGIN
  c := UTL_SMTP.OPEN_CONNECTION(vv_host, vn_port);

  UTL_SMTP.HELO(c, vv_domain); -- HELO  
  UTL_SMTP.MAIL(c, vv_from);   -- �����»��
  UTL_SMTP.RCPT(c, vv_to);     -- �޴»��  
   
  UTL_SMTP.OPEN_DATA(c); -- ���Ϻ��� �ۼ� ���� 
  UTL_SMTP.WRITE_DATA(c,'MIME-Version: 1.0' || UTL_TCP.CRLF ); -- MIME ����
  -- Content-Type: multipart/mixed, boundary �Է� 
  UTL_SMTP.WRITE_DATA(c,'Content-Type: multipart/mixed; boundary="' || vv_boundary || '"' || UTL_TCP.CRLF); 
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW('From: ' || '"ȫ�浿" <charieh@hong.com>' || UTL_TCP.CRLF) ); -- �����»��
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW('To: ' || '"ȫ�浿" <charieh@hong.com>' || UTL_TCP.CRLF) );   -- �޴»��
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW('Subject: HTML ÷������ �׽�Ʈ' || UTL_TCP.CRLF) );             -- ����
  UTL_SMTP.WRITE_DATA(c, UTL_TCP.CRLF );                                            -- �� �� ����
  
  -- HTML ������ �ۼ�
  vv_html := '<HEAD>
   <TITLE>HTML �׽�Ʈ</TITLE>
 </HEAD>
 <BDOY>
    <p>�� ������ <b>HTML</b> <i>����</i> ���� </p>
    <p>÷�����ϱ��� �� <strong>����</strong>�Դϴ�. </p>
 </BODY>
</HTML>';

  -- ���� ���� 
  UTL_SMTP.WRITE_DATA(c, '--' || vv_boundary || UTL_TCP.CRLF );
  UTL_SMTP.WRITE_DATA(c, 'Content-Type: text/html;' || UTL_TCP.CRLF );
  UTL_SMTP.WRITE_DATA(c, 'charset=euc-kr' || UTL_TCP.CRLF );
  UTL_SMTP.WRITE_DATA( c, UTL_TCP.CRLF );
  UTL_SMTP.WRITE_RAW_DATA(c, UTL_RAW.CAST_TO_RAW(vv_html || UTL_TCP.CRLF)  );
  UTL_SMTP.WRITE_DATA( c, UTL_TCP.CRLF );
  
  -- ÷������ �߰� 
  UTL_SMTP.WRITE_DATA(c, '--' || vv_boundary || UTL_TCP.CRLF ); 
  -- ������ Content-Type�� application/octet-stream
  UTL_SMTP.WRITE_DATA(c,'Content-Type: application/octet-stream; name="' || vv_filename || '"' || UTL_TCP.CRLF);
  UTL_SMTP.WRITE_DATA(c,'Content-Transfer-Encoding: base64' || UTL_TCP.CRLF);
  UTL_SMTP.WRITE_DATA(c,'Content-Disposition: attachment; filename="' || vv_filename || '"' || UTL_TCP.CRLF);
  

  UTL_SMTP.WRITE_DATA(c, UTL_TCP.CRLF);

  
  -- fn_get_raw_file �Լ��� ����� ���� ������ �о�´�. 
  vf_file_buff := fn_get_raw_file(vv_directory, vv_filename);
  -- ������ �� ũ�⸦ �����´�. 
  vn_file_len := DBMS_LOB.GETLENGTH(vf_file_buff);
  
  -- ������ü ũ�Ⱑ vn_base64_max_len ���� �۴ٸ�, ���Ҵ������� vn_divide ���� ����ũ��� ���� 
  IF vn_file_len <= vn_base64_max_len THEN
     vn_divide := vn_file_len;
  ELSE -- �׷��� �ʴٸ� BASE64 ���Ҵ����� vn_base64_max_len�� ���� 
     vn_divide := vn_base64_max_len;
  END IF;
  
  -- ������ ���� ������ BASE64�� ��ȯ�� �� �᾿ ��´�. 
  vn_pos := 0;
  WHILE vn_pos < vn_file_len
  LOOP
    
    -- (������üũ�� - ����ũ��)�� ���Ҵ������� ũ�� 
    IF (vn_file_len - vn_pos) >= vn_divide then 
       vn_divide := vn_divide;
    ELSE -- �׷��� ������ ���Ҵ��� = (������üũ�� - ����ũ��)
       vn_divide := vn_file_len - vn_pos;
    END IF ;    
    
    -- ������ 54 ������ �ڸ���. 
    vf_temp_buff := UTL_RAW.SUBSTR ( vf_file_buff, vn_pos, vn_divide);
    -- BASE64 ���ڵ��� �� �� ���ϳ��� ÷�� 
    UTL_SMTP.WRITE_RAW_DATA(c, UTL_ENCODE.BASE64_ENCODE ( vf_temp_buff));
    UTL_SMTP.WRITE_DATA(c,  UTL_TCP.CRLF ); 
    
    -- vn_pos�� vn_base64_max_len �� ������ ����
    vn_pos := vn_pos + vn_divide;
  END LOOP;
  
    -- �� ������ boundary���� �հ� �ڿ� '--'�� �ݵ�� �ٿ��� �Ѵ�.
  UTL_SMTP.WRITE_DATA(c, '--' ||  vv_boundary || '--' || UTL_TCP.CRLF ); 
  
  UTL_SMTP.CLOSE_DATA(c); -- ���� ���� �ۼ� ����  
  UTL_SMTP.QUIT(c);       -- ���� ���� ����

EXCEPTION 
  WHEN UTL_SMTP.INVALID_OPERATION THEN
       dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.TRANSIENT_ERROR THEN
       dbms_output.put_line(' Temporary e-mail issue - try again'); 
       UTL_SMTP.QUIT(c);
  WHEN UTL_SMTP.PERMANENT_ERROR THEN
       dbms_output.put_line(' Permanent Error Encountered.'); 
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(c);
  WHEN OTHERS THEN 
     dbms_output.put_line(sqlerrm);
     UTL_SMTP.QUIT(c);
END;

-- 03. UTL_MAIL �� �̿��� ���� ����
-- (2) UTL_MAIL ��Ű���� ����� ���� ����

BEGIN

   UTL_MAIL.SEND (
       sender     => 'charieh@hong.com',
       recipients => 'charieh@hong.com',
       cc         => null,
       bcc        => null,
       subject    => 'UTL_MAIL ���� �׽�Ʈ',
       message    => 'UTL_MAIL�� �̿��� �����ϴ� �����Դϴ�',
       mime_type  => 'text/plain; charset=euc-kr',
       priority   => 3,
       replyto    => 'charieh@hong.com');
    
EXCEPTION WHEN OTHERS THEN
   DBMS_OUTPUT.PUT_LINE(sqlerrm);

END;

-- HTML ����
DECLARE 

  vv_html  VARCHAR2(300);
BEGIN
	
  vv_html := '<HEAD>
   <TITLE>HTML �׽�Ʈ</TITLE>
 </HEAD>
 <BDOY>
    <p>�� ������ <b>HTML</b> <i>����</i> ���� </p>
    <p> <strong>UTL_MAIL</strong> ��Ű���� ����� ���� �����Դϴ�. </p>
 </BODY>
</HTML>';

   UTL_MAIL.SEND (
       sender     => 'charieh@hong.com',
       recipients => 'charieh@hong.com',
       cc         => null,
       bcc        => null,
       subject    => 'UTL_MAIL ���� �׽�Ʈ2',
       message    => vv_html,
       mime_type  => 'text/html; charset=euc-kr',
       priority   => 1,
       replyto    => 'charieh@hong.com');
    
EXCEPTION WHEN OTHERS THEN
   DBMS_OUTPUT.PUT_LINE(sqlerrm);

END;

-- �� ÷������ ����
DECLARE 
  vv_directory  VARCHAR2(30) := 'SMTP_FILE'; --������ �ִ� ���丮�� 
  vv_filename   VARCHAR2(30) := 'ch18_txt_file.txt';  -- ���ϸ�  
  vf_file_buff  RAW(32767);   -- ���� ������ ���� RAWŸ�� ���� 
  vv_html  VARCHAR2(300);
  
BEGIN
	
  vv_html := '<HEAD>
   <TITLE>HTML �׽�Ʈ</TITLE>
 </HEAD>
 <BDOY>
    <p>�� ������ <b>HTML</b> <i>����</i> ���� </p>
    <p> <strong>UTL_MAIL</strong> ��Ű���� ����� ���� �����Դϴ�. </p>
 </BODY>
</HTML>';

   -- ���� �о����
   vf_file_buff := fn_get_raw_file(vv_directory, vv_filename);

   UTL_MAIL.SEND_ATTACH_RAW (
       sender     => 'charieh@hong.com',
       recipients => 'charieh@hong.com',
       cc         => null,
       bcc        => null,
       subject    => 'UTL_MAIL �������� �׽�Ʈ',
       message    => vv_html,
       mime_type  => 'text/html; charset=euc-kr',
       priority   => 1,
       attachment => vf_file_buff,
       att_inline => TRUE,
       att_mime_type => 'application/octet',
       att_filename  => vv_filename,
       replyto    => 'charieh@hong.com');
    
EXCEPTION WHEN OTHERS THEN
   DBMS_OUTPUT.PUT_LINE(sqlerrm);

END;