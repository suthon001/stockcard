/// <summary>
/// Unknown Stock Permission (ID 56150).
/// </summary>
permissionset 56150 "Stock Permission"
{
    Assignable = true;
    Caption = 'Stock Permission', MaxLength = 30;
    Permissions =
        report "Stock Card Summary-Include Exp" = X,
        Report "Stock Card Detail New" = X;
}
