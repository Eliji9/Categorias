//---------------------------------------------------------------------
// TIER 2 (Standard ABAP) - Liberar con contrato C1 "Use in Cloud Development"
// Fuente: ANKA (Clases de activos fijos) -> KTOGR (Determinación de cuentas)
// Si en tu release I_AssetClass expone la determinación de cuentas
// (KTOGR), elimina esta vista y usa la estándar.
//---------------------------------------------------------------------
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'T2 - Clase activo fijo - Determ. cuentas (ANKA)'
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #S,
  dataClass:      #CUSTOMIZING
}
define view entity ZI_FI_AssetClassAcctDet_T2
  as select from anka
{
  key anlkl as AssetClass,
      ktogr as AssetAccountDetermination
}
