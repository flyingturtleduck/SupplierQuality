-----------------------------------------------------------------------------
--
--  Logical unit: CQualityType
--  Component:    PURCH
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
-----------------------------------------------------------------------------

layer Cust;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@Override
PROCEDURE Check_Delete___ (
   remrec_ IN c_quality_type_tab%ROWTYPE )
IS
BEGIN
   --Add pre-processing code here
   check_exist_list(remrec_.quality_type_id);
   super(remrec_);
   --Add post-processing code here
END Check_Delete___;



PROCEDURE check_exist_list 
   (quality_type_id_ IN VARCHAR2) 
IS
   col_name_  VARCHAR2(2000);
   view_name_ VARCHAR2(2000);
   v_sql_     VARCHAR2(2000);
   v_cursor_   SYS_REFCURSOR;
   ref_prompt_   VARCHAR2(2000);
   cnt_ NUMBER := 0;
      
   CURSOR check_delete_reference IS
    SELECT view_name, col_name
      FROM reference_sys_tab
     WHERE ref_name = 'CQualityType'
       AND option_name IN ('RESTRICTED', 'CUSTOM', 'CUSTOMLIST', 'CASCADE')
       AND Dictionary_SYS.Logical_Unit_Is_Active_Num(lu_name) = 1;
   
BEGIN
   FOR rec_ IN check_delete_reference LOOP
    col_name_  := rec_.col_name;
    view_name_ := rec_.view_name;
    v_sql_ :=   'SELECT COUNT(*)   FROM ' || view_name_ || ' 
       WHERE ' || col_name_ || ' IS NOT NULL
       AND report_sys.parse_parameter( '''||quality_type_id_||''',' || col_name_ || ') = ''TRUE''';
    @ApproveDynamicStatement;
   OPEN v_cursor_ FOR v_sql_ ;
    LOOP
      FETCH v_cursor_
        INTO cnt_;
      EXIT WHEN v_cursor_%NOTFOUND;
      IF cnt_ > 0 THEN
         ref_prompt_ := Dictionary_SYS.Get_View_Prompt_(view_name_);
         Error_SYS.Record_Constraint('CQualityType', ref_prompt_, cnt_, NULL, quality_type_id_); 

      END IF;
    END LOOP;
    CLOSE v_cursor_;
  END LOOP;
 
END check_exist_list;

-------------------- LU CUST NEW METHODS -------------------------------------
