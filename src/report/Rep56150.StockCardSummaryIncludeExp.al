/// <summary>
/// Report Stock Card Summary-Include Exp (ID 56150).
/// </summary>
report 56150 "Stock Card Summary-Include Exp"
{
    DefaultLayout = RDLC;
    Caption = 'Stock Card Summary-Include Expected Cost';
    RDLCLayout = './LayoutReport/StockCardSummaryIncludeExoectedCost.rdl';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = all;
    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Inventory Posting Group", "Location Filter", "Global Dimension 1 Filter";
            column(ShowExp; ShowExp) { }
            column(Name_CompanyInfo; CompanyInfo.Name) { }
            column(BeginDate; BeginDate) { }
            column(EndDate; EndDate) { }
            column(LocationFilter; LocationFilter) { }
            column(Dim1Filter; Dim1Filter) { }
            column(No_Item; Item."No.") { }
            column(Description_Item; Item.Description) { }
            column(BaseUnitofMeasure_Item; Item."Base Unit of Measure") { }
            column(BegQty; BegQty) { }
            column(BegAmt; BegAmt) { }
            column(BeqQtyExp; BeqQtyExp) { }
            column(BeqAmtExp; BeqAmtExp) { }
            column(PosQty; PosQty) { }
            column(PosAmt; PosAmt) { }
            column(PosQtyExp; PosQtyExp) { }
            column(PosAmtExp; PosAmtExp) { }
            column(NegQty; ABS(NegQty)) { }
            column(NegAmt; ABS(NegAmt)) { }
            column(NegQtyExp; ABS(NegQtyExp)) { }
            column(NegAmtExp; ABS(NegAmtExp)) { }
            column(EndQty; EndQty) { }
            column(EndAmt; EndAmt) { }
            column(EndQtyExp; EndQtyExp) { }
            column(EndAmtExp; EndAmtExp) { }
            column(CostperUnit; CostperUnit) { }
            trigger OnPreDataItem()
            begin
                CompanyInfo.GET;

                CLEAR(LocationFilter);
                CLEAR(Dim1Filter);

                IF GETFILTER("Location Filter") <> '' THEN
                    LocationFilter := GETFILTER("Location Filter");

                IF GETFILTER("Global Dimension 1 Filter") <> '' THEN
                    Dim1Filter := GETFILTER("Global Dimension 1 Filter");
            end;

            trigger OnAfterGetRecord()
            begin
                CLEAR(BegQty);
                CLEAR(BegAmt);
                CLEAR(BeqQtyExp);
                CLEAR(BeqAmtExp);
                CalculateNetChange("No.", 0, BegQty, BegAmt, BeqQtyExp, BeqAmtExp);

                //Positive
                CLEAR(PosQty);
                CLEAR(PosAmt);
                CLEAR(PosAmtExp);
                CLEAR(PosQtyExp);
                CalculateNetChange("No.", 1, PosQty, PosAmt, PosQtyExp, PosAmtExp);

                //Negative
                CLEAR(NegQty);
                CLEAR(NegAmt);
                CLEAR(NegAmtExp);
                CLEAR(NegQtyExp);
                CalculateNetChange("No.", 2, NegQty, NegAmt, NegQtyExp, NegAmtExp);

                //Ending Balance
                CLEAR(EndQty);
                CLEAR(EndAmt);
                CLEAR(EndAmtExp);
                CLEAR(EndQtyExp);
                CalculateNetChange("No.", 3, EndQty, EndAmt, EndQtyExp, EndAmtExp);

                //Cost Per Unit
                CLEAR(CostperUnit);
                IF EndQty <> 0 THEN
                    CostperUnit := EndAmt / EndQty;
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
                    field(ShowExp; ShowExp)
                    {
                        ApplicationArea = all;
                        Caption = 'Show Expected';
                    }
                    field("Begin Date"; BeginDate)
                    {
                        ApplicationArea = all;
                        Caption = 'Begin Date';
                    }
                    field("End Date"; EndDate)
                    {
                        ApplicationArea = all;
                        Caption = 'Ending Date';
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        IF (BeginDate = 0D) OR (EndDate = 0D) THEN
            ERROR('Please specify date filter!');
    end;


    LOCAL procedure CalculateNetChange(ItemNo: Code[20]; "Type": Option "Beginning Balance","Positive","Negative","Ending Balance"; VAR Qty: Decimal; VAR Amt: Decimal;
    VAR QtyExp: Decimal; VAR AmtExp: Decimal)
    var
        ItemLedger: Record "Item Ledger Entry";
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
        ValueEntry.CALCSUMS("Cost Amount (Actual)", "Cost Amount (Expected)", "Item Ledger Entry Quantity");

        Qty := ValueEntry."Invoiced Quantity";
        Amt := ValueEntry."Cost Amount (Actual)";
        if ShowExp then begin
            AmtExp := ValueEntry."Cost Amount (Expected)";
            QtyExp := ValueEntry."Item Ledger Entry Quantity" - ValueEntry."Invoiced Quantity";
        end;

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
        BeqQtyExp, BeqAmtExp : Decimal;
        PosQtyExp, PosAmtExp : Decimal;

        NegQtyExp, NegAmtExp : Decimal;
        EndQtyExp, EndAmtExp : Decimal;
        CostperUnit: Decimal;
        ShowExp: Boolean;

}