//---------------------------------------------------------------------
// TIER 2 (Standard ABAP) - Liberar con contrato C1 "Use in Cloud Development"
// Fuente: T095 (Cuentas de mayor de activos fijos por determinación)
// KTANSW = Cuenta de balance CAP (costes de adquisición y producción)
// La vista es genérica; el filtro por área de valoración AFABE = '01'
// se aplica en ZI_MM_MatPospreAcct.
//---------------------------------------------------------------------
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'T2 - Cuentas mayor activos fijos (T095)'
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #S,
  dataClass:      #CUSTOMIZING
}
define view entity ZI_FI_AssetGLAccount_T2
  as select from t095
{
  key ktopl  as ChartOfAccounts,
  key ktogr  as AssetAccountDetermination,
  key afabe  as AssetDepreciationArea,
      ktansw as AcquisitionCostAccount
}
