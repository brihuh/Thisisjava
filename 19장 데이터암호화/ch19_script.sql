-- 19��. ���ν����� �̸����� ������
-- 01. ������ ��ȣȭ
-- (2) DBMS_CRYPTO ��Ű��

conn SYS/hong AS SYSDBA;

grant execute on DBMS_CRYPTO to public;

-- (4) ��ȣȭ �ǽ�

DECLARE
  input_string  VARCHAR2 (200) := 'The Oracle';  -- ��ȣȭ�� VARCHAR2 ������
  output_string VARCHAR2 (200); -- ��ȣȭ�� VARCHAR2 ������ 

  encrypted_raw RAW (2000); -- ��ȣȭ�� ������ 
  decrypted_raw RAW (2000); -- ��ȣȭ�� ������ 

  num_key_bytes NUMBER := 256/8; -- ��ȣȭ Ű�� ���� ���� (256 ��Ʈ, 32 ����Ʈ)
  key_bytes_raw RAW (32);        -- ��ȣȭ Ű 

  -- ��ȣȭ ��Ʈ 
  encryption_type PLS_INTEGER; 
  
BEGIN
	 -- ��ȣȭ ��Ʈ ����
	 encryption_type := DBMS_CRYPTO.ENCRYPT_AES256 + -- 256��Ʈ Ű�� ����� AES ��ȣȭ 
	                    DBMS_CRYPTO.CHAIN_CBC +      -- CBC ��� 
	                    DBMS_CRYPTO.PAD_PKCS5;       -- PKCS5�� �̷���� �е�
	
   DBMS_OUTPUT.PUT_LINE ('���� ���ڿ�: ' || input_string);

   -- RANDOMBYTES �Լ��� ����� ��ȣȭ Ű ���� 
   key_bytes_raw := DBMS_CRYPTO.RANDOMBYTES (num_key_bytes);
   
   -- ENCRYPT �Լ��� ��ȣȭ�� �Ѵ�. ���� ���ڿ��� UTL_I18N.STRING_TO_RAW�� ����� RAW Ÿ������ ��ȯ�Ѵ�. 
   encrypted_raw := DBMS_CRYPTO.ENCRYPT ( src => UTL_I18N.STRING_TO_RAW (input_string, 'AL32UTF8'),   
                                          typ => encryption_type,
                                          key => key_bytes_raw
                                        );
                                        
   -- ��ȣȭ�� RAW �����͸� �ѹ� ����غ���
   DBMS_OUTPUT.PUT_LINE('��ȣȭ�� RAW ������: ' || encrypted_raw);                                     
   -- ��ȣȭ �� �����͸� �ٽ� ��ȣȭ ( ��ȣȭ�ߴ� Ű�� ��ȣȭ ��Ʈ�� �����ϰ� ����ؾ� �Ѵ�. )
   decrypted_raw := DBMS_CRYPTO.DECRYPT ( src => encrypted_raw,
                                          typ => encryption_type,
                                          key => key_bytes_raw
                                        );
   
   -- ��ȣȭ�� RAW Ÿ�� �����͸� UTL_I18N.RAW_TO_CHAR�� ����� �ٽ� VARCHAR2�� ��ȯ 
   output_string := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
   -- ��ȣȭ�� ���ڿ� ��� 
   DBMS_OUTPUT.PUT_LINE ('��ȣȭ�� ���ڿ�: ' || output_string);
END;


-- HASH, MAC �Լ�
DECLARE

  input_string  VARCHAR2 (200) := 'The Oracle';  -- �Է� VARCHAR2 ������
  input_raw     RAW(128);                        -- �Է� RAW ������ 

  encrypted_raw RAW (2000); -- ��ȣȭ ������ 
  
  key_string VARCHAR2(8) := 'secret';  -- MAC �Լ����� ����� ��� Ű
  raw_key RAW(128) := UTL_RAW.CAST_TO_RAW(CONVERT(key_string,'AL32UTF8','US7ASCII')); -- ���Ű�� RAW Ÿ������ ��ȯ
  
BEGIN
	-- VARCHAR2�� RAW Ÿ������ ��ȯ
	input_raw := UTL_I18N.STRING_TO_RAW (input_string, 'AL32UTF8');
	
	
	DBMS_OUTPUT.PUT_LINE('----------- HASH �Լ� -------------');
	encrypted_raw := DBMS_CRYPTO.HASH( src => input_raw,
                                     typ => DBMS_CRYPTO.HASH_SH1);
                                     
  DBMS_OUTPUT.PUT_LINE('�Է� ���ڿ��� �ؽð� : ' || RAWTOHEX(encrypted_raw));   
    
  
  DBMS_OUTPUT.PUT_LINE('----------- MAC �Լ� -------------'); 
  encrypted_raw := DBMS_CRYPTO.MAC( src => input_raw,
                                    typ => DBMS_CRYPTO.HMAC_MD5,
                                    key => raw_key);   
                                    
  DBMS_OUTPUT.PUT_LINE('MAC �� : ' || RAWTOHEX(encrypted_raw));
END;


-- ���� ���Ͽ�
DECLARE
  vv_ddl VARCHAR2(1000); -- ��Ű�� �ҽ��� �����ϴ� ����
BEGIN
	-- ��Ű�� �ҽ��� vv_ddl�� ����
  vv_ddl := 'CREATE OR REPLACE PACKAGE ch19_wrap_pkg IS
                pv_key_string VARCHAR2(30) := ''OracleKey'';
             END ch19_wrap_pkg;';
             
        
  -- CREATE_WRAPPED ���ν����� ����ϸ� ��Ű�� �ҽ��� ����� �Ͱ� ���ÿ� �����ϵ� �����Ѵ�. 
  DBMS_DDL.CREATE_WRAPPED ( vv_ddl );
      
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE(SQLERRM);
END ;


BEGIN
  DBMS_OUTPUT.PUT_LINE(ch19_wrap_pkg.pv_key_string);
END;

-- 02. ������ ��ƿ��Ƽ ���α׷� �����
-- (1) �ҽ� �˻�

CREATE OR REPLACE PACKAGE my_util_pkg IS
    -- ���α׷� �ҽ� �˻� ���ν��� 
    PROCEDURE program_search_prc (ps_src_text IN VARCHAR2);
END my_util_pkg;


