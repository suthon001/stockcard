/// <summary>
/// Report Stock Card Detail New (ID 56151).
/// </summary>
report 56151 "Stock Card Detail New"
{
    DefaultLayout = RDLC;
    RDLCLayout = './LayoutReport/StockCardDetail.rdl';
    Caption = 'Stock Card Detail (New)';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = all;
    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Inventory Posting Group", "Location Filter", "Global Dimension 1 Filter";
            column(Name_CompanyInfo; CompanyInfo.Name) { }
            column(BeginDate; BeginDate) { }
            column(EndDate; EndDate) { }
            column(LocationFilter; LocationFilter) { }
            column(Dim1Filter; Dim1Filter) { }
            column(No_Item; "No.") { }
            column(Description_Item; Description) { }
            column(BaseUnitofMeasure_Item; "Base Unit of Measure") { }
            column(CostingMethod; "Costing Method") { }
            column(InvPostingGroup; "Inventory Posting Group") { }
            column(InvPostingDescription; InvName) { }

            dataitem("Item Ledger Positive"; "Value Entry")
            {
                DataItemTableView = SORTING("Item No.", "Posting Date") WHERE("Item Ledger Entry Type" = FILTER(<> Transfer), "Item Ledger Entry Quantity" = FILTER(>= 0));
                DataItemLink = "Item No." = FIELD("No.");
                column(BeginingQty; BegQty) { }
                column(BeginingAmt; BegAmt) { }
                trigger OnPreDataItem()
                begin
                    // if not ExpacCost then
                    //      SETFILTER("Posting Date", '%1..%2', NewDate, EndDate)
                    //   else
                    SETRANGE("Posting Date", BeginDate, EndDate);
                    IF LocationFilter <> '' THEN
                        SETFILTER("Location Code", LocationFilter);

                end;

                trigger OnAfterGetRecord()
                var
                    ltItemLedgerEntry: Record "Item Ledger Entry";

                begin
                    ltItemLedgerEntry.GET("Item Ledger Entry No.");
                    // if not ExpacCost then
                    //     ltItemLedgerEntry.SETFILTER("TPP Date Filter", '%1..%2', NewDate, EndDate)
                    // else
                    ltItemLedgerEntry.SETRANGE("Posting Date", BeginDate, EndDate);
                    ltItemLedgerEntry.CalcFields("TPP Cost Amount Stock Card", "Cost Amount (Expected)");
                    if ltItemLedgerEntry."Entry Type" = ltItemLedgerEntry."Entry Type"::Purchase then
                        if not ExpacCost then
                            if ltItemLedgerEntry."TPP Cost Amount Stock Card" = 0 then
                                CurrReport.Skip();



                    TempolalyLedger.reset();
                    TempolalyLedger.SetRange("Ref. Entry No.", ltItemLedgerEntry."Entry No.");
                    if TempolalyLedger.IsEmpty then begin
                        EntryNo += 1;
                        TempolalyLedger.INIT;
                        TempolalyLedger.TRANSFERFIELDS(ltItemLedgerEntry);
                        TempolalyLedger."Posting Date" := "Posting Date";
                        if ExpacCost then
                            TempolalyLedger."TPP Cost Amount Stock Card 2" := ltItemLedgerEntry."TPP Cost Amount Stock Card" + ltItemLedgerEntry."Cost Amount (Expected)"
                        else
                            TempolalyLedger."TPP Cost Amount Stock Card 2" := ltItemLedgerEntry."TPP Cost Amount Stock Card";
                        TempolalyLedger."TPP Check Positive" := FALSE;
                        TempolalyLedger."Entry No." := EntryNo;
                        TempolalyLedger."Ref. Entry No." := ltItemLedgerEntry."Entry No.";
                        TempolalyLedger.INSERT;
                    end;

                end;
            }
            dataitem("Item Ledger Negative"; "Value Entry")
            {
                DataItemTableView = SORTING("Item No.", "Posting Date") WHERE("Item Ledger Entry Type" = FILTER(<> Transfer), "Item Ledger Entry Quantity" = FILTER(< 0));
                DataItemLink = "Item No." = FIELD("No.");
                trigger OnPreDataItem()
                begin
                    // if not ExpacCost then
                    //     SETFILTER("Posting Date", '%1..%2', NewDate, EndDate)
                    // else
                    SETRANGE("Posting Date", BeginDate, EndDate);
                    IF LocationFilter <> '' THEN
                        SETFILTER("Location Code", LocationFilter);
                end;

                trigger OnAfterGetRecord()
                var
                    ltItemLedgerEntry: Record "Item Ledger Entry";

                begin
                    ltItemLedgerEntry.GET("Item Ledger Entry No.");
                    // if not ExpacCost then
                    //     ltItemLedgerEntry.SETFILTER("TPP Date Filter", '%1..%2', NewDate, EndDate)
                    // else
                    ltItemLedgerEntry.SETRANGE("Posting Date", BeginDate, EndDate);
                    ltItemLedgerEntry.CalcFields("TPP Cost Amount Stock Card", "Cost Amount (Expected)");
                    if ltItemLedgerEntry."Entry Type" = ltItemLedgerEntry."Entry Type"::Sale then
                        if not ExpacCost then
                            if ltItemLedgerEntry."TPP Cost Amount Stock Card" = 0 then
                                CurrReport.Skip();

                    TempolalyLedger.reset();
                    TempolalyLedger.SetRange("Ref. Entry No.", ltItemLedgerEntry."Entry No.");
                    if TempolalyLedger.IsEmpty then begin
                        EntryNo += 1;
                        TempolalyLedger.INIT;
                        TempolalyLedger.TRANSFERFIELDS(ltItemLedgerEntry);
                        TempolalyLedger."Posting Date" := "Posting Date";
                        if ExpacCost then
                            TempolalyLedger."TPP Cost Amount Stock Card 2" := ltItemLedgerEntry."TPP Cost Amount Stock Card" + ltItemLedgerEntry."Cost Amount (Expected)"
                        else
                            TempolalyLedger."TPP Cost Amount Stock Card 2" := ltItemLedgerEntry."TPP Cost Amount Stock Card";
                        TempolalyLedger."TPP Check Positive" := True;
                        TempolalyLedger."Entry No." := EntryNo;
                        TempolalyLedger."Ref. Entry No." := ltItemLedgerEntry."Entry No.";
                        TempolalyLedger.INSERT;

                    end;

                end;
            }
            dataitem("Item Ledger Transfer"; "Item Ledger Entry")
            {
                DataItemTableView = SORTING("Item No.", "Posting Date") WHERE("Entry Type" = CONST(Transfer));
                DataItemLink = "Item No." = FIELD("No.");
                trigger OnPreDataItem()
                begin
                    SETRANGE("Posting Date", BeginDate, EndDate);
                    IF LocationFilter <> '' THEN
                        SETFILTER("Location Code", LocationFilter)
                    else
                        SetFilter(Quantity, '>=%1', 0);
                end;

                trigger OnAfterGetRecord()
                var
                    ItemLedgerEntry2: Record "Item Ledger Entry";
                begin
                    SETFILTER("TPP Date Filter", '%1..%2', NewDate, EndDate);
                    CALCFIELDS("TPP Cost Amount Stock Card", "Cost Amount (Expected)");
                    EntryNo += 1;
                    TempolalyLedger.INIT;
                    TempolalyLedger.TRANSFERFIELDS("Item Ledger Transfer");
                    TempolalyLedger."TPP Cost Amount Stock Card 2" := "Item Ledger Transfer"."TPP Cost Amount Stock Card";
                    TempolalyLedger."Entry No." := EntryNo;
                    TempolalyLedger."TPP TransferOrder" := TRUE;
                    TempolalyLedger."TPP Check Positive" := FALSE;
                    TempolalyLedger.INSERT;

                    ItemLedgerEntry2.RESET;
                    ItemLedgerEntry2.SETFILTER("Posting Date", '%1', "Item Ledger Transfer"."Posting Date");
                    ItemLedgerEntry2.SETFILTER("Item No.", '%1', "Item Ledger Transfer"."Item No.");
                    ItemLedgerEntry2.SETFILTER("Entry Type", '%1', "Item Ledger Transfer"."Entry Type");
                    ItemLedgerEntry2.SETFILTER("Document Type", '%1', "Item Ledger Transfer"."Document Type");
                    ItemLedgerEntry2.SETFILTER("Document No.", '%1', "Item Ledger Transfer"."Document No.");
                    ItemLedgerEntry2.SETFILTER("Entry No.", '%1', "Item Ledger Transfer"."Entry No." - 1);
                    if LocationFilter <> '' then
                        ItemLedgerEntry2.SetFilter("Location Code", LocationFilter);
                    IF ItemLedgerEntry2.FINDFIRST THEN BEGIN
                        ItemLedgerEntry2.CALCFIELDS("TPP Cost Amount Stock Card", "Cost Amount (Expected)");
                        EntryNo += 1;
                        TempolalyLedger.INIT;
                        TempolalyLedger.TRANSFERFIELDS(ItemLedgerEntry2);
                        TempolalyLedger."TPP Cost Amount Stock Card 2" := ItemLedgerEntry2."TPP Cost Amount Stock Card";
                        TempolalyLedger."Entry No." := EntryNo;
                        TempolalyLedger."TPP TransferOrder" := TRUE;
                        TempolalyLedger."TPP Check Positive" := FALSE;
                        TempolalyLedger.INSERT;

                    END;

                end;
            }
            dataitem("Temporay Item Ledger"; "Item Ledger Entry")
            {
                DataItemTableView = SORTING("Entry No.");
                UseTemporary = true;
                column(DocumentDate; FORMAT("Posting Date")) { }
                column(DocumentNo; "Document No.") { }
                column(DocDescription; DocDesc) { }
                column(DocLocation; "Location Code") { }
                column(QtyIn; PosQty) { }
                column(AmtIn; PosAmt) { }
                column(QtyOut; NegQty) { }
                column(AmtOut; NegAmt) { }
                column(QtyBal; EndQty) { }
                column(AmtBal; EndAmt) { }
                column(UnitCost; CostperUnit) { }

                trigger OnPreDataItem()
                begin
                    TempolalyLedger.RESET;
                    TempolalyLedger.SETCURRENTKEY("Posting Date", "Item No.", "Entry No.");
                    //TempolalyLedger.SETFILTER(TransferOrder,'%1',FALSE);
                    IF TempolalyLedger.FINDFIRST THEN
                        REPEAT
                            EntryNo2 += 1;
                            "Temporay Item Ledger".INIT;
                            "Temporay Item Ledger".TRANSFERFIELDS(TempolalyLedger);
                            "Temporay Item Ledger"."Entry No." := EntryNo2;
                            "Temporay Item Ledger".INSERT;
                        UNTIL TempolalyLedger.NEXT = 0;
                end;

                trigger OnAfterGetRecord()
                var
                    Customer: Record Customer;
                    Vendor: Record Vendor;
                begin
                    PosQty := 0;
                    PosAmt := 0;
                    NegQty := 0;
                    NegAmt := 0;
                    IF Quantity >= 0 THEN BEGIN
                        PosQty := Quantity;
                        PosAmt := "TPP Cost Amount Stock Card 2";
                    END ELSE BEGIN
                        NegQty := -Quantity;
                        NegAmt := -"TPP Cost Amount Stock Card 2";
                    END;
                    EndQty += Quantity;
                    EndAmt += "TPP Cost Amount Stock Card 2";
                    IF EndQty = 0 THEN
                        CostperUnit := 0
                    ELSE
                        CostperUnit := ROUND(EndAmt / EndQty, 0.00001);
                    DocDesc := '';
                    IF ("Entry Type" = "Entry Type"::Purchase) THEN BEGIN
                        IF Quantity >= 0 THEN BEGIN
                            IF Vendor.GET("Source No.") THEN
                                DocDesc := 'Receive from ' + Vendor.Name;
                        END ELSE BEGIN
                            IF Vendor.GET("Source No.") THEN
                                DocDesc := 'Return to ' + Vendor.Name;
                        END;
                    END ELSE
                        IF ("Entry Type" = "Entry Type"::Sale) THEN BEGIN
                            IF Quantity >= 0 THEN BEGIN
                                IF Customer.GET("Source No.") THEN
                                    DocDesc := 'Receive from ' + Customer.Name;
                            END ELSE BEGIN
                                IF Customer.GET("Source No.") THEN
                                    DocDesc := 'Ship to' + Customer.Name;
                            END;
                        END ELSE
                            IF ("Entry Type" = "Entry Type"::"Positive Adjmt.") THEN BEGIN
                                DocDesc := 'Adjust In';
                            END ELSE
                                IF ("Entry Type" = "Entry Type"::"Negative Adjmt.") THEN BEGIN
                                    DocDesc := 'Adjust Out';
                                END ELSE
                                    IF ("Entry Type" = "Entry Type"::Transfer) THEN BEGIN
                                        IF Quantity >= 0 THEN BEGIN
                                            DocDesc := 'Transfer In';
                                        END ELSE BEGIN
                                            DocDesc := 'Transfer Out';
                                        END;
                                    END;
                end;
            }
            trigger OnPreDataItem()
            begin
                CompanyInfo.GET;

                CLEAR(LocationFilter);
                CLEAR(Dim1Filter);

                IF GETFILTER("Location Filter") <> '' THEN
                    LocationFilter := GETFILTER("Location Filter");

                IF GETFILTER("Global Dimension 1 Filter") <> '' THEN
                    Dim1Filter := GETFILTER("Global Dimension 1 Filter");
                IF NOT "Temporay Item Ledger".ISTEMPORARY THEN
                    ERROR('Temporay Item Ledger must be Temporary table');
                IF NOT TempolalyLedger.ISTEMPORARY THEN
                    ERROR('TempolalyLedger must be Temporary table');

            end;

            trigger OnAfterGetRecord()
            begin
                IF InvPostingGroup.GET(Item."Inventory Posting Group") THEN
                    InvName := InvPostingGroup.Description;
                //+
                BalQty := 0;
                BalAmt := 0;
                BegQty := 0;
                BegAmt := 0;
                ItemLedgEntry.RESET;
                ItemLedgEntry.SETCURRENTKEY("Item No.", "Posting Date");
                ItemLedgEntry.SETRANGE("Item No.", "No.");
                ItemLedgEntry.SetFilter("Posting Date", '%1..%2', NewDate, CALCDATE('-1D', BeginDate));
                ItemLedgEntry.SETFILTER("TPP Date Filter", '%1..%2', NewDate, CALCDATE('-1D', BeginDate));
                IF LocationFilter <> '' THEN
                    ItemLedgEntry.SETFILTER("Location Code", LocationFilter);
                IF ItemLedgEntry.FIND('-') THEN
                    REPEAT
                        ItemLedgEntry.CALCFIELDS("TPP Cost Amount Stock Card");
                        BegQty += ItemLedgEntry.Quantity;
                        BegAmt += ItemLedgEntry."TPP Cost Amount Stock Card";
                    UNTIL ItemLedgEntry.NEXT = 0;
                BalQty := BegQty;
                BalAmt := BegAmt;
                EndQty := BegQty;
                EndAmt := BegAmt;
                TempolalyLedger.RESET;
                TempolalyLedger.DELETEALL;
                "Temporay Item Ledger".RESET;
                "Temporay Item Ledger".DELETEALL;
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Option)
                {
                    field("Begin Date"; BeginDate)
                    {
                        ApplicationArea = all;
                    }
                    field("End Date"; EndDate)
                    {
                        ApplicationArea = all;
                    }
                    field(ExpacCost; ExpacCost)
                    {
                        Caption = 'Include Expected Cost';
                        ApplicationArea = all;
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        IF (BeginDate = 0D) OR (EndDate = 0D) THEN
            ERROR('Please specify date filter!');
        NewDate := DMY2Date(01, 01, 01);

    end;

    LOCAL procedure CalculateNetChange(ItemNo: Code[20]; Type: Option "Beginning Balance","Positive",Negative,"Ending Balance"; VAR Qty: Decimal; VAR Amt: Decimal)
    begin
        ValueEntry.RESET;
        ValueEntry.SETCURRENTKEY("Item No.", "Global Dimension 1 Code", "Location Code", "Posting Date", "Valued Quantity");
        ValueEntry.SETRANGE("Item No.", ItemNo);
        IF Item.GETFILTER("Global Dimension 1 Filter") <> '' THEN
            ValueEntry.SETFILTER("Global Dimension 1 Code", Item.GETFILTER("Global Dimension 1 Filter"));
        IF Item.GETFILTER("Location Filter") <> '' THEN
            ValueEntry.SETFILTER("Location Code", Item.GETFILTER("Location Filter"));

        CASE Type OF
            Type::"Beginning Balance":
                ValueEntry.SETRANGE("Posting Date", 0D, BeginDate - 1);
            Type::Positive, Type::Negative:
                ValueEntry.SETRANGE("Posting Date", BeginDate, EndDate);
            Type::"Ending Balance":
                ValueEntry.SETRANGE("Posting Date", 0D, EndDate);
        END;

        CASE Type OF
            Type::Positive:
                ValueEntry.SETFILTER("Valued Quantity", '>=%1', 0);
            Type::Negative:
                ValueEntry.SETFILTER("Valued Quantity", '<%1', 0);
        END;
        ValueEntry.CALCSUMS("Invoiced Quantity");
        ValueEntry.CALCSUMS("Cost Amount (Actual)");

        Qty := ValueEntry."Invoiced Quantity";
        Amt := ValueEntry."Cost Amount (Actual)";
    end;

    var
        CompanyInfo: Record "Company Information";
        LocationFilter: Text[80];
        Dim1Filter: Text[80];
        BeginDate: Date;
        EndDate: Date;
        ValueEntry: Record "Value Entry";
        BegQty: Decimal;
        BegAmt: Decimal;
        PosQty: Decimal;
        PosAmt: Decimal;
        NegQty: Decimal;
        NegAmt: Decimal;
        EndQty: Decimal;
        EndAmt: Decimal;
        CostperUnit: Decimal;
        InvName: Text[100];
        InvPostingGroup: Record "Inventory Posting Group";
        BalQty: Decimal;
        BalAmt: Decimal;
        DocDesc: Text[100];
        ItemLedgEntry: Record "Item Ledger Entry";
        EntryNo: Integer;
        TempolalyLedger: Record "Item Ledger Entry" temporary;
        EntryNo2: Integer;
        NewDate: Date;
        ExpacCost: Boolean;

}