-----------------------------------------------------------------------------
--
--  Logical unit: PurchaseOrder
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


-------------------- LU CUST NEW METHODS -------------------------------------

@Override
PROCEDURE Release__ (
   info_       OUT    VARCHAR2,
   objid_      IN     VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   attr_       IN OUT VARCHAR2,
   action_     IN     VARCHAR2 )
IS
  c_po_rec_       PURCHASE_ORDER_TAB%ROWTYPE;
  c_vendor_no_    PURCHASE_ORDER_TAB.vendor_no%TYPE;
  c_quality_type_ VARCHAR2(100);
  c_env_type_     VARCHAR2(100);
  c_key_ref_      VARCHAR2(4000);
  c_doc_count_    NUMBER;

  CURSOR c_check_prel_doc IS
    SELECT COUNT(*)
      FROM DOC_REFERENCE_OBJECT_TAB a, DOC_ISSUE_TAB b
     WHERE a.doc_no = b.doc_no
       AND a.doc_class = b.doc_class
       AND a.doc_sheet = b.doc_sheet
       AND a.doc_rev = b.doc_rev
       AND lu_name = 'PurchaseOrder'
       AND key_ref =
           Client_SYS.Get_Key_Reference('PurchaseOrder',
                                        'ORDER_NO',
                                        po_rec_.order_no)
       AND b.rowstate NOT IN ('Approved', 'Released', 'Obsolete');
BEGIN
   --Add pre-processing code here
   IF (action_ = 'DO') THEN
      c_po_rec_       := Get_Object_By_Id___(objid_);
      c_vendor_no_    := po_rec_.vendor_no;
      c_quality_type_ := C_Purch_Compliance_API.Get_Quality_Type(c_vendor_no_);
      c_env_type_     := C_Purch_Compliance_API.Get_Environment_Type(c_vendor_no_);
      
      IF (c_quality_type_ IS NULL OR c_env_type_ IS NULL) THEN
        Error_SYS.Record_General(lu_name_,
                                 'C_COMP_MISSING: Supplier :P1 does not have Quality Type and/or Environment Type on the Compliance record. Update the supplier before releasing this Purchase Order.',
                                 c_vendor_no_);
      END IF;
      c_key_ref_ := Client_SYS.Get_Key_Reference('PurchaseOrder',
                                                 'ORDER_NO',
                                                 po_rec_.order_no);
      OPEN c_check_prel_doc;
      FETCH c_check_prel_doc
        INTO c_doc_count_;
      CLOSE c_check_prel_doc;

      IF (NVL(c_doc_count_, 0) > 0) THEN
        Error_SYS.Record_General(lu_name_,
                                 'C_DOC_NOT_RELEASED: Purchase Order :P1 has :P2 attached document(s) not in Released/Approved status. Approve all documents before releasing.',
                                 po_rec_.order_no,
                                 c_doc_count_);
      END IF;  
   END IF;
   super(info_, objid_, objversion_, attr_, action_);
   --Add post-processing code here
END Release__;