CREATE OR REPLACE PACKAGE BODY my_util_pkg IS

  -- ���α׷� �ҽ� �˻� ���ν���
  PROCEDURE program_search_prc (ps_src_text IN VARCHAR2)
  IS
    vs_search VARCHAR2(100);
    vs_name   VARCHAR2(1000);
  BEGIN
    -- ã�� Ű���� �յڿ� '%'�� ���δ�. 
    vs_search := '%' || NVL(ps_src_text, '%') || '%';
    
    -- dba_source���� �Էµ� Ű����� �ҽ��� �˻��Ѵ�. 
    -- �Է� Ű���尡 �빮�� Ȥ�� �ҹ��ڰ� �� �� �����Ƿ� UPPER, LOWER �Լ��� �̿��� �˻��Ѵ�. 
    FOR C_CUR IN ( SELECT name, type, line, text
                     FROM user_source
                    WHERE text like UPPER(vs_search) 
                       OR text like LOWER(vs_search)
                    ORDER BY name, type, line
                  )
    LOOP
       -- ���α׷� �̸��� �ٹ�ȣ�� ������ ����Ѵ�. 
       vs_name := C_CUR.name || ' - ' || C_CUR.type || ' - ' || C_Cur.line || ' : ' || REPLACE(C_CUR.text, CHR(10), '');
       DBMS_OUTPUT.PUT_LINE( vs_name);
    END LOOP;
  	
  END program_search_prc;
END my_util_pkg;

-- �μ����̺� �˻�
BEGIN
  my_util_pkg.program_search_prc ('departments');
END;

-- (2) ��ü �˻�
-- ��Ű�� ���� 
CREATE OR REPLACE PACKAGE BODY my_util_pkg IS

  -- ���α׷� �ҽ� �˻� ���ν���
  PROCEDURE program_search_prc (ps_src_text IN VARCHAR2)
  IS
    vs_search VARCHAR2(100);
    vs_name   VARCHAR2(1000);
  BEGIN
    ...  

  -- ��ü�˻� ���ν��� 
  PROCEDURE object_search_prc (ps_obj_name IN VARCHAR2)
  IS
    vs_search VARCHAR2(100);
    vs_name   VARCHAR2(1000);
  BEGIN
    -- ã�� Ű���� �յڿ� '%'�� ���δ�. 
    vs_search := '%' || NVL(ps_obj_name, '%') || '%';
    
    -- referenced_name �Էµ� Ű����� ������ü�� �˻��Ѵ�.  
    -- user_dependencies���� ��� �빮�ڷ� �����Ͱ� �� �����Ƿ� UPPER �Լ��� �̿��� �˻��Ѵ�. 
    FOR C_CUR IN ( SELECT name, type
                     FROM user_dependencies
                    WHERE referenced_name LIKE UPPER(vs_search) 
                    ORDER BY name, type
                  )
    LOOP
       -- ���α׷� �̸��� �ٹ�ȣ�� ������ ����Ѵ�. 
       vs_name := C_CUR.name || ' - ' || C_CUR.type ;
       DBMS_OUTPUT.PUT_LINE( vs_name);
    END LOOP;
  	
  END object_search_prc;  
END my_util_pkg;

-- �μ����̺��� �����ϴ� ��ü �˻�
BEGIN
  my_util_pkg.object_search_prc ('departments');
END;


-- (3) ���̺� ���̾ƿ� ���

  -- ���̺� Layout ���
  PROCEDURE table_layout_prc ( ps_table_name IN VARCHAR2)
  IS
    vs_table_name VARCHAR2(50) := UPPER(ps_table_name);
    vs_owner      VARCHAR2(50);
    vs_columns    VARCHAR2(300);
  BEGIN
  	BEGIN
  	  -- TABLE�� �ִ��� �˻� 
  	  SELECT OWNER
  	    INTO vs_owner
  	    FROM ALL_TABLES
    	 WHERE TABLE_NAME = vs_table_name;
  	
  	EXCEPTION WHEN NO_DATA_FOUND THEN
  	     DBMS_OUTPUT.PUT_LINE(vs_table_name || '��� ���̺��� �������� �ʽ��ϴ�');
  	     RETURN;
    END;
    
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('���̺�: ' || vs_table_name || ' , ������ : ' || vs_owner);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
  	
  	-- �÷����� �˻� �� ��� 
    FOR C_CUR IN ( SELECT column_name, data_type, data_length, nullable, data_default 
                     FROM ALL_TAB_COLS
                    WHERE table_name = vs_table_name
                    ORDER BY column_id;
                  )
    LOOP
       -- �÷� ������ ����Ѵ�. ���� ���� ��µǵ��� RPAD �Լ��� ����Ѵ�.  
       vs_columns := RPAD(C_CUR.column_name, 20) || RPAD(C_CUR.data_type, 15) || RPAD(C_CUR.data_length, 5) || RPAD(C_CUR.nullable, 2) || RPAD(C_CUR.data_default, 10);
       DBMS_OUTPUT.PUT_LINE( vs_columns);
    END LOOP;  	
  	
  END table_layout_prc;
  
-- table_layout_prc ���ν��� ����
BEGIN
  -- �μ� ���̺�� �Է� 
  my_util_pkg.table_layout_prc ('departments');  
END;



-- (4) �÷����� ���η� ���

  PROCEDURE print_col_value_prc ( ps_query IN VARCHAR2 )
  IS
      l_theCursor     INTEGER DEFAULT DBMS_SQL.OPEN_CURSOR;
      l_columnValue   VARCHAR2(4000);
      l_status        INTEGER;
      l_descTbl       DBMS_SQL.DESC_TAB;
      l_colCnt        NUMBER;
  BEGIN
      -- ���������� p_query �Ű������� �����Ƿ� �̸� �Ľ��Ѵ�. 
      DBMS_SQL.PARSE(  l_theCursor,  ps_query, DBMS_SQL.NATIVE );
      
      -- DESCRIBE_COLUMN ���ν��� : Ŀ���� ���� �÷������� DBMS_SQL.DESC_TAB �� ������ �ִ´�. 
      DBMS_SQL.DESCRIBE_COLUMNS  ( l_theCursor, l_colCnt, l_descTbl );
  
      -- ���õ� �÷� ������ŭ ������ ���� DEFINE_COLUMN ���ν����� ȣ���� �÷��� �����Ѵ�. 
      FOR i IN 1..l_colCnt 
      LOOP
          DBMS_SQL.DEFINE_COLUMN (l_theCursor, i, l_columnValue, 4000);
      END LOOP;
  
      -- ���� 
      l_status := DBMS_SQL.EXECUTE(l_theCursor);
  
      WHILE ( DBMS_SQL.FETCH_ROWS (l_theCursor) > 0 ) 
      LOOP
          -- �÷� ������ŭ �ٽ� ������ ���鼭 �÷� ���� l_columnValue ������ ��´�.
          -- DBMS_SQL.DESC_TAB �� ������ l_descTbl.COL_NAME�� �÷� ��Ī�� �ְ� 
          -- l_columnValue���� �÷� ���� ����ִ�. 
          FOR i IN 1..l_colCnt 
          LOOP
            DBMS_SQL.COLUMN_VALUE ( l_theCursor, i, l_columnValue );
            DBMS_OUTPUT.PUT_LINE  ( rpad( l_descTbl(i).COL_NAME, 30 ) || ': ' || l_columnValue );
          END LOOP;
          DBMS_OUTPUT.PUT_LINE( '-----------------' );
      END LOOP;
  
      DBMS_SQL.CLOSE_CURSOR (l_theCursor);
  
  END print_col_value_prc;


