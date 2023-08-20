/// <summary>
/// TableExtension Item Ledger (ID 56150) extends Record Item Ledger Entry.
/// </summary>
tableextension 56150 "Item Ledger" extends "Item Ledger Entry"
{
    fields
    {
        field(56150; "Ref. Entry No."; Integer)
        {
            Caption = 'Ref. Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
