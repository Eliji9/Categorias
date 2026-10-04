//---------------------------------------------------------------------
// TIER 1 (ABAP Cloud)
// Último ejercicio con texto por Entidad CP / Pospre / Idioma.
// Corrige el reporte original, que leía FMCIT sin FIKRS ni GJAHR
// (tomaba el primer registro que encontraba).
//---------------------------------------------------------------------
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pospre - último ejercicio con texto'
@ObjectModel.usageType: {
  serviceQuality: #B,
  sizeCategory:   #M,
  dataClass:      #MASTER
}
define view entity ZI_PSM_CmmtItemLastYr
  as select from ZI_PSM_CmmtItemText_T2
{
  key FinancialManagementArea,
  key CommitmentItem,
  key Language,
      max( FiscalYear ) as FiscalYear
}
group by
  FinancialManagementArea,
  CommitmentItem,
  Language