-- print_col_value_prc ���ν��� ����
BEGIN
  -- �μ� ���̺� ��ȸ  
  my_util_pkg.print_col_value_prc ('select * from departments where rownum < 3');  
END;

-- (5) �̸��� ����

CREATE OR REPLACE PACKAGE my_util_pkg IS
    -- 1. ���α׷� �ҽ� �˻� ���ν��� 
    PROCEDURE program_search_prc (ps_src_text IN VARCHAR2);
    
    -- 2. ��ü�˻� ���ν��� 
    PROCEDURE object_search_prc (ps_obj_name IN VARCHAR2);    
    
    -- 3. ���̺� Layout ���
    PROCEDURE table_layout_prc ( ps_table_name IN VARCHAR2);
    
    -- 4. �÷� ���� ���η� ��� 
    PROCEDURE print_col_value_prc ( ps_query IN VARCHAR2 );
    
    -- �̸��� ���۰� ���õ� ��Ű�� ���
    pv_host   VARCHAR2(10)  := 'localhost';  -- SMTP ������
    pn_port   NUMBER        := 25;           -- ��Ʈ��ȣ
    pv_domain VARCHAR2(30) := 'hong.com';   -- �����θ�
    
    pv_boundary VARCHAR2(50) := 'DIFOJSLKDWFEFO.WEFOWJFOWE';  -- boundary text
    pv_directory VARCHAR2(50) := 'SMTP_FILE'; --������ �ִ� ���丮��     
    
    -- 5. �̸��� ����  
    PROCEDURE email_send_prc ( ps_query IN VARCHAR2 );
    
END my_util_pkg;

PROCEDURE email_send_prc ( ps_from    IN VARCHAR2,  -- ������ ���
                             ps_to      IN VARCHAR2,  -- �޴� ���
                             ps_subject IN VARCHAR2,  -- ����
                             ps_body    IN VARCHAR2,  -- ���� 
                             ps_content IN VARCHAR2  DEFAULT 'text/plain;', -- Content-Type
                             ps_file_nm IN VARCHAR2   -- ÷������ 
                           )
  IS
    vc_con utl_smtp.connection;
    
    v_bfile        BFILE;       -- ������ ���� ���� 
    vn_bfile_size  NUMBER := 0; -- ����ũ�� 
    
    v_temp_blob    BLOB := EMPTY_BLOB; -- ������ �Űܴ��� BLOB Ÿ�� ����
    vn_blob_size   NUMBER := 0;        -- BLOB ���� ũ�� 
    vn_amount      NUMBER := 54;       -- 54 ������ ������ �߶� ���Ͽ� ���̱� ����
    v_tmp_raw      RAW(54);            -- 54 ������ �ڸ� ���ϳ����� ��� RAW Ÿ�Ժ��� 
    vn_pos         NUMBER := 1; --���� ��ġ�� ��� ���� 
    
  BEGIN
  	
    vc_con := UTL_SMTP.OPEN_CONNECTION(pv_host, pn_port);

    UTL_SMTP.HELO(vc_con, pv_domain); -- HELO  
    UTL_SMTP.MAIL(vc_con, ps_from);   -- �����»��
    UTL_SMTP.RCPT(vc_con, ps_to);     -- �޴»��  	
    
    UTL_SMTP.OPEN_DATA(vc_con); -- ���Ϻ��� �ۼ� ���� 
    UTL_SMTP.WRITE_DATA(vc_con,'MIME-Version: 1.0' || UTL_TCP.CRLF ); -- MIME ����  
    
    UTL_SMTP.WRITE_DATA(vc_con,'Content-Type: multipart/mixed; boundary="' || pv_boundary || '"' || UTL_TCP.CRLF); 
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('From: ' || ps_from || UTL_TCP.CRLF) ); -- �����»��
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('To: ' || ps_to || UTL_TCP.CRLF) );   -- �޴»��
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('Subject: ' || ps_subject || UTL_TCP.CRLF) ); -- ����
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );  -- �� �� ����  
  	
    -- ���� ���� 
    UTL_SMTP.WRITE_DATA(vc_con, '--' || pv_boundary || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, 'Content-Type: ' || ps_content || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, 'charset=euc-kr' || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW(ps_body || UTL_TCP.CRLF)  );
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );

    -- ÷�������� �ִٸ� ...
    IF ps_file_nm IS NOT NULL THEN  
    
        UTL_SMTP.WRITE_DATA(vc_con, '--' || pv_boundary || UTL_TCP.CRLF ); 
        -- ������ Content-Type�� application/octet-stream
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Type: application/octet-stream; name="' || ps_file_nm || '"' || UTL_TCP.CRLF);
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Transfer-Encoding: base64' || UTL_TCP.CRLF);
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Disposition: attachment; filename="' || ps_file_nm || '"' || UTL_TCP.CRLF);

        UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF);
        
        -- ����ó�� ����
        -- ������ �о� BFILE ������ v_bfile�� ��´�. 
        v_bfile := BFILENAME(pv_directory, ps_file_nm); 
        -- v_bfile ���� ������ �б��������� ����. 
        DBMS_LOB.OPEN(v_bfile, DBMS_LOB.LOB_READONLY); 
        -- v_bfile�� ��� ������ ũ�⸦ �����´�. 
        vn_bfile_size := DBMS_LOB.GETLENGTH(v_bfile);
        
        -- v_bfile�� BLOB ������ v_temp_blob�� ��� ���� �ʱ�ȭ 
        DBMS_LOB.CREATETEMPORARY(v_temp_blob, TRUE);
        -- v_bfile�� ��� ������ v_temp_blob �� �ű��. 
        DBMS_LOB.LOADFROMFILE(v_temp_blob, v_bfile, vn_bfile_size);
        -- v_temp_blob�� ũ�⸦ ���Ѵ�. 
        vn_blob_size := DBMS_LOB.GETLENGTH(v_temp_blob);    
        
        -- vn_pos �ʱⰪ�� 1, v_temp_blob ũ�⺸�� ���� ��� ���� 
        WHILE vn_pos < vn_blob_size 
        LOOP
            -- v_temp_blob�� ��� ������ vn_amount(54)�� �߶�  v_tmp_raw�� ��´�. 
            DBMS_LOB.READ(v_temp_blob, vn_amount, vn_pos, v_tmp_raw);
            -- �߶� v_tmp_raw�� ���Ͽ� ÷���Ѵ�. 
            UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_ENCODE.BASE64_ENCODE ( v_tmp_raw));
            UTL_SMTP.WRITE_DATA(vc_con,  UTL_TCP.CRLF );            

            v_tmp_raw := NULL;
            vn_pos := vn_pos + vn_amount;
        END LOOP;
        
        DBMS_LOB.FREETEMPORARY(v_temp_blob); -- v_temp_blob �޸� ����
        DBMS_LOB.FILECLOSE(v_bfile); -- v_bfile �ݱ�         

    END IF; -- ÷������ ó�� ���� 
    
    -- �� ������ boundary���� �հ� �ڿ� '--'�� �ݵ�� �ٿ��� �Ѵ�.
    UTL_SMTP.WRITE_DATA(vc_con, '--' ||  pv_boundary || '--' || UTL_TCP.CRLF );   
    
    UTL_SMTP.CLOSE_DATA(vc_con); -- ���� ���� �ۼ� ����  
    UTL_SMTP.QUIT(vc_con);       -- ���� ���� ����
    

  
  EXCEPTION 
    WHEN UTL_SMTP.INVALID_OPERATION THEN
         dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
         dbms_output.put_line(sqlerrm);
         UTL_SMTP.QUIT(vc_con);
    WHEN UTL_SMTP.TRANSIENT_ERROR THEN
         dbms_output.put_line(' Temporary e-mail issue - try again'); 
         UTL_SMTP.QUIT(vc_con);
    WHEN UTL_SMTP.PERMANENT_ERROR THEN
         dbms_output.put_line(' Permanent Error Encountered.'); 
         dbms_output.put_line(sqlerrm);
         UTL_SMTP.QUIT(vc_con);
    WHEN OTHERS THEN 
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(vc_con);
    	
  END email_send_prc;


