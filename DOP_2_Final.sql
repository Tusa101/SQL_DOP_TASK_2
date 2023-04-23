VERIFY OFF;
UNDEFINE input_str;
DECLARE
    --���������� ������� ������
    v_input_cells_to_pass VARCHAR2(384):= LOWER('&&input_str');
--���������� ������� �����
    v_cells_to_pass_cnt NUMBER(2):= REGEXP_COUNT(LOWER('&input_str'), '((a|b|c|d|e|f|g|h)(1|2|3|4|5|6|7|8))|
                                                                       ((a|b|c|d|e|f|g|h)(1|2|3|4|5|6|7|8)\s)');
    --���������� ����� � ��������, ��������� � ��������� ������ (������ ������)
    TYPE rec_type_cell IS RECORD 
-- ����� to_pass_left  ������������� ���������� �����,������� �������� �������� ����
    (row_num   NUMBER(2), col_num   NUMBER(2), to_pass_left   NUMBER(2)); 
--��� ������ � ��������
    TYPE type_list IS
        TABLE OF rec_type_cell; 
--��� ������ ������� � ��������
    TYPE type_list_2D IS
        TABLE OF type_list; 
    arr_cells_to_pass          type_list := type_list(); 
    arr_2D_paths               type_list_2D := type_list_2D(); 
    --��������������� ����������
   -- ����������� ����
 v_shortest_path            NUMBER := 65; 
    v_iterator                 NUMBER := 0; 
   -- ���������� ���������� ������������� ������
    v_cell_exists              BOOLEAN;
   -- ���������� ��� ��������� ������� ������� ������
    v_current_cell_to_pass     VARCHAR(1000);
    v_last_cell                rec_type_cell;
    v_new_cell                 rec_type_cell;
    v_temp_path                type_list := type_list();
    --������ �������� �����
    arr_ended_paths        type_list_2D := type_list_2D(); 
    --�������, ������������ ��������� ����������� �������� ���� (�������� 8 ������ �� ��������)
    TYPE type_num_arr  IS TABLE OF NUMBER(2);
    arr_possible_ways_rows type_num_arr:= type_num_arr(-2, -2, 2, 2, -1, 1, -1, 1);
    arr_possible_ways_cols type_num_arr:= type_num_arr(-1, 1, -1, 1, -2, -2, 2, 2);
    
    
    --������� ��� ������
--��� ������ ��� �������� ����������������� �����
    TYPE type_mini_desk IS RECORD 
    ( a   NUMBER(2), b   NUMBER(2), c   NUMBER(2),
      d   NUMBER(2), e   NUMBER(2), f   NUMBER(2),
      g   NUMBER(2), h   NUMBER(2));
    TYPE type_desk IS 
    TABLE OF type_mini_desk;
--������ �����
    rec_desk                  type_mini_desk;
--������ �����
    arr_desk_of_desks         type_desk := type_desk();
BEGIN
    --��������� ������� ������, ��������� ����������� ��������� �� ������������, �������� ����� ����� �����������
    v_temp_path.extend(1);
    arr_cells_to_pass.extend(v_cells_to_pass_cnt);
    arr_2D_paths.extend(v_cells_to_pass_cnt);
    FOR i IN 1..v_cells_to_pass_cnt LOOP
--���������� ����� ��������� ���������� ������� ������ � ������ ������� �����
        v_current_cell_to_pass := regexp_substr(v_input_cells_to_pass, '\w\d', 1, i);
        arr_cells_to_pass(i).to_pass_left := v_cells_to_pass_cnt - 1;
        --�������������� ���������
        arr_cells_to_pass(i).row_num := 9-TO_NUMBER(substr(v_current_cell_to_pass, 2, 1));
        --��������� ���������� �������� �� ��������
        arr_cells_to_pass(i).col_num :=
            CASE substr(v_current_cell_to_pass, 1, 1)
                WHEN 'a' THEN 1
                WHEN 'b' THEN 2
                WHEN 'c' THEN 3
                WHEN 'd' THEN 4
                WHEN 'e' THEN 5
                WHEN 'f' THEN 6
                WHEN 'g' THEN 7
                WHEN 'h' THEN 8
            END;
        v_temp_path(1) := arr_cells_to_pass(i);
        arr_2D_paths(i) := v_temp_path;
    END LOOP;

    v_iterator := arr_2D_paths.first;
--���� ��� ��������� ���� ��������� ����� �� ������ ������ ����� ��� ������
    WHILE v_iterator <= arr_2D_paths.last LOOP
       --������� ������ ��� ���������� ��������� ���� ����� ��������� ���� ��� ��������� ����� 
       IF arr_2D_paths(v_iterator).count = v_shortest_path THEN
            EXIT;
        END IF;
        --����������� ��������� ������ ���� ��� ������������ �����������
        v_temp_path := arr_2D_paths(v_iterator);
        v_last_cell := v_temp_path(v_temp_path.last);
        v_temp_path.extend(1);
        --����������� ������ ���� ���������: ��-�� �������������� ��� ������� � ������ ������, ��� ���������� ��������� ����, ������������ ������ �� ���� ����������, ��� ������� ����� ��� ��������� ����� 2
        IF v_shortest_path < 65 AND v_last_cell.to_pass_left>2 THEN
            v_iterator:=v_iterator + 1; 
            CONTINUE;
        END IF;
        
        --���������� � ���������� ����� ����� � ���� ��� ����������� ��������
        FOR i IN 1..8 LOOP
--������ � ��������� ��������� �����
            v_new_cell.row_num:=v_last_cell.row_num + arr_possible_ways_rows(i);
            v_new_cell.col_num:=v_last_cell.col_num + arr_possible_ways_cols(i);
            v_new_cell.to_pass_left:= v_last_cell.to_pass_left;
            
            --�������� �� ����� �� ������� ��������� �����
            IF v_new_cell.col_num < 1 OR v_new_cell.col_num > 8 OR v_new_cell.row_num < 1 OR v_new_cell.row_num > 8 THEN
                CONTINUE;
            END IF;
            
            --��������, ���� �� ��� ������ ������ � ������ ����
            v_cell_exists := true;
            FOR j IN v_temp_path.first..v_temp_path.last LOOP 
                IF ( v_temp_path(j).row_num = v_new_cell.row_num ) 
                AND ( v_temp_path(j).col_num = v_new_cell.col_num ) THEN
                    v_cell_exists := false;
                    EXIT;
                END IF;
            END LOOP;
           
            -- �������� �� ������������� ������ � ���� � �� ����������
            IF v_cell_exists THEN
		--���� �������� ����� ������ �� ���������� �� � ������ ������� �����
--���� ������ ������ �������� �������, �� � ����� ������ ���������� �� ���������� ������� ����� ��������� �� 1
                FOR j IN arr_cells_to_pass.first..arr_cells_to_pass.last LOOP 
                    IF ( arr_cells_to_pass(j).row_num = v_new_cell.row_num ) 
                    AND ( arr_cells_to_pass(j).col_num = v_new_cell.col_num ) THEN
                        v_new_cell.to_pass_left := v_last_cell.to_pass_left - 1;
                        EXIT;
                    END IF;
                END LOOP;
--��������� ����� ������ � ������� ����
                v_temp_path(v_temp_path.last) := v_new_cell;
--��������� ������ ���� � ������ ���� ��������� �����
                arr_2D_paths.extend(1);
                arr_2D_paths(arr_2D_paths.last) := v_temp_path;
--���������� ������ ���� � ������ ��������  ����� ��� ������� ����������� ���� ������� �����
                IF v_new_cell.to_pass_left = 0 THEN
                    v_shortest_path := v_temp_path.count;
                    arr_ended_paths.extend(1);
                    arr_ended_paths(arr_ended_paths.last) := v_temp_path;
                END IF;
            END IF;
        END LOOP;
        v_iterator := v_iterator + 1;
    END LOOP;
    
    --����� ��������� �����
dbms_output.put_line('-----------------------------------------------------------------------------');dbms_output.put_line('-----------------------------------------------------------------------------');
    FOR i IN arr_ended_paths.first..arr_ended_paths.last LOOP
--���������� � ������ ����� ����� ����� 
        arr_desk_of_desks := type_desk();
        arr_desk_of_desks.extend(8);
        v_temp_path := arr_ended_paths(i);
        FOR j IN v_temp_path.first..v_temp_path.last LOOP
          --� ������ ����� � ����� ������������� ��������� �����, �.�. � ������, ������� ������������� ������� ����, ������������ �� ���������� ����� � ������ 
 v_last_cell := v_temp_path(j);
            CASE WHEN v_last_cell.col_num = 1 THEN
                 arr_desk_of_desks(v_last_cell.row_num).a := j;
                 WHEN v_last_cell.col_num = 2 THEN
                 arr_desk_of_desks(v_last_cell.row_num).b := j;
                 WHEN v_last_cell.col_num = 3 THEN
                 arr_desk_of_desks(v_last_cell.row_num).c := j;   
                 WHEN v_last_cell.col_num = 4 THEN
                 arr_desk_of_desks(v_last_cell.row_num).d := j;
                 WHEN v_last_cell.col_num = 5 THEN
                 arr_desk_of_desks(v_last_cell.row_num).e := j;
                 WHEN v_last_cell.col_num = 6 THEN
                 arr_desk_of_desks(v_last_cell.row_num).f := j;
                 WHEN v_last_cell.col_num = 7 THEN
                 arr_desk_of_desks(v_last_cell.row_num).g := j;
                 WHEN v_last_cell.col_num = 8 THEN
                 arr_desk_of_desks(v_last_cell.row_num).h := j;
            END CASE;
        END LOOP;
--�������������� ������
        dbms_output.put_line('   H  G  F  E  D  C  B  A   ');
        FOR j IN 1..8 LOOP
--����� ����� ��������� ��� �������, ��� � ������ ������ ���� ��� �������, ���� ����� ����� 2 (0x ��� xx)
            rec_desk := arr_desk_of_desks(j);
            dbms_output.put(9-j);
            dbms_output.put(' |' || nvl(lpad(rec_desk.a, 2, '0'), '  ') || '|'
                                 || nvl(lpad(rec_desk.b, 2, '0'), '  ') || '|'
                                 || nvl(lpad(rec_desk.c, 2, '0'), '  ') || '|'
                                 || nvl(lpad(rec_desk.d, 2, '0'), '  ') || '|'
                                 || nvl(lpad(rec_desk.e, 2, '0'), '  ') || '|'
                                 || nvl(lpad(rec_desk.f, 2, '0'), '  ') || '|'
                                 || nvl(lpad(rec_desk.g, 2, '0'), '  ') || '|'
                                 || nvl(lpad(rec_desk.h, 2, '0'), '  ') || '|');
            dbms_output.put_line(j);
        END LOOP;
        dbms_output.put_line('   A  B  C  D  E  F  G  H   ');
        dbms_output.put_line(' ');
    END LOOP;
END;
/
