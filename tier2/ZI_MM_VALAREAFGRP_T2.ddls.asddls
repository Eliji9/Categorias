//---------------------------------------------------------------------
// TIER 2 (Standard ABAP) - Liberar con contrato C1 "Use in Cloud Development"
// Reemplaza: T001K (BWKEY -> BUKRS, BWMOD)
// Motivo: I_ValuationArea no expone la agrupación de valoración (BWMOD),
//         que es la que usa OBYC/T030 en la determinación real de cuentas.
//---------------------------------------------------------------------
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'T2 - Área valoración y agrupación (T001K)'
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #S,
  dataClass:      #CUSTOMIZING
}
define view entity ZI_MM_ValAreaFGrp_T2
  as select from t001k
{
  key bwkey as ValuationArea,
      bukrs as CompanyCode,
      bwmod as ValuationGroupingCode
}