DECLARE
  vv_html VARCHAR2(1000);
BEGIN
  vv_html := '<HTML> <HEAD>
   <TITLE>HTML �׽�Ʈ</TITLE>
 </HEAD>
 <BDOY>
    <p>�� ������ <b>HTML</b> <i>����</i> ���� </p>
    <p> <strong>my_util_pkg</strong> ��Ű���� email_send_prc ���ν����� ����� ���� �����Դϴ�. </p>
 </BODY>
</HTML>';

  -- �̸������� 
  my_util_pkg.email_send_prc ( ps_from => 'charieh@hong.com'
                               ,ps_to => 'charieh@hong.com'
                               ,ps_subject =>  '�׽�Ʈ ����'
                               ,ps_body => vv_html
                               ,ps_content => 'text/html;'
                               ,ps_file_nm => 'hong1.txt'
                               );
END;



-- (6) ��й�ȣ ����
-- ��й�ȣ ����
  FUNCTION fn_create_pass ( ps_input IN VARCHAR2,
                            ps_add   IN VARCHAR2 )
           RETURN RAW
  IS
    v_raw     RAW(32747);
    v_key_raw RAW(32747);
    v_input_string VARCHAR2(100);
  BEGIN
    -- Ű ���� ���� ch19_wrap_pkg ��Ű���� pv_key_string ����� ������ RAW Ÿ������ ��ȯ�Ѵ�. 
    v_key_raw := UTL_RAW.CAST_TO_RAW(ch19_wrap_pkg.pv_key_string );
    
    -- �� �� ������ ��ȭ�ϱ� ���� �� ���� �Է� �Ű������� Ư�������� $%�� ������ 
    -- MAC �Լ��� ù ��° �Ű������� �ѱ��.  
    v_input_string := ps_input || '$%' || ps_add;
    
    -- MAC �Լ��� ����� �Է� ���ڿ��� RAW Ÿ������ ��ȯ�Ѵ�. 
    v_raw := DBMS_CRYPTO.MAC (src => UTL_RAW.CAST_TO_RAW(v_input_string)
                             ,typ => DBMS_CRYPTO.HMAC_SH1
                             ,key => v_key_raw);
                             
    RETURN v_raw;
  END fn_create_pass;
  
-- ��й�ȣ üũ
  FUNCTION fn_check_pass ( ps_input IN VARCHAR2,
                           ps_add   IN VARCHAR2,
                           p_raw    IN RAW ) 
           RETURN VARCHAR2
  IS
    v_raw     RAW(32747);
    v_key_raw RAW(32747);
    v_input_string VARCHAR2(100);
    
    v_rtn VARCHAR2(10) := 'N';
  BEGIN  
    -- Ű ���� ���� ch19_wrap_pkg ��Ű���� pv_key_string ����� ������ RAW Ÿ������ ��ȯ�Ѵ�. 
    v_key_raw := UTL_RAW.CAST_TO_RAW(ch19_wrap_pkg.pv_key_string );
    
    -- �� �� ������ ��ȭ�ϱ� ���� �� ���� �Է� �Ű������� Ư�������� $%�� ������ 
    -- MAC �Լ��� ù ��° �Ű������� �ѱ��.  
    v_input_string := ps_input || '$%' || ps_add;
    
    -- MAC �Լ��� ����� �Է� ���ڿ��� RAW Ÿ������ ��ȯ�Ѵ�. 
    v_raw := DBMS_CRYPTO.MAC (src => UTL_RAW.CAST_TO_RAW(v_input_string)
                             ,typ => DBMS_CRYPTO.HMAC_SH1
                             ,key => v_key_raw);
                             
    IF v_raw = p_raw THEN
       v_rtn := 'Y';
    ELSE
       v_rtn := 'N';    
    END IF;
                             
    RETURN v_rtn;
  END fn_check_pass;  
  
-- ���̺� ����
CREATE TABLE ch19_user ( user_id   VARCHAR2(50),   -- ����ھ��̵�
                         user_name VARCHAR2(100),  -- ����ڸ�
                         pass      RAW(2000));     -- ��й�ȣ 
  
-- ��й�ȣ ���� �׽�Ʈ 
DECLARE
  vs_pass VARCHAR2(20);
BEGIN
  -- ȫ�浿�̶�� ����� �н����带 HONG �̶�� �Է��ߴٰ� �����Ѵ�. 
  vs_pass := 'HONG';
  
  -- ch19_user ���̺��� ȫ�浿�� ã�Ƴ� �Էµ� �н������ �� ������� ���̵� 
  -- fn_create_pass �Ű������� �Ѱ� ������� �޾� pass �÷��� �����Ѵ�. 
  UPDATE ch19_user
     SET pass = my_util_pkg.fn_create_pass (vs_pass , user_id)
  WHERE user_id = 'gdhong';

  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
  COMMIT;

END ;


SELECT *
FROM ch19_user;

-- ��й�ȣ üũ
DECLARE
  vs_pass VARCHAR2(20);
  v_raw raw(32747);
  
BEGIN
  -- ȫ�浿�̶�� ����� �н����带 HONG �̶�� �Է��ߴٰ� �����Ѵ�. 
  vs_pass := 'HONG';
  -- ���̺��� ȫ�浿�� �н����带 ������ v_raw ������ ��´�. 
  SELECT pass
    INTO v_raw
    FROM ch19_user
   WHERE user_id = 'gdhong';
  
  -- �Է��� �н������ ���̵� ���� ��й�ȣ�� üũ�Ѵ�. 
  IF my_util_pkg.fn_check_pass(vs_pass, 'gdhong', v_raw) = 'Y' THEN
     DBMS_OUTPUT.PUT_LINE('���̵�� ��й�ȣ�� �¾ƿ�');
  ELSE
     DBMS_OUTPUT.PUT_LINE('���̵�� ��й�ȣ�� �޶��');
  END IF;
