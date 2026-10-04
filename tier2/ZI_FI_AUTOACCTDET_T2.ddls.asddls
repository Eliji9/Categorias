//---------------------------------------------------------------------
// TIER 2 (Standard ABAP) - Liberar con contrato C1 "Use in Cloud Development"
// Reemplaza: T030 (Determinación automática de cuentas - OBYC)
// No existe vista CDS liberada equivalente. La vista es genérica;
// el filtro por operación GBB se aplica en ZR_MM_MatPospre.
//---------------------------------------------------------------------
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'T2 - Determinación automática cuentas (T030)'
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #M,
  dataClass:      #CUSTOMIZING
}
define view entity ZI_FI_AutoAcctDet_T2
  as select from t030
{
  key ktopl as ChartOfAccounts,
  key ktosl as TransactionKey,
  key bwmod as ValuationGroupingCode,
  key komok as AccountModifier,
  key bklas as ValuationClass,
      konts as GLAccount,
      konth as GLAccountCredit
}
