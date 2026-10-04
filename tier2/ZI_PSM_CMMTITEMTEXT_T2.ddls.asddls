//---------------------------------------------------------------------
// TIER 2 (Standard ABAP) - Liberar con contrato C1 "Use in Cloud Development"
// Reemplaza: FMCIT (Textos de posición presupuestaria / Pospre)
//---------------------------------------------------------------------
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'T2 - Textos posición presupuestaria (FMCIT)'
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #M,
  dataClass:      #MASTER
}
define view entity ZI_PSM_CmmtItemText_T2
  as select from fmcit
{
  key fikrs as FinancialManagementArea,
  key gjahr as FiscalYear,
  key fipex as CommitmentItem,
  key spras as Language,
      bezei as CommitmentItemShortName,
      text1 as CommitmentItemName
}