END ;

  
 -- (7) ������ ��ȣȭ
 -- ��ȣȭŰ �����
DECLARE
  vv_ddl VARCHAR2(1000); -- ��Ű�� �ҽ��� �����ϴ� ����
BEGIN
-- ��Ű�� �ҽ��� vv_ddl�� ����
    vv_ddl := 'CREATE OR REPLACE PACKAGE ch19_wrap_pkg IS
                pv_key_string  CONSTANT VARCHAR2(30) := ''OracleKey'';
                key_bytes_raw  CONSTANT RAW(32) := ''1181C249F0F9C3343E8FF2BCCF370D3C9F70E973531DEC1C5066B54F27A507DB'';  
             END ch19_wrap_pkg;';             
        
  -- CREATE_WRAPPED ���ν����� ����ϸ� ��Ű�� �ҽ��� ����� �Ͱ� ���ÿ� �����ϵ� �����Ѵ�. 
  DBMS_DDL.CREATE_WRAPPED ( vv_ddl );
      
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE(SQLERRM);
END ;


  /* 8. ��ȣȭ �Լ� **************************************************************************************************************************/    
  FUNCTION fn_encrypt ( ps_input_string IN VARCHAR2 )
           RETURN RAW
  IS 
    encrypted_raw RAW(32747);
    v_key_raw RAW(32747);         -- ��ȣȭ Ű    
    encryption_type PLS_INTEGER;  -- ��ȣȭ ��Ʈ    
  BEGIN
    -- ��ȣȭ Ű ���� �����´�. 
    v_key_raw := ch19_wrap_pkg.key_bytes_raw;  
    
	  -- ��ȣȭ ��Ʈ ����
	  encryption_type := DBMS_CRYPTO.ENCRYPT_AES256 + -- 256��Ʈ Ű�� ����� AES ��ȣȭ 
	                     DBMS_CRYPTO.CHAIN_CBC +      -- CBC ��� 
	                     DBMS_CRYPTO.PAD_PKCS5;       -- PKCS5�� �̷���� �е� 
         
    -- ENCRYPT �Լ��� ��ȣȭ�� �Ѵ�. �Ű������� ���� ���ڿ��� UTL_I18N.STRING_TO_RAW�� ����� RAW Ÿ������ ��ȯ�Ѵ�.               
    encrypted_raw := DBMS_CRYPTO.ENCRYPT ( src => UTL_I18N.STRING_TO_RAW (ps_input_string, 'AL32UTF8'),   
                                           typ => encryption_type,
                                           key => v_key_raw
                                          );
                       
     RETURN encrypted_raw;
  END fn_encrypt;
  
  
  /* 9. ��ȣȭ �Լ� **************************************************************************************************************************/      
  FUNCTION fn_decrypt ( prw_encrypt IN RAW )
           RETURN VARCHAR2
  IS
    vs_return VARCHAR2(100);
    v_key_raw RAW(32747);         -- ��ȣȭ Ű    
    encryption_type PLS_INTEGER;  -- ��ȣȭ ��Ʈ  
    decrypted_raw   RAW (2000);   -- ��ȣȭ ������ 
  BEGIN
    -- ��ȣȭ Ű ���� �����´�. 
    v_key_raw := ch19_wrap_pkg.key_bytes_raw;    
    
	  -- ��ȣȭ ��Ʈ ����
	  encryption_type := DBMS_CRYPTO.ENCRYPT_AES256 + -- 256��Ʈ Ű�� ����� AES ��ȣȭ 
	                     DBMS_CRYPTO.CHAIN_CBC +      -- CBC ��� 
	                     DBMS_CRYPTO.PAD_PKCS5;       -- PKCS5�� �̷���� �е�  
                       
    -- �Ű������� ���� RAW Ÿ�� �����͸� �ٽ� ��ȣȭ ( ��ȣȭ�ߴ� Ű�� ��ȣȭ ��Ʈ�� �����ϰ� ����ؾ� �Ѵ�. )
    decrypted_raw := DBMS_CRYPTO.DECRYPT ( src => prw_encrypt,
                                           typ => encryption_type,
                                           key => v_key_raw
                                         );               
     -- ��ȣȭ�� RAW Ÿ�� �����͸� UTL_I18N.RAW_TO_CHAR�� ����� �ٽ� VARCHAR2�� ��ȯ 
     vs_return := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
     
     RETURN vs_return;
  END fn_decrypt;  
  
-- ��ȣȭ �׽�Ʈ
BEGIN
  -- ȫ�浿�� ��ȭ��ȣ�� ��ȣȭ�� �� �����Ѵ�. 
  UPDATE ch19_user
     SET phone_number = my_util_pkg.fn_encrypt('010-0000-0001')
   WHERE user_id = 'gdhong';
   
  COMMIT;
END;  

-- ��ȣȭ �׽�Ʈ
DECLARE 
  v_raw RAW(2000);
  vs_phone_number VARCHAR2(50);
BEGIN
  -- ȫ�浿�� ��ȭ��ȣ�� �����´�. 
  SELECT phone_number
    INTO v_raw
    FROM ch19_user
   WHERE user_id = 'gdhong';
  
  -- RAW Ÿ���� ��ȭ��ȣ�� ��ȣȭ �Լ��� �־� ���� ���������� ��ȭ��ȣ�� ��´�. 
  vs_phone_number := my_util_pkg.fn_decrypt(v_raw);
  DBMS_OUTPUT.PUT_LINE('��ȭ��ȣ : ' || vs_phone_number);
END;


-- �� MY_UTIL_PKG �ҽ�
CREATE OR REPLACE PACKAGE my_util_pkg IS
    -- 1. ���α׷� �ҽ� �˻� ���ν��� 
    PROCEDURE program_search_prc (ps_src_text IN VARCHAR2);
    
    -- 2. ��ü�˻� ���ν��� 
    PROCEDURE object_search_prc (ps_obj_name IN VARCHAR2);    
    
    -- 3. ���̺� Layout ���
    PROCEDURE table_layout_prc ( ps_table_name IN VARCHAR2);
    
    -- 4. �÷� ���� ���η� ��� 
    PROCEDURE print_col_value_prc ( ps_query IN VARCHAR2 );
    
    -- �̸��� ���۰� ���õ� ��Ű�� ���
    pv_host VARCHAR2(10)  := 'localhost';  -- SMTP ������
    pn_port NUMBER        := 25;           -- ��Ʈ��ȣ
    pv_domain VARCHAR2(30) := 'hong.com';   -- �����θ�
    
    pv_boundary VARCHAR2(50) := 'DIFOJSLKDWFEFO.WEFOWJFOWE';  -- boundary text
    pv_directory VARCHAR2(50) := 'SMTP_FILE'; --������ �ִ� ���丮��   
        
    -- 5. �̸��� ����  
    PROCEDURE email_send_prc ( ps_from    IN VARCHAR2,  
                               ps_to      IN VARCHAR2,  
                               ps_subject IN VARCHAR2, 
                               ps_body    IN VARCHAR2,  
                               ps_content IN VARCHAR2  DEFAULT 'text/plain;', 
                               ps_file_nm IN VARCHAR2  
                             );  
                             
                             
    -- 6. ��й�ȣ ����
    FUNCTION fn_create_pass ( ps_input IN VARCHAR2,
                              ps_add   IN VARCHAR2 )
             RETURN RAW;
                              
    -- 7. ��й�ȣ Ȯ��   
    FUNCTION fn_check_pass ( ps_input IN VARCHAR2,
                             ps_add   IN VARCHAR2,
                             p_raw    IN RAW )  
             RETURN VARCHAR2;       
             
    -- 8. ��ȣȭ �Լ�
    FUNCTION fn_encrypt ( ps_input_string IN VARCHAR2 )
             RETURN RAW;
             
    -- 9. ��ȣȭ �Լ�
    FUNCTION fn_decrypt ( prw_encrypt IN RAW )
             RETURN VARCHAR2;
  
