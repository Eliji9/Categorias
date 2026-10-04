//---------------------------------------------------------------------
// TIER 2 (Standard ABAP) - Liberar con contrato C1 "Use in Cloud Development"
// Reemplaza: SKB1-FIPOS (Pospre asignada a la cuenta en la sociedad)
// Si en tu release I_GLAccountInCompanyCode expone la posición
// presupuestaria (CommitmentItem), elimina esta vista y usa la estándar.
//---------------------------------------------------------------------
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'T2 - Cuenta mayor en sociedad - Pospre (SKB1)'
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #M,
  dataClass:      #MASTER
}
define view entity ZI_FI_GLAcctCmmtItem_T2
  as select from skb1
{
  key bukrs as CompanyCode,
  key saknr as GLAccount,
      fipos as CommitmentItem
}
