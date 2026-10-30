//---------------------------------------------------------------------
// TIER 2 (Standard ABAP) - Liberar con contrato C1 "Use in Cloud Development"
// Fuente: ZTCLASE_AF (Obtener Clase de Activo Fijo ANKA-ANLKL con MBEW-BKLAS)
// Clave de la tabla: BKLAS + ANLKL + KTOPL. Se agrupa por BKLAS + KTOPL
// tomando MIN(ANLKL) para garantizar UNA clase por categoría/plan y
// evitar registros duplicados en el reporte si alguien configura más
// de una clase para la misma categoría.
// NOTA: si ZTCLASE_AF tiene versión de lenguaje "ABAP for Cloud
//       Development", esta vista va en el paquete T1 sin liberación.
//---------------------------------------------------------------------
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'T2 - Clase activo fijo por cat. valoración'
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #S,
  dataClass:      #CUSTOMIZING
}
define view entity ZI_FI_AssetClassByValCl_T2
  as select from ztclase_af
{
  key bklas       as ValuationClass,
  key ktopl       as ChartOfAccounts,
      min( anlkl ) as AssetClass
}
group by
  bklas,
  ktopl