END my_util_pkg;


-- ��Ű�� ����
CREATE OR REPLACE PACKAGE BODY my_util_pkg IS

  /* 1. ���α׷� �ҽ� �˻� ���ν��� *************************************************************************************/
  PROCEDURE program_search_prc (ps_src_text IN VARCHAR2)
  IS
    vs_search VARCHAR2(100);
    vs_name   VARCHAR2(1000);
  BEGIN
    -- ã�� Ű���� �յڿ� '%'�� ���δ�. 
    vs_search := '%' || NVL(ps_src_text, '%') || '%';
    
    -- dba_source���� �Էµ� Ű����� �ҽ��� �˻��Ѵ�. 
    -- �Է� Ű���尡 �빮�� Ȥ�� �ҹ��ڰ� �� �� �����Ƿ� UPPER, LOWER �Լ��� �̿��� �˻��Ѵ�. 
    FOR C_CUR IN ( SELECT name, type, line, text
                     FROM user_source
                    WHERE text like UPPER(vs_search) 
                       OR text like LOWER(vs_search)
                    ORDER BY name, type, line
                  )
    LOOP
       -- ���α׷� �̸��� �ٹ�ȣ�� ������ ����Ѵ�. 
       vs_name := C_CUR.name || ' - ' || C_CUR.type || ' - ' || C_Cur.line || ' : ' || REPLACE(C_CUR.text, CHR(10), '');
       DBMS_OUTPUT.PUT_LINE( vs_name);
    END LOOP;
  	
  END program_search_prc;
  

  /* 2. ��ü�˻� ���ν��� *************************************************************************************************/
  PROCEDURE object_search_prc (ps_obj_name IN VARCHAR2)
  IS
    vs_search VARCHAR2(100);
    vs_name   VARCHAR2(1000);
  BEGIN
    -- ã�� Ű���� �յڿ� '%'�� ���δ�. 
    vs_search := '%' || NVL(ps_obj_name, '%') || '%';
    
    -- referenced_name �Էµ� Ű����� ������ü�� �˻��Ѵ�.  
    -- user_dependencies���� ��� �빮�ڷ� �����Ͱ� �� �����Ƿ� UPPER �Լ��� �̿��� �˻��Ѵ�. 
    FOR C_CUR IN ( SELECT name, type
                     FROM user_dependencies
                    WHERE referenced_name LIKE UPPER(vs_search) 
                    ORDER BY name, type
                  )
    LOOP
       -- ���α׷� �̸��� �ٹ�ȣ�� ������ ����Ѵ�. 
       vs_name := C_CUR.name || ' - ' || C_CUR.type ;
       DBMS_OUTPUT.PUT_LINE( vs_name);
    END LOOP;
  	
  END object_search_prc;  
  
  /* 3. ���̺� Layout ��� ***********************************************************************************************/
  PROCEDURE table_layout_prc ( ps_table_name IN VARCHAR2)
  IS
    vs_table_name VARCHAR2(50) := UPPER(ps_table_name);
    vs_owner      VARCHAR2(50);
    vs_columns    VARCHAR2(300);
  BEGIN
  	BEGIN
  	  -- TABLE�� �ִ��� �˻� 
  	  SELECT OWNER
  	    INTO vs_owner
  	    FROM ALL_TABLES
    	 WHERE TABLE_NAME = vs_table_name;
  	
  	EXCEPTION WHEN NO_DATA_FOUND THEN
  	     DBMS_OUTPUT.PUT_LINE(vs_table_name || '��� ���̺��� �������� �ʽ��ϴ�');
  	     RETURN;
    END;
    
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('���̺�: ' || vs_table_name || ' , ������ : ' || vs_owner);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
  	
  	-- �÷����� �˻� �� ��� 
    FOR C_CUR IN ( SELECT column_name, data_type, data_length, nullable, data_default 
                     FROM ALL_TAB_COLS
                    WHERE table_name = vs_table_name
                    ORDER BY column_id
                  )
    LOOP
       -- �÷� ������ ����Ѵ�. ���� ���� ��µǵ��� RPAD �Լ��� ����Ѵ�.  
       vs_columns := RPAD(C_CUR.column_name, 20) || RPAD(C_CUR.data_type, 15) || RPAD(C_CUR.data_length, 5) || RPAD(C_CUR.nullable, 2) || RPAD(C_CUR.data_default, 10);
       DBMS_OUTPUT.PUT_LINE( vs_columns);
    END LOOP;  	
  	
  END table_layout_prc;
  
  
  /* 4. �÷� ���� ���η� ��� *****************************************************************************************************************************************/
  PROCEDURE print_col_value_prc ( ps_query IN VARCHAR2 )
  IS
      l_theCursor     INTEGER DEFAULT DBMS_SQL.OPEN_CURSOR;
      l_columnValue   VARCHAR2(4000);
      l_status        INTEGER;
      l_descTbl       DBMS_SQL.DESC_TAB;
      l_colCnt        NUMBER;
  BEGIN
      -- ���������� p_query �Ű������� �����Ƿ� �̸� �Ľ��Ѵ�. 
      DBMS_SQL.PARSE(  l_theCursor,  ps_query, DBMS_SQL.NATIVE );
      
      -- DESCRIBE_COLUMN ���ν��� : Ŀ���� ���� �÷������� DBMS_SQL.DESC_TAB �� ������ �ִ´�. 
      DBMS_SQL.DESCRIBE_COLUMNS  ( l_theCursor, l_colCnt, l_descTbl );
  
      -- ���õ� �÷� ������ŭ ������ ���� DEFINE_COLUMN ���ν����� ȣ���� �÷��� �����Ѵ�. 
      FOR i IN 1..l_colCnt 
      LOOP
          DBMS_SQL.DEFINE_COLUMN (l_theCursor, i, l_columnValue, 4000);
      END LOOP;
  
      -- ���� 
      l_status := DBMS_SQL.EXECUTE(l_theCursor);
  
      WHILE ( DBMS_SQL.FETCH_ROWS (l_theCursor) > 0 ) 
      LOOP
          -- �÷� ������ŭ �ٽ� ������ ���鼭 �÷� ���� l_columnValue ������ ��´�.
          -- DBMS_SQL.DESC_TAB �� ������ l_descTbl.COL_NAME�� �÷� ��Ī�� �ְ� 
          -- l_columnValue���� �÷� ���� ����ִ�. 
          FOR i IN 1..l_colCnt 
          LOOP
            DBMS_SQL.COLUMN_VALUE ( l_theCursor, i, l_columnValue );
            DBMS_OUTPUT.PUT_LINE  ( rpad( l_descTbl(i).COL_NAME, 30 ) || ': ' || l_columnValue );
          END LOOP;
          DBMS_OUTPUT.PUT_LINE( '-----------------' );
      END LOOP;
  
      DBMS_SQL.CLOSE_CURSOR (l_theCursor);
  
  END print_col_value_prc;  
  
  /* 5. �̸��� ���� **************************************************************************************************************************/
  PROCEDURE email_send_prc ( ps_from    IN VARCHAR2,  -- ������ ���
                             ps_to      IN VARCHAR2,  -- �޴� ���
                             ps_subject IN VARCHAR2,  -- ����
                             ps_body    IN VARCHAR2,  -- ���� 
                             ps_content IN VARCHAR2  DEFAULT 'text/plain;', -- Content-Type
                             ps_file_nm IN VARCHAR2   -- ÷������ 
                           )
  IS
    vc_con utl_smtp.connection;
    
    v_bfile        BFILE;       -- ������ ���� ���� 
    vn_bfile_size  NUMBER := 0; -- ����ũ�� 
    
    v_temp_blob    BLOB := EMPTY_BLOB; -- ������ �Űܴ��� BLOB Ÿ�� ����
    vn_blob_size   NUMBER := 0;        -- BLOB ���� ũ�� 
    vn_amount      NUMBER := 54;       -- 54 ������ ������ �߶� ���Ͽ� ���̱� ����
    v_tmp_raw      RAW(54);            -- 54 ������ �ڸ� ���ϳ����� ��� RAW Ÿ�Ժ��� 
    vn_pos         NUMBER := 1; --���� ��ġ�� ��� ���� 
    
  BEGIN
  	
    vc_con := UTL_SMTP.OPEN_CONNECTION(pv_host, pn_port);

    UTL_SMTP.HELO(vc_con, pv_domain); -- HELO  
    UTL_SMTP.MAIL(vc_con, ps_from);   -- �����»��
    UTL_SMTP.RCPT(vc_con, ps_to);     -- �޴»��  	
    
    UTL_SMTP.OPEN_DATA(vc_con); -- ���Ϻ��� �ۼ� ���� 
    UTL_SMTP.WRITE_DATA(vc_con,'MIME-Version: 1.0' || UTL_TCP.CRLF ); -- MIME ����  
    
    UTL_SMTP.WRITE_DATA(vc_con,'Content-Type: multipart/mixed; boundary="' || pv_boundary || '"' || UTL_TCP.CRLF); 
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('From: ' || ps_from || UTL_TCP.CRLF) ); -- �����»��
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('To: ' || ps_to || UTL_TCP.CRLF) );   -- �޴»��
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('Subject: ' || ps_subject || UTL_TCP.CRLF) ); -- ����
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );  -- �� �� ����  
  	
    -- ���� ���� 
    UTL_SMTP.WRITE_DATA(vc_con, '--' || pv_boundary || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, 'Content-Type: ' || ps_content || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, 'charset=euc-kr' || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW(ps_body || UTL_TCP.CRLF)  );
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );

    -- ÷�������� �ִٸ� ...
    IF ps_file_nm IS NOT NULL THEN  
    
        UTL_SMTP.WRITE_DATA(vc_con, '--' || pv_boundary || UTL_TCP.CRLF ); 
        -- ������ Content-Type�� application/octet-stream
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Type: application/octet-stream; name="' || ps_file_nm || '"' || UTL_TCP.CRLF);
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Transfer-Encoding: base64' || UTL_TCP.CRLF);
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Disposition: attachment; filename="' || ps_file_nm || '"' || UTL_TCP.CRLF);

        UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF);
        
        -- ����ó�� ����
        -- ������ �о� BFILE ������ v_bfile�� ��´�. 
        v_bfile := BFILENAME(pv_directory, ps_file_nm); 
        -- v_bfile ���� ������ �б��������� ����. 
        DBMS_LOB.OPEN(v_bfile, DBMS_LOB.LOB_READONLY); 
        -- v_bfile�� ��� ������ ũ�⸦ �����´�. 
        vn_bfile_size := DBMS_LOB.GETLENGTH(v_bfile);
        
        -- v_bfile�� BLOB ������ v_temp_blob�� ��� ���� �ʱ�ȭ 
        DBMS_LOB.CREATETEMPORARY(v_temp_blob, TRUE);
        -- v_bfile�� ��� ������ v_temp_blob �� �ű��. 
        DBMS_LOB.LOADFROMFILE(v_temp_blob, v_bfile, vn_bfile_size);
        -- v_temp_blob�� ũ�⸦ ���Ѵ�. 
        vn_blob_size := DBMS_LOB.GETLENGTH(v_temp_blob);    
        
        -- vn_pos �ʱⰪ�� 1, v_temp_blob ũ�⺸�� ���� ��� ���� 
        WHILE vn_pos < vn_blob_size 
        LOOP
            -- v_temp_blob�� ��� ������ vn_amount(54)�� �߶�  v_tmp_raw�� ��´�. 
            DBMS_LOB.READ(v_temp_blob, vn_amount, vn_pos, v_tmp_raw);
            -- �߶� v_tmp_raw�� ���Ͽ� ÷���Ѵ�. 
            UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_ENCODE.BASE64_ENCODE ( v_tmp_raw));
            UTL_SMTP.WRITE_DATA(vc_con,  UTL_TCP.CRLF );            

            v_tmp_raw := NULL;
            vn_pos := vn_pos + vn_amount;
        END LOOP;
        
      DBMS_LOB.FREETEMPORARY(v_temp_blob); -- v_temp_blob �޸� ����
      DBMS_LOB.FILECLOSE(v_bfile); -- v_bfile �ݱ�         

    END IF; -- ÷������ ó�� ���� 
    
    -- �� ������ boundary���� �հ� �ڿ� '--'�� �ݵ�� �ٿ��� �Ѵ�.
    UTL_SMTP.WRITE_DATA(vc_con, '--' ||  pv_boundary || '--' || UTL_TCP.CRLF );   
    
    UTL_SMTP.CLOSE_DATA(vc_con); -- ���� ���� �ۼ� ����  
    UTL_SMTP.QUIT(vc_con);       -- ���� ���� ����
    
  EXCEPTION 
    WHEN UTL_SMTP.INVALID_OPERATION THEN
         dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
         dbms_output.put_line(sqlerrm);
         UTL_SMTP.QUIT(vc_con);
    WHEN UTL_SMTP.TRANSIENT_ERROR THEN
         dbms_output.put_line(' Temporary e-mail issue - try again'); 
         UTL_SMTP.QUIT(vc_con);
    WHEN UTL_SMTP.PERMANENT_ERROR THEN
         dbms_output.put_line(' Permanent Error Encountered.'); 
         dbms_output.put_line(sqlerrm);
         UTL_SMTP.QUIT(vc_con);
    WHEN OTHERS THEN 
       dbms_output.put_line(sqlerrm);
       UTL_SMTP.QUIT(vc_con);
    	
  END email_send_prc;


  /* 6. ��й�ȣ ���� **************************************************************************************************************************/
  FUNCTION fn_create_pass ( ps_input IN VARCHAR2,
                            ps_add   IN VARCHAR2 )
           RETURN RAW
  IS
    v_raw     RAW(32747);
    v_key_raw RAW(32747);
    v_input_string VARCHAR2(100);
  BEGIN
    -- Ű ���� ���� ch19_wrap_pkg ��Ű���� pv_key_string ����� ������ RAW Ÿ������ ��ȯ�Ѵ�. 
    v_key_raw := UTL_RAW.CAST_TO_RAW(ch19_wrap_pkg.pv_key_string );
    
    -- �� �� ������ ��ȭ�ϱ� ���� �� ���� �Է� �Ű������� Ư�������� $%�� ������ 
    -- MAC �Լ��� ù ��° �Ű������� �ѱ��.  
    v_input_string := ps_input || '$%' || ps_add;
    
    -- MAC �Լ��� ����� �Է� ���ڿ��� RAW Ÿ������ ��ȯ�Ѵ�. 
    v_raw := DBMS_CRYPTO.MAC (src => UTL_RAW.CAST_TO_RAW(v_input_string)
                             ,typ => DBMS_CRYPTO.HMAC_SH1
                             ,key => v_key_raw);
                             
    RETURN v_raw;
  END fn_create_pass;
  
  /* 7. ��й�ȣ Ȯ�� **************************************************************************************************************************/
  FUNCTION fn_check_pass ( ps_input IN VARCHAR2,
                           ps_add   IN VARCHAR2,
                           p_raw    IN RAW ) 
           RETURN VARCHAR2
  IS
    v_raw     RAW(32747);
    v_key_raw RAW(32747);
    v_input_string VARCHAR2(100);
    
    v_rtn VARCHAR2(10) := 'N';
  BEGIN  
    -- Ű ���� ���� ch19_wrap_pkg ��Ű���� pv_key_string ����� ������ RAW Ÿ������ ��ȯ�Ѵ�. 
    v_key_raw := UTL_RAW.CAST_TO_RAW(ch19_wrap_pkg.pv_key_string );
    
    -- �� �� ������ ��ȭ�ϱ� ���� �� ���� �Է� �Ű������� Ư�������� $%�� ������ 
    -- MAC �Լ��� ù ��° �Ű������� �ѱ��.  
    v_input_string := ps_input || '$%' || ps_add;
    
    -- MAC �Լ��� ����� �Է� ���ڿ��� RAW Ÿ������ ��ȯ�Ѵ�. 
    v_raw := DBMS_CRYPTO.MAC (src => UTL_RAW.CAST_TO_RAW(v_input_string)
                             ,typ => DBMS_CRYPTO.HMAC_SH1
                             ,key => v_key_raw);
                             
    IF v_raw = p_raw THEN
       v_rtn := 'Y';
    ELSE
       v_rtn := 'N';    
    END IF;
                             
    RETURN v_rtn;
  END fn_check_pass;  
  
  /* 8. ��ȣȭ �Լ� **************************************************************************************************************************/    
  FUNCTION fn_encrypt ( ps_input_string IN VARCHAR2 )
           RETURN RAW
  IS 
    encrypted_raw RAW(32747);
    v_key_raw RAW(32747);         -- ��ȣȭ Ű    
    encryption_type PLS_INTEGER;  -- ��ȣȭ ��Ʈ    
  BEGIN
    -- ��ȣȭ Ű ���� �����´�. 
    v_key_raw := ch19_wrap_pkg.key_bytes_raw;  
    
	  -- ��ȣȭ ��Ʈ ����
	  encryption_type := DBMS_CRYPTO.ENCRYPT_AES256 + -- 256��Ʈ Ű�� ����� AES ��ȣȭ 
	                     DBMS_CRYPTO.CHAIN_CBC +      -- CBC ��� 
	                     DBMS_CRYPTO.PAD_PKCS5;       -- PKCS5�� �̷���� �е� 
         
    -- ENCRYPT �Լ��� ��ȣȭ�� �Ѵ�. �Ű������� ���� ���ڿ��� UTL_I18N.STRING_TO_RAW�� ����� RAW Ÿ������ ��ȯ�Ѵ�.               
    encrypted_raw := DBMS_CRYPTO.ENCRYPT ( src => UTL_I18N.STRING_TO_RAW (ps_input_string, 'AL32UTF8'),   
                                           typ => encryption_type,
                                           key => v_key_raw
                                          );
                       
     RETURN encrypted_raw;
  END fn_encrypt;
  
  /* 9. ��ȣȭ �Լ� **************************************************************************************************************************/      
  FUNCTION fn_decrypt ( prw_encrypt IN RAW )
           RETURN VARCHAR2
  IS
    vs_return VARCHAR2(100);
    v_key_raw RAW(32747);         -- ��ȣȭ Ű    
    encryption_type PLS_INTEGER;  -- ��ȣȭ ��Ʈ  
    decrypted_raw   RAW (2000);   -- ��ȣȭ ������ 
  BEGIN
    -- ��ȣȭ Ű ���� �����´�. 
    v_key_raw := ch19_wrap_pkg.key_bytes_raw;    
    
	  -- ��ȣȭ ��Ʈ ����
	  encryption_type := DBMS_CRYPTO.ENCRYPT_AES256 + -- 256��Ʈ Ű�� ����� AES ��ȣȭ 
	                     DBMS_CRYPTO.CHAIN_CBC +      -- CBC ��� 
	                     DBMS_CRYPTO.PAD_PKCS5;       -- PKCS5�� �̷���� �е�  
                       
    -- �Ű������� ���� RAW Ÿ�� �����͸� �ٽ� ��ȣȭ ( ��ȣȭ�ߴ� Ű�� ��ȣȭ ��Ʈ�� �����ϰ� ����ؾ� �Ѵ�. )
    decrypted_raw := DBMS_CRYPTO.DECRYPT ( src => prw_encrypt,
                                           typ => encryption_type,
                                           key => v_key_raw
                                         );               
     -- ��ȣȭ�� RAW Ÿ�� �����͸� UTL_I18N.RAW_TO_CHAR�� ����� �ٽ� VARCHAR2�� ��ȯ 
     vs_return := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
     
     RETURN vs_return;
  END fn_decrypt;
  
END my_util_pkg;