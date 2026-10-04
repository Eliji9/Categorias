//---------------------------------------------------------------------
// TIER 2 (Standard ABAP) - Liberar con contrato C1 "Use in Cloud Development"
// Reemplaza: SKB1-ALTKT + SKB1-TOGRU (antigua columna "Cuenta AS400")
// Fuente nueva: ZTCTAS_REGULAT (Cuentas Regulatorias)
// NOTA: si ZTCTAS_REGULAT ya fue creada con versión de lenguaje
//       "ABAP for Cloud Development", esta vista puede vivir en Tier 1
//       y no requiere liberación.
//---------------------------------------------------------------------
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'T2 - Cuentas regulatorias (ZTCTAS_REGULAT)'
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #M,
  dataClass:      #MASTER
}
define view entity ZI_FI_CtasRegulat_T2
  as select from ztctas_regulat
{
  key saknr   as GLAccount,
  key ktopl   as ChartOfAccounts,
  key bukrs   as CompanyCode,
      ctareg  as RegulatoryAccount,
      ctapuc  as PUCPANAccount,
      ctacuif as CUIFAccount,
      icp     as AssociatedGLCompany
}
