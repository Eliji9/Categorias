//---------------------------------------------------------------------
// TIER 1 (ABAP Cloud)
// Texto vigente de la Pospre (ejercicio más reciente).
//---------------------------------------------------------------------
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pospre - texto vigente'
@ObjectModel.usageType: {
  serviceQuality: #B,
  sizeCategory:   #M,
  dataClass:      #MASTER
}
define view entity ZI_PSM_CmmtItemTextCur
  as select from ZI_PSM_CmmtItemLastYr  as LastYear
    inner join   ZI_PSM_CmmtItemText_T2 as CmmtText
      on  CmmtText.FinancialManagementArea = LastYear.FinancialManagementArea
      and CmmtText.CommitmentItem          = LastYear.CommitmentItem
      and CmmtText.Language                = LastYear.Language
      and CmmtText.FiscalYear              = LastYear.FiscalYear
{
  key LastYear.FinancialManagementArea,
  key LastYear.CommitmentItem,
  key LastYear.Language,
      CmmtText.CommitmentItemName
}
