<��������>

�� �̹� ���� ���������� 1�� ���ε�, �� ������ �� �������� �̹� �忡�� ��� ��� ������ ����Ǿ� �ֱ� �����̴�.  

1. UTL_SMTP�� ���� UTL_MAIL ��Ű���� ������ ���ٴ� ���� �ڸ��� ����̴�. UTL_MAIL.SEND_ATTACH_RAW ���ν����� ������ �Ű������� ������ �����  
�ϴ� ���ν����� ������ ������. ��, UTL_SMTP�� ����� ���� ���α׷����� ����ؾ� �Ѵ�. 

<����>


    
CREATE OR REPLACE PROCEDURE ch18_send_mail ( ps_from    IN VARCHAR2,  -- ������ ���
                                             ps_to      IN VARCHAR2,  -- �޴� ���
                                             ps_subject IN VARCHAR2,  -- ����
                                             ps_body    IN VARCHAR2,  -- ���� 
                                             ps_content IN VARCHAR2  DEFAULT 'text/plain;', -- Content-Type
                                             ps_file_nm IN VARCHAR2   -- ÷������ 
                                          )    
 IS
    vc_con utl_smtp.connection;
     
    vv_host    VARCHAR2(30)   := 'localhost'; -- SMTP ������
    vn_port    NUMBER := 25;                -- ��Ʈ��ȣ
    vv_domain  VARCHAR2(30)   := 'hong.com';
    vv_directory VARCHAR2(30) := 'SMTP_FILE';
    vv_boundary VARCHAR2(50) := 'DIFOJSLKDWFEFO.WEFOWJFOWE';  -- boundary text
   
    vf_file_buff  RAW(32767);   -- ���� ������ ���� RAWŸ�� ���� 
    vf_temp_buff  RAW(54);
    vn_file_len   NUMBER := 0;  -- ���� ����
    
    -- �� �ٴ� �� �� �ִ� BASE64 ��ȯ�� ������ �ִ� ���� 
    vn_base64_max_len  NUMBER := 54; --76 * (3/4);
    vn_pos             NUMBER := 1; --���� ��ġ�� ��� ���� 
    -- ������ �� �پ� �ڸ� �� ����� ���� ����Ʈ �� 
    vn_divide          NUMBER := 0;  
  BEGIN
  	
    vc_con := UTL_SMTP.OPEN_CONNECTION(vv_host, vn_port);

    UTL_SMTP.HELO(vc_con, vv_domain); -- HELO  
    UTL_SMTP.MAIL(vc_con, ps_from);   -- �����»��
    UTL_SMTP.RCPT(vc_con, ps_to);     -- �޴»��  	
    
    UTL_SMTP.OPEN_DATA(vc_con); -- ���Ϻ��� �ۼ� ���� 
    UTL_SMTP.WRITE_DATA(vc_con,'MIME-Version: 1.0' || UTL_TCP.CRLF ); -- MIME ����  
    
    UTL_SMTP.WRITE_DATA(vc_con,'Content-Type: multipart/mixed; boundary="' || vv_boundary || '"' || UTL_TCP.CRLF); 
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('From: ' || ps_from || UTL_TCP.CRLF) ); -- �����»��
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('To: ' || ps_to || UTL_TCP.CRLF) );   -- �޴»��
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW('Subject: ' || ps_subject || UTL_TCP.CRLF) ); -- ����
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );  -- �� �� ����  
  	
    -- ���� ���� 
    UTL_SMTP.WRITE_DATA(vc_con, '--' || vv_boundary || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, 'Content-Type: ' || ps_content || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, 'charset=euc-kr' || UTL_TCP.CRLF );
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );
    UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_RAW.CAST_TO_RAW(ps_body || UTL_TCP.CRLF)  );
    UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF );
    
    -- ÷�������� �ִٸ� ...
    IF ps_file_nm IS NOT NULL THEN  
    
        UTL_SMTP.WRITE_DATA(vc_con, '--' || vv_boundary || UTL_TCP.CRLF ); 
        -- ������ Content-Type�� application/octet-stream
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Type: application/octet-stream; name="' || ps_file_nm || '"' || UTL_TCP.CRLF);
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Transfer-Encoding: base64' || UTL_TCP.CRLF);
        UTL_SMTP.WRITE_DATA(vc_con,'Content-Disposition: attachment; filename="' || ps_file_nm || '"' || UTL_TCP.CRLF);
        
      
        UTL_SMTP.WRITE_DATA(vc_con, UTL_TCP.CRLF);
      
        
        -- fn_get_raw_file �Լ��� ����� ���� ������ �о�´�. 
        vf_file_buff := fn_get_raw_file(vv_directory, ps_file_nm);
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
          UTL_SMTP.WRITE_RAW_DATA(vc_con, UTL_ENCODE.BASE64_ENCODE ( vf_temp_buff));
          UTL_SMTP.WRITE_DATA(vc_con,  UTL_TCP.CRLF ); 
          
          -- vn_pos�� vn_base64_max_len �� ������ ����
          vn_pos := vn_pos + vn_divide;
        END LOOP;
    
    END IF; -- ÷������ ó�� ���� 
    
    -- �� ������ boundary���� �հ� �ڿ� '--'�� �ݵ�� �ٿ��� �Ѵ�.
    UTL_SMTP.WRITE_DATA(vc_con, '--' ||  vv_boundary || '--' || UTL_TCP.CRLF );   
    
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
    	
  END;

       
       
       
-- ���ν��� ����
BEGIN
	
	ch18_send_mail ( ps_from    => 'charieh@hong.com'
                  ,ps_to      => 'charieh@hong.com'
                  ,ps_subject => '��������'
                  ,ps_body    => 'Test mail'
                  ,ps_content => 'text/plain;'
                  ,ps_file_nm => 'ch18_txt_file.txt'
                 )   
END;       
